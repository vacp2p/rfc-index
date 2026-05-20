# src/logos_core/tcp_host.nim
{.push raises: [], gcsafe.}

import std/[os, net, sequtils, strutils]
import std/typedthreads
import stew/byteutils
import results
import logos_core/[cbor_stuff, transport, tcp_protocols]

const defaultTcpHostPort* = 8543

{.pragma: api, raises: [], gcsafe.}

type
  TcpHostRuntimeOps* = object
    loadPlugin*: proc(path: string): Result[(string, string), string] {.api.}
    unloadPlugin*: proc(name: string): Result[void, string] {.api.}
    listPlugins*: proc(): seq[string] {.api.}
    dispatchPlugin*: proc(
      plugin: string, methodName: string, params: seq[byte]
    ): Result[seq[byte], string] {.api.}

  TcpHost* = object
    serverSocket*: Socket
    serverThread*: Thread[pointer]
    running*: bool
    port*: int
    runtimeOps*: TcpHostRuntimeOps

  LoadPluginParams* = object
    path*: string

  UnloadPluginParams* = object
    name*: string

  DispatchPluginParams* = object
    plugin*: string
    methodName*: string
    payload*: seq[byte]

proc serverLoop*(host: TcpHost)

proc tcpHostThreadProc(arg: pointer) {.thread, nimcall.} =
  let hostRef = cast[ptr TcpHost](arg)
  serverLoop(hostRef[])

proc newTcpHost*(
    runtimeOps: TcpHostRuntimeOps, port: int
): Result[ref TcpHost, string] =
  var host = (ref TcpHost)(runtimeOps: runtimeOps, port: port, running: false)
  try:
    host.serverSocket = newSocket(AF_INET, SOCK_STREAM)
    host.serverSocket.setSockOpt(OptReuseAddr, true)
    host.serverSocket.bindAddr(Port(port))
    host.serverSocket.listen()
  except CatchableError as e:
    try:
      host.serverSocket.close()
    except:
      discard
    return err("Unable to bind TCP host on port " & $port & " - " & e.msg)

  host.running = true
  try:
    host.serverThread.createThread(tcpHostThreadProc, addr(host[]))
  except:
    raiseAssert "oops"

  ok(host)

proc stopServer*(host: ref TcpHost) =
  if host == nil or not host.running:
    return
  host.running = false
  try:
    host.serverSocket.close()
  except:
    discard
  try:
    joinThread(host.serverThread)
  except:
    discard

proc makeErrorResponse*(err: string): seq[byte] =
  Cbor.encode(ResponsePayload(result: @[], error: err))

proc getSchema*(host: TcpHost): string =
  """
  ; -- metadata --
  _module = "tcp_host"
  _version = [1, 0]

  ; -- methods --
  tcp_host.load-plugin-request = {
      path: tstr,
  }
  tcp_host.load-plugin-response = {
      data: [* tstr],
  }

  tcp_host.unload-plugin-request = {
      name: tstr,
  }
  tcp_host.unload-plugin-response = {
      message: tstr,
  }

  tcp_host.list-plugins-request = {}
  tcp_host.list-plugins-response = {
      plugins: [* tstr],
  }

  tcp_host.dispatch-plugin-request = {
      plugin: tstr,
      methodName: tstr,
      payload: bstr,
  }
  tcp_host.dispatch-plugin-response = {
      result: bstr,
  }

  tcp_host.logos.schema-request = {}
  tcp_host.logos.schema-response = {
      schema: tstr,
  }

  tcp_host.ping-request = {}
  tcp_host.ping-response = {
      response: tstr,
  }
  """

proc dispatchRequest*(host: TcpHost, req: RequestPayload): ResponsePayload =
  var response = ResponsePayload(result: @[], error: "")
  try:
    case req.meth
    of "load-plugin":
      let params = Cbor.decode(req.params, LoadPluginParams)
      let res = host.runtimeOps.loadPlugin(params.path)
      if res.isOk:
        let (name, version) = res.get
        response.result = Cbor.encode(@[name, version])
      else:
        response.error = res.error
    of "unload-plugin":
      let params = Cbor.decode(req.params, UnloadPluginParams)
      let res = host.runtimeOps.unloadPlugin(params.name)
      if res.isOk:
        response.result = Cbor.encode("unloaded")
      else:
        response.error = res.error
    of "list-plugins":
      response.result = Cbor.encode(host.runtimeOps.listPlugins())
    of "dispatch-plugin":
      let params = Cbor.decode(req.params, DispatchPluginParams)
      let res =
        host.runtimeOps.dispatchPlugin(params.plugin, params.methodName, params.payload)
      if res.isOk:
        response.result = res.get
      else:
        response.error = res.error
    of "logos.schema":
      response.result = Cbor.encode(host.getSchema())
    of "ping":
      response.result = Cbor.encode("pong")
    else:
      response.error = "Unknown method: " & req.meth
  except CatchableError as exc:
    response.error = "Invalid request payload: " & exc.msg
  response

proc sendErrorResponse*(client: Socket, err: string) =
  let payload = Cbor.encode(ResponsePayload(result: @[], error: err))
  let respMsg = TransportMessage(tag: tResponse, payload: payload)
  discard sendTransportMessage(client, respMsg)

proc handleClient*(host: TcpHost, client: Socket) {.gcsafe.} =
  try:
    while host.running:
      let messageRes = receiveTransportMessage(client)
      if messageRes.isErr:
        break

      let msg = messageRes.get
      case msg.tag
      of tHello:
        let helloReq = Cbor.decode(msg.payload, HelloRequest)
        let helloResp = HelloResponse(
          protocol: defaultTcpProtocol,
          module: "tcp_host",
          version: @[1'u32, 0'u32],
          token: @[],
        )
        let respPayload = Cbor.encode(helloResp)
        let respMsg = TransportMessage(tag: tHello, payload: respPayload)
        if sendTransportMessage(client, respMsg).isErr:
          break
      of tRequest:
        let reqPayload = Cbor.decode(msg.payload, RequestPayload)
        let response = host.dispatchRequest(reqPayload)
        let respPayload = Cbor.encode(response)
        let respMsg = TransportMessage(tag: tResponse, payload: respPayload)
        if sendTransportMessage(client, respMsg).isErr:
          break
      else:
        sendErrorResponse(client, "Unsupported transport message")
        break

    client.close()
  except CatchableError as exc:
    client.close()

proc serverLoop*(host: TcpHost) =
  while host.running:
    try:
      var client: Socket
      host.serverSocket.accept(client)
      host.handleClient(client)
    except OSError:
      break
    except:
      break

proc stopHost*(host: ref TcpHost) =
  stopServer(host)

proc startHost*(
    loadPlugin: proc(path: string): Result[(string, string), string] {.api.},
    unloadPlugin: proc(name: string): Result[void, string] {.api.},
    listPlugins: proc(): seq[string] {.api.},
    dispatchPlugin: proc(
      plugin: string, methodName: string, params: seq[byte]
    ): Result[seq[byte], string] {.api.},
    port: int,
): Result[ref TcpHost, string] =
  newTcpHost(
    TcpHostRuntimeOps(
      loadPlugin: loadPlugin,
      unloadPlugin: unloadPlugin,
      listPlugins: listPlugins,
      dispatchPlugin: dispatchPlugin,
    ),
    port,
  )
