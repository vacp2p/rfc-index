# modules residing in shared librarys (.so/.dll/etc)

import ./iface, results
import std/[os, strutils, dynlib]

{.pragma: capi, cdecl, raises: [], gcsafe.}

type
  # C function pointer types per LOGOS-MODULE-INTERFACE spec section 2.6
  LogosNameFn* = proc(): cstring {.capi.}
  LogosSchemFn* = proc(): cstring {.capi.}
  LogosVersionFn* = proc(): cstring {.capi.}
  LogosInitFn* = proc(): cint {.capi.}
  LogosDestroyFn* = proc() {.capi.}
  LogosDispatchFn* = proc(
    meth: cstring,
    request_payload: ptr uint8,
    request_len: csize_t,
    response_payload: ptr ptr uint8,
    response_len: ptr csize_t,
  ): cint {.capi.}
  LogosFreeFn* = proc(p: pointer) {.capi.}

  SharedModule* = object
    name*: string
    version*: string
    schema*: string
    handle*: LibHandle

    initFn*: LogosInitFn
    dispatchFn: LogosDispatchFn
    destroyFn*: LogosDestroyFn
    freeFn*: LogosFreeFn

proc `=copy`*(a: var SharedModule, b: SharedModule) {.error.}
proc `=destroy`*(m: var SharedModule) =
  ## Unload a m and clean up resources.
  if not m.handle.isNil:
    if not m.destroyFn.isNil:
      m.destroyFn()
    dynlib.unloadLib(m.handle)
    m.handle = nil

proc dispatch*(
    m: SharedModule, meth: string, params: openArray[byte]
): Result[seq[byte], string] =
  var response_ptr: ptr uint8
  var response_len: csize_t

  let request_ptr =
    if params.len > 0:
      addr params[0]
    else:
      nil
  let dispatch_result = m.dispatchFn(
    meth.cstring, request_ptr, params.len.csize_t, addr response_ptr, addr response_len
  )

  if dispatch_result != 0:
    if not response_ptr.isNil:
      m.freeFn(response_ptr)
    return err("Dispatch failed with code: " & $dispatch_result)

  if response_ptr.isNil:
    return ok(newSeq[byte]())

  # Copy response bytes
  var response = newSeq[byte](response_len)
  if response_len > 0:
    copyMem(addr response[0], response_ptr, response_len)

  m.freeFn(response_ptr)
  ok(response)

proc init*(_: type SharedModule, path: string): Result[SharedModule, string] =
  ## Load a Logos module using dlopen/dlsym according to LOGOS-MODULE-INTERFACE spec.
  if not fileExists(path):
    return err("Module file not found: " & path)

  # Load the shared library
  let handle = dynlib.loadLib(path)
  if handle.isNil:
    return err("Failed to load m library: " & path)

  # Bootstrap: load logos_module_name to discover the m name
  let bootstrap_name = dynlib.symAddr(handle, "logos_module_name")
  if bootstrap_name.isNil:
    dynlib.unloadLib(handle)
    return err("Bootstrap symbol 'logos_module_name' not found")

  let get_bootstrap_name = cast[LogosNameFn](bootstrap_name)
  let module_name_c = get_bootstrap_name()
  if module_name_c.isNil:
    dynlib.unloadLib(handle)
    return err("logos_module_name() returned null")

  let module_name = $module_name_c

  # Construct full symbol names per spec section 2.6
  # Hyphens in m name are replaced with underscores
  let module_prefix = "logos_" & module_name.replace("-", "_") & "_"

  # Load required symbols
  let name_sym = dynlib.symAddr(handle, module_prefix & "name")
  let schema_sym = dynlib.symAddr(handle, module_prefix & "schema")
  let version_sym = dynlib.symAddr(handle, module_prefix & "version")
  let init_sym = dynlib.symAddr(handle, module_prefix & "init")
  let destroy_sym = dynlib.symAddr(handle, module_prefix & "destroy")
  let dispatch_sym = dynlib.symAddr(handle, module_prefix & "dispatch")
  let free_sym = dynlib.symAddr(handle, "logos_free")

  if name_sym.isNil or schema_sym.isNil or version_sym.isNil or init_sym.isNil or
      destroy_sym.isNil or dispatch_sym.isNil or free_sym.isNil:
    dynlib.unloadLib(handle)
    return err("One or more required symbols not found in m")

  # Cast to proper function types
  let get_name = cast[LogosNameFn](name_sym)
  let get_schema = cast[LogosSchemFn](schema_sym)
  let get_version = cast[LogosVersionFn](version_sym)
  let init_fn = cast[LogosInitFn](init_sym)
  let destroy_fn = cast[LogosDestroyFn](destroy_sym)
  let dispatch_fn = cast[LogosDispatchFn](dispatch_sym)
  let free_fn = cast[LogosFreeFn](free_sym)

  # Call init to initialize the m
  let init_result = init_fn()
  if init_result != 0:
    destroy_fn()
    dynlib.unloadLib(handle)
    return err("M initialization failed with code: " & $init_result)

  # Retrieve m metadata
  let name_str = $get_name()
  let version_str = $get_version()
  let schema_str = $get_schema()

  # Create a wrapper dispatch function that matches the expected signature
  var m = SharedModule(
    name: name_str,
    version: version_str,
    schema: schema_str,
    handle: handle,
    initFn: init_fn,
    dispatchFn: dispatch_fn,
    destroyFn: destroy_fn,
    freeFn: free_fn,
  )

  ok(m)
