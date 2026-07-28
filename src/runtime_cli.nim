import std/[os, strutils, tables, sequtils]
import results
import logos_core/[cbor_stuff, schemas, runtime]

const defaultPort = 8543

type
  CliCmd* = enum
    ccHelp, ccLoad, ccList, ccSchema, ccMethods, ccCall
    ccStartHost, ccStopHost, ccRun

  CliArgs* = object
    cmd*: CliCmd
    loadPath*: string
    schemaName*: string
    methodName*: string
    callModule*: string
    callMethod*: string
    callArgs*: seq[string]
    hostPort*: int
    runCmds*: seq[string]

proc printFullUsage() =
  echo "Usage: runtime-cli [command] [options...]"
  echo ""
  echo "Commands:"
  echo "  run <cmd> [args...] [&& <cmd> [args...]]"
  echo "    Run one or more chained commands in a single session"
  echo ""
  echo "  load <path>"
  echo "    Load a module (.so file or tcp:// target)"
  echo ""
  echo "  list"
  echo "    List loaded modules"
  echo ""
  echo "  schema <module-name>"
  echo "    Print the CDDL schema of a module"
  echo ""
  echo "  methods <module-name>"
  echo "    List available methods of a module"
  echo ""
  echo "  call <module> <method> [key=value ...]"
  echo "    Call a method with named parameters"
  echo ""
  echo "  start-host [port]"
  echo "    Start the TCP host server (default: 8543)"
  echo ""
  echo "  stop-host"
  echo "    Stop the TCP host server"

proc parseArgs(): CliArgs =
  if paramCount() < 1:
    printFullUsage()
    quit(1)

  let raw = paramStr(1).toLowerAscii
  case raw
  of "load":
    result.cmd = ccLoad
    if paramCount() >= 2: result.loadPath = paramStr(2)
  of "list": result.cmd = ccList
  of "schema":
    result.cmd = ccSchema
    if paramCount() >= 2: result.schemaName = paramStr(2)
  of "methods":
    result.cmd = ccMethods
    if paramCount() >= 2: result.methodName = paramStr(2)
  of "call":
    result.cmd = ccCall
    if paramCount() >= 2: result.callModule = paramStr(2)
    if paramCount() >= 3: result.callMethod = paramStr(3)
    for j in 4 .. paramCount():
      result.callArgs.add(paramStr(j))
  of "start-host":
    result.cmd = ccStartHost
    if paramCount() >= 2:
      try: result.hostPort = parseInt(paramStr(2))
      except: result.hostPort = defaultPort
    else:
      result.hostPort = defaultPort
  of "stop-host": result.cmd = ccStopHost
  of "run":
    result.cmd = ccRun
    var i = 2
    var currentCmds: seq[string] = @[]
    while i <= paramCount():
      let arg = paramStr(i)
      if arg == "&&" and currentCmds.len > 0:
        result.runCmds.add(currentCmds.join(" "))
        currentCmds = @[]
      else:
        currentCmds.add(arg)
      inc i
    if currentCmds.len > 0:
      result.runCmds.add(currentCmds.join(" "))
  of "help", "-h", "--help": result.cmd = ccHelp
  else:
    echo "Unknown command: " & paramStr(1)
    quit(1)

proc doLoad(rt: var Runtime, path: string): Result[void, string] =
  let loaded = rt.load(path)
  if loaded.isOk:
    echo "  Loaded: ", loaded.get[0], " (version ", loaded.get[1], ")"
    ok()
  else:
    err("Load failed: " & loaded.error)

proc doList(rt: Runtime): Result[void, string] =
  let plugins = rt.listPlugins()
  if plugins.len == 0:
    echo "  No modules loaded."
  else:
    echo "  Loaded modules:"
    for name in plugins:
      echo "  - ", name
  ok()

