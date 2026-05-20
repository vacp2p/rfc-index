# src/logos_core/runtime.nim

{.push gcsafe, raises: [].}

import ./[iface, shared_modules, tcp_modules, tcp_host, tcp_protocols]
import results
import std/[tables, os, net, sequtils]

type
  ModuleState* {.pure.} = enum
    unloaded
    loaded
    ready
    stopping
    error

  ModuleInfo* = object
    m: Module
    state: ModuleState

  Runtime* = object
    modules: Table[string, ModuleInfo]
    subscribers: seq[Socket]
    tcpHost: ref TcpHost

proc newRuntime*(): Runtime =
  Runtime(modules: initTable[string, ModuleInfo](), subscribers: @[], tcpHost: nil)

proc registerModule*(runtime: var Runtime, name: string, info: sink ModuleInfo) =
  runtime.modules[name] = info

proc shutdown*(runtime: var Runtime) =
  if runtime.tcpHost != nil:
    stopHost(runtime.tcpHost)
    runtime.tcpHost = nil
  runtime.modules.clear()

proc load*(runtime: var Runtime, path: string): Result[(string, string), string] =
  if isTcpTarget(path):
    let tcp = ?TcpModule.init(path)
    let res = (tcp.moduleName, tcp.version)
    let module = Module(
      name: tcp.moduleName,
      host: path,
      schema: tcp.schema,
      version: tcp.version,
      initFn: proc(): cint =
        0,
      dispatchFn: proc(
          meth: string, params: openArray[byte]
      ): Result[seq[byte], string] =
        tcp.dispatch(meth, params),
      destroyFn: proc() =
        tcp.destroy(),
    )
    runtime.registerModule(module.name, ModuleInfo(m: module))
    ok(res)
  else:
    let shared = (ref SharedModule)()
    shared[] = ?SharedModule.init(path)
    let res = (shared.name, shared.version)
    let module = Module(
      name: shared.name,
      host: path,
      schema: shared.schema,
      version: shared.version,
      initFn: proc(): cint =
        shared[].initFn(),
      dispatchFn: proc(
          meth: string, params: openArray[byte]
      ): Result[seq[byte], string] =
        shared[].dispatch(meth, params),
      destroyFn: proc() =
        shared[].destroyFn(),
    )
    runtime.registerModule(module.name, ModuleInfo(m: module))
    ok(res)

proc unload*(runtime: var Runtime, name: string): Result[void, string] =
  if runtime.modules.hasKey(name):
    runtime.modules.del name
    ok()
  else:
    err("Plugin not loaded: " & name)

proc listPlugins*(runtime: Runtime): seq[string] =
  runtime.modules.keys.toSeq

proc pluginSchema*(runtime: Runtime, name: string): Result[string, string] =
  if runtime.modules.hasKey(name):
    try:
      ok(runtime.modules[name].m.schema)
    except:
      raiseAssert "oops"
  else:
    err("Plugin not loaded: " & name)

proc dispatchPlugin*(
    runtime: Runtime, name: string, methodName: string, params: seq[byte]
): Result[seq[byte], string] =
  if runtime.modules.hasKey(name):
    try:
      runtime.modules[name].m.dispatchFn(methodName, params)
    except:
      raiseAssert "oops"
  else:
    err("Plugin not loaded: " & name)


proc startTcpHost*(runtime: var Runtime, port: int): Result[int, string] =
  if runtime.tcpHost != nil and runtime.tcpHost.running:
    return err("TCP host already running")
  let runtime = addr runtime
  let hostRes = startHost(
    proc(path: string): Result[(string, string), string] = runtime[].load(path),
    proc(name: string): Result[void, string] = runtime[].unload(name),
    proc(): seq[string] = runtime[].listPlugins(),
    proc(plugin: string, methodName: string, params: seq[byte]): Result[seq[byte], string] =
      runtime[].dispatchPlugin(plugin, methodName, params),
    port,
  )

  if hostRes.isErr:
    return err(hostRes.error)
  runtime.tcpHost = hostRes.get
  ok(port)

proc stopTcpHost*(runtime: var Runtime): Result[void, string] =
  if runtime.tcpHost == nil:
    return ok()
  stopHost(runtime.tcpHost)
  runtime.tcpHost = nil
  ok()
