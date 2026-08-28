# MESSAGE-SEGMENTATION-AND-RECONSTRUCTION

| Field | Value |
| --- | --- |
| Name | Message Segmentation and Reconstruction |
| Slug | 243 |
| Version | 0.2 |
| Status | raw |
| Type | RFC |
| Category | application |
| Tags | segmentation |

## Abstract

This specification defines an application-layer wire format that carries a payload larger than the maximum message size of the underlying transport.
The payload is split into data segments that can be reconstructed by the receiver even when segments arrive out of order. The data segments can optionally be extended with Reed–Solomon parity ones, in which case, recovery can also happen if the lost segments are under a certain threshold.

## Terminology

- **original payload**: the full application payload before segmentation.
- **data segment**: one chunk of the original payload.
- **parity segment**: an erasure-coded segment derived from the set of data segments.
- **segment message**: a [`SegmentMessage`](#wire-format) carrying either data or parity segment.
- **segmentSize**: maximum size in bytes of a serialized segment message, see [Configuration](#configuration).

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Interoperability

The wire format and the Keccak256 hash below are fixed by this specification,
so participants that agree on `maxDataSegments` can exchange segmented payloads.
That is the only configured value one participant enforces against another,
and it is chosen per application rather than fixed here, see [Configuration](#configuration).

Interoperability across applications is not a goal of this specification.

## Wire Format

```protobuf
syntax = "proto3";

message SegmentMessage {
  bytes  entire_message_hash  = 1;
  uint32 index                = 2;
  uint32 segment_count        = 3;
  bool   is_parity            = 4;
  bytes  payload              = 5;
  uint32 payload_length       = 6;
}
```

| Field | Presence | Description |
| --- | --- | --- |
| `entire_message_hash` | REQUIRED | `Keccak256(original payload)`, exactly 32 bytes. Identifies the set of segments that reconstruct one payload. |
| `index` | REQUIRED | Zero-based position of this segment within its own class: among the data segments when `is_parity` is `false`; among the parity segments when `is_parity` is `true`. |
| `segment_count` | REQUIRED | Number of segments in this segment's own class: the count of data segments when `is_parity` is `false`; the count of parity segments when `is_parity` is `true`. |
| `is_parity` | OPTIONAL, defaults to `false` | `true` for a parity segment, `false` for a data segment. |
| `payload` | REQUIRED | The data chunk or the parity shard. |
| `payload_length` | REQUIRED | Length in bytes of the original payload, before segmentation. |

`is_parity` gives `index` and `segment_count` their meaning: both are read within the class the flag selects.
Every segment of a set carries the same `segment_count` as the other segments of its class,
and the same `payload_length` as every other segment of the set.
`payload_length` is repeated on every segment because any segment may be one of those lost,
and reconstruction needs the length whichever subset survives.

### Segment Message Validity

A segment message is valid only if all of the following hold:

- `entire_message_hash` is exactly 32 bytes.
- `segment_count >= 1`.
- `segment_count <= maxDataSegments`, the receiver's configured limit.
- `index < segment_count`.

An invalid segment message MUST be discarded.

A segment message with `segment_count == 1`, `index == 0` and `is_parity == false` is valid:
its `payload` is the entire original payload.

### Segment Set Validity

Two valid segment messages belong to the same **segment set** only if they carry equal `entire_message_hash`
and equal `payload_length`, and equal `segment_count` whenever they carry equal `is_parity`.

Within a segment set, `(is_parity, index)` MUST be unique.
A segment message whose `(is_parity, index)` is already held MUST be ignored.

### Reconstructed Payload Validity

A segment set can be reconstructed once it holds as many segment messages as the set has data segments.
The reconstructed payload is obtained as follows:

- If every data segment is held,
  it is the concatenation of their `payload` fields in ascending `index` order.
- Otherwise, it is the result of Reed–Solomon decoding over the held data and parity segments,
  as defined in [Reed–Solomon Coding](#reedsolomon-coding).

The assembled bytes are then truncated to `payload_length`.
This step is unconditional, and is what discards the zero padding that Reed–Solomon encoding may leave
on a data segment recovered by decoding.
Assembled bytes shorter than `payload_length` mean the set is incomplete and MUST NOT be truncated or delivered.

The reconstructed payload is valid only if `Keccak256(reconstructed payload)` equals the `entire_message_hash` of the segment set.
An invalid reconstructed payload MUST be discarded and the failure SHOULD be logged.
Only a valid reconstructed payload is delivered to the application.

## Segmentation

To transmit an original payload, the sender:

- MUST compute `entire_message_hash = Keccak256(original payload)`.
- MUST split the payload into one or more data segments,
  choosing the chunk size so that every resulting serialized `SegmentMessage` is at most `segmentSize` bytes.
- MAY generate parity segments at `parityRate` as defined in [Reed–Solomon Coding](#reedsolomon-coding).
- MUST encode every segment as a `SegmentMessage` that satisfies [Segment Message Validity](#segment-message-validity),
  with `segment_count` set to the number of segments in that segment's own class,
  and `payload_length` set to the length of the original payload.
- MUST send each segment message as an individual transport message.

Segments MAY be sent in any order.

## Reed–Solomon Coding

A sender that uses parity applies [Reed–Solomon erasure coding](https://github.com/catid/leopard)
over its data segments to produce a further `ceil(parityRate * number of data segments)` parity segments.
Parity MUST remain the minority class, which follows from `parityRate < 1`:
reconstruction takes as many segments as the set has data segments,
so a set reaches that number only by holding at least one data segment, and with it the count.

Reed–Solomon operates on equal-length inputs, called **shards**.
The **shard length** is the chunk size the payload was split into,
that is the length of the data segment at `index == 0`.
Only the last data segment may be shorter, and the encoder zero-pads it to shard length.
That padding never reaches the wire:
data segments are sent at their true length,
so a parity segment is the only one guaranteed to be exactly shard-length,
and a decoding receiver always holds one, since a complete set needs no decoding.

A set that carries parity is reconstructible from any subset of its segments as large as its number of data segments:
the receiver reads the shard length off a parity segment, re-pads the data segments it holds, and decodes the rest.
Receivers MUST support Reed–Solomon decoding, since any sender MAY use parity.

A final data segment recovered by decoding comes back zero-padded to shard length rather than at its true length.
Truncating the assembled bytes to `payload_length` discards that padding,
which is why [Reconstructed Payload Validity](#reconstructed-payload-validity) applies it to every reconstruction.

## Implementation Suggestions

### When to Use Parity

Parity costs `parityRate` extra bandwidth on *every* message, whether or not anything is lost.
It pays off only where losses are independent and a retransmission would cost more than that constant overhead.
[RFC 3453](https://www.rfc-editor.org/rfc/rfc3453) covers the general trade-off.

One case is specific to this stack.
Where an end-to-end reliability layer already retransmits missing segments,
as in [RELIABLE-CHANNEL-API](reliable-channel-api.md) with SDS,
parity repairs the same loss a second time; set `parityRate = 0` there.

### Segment Caching

Received segments accumulate until their set is reconstructible, so an unbounded cache is a memory leak driven by remote senders.
Implementations SHOULD:

- Index the cache by `entire_message_hash`, and additionally by sender where the transport authenticates one.
  Authenticating the sender is out of scope of this specification.
- Bound both the number of concurrent reconstructions and the total buffered bytes,
  per sender as well as globally where a sender identity is available.
  A fixed-size ring of reconstruction slots gives a hard worst-case bound of `slots * 2 * maxDataSegments * segmentSize` bytes.

Segments MAY be persisted, for example in SQLite, so that partial reconstructions survive a restart.
In-memory buffering is sufficient otherwise.

### Configuration

- `segmentSize`: maximum size in bytes of a serialized segment message.
  Chosen by the application so that a segment fits the transport's maximum message size.
- `parityRate`: number of parity segments relative to the number of data segments.
  MUST be less than `1`, see [Reed–Solomon Coding](#reedsolomon-coding).
  Defaults to `0`, which disables parity.
  `0.125` is RECOMMENDED where the [guidance above](#when-to-use-parity) favours parity.
- `maxDataSegments`: maximum number of data segments a receiver accepts.
  Parity needs no separate limit, being the smaller class.
  **256** is RECOMMENDED, capping an original payload near `256 * segmentSize`, about 38 MB over a 150 KB transport.
  An application needing more MAY raise it, up to the shard limit of its Reed–Solomon implementation.
  All participants in an application MUST use the same value, see [Interoperability](#interoperability).

[RELIABLE-CHANNEL-API](reliable-channel-api.md) surfaces these as `SegmentationConfig`,
where `segmentSizeBytes` is this `segmentSize`
and `enableReedSolomon` selects between `parityRate = 0` and a non-zero rate.
It applies segmentation before SDS and encryption,
so `segmentSizeBytes` MUST leave room for the SDS and encryption overhead added to each segment before it reaches the transport.
Its `persistence` backend is the storage referred to in [Segment Caching](#segment-caching).

## Security Considerations

### Privacy

`entire_message_hash` links the segments of one payload to each other, but does not reveal the payload.
Applications SHOULD encrypt each serialized `SegmentMessage` before transmission,
which hides both the hash and the segment counts from observers.
Traffic analysis may still identify a segmented flow by its timing and volume.

### Integrity

This specification provides no confidentiality and no sender authentication.
The `entire_message_hash` check on the reconstructed payload detects accidental corruption and mismatched segments,
but an attacker able to inject transport messages can compute a consistent hash over a payload of their own.
Applications requiring authenticity MUST obtain it from another layer.

### Denial of Service

A remote sender controls how much memory a receiver buffers, so implementations MUST bound it.
The limits and timeouts in [Segment Caching](#segment-caching) are the mitigation.
Rate limiting at the transport, for example [17/WAKU2-RLN-RELAY](../../core/draft/17/rln-relay.md) on Waku,
additionally bounds how fast an attacker can create pending reconstructions.

## References

1. [64/WAKU2-NETWORK](../../core/draft/64/network.md#message-size)
2. [17/WAKU2-RLN-RELAY](../../core/draft/17/rln-relay.md)
3. [RELIABLE-CHANNEL-API](reliable-channel-api.md)
4. [nim-leopard](https://github.com/status-im/nim-leopard) – Nim bindings for Leopard-RS
5. [Leopard-RS](https://github.com/catid/leopard) – Fast Reed–Solomon erasure coding library
6. [RFC 3453](https://www.rfc-editor.org/rfc/rfc3453) – The Use of Forward Error Correction (FEC) in Reliable Multicast
7. [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) – Key words for use in RFCs to Indicate Requirement Levels

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
