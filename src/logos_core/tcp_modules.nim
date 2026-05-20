# src/logos_core/tcp_modules.nim

{.push raises: [], gcsafe.}

import ./[cbor_stuff, iface, transport, tcp_protocols]

import results, stew/endians2
import std/[net, os, strutils, sequtils]

export cbor_stuff

type
  TcpModule* = ref object
    host*: string
    port*: int
    moduleName*: string
    version*: string
    schema*: string
    client*: Socket

proc init*(_: type TcpModule, target: string): Result[TcpModule, string] =
  let targetRes = parseTcpTarget(target)
  if targetRes.isErr:
    return err(targetRes.error)

  let (host, port) = targetRes.get
  var client = try:
      newSocket(AF_INET, SOCK_STREAM)
    except:
      return err("oops")
  try:
    client.connect(host, Port(port))
  except OSError as e:
    client.close()
    return err("Unable to connect to " & host & ":" & $port & " - " & e.msg)

  let helloReq = HelloRequest(
    protocol: defaultTcpProtocol,
    module: "tcp_module_client",
    version: @[1'u32, 0'u32],
    token: @[],
  )
  let helloMsg = TransportMessage(tag: tHello, payload: Cbor.encode(helloReq))
  let sendRes = sendTransportMessage(client, helloMsg)
  if sendRes.isErr:
    client.close()
    return err(sendRes.error)

  let handshake = receiveTransportMessage(client)
  if handshake.isErr:
    client.close()
    return err(handshake.error)

  let helloResp = handshake.get
  if helloResp.tag != tHello:
    client.close()
    return err("Handshake failed: expected hello response")

  var parsed: HelloResponse
  try:
    parsed = Cbor.decode(helloResp.payload, HelloResponse)
  except:
    client.close()
    return err("Invalid hello response payload")

  var schema = ""
  let schemaRes = requestSchema(client)
  if schemaRes.isOk:
    schema = schemaRes.get

  let module = TcpModule(
    host: host,
    port: port,
    moduleName: parsed.module,
    version: versionString(parsed.version),
    schema: schema,
    client: client,
  )
  ok(module)

proc dispatch*(
    m: TcpModule, meth: string, params: openArray[byte]
): Result[seq[byte], string] =
  var requestParams: seq[byte] = @[]
  requestParams.setLen(params.len)
  for i in 0 ..< params.len:
    requestParams[i] = params[i]

  let request = RequestPayload(meth: meth, params: requestParams)
  let reqMsg = TransportMessage(tag: tRequest, payload: Cbor.encode(request))
  let sendRes = sendTransportMessage(m.client, reqMsg)
  if sendRes.isErr:
    return err(sendRes.error)

  let response = receiveTransportMessage(m.client)
  if response.isErr:
    return err(response.error)

  if response.get.tag != tResponse:
    return err("Unexpected transport response tag")

  var resp: ResponsePayload
  try:
    resp = Cbor.decode(response.get.payload, ResponsePayload)
  except:
    return err("Invalid remote response payload")

  if resp.error.len > 0:
    err(resp.error)
  else:
    ok(resp.result)

proc destroy*(m: TcpModule) =
  try:
    m.client.close()
  except:
    discard
