import std/[algorithm, os, strutils, random, unicode, sequtils, re, tables]
import illwill, results, stew/byteutils
import logos_core/[cbor_stuff, schemas, runtime, tcp_host]

const
  firePanelWidth = 20
  fireMaxIntensity = 5

var browserExtensions: seq[string] = @[".so"]

type
  AppMode* = enum
    loadedPlugins
    pluginBrowser
    methodSelecting
    methodCalling

  BrowserItem* = object
    name*: string
    path*: string
    isDir*: bool
    isLoadable*: bool

  MethodCall* = object
    plugin*: string
    methodName*: string
    params*: seq[MethodParam]
    currentParamIdx*: int
    result*: string
    error*: string

  AppState* = object
    runtime*: Runtime
    mode*: AppMode
    selectedPlugin*: int
    selectedBrowser*: int
    browserDir*: string
    browserItems*: seq[BrowserItem]
    status*: string
    fire*: seq[seq[int]]
    fireFuel*: int
    methods*: seq[string]
    selectedMethod*: int
    methodCall*: MethodCall
    serverRunning*: bool

proc clampIndex(idx: int, len: int): int =
  if len <= 0:
    0
  elif idx < 0:
    0
  elif idx >= len:
    len - 1
  else:
    idx

proc initMethodCall*(
    plugin: string, methodName: string, params: seq[MethodParam]
): MethodCall =
  MethodCall(
    plugin: plugin,
    methodName: methodName,
    params: params,
    currentParamIdx: 0,
    result: "",
    error: "",
  )

proc makeBrowserItem*(dir, name: string): BrowserItem =
  let path = joinPath(dir, name)
  var isLoadable = false
  for ext in browserExtensions:
    if name.endsWith(ext):
      isLoadable = true
      break
  BrowserItem(
    name: name,
    path: path,
    isDir: dirExists(path),
    isLoadable: not dirExists(path) and isLoadable,
  )

proc scanBrowser*(dir: string): seq[BrowserItem] =
  var items: seq[BrowserItem] = @[]
  for kind, name in walkDir(dir, relative = true):
    if name == "." or name == "..":
      continue
    let item = makeBrowserItem(dir, name)
    if item.isDir or item.isLoadable:
      items.add item
  items.sort(
    proc(a, b: BrowserItem): int =
      if a.isDir and not b.isDir:
        -1
      elif not a.isDir and b.isDir:
        1
      else:
        a.name.cmp(b.name)
  )
  items

proc initFireGrid*(height, width: int): seq[seq[int]] =
  result = newSeq[seq[int]](height)
  for i in 0 ..< height:
    result[i] = newSeq[int](width)

proc injectSpark*(state: var AppState) =
  let base = state.fire.len - 1
  for _ in 0 ..< 3:
    let x = rand(state.fire[base].high)
    state.fire[base][x] = min(fireMaxIntensity, state.fire[base][x] + 2)
  # Add fuel on user interaction so the fire can burn brighter for a while
  state.fireFuel = min(200, state.fireFuel + 20)

proc stepFire*(state: var AppState) =
  let height = state.fire.len
  let width = state.fire[0].len
  for y in 0 ..< height - 1:
    for x in 0 ..< width:
      let source = max(0, min(width - 1, x + rand(3) - 1))
      let decay = rand(2) # slower decay than before
      let intensity = max(0, state.fire[y + 1][source] - decay)
      state.fire[y][x] = intensity

  # Compose the bottom row based on remaining fuel
  let emissionChance =
    if state.fireFuel > 0:
      min(10, 2 + state.fireFuel div 20)
    else:
      0

  for x in 0 ..< width:
    if emissionChance > 0 and rand(10) < emissionChance:
      state.fire[height - 1][x] = min(fireMaxIntensity, state.fire[height - 1][x] + 1)
    elif state.fireFuel == 0 and state.fire[height - 1][x] > 0:
      state.fire[height - 1][x] = max(0, state.fire[height - 1][x] - 1)

  # Burn fuel gradually; if no user actions occur, the fire dies
  if state.fireFuel > 0:
    state.fireFuel = max(0, state.fireFuel - 1)

