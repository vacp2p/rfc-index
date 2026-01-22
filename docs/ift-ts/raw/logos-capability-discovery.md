# LOGOS-CAPABILITY-DISCOVERY

| Field | Value |
| --- | --- |
| Name | Logos Capability Discovery Protocol |
| Slug | 107 |
| Status | raw |
| Category | Standards Track |
| Editor | Arunima Chaudhuri [arunima@status.im](mailto:arunima@status.im) |
| Contributors | Ugur Sen [ugur@status.im](mailto:ugur@status.im) |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/ift-ts/raw/logos-capability-discovery.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/ift-ts/raw/logos-capability-discovery.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/vac/raw/logos-capability-discovery.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/vac/raw/logos-capability-discovery.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/vac/raw/logos-capability-discovery.md) — ci: add mdBook configuration (#233)
- **2025-12-09** — [`aaf158a`](https://github.com/vacp2p/rfc-index/blob/aaf158aa59edb2ce0841a345725d16355218c196/vac/raw/logos-capability-discovery.md) — VAC/RAW/LOGOS-DISCOVERY-CAPABILITY RFC  (#212)

<!-- timeline:end -->





> **Note:** This specification is currently a WIP and undergoing a high rate of changes.

## Abstract

This RFC defines the Logos Capability Discovery protocol,
a discovery mechanism inspired by [DISC-NG service discovery](https://ieeexplore.ieee.org/document/10629017)
built on top of [Kad-dht](https://github.com/libp2p/specs/tree/7740c076350b6636b868a9e4a411280eea34d335/kad-dht).

The protocol enables nodes to:

- Advertise their participation in specific services
- Efficiently discover other peers participating in those services

In this RFC, the terms "capability" and "service" are used interchangeably.
Within Logos, a node’s “capabilities” map directly to
the “services” it participates in.
Similarly, "peer" and "node" refer to the same entity:
a participant in the Logos Discovery network.

Logos discovery extends Kad-dht toward a multi-service, resilient discovery layer,
enhancing reliability while maintaining compatibility with existing Kad-dht behavior.
For everything else that isn't explicitly stated herein,
it is safe to assume behaviour similar to Kad-dht.

## Motivation

In decentralized networks supporting multiple services,
efficient peer discovery for specific services is critical.
Traditional approaches face several challenges:

- Inefficiency: Random-walk–based discovery is inefficient for unpopular services.
- Load imbalance: A naive approach where nodes advertise their service at DHT peers
whose IDs are closest to the service ID
leads to hotspots and overload at popular services.
- Scalability: Discovery must scale logarithmically across many distinct services.

Logos discovery addresses these through:

- Service-specific routing tables
- Adaptive advertisement placement with admission control
- Improved lookup operations balancing efficiency and resilience

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Protocol Roles

The Logos capability discovery protocol defines three roles that nodes can perform:

### Advertiser

**Advertisers** are nodes that participate in a service
and want to be discovered by other peers.

Responsibilities:

- Advertisers SHOULD register advertisements for their service across registrars
- Advertisers SHOULD handle registration responses

### Discoverer

**Discoverers** are nodes attempting to find peers that provide a specific service.

Responsibilities:

- Discoverers SHOULD query registrars for advertisements of a service

### Registrar

**Registrars** are nodes that store and serve advertisements.

Responsibilities:

- Registrars MUST use a waiting time based admission control mechanism
to decide whether to store an advertisement coming from an advertiser or not.
- Registrars SHOULD respond to query requests for advertisements coming from discoverers.

## Definitions

### DHT Routing Table

Every participant in the kad-dht peer discovery layer
maintains the peer routing table `KadDHT(peerID)`.
It is a distributed key-value store with
[peer IDs](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/peer-ids/peer-ids.md#peer-ids)
as key against their matching
[signed peer records](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/RFC/0003-routing-records.md) values.
It is centered on the node's own `peerID`.

> “Centered on” means the table is organized using that ID as the reference point
for computing distances with other peers and assigning peers to buckets.

### Bucket

Each table is organized into buckets.
A bucket is a container that stores information about peers
at a particular distance range from the center ID.

For simplicity in this RFC, we represent each bucket as a list of peer IDs.
However, in a full implementation, each entry in the bucket MUST store
a complete peer information necessary to enable communication.

**Bucket Size:**

The number of entries a bucket can hold is implementation-dependent.

- Smaller buckets → lower memory usage but reduced resilience to churn
- Larger buckets →  better redundancy but increased maintenance overhead

### Service

A service is a logical sub-network within the larger peer-to-peer network.
It represents a specific capability a node supports
— for example, a particular protocol or functionality it offers.
A service MUST be identified by a libp2p protocol ID via the
[identify protocol](https://github.com/libp2p/specs/tree/7740c076350b6636b868a9e4a411280eea34d335/identify).

### Service ID

The service ID `service_id_hash` MUST be the SHA-256 hash of the protocol ID.

For example:

| Service Identifier | Service ID |
| --- | --- |
| `/waku/store/1.0.0` | `313a14f48b3617b0ac87daabd61c1f1f1bf6a59126da455909b7b11155e0eb8e` |
| `/libp2p/mix/1.2.0` | `9c55878d86e575916b267195b34125336c83056dffc9a184069bcb126a78115d` |

### Advertisement Cache

An advertisement cache `ad_cache` is a bounded storage structure
maintained by registrars to store accepted advertisements.

### Advertise Table

For every service it participates in, an advertiser node MUST maintain an
advertise table `AdvT(service_id_hash)` centered on `service_id_hash`.
The table MAY be initialized using
peers from the advertiser’s `KadDHT(peerID)` routing table.
It SHOULD be updated opportunistically through interactions with
registrars during the advertisement process.

Each bucket in the advertise table contains a list of registrar peers at a
particular XOR distance range from `service_id_hash`, which are candidates for placing
advertisements.

### Search Table

For every service it attempts to discover, a discoverer node MUST maintain a
search table `DiscT(service_id_hash)` centered on `service_id_hash`.
The table MAY be initialized using
peers from the discoverer’s`KadDHT(peerID)` routing table.
It SHOULD be updated through interactions with
registrars during lookup operations.

Each bucket in the search table contains a list of registrar peers at a
particular XOR distance range from `service_id_hash`, which discoverers can query to
retrieve advertisements for that service.

### Registrar Table

For every service for which it stores and serves advertisements,
a registrar node SHOULD maintain a registrar table `RegT(service_id_hash)`
centered on `service_id_hash`.
The table MAY be initialized using peers from the
registrar’s `KadDHT(peerID)` routing table.
It SHOULD be updated opportunistically
through interactions with advertisers and discoverers.

Each bucket in the registrar table contains a list of peer nodes
at a particular XOR distance range from `service_id_hash`.
Registrars use this table to return
`closerPeers` during `REGISTER` and `GET_ADS` responses,
enabling advertisers and discoverers to
refine their service-specific routing tables.

### Address

A [multiaddress](https://github.com/libp2p/specs/tree/7740c076350b6636b868a9e4a411280eea34d335/addressing)
is a standardized way used in libp2p to represent network addresses.
Implementations SHOULD use multiaddresses for peer connectivity.
However, implementations MAY use alternative address representations if they:

- Remain interoperable
- Convey sufficient information (IP + port) to establish connections

### Signature

Refer to [Peer Ids and Keys](https://github.com/libp2p/specs/blob/7740c076350b6636b868a9e4a411280eea34d335/peer-ids/peer-ids.md)
to know about supported signatures.
In the base Kad DHT specification, signatures are optional,
typically implemented as a PKI signature over the tuple `(key || value || author)`.
In this RFC digital signatures MUST be used to
authenticate advertisements and tickets.

### Expiry Time `E`

`E` is advertisement expiry time in seconds.
The expiry time **`E`** is a system wide parameter,
not an individual advertisement field or parameter of an individual registrar.

## Data Structures

### Advertisement

An **advertisement** is a data structure
indicating that a specific node participates in a service.
In this RFC we refer to advertisement objects as `ads`.
For a single advertisement object we use `ad`.

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

Advertisements MUST include `service_id_hash`, `peerID`, `addrs` and `signature` fields.
Advertisements MAY include `metadata` and `timestamp` fields.
The `signature` field MUST be a Ed25519 signature over the concatenation of
(`service_id_hash` || `peerID` || `addrs`).
Refer to [Signature](#signature) section for more details.
Implementations MUST verify this signature before accepting an advertisement.

### Ticket

Tickets are digitally signed objects
issued by registrars to advertisers to reliably indicate
how long an advertiser already waited for admission.

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

Tickets MUST include `ad`, `t_init`, `t_mod`, `t_wait_for` and `signature` fields.
The `signature` field MUST be an Ed25519 signature over the concatenation of
(`ad` || `t_init` || `t_mod` || `t_wait_for`).
Refer to [Signature](#signature) section for more details.
Implementations MUST verify this signature before accepting a ticket.

## Protocol Specifications

### System Parameters

The system parameters are derived directly from
the [DISC-NG paper](https://ieeexplore.ieee.org/document/10629017).
Implementations SHOULD modify them as needed based on specific requirements.

| Parameter | Default Value | Description |
| --- | --- | --- |
| `K_register` | 3 | Max number of active (i.e. unexpired) registrations + ongoing registration attempts per bucket. |
| `K_lookup` | 5 | For each bucket in the search table, number of random registrar nodes queried by discoverers |
| `F_lookup` | 30 | number of advertisers to find in the lookup process. We stop lookup process when we have found these many advertisers |
| `F_return` | 10 | max number of service-specific peers returned from a single registrar |
| `E` | 900 seconds | Advertisement expiry time (15 minutes) |
| `C` | 1,000 | Advertisement cache capacity |
| `P_occ` | 10 | Occupancy exponent for waiting time calculation |
| `G` | 10⁻⁷ | Safety parameter for waiting time calculation |
| `δ` | 1 second | Registration window time |
| `m`  | 16 | Number of buckets for advertise table, search table |

### Distance

The distance `d` between any two keys in Logos Capability Discovery
MUST be calculated using the bitwise XOR applied to their 256-bit SHA-256 representations.
This provides a deterministic, uniform, and symmetric way to measure proximity in the keyspace.
The keyspace is the entire numerical range of possible `peerID` and `service_id_hash`
— the 256-bit space in which all SHA-256–derived IDs exist.
XOR MUST be used to measure distances between them in the keyspace.

For every node in the network, the `peerID` is unique.
In this system, both `peerID` and the `service_id_hash` are 256-bit SHA-256 hashes.
Thus both belong to the same keyspace.

Advertise table `AdvT(service_id_hash)`, search table `DiscT(service_id_hash)`
and registrar table `RegT(service_id_hash)` MUST be centered on `service_id_hash`
while `KadDHT(peerID)` table is centered on `peerID`.

When inserting a node into `AdvT(service_id_hash)`, `DiscT(service_id_hash)` or `RegT(service_id_hash)`,
the bucket index into which the node will be inserted MUST be determined by:

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

This formula MUST also used when we bootstrap peers.
Bootstrapping MAY be done from the `KadDHT(peerID)` table.
For every peer present in the table from where we bootstrap,
we MUST use the same formula to place them in `AdvT(service_id_hash)`,
`DiscT(service_id_hash)` and `RegT(service_id_hash)` buckets.

Initially the density of peers in the search table `DiscT(service_id_hash)`
and advertise table `AdvT(service_id_hash)` around `service_id_hash` might be low or even null
particularly when `service_id_hash` and `peerID` are distant in the keyspace
(as `KadDHT(peerID)` is centered on `peerID`).
The buckets SHOULD be filled opportunistically
while interacting with peers during the search or advertisement process.
Registrars, apart from responding to queries,
SHOULD return a list of peers as `response.closerPeers` .
These peers SHOULD be added to buckets in `AdvT(service_id_hash)` and `DiscT(service_id_hash)`.
While adding peers implementations MUST use the same formula.

**Note:**

The `response.closerPeers` field returned by registrars SHOULD include
a list of peer information object which contains both peer IDs and addresses,
as the latter is required to contact peers.
In this RFC, we simplify representation by listing only peer IDs,
but full implementations SHOULD include address information.

## RPC Messages

All RPC messages MUST be sent using the libp2p Kad-dht message format
with new message types added for Logos discovery operations.

### Message Types

The following message types MUST be added to the Kad-dht `Message.MessageType` enum:

```protobuf
enum MessageType {
    // ... existing Kad-dht message types ...
    REGISTER = 6;
    GET_ADS = 7;
}
```

### REGISTER Message

#### REGISTER Request

Advertisers SHOULD send `REGISTER` request message to registrars
to admit the advertiser's advertisemnet for a service
into the registrar's `ad_cache`.

```protobuf
message Message {
    MessageType type = 1;  // REGISTER
    bytes key = 2;         // service_id_hash
    Advertisement ad = 3;   // The advertisement to register
    optional Ticket ticket = 4;  // Optional: ticket from previous attempt
}
```

Advertisers SHOULD include the `service_id_hash` in the `key` field
and the advertisement in the `ad` field of the request.
If this is a retry attempt, advertisers SHOULD include
the latest `ticket` received from the registrar.

#### REGISTER Response

`REGISTER` response SHOULD be sent by registrars to advertisers.

```protobuf
enum RegistrationStatus {
    CONFIRMED = 0;  // Advertisement accepted
    WAIT = 1;       // wait, ticket provided
    REJECTED = 2;   // Advertisement rejected
}

message Message {
    MessageType type = 1;       // REGISTER
    RegistrationStatus status = 2;
    optional Ticket ticket = 3;  // Provided if status = WAIT
    repeated Peer closerPeers = 4;  // Peers for populating advertise table
}
```

Registrars SHOULD set the `status` field to indicate the result of the registration attempt.
If `status` is `WAIT`, registrars MUST provide a valid `ticket`.
Registrars SHOULD include `closerPeers` to help populate the advertiser's table.

### GET_ADS Message

#### GET_ADS Request

Discoverers send `GET_ADS` request message to registrars
to get advertisements for a particular service.

```protobuf
message Message {
    MessageType type = 1;  // GET_ADS
    bytes key = 2;         // service_id_hash to look up
}
```

Discoverers SHOULD include the `service_id_hash` they are searching for in the `key` field.

#### GET_ADS Response

Registrars SHOULD respond to discoverer's `GET_ADS` request
using the following response structure.

```protobuf
message Message {
    MessageType type = 1;              // GET_ADS
    repeated Advertisement ads = 2;     // Up to F_return advertisements
    repeated Peer closerPeers = 3;     // Peers for populating search table
}
```

Registrars MUST return up to `F_return` advertisements for the requested service.
Registrars SHOULD include `closerPeers` to help populate the discoverer's search table.

## Sequence Diagram

![Sequence diagram](https://github.com/user-attachments/assets/d85fab17-c636-417a-afaf-c609aa53075d)

## Advertisement Placement

### Overview

`ADVERTISE(service_id_hash)` lets advertisers publish itself
as a participant in a particular `service_id_hash` .

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

Discoverers are nodes attempting to find peers that
provide a specific service identified by `service_id_hash`.

#### Discovery Table `DiscT(service_id_hash)` Requirements

For each service that a discoverer wants to find,
it MUST instantiate a search table `DiscT(service_id_hash)`,
centered on that `service_id_hash`.

Discoverers MAY bootstrap `DiscT(service_id_hash)` by copying existing entries
from `KadDHT(peerID)` already maintained by the node.
For every peer present in the table from where we bootstrap,
we MUST use the formula described in the [Distance](#distance) section to place them in buckets.
`DiscT(service_id_hash)` SHOULD be maintained through interactions
with registrars during lookup operations.

#### Lookup Requirements

The `LOOKUP(service_id_hash)` is carried out by discoverer nodes to query registrar nodes
to get advertisements of a particular `service_id_hash`.
The `LOOKUP(service_id_hash)` procedure MUST work as a gradual search
on the search table `DiscT(service_id_hash)` of the service whose advertisements it wants.
The `LOOKUP(service_id_hash)` MUST start from far buckets `(b_0)`
which has registrar nodes with fewer shared bits with service_id_hash
and moving to buckets `(b_(m-1))` containing registrar nodes with
higher number of shared bits or closer to `service_id_hash`.
To perform a lookup, discoverers:

- SHOULD query `K_lookup` random registrar nodes from every bucket of `DiscT(service_id_hash)`.
- MUST verify the signature of each advertisement received before accepting it.
- SHOULD add closer peers returned by registrars
in the response to `DiscT(service_id_hash)` to improve future lookups.
- SHOULD retrieve at most `F_return` advertisement peers from a single registrar.
- SHOULD run the lookup process periodically.
Implementations can choose the interval based on their requirements.

### Lookup Algorithm

We RECOMMEND that the following algorithm be used
to implement the service discovery requirements specified above.
Implementations MAY use alternative algorithms
as long as they satisfy requirements specified in the previous section.

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

Refer to the [Lookup Algorithm Explanation section](#lookupservice_id_hash-algorithm-explanation)
for the detailed explanation.

## Admission Protocol

### Overview

Registrars are nodes that store and serve advertisements.
They play a critical role in the Logos discovery network
by acting as intermediaries between advertisers and discoverers.

#### Admission Control Requirements

Registrars MUST use a waiting time based admission protocol
to admit advertisements into their `ad_cache`.
The mechanism does not require registrars to maintain
any state for each ongoing request preventing DoS attacks.

When a registrar node receives a `REGISTER` request from an advertiser node
to admit its `ad` for a service into the `ad_cache`,
the registrar MUST process the request according to the following requirements:

- The registrar MUST NOT admit an advertisement
if an identical `ad` already exists in the `ad_cache`.
- The Registrar MUST calculate waiting time for the advertisement
using the formula specified in the
[Waiting Time Calculation](#waiting-time-calculation) section.
The waiting time determines how long the advertiser must wait
before the `ad` can be admitted to the `ad_cache`.
- If no `ticket` is provided in the `REGISTER` request then
this is the advertiser's first registration attempt for the `ad`.
The registrar MUST create a new `ticket`
and return the signed `ticket` to the advertiser with status `Wait`.
- If the advertiser provides a `ticket` in the `REGISTER` request from a previous attempt:
  - The registrar MUST verify the `ticket.signature`
  is valid and was issued by this registrar.
  - The registrar MUST verify that `ticket.ad` matches the `ad` in the current request
  - The registrar MUST verify that the `ad` is still not in the `ad_cache`
  - The registrar MUST verify the retry is within the registration window
  - If any verification fails, the registrar MUST reject the request
  - The registrar MUST recalculate the waiting time based on current cache state
  - The registrar MUST calculate remaining wait time:
    `t_remaining = t_wait - (NOW() - ticket.t_init)`.
    This ensures advertisers accumulate waiting time across retries
- If `t_remaining ≤ 0`, the registrar MUST add the `ad` to the `ad_cache`
with `ad.Timestamp` set to current Unix time.
The registrar SHOULD return response with `status = Confirmed`
- If `t_remaining > 0`, the advertiser SHOULD continue waiting.
The registrar MUST issue a new `ticket` with updated `ticket.t_mod` and `ticket.t_wait_for = MIN(E, t_remaining)`.
The registrar MUST sign the new `ticket`.
The registrar SHOULD return response with status `Wait` and the new signed `ticket`.
- The registrar SHOULD include a list of closer peers (`response.closerPeers`)
to help the advertiser improve its advertise table.

`ad_cache` maintainence:

- The total size of the `ad_cache` MUST be limited by its capacity `C`.
- Each `ad` stored in the `ad_cache` MUST have an associated expiry time `E`,
after which the `ad` is MUST be automatically removed.
- When processing or periodically cleaning,
the registrar MUST check `if currentTime - ad.Timestamp > E`.
If true, the `ad` is expired and MUST be removed from the cache.
- `ad_cache` MUST NOT store duplicate `ad`.

### Registration Flow

We RECOMMEND that the following algorithm be used by registrars
to implement the admission control requirements specified above.

Refer to the [Register Message section](#register-message)
for the request and response structure of `REGISTER`.

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

Refer to the [Register Algorithm Explanation section](#register-algorithm-explanation)
for detailed explanation.

## Lookup Response Algorithm

Registrars respond to `GET_ADS` requests from discoverers
using the `LOOKUP_RESPONSE()` algorithm.
Refer to [GET_ADS Message section](#get_ads-message)
for the request and response structure of `GET_ADS`.

```text
procedure LOOKUP_RESPONSE(service_id_hash):
    response.ads ← ad_cache.getAdvertisements(service_id_hash)[:F_return]
    response.closerPeers ← GETPEERS(service_id_hash)
    return response
end procedure
```

1. Fetch all `ads` for `service_id_hash` from the registrar’s `ad_cache`.
Then return up to `F_return` of them
(a system parameter limiting how many `ads` are sent per query by a registrar).
2. Call the `GETPEERS(service_id_hash)` function to get a list of peers
from across the registrar’s routing table `RegT(service_id_hash)`.
3. Send the assembled response (advertisements + closer peers) back to the discoverer.

## Peer Table Updates

While responding to both `REGISTER` requests by advertisers
and `GET_ADS` request by discoverers,
the contacted registrar node also returns a list of peers.
To get this list of peers, the registrar runs the `GETPEERS(service_id_hash)` algorithm.
Both advertisers and discoverers update their
service-specific tables using this list of peers.

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

The waiting time is the time advertisers have to
wait before their `ad` is admitted to the `ad_cache`.
The waiting time is given based on the `ad` itself
and the current state of the registrar’s `ad_cache`.

The waiting time for an advertisement MUST be calculated using:

```text
w(ad) = E × (1/(1 - c/C)^P_occ) × (c(ad.service_id_hash)/C + score(getIP(ad.addrs)) + G)
```

- `c`: Current cache occupancy
- `c(ad.service_id_hash)`: Number of advertisements for `service_id_hash` in cache
- `getIP(ad.addrs)` is a function to get the IP address from the multiaddress of the advertisement.
- `score(getIP(ad.addrs))`: IP similarity score (0 to 1). Refer to the [IP Similarity Score section](#ip-similarity-score)

Section [System Parameters](#system-parameters) can be referred
for the definitions of the remaining parameters in the formula.

Issuing waiting times promote diversity in the `ad_cache`.
It results in high waiting times and slower admission for malicious advertisers
using Sybil identities from a limited number of IP addresses.
It also promotes less popular services with fast admission
ensuring fairness and robustness against failures of single registrars.

### Scaling

The waiting time is normalized by the ad’s expiry time `E`.
It binds waiting time to `E` and allows us to reason about the number of incoming requests
regardless of the time each `ad` spends in the `ad_cache`.

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

The IP similarity score is used to detect and limit
Sybil attacks where malicious actors create multiple advertisements
from the same network or IP prefix.

Registrars MUST use an IP similarity score to
limit the number of `ads` coming from the same subnetwork
by increasing their waiting time.
The IP similarity mechanism:

- MUST calculate a score ranging from 0 to 1, where:
  - A score closer to 1 indicates IPs sharing similar prefixes
  (potential Sybil behavior)
  - A score closer to 0 indicates diverse IPs (legitimate behavior)
- MUST track IP addresses of `ads` currently in the `ad_cache`.
- MUST update its tracking structure when:
  - A new `ad` is admitted to the `ad_cache`: MUST add the IP
  - An `ad` expires after time `E`:
  MUST remove IP if there are no other active `ads` from the same IP
- MUST calculate the IP similarity score every time
a waiting time is calculated for a new registration attempt.

#### Tree Structure

We RECOMMEND using an IP tree data structure
to efficiently track and calculate IP similarity scores.
An IP tree is a binary tree that stores
IPs used by `ads` currently present in the `ad_cache`.
This data structure provides logarithmic time complexity
for insertion, deletion, and score calculation.
Implementations MAY use alternative data structures
as long as they satisfy the requirements specified above.
The recommended IP tree has the following structure:

- Each tree vertex stores a `IP_counter` showing how many IPs pass through that node.
- Apart from root, the IP tree is a 32-level binary tree
- The `IP_counter` of every vertex of the tree is initially set to 0.
- edges represent consecutive 0s or 1s in a binary representation of IPv4 addresses.
- While inserting an IPv4 address into the tree using `ADD_IP_TO_TREE()` algorithm,
`IP_counter`s of all the visited vertices are increased by 1.
The visited path is the binary representation of the IPv4 address.
IPv4 addresses are inserted into the tree only when they are admitted to the `ad_cache`.
- The IP tree is traversed to calculate the IP score using
`CALCULATE_IP_SCORE()` every time the waiting time is calculated.
- When an `ad` expires after `E` the `ad` is removed from the `ad_cache`
and the IP tree is also updated using the `REMOVE_FROM_IP_TREE()` algorithm
by decreasing the `IP_counter`s on the path.
The path is the binary representation of the IPv4 address.
- the root `IP_counter` stores the number of IPv4 addresses
that are currently present in the `ad_cache`

#### `ADD_IP_TO_TREE()` algorithm

When an `ad` is admitted to the `ad_cache`,
its IPv4 address MUST be added to the IP tracking structure.

We RECOMMEND the `ADD_IP_TO_TREE()` algorithm for adding IPv4 addresses to the IP tree.
This algorithm ensures efficient insertion with O(32) time complexity.
Implementations MAY use alternative approaches as long as they maintain
accurate IP tracking for similarity calculation.

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

1. Start from the root node of the tree.
Initialize current node variable `v` to root of the tree `tree.root`.
2. Convert the IP address into its binary form (32 bits) and sore in variable `bits`
3. Go through each bit of the IP address, from the most significant (leftmost `0`) to the least (rightmost `31`).
    1. Increase the `IP_counter` for the current node `v.IP_counter`.
    This records that another IP passed through this vertex `v` (i.e., shares this prefix).
    2. Move to the next node in the tree. Go left `v.left` if the current bit `bits[i]` is `0`.
    Go right `v.right` if it’s `1`.
    This follows the path corresponding to the IP’s binary representation.

#### `CALCULATE_IP_SCORE()` algorithm

Every time a waiting time is calculated for a registration attempt,
the registrar MUST calculate the IP similarity score for the advertiser's IP address.
This score determines how similar the IP is to other IPs already in the cache.

We RECOMMEND the `CALCULATE_IP_SCORE()` algorithm for calculating IP similarity scores.
This algorithm traverses the IP tree to detect how many IPs share common prefixes,
providing an effective measure of potential Sybil behavior.
Implementations MAY use alternative approaches
as long as they accurately measure IP similarity on a 0-1 scale.

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
2. Initialize the similarity score `score` to 0.
This score will later show how common the IP’s prefix is among existing IPs.
3. Convert the IP address into its binary form (32 bits) and sore in variable `bits`
4. Go through each bit of the IP address,
from the most significant (leftmost `0`) to the least (rightmost `31`).
    1. Move to the next node in the tree.
    Go left `v.left` if the current bit `bits[i]` is `0`. Go right `v.right` if it’s `1`.
    This follows the path corresponding to the IP’s binary representation.
    2. Check if this node’s `IP_counter` is larger than expected in a perfectly balanced tree.
    If it is, that means too many IPs share this prefix,
    so increase the similarity score `score` by 1.
5. Divide the total score by 32 (the number of bits in the IP) and return it.

#### `REMOVE_FROM_IP_TREE()` algorithm

When an `ad` expires after time `E`,
the registrar MUST remove the `ad` from the `ad_cache`.
The registrar MUST also remove the IP from IP tracking structure
if there are no other active `ad` in `ad_cache` from the same IP.

We RECOMMEND the `REMOVE_FROM_IP_TREE()` algorithm for removing IPv4 addresses from the IP tree.
This algorithm ensures efficient deletion with O(32) time complexity.
Implementations MAY use alternative approaches as long as they maintain accurate IP tracking.

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

Implementations can extend the IP tree algorithms to IPv6
by using a 128-level binary tree,
corresponding to the 128-bit length of IPv6 addresses.

### Safety Parameter

The safety parameter `G` ensures waiting times never reach zero even when:

- Service similarity is zero (new service).
- IP similarity is zero (completely distinct IP)

It prevents `ad_cache` overflow in cases when attackers try to
send `ads` for random services or from diverse IPs.

### Lower Bound Enforcement

To prevent "ticket grinding" attacks where advertisers
repeatedly request new tickets hoping for better waiting times,
registrars MUST enforce lower bounds:

Invariant: A new waiting time `w_2` at time `t_2`
cannot be smaller than a previous waiting time `w_1` at time `t_1`
(where `t_1 < t_2`) by more than the elapsed time:

```text
w_2 ≥ w_1 - (t_2 - t_1)
```

Thus registrars MUST maintain lower bound state for:

- Each service in the cache: `bound(service_id_hash)` and `timestamp(service_id_hash)`
- Each IP prefix in the IP tree: `bound(IP)` and `timestamp(IP)`

The total waiting time will respect the lower bound if lower bound is enforced on these.
These two sets have a bounded size as number of `ads` present in the `ad_cache`
at a time is bounded by the cache capacity `C`.

**How SHOULD lower bound be calculated for service IDs:**

When new `service_id_hash` enters the cache, `bound(service_id_hash)` is set to `0`,
and a `timestamp(service_id_hash)` is set to the current time.
When a new ticket request arrives for the same `service_id_hash`,
the registrar calculates the service waiting time `w_s` and then applies the lower-bound rule:

`w_s = max(w_s, bound(service_id_hash) - timestamp(service_id_hash))`

The values `bound(service_id_hash)` and `timestamp(service_id_hash)`
are updated whenever a new `ticket` is issued
and the condition `w_s > (bound(service_id_hash) - timestamp(service_id_hash))`is satisfied.

**How SHOULD lower bound be calculated for IPs:**
Registrars enforce lower-bound state for the advertiser’s IP address using IP tree
(refer to the [IP Similarity Score section](#ip-similarity-score)).

## Implementation Notes

### Client and Server Mode

Logos discovery respects the client/server mode distinction
from the base Kad-dht specification:

- **Server mode nodes**: MAY be Discoverer, Advertiser or Registrar
- **Client mode nodes**: MUST be only Discoverer

Implementations MAY include incentivization mechanisms
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

This appendix provides detailed explanations of some algorithms
and helper procedures referenced throughout this RFC.
To maintain clarity and readability in the main specification,
the body contains only the concise pseudocode and high-level descriptions.

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
        and never returns the same one twice during the same `ad` placement process.
        If there are no peers, it returns `None`.
    4. if we get a peer then we add that to that bucket `ongoing[i]`
    5. Build the advertisement object `ad` containing `service_id_hash`, `peerID`, `addrs`, and `timestamp`
    (Refer to the [Advertisement section](#advertisement)) .
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
    wait for `E` seconds,
    then stop retrying because the `ad` is already registered.
    5. If the registrar says “wait” (its cache is full or overloaded),
    sleep for the time written in the ticket `ticket.t_wait_for`(but not more than `E`).
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
        belongs to this same advertisement and that the `ad` is still not already in the `ad_cache`.
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
    In this case registrar does not store `ad` but instead issues a ticket.
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
Each time an advertiser tries to register,
the registrar recalculates a new waiting time based on its current cache state.
The remaining time `t_remaining` is then computed as the difference between
the new waiting time and the time the advertiser has already waited, as recorded in the ticket.
With every retry, the advertiser accumulates waiting time and will eventually be admitted.
However, if the advertiser misses its registration window or fails to include the last ticket,
it loses all accumulated waiting time and must restart the registration process from the beginning.
Implementations must consider these factors while deciding the registration window `δ` time.

This design lets registrars prioritize advertisers that have waited longer
without keeping any per-request state before the `ad` is admitted to the cache.
Because waiting times are recalculated and tickets are stored only on the advertiser’s side,
the registrar is protected from memory exhaustion
and DoS attacks caused by inactive or malicious advertisers.
