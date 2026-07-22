# RLN-API

| Field | Value |
| --- | --- |
| Name | RLN API definition |
| Status | raw |
| Category | application |
| Tags | rln, membership, spam-protection, application, api |
| Editor | Tanya Stubbs <tanya@status.im> |

## Abstract

This document specifies the interface a Logos Delivery node
([logos-messaging/logos-delivery](https://github.com/logos-messaging/logos-delivery))
requires of an external module in order to manage
[RLN](https://lip.logos.co/anoncomms/raw/rln-v2.html) memberships
and to perform RLN message validation.

RLN message validation is an optional feature of the Messaging API
([MESSAGING-API, The Validation API](messaging-api.md#the-validation-api)).
When it is enabled,
the node manages memberships through the Module
and generates and verifies proofs with functions the Module provides.
The interface is registry-agnostic,
so a single specification serves every deployment.

## Motivation

[MESSAGING-API](messaging-api.md) already models RLN as message validation,
configured through an EVM-specific `RlnConfig`.
Supporting memberships that live in different registries,
acquired in different ways,
means generalizing that configuration and
delegating the registry-specific work to a module Logos Delivery does not itself implement.

This document defines what that module SHALL expose, so that:

- the registry backing a deployment is selected by configuration, not by code;
- Logos Delivery manages memberships and generates and verifies proofs through one stable interface,
  independent of how the module packages its internals;
- payment and account handling remain below the module, invisible to Logos Delivery.

## Semantic

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document
are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

## Terminology

| Term | Meaning |
| --- | --- |
| Module | The component implementing this interface. Exposes a membership-management portion and a rate-limiting portion. |
| Consumer | The component calling this interface. |
| Registry | A membership set — a Merkle tree of rate commitments — identified by a CAIP-10 `registry_id`. Internal registry access is the Module's concern. |
| `registry_id` | `<namespace>:<reference>:<account_address>`, e.g. `eip155:59144:0xb9cd…` or `logos:testnet:<64 lowercase hex>`. MUST be canonicalized before comparison or hashing. |
| `rln_identifier` | A 32-byte per-application identifier ([32/RLN-V1](https://github.com/logos-co/logos-lips/blob/master/docs/anoncomms/draft/32/rln-v1.md)), mixed into the external nullifier so one membership can serve several applications. |
| Rate commitment | `poseidon(identity_commitment, rate_limit)` — a registry tree leaf. |
| Direct registration | The Module registers a membership itself, from a funded account. |
| Delegated registration | The Module registers on a client's behalf as a participant in the [RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html). |

## API design

### The Module

An instance of the Module serves a single registry,
selected at configuration time by its `registry_id`;
no function in the required interface is registry-specific.
It exposes two portions:

- **Membership management** — credential generation,
  membership registration,
  membership persistence,
  a membership existence check,
  and registry reads: the membership's Merkle proof and the valid-root set.
- **Rate limiting** — stateless proof generation and verification functions
  over a membership and a registry view supplied by the consumer.

The registry view — the membership's Merkle proof path and the window of valid roots —
is maintained inside the Module (fetched, cached, and refreshed as the tree changes)
and served to the consumer through the registry reads,
which feed the proof functions.
Registry access and payment — the latter via an accounts module beneath the Module —
are internal to the Module and out of scope here.
Identity secrets pass only between the Module and the consumer;
they are never submitted to the registry.

## Type definitions

```c

// CAIP-10 account identifier, canonicalized. e.g. "eip155:59144:0xb9cd..."
// Configuration-time only: selects the registry an instance serves.
typedef const char* RegistryId;

typedef struct { const uint8_t* ptr; size_t len; } Bytes;

// The minimum set of conditions an error result MUST distinguish.
typedef enum {
    RLN_ERR_NOT_READY,   // Module cannot serve this yet; retry once ready
    RLN_ERR_TRANSIENT,   // e.g. registry/RPC failure; the caller MAY retry
    RLN_ERR_PERMANENT    // e.g. invalid input; retrying cannot succeed
} RlnErrorKind;

typedef struct {
    uint8_t identity_trapdoor[32];
    uint8_t identity_nullifier[32];
    uint8_t identity_secret_hash[32];  // poseidon(trapdoor, nullifier)
    uint8_t identity_commitment[32];   // poseidon(secret_hash)
} IdentityCredential;

typedef struct {
    IdentityCredential credential;
    uint64_t           rate_limit;  // messages per epoch
    uint64_t           leaf_index;  // index of the rate commitment in the tree
} Membership;

typedef struct {
    uint32_t tree_depth;      // depth of the registry's Merkle tree
    uint64_t epoch_size_sec;  // duration of one epoch in seconds
    uint64_t max_rate_limit;  // registry maximum; a Module MAY expose more parameters
} RegistryParameters;

// All fields derived from a single consistent snapshot of the registry's tree.
typedef struct {
    uint64_t       leaf_index;
    uint8_t        leaf[32];        // rate commitment
    uint8_t        root[32];
    const uint8_t* path_elements;   // tree_depth * 32 bytes
    const uint8_t* path_indices;    // tree_depth bytes
} MerkleProof;

typedef struct {
    const uint8_t* roots;  // concatenated 32-byte roots
    size_t         len;    // number of roots
} RootSet;

typedef struct {
    uint8_t proof[128];              // zero-knowledge proof
    uint8_t root[32];                // root the proof was generated against
    uint8_t external_nullifier[32];  // hash(epoch, rln_identifier)
    uint8_t share_x[32];             // Shamir share of the identity secret
    uint8_t share_y[32];
    uint8_t nullifier[32];
} RateLimitProof;

```

## Required functions

The Module SHALL expose the functions in this section.

### Lifecycle

#### `start()`

Start the Module:
establish the connection to the configured registry,
load a persisted membership if one exists (see [Persistence](#persistence)),
and start the tasks that maintain the valid-root window and the cached Merkle proof path.

#### `stop()`

Stop the Module and all its maintenance tasks.
In-flight requests SHALL be cancelled cleanly.

#### `bool is_ready()`

Return `true` only once the Module can serve current registry reads —
in particular, once its valid-root window is warm.
A read requested before the Module is ready
SHALL fail as not-ready rather than be served from a cold window.

#### `RegistryParameters parameters()`

Return the registry's parameters.
Every validator of a shard MUST agree on these;
the consumer SHOULD validate them against its configuration at startup and refuse to proceed on mismatch.

### Credential generation

#### `IdentityCredential generate_credential()`

Generate a new identity credential using the Module's Zerokit key-generation primitive —
the same cryptography as the [rate-limiting portion](#rate-limiting).
The Module MAY also offer deterministic generation from caller-supplied entropy.

### Registration

#### `Membership register(IdentityCredential credential, uint64_t rate_limit)`

Register a membership for `credential` at the requested `rate_limit`,
and persist the resulting membership (see [Persistence](#persistence)).
Only the `identity_commitment` is submitted to the registry.

The function SHALL return only once the membership is confirmed in the registry —
for example, once the registration transaction is mined and its registration event observed —
with the confirmed `leaf_index` and `rate_limit`.
Registration is not instantaneous — on some registries it takes minutes —
so it MAY be long-running,
and the consumer MUST be able to await it without blocking a shared event loop.
A failed registration SHALL report whether it is retryable.

#### `bool is_member(uint8_t identity_commitment[32])`

Return whether `identity_commitment` is present in the registry's membership set.

### Persistence

The Module SHALL persist its membership,
so that a membership registered before a restart is available after it
without registering again.
Persisted identity secrets SHALL be encrypted at rest.

#### `Membership get_membership()`

Return the Module's membership,
from `register()` in this run or loaded from persistence at `start()`.

### Registry reads

#### `MerkleProof get_merkle_proof()`

Return the Merkle proof for the membership's leaf.
All fields MUST be derived from a single consistent snapshot of the registry's tree;
the Module SHOULD retry snapshot acquisition when the tree changes mid-read.

#### `RootSet get_valid_roots()`

Return the current valid-root window.
Root freshness is correctness-critical:
a verifier accepts a proof only if it was generated against a root in this window.

## Rate limiting

The rate-limiting portion is a set of stateless functions
over a membership and a registry view supplied by the consumer,
obtained through [`get_membership`](#persistence) and the [registry reads](#registry-reads).
Detecting double-signalling
— recovering an identity secret from two proofs that share a `message_id` within one epoch —
is the consumer's responsibility and is out of scope of these functions.

#### `RateLimitProof generate_proof(Membership membership, Bytes signal, MerkleProof merkle_proof, uint64_t epoch, uint64_t message_id, uint8_t rln_identifier[32])`

Generate an RLN proof that `signal` was produced by the holder of `membership`
within its rate limit for the epoch.
The function MUST fail permanently
unless `message_id` is within the membership's rate limit.
The proof is bound to the external nullifier `hash(epoch, rln_identifier)`.
A proof generated from a stale `merkle_proof` — one whose root has left the valid-root window —
is rejected by verifiers;
the consumer SHOULD refresh the proof path via [`get_merkle_proof`](#registry-reads) and retry.

#### `bool verify_proof(Bytes signal, RateLimitProof proof, RootSet valid_roots)`

Verify an RLN proof for `signal`.
Returns `true` only if the proof is valid and
`proof.root` is a member of `valid_roots`;
a proof whose root is absent — for example after root rotation — returns `false`.
The consumer SHOULD verify against freshly read roots,
so that a proof generated against a newer root is not falsely rejected.

## Optional extensions

A Module MAY additionally provide any of the following;
the consumer MUST NOT require them and
SHALL treat their absence as a permanent unsupported-operation error.

- **Delegated registration** —
  registering on a client's behalf through the
  [RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html)
  rather than from a funded account.
- **Multiple memberships** —
  holding more than one membership for the registry.
  A Module that does so MUST require the consumer to select one explicitly
  and MUST NOT choose silently among candidates.
- **Interoperable keystore format** —
  storing the persisted membership (see [Persistence](#persistence))
  per [RLN-KEYSTORE](rln-keystore.md),
  making credential files portable across implementations.
- **Registry subscriptions** —
  change notifications for the membership's Merkle proof or the valid-root set.
- **Withdrawal** —
  erasing a membership and recovering its deposit, where the registry supports it.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [MESSAGING-API](messaging-api.md)
- [RLN-KEYSTORE](rln-keystore.md)
- [RLN](https://lip.logos.co/anoncomms/raw/rln-v2.html)
- [RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html)
- [WAKU2-RLN-RELAY](https://lip.logos.co/messaging/draft/17/rln-relay.html)
- [OnchainGroupManager, logos-delivery](https://github.com/logos-messaging/logos-delivery/blob/master/logos_delivery/waku/rln/group_manager/on_chain/group_manager.nim)
