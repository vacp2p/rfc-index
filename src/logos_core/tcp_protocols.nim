# src/logos_core/tcp_protocols.nim
# Protocol types and TCP utilities for Logos module transport
# Per LOGOS-MODULE-TRANSPORT Section 1.3 (message definitions)
# Types are imported from high_level.nim; this module adds transport-specific payloads.

import ./[cbor_stuff, modules]
import results
import std/[net, strutils]

const defaultTcpProtocol* = 1'u32

## Transport-specific payload types (these are NOT in high_level.nim)
## They use the types defined there (SchemaCommitment, etc.)

type
  ## Subscribe/Unsubscribe - per LOGOS-MODULE-TRANSPORT Section 5
  SubscribePayload* = object
    subId*: uint32 # subscription-id (renamed from 'id' to avoid keyword)
    eventName*: string # event name (renamed from 'event')

  UnsubscribePayload* = object
    subId*: uint32 # subscription-id

  ## Cancel - per LOGOS-MODULE-TRANSPORT Section 6
  CancelPayload* = object
    callId*: uint32 # call-id (renamed from 'id')

  ## Event payload - per LOGOS-MODULE-TRANSPORT Section 5
  EventPayload* = object
    subId*: uint32 # subscription-id
    eventName*: string # event name
    eventData*: seq[byte] # CBOR-encoded event map (renamed from 'data')

  ## Protocol error - per LOGOS-MODULE-TRANSPORT Section 1.3 (kind 6)
  ProtocolErrorPayload* = object
    errCode*: int # error code (renamed from 'code')
    errMsg*: string # error message (renamed from 'message')
    errDetail*: Opt[seq[byte]] # optional detail

## Transport request/response - per LOGOS-MODULE-TRANSPORT Section 4
## Using snake_case field names to avoid Nim keyword conflicts
type
  TransportRequest* = object
    callId*: uint32 # call-id correlation (renamed from 'id')
    methodName*: string # method name (renamed from 'method')
    params*: seq[byte] # CBOR-encoded request params

  TransportResponse* = object
    callId*: uint32 # echo of request call-id
    responseResult*: Opt[seq[byte]] # result (renamed from 'result')
    responseError*: Opt[string] # error message (renamed from 'error')

## RPC-style convenience types for the TCP host
type
  HelloRequest* = object
    protocol*: uint32
    module*: string
    version*: seq[uint32]
    token*: seq[byte]
    schema*: SchemaCommitment
    expectSchema*: Opt[SchemaCommitment]

  HelloResponse* = object
    protocol*: uint32
    module*: string
    version*: seq[uint32]
    token*: seq[byte]
    schema*: SchemaCommitment
    expectSchema*: Opt[SchemaCommitment]

# ============================================================================
# TCP target parsing utilities
# ============================================================================

proc parseTcpTarget*(target: string): Result[(string, int), string] =
  let raw =
    if target.startsWith("tcp://"):
      target[6 ..^ 1]
    else:
      target
  let idx = raw.rfind(':')
  if idx == -1:
    return err("Invalid TCP target, expected host:port or tcp://host:port: " & target)

  var host = raw[0 .. idx - 1]
  let portStr = raw[idx + 1 ..^ 1]
  if host.len == 0 or portStr.len == 0:
    return err("Invalid TCP target, missing host or port: " & target)

  if host.startsWith("[") and host.endsWith("]"):
    host = host[1 ..^ 2]

  var port = 0
  try:
    port = parseInt(portStr)
  except ValueError:
    return err("Invalid TCP port: " & portStr)

  if port <= 0 or port > 65535:
    return err("TCP port out of range: " & $port)

  ok((host, port))

proc isTcpTarget*(target: string): bool =
  if target.startsWith("tcp://"):
    return true
  let idx = target.rfind(':')
  if idx == -1:
    return false
  let portStr = target[idx + 1 ..^ 1]
  if portStr.len == 0:
    return false
  for ch in portStr:
    if not ch.isDigit:
      return false
  true

proc versionString*(version: seq[uint32]): string =
  if version.len == 0:
    return ""
  result = $version[0]
  for i in 1 ..< version.len:
    result.add("." & $version[i])

proc requestSchema*(client: Socket): Result[string, string] =
  let request = TransportRequest(callId: 0, methodName: "logos.schema", params: @[])
  # We don't have encode/decode here — the host uses its own serialization
  # This is a stub; the actual implementation is in tcp_host.nim
  discard