proc doSchema(rt: Runtime, name: string): Result[void, string] =
  let schemaRes = rt.pluginSchema(name)
  if schemaRes.isOk:
    echo "  Schema for '", name, "':"
    echo schemaRes.get
    ok()
  else:
    err("Plugin not found: " & schemaRes.error)

proc doMethods(rt: Runtime, name: string): Result[void, string] =
  let schemaRes = rt.pluginSchema(name)
  if schemaRes.isErr:
    return err("Plugin not found: " & schemaRes.error)
  let schema = schemaRes.get
  let methods = extractMethodsFromSchema(schema)
  if methods.len == 0:
    echo "  No methods found in '", name, "'."
  else:
    echo "  Methods in '", name, "':"
    for m in methods:
      let params = extractMethodParams(schema, m)
      if params.len > 0:
        let paramStr = params.mapIt(it.name & ": " & it.typeName).join(", ")
        echo "    - " & m & " (" & paramStr & ")"
      else:
        echo "    - " & m
  ok()

proc doCall(rt: Runtime, moduleName: string, methodName: string, argStrs: seq[string]): Result[void, string] =
  let schemaRes = rt.pluginSchema(moduleName)
  if schemaRes.isErr:
    return err("Plugin not found: " & schemaRes.error)
  let schema = schemaRes.get

  let methods = extractMethodsFromSchema(schema)
  if methodName notin methods:
    return err("Method '" & methodName & "' not found. Available: " & methods.join(", "))

  var params = extractMethodParams(schema, methodName)
  var args = initOrderedTable[string, string]()
  for arg in argStrs:
    let eqIdx = arg.find('=')
    if eqIdx > 0:
      let key = arg[0 ..< eqIdx].strip().toLowerAscii
      let value = arg[eqIdx + 1 ..< arg.len]
      args[key] = value
    else:
      return err("Invalid parameter format: '" & arg & "'. Expected key=value")

  for i in 0 ..< params.len:
    if args.hasKey(params[i].name.toLowerAscii):
      params[i].value = args[params[i].name.toLowerAscii]

  let cborParams = buildCborParams(params).valueOr:
    return err("Parameter error: " & error)

  let dispatch = rt.dispatchPlugin(moduleName, methodName, cborParams).valueOr:
    return err("Dispatch failed: " & error)

  let decoded = Cbor.decode(dispatch, CborValueRef)
  echo "  Result:"
  echo decoded
  ok()

proc doStartHost(rt: var Runtime, port: int): Result[void, string] =
  let res = rt.startTcpHost(Port(port))
  if res.isOk:
    echo "  TCP host listening on port ", res[]
    ok()
  else:
    err("Failed to start TCP host: " & res.error)

proc doStopHost(rt: var Runtime): Result[void, string] =
  let res = rt.stopTcpHost()
  if res.isOk:
    echo "  TCP host stopped."
    ok()
  else:
    err("Failed to stop TCP host: " & res.error)

proc parseSingleCmd(line: string): (CliCmd, seq[string]) =
  ## Parse a single command line into (command, args)
  let parts = line.strip().splitWhitespace()
  if parts.len == 0:
    return (ccHelp, @[])
  case parts[0].toLowerAscii
  of "load":
    result = (ccLoad, @[parts[1]] & parts[1 ..< parts.len].toSeq)
  of "list":
    result = (ccList, @[])
  of "schema":
    result = (ccSchema, @[parts[1]])
  of "methods":
    result = (ccMethods, @[parts[1]])
  of "call":
    result = (ccCall, @["--module=" & parts[1], "--method=" & parts[2]] & parts[3 ..< parts.len].toSeq)
  of "start-host":
    if parts.len > 1:
      result = (ccStartHost, @[parts[1]])
    else:
      result = (ccStartHost, @[])
  of "stop-host":
    result = (ccStopHost, @[])
  else:
    result = (ccHelp, @[])

