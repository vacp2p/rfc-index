# src/logos_core/high_level.nim
# High-level Nim-friendly types for the Logos module interface.
# Wraps C ABI types with convenience conversions (cstring→string, pointer/len→seq[byte]).

import results
import ./abi_types

# ============================================================================
# Reexports — types that are identical at ABI and high-level
# ============================================================================

export LogosErrorCode

{.pragma: api, raises: [], gcsafe.}

# ============================================================================
# High-level function types
# These are Nim-proc-style wrappers around the C ABI function pointers.
# ============================================================================

type
  ## Lifecycle _init — returns 0 on success, non-zero error code
  InitFn* = proc(): cint {.api.}

  ## Lifecycle destroy
  DestroyFn* = proc() {.api.}

  ## Module memory deallocator
  FreeFn* = proc(p: pointer){.api.}

  ## High-level dispatch — takes a method name and CBOR bytes, returns a Result.
  DispatchFn* =
    proc(meth: string, params: openArray[byte]): Result[seq[byte], string] {.api.}

  ## High-level publish callback — event data as seq[byte]
  PublishFn* = proc(eventData: seq[byte]) {.api.}

  ## Setter for the high-level publish callback
  PublishSetter* = proc(fn: PublishFn, userData: pointer) {.api.}

  ## High-level call-module callback — takes target name and request bytes,
  ## returns a Result with the response bytes.
  CallModuleFn* = proc(
    targetModule: string, requestCbor: openArray[byte]
  ): Result[seq[byte], string] {.api.}

  ## Response deallocator for call-module
  FreeResponseFn* = proc(p: pointer) {.api.}

  ## Setter for the high-level call-module callback
  CallModuleSetter* =
    proc(fn: CallModuleFn, freeFn: FreeResponseFn, userData: pointer) {.api.}

  ## A loaded Logos module at the high-level Nim API.
  ## Holds the module metadata and the high-level dispatch function.
  ## The actual FFI bridges are created by wrapDispatchFn etc.
  Module* = object
    name*: string
    host*: string
    version*: string
    schema*: string

    ## Mandatory lifecycle
    initFn*: InitFn
    destroyFn*: DestroyFn

    dispatchFn*: DispatchFn
    freeFn*: FreeFn

    ## Optional callbacks (may be nil if module doesn't publish or call modules)
    publishSetter*: Opt[PublishSetter]
    callModuleSetter*: Opt[CallModuleSetter]

# ============================================================================
# Conversion procs — bridge ABI types to high-level types
# ============================================================================

## Convert a cstring to a Nim string
proc toString*(s: cstring): string =
  ## Convert a C string (cstring) to a Nim string.
  ## Returns an empty string if s is nil.
  if s.isNil:
    ""
  else:
    $s

## Convert a pointer + length pair to a seq[byte]
proc toSeqBytes(data: pointer, len: csize_t): seq[byte] =
  ## Convert a raw pointer and length to a seq[byte].
  ## Caller is responsible for ensuring the memory is valid.
  if data.isNil or len == 0:
    return @[]
  result = newSeqUninit[byte](len)
  copyMem(addr result[0], data, len)

## Wrap a LogosDispatchFnAbi into a DispatchFn.
## Takes responsibility for the callee-allocated response buffer via freeFn.
proc wrapDispatchFn*(dispatch: LogosDispatchFnAbi, freeFn: LogosFreeFnAbi): DispatchFn =
  ## Wrap the raw C ABI dispatch into a Nim Result-returning proc.
  proc impl(meth: string, params: openArray[byte]): Result[seq[byte], string] {.api.} =
    var respPtr: ptr uint8
    var respLen: csize_t

    let paramsPtr =
      if params.len > 0:
        addr params[0]
      else:
        nil

    let code =
      dispatch(meth.cstring, paramsPtr, params.len.csize_t, addr respPtr, addr respLen)

    if code != 0:
      if not respPtr.isNil:
        freeFn(respPtr)
      return err("Dispatch failed with code: " & $code)

    if respPtr.isNil:
      return ok(newSeq[byte]())

    let response = toSeqBytes(respPtr, respLen)
    freeFn(respPtr)
    ok(response)

  return impl

## Wrap a LogosPublishFnAbi into a PublishFn.
proc wrapPublishFn(fn: LogosPublishFnAbi): PublishFn =
  ## Wrap the raw C ABI publish callback into a Nim seq[byte] proc.
  proc impl(eventData: seq[byte]) {.api.} =
    if eventData.len > 0:
      fn(addr eventData[0], eventData.len.csize_t)
    else:
      fn(nil, 0)

  return impl

