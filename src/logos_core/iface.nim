# src/logos_core/interface.nim

import results, std/dynlib

## Error codes for the Logos protocol.
type
  LogosErrorCode* {.pure.} = enum
    ok = 0
    methodNotFound = 1
    invalidParams = 2
    moduleError = 3
    notAuthorised = 4
    transportError = 5
    timeout = 6
    versionMismatch = 7
    not_ready = 8
    cancelled = 9

## The result of a Logos operation.
type LogosResult* = object
  code: LogosErrorCode
  message*: string
  detail*: string # Using string for simplicity in Nim, can be converted to/from bytes

## An opaque handle to a Logos module.
type
  InitFn* = proc(): cint {.gcsafe, raises: [].}
  DispatchFn* = proc(meth: string, params: openArray[byte]): Result[seq[byte], string] {.gcsafe, raises: [].}
  DestroyFn* = proc() {.gcsafe, raises: [].}

  Module* = object
    name*: string
    host*: string # Where the module is running
    version*: string
    schema*: string

    initFn*: InitFn
    dispatchFn*: DispatchFn
    destroyFn*: DestroyFn