proc renderFire*(state: AppState, tb: var TerminalBuffer, x0, y0: int) =
  let palette = @[
    (' ', fgWhite, bgBlack),
    ('.', fgRed, bgBlack),
    (':', fgRed, bgBlack),
    ('*', fgYellow, bgBlack),
    ('O', fgYellow, bgBlack),
    ('@', fgWhite, bgRed),
  ]
  for y in 0 ..< state.fire.len:
    for x in 0 ..< state.fire[y].len:
      let intensity = state.fire[y][x]
      let (ch, fg, bg) = palette[min(intensity, fireMaxIntensity)]
      tb[x0 + x, y0 + y] =
        TerminalChar(ch: [ch].runeAt(0), fg: fg, bg: bg, style: {}, forceWrite: false)

proc drawBox*(tb: var TerminalBuffer, x0, y0, w, h: int, title: string) =
  tb.fill(x0, y0, x0 + w - 1, y0 + h - 1, " ")
  tb.write(x0, y0, "+" & repeat("-", w - 2) & "+")
  for y in 1 ..< h - 1:
    tb.write(x0, y0 + y, "|")
    tb.write(x0 + w - 1, y0 + y, "|")
  tb.write(x0, y0 + h - 1, "+" & repeat("-", w - 2) & "+")
  if title.len > 0 and w > 4:
    tb.write(x0 + 2, y0, "[" & title & "]")

proc drawLabel*(tb: var TerminalBuffer, x, y: int, label: string) =
  tb.write(x, y, label)

proc padRight(s: string, w: int): string =
  s

proc drawPluginList*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  let plugins = state.runtime.listPlugins()
  drawBox(tb, x0, y0, w, h, " Loaded Plugins ")
  let visible = h - 3
  for i in 0 ..< min(visible, plugins.len):
    let idx = i
    let lineY = y0 + 1 + i
    let text = plugins[idx]
    if idx == state.selectedPlugin:
      tb.setBackgroundColor(bgWhite)
      tb.setForegroundColor(fgBlack)
      tb.write(x0 + 1, lineY, text.padRight(w - 2))
      tb.setBackgroundColor(bgBlack)
      tb.setForegroundColor(fgWhite)
    else:
      tb.write(x0 + 1, lineY, text.padRight(w - 2))
  if plugins.len == 0:
    tb.write(x0 + 1, y0 + 1, "<no loaded plugins>")

proc drawSchema*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  drawBox(tb, x0, y0, w, h, " Schema ")
  let plugins = state.runtime.listPlugins()
  if plugins.len == 0:
    tb.write(x0 + 1, y0 + 1, "No plugin selected.")
    return
  let sel = clampIndex(state.selectedPlugin, plugins.len)
  let name = plugins[sel]
  let schemaRes = state.runtime.pluginSchema(name)
  var lines: seq[string]
  if schemaRes.isOk:
    lines = schemaRes.get.splitLines()
  else:
    lines = @["Error: " & schemaRes.error]
  for i, line in lines.pairs:
    if i >= h - 2:
      break
    tb.write(x0 + 1, y0 + 1 + i, line[0 ..< min(line.len, w - 2)])

proc drawBrowser*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  drawBox(tb, x0, y0, w, h, " Plugin Browser ")
  tb.write(x0 + 1, y0 + 1, state.browserDir[0 ..< min(state.browserDir.len, w - 3)])
  let visible = h - 4
  for i in 0 ..< min(visible, state.browserItems.len):
    let item = state.browserItems[i]
    let lineY = y0 + 2 + i
    var label = item.name
    if item.isDir:
      label = label & "/"
    if item.isLoadable:
      label = label & " [so]"
    if i == state.selectedBrowser:
      tb.setBackgroundColor(bgWhite)
      tb.setForegroundColor(fgBlack)
      tb.write(x0 + 1, lineY, label.padRight(w - 2))
      tb.setBackgroundColor(bgBlack)
      tb.setForegroundColor(fgWhite)
    else:
      tb.write(x0 + 1, lineY, label.padRight(w - 2))
  if state.browserItems.len == 0:
    tb.write(x0 + 1, y0 + 2, "<no libraries found>")

