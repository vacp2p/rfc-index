# TCP host server for Logos modules
# Per LOGOS-MODULE-TRANSPORT (stream binding, message types)

{.push raises: [], gcsafe.}

import std/net
import std/typedthreads
import results
import logos_core/[cbor_stuff, transport, tcp_protocols, modules]

export net

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
    port*: net.Port
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
    runtimeOps: TcpHostRuntimeOps, port: net.Port
): Result[ref TcpHost, string] =
  var host = (ref TcpHost)(runtimeOps: runtimeOps, port: port, running: false)
  try:
    host.serverSocket = newSocket(AF_INET, SOCK_STREAM)
    host.serverSocket.setSockOpt(OptReuseAddr, true)
    host.serverSocket.bindAddr(net.Port(port))
    host.serverSocket.listen()
    host.port = host.serverSocket.getLocalAddr()[1]
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

proc getSchema*(host: TcpHost): string =
  """
  ; -- metadata --
  _module = "tcp_host"
  _version = [1, 0]

  ; -- methods --
  tcp_host.load_plugin_request = {
      path: tstr,
  }
  tcp_host.load_plugin_response = {
      data: [* tstr],
  }

  tcp_host.unload_plugin_request = {
      name: tstr,
  }
  tcp_host.unload_plugin_response = {
      message: tstr,
  }

  tcp_host.list_plugins_request = {}
  tcp_host.list_plugins_response = {
      plugins: [* tstr],
  }

  tcp_host.dispatch_plugin_request = {
      plugin: tstr,
      methodName: tstr,
      payload: bstr,
  }
  tcp_host.dispatch_plugin_response = {
      result: bstr,
  }

  tcp_host.logos.schema_request = {}
  tcp_host.logos.schema_response = {
      schema: tstr,
  }

  tcp_host.ping_request = {}
  tcp_host.ping_response = {
      response: tstr,
  }
  """

proc dispatchRequest*(host: TcpHost, req: TransportRequest): TransportResponse =
  ## Dispatch a transport request to the runtime ops
  var response = TransportResponse(
    callId: req.callId,
    responseResult: Opt.none(seq[byte]),
    responseError: Opt.none(string),
  )
  try:
    # We use Cbor.encode/decode from cbor_stuff.nim for serialization
    case req.methodName
    of "load_plugin":
      let params = Cbor.decode(req.params, LoadPluginParams)
      let res = host.runtimeOps.loadPlugin(params.path)
      if res.isOk:
        let (name, version) = res.get
        response.responseResult = Opt.some(Cbor.encode(@[name, version]))
      else:
        response.responseError = Opt.some(res.error)
    of "unload_plugin":
      let params = Cbor.decode(req.params, UnloadPluginParams)
      let res = host.runtimeOps.unloadPlugin(params.name)
      if res.isOk:
        response.responseResult = Opt.some(Cbor.encode("unloaded"))
      else:
        response.responseError = Opt.some(res.error)
    of "list_plugins":
      response.responseResult = Opt.some(Cbor.encode(host.runtimeOps.listPlugins()))
    of "dispatch_plugin":
      let params = Cbor.decode(req.params, DispatchPluginParams)
      let res =
        host.runtimeOps.dispatchPlugin(params.plugin, params.methodName, params.payload)
      if res.isOk:
        response.responseResult = Opt.some(res.get)
      else:
        response.responseError = Opt.some(res.error)
    of "logos.schema":
      response.responseResult = Opt.some(Cbor.encode(host.getSchema()))
    of "ping":
      response.responseResult = Opt.some(Cbor.encode("pong"))
    # ============================================================================
    # Runtime Control methods (per LOGOS-MODULE-RUNTIME Section 9)
    # ============================================================================
    of "list_modules":
      # TODO: implement with proper module records
      response.responseResult = Opt.some(default(seq[byte]))
    of "list_routes":
      # TODO: implement with route records
      response.responseResult = Opt.some(default(seq[byte]))
    of "start_module":
      # TODO: implement start_module
      response.responseResult = Opt.some(default(seq[byte]))
    of "stop_module":
      # TODO: implement stop_module
      response.responseResult = Opt.some(default(seq[byte]))
    of "get_readiness":
      # TODO: implement get_readiness
      response.responseResult = Opt.some(default(seq[byte]))
    of "revoke_route":
      # TODO: implement revoke_route
      response.responseResult = Opt.some(default(seq[byte]))
    else:
      response.responseError = Opt.some("Unknown method: " & req.methodName)
  except CatchableError as exc:
    response.responseError = Opt.some("Invalid request payload: " & exc.msg)
  response

