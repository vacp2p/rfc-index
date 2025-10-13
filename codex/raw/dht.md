---
title: CODEX-DHT
name: Codex DHT
status: raw
tags: 
editor: 
contributors:
---

## Abstract

This document explians the Codex DHT (Data Hash Table) component.
It is used to store Codex's signed-peer-record (SPR) entries,
as well as content identifiers (CID) for each host.

## Background

Codex is a network of peer nodes, identified as providers or hosts,
particapting in a decentralized peer-to-peer storage protocol.
Codex offers data durability guarantees, incentive mechanisms and data persistenace guarantees.

The Codex DHT component is a modified version of [DiscV5 DHT](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md) protocol.
DiscV5 is a node discovery system used to find peers who are registered on a distributed hash table.
This allows a provider to publish their connection information and
information about what content they are storing.
A Codex provider will support this protocol at no extra cost other than using resources to store node records.
This allows any node to become the entry point to connect to the current live nodes on the Codex netowork.

## Wire Format

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

A `provider` is a peer node participanting in the Codex network.
All key values in the following structure are REQUIRED from the `provider`.

``` js

{
   "Provider" : {
        id: NodeId
        pubkey: PublicKey
        address: Array[peerId]
        record: SignedPeerRecord
        seen: float // Indicates if there was at least one successful
        // request-response with this provider, or if the node was verified
        // through the underlying transport mechanisms. After first contact
        // it tracks how reliable is the communication with the provider.
        stats: Stats # traffic measurements and statistics
    }
  
    "SignedPeerRecord" : {
      "seqNum": uint64, // sequence number of record update
      "pubkkey": PublicKey,
      "ip": IpAddress, // ip address is optionaloptional
      "tcpPort": Port,
      "udpPort": Port
    }

}

```

- `NodeId = keccak256(pubKey)`

The `NodeId` is used in the discv5 protocol to identitfy other `provider`s in the network.
When contructing the `NodeId`,
the `provider` MUST use a Keccak256 hash of it's `pubkey`
or a content identitfier, `CID`.
The `peerId` SHOULD also be derived from the same `pubkey`.

### Signed Peer Record

Each `provider` MUST be represented by a `record`,
which is contains their connection information.
On the Codex network, 
the `record` is considerd a `SignedPeerRecord`, SPR.
This the structure of a SPR is shared from the ENR, Ethereum Node Record, specification definition.
The structure consist of:

All key values, exculing the `ip`, is REQUORED.
A `provider` in the network MUST store the `SignedPeerRecord` belonging to a set of `provider`s in the network.
This will help finding content stored on nodes with the DHT.
Which nodes and the amount of nodes in this set is described in the {routing table](#routingtable) section.
The private key MUST be used to sign the `record`.
If the `record` is unsigned, a `provider` MUST disregard messages from that node.
The `provider` SHOULD contact other nodes in the network to disseinate new and updated records.
Using the 

### Retrieve Records

- nodes in the network to perform queries
- it SHOULD update their `record`, increase the sequence number and
sign a new version of the `record` whenever their information changes
- discard stale records as defined by configuration

### Distance calculation

#### Routing table

``` js

   "RoutingTable" : {
       "localProvider": Provider,
       "buckets": seq[KBucket],
       "bitsPerHop": number, 
       "ipLimits": IpLimits, // IP limits for total routing table: all buckets and
       // replacement caches.
       "distanceCalculator" : DistanceCalculator,
       "rng" : ref HmacDrbgContext
   }
   "KBucket" : {
       "istart", "iend": NodeId, 
       "providers": seq[Provider],
       "replacementCache": seq[Providers], // Nodes that could not be added to the `providers`
       // seq as it is full and without stale nodes. This is practically a small
       // LRU cache.
       "ipLimits": IpLimits, ## IP limits for bucket: node entries and replacement
       // cache entries combined.
   }
   "IpLimits" : {
      "tableIpLimit": number,
      "bucketIpLimit": number
   }


```

The `bitsPerHop` SHOULD indicate the minimum number of bits a `provider` will get closer to finding the target per query.
Practically, it tells you also how often your "not in range" branch will split off.
Setting this value to 1 is the basic, non accelerated version,
which will never split off the not in range branch and which will result in $ \log_2 n $ hops per lookup.
Setting it higher will increase the amount of splitting on a not in range branch 
thus holding more `providers` with a better keyspace coverage and
will result in an improvement of $ \log_{2^b} n $ hops per lookup.

- The `DistanceCalculator` value MUST be generated with
- istart: Range of NodeIds this KBucket covers. This is not a
simple logarithmic distance as buckets can be split over a prefix that
does not cover the `localNode` id.

- providers: Node entries of the KBucket are sorted according to last time seen.
First entry (head) is considered the most recently seen node and
the last entry (tail) is considered the least recently seen node.
Here "seen" indicates a successful request-response.
This can also not have occured yet.

- IpLimits: The routing table IP limits are applied on both the total table,
and on the individual buckets.
In each case, the active node entries,
but also the entries waiting in the replacement cache are accounted for.
This way, the replacement cache can't get filled with nodes that then can't be added due to the limits that apply.
As entries are not verified immediately before or on entry,
it is possible that a malicious node could fill the routing table or
a specific bucket with SPRs with IPs it does not control.
The effect of this would be that a node that actually owns the
IP could have a difficult time getting its SPR distrubuted in the DHT.
As a consequence would not be reached from the outside as much or at all.
However, that `provider` can still search and find nodes to connect to.

There is the possiblity to set the IP limit on verified `providers` only,
but that would allow for lookups to be done on a higher set of nodes owned by the same identity.
This is a worse alternative.
Doing lookups only on verified nodes would slow down discovery start up.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