proc drawFooter*(tb: var TerminalBuffer, width, height: int, status: string) =
  let footer =
    "F1=Loaded F2=Browse F3=StartHost F4=ConnectTCP Enter=Open/Load Delete=Unload Backspace=Up ESC=Quit"
  tb.write(0, height - 2, footer[0 ..< min(footer.len, width)])
  tb.write(0, height - 1, status[0 ..< min(status.len, width)])

proc drawMethods*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  drawBox(tb, x0, y0, w, h, " Methods ")
  if state.methods.len == 0:
    tb.write(x0 + 1, y0 + 1, "<no methods available>")
    return
  let visible = h - 3
  for i in 0 ..< min(visible, state.methods.len):
    let lineY = y0 + 1 + i
    let text = state.methods[i]
    if i == state.selectedMethod:
      tb.setBackgroundColor(bgWhite)
      tb.setForegroundColor(fgBlack)
      tb.write(x0 + 1, lineY, text.padRight(w - 2))
      tb.setBackgroundColor(bgBlack)
      tb.setForegroundColor(fgWhite)
    else:
      tb.write(x0 + 1, lineY, text.padRight(w - 2))

proc drawMethodParams*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  drawBox(tb, x0, y0, w, h, " Parameters ")
  if state.methodCall.params.len == 0:
    tb.write(x0 + 1, y0 + 1, "<no parameters>")
    return
  let visible = h - 3
  for i in 0 ..< min(visible, state.methodCall.params.len):
    let lineY = y0 + 1 + i
    let param = state.methodCall.params[i]
    var text = param.name & ": " & param.typeName & " = " & param.value
    if param.isOptional:
      text = "?" & text
    if i == state.methodCall.currentParamIdx:
      tb.setBackgroundColor(bgBlack)
      tb.setForegroundColor(fgWhite)
      text = text & "|"
      tb.write(x0 + 1, lineY, text.padRight(w - 2))
      tb.setBackgroundColor(bgBlack)
      tb.setForegroundColor(fgWhite)
    else:
      tb.write(x0 + 1, lineY, text.padRight(w - 2))

proc drawMethodResult*(state: AppState, tb: var TerminalBuffer, x0, y0, w, h: int) =
  drawBox(tb, x0, y0, w, h, " Result ")
  if state.methodCall.error.len > 0:
    tb.setForegroundColor(fgRed)
    let lines = state.methodCall.error.splitLines()
    for i, line in lines.pairs:
      if i >= h - 2:
        break
      tb.write(x0 + 1, y0 + 1 + i, line[0 ..< min(line.len, w - 2)])
    tb.setForegroundColor(fgWhite)
  elif state.methodCall.result.len > 0:
    tb.setForegroundColor(fgGreen)
    let lines = state.methodCall.result.splitLines()
    for i, line in lines.pairs:
      if i >= h - 2:
        break
      tb.write(x0 + 1, y0 + 1 + i, line[0 ..< min(line.len, w - 2)])
    tb.setForegroundColor(fgWhite)
  else:
    tb.write(x0 + 1, y0 + 1, "<no result yet>")

proc getParentDir*(dir: string): string =
  let parent = splitPath(dir).head
  if parent.len == 0 or parent == dir: dir else: parent

proc refreshBrowser*(state: var AppState) =
  state.browserItems = scanBrowser(state.browserDir)
  state.selectedBrowser = clampIndex(state.selectedBrowser, state.browserItems.len)

proc loadSelectedBrowser*(state: var AppState) =
  if state.browserItems.len == 0:
    state.status = "No browser entry selected."
    return
  let item = state.browserItems[state.selectedBrowser]
  if item.isDir:
    state.browserDir = item.path
    refreshBrowser(state)
    state.status = "Entered " & item.name
  elif item.isLoadable:
    let result = state.runtime.load(item.path)
    if result.isOk:
      state.selectedPlugin = state.runtime.listPlugins().len - 1
      state.status = "Loaded plugin " & result.get[0]
    else:
      state.status = "Load failed: " & result.error
  else:
    state.status = "Not a loadable plugin."