proc sendProtocolError*(client: Socket, code: int, msg: string) =
  let payload = Cbor.encode(
    ProtocolErrorPayload(errCode: code, errMsg: msg, errDetail: Opt.none(seq[byte]))
  )
  let errMsg = TransportMessage(tag: tProtocolError, payload: payload)
  discard sendTransportMessage(client, errMsg)

# ============================================================================
# Handle new message types per LOGOS-MODULE-TRANSPORT spec
# ============================================================================

proc handleClient*(host: TcpHost, client: Socket) {.gcsafe.} =
  try:
    while host.running:
      let messageRes = receiveTransportMessage(client)
      if messageRes.isErr:
        break

      let msg = messageRes.get
      case msg.tag
      of tHello:
        # Handle Hello with schema commitment
        try:
          let helloReq = Cbor.decode(msg.payload, HelloRequest)
          let helloResp = HelloResponse(
            protocol: defaultTcpProtocol,
            module: "tcp_host",
            version: @[1'u32, 0'u32],
            token: @[],
            schema: SchemaCommitment(
              commitmentModel: "logos.commitment-model.2026-06",
              schemaRoot: @[],
              hashProfile: "logos.hash-profile.2026-05",
              hashSuite: "example-suite",
            ),
          )
          let respPayload = Cbor.encode(helloResp)
          let respMsg = TransportMessage(tag: tHello, payload: respPayload)
          if sendTransportMessage(client, respMsg).isErr:
            break
        except:
          sendProtocolError(client, 2, "Invalid Hello payload")
          break
      of tRequest:
        try:
          let reqPayload = Cbor.decode(msg.payload, TransportRequest)
          let response = dispatchRequest(host, reqPayload)
          let respPayload = Cbor.encode(response)
          let respMsg = TransportMessage(tag: tResponse, payload: respPayload)
          if sendTransportMessage(client, respMsg).isErr:
            break
        except:
          sendProtocolError(client, 2, "Invalid request payload")
          break
      of tSubscribe:
        # NEW: Register event subscription (per LOGOS-MODULE-TRANSPORT Section 5)
        # Per spec: no separate ack required
        try:
          let subReq = Cbor.decode(msg.payload, SubscribePayload)
          # TODO: register subscriber, track subscription mapping
          # Stub: acknowledge by doing nothing (spec says no ack in this revision)
        except:
          sendProtocolError(client, 2, "Invalid subscribe payload")
          break
      of tUnsubscribe:
        # NEW: Cancel event subscription
        try:
          let unsubReq = Cbor.decode(msg.payload, UnsubscribePayload)
          # TODO: remove subscription
        except:
          sendProtocolError(client, 2, "Invalid unsubscribe payload")
          break
      of tCancel:
        # NEW: Abort in-flight request (per LOGOS-MODULE-TRANSPORT Section 6)
        try:
          let cancelReq = Cbor.decode(msg.payload, CancelPayload)
          # TODO: cancel in-flight request, return cancelled error
          # For now, send a cancelled error response
          let resp = TransportResponse(
            callId: cancelReq.callId,
            responseResult: Opt.none(seq[byte]),
            responseError: Opt.some("cancelled"),
          )
          let respPayload = Cbor.encode(resp)
          discard sendTransportMessage(
            client, TransportMessage(tag: tResponse, payload: respPayload)
          )
        except:
          sendProtocolError(client, 2, "Invalid cancel payload")
          break
      of tProtocolError:
        # NEW: Protocol error received (per LOGOS-MODULE-TRANSPORT Section 1.3 kind 6)
        client.close()
        break
      else:
        sendProtocolError(client, 2, "Unsupported transport message")
        break

    client.close()
  except CatchableError:
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
    port: net.Port,
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
