# src/logos_core/tcp_protocols.nim

import ./cbor_stuff, ./transport
import results, stew/endians2
import std/[net, os, strutils, sequtils]

const defaultTcpProtocol* = 1'u32

type
  HelloRequest* = object
    protocol*: uint32
    module*: string
    version*: seq[uint32]
    token*: seq[byte]

  HelloResponse* = object
    protocol*: uint32
    module*: string
    version*: seq[uint32]
    token*: seq[byte]

  RequestPayload* = object
    meth*: string
    params*: seq[byte]

  ResponsePayload* = object
    result*: seq[byte]
    error*: string

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
  let request = RequestPayload(meth: "logos.schema", params: @[])
  let reqMsg = TransportMessage(tag: tRequest, payload: Cbor.encode(request))
  discard sendTransportMessage(client, reqMsg)

  let response = receiveTransportMessage(client)
  if response.isErr:
    return err(response.error)

  if response.get.tag != tResponse:
    return err("Unexpected transport response tag while fetching schema")

  let payload = response.get.payload
  var resp: ResponsePayload
  try:
    resp = Cbor.decode(payload, ResponsePayload)
  except:
    return err("Invalid CBOR response payload for schema")

  if resp.error.len > 0:
    return err(resp.error)

  if resp.result.len == 0:
    return ok("")

  try:
    let schema = Cbor.decode(resp.result, string)
    return ok(schema)
  except:
    return ok("")
