# src/logos_core/runtime.nim

{.push gcsafe, raises: [].}

import ./[modules, shared_modules, tcp_modules, tcp_host, tcp_protocols]
import results
import std/[tables, os, net, sequtils]

type
  ModuleInfo* = object
    m*: Module
    state*: State
    instanceId*: string # NEW: opaque instance identity
    remote*: Option[string] # NEW: remote runtime endpoint (for facade)

  Runtime* = object
    modules*: Table[string, ModuleInfo]
    subscribers*: seq[Socket] # NEW: track subscribers
    tcpHost*: ref TcpHost

proc newRuntime*(): Runtime =
  Runtime(modules: initTable[string, ModuleInfo](), subscribers: @[], tcpHost: nil)

proc registerModule*(runtime: var Runtime, name: string, info: sink ModuleInfo) =
  runtime.modules[name] = info

proc shutdown*(runtime: var Runtime) =
  if runtime.tcpHost != nil:
    stopHost(runtime.tcpHost)
    runtime.tcpHost = nil
  for name in runtime.modules.keys.toSeq:
    try:
      let info = runtime.modules[name]
      if not info.m.destroyFn.isNil:
        info.m.destroyFn()
    except:
      discard
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
  runtime.modules.withValue(name, module):
    if not module[].m.destroyFn.isNil:
      module[].m.destroyFn()
    runtime.modules.del name
    return ok()
  do:
    return err("Plugin not loaded: " & name)

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
    runtime: var Runtime, name, methodName: string, params: seq[byte]
): Result[seq[byte], string] =
  try:
    return runtime.modules[name].m.dispatchFn(methodName, params)
  except KeyError:
    return err("Plugin not loaded: " & name)

proc startTcpHost*(runtime: var Runtime, port: net.Port): Result[net.Port, string] =
  if runtime.tcpHost != nil and runtime.tcpHost.running:
    return err("TCP host already running")
  let runtime = addr runtime
  let hostRes = startHost(
    proc(path: string): Result[(string, string), string] =
      runtime[].load(path),
    proc(name: string): Result[void, string] =
      runtime[].unload(name),
    proc(): seq[string] =
      runtime[].listPlugins(),
    proc(
        plugin: string, methodName: string, params: seq[byte]
    ): Result[seq[byte], string] =
      runtime[].dispatchPlugin(plugin, methodName, params),
    port,
  )

  runtime.tcpHost = hostRes.valueOr:
    return err(error)
  ok(runtime.tcpHost.port)

proc stopTcpHost*(runtime: var Runtime): Result[void, string] =
  if runtime.tcpHost == nil:
    return ok()
  stopHost(runtime.tcpHost)
  runtime.tcpHost = nil
  ok()

# ============================================================================
# Runtime Control Methods (from LOGOS-MODULE-RUNTIME Section 9)
# ============================================================================

proc listModules*(runtime: var Runtime): seq[ModuleRecord] =
  ## Returns module records for all known modules
  result = @[]
  for name, info in runtime.modules.pairs:
    let rec = ModuleRecord(
      module: name,
      instance: Opt.some(info.instanceId),
      state: info.state,
      mode: mDirect, # TODO: derive from module type (direct vs tcp)
    )
    result.add(rec)

proc startModule*(runtime: var Runtime, name: string): Result[void, string] =
  ## Starts a module record already known to the runtime
  try:
    let info = runtime.modules[name]
    return
      if info.state == sUnloaded:
        # Load and init module
        runtime.modules[name].state = sLoaded
        # TODO: call initFn() when actual init is wired
        runtime.modules[name].state = sReady
        ok()
      else:
        err("Module already loaded (state: " & $info.state & ")")
  except KeyError:
    return err("Module not found: " & name)

proc stopModule*(runtime: var Runtime, name: string): Result[void, string] =
  ## Stops the selected module instance
  try:
    if runtime.modules.hasKey(name):
      if runtime.modules[name].state == sReady:
        runtime.modules[name].state = sStopping
        # TODO: call destroyFn()
        runtime.modules[name].state = sUnloaded
        ok()
      else:
        err("Module not in ready state (state: " & $runtime.modules[name].state & ")")
    else:
      err("Module not found: " & name)
  except KeyError:
    err("Module not found: " & name)

proc getReadiness*(
    runtime: var Runtime, name: string
): Result[(State, Option[Reason]), string] =
  try:
    return ok((runtime.modules[name].state, none[Reason]()))
  except KeyError:
    return err("Module not found: " & name)

proc listRoutes*(runtime: Runtime): seq[RouteRecord] =
  ## Returns routes (currently empty - to be implemented when routes exist)
  result = @[]

proc revokeRoute*(runtime: var Runtime, routeId: string): Result[void, string] =
  ## Revoke a route (currently no routes exist)
  ok()
