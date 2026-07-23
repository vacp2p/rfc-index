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
| Scope | The context a call operates on — a registry and an application: `registry_id` + `rln_identifier` (`MembershipScope`). |
| Identity commitment | The public value derived from an identity credential ([RLN](https://lip.logos.co/anoncomms/raw/rln-v2.html)); the only credential-derived value that appears in the registry. |
| Rate commitment | `poseidon(identity_commitment, rate_limit)` — a registry tree leaf. |
| Direct registration | The Module registers a membership itself, from a funded account. |
| Delegated registration | The Module registers on a client's behalf as a participant in the [RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html). |

## API design

### The Module

An instance of the Module serves the registries selected by its configuration;
every call names the registry and application context it operates on
through a `MembershipScope`,
with a default scope configured at start.
It exposes two portions:

- **Membership management** — registration and membership state:
  the Module generates the identity credential,
  registers its rate commitment,
  persists it,
  and tracks the membership's lifecycle in the registry.
- **Rate limiting** — proof generation and verification
  over state the Module maintains itself:
  the current epoch, message-id allocation,
  the membership's Merkle proof path, and the valid-root window.

The consumer supplies only scopes, signals, and proofs.
Registry access and payment — the latter via an accounts module beneath the Module —
are internal to the Module and out of scope here.
Identity credentials never leave the Module:
they are generated at registration, persisted encrypted,
and used only inside proof generation.

## Type definitions

```c

typedef struct { const uint8_t* ptr; size_t len; } Bytes;

// The minimum set of conditions an error result MUST distinguish.
typedef enum {
    RLN_ERR_NOT_READY,         // Module cannot serve this yet; retry once ready
    RLN_ERR_TRANSIENT,         // e.g. registry/RPC failure; the caller MAY retry
    RLN_ERR_BUDGET_EXHAUSTED,  // the epoch's rate limit is spent; retry next epoch
    RLN_ERR_PERMANENT          // e.g. invalid input; retrying cannot succeed
} RlnErrorKind;

// Everything a call operates on: the registry and the application context.
// A default scope is set at start(); every function accepts an explicit scope.
typedef struct {
    const char* registry_id;         // CAIP-10 account identifier, canonicalized,
                                     // e.g. "eip155:59144:0xb9cd..."
    uint8_t     rln_identifier[32];  // per-application identifier, mixed into
                                     // the external nullifier
} MembershipScope;

// Open registration options; recognized keys are registry-specific,
// e.g. selecting delegated registration through an allocation service.
typedef struct { const char* key; const char* value; } RegistryOption;
typedef struct { const RegistryOption* ptr; size_t len; } RegistryOptions;

typedef enum {
    MEMBERSHIP_UNKNOWN,                   // not present in the registry
    MEMBERSHIP_PENDING,                   // submitted, not yet confirmed by the registry
    MEMBERSHIP_FAILED,                    // observed absent after the confirmation window
    MEMBERSHIP_ACTIVE,                    // confirmed and within its validity period
    MEMBERSHIP_GRACE_PERIOD,              // still usable, but approaching expiry
    MEMBERSHIP_EXPIRED,                   // validity period lapsed
    MEMBERSHIP_ERASED_AWAITS_WITHDRAWAL,  // removed; deposit still recoverable
    MEMBERSHIP_ERASED                     // removed; nothing left to recover
} MembershipStatus;

// Membership metadata. The identity credential backing it is generated,
// persisted, and used only inside the Module; it never crosses this interface.
typedef struct {
    const char* membership_hash;  // stable one-way local handle,
                                  // lowercase_hex(SHA256(registry_id || 0x00 || identity_commitment))
    uint64_t    rate_limit;       // messages per epoch; provisional while PENDING
    uint64_t    leaf_index;       // index of the rate commitment in the tree;
                                  // meaningful once ACTIVE
} Membership;

typedef struct {
    MembershipStatus status;
    Membership       membership;  // meaningful unless status is UNKNOWN
} MembershipState;

typedef struct {
    uint64_t epoch_size_sec;  // duration of one epoch in seconds
    uint64_t max_rate_limit;  // registry maximum; a Module MAY expose more parameters
} RegistryParameters;

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
A function called before the Module can serve it
SHALL fail with `RLN_ERR_NOT_READY`
rather than be served from a cold registry view.

### Lifecycle

#### `start()`

Start the Module with its configuration,
which selects the registries the instance serves
and a default `MembershipScope` for calls that do not pass one explicitly.
Starting establishes the registry connections,
loads persisted memberships (see [Persistence](#persistence)),
and starts the tasks that maintain the Module's local registry view:
the valid-root window, each membership's Merkle proof path, and each membership's state.
A membership is not required to start:
a Module started without one serves [`verify_proof`](#rate-limiting)
from its registry view alone.

#### `stop()`

Stop the Module and all its maintenance tasks.
In-flight requests SHALL be cancelled cleanly.

### Registration

#### `Membership register(MembershipScope scope, uint64_t rate_limit, RegistryOptions options)`

Generate a new identity credential inside the Module,
register a membership for it at the requested `rate_limit`,
and persist the credential and membership (see [Persistence](#persistence)).
A `rate_limit` above the registry's `max_rate_limit` SHALL fail as `RLN_ERR_PERMANENT`.
Only the rate commitment derived from the credential is submitted to the registry;
the credential itself never leaves the Module.
`options` carries registry-specific registration choices —
for example, selecting delegated registration through the
[RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html)
rather than direct registration from a funded account.

Registration is not instantaneous — on some registries confirmation takes minutes —
so the function SHALL return once the registration is submitted and durably persisted,
with the membership `PENDING`
and its `rate_limit` and `leaf_index` provisional.
Confirmation is observed through [`get_membership_state`](#registration),
which transitions to `ACTIVE` once the registration is confirmed in the registry,
or to `FAILED` if it is observed absent after the confirmation window.
A failed submission SHALL report whether it is retryable.

#### `MembershipState get_membership_state(MembershipScope scope)`

Return the status and metadata of the scope's membership,
whether registered in this run or loaded from persistence at `start()`.
The Module SHALL track the registry
so the reported status stays current through the full membership lifecycle;
`UNKNOWN` is returned when no membership exists for the scope.

### Persistence

The Module SHALL persist each membership it registers,
so that a membership registered before a restart is available after it
without registering again.
Persisted identity credentials SHALL be encrypted at rest.

## Rate limiting

The rate-limiting portion is the proof functions.
All RLN state they need —
the current epoch, message-id allocation within the rate limit,
the membership's Merkle proof path, and the valid-root window —
is maintained inside the Module;
the consumer supplies only the scope and the signal.
A membership is required only to generate proofs:
verification runs against the registry view alone,
so a consumer that only validates messages never registers.
Detecting double-signalling across messages
— recovering an identity secret from two proofs that share a nullifier within one epoch —
is the consumer's responsibility and is out of scope of these functions.

#### `RateLimitProof generate_proof(MembershipScope scope, Bytes signal)`

Generate an RLN proof that `signal` was produced by the holder of the scope's membership
within its rate limit for the current epoch.
The Module determines the epoch,
allocates the next unused `message_id` within the membership's `rate_limit`,
and binds the proof to the external nullifier `hash(epoch, rln_identifier)`.
The Module SHALL NOT issue two proofs for the same `(epoch, message_id)` pair:
doing so reveals the identity secret.
When the epoch's budget is exhausted,
the function SHALL fail with `RLN_ERR_BUDGET_EXHAUSTED`;
allocation resets at the next epoch.
The membership MUST be usable — `ACTIVE` or `GRACE_PERIOD` —
for proof generation to succeed.

#### `bool verify_proof(MembershipScope scope, Bytes signal, RateLimitProof proof)`

Verify an RLN proof for `signal`.
Returns `true` only if the proof is valid and
`proof.root` is within the Module's current valid-root window.
Verification is on the message hot path —
it runs for every message a validator receives —
so the Module SHALL serve it from its locally maintained registry state
and SHALL NOT perform registry access on the verification path.
The valid-root window is maintained asynchronously as the registry changes,
and SHOULD be maintained timely enough
that a proof generated against a newly published root is not falsely rejected.

## Optional extensions

A Module MAY additionally provide any of the following;
the consumer MUST NOT require them and
SHALL treat their absence as an unsupported operation failing with `RLN_ERR_PERMANENT`.

- **Multiple memberships** —
  holding more than one membership for a scope.
  A Module that does so MUST require the consumer to select one explicitly —
  for example by `membership_hash` —
  and MUST NOT choose silently among candidates.
- **Credential export** —
  exporting a persisted membership (see [Persistence](#persistence))
  per [RLN-KEYSTORE](rln-keystore.md),
  making credential files portable across implementations.
  Export is the only operation through which a credential crosses this interface;
  a consumer that invokes it takes custody of the identity secrets.
- **Slot reclamation** —
  returning a message-id allocation to the epoch's budget
  when a proof was generated but its message was never published.
- **Quota and parameters read** —
  exposing the registry's `RegistryParameters`
  and the membership's remaining budget in the current epoch,
  for consumer-side send scheduling.
- **Membership state subscriptions** —
  change notifications for the membership lifecycle,
  sparing the consumer polling [`get_membership_state`](#registration).
- **Withdrawal** —
  erasing a membership and recovering its deposit, where the registry supports it —
  the operation that resolves the `ERASED_AWAITS_WITHDRAWAL` state.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [MESSAGING-API](messaging-api.md)
- [RLN-KEYSTORE](rln-keystore.md)
- [RLN](https://lip.logos.co/anoncomms/raw/rln-v2.html)
- [RLN Membership Allocation Protocol](https://lip.logos.co/anoncomms/raw/rln-membership-service.html)
- [WAKU2-RLN-RELAY](https://lip.logos.co/messaging/draft/17/rln-relay.html)
- [OnchainGroupManager, logos-delivery](https://github.com/logos-messaging/logos-delivery/blob/master/logos_delivery/waku/rln/group_manager/on_chain/group_manager.nim)