proc unloadSelectedPlugin*(state: var AppState) =
  let plugins = state.runtime.listPlugins()
  if plugins.len == 0:
    state.status = "No plugin to unload."
    return
  let sel = clampIndex(state.selectedPlugin, plugins.len)
  let name = plugins[sel]
  let result = state.runtime.unload(name)
  if result.isOk:
    state.selectedPlugin =
      clampIndex(state.selectedPlugin - 1, state.runtime.listPlugins().len)
    state.status = "Unloaded " & name
  else:
    state.status = "Unload failed: " & result.error

proc callMethodWithParams*(state: var AppState) =
  let plugins = state.runtime.listPlugins()
  if plugins.len == 0:
    state.status = "No plugin loaded."
    return
  let pluginName = plugins[clampIndex(state.selectedPlugin, plugins.len)]
  let cborParamsRes = buildCborParams(state.methodCall.params)
  if cborParamsRes.isErr:
    state.methodCall.error = cborParamsRes.error
    state.methodCall.result = ""
    state.status = "Invalid parameter value"
    return
  let methodName = state.methodCall.methodName
  let dispatchRes = state.runtime.dispatchPlugin(pluginName, methodName, cborParamsRes.get)
  if dispatchRes.isOk:
    state.methodCall.result =
      "Success: " & $dispatchRes.get.len & " bytes returned\n" & toHex(dispatchRes.get) &
      "\n" & $(Cbor.decode(dispatchRes.get(), CborValueRef))

    state.methodCall.error = ""
    state.status = "Method called successfully"
  else:
    state.methodCall.error = dispatchRes.error
    state.methodCall.result = ""
    state.status = "Method call failed"

proc callMethodOnSelectedPlugin*(state: var AppState) =
  let plugins = state.runtime.listPlugins()
  if plugins.len == 0:
    state.status = "No plugin selected."
    return
  let pluginName = plugins[clampIndex(state.selectedPlugin, plugins.len)]
  let schemaRes = state.runtime.pluginSchema(pluginName)
  if schemaRes.isErr:
    state.status = "Failed to get schema x: " & schemaRes.error
    return
  let schema = schemaRes.get
  state.methods = extractMethodsFromSchema(schema)
  if state.methods.len == 0:
    state.status = "No methods available."
    return
  state.selectedMethod = 0
  state.mode = methodSelecting
  state.status = "Select a method to call (Enter to call, Up/Down to select)"
  state.methodCall.plugin = pluginName

proc dispatchSelectedMethod*(state: var AppState) =
  if state.methods.len == 0 or state.selectedMethod >= state.methods.len:
    state.status = "Invalid method selection."
    return
  let plugins = state.runtime.listPlugins()
  if plugins.len == 0:
    state.status = "No plugin loaded."
    return
  let pluginName = plugins[clampIndex(state.selectedPlugin, plugins.len)]
  let schemaRes = state.runtime.pluginSchema(pluginName)
  if schemaRes.isErr:
    state.status = "Failed to get schema."
    return
  let methodName = state.methods[state.selectedMethod]
  let schema = schemaRes.get
  let params = extractMethodParams(schema, methodName)
  state.methodCall = initMethodCall(pluginName, methodName, params)
  if params.len == 0:
    # No parameters, call immediately
    let cborParamsRes = buildCborParams(state.methodCall.params)
    if cborParamsRes.isErr:
      state.methodCall.error = cborParamsRes.error
      state.methodCall.result = ""
      state.status = "Invalid parameter value"
      return
    let dispatchRes = state.runtime.dispatchPlugin(pluginName, methodName, cborParamsRes.get)
    if dispatchRes.isOk:
      state.methodCall.result =
        "Success: " & $dispatchRes.get.len & " bytes returned\n" & toHex(
          dispatchRes.get
        ) & "\n" & $(Cbor.decode(dispatchRes.get(), CborValueRef))
      state.methodCall.error = ""
      state.status = "Method called successfully"
    else:
      state.methodCall.error = dispatchRes.error
      state.methodCall.result = ""
      state.status = "Method call failed"
  else:
    state.status =
      "Enter parameter values (Up/Down to navigate, type to edit, Enter to confirm)"

