---
title: LOGOS-CAPABILITY-DISCOVERY
name: Logos Capability Discovery Protocol
status: raw
category: Standards Track
tags:
editor: Arunima Chaudhuri [arunima@status.im](mailto:arunima@status.im)
contributors: Ugur Sen [ugur@status.im](mailto:ugur@status.im)

---

## Abstract

This RFC defines the Logos capability discovery protocol,
a discovery mechanism inspired by [DISC-NG service discovery](https://ieeexplore.ieee.org/document/10629017)
built on top of [Kad-dht](https://github.com/libp2p/specs/tree/7740c076350b6636b868a9e4a411280eea34d335/kad-dht).
It enables nodes to advertise their participation in specific services
and allows other nodes to efficiently discover peers participating in those services.
In this RFC, the terms capability and service are used interchangeably.
Within Logos, a node’s “capabilities” map directly to the “services” it participates in.

The protocol adds service-specific advertisement placement and retrieval mechanisms
on top of the base Kad-dht functionality.
For everything else that isn't explicitly stated herein,
it is safe to assume behaviour similar to Kad-dht.
The terms “peer” and “node” are used interchangeably throughout this document
and refer to the same entity — a participant in the Logos Discovery network.

Logos discovery extends Kad-dht toward a multi-service, resilient discovery layer,
enhancing reliability while maintaining compatibility with existing Kad-dht behavior.

## Motivation

In decentralized networks supporting multiple services,
efficient peer discovery for specific services is critical.
Traditional approaches face several challenges:

1. Random-walk–based discovery is inefficient for unpopular services.
2. A naive approach where nodes advertise their service at DHT peers
whose IDs are closest to the service ID leads to hotspots and overload at popular services.
3. Discovery must scale logarithmically across many distinct services.

Through service-specific tables, adaptive advertisement placement,
admission control, and improved lookup operation,
Logos discovery aims to balance efficiency, scalability,
and resilience across multiple services.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Protocol Roles

### Advertiser

**Advertisers** participate in service and want to be discovered by their peers.
Advertisers run the `ADVERTISE()` algorithm as in described in [Advertise Algorithm section](#advertisement-algorithm)
for distributing advertisements across registrars. They maintain the **advertise table** `AdvT(service_id_hash)`.

### Discoverer

Discoverers attempt to discover advertisers registered under specific service
by running the `LOOKUP()` algorithm as in described in [Lookup Algorithm section](#lookup-algorithm).

### Registrar

Registrars store advertisements from advertisers in their advertisement cache.
Registrars use a waiting time based admission control mechanism using the `REGISTER()` algorithm
as described in [Registration Flow section](#registration-flow)
to decide whether to admit an advertisement coming from an advertiser or not.
It uses the `LOOKUP_RESPONSE()` as described in [Lookup Response Algorithm section](#lookup-response-algorithm),
algorithm to respond to `LOOKUP()` requests of discoverers.

## Definitions

### DHT Routing Table

Every participant in the kad-dht peer discovery layer maintains the peer routing table `KadDHT(peerID)`.
It is a distributed key-value store with
[peer IDs](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/peer-ids/peer-ids.md#peer-ids)
as key against their matching
[signed peer records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md) values.
It is centered on the node's `peerID`.

**Note:**

“Centered on” means the table is organized using that ID as the reference point
for computing distances with other peers and assigning peers to buckets.

### Service

A service is a logical sub-network within the larger peer-to-peer network.
It represents a specific capability a node supports — for example, a particular protocol or functionality it offers.
Services are identified by a unique service identifier string like `waku.store, libp2p.mix, etc.`

### Service ID

The service ID `service_id_hash` is the SHA-256 hash of the service identifier string.

For example:

| Service Identifier | Service ID (hex, truncated) |
| --- | --- |
| `waku.store` | `a4b6f3d1c7e2d8f4c9b9e6d1f3a1c2e9...` |
| `libp2p.mix` | `5e71b18a9d7c3c20f92a15b54a7d4c3e...` |

### Ticket

Tickets are digitally signed objects
(refer to the [Ticket Structure section](#ticket-structure))
issued by registrars to advertisers to reliably indicate
how long an advertiser already waited for admission.

### Advertisement

An **advertisement** is a data structure (refer to the [Advertisement Structure section](#advertisement-structure))
indicating that a specific node participates in a service.
In this RFC we refer to advertisement objects as `ads`.
For a single advertisement object we use `ad`.

### Advertisement Cache

An advertisement cache is a bounded storage structure
maintained by registrars to store accepted advertisements.

### Advertise Table

An advertise table `AdvT(service_id_hash)` is centered on `service_id_hash` and maintained by advertisers.
It is initialized from the advertiser’s Kad-dht routing table
and maintained through interactions with registrars during the advertisement process.
Every bucket in the table has a list of registrars at a particular distance
on which advertisers can place their advertisements.

### Search Table

A search table `DiscT(service_id_hash)` is centered `service_id_hash` and maintained by discoverers.
It is initialized from the discoverer’s Kad-dht routing table
and  maintained through interactions with registrars during lookup operations.
Every bucket in the table has a list of registrars at a particular distance
which discoverers can query to get advertisements for a particular service.

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

## Protocol Specifications

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

### Distance

The distance `d` between any two keys in Logos Capability Discovery
is defined using the bitwise XOR applied to their 256-bit SHA-256 representations.
This provides a deterministic, uniform, and symmetric way to measure proximity in the keyspace.
The keyspace is the entire numerical range of possible `peerID` and `service_id_hash`
— the 256-bit space in which all SHA-256–derived IDs exist.
XOR is used to measure distances between them in the keyspace.

For every node in the network, the `peerID` is unique.
In this system, both `peerID` and the `service_id_hash` are 256-bit SHA-256 hashes.
Thus both belong to the same keyspace.

Advertise table `AdvT(service_id_hash)` and search table `DiscT(service_id_hash)` are centered on `service_id_hash`
while `KadDHT(peerID)` table is centered on `peerID`.

When inserting a node into advertise table `AdvT(service_id_hash)` or the search table `DiscT(service_id_hash)`,
the bucket index into which the node will be inserted is determined by:

- x = reference ID which is the `service_id_hash`
- y = target peer ID `peerID`
- L = 256 = bit length of IDs
- `m` = 16 = number of buckets in the advertise/search table
- `d = x ⊕ y = service_id_hash ⊕ peerID` = bitwise XOR distance (interpreted as an unsigned integer)

The bucket index `i` where `y` is placed in `x`'s advertise/search table is:

- For `d > 0`, `i = min( ⌊ (m / 256) * (256 − 1 − ⌊log₂(d)⌋) ⌋ , m − 1 )`
- For `d = 0`, `i = m - 1` which is the same ID case

If we further simplify it, then:

- Let `lz = CLZ(d)` = number of leading zeros in the 256-bit representation of `d`
- `i = min( ⌊ (lz * m) / 256 ⌋ , m − 1 )`

Lower-index buckets represent peers far away from `service_id_hash` in the keyspace,
while higher-index buckets contain peers closer to `service_id_hash`.
This property allows efficient logarithmic routing:
each hop moves to a peer that shares a longer prefix of bits
with the target `service_id_hash`.

This formula is also used when we bootstrap peers from the `KadDHT` table.
For every peer present in the `KadDHT(peerID)` table
we use the same formula to place them in advertise table `AdvT(service_id_hash)`,
search table `DiscT(service_id_hash)` and Registrar Table `RegT(service_id_hash)` buckets.

Initially the density of peers in the search table `DiscT(service_id_hash)`
and advertise table `AdvT(service_id_hash)` around `service_id_hash` might be low or even null
particularly when `service_id_hash` and `peerID` are distant in the keyspace
(as `KadDHT(peerID)` is centered on `peerID`).
The buckets are thus filled opportunistically
while interacting with peers during the search or advertisement process.
Registrars, apart from responding to queries,
return a list of peers as `response.closerPeers` .
These are also added to buckets in `AdvT(service_id_hash)` and `DiscT(service_id_hash)` using the same formula.

**Note:**

The `response.closerPeers` field returned by registrars should include
a list of peer information object which contains both peer IDs and addresses,
as the latter is required to contact peers.
In this RFC, we simplify representation by listing only peer IDs,
but full implementations must include address information.

## RPC Messages

All RPC messages are sent using the libp2p Kad-dht message format
with new message types added for Logos discovery operations.

### Message Types

The following message types are added to the Kad-dht `Message.MessageType` enum:

```protobuf
enum MessageType {
    // ... existing Kad-dht message types ...
    REGISTER = 6;
    GET_ADS = 7;
}
```

### Advertisement Structure

```protobuf
message Advertisement {
    // Service identifier (32-byte SHA-256 hash)
    bytes service_id_hash = 1;

    // Peer ID of advertiser (32-byte hash of public key)
    bytes peerID = 2;

    // Multiaddrs of advertiser
    repeated bytes addrs = 3;

    // Ed25519 signature over (service_id_hash || peerID || addrs)
    bytes signature = 4;

    // Optional: Service-specific metadata
    optional bytes metadata = 5;

    // Unix timestamp in seconds
    uint64 timestamp = 6;
}
```

### Ticket Structure

```protobuf
message Ticket {
    // Copy of the original advertisement
    Advertisement ad = 1;

    // Ticket creation timestamp (Unix time in seconds)
    uint64 t_init = 2;

    // Last modification timestamp (Unix time in seconds)
    uint64 t_mod = 3;

    // Remaining wait time in seconds
    uint32 t_wait_for = 4;

    // Ed25519 signature over (ad || t_init || t_mod || t_wait_for)
    bytes signature = 5;
}
```

### REGISTER Message

#### Request

```protobuf
message Message {
    MessageType type = 1;  // REGISTER
    bytes key = 2;         // service_id_hash
    Advertisement ad = 3;   // The advertisement to register
    optional Ticket ticket = 4;  // Optional: ticket from previous attempt
}
```

#### Response

```protobuf
enum RegistrationStatus {
    CONFIRMED = 0;  // Advertisement accepted
    WAIT = 1;       // Must wait, ticket provided
    REJECTED = 2;   // Advertisement rejected
}

message Message {
    MessageType type = 1;       // REGISTER
    RegistrationStatus status = 2;
    optional Ticket ticket = 3;  // Provided if status = WAIT
    repeated Peer closerPeers = 4;  // Peers for populating advertise table
}
```

### GET_ADS Message

#### Request

```protobuf
message Message {
    MessageType type = 1;  // GET_ADS
    bytes key = 2;         // service_id_hash to look up
}
```

#### Response

```protobuf
message Message {
    MessageType type = 1;              // GET_ADS
    repeated Advertisement ads = 2;     // Up to F_return advertisements
    repeated Peer closerPeers = 3;     // Peers for populating search table
}
```

## Advertisement Placement

### Overview

`ADVERTISE(service_id_hash)` lets advertisers publish itself as a participant in a particular `service_id_hash` .

It spreads advertisements for its service across multiple registrars,
such that other peers can  find it efficiently.

### Advertisement Algorithm

Advertisers place advertisements across multiple registrars using the `ADVERTISE()` algorithm.
The advertisers run `ADVERTISE()` periodically.
Implementations may choose the interval based on their requirements.

```text
procedure ADVERTISE(service_id_hash):
    ongoing ← MAP<bucketIndex; LIST<registrars>>
    AdvT(service_id_hash) ← KadDHT(peerID)
    for i in 0, 1, ..., m-1:
        while ongoing[i].size < K_register:
            registrar ← AdvT(service_id_hash).getBucket(i).getRandomNode()
            if registrar = None:
                break
            end if
            ongoing[i].add(registrar)
            ad.service_id_hash ← service_id_hash
            ad.peerID ← peerID
            ad.addrs ← node.addrs
            ad.timestamp ← NOW()
            SIGN(ad)
            async(ADVERTISE_SINGLE(registrar, ad, i, service_id_hash))
        end while
    end for
end procedure

procedure ADVERTISE_SINGLE(registrar, ad, i, service_id_hash):
    ticket ← None
    while True:
        response ← registrar.Register(ad, ticket)
        AdvT(service_id_hash).add(response.closerPeers)
        if response.status = Confirmed:
            SLEEP(E)
            break
        else if response.status = Wait:
            SLEEP(min(E, response.ticket.t_wait_for))
            ticket ← response.ticket
        else:
            break
        end if
    end while
    ongoing[i].remove(registrar)
end procedure
```

Refer to the [Advertiser Algorithms Explanation section](#advertiser-algorithms-explanation) for a detailed explanation.

## Service Discovery

### Overview

The `LOOKUP(service_id_hash)` procedure is run by a discoverer to query registrar nodes
to find advertisements for a specific `service_id_hash`.

Discoverers runs `LOOKUP(service_id_hash)` periodically and when more peers are requested by its service application.
Implementations may choose the interval based on their requirements.

It works like a gradual search on the search table `DiscT(service_id_hash)`,
starting from far buckets (`b_0`) which has registrar nodes with fewer shared bits with `service_id_hash`
and moving to buckets (`b_(m-1)`) containing registrar nodes with higher number of shared bits or closer to `service_id_hash`.

### Lookup Algorithm

```protobuf
procedure LOOKUP(service_id_hash):
    DiscT(service_id_hash) ← KadDHT(peerID)
    foundPeers ← SET<Peers>
    for i in 0, 1, ..., m-1:
        for j in 0, ..., K_lookup - 1:
            peer ← DiscT(service_id_hash).getBucket(i).getRandomNode()
            if peer = None:
                break
            end if
            response ← peer.GetAds(service_id_hash)
            for ad in response.ads:
                assert(ad.hasValidSignature())
                foundPeers.add(ad.peerID)
                if foundPeers.size ≥ F_lookup:
                      break
                  end if
              end for
            DiscT(service_id_hash).add(response.closerPeers)
            if foundPeers.size ≥ F_lookup:
                return foundPeers
            end if
        end for
    end for
    return foundPeers
end procedure
```

Refer to the [Lookup Algorithm Explanation section](#lookupservice_id_hash-algorithm-explanation) for the detailed explanation.

## Admission Protocol

### Overview

Registrars use a waiting time based admission protocol to admit advertisements into their `ad_cache`.
The mechanism does not require registrars to maintain any state for each ongoing request preventing DoS attacks.

`ad_cache` is the advertisement cache.
It is a bounded storage structure maintained by registrars to store accepted advertisements.
The total size of the `ad_cache` is limited by its capacity `C`.
Each ad stored in the `ad_cache` has an associated expiry time `E`,
after which the `ad` is automatically removed.

How expiry works:

- When an advertisement is registered,
it is stored in the registrar node’s `ad_cache`
with its `Timestamp` = current Unix time.
- When processing or periodically cleaning,
the registrar checks `if currentTime - ad.Timestamp > E`.
- If true → the ad is expired and should be removed from the cache.

### Registration Flow

When a registrar receives a `REGISTER` request from an advertiser
then it runs the `Register()` algorithm to decide whether to admit `ad` coming from advertiser
into its `ad_cache` or not.
Refer to the [Register Message section](#register-message) for the request and response structure of `REGISTER`.

```text
procedure REGISTER(ad, ticket):
    assert(ad not in ad_cache)
    response.ticket.ad ← ad
    t_wait ← CALCULATE_WAITING_TIME(ad)

    if ticket.empty():
        t_remaining ← t_wait
        response.ticket.t_init ← NOW()
        response.ticket.t_mod ← NOW()
    else:
        assert(ticket.hasValidSignature())
        assert(ticket.ad = ad)
        assert(ad.notInAdCache())
        t_scheduled ← ticket.t_mod + ticket.t_wait_for
        assert(t_scheduled ≤ NOW() ≤ t_scheduled + δ)
        t_remaining ← t_wait - (NOW() - ticket.t_init)
    end if
    if t_remaining ≤ 0:
        ad_cache.add(ad)
        response.status ← Confirmed
    else:
        response.status ← Wait
        response.ticket.t_wait_for ← MIN(E, t_remaining)
        response.ticket.t_mod ← NOW()
        SIGN(response.ticket)
    end if
    response.closerPeers ← GETPEERS(ad.service_id_hash)
    return response
end procedure
```

Refer to the [Register Algorithm Explanation section](#register-algorithm-explanation) for detailed explanation.

### Lookup Response Algorithm

Registrars respond to `GET_ADS` requests from discoverers using the `LOOKUP_RESPONSE()` algorithm.
Refer to [GET_ADS Message section](#get_ads-message) for the request and response structure of `GET_ADS`.

```text
procedure LOOKUP_RESPONSE(service_id_hash):
    response.ads ← ad_cache.getAdvertisements(service_id_hash)[:F_return]
    response.closerPeers ← GETPEERS(service_id_hash)
    return response
end procedure
```

1. Fetch all `ads` for `service_id_hash` from the registrar’s `ad_cache`.
Then return up to `F_return` of them (a system parameter limiting how many `ads` are sent per query by a registrar).
2. Call the `GETPEERS(service_id_hash)` function to get a list of peers
from across the registrar’s routing table `RegT(service_id_hash)`.
3. Send the assembled response (advertisements + closer peers) back to the discoverer.

### Peer Table Updates

While responding to both `REGISTER` requests by advertisers and `GET_ADS` request by discoverers,
the contacted registrar node also returns a list of peers.
To get this list of peers, the registrar runs the `GETPEERS(service_id_hash)` algorithm.
Both advertisers and discoverers update their service-specific tables using this list of peers.

```text
procedure GETPEERS(service_id_hash):
    peers ← SET<peers>
    RegT(service_id_hash) ← KadDHT(peerID)
    for i in 0, 1, ..., m-1:
        peer ← b_i(service_id_hash).getRandomNode()
        if peer ≠ None:
            peers.add(peer)
        end if
    end for
    return peers
end procedure
```

1. `peers` is initialized as an empty set to avoid storing duplicates
2. The registrar table `RegT(service_id_hash)` is initialized from the node’s `KadDHT(peerID)` routing table.
Refer to the [Distance section](#distance) on how to add peers.
3. Go through all `m` buckets in the registrar’s table — from farthest to closest relative to the `service_id_hash`.
    1. Pick one random peer from bucket `i`.
    `getRandomNode()`  function remembers already returned nodes and never returns the same one twice.
    2. If peer returned is not null then we move on to next bucket.
    Else we try to get another peer in the same bucket
4. Return `peers` which contains one peer from every bucket of `RegT(service_id_hash)`.

Malicious registrars could return large numbers of malicious nodes in a specific bucket.
To limit this risk, a node communicating with a registrar asks it to return a single peer per bucket
from registrar’s view of the routing table `RegT(service_id_hash)`.
Contacting registrars in consecutive buckets divides the search space by a constant factor,
and allows learning new peers from more densely-populated routing tables towards the destination.
The procedure mitigates the risk of having malicious peers polluting the table
while still learning rare peers in buckets close to `service_id_hash`.

## Waiting Time Calculation

### Formula

The waiting time is the time advertisers have to wait before being admitted to the `ad_cache`.
The waiting time is given based on the ad itself and the current state of the registrar’s `ad_cache`.

The waiting time for an advertisement is calculated using:

```text
w(ad) = E × (1/(1 - c/C)^P_occ) × (c(ad.service_id_hash)/C + score(getIP(ad.addrs)) + G)
```

- `c`: Current cache occupancy
- `c(ad.service_id_hash)`: Number of advertisements for `service_id_hash` in cache
- `getIP(ad.addrs)` is a function to get the IP address from the multiaddress of the advertisement.
- `score(getIP(ad.addrs))`: IP similarity score (0 to 1). Refer to the [IP Similarity Score section](#ip-similarity-score)

Section [System Parameters](#system-parameters) can be referred
for the definitions of the remaining parameters in the formula.

Issuing waiting times promote diversity in the ad cache.
It results in high waiting times and slower admission for malicious advertisers
using Sybil identities from a limited number of IP addresses.
It also promotes less popular services with fast admission
ensuring fairness and robustness against failures of single registrars.

### Scaling

The waiting time is normalized by the ad’s expiry time `E`.
It binds waiting time to `E` and allows us to reason about the number of incoming requests
regardless of the time each ad spends in the ad cache.

### Occupancy Score

```text
occupancy_score = 1 / (1 - c/C)^P_occ
```

The occupancy score increases progressively as the cache fills:

- When `c << C`: Score ≈ 1 (minimal impact)
- As the `ad_cache` fills up, the score will be amplified by the divisor of the equation.
The higher the value of `P_occ`, the faster the increase.
Implementations should consider this while setting the value for `P_occ`
- As `c → C`: Score → ∞ (prevents overflow)

### Service Similarity

```text
service_similarity = c(ad.service_id_hash) / C
```

The service similarity score promotes diversity:

- Low when `service_id_hash` has few advertisements in cache. Thus lower waiting time.
- High when `service_id_hash` dominates the cache. Thus higher waiting time.

### IP Similarity Score

IP similarity score is used to limit the number of IPs coming from the same subnetwork
by increasing their waiting time.
Higher similarity means higher score and a higher waiting time.
The `score` ranges from 0 to 1:

- closer to 1 for IPs sharing similar prefix
- closer to 0 for diverse IPs

IP tree is a binary tree that stores IPs used by `ads` that are currently present in the `ad_cache`.

#### Tree Structure

- Each tree vertex stores a `IP_counter` showing how many IPs pass through that node.
- Apart from root, the IP tree is a 32-level binary tree
- The `IP_counter` of every vertex of the tree is initially set to 0.
- edges represent consecutive 0s or 1s in a binary representation of IPv4 addresses.
- While inserting an IPv4 address into the tree using `ADD_IP_TO_TREE()` algorithm,
`IP_counter`s of all the visited vertices are increased by 1.
The visited path is the binary representation of the IPv4 address.
IPv4 addresses are inserted into the tree only when they are admitted to the `ad_cache`.
- The IP tree is traversed to calculate the IP score using `CALCULATE_IP_SCORE()` every time the waiting time is calculated.
- When an ad expires after `E` the ad is removed from the `ad_cache`
and the IP tree is also updated using the `REMOVE_FROM_IP_TREE()` algorithm by decreasing the `IP_counter`s on the path.
The path is the binary representation of the IPv4 address.
- the root `IP_counter` stores the number of IPv4 addresses that are currently present in the `ad_cache`

#### `ADD_IP_TO_TREE()` algorithm

IPv4 addresses are added to the IP tree using the `ADD_IP_TO_TREE()` algorithm when an ad admitted to the `ad_cache`.

```text
procedure ADD_IP_TO_TREE(tree, IP):
    v ← tree.root
    bits ← IP.toBinary()
    for i in 0, 1, ..., 31:
        v.IP_counter ← v.IP_counter + 1
        if bits[i] = 0:
            v ← v.left
        else:
            v ← v.right
        end if
    end for
end procedure
```

1. Start from the root node of the tree. Initialize current node variable `v` to root of the tree `tree.root`.
2. Convert the IP address into its binary form (32 bits) and sore in variable `bits`
3. Go through each bit of the IP address, from the most significant (leftmost `0`) to the least (rightmost `31`).
    1. Increase the `IP_counter` for the current node `v.IP_counter`.
    This records that another IP passed through this vertex `v` (i.e., shares this prefix).
    2. Move to the next node in the tree. Go left `v.left` if the current bit `bits[i]` is `0`.
    Go right `v.right` if it’s `1`.
    This follows the path corresponding to the IP’s binary representation.

The IP tree is traversed to calculate the IP score using `CALCULATE_IP_SCORE()` every time the waiting time is calculated.
It calculates how similar a given IP address is to other IPs already in the `ad_cache`
and returns the IP similarity score of the inserted IP address.
It’s used to detect when too many `ads` come from the same network or IP prefix — a possible Sybil behavior.

#### `CALCULATE_IP_SCORE()` algorithm

```text
procedure CALCULATE_IP_SCORE(tree, IP):
    v ← tree.root
    score ← 0
    bits ← IP.toBinary()
    for i in 0, 1, ..., 31:
        if bits[i] = 0:
            v ← v.left
        else:
            v ← v.right
        end if
        if v.IP_counter > tree.root.IP_counter / 2^i:
            score ← score + 1
        end if
    end for
    return score / 32
end procedure
```

1. Start from the root node of the tree.
2. Initialize the similarity score `score` to 0. This score will later show how common the IP’s prefix is among existing IPs.
3. Convert the IP address into its binary form (32 bits) and sore in variable `bits`
4. Go through each bit of the IP address, from the most significant (leftmost `0`) to the least (rightmost `31`).
    1. Move to the next node in the tree. Go left `v.left` if the current bit `bits[i]` is `0`. Go right `v.right` if it’s `1`.
    This follows the path corresponding to the IP’s binary representation.
    2. Check if this node’s `IP_counter` is larger than expected in a perfectly balanced tree.
    If it is, that means too many IPs share this prefix, so increase the similarity score `score` by 1.
5. Divide the total score by 32 (the number of bits in the IP) and return it.

#### `REMOVE_FROM_IP_TREE()` algorithm

When an ad expires after `E`, its IP is removed from the tree, and the `IP_counter`s in the nodes are decreased using the `REMOVE_FROM_IP_TREE()` algorithm.

```text
procedure REMOVE_FROM_IP_TREE(tree, IP):
    v ← tree.root
    bits ← IP.toBinary()
    for i in 0, 1, ..., 31:
        v.IP_counter ← v.IP_counter - 1
        if bits[i] = 0:
            v ← v.left
        else:
            v ← v.right
        end if
    end for
end procedure
```

Implementations can extend the IP tree algorithms to IPv6 by using a 128-level binary tree,
corresponding to the 128-bit length of IPv6 addresses.

### Safety Parameter

The safety parameter `G` ensures waiting times never reach zero even when:

- Service similarity is zero (new service).
- IP similarity is zero (completely distinct IP)

It prevents `ad_cache` overflow in cases when attackers try to send `ads` for random services or from diverse IPs.

### Lower Bound Enforcement

To prevent "ticket grinding" attacks where advertisers repeatedly request new tickets hoping for better waiting times,
registrars enforce lower bounds:

Invariant: A new waiting time `w_2` at time `t_2`
cannot be smaller than a previous waiting time `w_1` at time `t_1`
(where `t_1 < t_2`) by more than the elapsed time:

```text
w_2 ≥ w_1 - (t_2 - t_1)
```

Thus registrars maintain lower bound state for:

- Each service in the cache: `bound(service_id_hash)` and `timestamp(service_id_hash)`
- Each IP prefix in the IP tree: `bound(IP)` and `timestamp(IP)`

The total waiting time will respect the lower bound if lower bound is enforced on these.
These two sets have a bounded size as number of `ads` present in the `ad_cache` at a time is bounded by the cache capacity C.

**How lower bound is calculated for service IDs:**

When new `service_id_hash` enters the cache, `bound(service_id_hash)` is set to `0`,
and a `timestamp(service_id_hash)` is set to the current time.
When a new ticket request arrives for the same `service_id_hash`,
the registrar calculates the service waiting time `w_s` and then applies the lower-bound rule:

`w_s = max(w_s, bound(service_id_hash) - timestamp(service_id_hash))`

The values `bound(service_id_hash)` and `timestamp(service_id_hash)` are updated whenever a new ticket is issued
and the condition `w_s > (bound(service_id_hash) - timestamp(service_id_hash))`is satisfied.

**How lower bound is calculated for IPs:**
Registrars enforce lower-bound state for the advertiser’s IP address using IP tree
(refer to the [IP Similarity Score section](#ip-similarity-score)).

## Implementation Notes

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

[0] [Kademlia: A Peer-to-Peer Information System Based on the XOR Metric](https://pdos.csail.mit.edu/~petar/papers/maymounkov-kademlia-lncs.pdf)

[1] [DISC-NG: Robust Service Discovery in the Ethereum Global Network](https://ieeexplore.ieee.org/document/10629017)

[2] [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)

[3] [Go implementation](https://github.com/libp2p/go-libp2p-kad-dht)

## Appendix

This appendix provides detailed explanations of some algorithms and helper procedures referenced throughout this RFC. To maintain clarity and readability in the main specification, the body contains only the concise pseudocode and high-level descriptions.

### Advertiser Algorithms Explanation

Refer to the [Advertisement Algorithm section](#advertisement-algorithm) for the pseudocode.

#### ADVERTISE() algorithm explanation

1. Initialize a map `ongoing` for tracking which registrars are currently being advertised to.
2. Initialize the advertise table `AdvT(service_id_hash)` by bootstrapping peers from
the advertiser’s `KadDHT(peerID)` routing table.
(Refer to the [Distance section](#distance))
3. Iterate over all buckets (i = 0 through `m-1`),
where `m` is the number of buckets in `AdvT(service_id_hash)` and `ongoing` map.
Each bucket corresponds to a particular distance from the `service_id_hash`.
    1. `ongoing[i]` contains list of  registrars with active (unexpired) registrations
    or ongoing registration attempts at a distance `i`
    from the `service_id_hash` of the service that the advertiser is advertising for.
    2. Advertisers continuously maintain up to `K_register` active (unexpired) registrations
    or ongoing registration attempts in every bucket of the `ongoing` map for its service.
    Increasing `K_register` makes the advertiser easier to find
    at the cost of increased communication and storage costs.
    3. Pick a random registrar from bucket `i` of `AdvT(service_id_hash)` to advertise to.
        - `AdvT(service_id_hash).getBucket(i)` → returns a list of registrars in bucket `i`
        from the advertise table `AdvT(service_id_hash)`
        - `.getRandomNode()` → function returns a random registrar node.
        The advertiser tries to place its advertisement into that registrar.
        The function remembers already returned nodes
        and never returns the same one twice during the same ad placement process.
        If there are no peers, it returns `None`.
    4. if we get a peer then we add that to that bucket `ongoing[i]`
    5. Build the advertisement object `ad` containing `service_id_hash`, `peerID`, `addrs`, and `timestamp`
    (Refer to the [Advertisement Structure section](#advertisement-structure)) .
    Then it is signed by the advertiser using the node’s private key (Ed25519 signature)
    6. Then send this `ad` asynchronously to the selected registrar.
    The helper `ADVERTISE_SINGLE()` will handle registration to a single registrar.
    Asynchronous execution allows multiple `ads` (to multiple registrars) to proceed in parallel.

#### ADVERTISE_SINGLE() algorithm explanation

`ADVERTISE_SINGLE()` algorithm handles registration to one registrar at a time

1. Initialize `ticket` to `None` as we have not yet got any ticket from registrar
2. Keep trying until the registrar confirms or rejects the `ad`.
    1. Send the `ad` to the registrar using `Register` request.
    Request structure is described in section [Register Message Structure](#register-message).
    If we already have a ticket, include it in the request.
    2. The registrar replies with a `response`.
    Refer to the [Register Message Structure section](#register-message) for the response structure
    3. Add the list of peers returned by the registrar `response.closerPeers` to the advertise table `AdvT(service_id_hash)`.
    Refer to the [Distance](#distance section) on how to add.
    These help improve the table for future use.
    4. If the registrar accepted the advertisement successfully,
    wait for `E` seconds (the ad expiry time),
    then stop retrying because the ad is already registered.
    5. If the registrar says “wait” (its cache is full or overloaded),
    sleep for the time written in the ticket `ticket.t_wait_for`(but not more than ad expiry time `E`).
    Then update `ticket` with the new one from the registrar, and try again.
    6. If the registrar rejects the ad, stop trying with this registrar.
3. Remove this registrar from the `ongoing` map in bucket i (`ongoing[i]`),
since we’ve finished trying with it.

### Discoverer Algorithms

#### LOOKUP(service_id_hash) algorithm explanation

Refer to the [Lookup Algorithm section](#lookup-algorithm) for the pseudocode.

1. The **Discovery Table** `DiscT(service_id_hash)` is initialized by
bootstrapping peers from the discoverer’s `KadDHT(peerID)` routing table.
(refer to the [Distance section](#distance))
2. Create an empty set `foundPeers` to store unique advertisers peer IDs discovered during the lookup.
3. Go through each bucket of the search table `DiscT(service_id_hash)` —
from farthest (`b₀`) to closest (`bₘ₋₁`) to the service ID `service_id_hash`.
For each bucket, query up to `K_lookup` random peers.
    1. Pick a random registrar node from bucket `i` of the search table `DiscT(service_id_hash)` to query
        1. `DiscT(service_id_hash).getBucket(i)` → returns a list of registrars
        in bucket `i` from the search table `DiscT(service_id_hash)`
        2. `.getRandomNode()` → function returns a random registrar node.
        The discover queries this node to get `ads` for a particular service ID `service_id_hash`.
        The function remembers already returned nodes and never returns the same one twice.
        If there are no peers, it returns `None`.
    2. A `GET_ADS` request is sent to the selected registrar peer.
    Refer to the [GET_ADS Message section](#get_ads-message) to see the request and response structure for `GET_ADS`.
    The response returned by the registrar node is stored in `response`
    3. The `response` contains a list of advertisements `response.ads`.
    A queried registrar returns at most `F_return` advertisements.
    If it returns more we can just randomly keep `F_return` of them.
    For each advertisement returned:
        1. Verify its digital signature for authenticity.
        2. Add the advertiser’s peer ID `ad.peerID` to the list `foundPeers`.
    4. The `response` also contains a list of peers `response.closerPeers`
    that is inserted into the search table `DiscT(service_id_hash)`.
    Refer to the [Distance section](#distance) for how it is added.
    5. Stop early if enough advertiser peers (`F_lookup`) have been found — no need to continue searching.
    For popular services `F_lookup` advertisers are generally found in the initial phase
    from the farther buckets and the search terminates.
    But for unpopular ones it might take longer but not more than `O(log N)`
    where N is number of nodes participating in the network as registrars.
    6. If early stop doesn’t happen then the search stops when no unqueried registrars remain in any of the buckets.
4. Return `foundPeers` which is the final list of discovered advertisers that provide service `service_id_hash`

Making the advertisers and discoverers walk towards `service_id_hash` in a similar fashion
guarantees that the two processes overlap and contact a similar set of registrars that relay the `ads`.
At the same time, contacting random registrars in each encountered bucket using `getRandomNode()`
makes it difficult for an attacker to strategically place malicious registrars in the network.
The first bucket `b_0(service_id_hash)` covers the largest fraction of the key space
as it corresponds to peers with no common prefix to `service_id_hash` (i.e. 50% of all the registrars).
Placing malicious registrars in this fraction of the key space
to impact service discovery process would require considerable resources.
Subsequent buckets cover smaller fractions of the key space,
making it easier for the attacker to place Sybils
but also increasing the chance of advertisers already gathering enough `ads` in previous buckets.

Parameters `F_return` and `F_lookup` play an important role in setting a compromise between security and efficiency.
A small value of `F_return << F_lookup` increases the diversity of the source of `ads` received by the discoverer
but increases search time, and requires reaching buckets covering smaller key ranges where eclipse risks are higher.
On the other hand, similar values for `F_lookup` and `F_return` reduce overheads
but increase the danger of a discoverer receiving `ads` uniquely from malicious nodes.
Finally, low values of `F_lookup` stop the search operation early,
before reaching registrars close to the service hash, contributing to a more balanced load distribution.
Implementations should consider these trade-offs carefully when selecting appropriate values.

### Registrar Algorithms

#### `REGISTER()` algorithm explanation

Refer to the [Registration Flow section](#registration-flow) for the pseudocode

1. Make sure this advertisement `ad` is not already in the registrar’s advertisement cache `ad_cache`.
Duplicates are not allowed.
An advertiser can place at most one `ad` for a specific `service_id_hash` in the `ad_cache` of a given registrar.
2. Prepare a response ticket `response.ticket` linked to this `ad`.
3. Then calculate how long the advertiser should wait `t_wait` before being admitted.
Refer to the [Waiting Time Calculation section](#waiting-time-calculation) for details.
4. Check if this is the first registration attempt (no ticket yet):
    1. If yes then it’s the first try. The advertiser must wait for the full waiting time `t_wait`.
    The ticket’s creation time `t_init` and last-modified time `t_mod` are both set to `NOW()`.
    2. If no, then this is a retry, so a previous ticket exists.
        1. Validate that the ticket is properly signed by the registrar,
        belongs to this same advertisement and that the ad is still not already in the `ad_cache`.
        2. Ensure the retry is happening within the allowed time window `δ` after the scheduled time.
        If the advertiser waits too long or too short, the ticket is invalid.
        3. Calculate how much waiting time is left `t_remaining`
        by subtracting how long the advertiser has already waited
        (`NOW() - ticket.t_init`) from `t_wait`.
5. Check if the remaining waiting time `t_remaining` is less than or equal to 0.
This means  the waiting time is over.
`t_remaining` can be 0 also when the registrar decides that
the advertiser doesn’t have to wait for admission to the `ad_cache`(waiting time `t_wait` is 0).
    1. If yes, add the `ad` to `ad_cache` and confirm registration.
    The advertisement is now officially registered.
    2. If no, then there is still time to wait.
    In this case registrar does not store ad but instead issues a ticket.
        1. set `reponse.status` to `wait`
        2. Update the ticket with the new remaining waiting time `t_wait_for`
        3. Update the ticket last modification time `t_mod`
        4. Sign the ticket again. The advertiser will retry later using this new ticket.
6. Add a list of peers closer to the `ad.service_id_hash` using the `GETPEERS()` function
to the response (the advertiser uses this to update its advertise table `AdvT(service_id_hash)`).
7. Send the full response back to the advertiser

Upon receiving a ticket, the advertiser waits for the specified `t_wait` time
before trying to register again with the same registrar.
Each new registration attempt must include the latest ticket issued by that registrar.

A ticket can only be used within a limited **registration window** `δ`,
which is chosen to cover the maximum expected delay between the advertiser and registrar.
This rule prevents attackers from collecting many tickets, accumulating waiting times,
and submitting them all at once to overload the registrar.

Advertisers only read the waiting time `t_wait` from the ticket —
they do **not** use the creation time `t_init` or the modification time `t_mod`.
Therefore, **clock** synchronization between advertisers and registrars is not required.

The waiting time `t_wait` is not fixed.
Each time an advertiser tries to register, the registrar recalculates a new waiting time based on its current cache state.
The remaining time `t_remaining` is then computed as the difference between
the new waiting time and the time the advertiser has already waited, as recorded in the ticket.
With every retry, the advertiser accumulates waiting time and will eventually be admitted.
However, if the advertiser misses its registration window or fails to include the last ticket,
it loses all accumulated waiting time and must restart the registration process from the beginning.
Implementations must consider these factors while deciding the registration window `δ` time.

This design lets registrars prioritize advertisers that have waited longer
without keeping any per-request state before the ad is admitted to the cache.
Because waiting times are recalculated and tickets are stored only on the advertiser’s side,
the registrar is protected from memory exhaustion and DoS attacks caused by inactive or malicious advertisers.
