# src/logos_core/shared_modules.nim
# Modules residing in shared libraries (.so/.dll/etc)
# Per LOGOS-MODULE-INTERFACE §2.6 — loads C ABI symbols from shared objects

import results
import std/[os, strutils, dynlib]
import ./abi_types

{.pragma: capi, cdecl, raises: [], gcsafe.}

type
  SharedModule* = object
    name*: string
    version*: string
    schema*: string
    handle*: LibHandle

    ## Mandatory lifecycle (ABI function pointers)
    initFn*: LogosInitFnAbi
    dispatchFn*: LogosDispatchFnAbi
    destroyFn*: LogosDestroyFnAbi
    freeFn*: LogosFreeFnAbi

    ## Optional callbacks (ABI function pointers)
    publishSetter*: Opt[LogosSetPublishFnAbi]
    callModuleSetter*: Opt[LogosSetCallModuleFnAbi]

proc `=copy`*(a: var SharedModule, b: SharedModule) {.error.}

proc `=destroy`*(m: var SharedModule) =
  ## Unload m and clean up resources.
  if not m.handle.isNil:
    if not m.destroyFn.isNil:
      m.destroyFn()
    dynlib.unloadLib(m.handle)
    m.handle = nil

proc dispatch*(
  m: SharedModule, meth: string, params: openArray[byte]
): Result[seq[byte], string] =
  var responsePtr: ptr uint8
  var responseLen: csize_t

  let requestPtr =
    if params.len > 0:
      addr params[0]
    else:
      nil
  let dispatchResult = m.dispatchFn(
    meth.cstring, requestPtr, params.len.csize_t, addr responsePtr, addr responseLen
  )

  if dispatchResult != 0:
    if not responsePtr.isNil:
      m.freeFn(responsePtr)
    return err("Dispatch failed with code: " & $dispatchResult)

  if responsePtr.isNil:
    return ok(newSeq[byte]())

  # Copy response bytes
  var response = newSeq[byte](responseLen)
  if responseLen > 0:
    copyMem(addr response[0], responsePtr, responseLen)

  m.freeFn(responsePtr)
  ok(response)

proc init*(_: type SharedModule, path: string): Result[SharedModule, string] =
  ## Load a Logos module using dlopen/dlsym according to LOGOS-MODULE-INTERFACE spec.
  ## Per §2.6: mandatory symbols _dispatch and _free are required.
  if not fileExists(path):
    return err("Module file not found: " & path)

  # Load the shared library
  let handle = dynlib.loadLib(path)
  if handle.isNil:
    return err("Failed to load module library: " & path)

  # Bootstrap: load logos_module_name to discover the module name
  let bootstrapName = dynlib.symAddr(handle, "logos_module_name")
  if bootstrapName.isNil:
    dynlib.unloadLib(handle)
    return err("Bootstrap symbol 'logos_module_name' not found")

  let getBootstrapName = cast[LogosNameFnAbi](bootstrapName)
  let moduleNameC = getBootstrapName()
  if moduleNameC.isNil:
    dynlib.unloadLib(handle)
    return err("logos_module_name() returned null")

  let moduleName = $moduleNameC

  # Construct full symbol names per spec section 2.6
  # Hyphens in module name are replaced with underscores
  let modulePrefix = "logos_" & moduleName.replace("-", "_") & "_"

  # Load mandatory symbols
  let nameSym = dynlib.symAddr(handle, cstring(modulePrefix & "name"))
  let schemaSym = dynlib.symAddr(handle, cstring(modulePrefix & "schema"))
  let versionSym = dynlib.symAddr(handle, cstring(modulePrefix & "version"))
  let initSym = dynlib.symAddr(handle, cstring(modulePrefix & "init"))
  let destroySym = dynlib.symAddr(handle, cstring(modulePrefix & "destroy"))
  let dispatchSym = dynlib.symAddr(handle, cstring(modulePrefix & "dispatch"))
  let freeSym = dynlib.symAddr(handle, "logos_free")

  # Check mandatory symbols
  if dispatchSym.isNil or freeSym.isNil:
    dynlib.unloadLib(handle)
    return err("Missing mandatory module symbols: logos_" & moduleName & "_dispatch and/or logos_free")

  if nameSym.isNil or schemaSym.isNil or versionSym.isNil or initSym.isNil or
      destroySym.isNil:
    dynlib.unloadLib(handle)
    return err("One or more required symbols not found in module")

  # Load optal symbols (may be nil)
  let publishSym = dynlib.symAddr(handle, cstring(modulePrefix & "set_publish"))
  let callSym = dynlib.symAddr(handle, cstring(modulePrefix & "set_call_module"))

  # Cast to proper function types
  let getName = cast[LogosNameFnAbi](nameSym)
  let getSchema = cast[LogosSchemaFnAbi](schemaSym)
  let getVersion = cast[LogosVersionFnAbi](versionSym)
  let initFn = cast[LogosInitFnAbi](initSym)
  let destroyFn = cast[LogosDestroyFnAbi](destroySym)
  let dispatchFn = cast[LogosDispatchFnAbi](dispatchSym)
  let freeFn = cast[LogosFreeFnAbi](freeSym)

  # Call init to initialize the module
  let initResult = initFn()
  if initResult != 0:
    destroyFn()
    dynlib.unloadLib(handle)
    return err("Module initialization failed with code: " & $initResult)

  # Retrieve module metadata
  let nameStr = $getName()
  let versionStr = $getVersion()
  let schemaStr = $getSchema()

  # Build optal callbacks
  var pubSetter: Opt[LogosSetPublishFnAbi] = Opt.none(LogosSetPublishFnAbi)
  var callSetter: Opt[LogosSetCallModuleFnAbi] = Opt.none(LogosSetCallModuleFnAbi)

  if not publishSym.isNil:
    pubSetter = Opt.some(cast[LogosSetPublishFnAbi](publishSym))
  if not callSym.isNil:
    callSetter = Opt.some(cast[LogosSetCallModuleFnAbi](callSym))

  var m = SharedModule(
    name: nameStr,
    version: versionStr,
    schema: schemaStr,
    handle: handle,
    initFn: initFn,
    dispatchFn: dispatchFn,
    destroyFn: destroyFn,
    freeFn: freeFn,
    publishSetter: pubSetter,
    callModuleSetter: callSetter,
  )

  ok(m)