proc executeCmd(rt: var Runtime, cmd: CliCmd, args: seq[string]): Result[void, string] =
  case cmd
  of ccHelp:
    echo "  No help available for 'help' (type 'runtime-cli' alone for full usage)"
    ok()
  of ccLoad:
    if args.len < 1:
      return err("Usage: load <path>")
    doLoad(rt, args[0])
  of ccList:
    doList(rt)
  of ccSchema:
    if args.len < 1:
      return err("Usage: schema <module-name>")
    doSchema(rt, args[0])
  of ccMethods:
    if args.len < 1:
      return err("Usage: methods <module-name>")
    doMethods(rt, args[0])
  of ccCall:
    var modName = ""
    var methodName = ""
    var extraArgs: seq[string] = @[]
    for a in args:
      if a.startsWith("--module="):
        modName = a[9 ..< a.len]
      elif a.startsWith("--method="):
        methodName = a[9 ..< a.len]
      elif not a.startsWith("--"):
        extraArgs.add(a)
    if modName.len == 0 or methodName.len == 0:
      return err("Usage: call <module> <method> [key=value ...]")
    doCall(rt, modName, methodName, extraArgs)
  of ccStartHost:
    var port = defaultPort
    for a in args:
      if a.startsWith("--port="):
        port = parseInt(a[7 ..< a.len])
    doStartHost(rt, port)
  of ccStopHost:
    doStopHost(rt)
  else:
    err("Unknown command")

proc doRun(rt: var Runtime, cmds: seq[string]) =
  echo "=== Logos Runtime CLI (run mode) ==="
  var cmdIdx = 0
  for cmdLine in cmds:
    # Split on && in case multiple chained commands are in one arg
    let subCmds = cmdLine.split("&&")
    for subCmd in subCmds:
      let trimmed = subCmd.strip()
      if trimmed.len == 0:
        continue
      inc cmdIdx
      echo ""
      echo ">> Cmd ", cmdIdx, ": ", trimmed
      let (cmd, cmdArgs) = parseSingleCmd(trimmed)
      let res = executeCmd(rt, cmd, cmdArgs)
      if res.isErr:
        echo "  ERROR: " & res.error
        echo "  Stopping run at command ", cmdIdx
        return

proc main() =
  let args = parseArgs()
  var rt = newRuntime()
  defer:
    rt.shutdown()

  case args.cmd
  of ccHelp:
    printFullUsage()
  of ccRun:
    if args.runCmds.len == 0:
      echo "  No commands provided. Usage:"
      echo "    runtime-cli run \"load libexploit.so\" && \"methods exploit\" && \"call exploit exec command=ls\""
      quit(1)
    doRun(rt, args.runCmds)
  of ccLoad:
    if args.loadPath.len == 0:
      echo "Usage: runtime-cli load <path>"
      quit(1)
    let res = doLoad(rt, args.loadPath)
    if res.isErr: quit("Load failed: " & res.error)
  of ccList:
    let res = doList(rt)
    if res.isErr: quit("Error: " & res.error)
  of ccSchema:
    if args.schemaName.len == 0:
      echo "Usage: runtime-cli schema <module-name>"
      quit(1)
    let res = doSchema(rt, args.schemaName)
    if res.isErr: quit("Error: " & res.error)
  of ccMethods:
    if args.methodName.len == 0:
      echo "Usage: runtime-cli methods <module-name>"
      quit(1)
    let res = doMethods(rt, args.methodName)
    if res.isErr: quit("Error: " & res.error)
  of ccCall:
    if args.callModule.len == 0 or args.callMethod.len == 0:
      echo "Usage: runtime-cli call <module> <method> [key=value ...]"
      quit(1)
    let res = doCall(rt, args.callModule, args.callMethod, args.callArgs)
    if res.isErr: quit("Error: " & res.error)
  of ccStartHost:
    let res = doStartHost(rt, args.hostPort)
    if res.isErr: quit("Error: " & res.error)
  of ccStopHost:
    let res = doStopHost(rt)
    if res.isErr: quit("Error: " & res.error)

when isMainModule:
  main()
