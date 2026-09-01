# MESSAGE-SEGMENTATION-AND-RECONSTRUCTION

| Field | Value |
| --- | --- |
| Name | Message Segmentation and Reconstruction |
| Slug | 243 |
| Version | 0.1 |
| Status | raw |
| Type | RFC |
| Category | application |
| Tags | segmentation |

## Abstract

This specification defines an application-layer wire format that carries a payload larger than the maximum message size of the underlying transport.
The payload is split into data segments that can be reconstructed by the receiver even when segments arrive out of order. The data segments can optionally be extended with Reed–Solomon parity ones, in which case, recovery can also happen if the lost segments are under a certain threshold.

## Motivation

Many message transport and delivery protocols impose a maximum message size that restricts the size of application payloads.
For example, Waku Relay typically propagates messages up to 150 KiB as per [64/WAKU2-NETWORK - Message](../../core/draft/64/network.md#message-size).
To support larger application payloads, a segmentation layer is required.
This specification enables larger messages by partitioning them into multiple envelopes and reconstructing them at the receiver.
Erasure-coded parity segments provide resilience against partial loss or reordering.

## Terminology

- **original payload**: the full application payload before segmentation.
- **data segment**: one chunk of the original payload.
- **parity segment**: an erasure-coded segment derived from the set of data segments.
- **class**: each one of the two possible segment types: data or parity.
- **segment message**: a [`SegmentMessage`](#wire-format) carrying either data or parity segment.
- **segmentSizeBytes**: maximum size of a serialized segment message, see [Configuration](#configuration).

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "NOT RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Wire Format

```protobuf
syntax = "proto3";

message SegmentMessage {
  bytes  entire_message_hash   = 1;  // Keccak256 of the original payload, 32 bytes
  uint32 entire_message_length = 2;  // length in bytes of the original payload
  uint32 index                 = 3;  // position within this segment's own class (data or parity)
  uint32 segment_count         = 4;  // number of items of the given class (data or parity)
  bool   is_parity             = 5;  // selects the class the two fields above refer to
  bytes  payload               = 6;  // data chunk or parity shard
}
```

### Validity

A **segment message** is valid only if all of the following hold:
- `entire_message_hash` is exactly 32 bytes.
- `1 <= segment_count <= maxTotalSegments` (receiver's configured limit.)
- `index < segment_count`.

An invalid segment message MUST be discarded.
A payload that fits one segment is valid if `segment_count == 1`, `index == 0`, `is_parity == false`.

A later revision of this specification MAY add fields.
A receiver MUST ignore any field it does not recognise rather than treat the segment message as invalid,
and a field number that is withdrawn MUST be `reserved` and MUST NOT be reused for another meaning.

## Reed–Solomon Coding

A sender that uses parity applies [Reed–Solomon erasure coding](https://github.com/catid/leopard)
over its data segments to produce `ceil(parityRate * number of data segments)` more,
or one fewer than the data segments where that is smaller, so a single data segment gets none.
Parity MUST remain the minority class, fewer parity segments than data ones,
so a receiver always learns the data-segment count before it can reconstruct.

Reed–Solomon operates on equal-length inputs, called shards.
The shard length is the chunk size the payload was split into,
so only the last data segment may be shorter, and the encoder zero-pads it.
That padding never reaches the wire, data segments being sent at their true length,
which leaves parity segments as the only ones always exactly shard-length.

Reed–Solomon recovers the data segments from any combination of segments as large as the data-segment count.
Decoding needs every shard at shard length, but the last data segment may travel shorter than that.
A receiver takes the shard length from a parity segment, those being always exactly that long,
re-pads its data segments to it, and decodes.
It always holds a parity segment when decoding, a missing data segment being what parity made up for.

Receivers SHOULD support Reed–Solomon decoding, and MUST where the application sets `parityRate > 0`;
without it a set reconstructs only once every data segment has arrived.

## Segmentation

To transmit an original payload, the sender:

- MUST compute `entire_message_hash = Keccak256(original payload)`.
- MUST split the payload into one or more data segments, at a chunk size such that every segment
  it sends, data and parity alike, serializes to at most `segmentSizeBytes`.
- MAY generate parity segments at `parityRate` as defined in [Reed–Solomon Coding](#reedsolomon-coding).
- MUST encode every segment as a `SegmentMessage` that satisfies [Validity](#validity).
- MUST send each segment message as an individual transport message; the order is unconstrained.

## Reconstruction

A receiver retains every valid segment message.

Two valid segment messages belong to the same **segment set** only if all of the following hold:
- they carry equal `entire_message_hash`.
- they carry equal `entire_message_length`.
- they carry equal `segment_count`, whenever their `is_parity` is equal.

Within a set, `(is_parity, index)` MUST be unique; a segment message repeating one already held MUST be ignored.

Until a set holds segments of both classes, the per-message `segment_count` bound is all a receiver can apply.
Once it holds one of each, it knows both counts, and MUST drop the whole set
where they sum above `maxTotalSegments`: no conforming sender produces such a set.

A set's `data_segment_count` is the `segment_count` of any segment message with `is_parity == false`.
- A set reaching that count in data segments alone reconstructs by [concatenation](#all-data-segments-are-received-successfully).
- A set reaching that count in data plus parity segments together reconstructs [through parity](#recovery-through-parity).
- Else, [expires](#expiry) after a configured timeout.

### All data segments are received successfully

The receiver produces the original payload following these steps:

1. Concatenate the data segments' `payload` fields in ascending `index` order.
2. Truncate to `entire_message_length`, which discards any zero padding left by Reed–Solomon encoding.
   Fewer assembled bytes than that mean the set is incomplete and MUST NOT be delivered to the application.
3. Verify that `Keccak256` of the result equals the set's `entire_message_hash`.

An invalid payload MUST be discarded; only a valid one is delivered to the application.
Any parity segments the set holds are unused, and the set MAY be released once the payload is delivered.

### Recovery through parity

Where a data segment is missing, parity segments stand in for it:
the set reconstructs once the number of segment messages it holds, data and parity alike,
reaches the `data_segment_count`.
The receiver [Reed–Solomon decodes](#reedsolomon-coding) the missing data segments from the ones it holds,
then proceeds as [above](#all-data-segments-are-received-successfully) from step 1.

### Expiry

The receiver MUST NOT wait indefinitely for all the required segments to arrive.
It MUST drop a set that has received no further segments
within a reconstruction timeout without delivering anything to the application.

A later segment message of a dropped set starts a new set, which reconstructs only if enough of the
original set's segments are retransmitted.

The timeout and the other bounds a receiver places on pending sets are covered in [Segment Caching](#segment-caching).

## Configuration

- `segmentSizeBytes`: chosen by the application so that a segment fits the transport's maximum message size.
- `parityRate`: number of parity segments relative to the number of data segments.
  MUST be less than `1`, and the count it yields is capped so that parity stays the minority class,
  see [Reed–Solomon Coding](#reedsolomon-coding).
  Defaults to `0`, which disables parity.
  `0.125` is RECOMMENDED where the [guidance below](#example-configurations) favours parity.
- `reconstructionTimeoutSeconds`: how long a segment set may go without a new segment message before the receiver
  drops it, see [Expiry](#expiry).
- `maxTotalSegments`: greatest number of segments a set may hold, data and parity together.
  Bounds how much memory one sender can make a receiver buffer, see [Segment Caching](#segment-caching).
  **256** is RECOMMENDED.
  An application MAY raise it where its receivers can absorb the larger buffer
  and its Reed–Solomon implementation has the shards for it,
  see [Example Configurations](#example-configurations).
  All participants in an application MUST use the same value,
  so participants interoperate within an application and not across applications.

## Implementation Suggestions

### Example Configurations

What each `parityRate` buys, for a payload split into 128 data segments:

| `parityRate` | Parity segments | Segments lost and still recovered | Bandwidth added | When to choose it |
| --- | --- | --- | --- | --- |
| `0` | 0 | none | none | Default. A reliability layer above already retransmits, or loss is rare |
| `0.0625` | 8 | up to 8 of 136 | 6% | Occasional independent loss, bandwidth tight |
| `0.125` | 16 | up to 16 of 144 | 13% | RECOMMENDED where loss is independent and retransmission costs more |
| `0.25` | 32 | up to 32 of 160 | 25% | Lossy links, or a slow retransmission path |
| `0.5` | 64 | up to 64 of 192 | 50% | No retransmission path at all, loss expected |

Recovery survives losing any segments up to the parity count, data or parity alike.
Every row fits any Reed–Solomon implementation.
[RFC 3453](https://www.rfc-editor.org/rfc/rfc3453) covers the general trade-off behind these choices.

`ceil` also rounds small sets up sharply: at `parityRate = 0.125` two data segments still get one parity segment,
a 50% overhead to tolerate a single loss.

How far `maxTotalSegments` can go, at `parityRate = 0.125` and `segmentSizeBytes` of 128 KiB:

| `maxTotalSegments` | Data segments | Parity segments | Needs a Reed–Solomon implementation over | Carries a payload up to |
| --- | --- | --- | --- | --- |
| 256 | 227 | 29 | GF(2^8), 256 shards | 28 MiB |
| 512 | 455 | 57 | GF(2^16), 65536 shards | 56 MiB |
| 1024 | 910 | 114 | GF(2^16), 65536 shards | 113 MiB |

Parity shares the budget with data, so a higher `parityRate` leaves room for a smaller payload.
The default 256 is the ceiling of the smaller field, so an implementation counting shards flatly
encodes any conforming set.

Leopard-style coders round parity up to a power of two and data up to a multiple of it,
so 227 data with 29 parity occupies 288 shards rather than 256.
Leopard-RS carries that in GF(2^16); a coder confined to GF(2^8) cannot, and needs a lower `maxTotalSegments`.

### Segment Caching

Received segments accumulate until their set is reconstructible. Implementations typically:

- Index the cache by `entire_message_hash`, and additionally by sender where the transport authenticates one.
  Authenticating the sender is out of scope of this specification.
- Bound both the number of segment sets held and the total buffered bytes,
  per sender as well as globally where a sender identity is available.
  Capping the sets bounds the bytes at that cap times
  `maxTotalSegments * segmentSizeBytes`, one segment more while a set awaits its second class.
- Evict the least recently updated set first,
  in addition to the `reconstructionTimeoutSeconds` expiry every receiver applies.

Segments can be persisted, for example in SQLite, so that partial reconstructions survive a restart.
In-memory buffering is sufficient otherwise.

## Security/Privacy Considerations

### Privacy

`entire_message_hash` links the segments of one payload to each other, but does not reveal the payload.
This specification does not enforce encryption, but applications SHOULD encrypt each serialized
`SegmentMessage` before transmission, which hides the hash and the segment counts from observers
and denies an attacker the hash it would need to [poison a set](#integrity).
Traffic analysis may still identify a segmented flow by its timing and volume.

### Integrity

This specification provides no sender authentication.
The `entire_message_hash` check on the reconstructed payload detects accidental corruption and mismatched segments,
but an attacker able to inject transport messages can compute a consistent hash over a payload of their own.
Such an attacker can also deny reconstruction outright: injecting a segment message that occupies an
`(is_parity, index)` of a set already in flight makes the receiver ignore the genuine one, so the set fails
its hash check and never reconstructs until it [expires](#expiry).
Encrypting each segment message, as [Privacy](#privacy) recommends, keeps `entire_message_hash` out of an
observer's reach and so out of reach of this attack.
Applications requiring authenticity MUST obtain it from another layer.

### Denial of Service

A remote sender controls how much memory a receiver buffers, so implementations MUST bound it.
The limits and timeouts in [Segment Caching](#segment-caching) are the mitigation.
Rate limiting at the transport, for example [17/WAKU2-RLN-RELAY](../../core/draft/17/rln-relay.md) on Waku,
additionally bounds how fast an attacker can create pending reconstructions.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [64/WAKU2-NETWORK](../../core/draft/64/network.md#message-size)
2. [17/WAKU2-RLN-RELAY](../../core/draft/17/rln-relay.md)
3. [nim-leopard](https://github.com/status-im/nim-leopard) – Nim bindings for Leopard-RS
4. [Leopard-RS](https://github.com/catid/leopard) – Fast Reed–Solomon erasure coding library
5. [klauspost/reedsolomon](https://github.com/klauspost/reedsolomon) – Reed–Solomon coding over GF(2^8) and GF(2^16)
6. [RFC 3453](https://www.rfc-editor.org/rfc/rfc3453) – The Use of Forward Error Correction (FEC) in Reliable Multicast
7. [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) – Key words for use in RFCs to Indicate Requirement Levels