proc drawMain*(state: AppState) =
  let width = terminalWidth()
  let height = terminalHeight()
  let panelWidth = min(firePanelWidth, max(8, width div 6))
  let mainWidth = max(1, width - panelWidth - 2)
  let mainHeight = max(1, height - 4)

  var tb = newTerminalBuffer(width, height)
  tb.clear()
  tb.write(1, 0, "Logos Runtime TUI - " & $(state.mode))
  if state.mode == loadedPlugins:
    let listHeight = max(6, mainHeight div 2)
    drawPluginList(state, tb, 0, 2, mainWidth, listHeight)
    drawSchema(state, tb, 0, 2 + listHeight, mainWidth, mainHeight - listHeight)
  elif state.mode in {methodCalling, methodSelecting}:
    let methodListHeight = max(5, mainHeight div 3)
    let paramHeight = max(5, mainHeight div 3)
    drawMethods(state, tb, 0, 2, mainWidth, methodListHeight)
    drawMethodParams(state, tb, 0, 2 + methodListHeight, mainWidth, paramHeight)
    drawMethodResult(
      state,
      tb,
      0,
      2 + methodListHeight + paramHeight,
      mainWidth,
      mainHeight - methodListHeight - paramHeight,
    )
  else:
    drawBrowser(state, tb, 0, 2, mainWidth, mainHeight)
  renderFire(state, tb, mainWidth + 2, 2)
  drawFooter(tb, width, height, state.status)
  display(tb)

