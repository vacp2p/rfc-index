---
title: LOGOS-DISCOVERY-CAPABILITY
name: A secure discovery mechanism with multi-service support
status: raw
category: Standards Track
tags:
editor:
contributors:

---

## Abstract

This RFC defines the Logos discovery capability,
a DISC-NG-inspired discovery mechanism
built on top of [Kad-dht](https://github.com/libp2p/specs/tree/master/kad-dht).
It enables nodes to advertise their participation in specific services
and allows other nodes to efficiently discover peers participating in those services.

The protocol adds service-specific advertisement placement and retrieval mechanisms
on top of the base Kad-dht functionality.
For everything else that isn't explicitly stated herein,
it is safe to assume behaviour similar to Kad-dht.
The terms “peer” and “node” are used interchangeably throughout this document
and refer to the same entity — a participant in the Logos Discovery network.

While Kad-dht provides scalable content routing, it is limited in resilience.
Logos discovery extends Kad-dht toward a multi-service, resilient discovery layer,
enhancing reliability while maintaining compatibility with existing Kad-dht behavior.

## Motivation

In decentralized networks supporting multiple services,
efficient peer discovery is critical.
Traditional approaches face several challenges:

1. Random walk is Inefficient for unpopular services.
2. Direct DHT lookups to closest nodes create hotspots at popular services
and are vulnerable to Sybil and Eclipse attacks.
3. Discovery must scale logarithmically across many distinct services.

Through service-specific tables, adaptive advertisement placement,
admission control, and improved lookup operation,
Logos discovery aims to balance efficiency, scalability,
and resilience across multiple services.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Definitions

### DHT Routing Table

The `KadDHT(node.id)` table is the kad-dht routing table every node maintains.
It is centered on `node.id`.
It is built and maintained in the same way as in the base Kad-dht.

### Service

A service is a logical sub-network within the larger peer-to-peer network.
Services are identified by a unique service identifier string like `waku.store, libp2p.mix, etc.`

### Service ID

### Service ID

The service ID **`s`** is the SHA-256 hash of the service identifier string.

For example:

| Service Identifier | Service ID (hex, truncated) |
| --- | --- |
| `waku.store` | `a4b6f3d1c7e2d8f4c9b9e6d1f3a1c2e9...` |
| `libp2p.mix` | `5e71b18a9d7c3c20f92a15b54a7d4c3e...` |

### Ticket

Tickets are digitally signed objects
(Refer to [Ticket Structure section](#ticket-structure))
issued by registrars to advertisers to reliably indicate
how long an advertiser already waited for admission.

### Advertisement

An **advertisement** is a data structure (Refer [Advertisement Structure section](#advertisement-structure))
indicating that a specific node participates in a service.

### Advertisement Cache

An advertisement cache is a bounded storage structure
maintained by registrars to store accepted advertisements.

### Advertise Table

An advertise table `AdvT(s)` is centered on service ID `s` and maintained by advertisers.
It is initialized from the advertiser’s Kad-dht routing table
and maintained through interactions with registrars during the advertisement process.
Every bucket in the table has a list of registrars at a particular distance
on which advertisers can place their advertisements.

### Search Table

A search table `DiscT(s)` is centered service ID on `s`  and maintained by discoverers.
It is initialized from the discoverer’s Kad-dht routing table
and  maintained through interactions with registrars during lookup operations.
Every bucket in the table has a list of registrars at a particular distance
which discoverers can query to get advertisements for a particular service.

### Distance

The distance `d` between any two keys in Logos Discovery Capability
is defined using the bitwise XOR applied to their 256-bit SHA-256 representations.
This provides a deterministic, uniform, and symmetric way to measure proximity in the keyspace.
The keyspace is the entire numerical range of possible `node.ids` and service IDs `s`
— the 256-bit space in which all SHA-256–derived IDs exist.
XOR is used to measure distances between them in the keyspace.

For every node in the network, the `node.id` is unique.
In this system, both `node.id` and the service ID `s` are 256-bit SHA-256 hashes.
Thus both belong to the same keyspace.

Advertise table `AdvT(s)` and search table `DiscT(s)` are centered on service ID `s`
while `KadDHT(node.id)` table is centered on `node.id`.

When inserting a node into advertise table `AdvT(s)` or the search table `DiscT(s)`,
the bucket index into which the node will be inserted is determined by:

- x = reference ID which is the service ID `s`
- y = target peer ID `node.id`
- L = 256 = bit length of IDs
- `m` = 16 = number of buckets in the advertise/search table
- `d = x ⊕ y = s ⊕ node.id` = bitwise XOR distance (interpreted as an unsigned integer)

The bucket index `i` where `y` is placed in `x`'s advertise/search table is:

- For `d > 0`, `i = min( ⌊ (m / 256) * (256 − 1 − ⌊log₂(d)⌋) ⌋ , m − 1 )`
- For `d = 0`, `i = m - 1` which is the same ID case

If we further simplify it, then:

- Let `lz = CLZ(d)` = number of leading zeros in the 256-bit representation of `d`
- `i = min( ⌊ (lz * m) / 256 ⌋ , m − 1 )`

Lower-index buckets represent peers far away from `s` in the keyspace,
while higher-index buckets contain peers closer to `s`.
This property allows efficient logarithmic routing:
each hop moves to a peer that shares a longer prefix of bits
with the target service ID `s`.

This formula is also used when we bootstrap peers from the `KadDHT` table.
For every peer present in the `KadDHT(node.id)` table
we use the same formula to place them in advertise table `AdvT(s)`,
search table `DiscT(s)` and Registrar Table `RegT(s)` buckets.

Initially the density of peers in the search table `DiscT(S)`
and advertise table `AdvT(s)` around `s` might be low or even null
particularly when `s` and `node.id` are distant in the keyspace
(as `KadDHT(node.id)` is centered on node ID).
The buckets are thus filled opportunistically
while interacting with peers during the search or advertisement process.
Registrars, apart from responding to queries,
return a list of peers as `response.closerPeers` .
These are also added to buckets in `AdvT(s)` and `DiscT(s)` using the same formula.

### System Parameters

The system parameters are derived directly from
the [DISC-NG paper](https://ieeexplore.ieee.org/document/10629017).
Implementations may modify them as needed based on specific requirements.

| Parameter | Default Value | Description |
| --- | --- | --- |
| `K_register` | 3 | Max number of active (i.e. unexpired) registrations + ongoing registration attempts per bucket. |
| `K_lookup` | 5 | For each bucket in the search table, number of random registrar nodes queried by discoverers |
| `F_lookup` | 30 | number of advertisers to find in the lookup process. we stop lookup process when we have found these many advertisers |
| `F_return` | 10 | max number of service-specific peers returned from a single registrar |
| `E` | 900 seconds | Advertisement expiry time (15 minutes) |
| `C` | 1,000 | Advertisement cache capacity |
| `P_occ` | 10 | Occupancy exponent for waiting time calculation |
| `G` | 10⁻⁷ | Safety parameter for waiting time calculation |
| `δ` | 1 second | Registration window time |
| `m`  | 16 | Number of buckets for advertise table, search table |

### Bucket

Each bucket in all the tables stores peer information —
typically including the peer ID, multiaddresses, and other relevant metadata.

For simplicity in this RFC, we represent each bucket as a list of peer IDs.
However, in a full implementation, each entry in the bucket should store
a complete peer information object containing both the peer ID
and the corresponding network address (to enable communication).

**Bucket Size:**

The number of entries a bucket can hold is implementation-dependent.

- Smaller buckets → lower memory usage but may reduce resilience to churn.
- Larger buckets → better redundancy but increased maintenance

**Note:**

The `response.closerPeers` field returned by registrars should include
a list of peer information object which contains both peer IDs and addresses,
as the latter is required to contact peers.
In this RFC, we simplify representation by listing only peer IDs,
but full implementations must include address information.

### Address

A multiaddress is a standardized way used in libp2p to represent network addresses

Since this RFC builds upon libp2p Kademlia DHT, we use multiaddresses for peer connectivity.
However, implementations are free to use alternative address representations,
as long as they remain interoperable and convey sufficient information
(e.g., IP + port) to establish a connection.

### Signature

In the base Kad DHT specification, signatures are optional,
typically implemented as a PKI ****signature over the tuple `(key || value || author)`.

This RFC does not restrict the specific digital signature algorithm used,
but implementations must ensure verifiability and interoperability across peers.

The recommended default is `Ed25519`,
as it is already widely used within the libp2p and Ethereum ecosystem
due to its balance of security and efficiency.

However, implementations may choose alternative schemes
based on their cryptographic stack or ecosystem requirements, such as:

- `secp256k1` — compatible with Ethereum and other ECDSA-based systems.
- `BLS12-381` — suitable for aggregate signatures
or use cases requiring threshold verification.
- `Ed25519` — recommended default; fast, deterministic,
and supported natively in libp2p.

### Expiry Time `E`

`E` is advertisement expiry time in seconds.
The expiry time **`E`** is a system wide parameter,
not an individual ad field or parameter of an individual registrar.

How expiry works:

- When an advertisement is registered,
it is stored in the registrar node’s ad_cache
with its `Timestamp` = current Unix time.
- When processing or periodically cleaning,
the registrar checks `if currentTime - ad.Timestamp > E`.
- If true → the ad is expired and should be removed from the cache.

## Protocol Roles

### Advertiser

**Advertisers** participate in service and want to be discovered by their peers.
Advertisers run the `ADVERTISE()` algorithm as in described in [Advertise Algorithm section](#advertisement-algorithm)
for distributing advertisements across registrars. They maintain the **advertise table** `AdvT(s)`.

### Discoverer

Discoverers attempt to discover advertisers registered under specific service
by running the `LOOKUP()` algorithm as in described in [Lookup Algorithm section](#lookup-algorithm).

### Registrar

Registers store ads from advertisers in their advertisement cache.
Registers use a waiting time based admission control mechanism using the `REGISTER()` algorithm
as described in [Registration Flow section](#registration-flow)
to decide whether to admit an advertisement coming from an advertiser or not.
It uses the `LOOKUP_RESPONSE()` as described in Section 8, algorithm to respond to `LOOKUP()` requests of discoverers.

## Advertisement Placement

### Overview

### Advertisement Algorithm

## Service Discovery

### Overview

### Lookup Algorithm

## Admission Protocol

### Overview

### Registration Flow

### Lookup Response Algorithm

### Peer Table Updates

## Waiting Time Calculation

### Formula

## RPC Messages

### Message Types

### Advertisement Structure

### Ticket Structure

### REGISTER Message

### GET_ADS Message

##  Implementation Notes

### Client and Server Mode

Logos discovery respects the client/server mode distinction
from the base Kad-dht specification:

- **Server mode nodes**: Can be Discoverer, Advertiser and Registrar
- **Client mode nodes**: Can only be Discoverer

Implementations may include incentivization mechanisms
to encourage peers to participate as advertisers or registrars,
rather than operating solely in client mode.
This helps prevent free-riding behavior,
ensures a fair distribution of network load,
and maintains the overall resilience and availability of the discovery layer.
Incentivization mechanisms are beyond the scope of this RFC.

## References

[0] Kademlia: A Peer-to-Peer Information System Based on the XOR Metric

[1] [DISC-NG: Robust Service Discovery in the Ethereum Global Network](https://ieeexplore.ieee.org/document/10629017)

[2] [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)

[3] [Go implementation](https://github.com/libp2p/go-libp2p-kad-dht)
