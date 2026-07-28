# src/logos_core/tcp_modules.nim
# TCP module client - connects to remote module hosts
# Per LOGOS-MODULE-TRANSPORT Section 3 (connection lifecycle)

{.push raises: [], gcsafe.}

import ./[cbor_stuff, modules, transport, tcp_protocols]

import results
import std/[net, os]

export cbor_stuff

type
  TcpModule* = ref object
    host*: string
    port*: int
    moduleName*: string
    version*: string
    schema*: string
    client*: Socket
    nextSubId*: uint32  # NEW: track subscription IDs

proc init*(_: type TcpModule, target: string): Result[TcpModule, string] =
  let (host, port) = parseTcpTarget(target).valueOr:
    return err(error)
  var client = try:
      newSocket(AF_INET, SOCK_STREAM)
    except:
      return err("oops")
  try:
    client.connect(host, net.Port(port))
  except OSError as e:
    client.close()
    return err("Unable to connect to " & host & ":" & $port & " - " & e.msg)

  # Send Hello with schema commitment
  let helloReq = HelloRequest(
    protocol: defaultTcpProtocol,
    module: "tcp_module_client",
    version: @[1'u32, 0'u32],
    token: @[],
    schema: SchemaCommitment(
      commitmentModel: "logos.commitment-model.2026-06",  # placeholder
      schemaRoot: @[],
      hashProfile: "logos.hash-profile.2026-05",
      hashSuite: "example-suite",
    ),
  )
  let helloMsg = TransportMessage(tag: tHello, payload: Cbor.encode(helloReq))
  if sendTransportMessage(client, helloMsg).isErr:
    client.close()
    return err("failed to send hello")

  let helloResp = receiveTransportMessage(client).valueOr:
    client.close()
    return err(error)
  if helloResp.tag != tHello:
    client.close()
    return err("Handshake failed: expected hello response")

  var parsed: HelloResponse
  try:
    parsed = Cbor.decode(helloResp.payload, HelloResponse)
  except:
    client.close()
    return err("Invalid hello response payload")

  # Validate response schema commitment
  # Placeholder check - real validation requires commitment-model spec
  # TODO: validate against expected schema when commitment spec lands

  # If we sent expect_schema, validate callee response
  if helloReq.expectSchema.isSome and parsed.expectSchema.isSome:
    if parsed.expectSchema.get != helloReq.expectSchema.get:
      client.close()
      return err("Expected schema not met")

  var schema = ""
  try:
    let request = TransportRequest(callId: 0, methodName: "logos.schema", params: @[])
    let reqMsg = TransportMessage(tag: tRequest, payload: Cbor.encode(request))
    discard sendTransportMessage(client, reqMsg)

    let response = receiveTransportMessage(client)
    if response.isOk and response.get.tag == tResponse:
      let respPayload = Cbor.decode(response.get.payload, TransportResponse)
      if respPayload.responseResult.isSome:
        schema = Cbor.decode(respPayload.responseResult.get, string)
  except:
    discard  # schema fetch is optional

  let module = TcpModule(
    host: host,
    port: port,
    moduleName: parsed.module,
    version: versionString(parsed.version),
    schema: schema,
    client: client,
    nextSubId: 1,  # NEW: start subscription IDs at 1
  )
  ok(module)

proc dispatch*(
  m: TcpModule, meth: string, params: openArray[byte]
): Result[seq[byte], string] =
  var requestParams: seq[byte] = @[]
  requestParams.setLen(params.len)
  for i in 0 ..< params.len:
    requestParams[i] = params[i]

  let request = TransportRequest(callId: 0, methodName: meth, params: requestParams)
  let reqMsg = TransportMessage(tag: tRequest, payload: Cbor.encode(request))
  if sendTransportMessage(m.client, reqMsg).isErr:
    return err("failed to send request")

  let response = receiveTransportMessage(m.client).valueOr:
    return err(error)

  if response.tag != tResponse:
    return err("Unexpected transport response tag")

  var resp: TransportResponse
  try:
    resp = Cbor.decode(response.payload, TransportResponse)
  except:
    return err("Invalid remote response payload")

  if resp.responseError.isSome:
    err(resp.responseError.get)
  elif resp.responseResult.isSome:
    ok(resp.responseResult.get)
  else:
    err("Response has neither result nor error")

# ============================================================================
# New subscription, unsubscribe, and cancel methods (per spec)
# ============================================================================

proc subscribe*(m: TcpModule, eventName: string): Result[uint32, string] =
  ## Subscribe to a named event
  ## Per LOGOS-MODULE-TRANSPORT Section 5
  let subId = m.nextSubId
  m.nextSubId += 1
  let req = SubscribePayload(subId: subId, eventName: eventName)
  let msg = TransportMessage(tag: tSubscribe, payload: Cbor.encode(req))
  if sendTransportMessage(m.client, msg).isErr:
    return err("failed to send subscribe")
  ok(subId)

proc unsubscribe*(m: TcpModule, subId: uint32): Result[void, string] =
  ## Unsubscribe from an event
  ## Per LOGOS-MODULE-TRANSPORT Section 5
  let req = UnsubscribePayload(subId: subId)
  let msg = TransportMessage(tag: tUnsubscribe, payload: Cbor.encode(req))
  if sendTransportMessage(m.client, msg).isErr:
    return err("failed to send unsubscribe")
  ok()

proc cancel*(m: TcpModule, callId: uint32): Result[void, string] =
  ## Cancel an in-flight request
  ## Per LOGOS-MODULE-TRANSPORT Section 6
  let req = CancelPayload(callId: callId)
  let msg = TransportMessage(tag: tCancel, payload: Cbor.encode(req))
  if sendTransportMessage(m.client, msg).isErr:
    return err("failed to send cancel")
  ok()

proc destroy*(m: TcpModule) =
  try:
    m.client.close()
  except:
    discard
