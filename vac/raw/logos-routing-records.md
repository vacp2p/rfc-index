---
title: logos-routing-records
name: Logos Routing Records
status: raw
category: Standards Track
tags:
editor: Hanno Cornelius <hanno@status.im>
contributors: Simon-Pierre Vivier <simvivier@status.im>
---

## Abstract

This RFC proposes Logos Routing Records,
an extension of libp2p's routing records,
that enables peers to encode an arbitrary list of supported services and essential service-related information.
This version of routing records allows peers to communicate capabilities such as protocol support,
and essential information related to such capabilities.
This is especially useful when (signed) routing records are used in peer discovery,
allowing discoverers to filter for peers matching a desired set of capability criteria.
Logos Routing Records maintain backwards compatibility with standard libp2p routing records,
while adding an extensible service information field that supports finer-grained capability communication.

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Motivation

We propose a new routing record as an extension of libp2p's [RFC003 Routing Records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md)
that allows encoding an arbitrary list of services,
and essential information pertaining to those services,
supported by the peer.

There are at least two reasons why a peer might want to encode service information in its routing records:

1. **To augment `identify` with peer capabilities:**
The libp2p [`identify` protocol](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/identify/README.md) allows peers to exchange critical information,
such as supported protocols,
on first connection.
The routing record (in a signed envelope) can also be exchanged during `identify`.
However, peers may want to exchange finer-grained information related to supported protocols/services,
that would otherwise require an application-level negotiation protocol.
An example would be nodes supporting libp2p [`mix` protocol](https://rfc.vac.dev/vac/raw/mix) also needing to exchange the mix key
before the service can be used.
2. **To advertise supported services:**
If the routing record is used as the discoverable record for a peer
(as we propose for Logos discovery methods)
that peer may want to encode a list of supported services
in its advertised record.
These services may be (but is not limited to) a list of supported libp2p protocols
and critical information pertaining to that service (such as the mix key, explained above).
Discoverers can then filter discovered records for desired capabilities
based on the encoded service information
or use it to initiate the service.

## Wire protocol

### Logos Routing Records

Logos Routing Records MUST adhere to the following structure:

```protobuf
syntax = "proto3";

package logos.peer.pb;

// LogosPeerRecord messages contain information that is useful to share with other peers.
// Currently, a LogosPeerRecord contains the public listen addresses for a peer
// and an extensible list of supported services as key-value pairs.
//
// LogosPeerRecords are designed to be serialised to bytes and placed inside of
// SignedEnvelopes before sharing with other peers.
message LogosPeerRecord {

  // AddressInfo is a wrapper around a binary multiaddr. It is defined as a
  // separate message to allow us to add per-address metadata in the future.
  message AddressInfo {
    bytes multiaddr = 1;
  }

  // peer_id contains a libp2p peer id in its binary representation.
  bytes peer_id = 1;

  // seq contains a monotonically-increasing sequence counter to order LogosPeerRecords in time.
  uint64 seq = 2;

  // addresses is a list of public listen addresses for the peer.
  repeated AddressInfo addresses = 3;

  message ServiceInfo{
    string id = 1;
    optional bytes data = 2;
  }

   // Extensible list of advertised services
  repeated ServiceInfo services = 4;
}
```

A peer MAY include a list of supported services in the `services` field.
These services could be libp2p protocols,
in which case it is RECOMMENDED that the libp2p protocol identifier be used as the `ServiceInfo` `id` field.
In any case, for each supported service,
the `id` field MUST be populated with a string identifier for that service.
In addition, the `data` field MAY be populated with additional information about the service.
It is RECOMMENDED that each `data` field be no more than `33` bytes.
(We choose `33` here to allow for the encoding of `256` bit keys with parity.
Also see [_Size constraints_](#size-constraints) for recommendations on limiting the overall record size.)

The rest of the `LogosPeerRecord`
MUST be populated as per the libp2p [`PeerRecord` specification](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md).
Due to the natural extensibility of protocol buffers,
serialised `LogosPeerRecord`s are backwards compatible with libp2p `PeerRecord`s,
only adding the functionality related to service info exchange.

#### Size constraints

To limit the impact on resources,
`LogosPeerRecord`s SHOULD NOT be used to encode information
that is not essential for discovery or service initiation.
Since these records are likely to be exchanged frequently,
they should be kept as small as possible while still providing all necessary functionality.
Although specific applications MAY choose to enforce a smaller size,
it is RECOMMENDED that an absolute maximum size of `1024` bytes is enforced for valid records.
Logos Routing Records may be included in size-constrained protocols
that further limit the size (such as DNS).

### Wrapping in Signed Peer Envelopes

Logos Routing Records MUST be wrapped in libp2p [signed envelope](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0002-signed-envelopes.md)s
before distributing them to peers.
The corresponding `LogosPeerRecord` message is serialised into the signed envelope's `payload` field.

#### Signed Envelope Domain

Logos Routing Records MUST use `libp2p-routing-state` as domain separator string
for the envelope signature.
This is the same as for ordinary libp2p [routing records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md#signed-envelope-domain).

#### Signed Envelope Payload Type

Logos Routing Records MUST use the UTF8 string `/libp2p/logos-routing-record/`
as the `payload_type` value.

> **_Note:_** this will make Logos Routing Records a subtype of the "namespace" [multicodec](https://github.com/multiformats/multicodec/blob/0c6c7d75f1580af329847dbc9900859a445ed980/table.csv).
In future we may define a more compact multicodec type for Logos Routing Records. 

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [libp2p `identify`](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/identify/README.md)
- [libp2p mix](https://rfc.vac.dev/vac/raw/mix)
- [multicodec](https://github.com/multiformats/multicodec/blob/0c6c7d75f1580af329847dbc9900859a445ed980/table.csv)
- [RFC002 Signed Envelope](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0002-signed-envelopes.md)
- [RFC003 Routing Records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md)
