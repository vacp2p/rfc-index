# RLN-MEMBERSHIP-MANAGEMENT

| Field | Value |
| --- | --- |
| Name | RLN Membership Management Module |
| Status | raw |
| Category | Standards Track |
| Tags | rln |
| Editor | Arseniy Klempner <arseniyk@status.im> |
| Contributors | |

## Abstract

This specification defines the RLN Membership Management Module,
a component that provides a registry-agnostic API for registering,
storing, and loading RLN memberships on behalf of consuming services.
The module supports multiple membership registries deployed across
heterogeneous execution environments,
multiple memberships per registry,
and multiple applications consuming those memberships concurrently.
Registries are identified using
[CAIP-10](https://standards.chainagnostic.org/CAIPs/caip-10) account identifiers,
and applications are identified by their `rln_identifier`.

## Background and Motivation

The Rate Limiting Nullifier (RLN) protocol,
as specified in [32/RLN-V1](../draft/32/rln-v1.md) and
[RLN-V2](rln-v2.md),
requires users to register an `identity_commitment` in a membership set
before participating in rate-limited anonymous signaling.
Existing specifications describe the membership set as a smart contract
deployed on an EVM-compatible blockchain
(see [WAKU2-RLN-CONTRACT](../../messaging/core/raw/rln-contract.md)).
However, membership registries now exist,
and will continue to appear,
in other languages and execution environments.
A component that manages memberships on behalf of consuming services
therefore requires an API that is agnostic
to the registry implementation and its host network.

Additionally, a single node may host multiple services,
each participating in one or more RLN applications,
backed by one or more memberships across one or more registries.
Existing specifications,
such as [WAKU-RLN-KEYSTORE](../../messaging/application/raw/rln-keystore.md),
identify a registry using EVM-specific constructs
(`chainId` per [EIP-155](https://eips.ethereum.org/EIPS/eip-155)
and a contract address),
and do not define how a consumer selects among multiple memberships.
This specification generalizes registry identification and
defines the data structures and functions required
to manage memberships in all of the following configurations:

| Case | Registries | Memberships | Applications |
| --- | --- | --- | --- |
| 1 | single | single | single |
| 2 | single | multiple | single |
| 3 | single | single | multiple |
| 4 | multiple | multiple | multiple |

In case 4, more granular configurations are possible,
e.g., one membership in one registry serves multiple applications,
while a set of memberships in a different registry
all serve a single application.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in
[RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### Terminology

- **Registry**: a membership set instance,
e.g., a smart contract on an EVM chain,
a program on a non-EVM chain,
or any other service maintaining an RLN membership Merkle tree.
- **Application**: a network or protocol deployment
that verifies RLN proofs against a registry,
identified by an `rln_identifier` as defined in
[32/RLN-V1](../draft/32/rln-v1.md).
- **Consumer**: a service that calls the module API,
e.g., a relay node implementing
[17/WAKU2-RLN-RELAY](../../messaging/core/draft/17/rln-relay.md),
a mix node, or a light client.
- **Registry provider**: an implementation-specific adapter
through which the module interacts with one class of registries.

It is assumed that each application uses exactly one registry instance
and exactly one `rln_identifier`.

### Registry Identification

A registry MUST be identified by a `registry_id`,
a [CAIP-10](https://standards.chainagnostic.org/CAIPs/caip-10)
account identifier of the form:

```text
registry_id:        chain_id + ":" + account_address
chain_id:           namespace + ":" + reference   (CAIP-2)
```

Examples:

```text
eip155:59144:0xB9cd878C90E49F797B4431fBF4fb333108CB90e6
logos:testnet:8f3a2b1c4d5e6f708192a3b4c5d6e7f8a9b0c1d2e3f4a5b6c7d8e9f0a1b2c3d4
```

The `namespace` component determines the address format of
the `account_address` component.
Namespaces are not limited to blockchains;
any execution environment hosting a registry MAY define a namespace,
subject to the CAIP-2 syntax constraints.

The `registry_id` MUST uniquely identify a single registry instance.
Because a registry deployment typically comprises several
addressable objects
(e.g., the program or contract, configuration accounts, tree accounts),
each namespace binding MUST define which single account
anchors a registry instance.
The anchor SHOULD be the account from which all other objects
of the registry can be resolved,
e.g., the contract address for smart-contract registries,
or the configuration account for registries whose remaining accounts
are derived from it.

Each namespace binding MUST also define one canonical textual form
for its `account_address`, including letter case.
The `registry_id` is an input to the `membership_hash`
(see [Membership](#membership)) and
is compared as an opaque string,
so implementations MUST canonicalize a `registry_id`
before comparing or hashing it and
MUST NOT require the ability to parse the `account_address`
of namespaces they do not support.

### Application Identification

An application MUST be identified by an `rln_identifier`,
a random value from a finite field, unique per RLN application,
as defined in [32/RLN-V1](../draft/32/rln-v1.md).
It is represented as a 32-byte value.

### Membership Scope

Because `rln_identifier` is only unique by convention,
and a registry may serve multiple applications,
every API request made on behalf of an application
MUST carry a `MembershipScope`:

```text
MembershipScope {
    registry_id:      string      // CAIP-10 account identifier
    rln_identifier:   bytes32     // application identifier
}
```

A `MembershipScope` uniquely identifies one application on one registry.
The module does not maintain a mapping of applications to registries;
the consumer, which is typically the application-related code,
is the authority on which registry its application uses and
provides both values with each request.

### Data Structures

#### IdentityCredential

The identity credential as defined in
[32/RLN-V1](../draft/32/rln-v1.md):

```text
IdentityCredential {
    identity_trapdoor:      bytes32
    identity_nullifier:     bytes32
    identity_secret_hash:   bytes32    // poseidon([identity_trapdoor, identity_nullifier])
    identity_commitment:    bytes32    // poseidon([identity_secret_hash])
}
```

Credential generation is the consumer's responsibility;
the module does not provide a generation function.
Consumers MUST generate credentials
from a cryptographically secure random source or
derive them deterministically from an existing key.
Interoperating consumers MUST use the same derivation scheme;
the RECOMMENDED scheme is `extended_seeded_keygen`
as specified in [ZEROKIT-API](zerokit-api.md).

#### MembershipState

The registry-agnostic lifecycle state of a membership.
It is a superset of the states defined in
[WAKU2-RLN-CONTRACT](../../messaging/core/raw/rln-contract.md);
a given registry class typically reports only a subset.

```text
enum MembershipState {
    Pending                    // submitted, not yet confirmed by the registry
    Failed                     // observed absent after the confirmation window
    Active
    GracePeriod
    Expired
    ErasedAwaitsWithdrawal
    Erased
    Unknown                    // not present in the registry
}
```

`Pending` and `Failed` are module-local states:
acceptance of a registration submission confirms
that the registry received it,
not that it was applied.
A membership MUST NOT remain `Pending` indefinitely;
implementations MUST bound `Pending` with a confirmation window,
after which a membership observed absent from the registry
MUST be reported as `Failed`
(see [Registration](#registration) for the exact rule).
Re-registering a `Failed` membership is safe
because registration is idempotent
(see [Registration](#registration)).

A membership MAY leave the membership set involuntarily:
registries MAY implement slashing,
which removes the leaf and
publicly reveals the identity secret
(see [32/RLN-V1](../draft/32/rln-v1.md)),
so on such registries an `Active` membership
can disappear at any time.
Some registries erase all membership record on removal,
making `Erased` indistinguishable from never-registered
in a raw registry read;
the module compensates by inferring erasure
from its stored records
(see [Registration](#registration)).
Consumers MUST stop generating proofs with a membership
reported as `Erased` or `Unknown`.

#### Membership

```text
Membership {
    membership_hash:    string             // unique local identifier, see below
    registry_id:        string             // CAIP-10 account identifier
    credential:         IdentityCredential
    rate_limit:         uint64             // messages per epoch; provisional while Pending
    leaf_index:         uint64             // position in the Merkle tree; provisional while Pending
    state:              MembershipState
}
```

A membership MUST belong to exactly one registry.
A membership carries no application association:
it MAY be used by any application whose scope
references the membership's registry,
and multiple memberships MAY serve the same application.
Which membership an application uses is resolved per request
(see [Membership Selection](#membership-selection)).

While a membership is `Pending`,
`leaf_index` and `rate_limit` are provisional:
the registry assigns the leaf position when
the registration is applied,
and concurrent registrations may cause it to differ
from the value estimated at submission time.
Implementations MUST re-read both fields from the registry
when the membership becomes `Active`.

The `membership_hash` MUST satisfy the following constraints:

- it MUST be derived deterministically from
the canonical `registry_id` and
`credential.identity_commitment`, and from nothing else —
in particular, not from provisional values such as `leaf_index`;
- implementations sharing a storage backend MUST use
the same construction.

A reference construction is given in
[Appendix B](#appendix-b-reference-membership-hash-construction).

#### MerkleProof

```text
MerkleProof {
    leaf_index:      uint64
    leaf:            bytes32     // rate commitment, see below
    root:            bytes32     // root of the snapshot the proof was taken from
    path_elements:   []bytes32
    path_indices:    []uint8
    valid_roots:     []bytes32   // valid root set of the same snapshot
}
```

The `leaf` is the rate commitment
`poseidon(identity_commitment, rate_limit)`,
as defined by the RLN-Diff registration method of
[RLN-V2](rln-v2.md);
it is included so that consumers need not know
the leaf construction to verify or use the proof.
The tree depth is implied by the length of `path_elements`;
provider wire formats that carry an explicit depth field
MUST be consistent with it.

All fields of a `MerkleProof` MUST be derived
from a single consistent snapshot of the registry's tree:
a proof whose `root` is fetched separately
from the valid root set may already have rotated out of it.
Implementations SHOULD retry snapshot acquisition
when the tree changes mid-read.

### Functions

All functions returning `Result<T>` MUST report failures
with an implementation-defined error type
distinguishing at least:

- unknown registry: no provider for the namespace;
- unknown membership;
- no usable membership: empty candidate set for a scope;
- ambiguous selection: multiple candidates and no `Selector`;
- storage locked (see [Storage Backend](#storage-backend));
- registry provider failure.

#### Registration

```text
register(
    registry_id:    string,
    credential:     IdentityCredential,
    rate_limit:     uint64,
    options:        RegisterOptions
) -> Result<Membership>
```

Submits a registration to the registry identified by `registry_id`
via the corresponding registry provider.
Only `credential.identity_commitment` is transmitted to the registry;
the module retains the full credential
so that the resulting membership can be stored and
later resolved for proof generation
(see [Membership Selection](#membership-selection)).
Registration on most registries is asynchronous;
for a newly submitted registration
the returned `Membership` MUST have `state = Pending`
until the registration is confirmed,
and consumers MUST NOT generate proofs with a `Pending` membership.
Confirmation MUST be established by reading the membership
back from the registry,
not by acceptance of the submission.
The transition to `Failed` MUST be based on
a successful registry read
observing the membership's absence
after the confirmation window has elapsed;
inability to reach the registry is not such an observation,
and the membership MUST remain `Pending`
while the registry cannot be read
(see [MembershipState](#membershipstate)).
The confirmation window SHOULD comfortably exceed
the registry's typical confirmation latency.
Registration MAY also fail terminally on registry-imposed bounds,
e.g., a rate limit outside the registry's accepted range or
exhausted total rate-limit capacity.

Registration MUST be idempotent with respect to
`(registry_id, credential.identity_commitment)`:
if the commitment is already registered,
the function MUST return the existing membership
rather than fail or double-register.
In that case the returned membership reflects
the existing registration,
and its `rate_limit` MAY differ from the requested value;
implementations SHOULD surface the mismatch to the consumer.

`RegisterOptions` is an implementation-defined structure carrying
registry-specific parameters,
e.g., the funding account, token approvals, or gas configuration.

```text
get_membership_state(
    registry_id:            string,
    identity_commitment:    bytes32
) -> Result<MembershipState>
```

Returns the merged view of a membership's state:
the state reported by the registry —
any state except the module-local `Pending` and `Failed`;
record-keeping registries MAY report
`Erased` and `ErasedAwaitsWithdrawal` directly,
while registries that erase records report absence as `Unknown` —
overlaid on the module's local records,
so that a submission the registry does not yet know about
is reported as `Pending` or `Failed` rather than `Unknown`.
Symmetrically, a membership the module has previously observed
in the membership set
(`Active`, `GracePeriod`, or `Expired`)
that the registry no longer reports
MUST be reported as `Erased` rather than `Unknown`.
Consumers SHOULD poll this function or
subscribe to membership updates
(see [Proof Support Data](#proof-support-data))
to detect the `Pending` to `Active` transition and
involuntary removal.

#### Membership Access

```text
get_memberships(registry_id: string) -> Result<[]Membership>
```

Returns all memberships managed by the module
for the registry identified by `registry_id`,
in any state, including `Pending` and `Failed`;
filtering usable memberships is the role of `select`.
A `Failed` membership SHOULD remain visible
until a re-registration replaces it,
so that consumers can observe and act on the failure.
Persistence of memberships is handled by the storage backend
(see [Storage Backend](#storage-backend)).

#### Membership Selection

```text
select(
    scope:             MembershipScope,
    selector:          OPTIONAL Selector,
    include_expired:   OPTIONAL bool      // default false
) -> Result<Membership>
```

Resolves the membership a consumer should use
for proof generation within `scope`.
The candidate set consists of all memberships
whose `registry_id` equals `scope.registry_id` and
whose state is `Active` or `GracePeriod`.
`Pending`, `Failed`, `Unknown`, `Erased`, and
`ErasedAwaitsWithdrawal` memberships
MUST NOT be selected.
`Expired` memberships are excluded
unless `include_expired` is set:
although the leaf remains in the tree and
proofs against it still verify,
erasing an `Expired` membership is typically permissionless,
so it can vanish mid-use.
The `scope.rln_identifier` does not filter the candidate set;
it partitions the state of stateful strategies (see below).
When the candidate set contains exactly one membership,
that membership MUST be returned.
When it contains multiple memberships,
the module MUST apply the provided `Selector`,
which is one of:

```text
Selector =
    | ByHash(membership_hash: string)     // explicit choice
    | ByStrategy(strategy: Strategy)      // module chooses

enum Strategy {
    HighestRateLimit
    RoundRobin
}
```

`ByHash` resolves within the candidate set;
implementations SHOULD distinguish
a membership that does not exist
from one that exists but is not in a usable state.
If the candidate set contains multiple memberships and
no `Selector` is provided,
the module MUST return an error rather than choose silently.
Stateful strategies such as `RoundRobin` MUST keep their state
per `MembershipScope`,
so that applications sharing a registry rotate independently.
Candidate filtering MAY rely on cached membership state;
implementations SHOULD bound the staleness of that cache.

#### Proof Support Data

```text
get_merkle_proof(registry_id: string, leaf_index: uint64) -> Result<MerkleProof>
get_valid_roots(registry_id: string) -> Result<[]bytes32>
```

Return the Merkle inclusion proof for a membership leaf and
the set of currently valid Merkle roots, respectively,
as maintained by the registry identified by `registry_id`.
These functions proxy to the corresponding registry provider and
exist so that consumers need not interact
with registry implementations directly.
`get_valid_roots` deliberately overlaps with
`MerkleProof.valid_roots`:
the standalone call refreshes the root window
without recomputing a proof.

Root freshness is correctness-critical:
verifiers accept a proof only if it was generated against a root
in their bounded window of recent roots,
so on an actively growing tree
roots age out within seconds to minutes,
and a consumer holding stale data
produces proofs that are rejected at send time.
Polling alone is therefore insufficient for active trees,
and implementations SHOULD additionally provide
a subscription surface:

```text
subscribe_valid_roots(registry_id: string)
    -> Result<Subscription<[]bytes32>>
subscribe_merkle_proof(registry_id: string, leaf_index: uint64)
    -> Result<Subscription<MerkleProof>>
```

A subscription delivers the current value upon establishment and
a new value whenever the underlying tree changes,
each `MerkleProof` satisfying the single-snapshot requirement of
[MerkleProof](#merkleproof).
The delivery mechanism
(callback, event stream, periodic re-broadcast)
is implementation-defined.

### Registry Provider Interface

Support for a class of registries is added to the module
by implementing a registry provider.
The module MUST route each provider-backed API call
to the provider registered for the namespace
of the request's `registry_id`.
Membership access operates on the module's local records:
`get_memberships` MUST NOT require a provider
for the namespace,
so that stored memberships remain auditable
after a provider is removed.
A registry provider MUST implement:

```text
register(registry_id: string, identity_commitment: bytes32,
         rate_limit: uint64, options: RegisterOptions)
    -> Result<{leaf_index: uint64, already_registered: bool}>
get_membership(registry_id: string, identity_commitment: bytes32)
    -> Result<{state: MembershipState, leaf_index: uint64, rate_limit: uint64}>
get_merkle_proof(registry_id: string, leaf_index: uint64)
    -> Result<MerkleProof>
get_valid_roots(registry_id: string) -> Result<[]bytes32>
```

A provider serves every registry of its namespace,
so each call carries the `registry_id`,
which the provider parses according to its namespace binding.
The `leaf_index` returned by `register` is
the provisional estimate described in [Membership](#membership).

`get_merkle_proof` and `get_valid_roots` MAY be implemented
as batch operations underneath,
provided each returned `MerkleProof` satisfies
the single-snapshot requirement.

A provider MAY deduplicate registration submissions
per `(registry_id, identity_commitment)`
while one is in flight,
but MUST bound the deduplication
so that a membership reported `Failed` can be re-submitted;
unbounded deduplication silently turns re-registration
into a replay of the stale first reply.

A registry provider SHOULD additionally notify the module
when the tree or the valid root set changes,
to serve the subscription surface of
[Proof Support Data](#proof-support-data);
where the underlying registry offers no push mechanism,
the provider MAY poll internally.

A registry provider SHOULD expose the registry-declared parameters
that bound registration,
e.g., the minimum and maximum rate limit per membership,
the total rate-limit capacity, and pricing,
so that the module can reject out-of-bounds requests
before submission.

A registry provider need not submit registrations
to the registry's host network itself.
The `register` operation MAY instead be fulfilled
by acting as a client of the RLN Membership Allocation Protocol
([RLN-MEMBERSHIP-SERVICE](rln-membership-service.md)):
the provider sends a `MembershipAllocationRequest` carrying
the `identity_commitment` and `rate_limit`
to a membership provider,
which registers the commitment in the registry
on the module's behalf.
This suits consumers that lack funds on the host network or
direct access to a node.
Delegated registration remains asynchronous:
the membership MUST stay `Pending`
until it is observed in the registry,
and the read operations
(`get_membership`, `get_merkle_proof`, `get_valid_roots`)
still require a data path to the registry.

A registry provider MAY additionally implement
lifecycle operations defined by its registry,
e.g., `extend`, `erase`, `withdraw`, and `slash` as specified in
[WAKU2-RLN-CONTRACT](../../messaging/core/raw/rln-contract.md) and
[32/RLN-V1](../draft/32/rln-v1.md).
The module MUST surface unsupported operations
as a distinguishable error rather than a silent no-op.

### Storage Backend

Just as registry interaction is pluggable via registry providers,
the storage backend used to persist memberships is pluggable.
A storage backend SHOULD be keystore-style:
memberships stored as credentials
encrypted under a key derived from a user-supplied password and
keyed by their `membership_hash`,
following [WAKU-RLN-KEYSTORE](../../messaging/application/raw/rln-keystore.md)
with the `membershipHash` construction generalized
as described in [Membership](#membership).
The medium holding the keystore,
e.g., a file on disk or a database record,
is implementation-defined.
The crypto envelope follows the referenced format
as pinned by its test vector:
PBKDF2-HMAC-SHA256 key derivation,
AES-128-CTR encryption keyed with `dk[0..16]`, and
`mac = keccak256(dk[16..32] || ciphertext)`.

The password-derived key implies an unlock step:
implementations MAY require an explicit unlock
(supplying the password)
before operations that write or release credentials,
e.g., `register` and `select`;
operations touching only non-secret metadata,
e.g., `get_memberships` and `get_membership_state`,
SHOULD NOT require it.
Note that a keystore holding zero credentials
offers no material to verify a password against:
any password appears to unlock it and
becomes the encryption password for the next write.

Any backend MUST satisfy the following requirements:

- Identity secrets MUST be encrypted at rest.
- When the encryption key is derived from a password,
the derivation MUST use a key derivation function
suitable for password hashing,
e.g., PBKDF2 as described in
[RFC 2898](https://www.ietf.org/rfc/rfc2898.txt).
- Tampering with stored credentials MUST be detectable
before their contents are used.
- The backend MUST NOT expose plaintext identity secrets
to anything other than the module holding the decryption key;
releasing a credential further, e.g., to a consumer via `select`,
is the module's decision, not the backend's.

### Configuration Case Mapping

The structures above cover the enumerated configurations as follows:

| Case | Representation |
| --- | --- |
| single registry, single membership, single app | one `Membership`; `select` is trivial |
| single registry, multiple memberships, single app | multiple `Membership` records in one registry; the application disambiguates via `Selector` |
| single registry, single membership, multiple apps | one `Membership`; each application presents its own `rln_identifier` in the `MembershipScope` |
| multiple registries, multiple memberships, multiple apps | union of the above; the `registry_id` in every `MembershipScope` partitions memberships per registry |

## Security and Privacy Considerations

### Concurrent use of a shared membership

When multiple consumers use the same membership
for the same application concurrently,
they share a single rate limit and a single `identity_secret_hash`.
If two consumers emit messages with the same `message_id`
within the same epoch,
the resulting Shamir shares reveal the identity secret
(see [RLN-V2](rln-v2.md)),
which on registries implementing slashing
leads to the membership being erased and
the credential publicly burned.
Implementations that permit shared memberships
MUST coordinate `message_id` allocation across consumers.
The RECOMMENDED mechanism is static partitioning of
the `[1, rate_limit]` `message_id` range among consumers
(the upper bound is called `user_message_limit` in
[RLN-V2](rln-v2.md)),
as it requires no runtime coordination;
alternatively, implementations MUST restrict a membership
to one consumer at a time.

### Credential reuse across applications

Using one membership across multiple applications is safe
only because each application's `rln_identifier` is mixed
into the `external_nullifier`
(see [32/RLN-V1](../draft/32/rln-v1.md)).
Application developers MUST ensure their `rln_identifier` is
unique and not copied from another application.

### Registry trust

The module trusts registry providers for Merkle roots and proofs.
A malicious provider can equivocate about membership state.
Consumers with stronger trust requirements SHOULD
verify roots against the registry directly,
e.g., by running a node for the host network.
Requesting proofs through third-party RPC providers
may link a consumer's network identity to its membership
(see [WAKU2-RLN-CONTRACT](../../messaging/core/raw/rln-contract.md)).

### Storage

Identity secrets MUST only be held in memory while in use.
The requirements of [Storage Backend](#storage-backend) apply
regardless of the medium holding the keystore.
Because proof generation takes place in the consumer,
`select` necessarily returns plaintext credentials
across the module boundary;
consumers MUST apply the same in-memory handling
to credentials they receive.
The security considerations of
[WAKU-RLN-KEYSTORE](../../messaging/application/raw/rln-keystore.md)
additionally apply.

## Appendix A: The `logos` Namespace Binding

This appendix provides the namespace binding required by
[Registry Identification](#registry-identification)
for registries hosted on Logos execution environments.

- **Namespace**: `logos`.
- **Reference**: the network name,
pinned to lowercase (e.g., `testnet`, `local`).
References are compared opaquely,
so without pinned casing
`logos:Testnet:…` and `logos:testnet:…`
would identify distinct registries
with distinct `membership_hash`es,
silently fragmenting stored memberships.
- **Anchor account**: the registration program's
configuration account,
i.e., the account from which every other object of the registry
(tree main account, subtree accounts,
membership accounts, treasury)
is derived.
- **Canonical `account_address` form**:
64 lowercase hexadecimal characters, without prefix.
- **`RegisterOptions`**: `funding_holding_account_id` —
the token holding account paying
`rate_limit × price_per_unit` at registration.
- **Time base**: membership lifecycle state is derived from
the on-chain clock account (`CLOCK_50`),
which reports epoch milliseconds;
lifecycle durations (active state duration, grace period)
are interpreted in the same unit.

## Appendix B: Reference Membership Hash Construction

```text
membership_hash = lowercase_hex(
    SHA256(utf8(registry_id) || 0x00 || identity_commitment))
```

`registry_id` is in canonical form,
`0x00` is a single separator byte
(CAIP-10 identifiers cannot contain it), and
`identity_commitment` is its 32-byte little-endian representation.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [32/RLN-V1](../draft/32/rln-v1.md)
- [RLN-V2](rln-v2.md)
- [17/WAKU2-RLN-RELAY](../../messaging/core/draft/17/rln-relay.md)
- [WAKU2-RLN-CONTRACT](../../messaging/core/raw/rln-contract.md)
- [WAKU-RLN-KEYSTORE](../../messaging/application/raw/rln-keystore.md)
- [RLN-MEMBERSHIP-SERVICE](rln-membership-service.md)
- [ZEROKIT-API](zerokit-api.md)
- [CAIP-2](https://standards.chainagnostic.org/CAIPs/caip-2)
- [CAIP-10](https://standards.chainagnostic.org/CAIPs/caip-10)
- [EIP-155](https://eips.ethereum.org/EIPS/eip-155)
- [RFC 2898](https://www.ietf.org/rfc/rfc2898.txt)
