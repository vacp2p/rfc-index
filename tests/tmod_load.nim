# Tests for loading and unloading shared library modules

import unittest
import os, strutils, tables
import ../src/logos_core/[runtime, shared_modules, modules]
import results

# Resolve the .so path relative to this tests/ directory
var exploitSo = getCurrentDir() / "src" / "libexploit.so"
normalizePath(exploitSo)

suite "Shared module load/unload":

  test "SharedModule.init fails for nonexistent file":
    let res = SharedModule.init("/tmp/nonexistent_module_xyz.so")
    check res.isErr
    check res.error.contains("Module file not found")

  test "Runtime.load with shared lib":
    var rt = newRuntime()
    let res = rt.load(exploitSo)
    check res.isOk
    let (name, version) = res.get
    check name == "exploit"
    check version == "1.0"
    check rt.listPlugins().contains("exploit")
    rt.shutdown()

  test "Runtime.unload removes module":
    var rt = newRuntime()
    discard rt.load(exploitSo)
    check rt.listPlugins().contains("exploit")
    let res = rt.unload("exploit")
    check res.isOk
    check not rt.listPlugins().contains("exploit")
    rt.shutdown()

  test "Runtime.unload nonexistent module fails":
    var rt = newRuntime()
    let res = rt.unload("nope")
    check res.isErr
    check res.error.contains("Plugin not loaded")
    rt.shutdown()

  test "Runtime.load then unload then load again":
    var rt = newRuntime()
    discard rt.load(exploitSo)
    check rt.listPlugins().contains("exploit")
    discard rt.unload("exploit")
    check not rt.listPlugins().contains("exploit")
    let res = rt.load(exploitSo)
    check res.isOk
    check rt.listPlugins().contains("exploit")
    rt.shutdown()

  test "Runtime.listPlugins returns correct set":
    var rt = newRuntime()
    check rt.listPlugins().len == 0
    discard rt.load(exploitSo)
    let plugins = rt.listPlugins()
    check plugins.len == 1
    check plugins[0] == "exploit"
    rt.shutdown()

  test "Runtime.shutdown cleans up":
    var rt = newRuntime()
    discard rt.load(exploitSo)
    rt.shutdown()
    check rt.modules.len == 0

  test "Runtime.pluginSchema returns valid schema":
    var rt = newRuntime()
    discard rt.load(exploitSo)
    let res = rt.pluginSchema("exploit")
    check res.isOk
    check res.get.contains("exploit.exec")
    rt.shutdown()

  test "Runtime.pluginSchema fails for nonexistent module":
    var rt = newRuntime()
    let res = rt.pluginSchema("nope")
    check res.isErr
    check res.error.contains("Plugin not loaded")
    rt.shutdown()
