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
It uses the `LOOKUP_RESPONSE()` as described in [Lookup Response Algorithm section](#lookup-response-algorithm),
algorithm to respond to `LOOKUP()` requests of discoverers.

## Advertisement Placement

### Overview

`ADVERTISE(s)` lets advertisers publish itself as a participant in a particular *service with ID* `s` .

It spreads advertisements for its service across multiple registrars,
such that other peers can  find it efficiently.

### Advertisement Algorithm

```
procedure ADVERTISE(s):
    ongoing ← MAP<bucketIndex; LIST<registrars>>
    AdvT(s) ← KadDHT(node.id)
    for i in 0, 1, ..., m-1:
        while ongoing[i].size < K_register:
            registrar ← AdvT(s).getBucket(i).getRandomNode()
            if registrar = None:
                break
            end if
            ongoing[i].add(registrar)
            ad.serviceId ← s
            ad.peerId ← node.id
            ad.addrs ← node.addrs
            ad.timestamp ← NOW()
            SIGN(ad)
            async(ADVERTISE_SINGLE(registrar, ad, i, s))
        end while
    end for
end procedure

procedure ADVERTISE_SINGLE(registrar, ad, i, s):
    ticket ← None
    while True:
        response ← registrar.Register(ad, ticket)
        AdvT(s).add(response.closerPeers)
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

**ADVERTISE() algorithm explanation**

Advertisers place advertisements across multiple registrars using the `ADVERTISE()` algorithm.
The advertisers run `ADVERTISE()` periodically.
Implementations may choose the interval based on their requirements.

1. Initialize a map `ongoing` for tracking which registrars are currently being advertised to.
2. Initialize the advertise table `AdvT(s)` by bootstrapping peers from
the advertiser’s `KadDHT(node.id)` routing table.
(Refer Section [Distance](#distance))
3. Iterate over all buckets (i = 0 through `m-1`),
where `m` is the number of buckets in `AdvT(s)` and `ongoing` map.
Each bucket corresponds to a particular distance from the service ID `s`.
    1. `ongoing[i]` contains list of  registrars with active (unexpired) registrations
    or ongoing registration attempts at a distance `i`
    from the service ID `s` of the service that the advertiser is advertising for.
    2. Advertisers continuously maintain up to `K_register` active (unexpired) registrations
    or ongoing registration attempts in every bucket of the `ongoing` map for its service.
    Increasing `K_register` makes the advertiser easier to find
    at the cost of increased communication and storage costs.
    3. Pick a random registrar from bucket `i` of `AdvT(s)` to advertise to.
        - `AdvT(s).getBucket(i)` → returns a list of registrars in bucket `i`
        from the advertise table `AdvT(S)`
        - `.getRandomNode()` → function returns a random registrar node.
        The advertiser tries to place its advertisement into that registrar.
        The function remembers already returned nodes
        and never returns the same one twice during the same ad placement process.
        If there are no peers, it returns `None`.
    4. if we get a peer then we add that to that bucket `ongoing[i]`
    5. Build the advertisement object `ad` containing `serviceId`, `peerID`, `addrs`, and `timestamp`
    (Refer section [Advertisement Structure](#advertisement-structure)) .
    Then it is signed by the advertiser using the node’s private key (Ed25519 signature)
    6. Then send this `ad` asynchronously to the selected registrar.
    The helper `ADVERTISE_SINGLE()` will handle registration to a single registrar.
    Asynchronous execution allows multiple ads (to multiple registrars) to proceed in parallel.

**ADVERTISE_SINGLE() algorithm explanation:**

`ADVERTISE_SINGLE()` algorithm handles registration to one registrar at a time

1. Initialize `ticket` to `None` as we have not yet got any ticket from registrar
2. Keep trying until the registrar confirms or rejects the `ad`.
    1. Send the `ad` to the registrar using `Register` request.
    Request structure is described in section [Register Message Structure](#register-message).
    If we already have a ticket, include it in the request.
    2. The registrar replies with a `response`.
    Refer Section [Register Message Structure](#register-message) for the response structure
    3. Add the list of peers returned by the registrar `response.closerPeers` to the advertise table `AdvT(s)`.
    Refer section [Distance](#distance) on how to add.
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

All RPC messages are sent using the libp2p Kad-dht message format with new message types added for Logos discovery operations.

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
    bytes serviceId = 1;

    // Peer ID of advertiser (32-byte hash of public key)
    bytes peerId = 2;

    // Multiaddrs of advertiser
    repeated bytes addrs = 3;

    // Ed25519 signature over (serviceId || peerId || addrs)
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
    bytes key = 2;         // serviceId
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
    bytes key = 2;         // serviceId to look up
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

[0] Kademlia: A Peer-to-Peer Information System Based on the XOR Metric

[1] [DISC-NG: Robust Service Discovery in the Ethereum Global Network](https://ieeexplore.ieee.org/document/10629017)

[2] [libp2p Kademlia DHT specification](https://github.com/libp2p/specs/blob/master/kad-dht/README.md)

[3] [Go implementation](https://github.com/libp2p/go-libp2p-kad-dht)
