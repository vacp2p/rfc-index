# src/logos_core/transport.nim

import ./iface, results
import std/[net, sequtils], stew/byteutils, stew/endians2

## Message tags as defined in LOGOS-module-transport.
type TransportTag* = enum
  tHello = 100
  tRequest = 101
  tResponse = 102
  tSubscribe = 103
  tUnsubscribe = 104
  tEvent = 105
  tProtocolError = 106
  tCancel = 107

## A simple wrapper for a length-prefixed message.
type TransportMessage* = object
  tag*: TransportTag
  payload*: seq[byte]

proc encodeMessage*(msg: TransportMessage): seq[byte] =
  ## Encodes a message with a 4-byte big-endian length prefix.
  # Append length (4 bytes, big-endian)
  result.add msg.payload.len.uint32.toBytesBE()

  # Append tag (1 byte)
  result.add(byte(msg.tag.ord))

  # Append payload
  result.add(msg.payload)

proc decodeMessage*(data: seq[byte]): Result[TransportMessage, string] =
  ## Decodes a length-prefixed message.
  if data.len < 5:
    return err("Message too short")

  # Read length (4.. bytes, big-endian)
  var length = uint32.fromBytesBE(data[0..3]).int

  if data.len < 4 + length:
    return err("Incomplete message")

  let tagByte = data[4]
  let tag = TransportTag(tagByte.int)

  let payload = data[5 .. 5 + length - 1]

  ok(TransportMessage(tag: tag, payload: payload))

proc readExact*(client: Socket, dest: var openArray[byte], size: int): Result[void, string] =
  ## Reads exactly `size` bytes from the socket.
  var read = 0
  while read < size:
    let chunk = client.recv(cast[cstring](addr dest[read]), size - read)
    if chunk <= 0:
      return err("Connection closed during read")
    read += chunk
  ok()

proc sendTransportMessage*(client: Socket, msg: TransportMessage): Result[void, string] =
  ## Sends a length-prefixed TransportMessage over the socket.
  let bytes = encodeMessage(msg)
  var written = 0
  while written < bytes.len:
    let chunk = client.send(cast[cstring](addr bytes[written]), bytes.len - written)
    if chunk <= 0:
      return err("Failed to send transport message")
    written += chunk
  ok()

proc receiveTransportMessage*(client: Socket): Result[TransportMessage, string] =
  ## Receives and decodes a length-prefixed TransportMessage from the socket.
  var header: array[4, byte]
  ?readExact(client, header, 4)

  let length = uint32.fromBytesBE(header).int
  if length < 1:
    return err("Invalid transport frame length")

  var body = newSeq[byte](length + 1)
  ?readExact(client, body, length + 1)

  var full = newSeq[byte](4 + length + 1)
  copyMem(addr full[0], addr header[0], 4)
  copyMem(addr full[4], addr body[0], length + 1)

  decodeMessage(full)