## Wrap a LogosCallModuleFnAbi into a CallModuleFn.
proc wrapCallModuleFn(
    fn: LogosCallModuleFnAbi, freeResp: LogosFreeResponseFnAbi
): CallModuleFn =
  ## Wrap the raw C ABI call-module callback into a Nim Result proc.
  proc impl(
      targetModule: string, requestCbor: openArray[byte]
  ): Result[seq[byte], string] {.api.} =
    var respPtr: ptr uint8
    var respLen: csize_t

    let reqPtr =
      if requestCbor.len > 0:
        addr requestCbor[0]
      else:
        nil

    let code = fn(
      targetModule.cstring, reqPtr, requestCbor.len.csize_t, addr respPtr, addr respLen
    )

    if code != 0:
      if not respPtr.isNil:
        freeResp(respPtr)
      return err("Call module failed with code: " & $code)

    if respPtr.isNil:
      return ok(newSeq[byte]())

    let response = toSeqBytes(respPtr, respLen)
    freeResp(respPtr)
    ok(response)

  return impl

# ============================================================================
# Runtime Control Schema Types (from LOGOS-MODULE-RUNTIME Section 9.1)
# These types support transport Hello schema commitment and
# the Runtime Control module contract.
# ============================================================================

type
  ## Address types
  AddressProfile* = string
  FailureCode* = string
  Reason* = string
  RouteId* = string
  ModuleName* = string
  RuntimeInstanceId* = string
  ModuleProviderId* = string
  ModuleInstanceId* = string
  SchemaNamespace* = string
  DescriptorKind* = string
  AuthorityRef* = string
  AuditRef* = string
  HostName* = string
  Port* = uint16
  Path* = string
  ServerName* = string
  Alpn* = string

  ## Runtime address transport tag
  RuntimeAddressTag* {.pure.} = enum
    ratUnixStream
    ratTcp
    ratTlsTcp
    ratQuic

  ## Per-transport address variants
  UnixStreamAddress* = object
    path*: Path
    profile*: Opt[AddressProfile]

  TcpAddress* = object
    host*: HostName
    port*: Port
    profile*: Opt[AddressProfile]

  TlsTcpAddress* = object
    host*: HostName
    port*: Port
    serverName*: Opt[ServerName]
    profile*: Opt[AddressProfile]

  QuicAddress* = object
    host*: HostName
    port*: Port
    serverName*: Opt[ServerName]
    alpn*: Opt[Alpn]
    profile*: Opt[AddressProfile]

  ## Discriminated union for runtime address
  ## Using a tag + case approach for Nim compatibility
  RuntimeAddressValue* = object
    tag*: RuntimeAddressTag
    unixStream*: UnixStreamAddress
    tcp*: TcpAddress
    tlsTcp*: TlsTcpAddress
    quic*: QuicAddress

  ## Runtime identity + address pair
  RuntimeEndpoint* = object
    runtimeInstanceId*: Opt[RuntimeInstanceId]
    address*: RuntimeAddressValue

  ## Target for a remote provider
  RemoteProviderTarget* = object
    runtime*: RuntimeEndpoint
    provider*: Opt[ModuleProviderId]
    module*: Opt[ModuleName]

  ## Structural schema commitment
  SchemaCommitment* = object
    commitmentModel*: string
    schemaRoot*: seq[byte] # CDDL bstr - raw bytes, no hash spec yet
    hashProfile*: string
    hashSuite*: string

  ## Address of a provider record inside a runtime instance
  ModuleProviderAddress* = object
    runtimeInstanceId*: Opt[RuntimeInstanceId]
    provider*: ModuleProviderId

  ## Module lifecycle state enum (spec string literals)
  State* {.pure.} = enum
    sUnloaded
    sLoaded
    sReady
    sStopping
    sError

  ## Module execution mode enum
  Mode* {.pure.} = enum
    mDirect
    mLocalTransport
    mRemoteTransport

  ## Route state enum
  RouteState* {.pure.} = enum
    rsEstablishing
    rsReady
    rsDraining
    rsRevoked
    rsFailed
    rsClosed

  ## Invocation descriptor
  InvocationDescriptor* = object
    kind*: Mode
    descriptorKind*: DescriptorKind
    descriptor*: Opt[seq[byte]]

  ## Route authority
  RouteAuthority* = object
    authorityProvider*: Opt[ModuleProviderAddress]
    authorityRef*: Opt[AuthorityRef]
    expiresAt*: Opt[uint64]
    auditRef*: Opt[AuditRef]

  ## Route failure info
  RouteFailure* = object
    code*: FailureCode
    message*: Opt[Reason]

  ## Module record (runtime introspection)
  ModuleRecord* = object
    module*: ModuleName
    provider*: Opt[ModuleProviderAddress]
    remote*: Opt[RemoteProviderTarget]
    instance*: Opt[ModuleInstanceId]
    state*: State
    mode*: Mode
    schemaNamespace*: Opt[SchemaNamespace]
    schema*: Opt[SchemaCommitment]
    reason*: Opt[Reason]

  ## Route record
  RouteRecord* = object
    route*: RouteId
    callerRuntime*: RuntimeInstanceId
    targetProvider*: ModuleProviderAddress
    module*: ModuleName
    instance*: Opt[ModuleInstanceId]
    schemaNamespace*: Opt[SchemaNamespace]
    schema*: Opt[SchemaCommitment]
    state*: RouteState
    invocation*: InvocationDescriptor
    authority*: Opt[RouteAuthority]
    failure*: Opt[RouteFailure]
