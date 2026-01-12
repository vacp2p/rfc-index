---
title: extended-kademlia-discovery
name: Extended Kademlia Discovery
status: raw
category: Standards Track
tags:
editor: Simon-Pierre Vivier <simvivier@status.im>
contributors: Hanno Cornelius <hanno@status.im>
---

## Abstract

TODO blabla summarizing what's in here

## Motivation

TOOD blabla on why we need this

## Semantic

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

Please refer to [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md) (`KAD-DHT`) and [extended peer records specification](https://github.com/vacp2p/rfc-index/blob/main/vac/raw/extensible-peer-records.md) (`XPR`) for terminology used in this document.

## Protocol

### Record Propagation

A node that wants to make itself discoverable,
also known as an _advertiser_,
MUST encode its discoverable information in an [`XPR`](https://github.com/vacp2p/rfc-index/blob/main/vac/raw/extensible-peer-records.md#extensible-peer-records).
The encoded information MUST be sufficient for discoverers to connect to this advertiser.
It MAY choose to encode some or all of its capabilities (and related information)
as `services` in the `XPR`.
This will allow future discoverers to filter discovered records based on desired capabilities.

In order to advertise this record,
the advertiser SHOULD first retrieve the `k` closest peers to its own peer ID
in its own `KAD-DHT` [routing table](https://github.com/libp2p/specs/blob/master/kad-dht/README.md#kademlia-routing-table).
This assumes that the routing table has been previously initialised
and follows the regular [bootstrap process](https://github.com/libp2p/specs/blob/master/kad-dht/README.md#bootstrap-process) as per the `KAD-DHT` specification.
The advertiser SHOULD then send a `PUT_VALUE` message to these `k` peers
to store the `XPR` against its own peer ID.
This process SHOULD be repeated periodically to maintain the advertised record.
We RECOMMEND an interval of once every `30` minutes.

### Record Discovery

A random walk discovery procedure (`FIND_RANDOM`) consist of the following steps;

1. A random value in the key space MUST be chosen (`R_KEY`).

2. Start the `KAD-DHT` [peer routing](https://github.com/libp2p/specs/blob/master/kad-dht/README.md#peer-routing) algorithm.

3. For each peers in `closerPeers` from `FIND_NODE` response messages, a `GET_VALUE` message MUST be sent but already seen peers MUST be ignored.

> `GET_VALUE` messages MUST always contain the peer id of the recipiant as the `key`
and the `record` in the response MUST be verified, invalid records and `closerPeers` MUST be discarded. Valid `XPR` in the records MAY be filtered to find peers matching a set of desired capabilities.

> `FIND_RANDOM` MAY terminate when `KAD-DHT` peer routing algorithm no longer returns new peers.

### Future Improvements

To make the system resilient to eclipse attacks, a node `XPR` are stored at the `k` closest nodes. Future version of this protocol could also retrieve `XPR` on more nodes than only the originator.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
- [extended peer records specification](TODO)
- [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)
- [RFC002 Signed Envelope](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0002-signed-envelopes.md)
- [RFC003 Routing Records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md)
- [capability discovery](https://github.com/vacp2p/rfc-index/blob/main/vac/raw/logos-capability-discovery.md)