proc runApp*() =
  var state = AppState(
    runtime: newRuntime(),
    mode: loadedPlugins,
    selectedPlugin: 0,
    selectedBrowser: 0,
    browserDir: getCurrentDir(),
    browserItems: @[],
    status: "Welcome to Logos Runtime TUI",
    fire: @[],
    methods: @[],
    selectedMethod: 0,
    methodCall: MethodCall(
      plugin: "", methodName: "", params: @[], currentParamIdx: 0, result: "", error: ""
    ),
    serverRunning: false,
  )
  state.browserItems = scanBrowser(state.browserDir)
  state.fire = initFireGrid(
    max(1, terminalHeight() - 4), min(firePanelWidth, max(8, terminalWidth() div 6))
  )

  illwillInit(fullScreen = true)
  defer:
    illwillDeinit()

  let keys = open("/tmp/keys.txt", fmWrite)
  while true:
    let termHeight = terminalHeight()
    let termWidth = terminalWidth()
    let desiredHeight = max(1, termHeight - 4)
    let desiredWidth = min(firePanelWidth, max(8, termWidth div 6))
    if state.fire.len != desiredHeight or state.fire[0].len != desiredWidth:
      state.fire = initFireGrid(desiredHeight, desiredWidth)

    stepFire(state)
    drawMain(state)
    let key = getKeyWithTimeout(100)
    if key != Key.None:
      keys.write($key & "\n")

      injectSpark(state)
      case key
      of Key.Escape:
        if state.mode == methodSelecting:
          state.mode = loadedPlugins
          state.status = "Returned to loaded plugins"
        elif state.mode == methodCalling:
          state.mode = methodSelecting
          state.status = "Select methods"
        else:
          break
      of Key.F1:
        state.mode = loadedPlugins
        state.status = "Switched to loaded plugins"
      of Key.F2:
        state.mode = pluginBrowser
        state.status = "Switched to plugin browser"
      of Key.F3:
        let startRes = state.runtime.startTcpHost(defaultTcpHostPort)
        if startRes.isOk:
          state.serverRunning = true
          state.status = "TCP host listening on port " & $defaultTcpHostPort
        else:
          state.status = "Failed to start TCP host: " & startRes.error
      of Key.F4:
        let target = "tcp://127.0.0.1:" & $defaultTcpHostPort
        let result = state.runtime.load(target)
        if result.isOk:
          state.selectedPlugin = state.runtime.listPlugins().len - 1
          state.status = "Connected to TCP target " & target
        else:
          state.status = "TCP load failed: " & result.error
      of Key.Up:
        if state.mode == loadedPlugins:
          state.selectedPlugin = max(0, state.selectedPlugin - 1)
        elif state.mode == methodSelecting:
          if state.selectedMethod > 0:
            state.selectedMethod -= 1
            let pluginName = state.methodCall.plugin
            let schemaRes = state.runtime.pluginSchema(pluginName)
            if schemaRes.isOk:
              let params =
                extractMethodParams(schemaRes.get, state.methods[state.selectedMethod])
              state.methodCall =
                initMethodCall(pluginName, state.methods[state.selectedMethod], params)
              state.status = "Switched to method " & state.methods[state.selectedMethod]
            else:
              state.status = "Error fetching schema: " & schemaRes.error
          else:
            state.status = "Already at first method"
        elif state.mode == methodCalling:
          state.methodCall.currentParamIdx =
            max(0, state.methodCall.currentParamIdx - 1)
        else:
          state.selectedBrowser = max(0, state.selectedBrowser - 1)
      of Key.Down:
        if state.mode == loadedPlugins:
          state.selectedPlugin =
            min(state.selectedPlugin + 1, max(0, state.runtime.listPlugins().len - 1))
        elif state.mode == methodSelecting:
          if state.selectedMethod < state.methods.len - 1:
            state.selectedMethod += 1
            let pluginName = state.methodCall.plugin
            let schemaRes = state.runtime.pluginSchema(pluginName)
            if schemaRes.isOk:
              let params =
                extractMethodParams(schemaRes.get, state.methods[state.selectedMethod])
              state.methodCall =
                initMethodCall(pluginName, state.methods[state.selectedMethod], params)
              state.status = "Switched to method " & state.methods[state.selectedMethod]
            else:
              state.status = "Error fetching schema " & pluginName & ": " & schemaRes.error
          else:
            state.status = "Already at last method"
        elif state.mode == methodCalling:
          state.methodCall.currentParamIdx = min(
            state.methodCall.currentParamIdx + 1,
            max(0, state.methodCall.params.len - 1),
          )
        else:
          state.selectedBrowser =
            min(state.selectedBrowser + 1, max(0, state.browserItems.len - 1))
      of Key.Backspace:
        if state.mode == methodCalling:
          if state.methodCall.currentParamIdx < state.methodCall.params.len:
            if state.methodCall.params[state.methodCall.currentParamIdx].value.len > 0:
              state.methodCall.params[state.methodCall.currentParamIdx].value = state.methodCall.params[
                state.methodCall.currentParamIdx
              ].value[
                0 ..<
                  state.methodCall.params[state.methodCall.currentParamIdx].value.len - 1
              ]
        elif state.mode == pluginBrowser:
          let parent = getParentDir(state.browserDir)
          if parent.len > 0 and parent != state.browserDir:
            state.browserDir = parent
            refreshBrowser(state)
            state.status = "Moved up to " & state.browserDir
      of Key.Enter:
        if state.mode == loadedPlugins:
          callMethodOnSelectedPlugin(state)
        elif state.mode == methodSelecting:
          dispatchSelectedMethod(state)
          state.mode = methodCalling
        elif state.mode == methodCalling:
          # If we're in method selection, dispatch the method
          if state.methodCall.methodName == "":
            dispatchSelectedMethod(state)
          elif state.methodCall.params.len == 0:
            # No parameters, call immediately
            callMethodWithParams(state)
          elif state.methodCall.currentParamIdx >= state.methodCall.params.len - 1:
            # Last parameter, call the method
            callMethodWithParams(state)
          else:
            # Move to next parameter
            state.methodCall.currentParamIdx += 1
            state.status =
              "Enter value for " &
              state.methodCall.params[state.methodCall.currentParamIdx].name
        else:
          loadSelectedBrowser(state)
      of Key.Delete:
        if state.mode == loadedPlugins:
          unloadSelectedPlugin(state)
      else:
        if state.mode == methodCalling:
          # Handle character input for parameter editing
          if ord(key) >= 32 and ord(key) <= 127:
            let keyStr = $char(ord(key))
            if state.methodCall.currentParamIdx < state.methodCall.params.len:
              state.methodCall.params[state.methodCall.currentParamIdx].value.add(
                keyStr
              )

proc main() =
  runApp()

when isMainModule:
  main()
