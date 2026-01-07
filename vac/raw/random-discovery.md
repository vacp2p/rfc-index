---
title: random-discovery
name: Random Discovery
status: raw
category: Standards Track
tags:
editor: Simon-Pierre Vivier <simvivier@status.im>
contributors: 
---

## Abstract

TODO blabla summarizing what's in here

## Motivation

TOOD blabla on why we need this

## Semantic

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

Please refer to [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md) and [extended peer records specification](TODO) for terminology used in this document.

## Protocol

### Record Propagation

A node that wants to make itself discoverable,
also known as an _advertiser_,
MUST encode its discoverable information in an [Extensible Peer Record]().
The encoded information MUST be sufficient for discoverers to connect to this advertiser.
It MAY choose to encode some or all of its capabilities (and related information)
as `services` in the `ExtensiblePeerRecord`.
This will allow future discoverers to filter discovered records based on desired capabilities.

In order to advertise this record,
the advertiser SHOULD first retrieve the `k` closest peers to its own peer ID
in its own [Kademlia routing table](https://github.com/libp2p/specs/blob/e87cb1c32a666c2229d3b9bb8f9ce1d9cfdaa8a9/kad-dht/README.md#kademlia-routing-table).
This assumes that the routing table has been previously initialised
and follows the regular [bootstrap process](https://github.com/libp2p/specs/blob/e87cb1c32a666c2229d3b9bb8f9ce1d9cfdaa8a9/kad-dht/README.md#bootstrap-process) as per the libp2p Kad-DHT specification.
The advertiser SHOULD then perform a [Kad-DHT `PUT_VALUE`](https://github.com/libp2p/specs/blob/e87cb1c32a666c2229d3b9bb8f9ce1d9cfdaa8a9/kad-dht/README.md#value-storage-and-retrieval) to these `k` peers
to store the `ExtensiblePeerRecord` against its own peer ID.
This process SHOULD be repeated periodically to maintain the advertised record.
We RECOMMEND an interval of once every `30` minutes,
for each discoverable `ExtensiblePeerRecord` the node wants to advertise.

### Record Discovery

A random discovery procedure (`FIND_RANDOM`) consist of the following steps;

1. A random value in the key space MUST be chosen (`R_KEY`).

2. A `GET_VALUE` message MUST be sent to the `k` closest nodes to `R_KEY`.

3. A `FIND_NODE` message MUST be sent to the `k` closest nodes to `R_KEY`.

4. For each peers in `closerPeers` from `FIND_NODE` responses, a `GET_VALUE` message MUST be sent but already seen peers MUST be ignored.

5. Repeat step 3 and 4 with new peers found via `FIND_NODE`.
`FIND_RANDOM` MAY terminate when the `k` closest peers to `R_KEY` are found.
The discoverer MAY choose to filter discovered `ExtensiblePeerRecords`
based on advertised `services`
to find peers matching a set of desired capabilities. 
> `GET_VALUE` messages MUST always contain the peer id of the recipiant as the `key`
and the `record` in the response MUST be verified, invalid records and `closerPeers` MUST be discarded. Valid records MAY be filtered for specific services.

### Attack Vectors

To make the system more resilient extended peer records could be stored randomly in the key space
but doing so would result in increased bandwidth requirements
because of the need to first find random nodes to store the records at.
When used in conjuction with [capability discovery](https://github.com/vacp2p/rfc-index/blob/main/vac/raw/logos-capability-discovery.md),
eclipse attacks effectiveness are greatly reduced
because a node can always be discovered via it's advertised services regardless of the random discoverability of it's records.
For this reason, we decided that this trade-off was worth it.


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
- [extended peer records specification](TODO)
- [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)
- [RFC002 Signed Envelope](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0002-signed-envelopes.md)
- [RFC003 Routing Records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md)
- [capability discovery](https://github.com/vacp2p/rfc-index/blob/main/vac/raw/logos-capability-discovery.md)