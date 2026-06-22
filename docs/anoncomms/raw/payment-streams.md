# PAYMENT-STREAMS

| Field | Value |
| --- | --- |
| Name | Payment Streams Protocol for Logos Services |
| Slug | 155 |
| Status | raw |
| Category | Standards Track |
| Editor | Sergei Tikhomirov <sergei@status.im> |
| Contributors | Akhil Peddireddy <akhil@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-05-11** — [`1ac7689`](https://github.com/logos-co/logos-lips/blob/1ac7689ee3fe1665d5d5d1bf9c180ed951cc660d/docs/anoncomms/raw/payment-streams.md) — chore: split ift ts specs (#334)
- **2026-03-18** — [`e07c655`](https://github.com/logos-co/logos-lips/blob/e07c655a1fb86b46c99c3dd164a29438ab093b49/docs/ift-ts/raw/payment-streams.md) — Chore: move and fix header for payment streams spec (#295)
- **2026-02-24** — [`14fd5c0`](https://github.com/logos-co/logos-lips/blob/14fd5c09ccb76cb36ebb6a4b6c8082850172d330/vac/raw/payment-streams.md) — docs: add payment streams raw spec (#224)

<!-- timeline:end -->

## Abstract

This document specifies a payment streams protocol in three layers:
on-chain payment streams,
stream-backed eligibility for request-response services,
and the LEZ and Logos Delivery profile.

The on-chain payment streams protocol defines generic vault and stream semantics.
Vaults hold deposits.
Streams accrue funds to providers over time.
The chain enforces allocation accounting and lazy accrual
(computing accrued balances when a stream is touched by an on-chain operation)
using a time signal.

Stream-backed eligibility for request-response services extends the
[incentivization specification](../../messaging/core/raw/incentivization.md)
with the `VaultProof`, `StreamProposal`, and `StreamProof` types.
Eligibility is the authorization to receive service.
This specification uses payment stream status as the eligibility criterion.
Providers advertise policy, negotiate parameters, and verify proofs against
on-chain state from the on-chain payment streams protocol.

The LEZ and Logos Delivery profile binds the protocol to the Logos Execution Zone (LEZ)
and the Logos Delivery Store query profile.
It maps abstract quantities to LEZ accounts and programs.
It records privacy tiers and wallet responsibilities.
It points to [Implementation Considerations](#implementation-considerations) for demo signing bytes.

Security and privacy properties are analyzed in a dedicated section.
Optional extensions are listed separately.

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
in this document are to be interpreted as described in
[RFC 2119](http://tools.ietf.org/html/rfc2119).

## Change Process

This document is governed by the [1/COSS](../../research/draft/1/coss.md) (COSS).

## Motivation

Logos is a privacy-focused tech stack that includes
Logos Messaging, Logos Blockchain, and Logos Storage.

Logos Messaging comprises a suite of communication protocols
with both P2P and request-response structures.
The backbone P2P protocols use tit-for-tat mechanisms.
Incentivization is introduced
for auxiliary request-response protocols
with well-defined user and provider roles.
One such protocol is Store,
which allows users to query historical messages
from Logos Messaging relay nodes.

Logos Blockchain includes the Logos Execution Zone (LEZ),
which enables both transparent and shielded execution.

We target the following requirements:

- Performance: Efficient payments with low latency and fees.
- Security: Limited loss exposure through spending controls.
- Privacy: On-chain deposit identity unlinkable to off-chain service requests.
- Extendability: Simple initial design with room for enhancements.

We propose using payment streams
(referred to simply as streams)
for paid request-response service.
Streams enable unidirectional time-based fund flows
from payer to payee.
Streams are simpler than alternatives
and map well to our use case.
Unlike alternatives (payment channels, e-cash),
stream parties avoid storing old states or initiating disputes,
and to not rely on a centralized mint entity.
Streams can be implemented on any smart-contract platform with a time signal.

This specification includes three main chapters.
First, we introduce an on-chain payment streams protocol.
Second, we define how it can be integrated
in a generic off-chain request-response protocol.
Third, we describe how the above protocol
maps onto Logos Execution Zone (LEZ)
and Logos Delivery Store as reference deployment.

## On-Chain Payment Streams Protocol

This section defines chain-agnostic on-chain semantics
of a payment streams protocol.

### Roles

The protocol has two roles:

- User: the party paying for services (payer).
- Provider: the party delivering services and receiving payment (payee).

The streams protocol does not have to be used in the user-provider context.
For consistency, throughout this document
we refer to the payer as the user, and to the payee as the provider.

### Vaults and streams

The protocol uses a two-level architecture
of vaults and streams.

A vault holds a user's deposit and backs multiple streams.
To start using the protocol,
the user MUST deposit funds into a vault.
A user MAY have multiple vaults.
One vault MAY back streams to different providers.

Let `balance` be the vault balance.
Let `total_allocated` be the sum of stored stream allocations for that vault.
`unallocated` is the portion of `balance` not committed to streams.
For each stream, `stream_allocation` is the stored allocation commitment.
`accrued` and `unaccrued` partition `stream_allocation`.

The following identities hold:

```text
balance = total_allocated + unallocated
stream_allocation = accrued + unaccrued
```

As balances are non-negative,
it MUST hold that `balance` ≥ `total_allocated` for any vault,
and that `stream_allocation` ≥ `accrued` for any stream.

Vault operations include:

- Initialize: create an empty vault.
- Deposit: increase `balance` and `unallocated`.
- Withdraw: decrease `balance` by at most `unallocated`.

A stream is an on-chain representation
of an individual payment flow of funds from a vault to one provider.
When creating a stream,
the user MUST allocate a portion of `unallocated` funds to that stream.
Each stream MUST belong to exactly one vault.
Each stream MUST specify an accrual rate (tokens per time unit).
The sum of all `stream_allocation` values for a vault MUST NOT exceed `balance`.

The user MAY withdraw unallocated funds from the vault at any time.

### Stream lifecycle

Accrual is the process by which funds of a given stream flow from the user to the provider.

State transition diagram:

```mermaid
graph LR;
    ACTIVE -->|pause / deplete| PAUSED;
    PAUSED -->|resume / top-up| ACTIVE;
    ACTIVE -->|close| CLOSED;
    PAUSED -->|close| CLOSED;
```

At any point in time, a stream MUST be in one of the following states:
`ACTIVE`, `PAUSED`, `CLOSED`.
Funds MUST accrue only if the stream is `ACTIVE`.
A `CLOSED` stream is permanently terminated
and MUST NOT transition to any other state.
The user creates a stream by setting `stream_allocation` and increasing `total_allocated`.
The user MAY pause an `ACTIVE` stream.
Pause stops accrual without changing `stream_allocation`.
The stream transitions automatically from `ACTIVE` to `PAUSED`
when allocated funds are fully accrued.
The user MAY resume a `PAUSED` stream.
Resume restarts accrual without changing `stream_allocation`.
Resume MUST fail if unaccrued balance is zero.
The user MAY top-up a stream.
Top-up increases `stream_allocation` and `total_allocated`.
Top-up MUST transition the stream to `ACTIVE` state.
To add funds and keep the stream `PAUSED`,
the user MUST pause the stream after top-up.
Either user or provider MAY close the stream from any non-`CLOSED` state.
Close releases unaccrued funds from `stream_allocation` back to `unallocated`.
When a stream is `CLOSED`,
unaccrued funds MUST automatically be transferred to the vault.
Accrued funds remain available for the provider to claim.
The provider MAY claim accrued funds from a stream at any time, in any state.
A claim MUST transfer the full accrued balance to the provider.
Closing a `CLOSED` stream is an error.

### Lazy accrual and folding

Stream state is a pure function of stored stream fields and the current timestamp.
Any party can compute the effective stream state
by reading on-chain stream state and a time signal locally.
However, stream state MAY be outdated on-chain.
To fold a stream means to update its accrued balance and state on-chain
based on the current timestamp.
Any on-chain operation that touches a stream MUST fold it before executing its main logic.
The blockchain MUST expose a time signal to be able to fold streams.

## Stream-Backed Eligibility for Request-Response Services

Stream-backed eligibility means a provider verifies service requests against
an on-chain payment stream and the proofs in this section.

This section defines how on-chain streams back service eligibility
in the incentivization request-response framework.
It uses protobuf for interchange.
It avoids Logos Delivery wire formats except where noted under
[LEZ and Logos Delivery Profile](#lez-and-logos-delivery-profile).

On-chain state is the source of truth for fund allocation and accrual.
Off-chain communication coordinates lifecycle events
and enables service delivery.

The service provision protocol remains defined elsewhere.
The incentivization specification
defines the generic request-response framework
with `EligibilityProof` and `EligibilityStatus`.
This specification extends `EligibilityProof`
with two new types for stream-backed service provision.

### Roles and service sessions

Stream-backed eligibility involves two roles:

- User: chooses stream parameters, signs proofs, opens and manages on-chain streams.
- Provider: serves paid requests, verifies stream-backed eligibility,
  and holds service session state.

A service session is the provider's off-chain record for delivering
service under one accepted `StreamProposal`.
The session begins when the provider accepts the proposal.
`PARAMS_REJECTED` exchanges before acceptance do not start a session.
`ServiceTermination` or dropped session state ends a session.

### Protocol phases

Verification is split into proposal, stream creation, and service.
Parameter negotiation and `PARAMS_REJECTED` retries are part of the
proposal phase rather than stream creation.

- Proposal — A vault-proof-backed `ServiceRequest` carries a
  `StreamProposal`.
  No stream exists on-chain yet.
- Stream creation — The user submits on-chain stream creation.
- Service — Later `ServiceRequest`s carry `StreamProof`.

### Wire encoding and signing requirements

Off-chain messages in this section use protobuf for interchange
between clients and providers.

Cryptographic commitments (`VaultProof.owner_signature`,
`StreamProof.signature`) MUST use a chain-specific canonical form.
Implementations MUST NOT sign raw protobuf-serialized message bytes unless
a chain integration explicitly specifies that scheme.

Each chain integration MUST define deterministic signed material for every
signature field this protocol uses and MUST publish test vectors for those
payloads.
Integrations MUST define how signed material covers the fields required by
VaultProof and StreamProof.
For LEZ, preimage bytes appear under Implementation Considerations.

### Eligibility Proof Types

The incentivization specification's `EligibilityProof`
is extended with two new optional fields:
`stream_proposal` and `stream_proof`.
These fields are mutually exclusive.
The first `ServiceRequest` MUST use `stream_proposal`.
Its semantics: "I want to open a stream to you
with these parameters.
Here is proof I have a vault to back it.
Here is my first request."
All subsequent requests MUST use `stream_proof`.

```protobuf
message EligibilityProof {
  // existing, from incentivization specification
  optional bytes proof_of_payment = 1;
  // new, for stream-backed service provision
  optional bytes stream_proposal = 2;
  optional bytes stream_proof = 3;
}
```

#### StreamParams

```protobuf
message StreamParams {
  bytes service_id = 1; // identifier of the requested service
  uint64 stream_rate = 2; // proposed accrual rate (tokens per time unit)
  uint64 stream_allocation = 3; // proposed initial allocation
  uint64 create_stream_deadline = 4; // latest create_stream time (absolute timestamp)
}
```

`StreamParams` holds the proposed stream fields for one
`StreamProposal`.
`VaultProof.owner_signature` covers these fields.

`create_stream_deadline` is the latest chain time for on-chain stream creation
in `StreamParams`.
The user MUST set it within `max_create_stream_deadline_delay`.
Create-stream deadline pairing is defined alongside `StreamProviderPolicy`.

#### VaultProof

A `VaultProof` proves that the user controls a vault
with sufficient unallocated funds
to back the proposed stream.

```protobuf
message VaultProof {
  bytes vault_id = 1; // on-chain identifier of the vault
  bytes provider_id = 2; // target provider (prevents replay)
  bytes owner_public_key = 3; // key used to verify owner_signature
  bytes owner_signature = 4; // signature over the proposal
}
```

The `owner_public_key` field identifies the key used to verify
`owner_signature`.
Chain-specific integrations MUST define how `owner_public_key`
maps or binds to the user identifier (the vault owner) stored on-chain.

The `owner_signature` field proves that the user authorizes
the proposed stream session.
It MUST cover at least the `VaultProof` fields
other than `owner_signature`,
the accompanying `StreamParams`,
and the `StreamProposal.public_key`.
This prevents a valid vault proof from being recombined
with different stream parameters or a different session key.

The exact owner-signature scheme,
public-key encoding,
and canonical signed payload are chain-specific integration details.
They MUST be deterministic and covered by test vectors.

The `provider_id` field is the provider identity used by this protocol.
It prevents replaying a `VaultProof` intended for one provider
against another provider.
It may differ from a chain-specific payee or account identifier.

Chain-specific integrations MUST define how `provider_id`
maps or binds to the on-chain payee identifier used by that chain.
For example, a chain integration MAY bind `provider_id`
to a long-lived service identity,
and separately bind that service identity
to the chain account that receives stream claims.
The binding mechanism is part of the chain-specific integration.

The user MAY issue `VaultProof`s to multiple providers.
The user MUST ensure that issuing a new `VaultProof`
does not cause the total of all promised `VaultProof` allocations
from this vault
to exceed the vault's unallocated balance.

#### StreamProposal

```protobuf
message StreamProposal {
  VaultProof vault_proof = 1;
  StreamParams stream_params = 2;
  bytes public_key = 3; // session key for signing subsequent service requests
}
```

#### StreamProof

A `StreamProof` links a request to an active on-chain stream.
It is signed by the session private key corresponding to
the `StreamProposal.public_key` accepted for that stream.

```protobuf
message StreamProof {
  bytes stream_id = 1; // on-chain identifier of the stream
  bytes signature = 2; // signature over request_data using committed public_key
}
```

### Message Types

The off-chain protocol uses three message types:
`ServiceRequest`, `ServiceResponse`, and `ServiceTermination`.

#### ServiceRequest

A `ServiceRequest` has two top-level fields,
consistent with the incentivization specification pattern:

- `request_data`: service-specific payload
- `eligibility_proof`: an `EligibilityProof`
  containing either a `stream_proposal` or a `stream_proof`

#### ServiceResponse

A `ServiceResponse` MUST include:

- `eligibility_status`: an `EligibilityStatus`
  (from the incentivization specification) with:
  - `status_code`: indicating acceptance,
    parameter rejection, proof invalidity, etc.
  - `status_desc`: human-readable description
    (RECOMMENDED to include actionable guidance
    on parameter rejection)
- `response_data`: service-specific payload
  (included if and only if the request is served)

Status codes specific to this specification:

- `OK`: request served
- `PARAMS_REJECTED`: stream parameters unacceptable.
  `VaultProof` NOT marked as spent.
  Spent status is provider session bookkeeping only.
  It is not an on-chain vault or stream field.
  User MAY retry with adjusted parameters
- `PROOF_INVALID`: `VaultProof` or `StreamProof` verification failed
- `STREAM_NOT_ACTIVE`: referenced stream
  is no longer active on-chain

The provider SHOULD limit parameter-rejection retries
to a RECOMMENDED maximum of 5 per vault
within a RECOMMENDED time window of 600 seconds.

#### ServiceTermination

The provider SHOULD send a `ServiceTermination` message
before stopping service.
This message MAY be sent at any point,
including before a stream is established on-chain.

This message MUST include:

- `termination_type`: `TEMPORARY` or `PERMANENT`
- `resume_after`: timestamp after which service MAY resume
  (REQUIRED for `TEMPORARY`, empty for `PERMANENT`)

For temporary termination,
the user MAY pause the stream until the `resume_after` time.
For permanent termination,
the user SHOULD close the stream to recover unaccrued funds.

##### Termination delivery

Semantically, `ServiceTermination` is a provider message indicating service
will stop.
On request-response transports, providers MAY carry the same termination
fields in `EligibilityStatus` within a `ServiceResponse` instead of a
standalone `ServiceTermination` message.

This suits request-response protocols where the provider cannot push messages.

Future versions MAY define a separate channel for negotiation
supporting heartbeats, parameter renegotiation, and proactive termination.
For now, no such channel exists.
All initiative comes from the user via `ServiceRequest`.

### StreamProviderPolicy

`StreamProviderPolicy` is the set of conditions the provider
advertises for proposing and operating a stream.

| Field | Role |
| --- | --- |
| `min_stream_rate` | The provider MUST reject proposals whose `StreamParams.stream_rate` is lower |
| `min_stream_allocation` | The provider MUST reject proposals whose `StreamParams.stream_allocation` is lower |
| `max_create_stream_deadline_delay` | Maximum seconds from proposal verification time until `create_stream_deadline` |
| `vault_proof_max_response_bytes` | The provider SHOULD limit the first vault-proof-backed `response_data` to this size (RECOMMENDED default: 65536) |

Implementations SHOULD expose:

- `proposal_satisfies_policy` in the proposal phase
- `stream_satisfies_policy` on every service request
- `new_stream_satisfies_proposal` on the first `StreamProof` for a
  service session (required on the first service request only)

The discovery specification defines how policy is advertised.
This specification defines fields and checks.

### Discovery Assumptions

Parties MUST agree on stream parameters before creation.
A separate discovery protocol SHOULD enable
providers to advertise services and payment-stream policy.

The provider SHOULD announce
accepted eligibility proof types, accepted assets,
and a `StreamProviderPolicy`
via the discovery protocol.
The user MUST read the provider's current discovery advertisement
immediately before building each `StreamProposal`.
The provider MUST verify each proposal against its
currently published `StreamProviderPolicy`.
A policy version or hash inside `StreamProposal`
is outside this specification.
Until discovery defines such a commitment,
the provider cannot know which past advertisement the user used.
If the user built a proposal from a stale advertisement,
the provider MAY reject it under the current policy.

Create-stream deadline pairing.
`StreamParams.create_stream_deadline` is an absolute chain timestamp.
It is the latest time the user commits to complete on-chain stream creation.
`StreamProviderPolicy.max_create_stream_deadline_delay` is the maximum allowed
delay in seconds from verification time until that deadline.
At proposal verification time `t`, the provider MUST require
`t < create_stream_deadline` and
`create_stream_deadline <= t + max_create_stream_deadline_delay`.
The user MUST choose `create_stream_deadline` within that bound.
RECOMMENDED default for `max_create_stream_deadline_delay`: 300 seconds.

Proposal verification time `t` and `create_stream_deadline`
use the same timestamp domain as stream folding in the on-chain streams protocol.

The provider SHOULD also advertise accepted eligibility proof types
and accepted assets.
The user indicates which asset applies by choosing `VaultProof.vault_id`
in the `StreamProposal` on the first vault-proof-backed `ServiceRequest`.
Vaults are single-asset.
If the provider accepts more than one asset,
the user picks the vault whose asset matches.

New `StreamProviderPolicy` advertisements apply only to new proposals.
After the provider accepts a proposal,
it MUST apply the same `StreamProviderPolicy` fields it used at
acceptance for that service session until the session ends.
The provider MAY end service with
`ServiceTermination`.
A future discovery extension MAY let a `StreamProposal` carry a
commitment to a specific published policy revision.

Users SHOULD monitor service delivery
and take action when providers stop delivering service.
Since users are typically online to receive service,
monitoring quality and pausing or closing streams
is a reasonable expectation.

Providers SHOULD monitor the stream on-chain
and SHOULD stop providing service when a stream is not `ACTIVE`.

### Service session continuation

The on-chain stream follows the stream lifecycle rules
from on-chain stream creation.
An on-chain stream MAY stay `ACTIVE` and accrue after service ends.
If the provider has ended service, the user SHOULD pause or close the
stream promptly.

Per-request eligibility uses `StreamProof`.
The provider MAY retain session state across user pause.
After resume, the user MAY send further `StreamProof`s under the same
acceptance.

The provider MAY send `ServiceTermination`.
The provider MAY drop session state.
The user MAY pause, close, or stop sending `StreamProof` requests.
After `PERMANENT` `ServiceTermination`, the user SHOULD close the
stream.
The provider SHOULD treat that acceptance as closed.
Further service requires a newly accepted `StreamProposal`.
After `TEMPORARY` `ServiceTermination`, the provider MAY resume under
the same acceptance once `resume_after` has passed.

### Protocol flow

#### Proposal

The user discovers a provider.
The provider's advertisement MUST include `StreamProviderPolicy`.

The user sends the first `ServiceRequest` with a
`StreamProposal` and `request_data`.

The provider MUST verify `VaultProof` against on-chain vault state.
The provider MUST run `proposal_satisfies_policy`.
The provider MUST verify `VaultProof.owner_signature` with
`VaultProof.owner_public_key` over the canonical proposal payload.
The provider MUST confirm that `owner_public_key` matches the
user (vault owner) for `VaultProof.vault_id` on-chain.
In the proposal phase the provider MUST read on-chain vault balance
and `total_allocated` for `VaultProof.vault_id` as defined in the
[On-Chain Payment Streams Protocol](#on-chain-payment-streams-protocol).
Unallocated is vault balance minus `total_allocated`.

The provider MUST reject the proposal if
`StreamParams.stream_allocation > unallocated`.
The provider MUST reject the proposal if
`StreamParams.stream_allocation < StreamProviderPolicy.min_stream_allocation`.

If parameters fail policy, the provider MUST respond with
`PARAMS_REJECTED`.
The provider MUST NOT treat the `VaultProof` as spent.
The user MAY send a new proposal with adjusted `StreamParams`.
If the proof is invalid, the provider MUST respond with
`PROOF_INVALID`.
If the provider accepts, it MUST respond with `OK` and
`response_data`.
The provider SHOULD use `StreamProviderPolicy.vault_proof_max_response_bytes` to
limit the first vault-proof-backed `response_data`.

#### Proposal acceptance and pending state

The provider MUST record service session state for the accepted
proposal.
Session state includes accepted `StreamParams`,
`VaultProof` fields used for verification
(`vault_id`, `provider_id`, `owner_public_key`),
`StreamProposal.public_key`,
and `stream_id` after the first valid `StreamProof`.

A user MUST NOT send a new `StreamProposal` to the same vault-provider
pair while another is pending.
The user MUST complete on-chain stream creation before sending another
`StreamProposal` to that provider after acceptance.

The user chooses `StreamParams.create_stream_deadline` in each
proposal.
If chain time passes `create_stream_deadline` without acceptance,
negotiation for that proposal MUST be treated as failed.
The user MAY then withdraw unallocated funds, fund other streams, and
MAY send a new `StreamProposal` to any provider.
The provider MUST NOT accept that proposal after
`create_stream_deadline`.
The provider MUST NOT treat its `VaultProof` as spent for that
proposal.

From acceptance until on-chain stream creation succeeds or
`create_stream_deadline` passes without a compliant stream,
the user MUST keep unallocated at least the accepted `stream_allocation`.
If creation fails for insufficient unallocated after acceptance, the
user has breached that obligation.
The provider SHOULD send `PERMANENT` `ServiceTermination`.

#### Stream creation

The user MUST submit on-chain stream creation before
`create_stream_deadline`.
On-chain rate and allocation MUST be greater than or equal to
the signed `StreamParams`.

#### Stream proofs

The user sends `ServiceRequest`s with `StreamProof`.
For each `StreamProof` the provider MUST read on-chain stream state
for `stream_id`.
The provider MUST verify each `StreamProof.signature` over
`request_data` using the session `public_key` from the accepted
proposal.

On the first `StreamProof` for a service session,
the provider learns `stream_id`
and MUST load the stream on-chain using `stream_id`
and MUST run `new_stream_satisfies_proposal`.
This predicate compares on-chain rate and stored allocation commitment
to the accepted `StreamParams` after folding to the current verification timestamp `t`.
On-chain rate and the stored allocation field MUST be greater than
or equal to the accepted `StreamParams`.
The comparison uses the stored allocation commitment
rather than unaccrued balance
(accrual reduces unaccrued without lowering stored allocation until
a claim).
If on-chain values are lower than proposed, the provider MUST
reject the request.
The provider MAY accept on-chain values higher than proposed.
The provider identifier stored on-chain for the stream MUST match this
session's `VaultProof.provider_id` from the accepted proposal,
using the chain-specific mapping for `provider_id`.

The stream MUST be `ACTIVE`.
On-chain rate MUST be at least `min_stream_rate` from policy.
The on-chain provider identifier MUST correspond to
`VaultProof.provider_id` for the acceptance.
The provider MUST run `stream_satisfies_policy` before serving every
service request.
The provider MUST ensure the request is for the service identified by
`service_id` in the accepted `StreamParams`.
`service_id` is fixed for that acceptance.
Changing `service_id` requires a new signed proposal.
For application protocols lacking `service_id` in
`request_data`, the provider binds via the eligibility handler.
LEZ and Logos Delivery Profile records the Store query binding.

Later `StreamProof` requests for the same service session need not run
`new_stream_satisfies_proposal`.
The provider MAY run it again.
That is redundant when the first run
succeeded and does not replace `stream_satisfies_policy` or signature
verification.

If the first `StreamProof` arrives after `create_stream_deadline`,
the provider MUST reject.
If on-chain parameters are below the accepted proposal,
the provider MUST reject.
If the stream is not `ACTIVE`,
the provider MUST respond with `STREAM_NOT_ACTIVE`.
If `create_stream_deadline` passes with no compliant stream,
the provider MAY drop session or pending-proposal state.
The proposal failure semantics from the pending state MUST apply.

The provider SHOULD use eligibility status codes defined in
`ServiceResponse`.

### Scope

This section defines policy fields and verification rules.
Discovery protocol mechanics for advertising `StreamProviderPolicy`
remain in the discovery specification.
Users SHOULD obtain current policy before proposing.

Service protocol wire formats remain in each service specification.
The incentivization specification defines the eligibility envelope.
This specification extends that envelope with `stream_proposal` and `stream_proof`.

Demo operator harnesses,
including scripts, fixtures, and local testing topologies,
belong in implementation repositories.

## LEZ and Logos Delivery Profile

This section maps the [On-Chain Payment Streams Protocol](#on-chain-payment-streams-protocol)
and [Stream-Backed Eligibility for Request-Response Services](#stream-backed-eligibility-for-request-response-services)
onto the Logos Execution Zone.
Wire layouts, error codes, and exact PDA seed literals live in the
payment-streams codebase.
LEZ-specific clock account identifiers and off-chain signing byte layouts are
recorded under Implementation Considerations.

### Scope and LEZ binding

LEZ supports two execution modes: transparent (public account visibility)
and shielded (hidden via zero-knowledge proofs).
LEZ hosts vault and stream accounts,
the payment-streams guest program,
and platform programs used for
deposits and stream folding,
including clock and authenticated transfer.

The LEZ binding centers on one payment-streams guest program plus platform
programs invoked for fund movement.
This section states binding requirements that realize on-chain streams invariants on LEZ.

### Mapping abstract accounting to LEZ

| On-chain quantity | LEZ representation |
| --- | --- |
| Vault `balance` | `VaultHolding` platform-native balance |
| `total_allocated` | `VaultConfig.total_allocated` |
| Per-stream allocation and accrual | Fields in `StreamConfig` |

All vault funds reside in `VaultHolding`.
Let B denote its balance.
B is the LEZ representation of abstract vault `balance`.

Two solvency invariants MUST hold after every mutating instruction:

1. `VaultHolding.balance` ≥ `VaultConfig.total_allocated`
2. `VaultConfig.total_allocated` equals the sum of each stream's `allocation`
   for this vault,
   including closed streams with residual accrued balance.

Instructions maintain the second invariant by applying the same delta to `VaultConfig.total_allocated`
whenever any stream's `allocation` changes.

Stream state is a pure function of stored `StreamConfig` fields and the current timestamp.
Every instruction that touches a stream folds it first, then applies the transition.

Closing and claiming on LEZ follow close and claim accounting from the on-chain streams protocol,
applied to `VaultHolding`, stream `allocation`, and `VaultConfig.total_allocated`.

### Accounts and identities

#### Account types

The program stores state in three account types:
`VaultConfig`, `VaultHolding`, and `StreamConfig`.

`VaultConfig` stores vault metadata and the authorization anchor.
Its `owner` field is the authorization anchor for user-gated instructions.
For `PseudonymousFunder`-tier vaults,
`owner` MUST be an identifier derived from a nullifier public key,
distinct from the user's key associated with their public on-chain activity.

`VaultHolding` is a dedicated account.
Its platform-native balance is the vault's total funds.
`VaultHolding` stores only a version byte in its application data.

`StreamConfig` stores per-stream parameters and lazy accrual state.

#### PDA derivation

Vault and stream accounts are PDAs:
their identifiers are derived deterministically from a canonical set of seeds.
Any party can compute a vault or stream address locally
without querying the chain,
given the owner identifier, vault identifier, and stream identifier.

`VaultConfig` seeds include the owner account identifier
and a user-chosen vault identifier,
binding each vault to its authorization anchor at derivation time.
`VaultHolding` is derived from the `VaultConfig` address,
keeping the two vault accounts co-located.
`StreamConfig` is derived from the `VaultConfig` address
and a stream identifier assigned sequentially by the program on stream creation.
Provider identity is stored as a field in `StreamConfig`
rather than encoded in the PDA seeds,
so a vault may back multiple streams to the same provider.

#### Privacy tiers

A privacy tier is stored in `VaultConfig` and is immutable for the vault's lifetime.

- `Public`: the vault may be operated via transparent or shielded transactions.
  Owner-funding unlinkability is out of scope for this tier.
- `PseudonymousFunder`: the vault is intended for shielded-only operation
  under a conforming wallet.
  The goal is to prevent linking the user's primary public key
  to vault and stream activity on-chain.

See Security and Privacy Considerations for analysis.

### Programs and time

#### Programs and interactions

On LEZ, the following programs and roles interact:

- Payment-streams guest program: owns vault and stream PDAs.
  It enforces allocation accounting, lazy accrual, lifecycle transitions, and
  authorization predicates described in the on-chain streams protocol and this section.
- Platform authenticated-transfer program: moves native balance from the
  user's account into `VaultHolding` on deposit.
  The guest validates that the user controls the vault and amount,
  then chains a transfer call to the program id supplied in the instruction.
- System clock accounts: supply monotonic timestamps for stream folding and
  for comparing against off-chain `create_stream_deadline`.
- Wallet / submitter: chooses transparent versus shielded execution,
  constructs account lists, and enforces client-side privacy policy.

Privacy-preserving deposit MAY require the payment-streams program to appear
in a multi-program proof so the chained authenticated transfer and guest
logic execute under one privacy-preserving transaction.
Multi-program proof layout for that case is a chain-implementation detail
outside this specification.

Direct transfers into `VaultHolding` without calling deposit increase
`VaultHolding` balance and therefore unallocated funds.
Solvency invariants remain satisfied.
Wallets SHOULD avoid direct transfers into `PseudonymousFunder` vaults,
because that path can link the funding account to vault activity.

#### Clock semantics

The payment-streams guest reads time from a system clock account supplied by the caller.
Three platform clock accounts exist on LEZ, updated at different frequencies.
The caller selects which one to use per instruction.
Finer-granularity clocks give more precise accrual folds.
Coarser clocks reduce the frequency of visible timestamp changes.
In shielded execution, coarser clocks also limit timing correlations visible to observers.

Off-chain stream creation deadlines and provider policy verification time
are interpreted as LEZ clock-account timestamps,
the same time source used for stream folding.

Clock account identifier strings appear under Implementation Considerations.

### LEZ authorization

Authorization means a cryptographic signature in transparent transactions
and proof of account control in shielded transactions.

Most instructions require authorization by the user.
Two instructions are exceptions.

`CloseStream` accepts authorization by either the user or the provider,
allowing the provider to initiate closure without requiring the user's cooperation.
`Claim` is authorized by the provider.

Both `CloseStream` and `Claim` include the user
as an explicit non-signing account,
checked for equality with `VaultConfig.owner`.
This binding complements PDA derivation,
which already ties the vault config to the user identifier.

Closing an already-closed stream is an error.

#### Operation correspondence

The table maps on-chain streams operations to the reference guest instruction
names.
Effects summarize changes to `VaultHolding` balance (B), per-stream
`allocation`, and `VaultConfig.total_allocated` after a successful instruction.
Stream-touching instructions fold accrual to the supplied clock time first.

| On-chain operation | Reference instruction | Authorizer | B / allocation / total_allocated effect |
| --- | --- | --- | --- |
| Initialize vault | `InitializeVault` | Vault owner | Creates empty vault accounts. No balance change. |
| Deposit | `Deposit` | Vault owner | B increases by deposit amount. `total_allocated` unchanged. |
| Withdraw unallocated | `Withdraw` | Vault owner | B decreases by withdraw amount. `total_allocated` unchanged. |
| Create stream | `CreateStream` | Vault owner | Stream `allocation` set. `total_allocated` increases by same amount. |
| Pause stream | `PauseStream` | Vault owner | Accrual stops. Allocation fields unchanged. |
| Resume stream | `ResumeStream` | Vault owner | Accrual resumes. Allocation fields unchanged. |
| Top-up stream | `TopUpStream` | Vault owner | Stream `allocation` and `total_allocated` increase by top-up amount. MAY transition to `ACTIVE`. |
| Close stream | `CloseStream` | Vault owner or stream provider | Unaccrued returned to vault (B unchanged). Stream `allocation` and `total_allocated` decrease by released unaccrued. Accrued MAY remain until claim. |
| Claim accrued | `Claim` | Stream provider | B decreases by payout. Provider balance increases. Stream `allocation` and `total_allocated` decrease by payout. |

### Wallet responsibilities

The guest enforces authorization and accounting given the accounts supplied
in a transaction.
Transparent versus shielded execution mode is outside guest visibility.

Wallets that support `PseudonymousFunder` vaults MUST refuse to submit
transparent transactions that touch those vaults or their streams.
Wallets SHOULD reject transparent funding paths that link a user's primary
public key to vault activity when unlinkability is intended.

See Security and Privacy Considerations for limits and rationale.

### LEZ proof bindings

For LEZ integrations, a LEZ integration derives the public account identifier
from `VaultProof.owner_public_key`
and compares it with `VaultConfig.owner`.

For LEZ public-vault integrations,
the expected owner-signature scheme is the Schnorr signature scheme.

For LEZ integrations, `provider_id` is the 32-byte stream payee
`AccountId`.
The LEZ provider identifier checks compare it to `StreamConfig.provider`
with octet equality.

### LEZ off-chain integration

This subsection defines the LEZ demo binding for `bytes` fields in the
off-chain protobuf messages.

#### Identifier encodings

| Field | Encoding |
| --- | --- |
| `VaultProof.vault_id` | Exactly 8 octets, little-endian `VaultId` (`u64`). |
| `StreamProof.stream_id` | Exactly 8 octets, little-endian `StreamId` (`u64`). |
| `VaultProof.provider_id` | Exactly 32 octets, LEZ `AccountId` of the stream payee. MUST equal `StreamConfig.provider` (identity mapping). |
| `VaultProof.owner_public_key` | Exactly 32 octets, x-only secp256k1 public key. |
| `VaultProof.owner_signature` | Exactly 64 octets, Schnorr signature over the LEZ vault-proof prehash. |
| `StreamProposal.public_key` | Exactly 32 octets, session key for `StreamProof.signature`. |
| `StreamProof.signature` | Exactly 64 octets, Schnorr signature over the LEZ Store eligibility prehash. |
| `StreamParams.service_id` | UTF-8 service identifier, no NUL terminator. Max length 128. Demo: `/vac/waku/store-query/3.0.0`. |

Decoders MUST reject wrong lengths for fixed-width fields.

Vault accounts are resolved by deriving vault program-derived addresses
from the user (from `owner_public_key`)
and `VaultProof.vault_id`.

#### Amounts and time

`StreamParams` rate, allocation, and deadline match the scales of
on-chain `StreamConfig` and the folding clock.
Protobuf encodes all three as `uint64`.
LEZ vault-owner signing and on-chain allocation store allocation as
`u128`, zero-extending the protobuf value.

#### LEZ signing scheme

LEZ integrations use the Schnorr signature scheme.
Both `VaultProof.owner_signature` and `StreamProof.signature` sign a 32-byte digest.
Signed material covers canonical field bytes only.
Protobuf field numbers stay out of scope for signing.
The digest construction and byte layouts are defined under
Implementation Considerations.

#### Eligibility envelope (Store)

The Store `eligibility_proof` field carries a protobuf
`EligibilityProof`.
`stream_proposal` and `stream_proof` hold the serialized
`StreamProposal` or `StreamProof` messages respectively.

For application protocols lacking `service_id` in
`request_data`, the Store eligibility handler binds paid Store queries
to the demo `service_id` in the identifier encodings table.

## Security and Privacy Considerations

This section describes the privacy properties of the protocol,
what they provide, and their limits.

### Privacy Goals

In this section, funder means the user in the role of funding a vault on chain.

The primary privacy goal is funder unlinkability:
preventing an observer from linking the user's primary public key
to on-chain vault and stream activity.

A secondary goal is provider privacy:
enabling a provider to receive funds
without revealing their real receiving addresses.
Observers still see stream payment terms on-chain in `StreamConfig`
(rate, allocation, provider identifier).
`StreamParams.service_id` remains off-chain in the service session.
Providers bind each request to the signed value for that acceptance.

### Execution Modes and Linkability

The same program logic executes in both transparent and shielded transactions.
Business logic — accrual math, lifecycle transitions, authorization predicates —
is identical across modes.
What differs is account visibility
and what linkage an observer can infer from on-chain artifacts.

Vault and stream PDAs are public accounts regardless of execution mode.
An observer can reconstruct the vault-to-stream graph from public account identifiers.
Shielded execution can hide the identity behind private signing accounts
and the destinations of private transfers,
while the existence of a stream,
its accrual state,
and the association between a vault and its streams remain visible.

### Stream Lifetime and Funder Unlinkability

If a stream is created in a transparent transaction,
it is permanently linked to the user on-chain.
No subsequent shielded execution can undo this linkage.
To achieve funder unlinkability,
a stream must be created and operated entirely via shielded transactions.

The protocol captures this through two tiers assigned at vault creation time.

A `Public`-tier vault may use transparent and shielded transactions.
Shielded execution provides selective confidentiality on individual operations
but does not provide funder unlinkability
if the vault has ever appeared on a transparent path.

A `PseudonymousFunder`-tier vault is intended to operate entirely via shielded transactions.
The same program logic runs in both transparent and shielded transactions
and leaves execution mode outside guest visibility.
Shielded-only enforcement is therefore wallet responsibility.
A future consensus-level hook could extend this enforcement
to arbitrary submitters,
but that is out of scope for this implementation.

`VaultConfig` is a public account even for `PseudonymousFunder`-tier vaults.
Its `owner` field is a persistent plaintext pseudonym visible to observers.
For `PseudonymousFunder` vaults,
that field is the nullifier-public-key-derived identifier described under
Account types.
The unlinkability target is separation of the primary public key from that pseudonym
rather than hiding the pseudonym itself.

### Wallet responsibilities and limits

The guest cannot observe whether execution was transparent or shielded.
Arbitrary submitters can still construct transparent transactions
against public vault and stream accounts.

### Verifiability

On-chain state of a stream is verifiable by both parties regardless of privacy tier.
`StreamConfig` is a public account.
A provider who knows the stream identifier can derive the account address locally
and read its accrual state from the chain at any time,
without knowing the user's real-world identity.

### Provider Privacy

`StreamConfig` stores the provider identifier in plaintext.
The association between a stream and its provider identifier is always visible on-chain.

A provider who wants to conceal their real receiving addresses
SHOULD use a long-term public-facing provider identifier
alongside one or more shielded receiving addresses,
and claim funds to those addresses via shielded transactions.
An observer then sees that a provider claimed from a stream
without learning where the funds were transferred.
Each transparent claim permanently links the stream to the receiving address for that claim.
Shielded claims to different addresses are independently unlinkable,
regardless of prior transparent claims.

### Service and payment risks

Streams bound user exposure through allocation,
while service quality remains outside the payment proof.
Users remain responsible for monitoring service delivery
and pausing or closing streams when providers stop serving.

Providers rely on policy checks and on-chain stream state
to decide whether each request should be served.
Providers may stop serving users who resume for only short windows,
pause and resume excessively,
or request bursts of service.

### Achieving Unlinkability

Shielded transactions alone do not guarantee unlinkability.
To achieve funder unlinkability on a `PseudonymousFunder`-tier vault,
the user MUST use shielded transactions for all vault and stream operations
and MUST pre-shield funds before depositing,
so no transparent transaction links the primary public key to the vault.
To achieve provider-address unlinkability,
the provider MUST use shielded claims directed to addresses
unlinked to their primary identity.

## Protocol Extensions

This section describes optional modifications
that MAY be applied to the base protocol.
Each extension is independent.

### Off-Chain Extensions

#### Load Cap

This extension is not part of `StreamProviderPolicy` in the base protocol.

A load cap is cumulative resource use per stream per time window
(e.g. total bytes or requests per minute).
It applies to the whole session rather than a single response.
The provider SHOULD advertise a load cap via discovery when using
this extension.

`vault_proof_max_response_bytes` stays in base `StreamProviderPolicy`.
It limits one vault-proof-backed response before an on-chain stream exists.

The provider MUST meter cumulative load per stream in the window.
The provider MUST NOT complete service that would exceed the cap.
The provider SHOULD reject or bound work and SHOULD tell the user when
a request cannot be served within the cap.
A user MAY request work without knowing response size in advance
(for example history over a time range).
Oversize outcomes are enforced by the provider rather than charged as a
user protocol breach.

When sustained load requires a higher cap,
the user SHOULD open multiple streams to the same provider.
The provider MAY terminate service when the cap is reached or
consistently exceeded.

#### Multi-round Stream Parameter Negotiation

A future extension MAY allow the provider
to include counter-proposed parameters
in a `PARAMS_REJECTED` response,
enabling iterative negotiation
before the first request is served.

### On-Chain Extensions

#### Auto-Pause

The user MAY specify an auto-pause duration when creating a stream.
When the specified duration elapses since stream creation or last resume,
the stream MUST automatically transition to PAUSED state.
The user MAY resume the stream, resetting the auto-pause timer.

Auto-pause limits loss if service stops and the user is offline.
Per-stream allocation already bounds total risk.
Auto-pause adds periodic check-ins for long-running streams.

#### Automatic Claim on Closure

This extension adds an optional auto-claim flag.
When auto-claim is enabled,
closing the stream MUST automatically claim accrued funds for the provider.

Auto-claim simplifies the protocol
by ensuring closed streams hold no funds,
eliminating the need to track balances in closed streams.

However, auto-claim has potential issues:

- Prevents provider from batching claims.
- May create timing correlations that leak privacy.
- Requires user to pay for provider's claim operation.
- May cause the entire close operation to fail if claim fails.

Assessing these trade-offs requires clarity on LEZ,
particularly gas model, batching techniques, and timing privacy.

#### Activation Fee

A user can exploit the pause/resume mechanism
by keeping a stream paused
and resuming briefly only when querying a service.
This results in minimal payment for actual service usage.

The activation fee addresses this attack.
When the activation fee is enabled,
a fixed amount MUST be transferred to the provider
immediately upon the stream becoming `ACTIVE`.
The activation fee SHOULD reflect
the minimum acceptable payment for a service session.
The activation fee applies to stream creation, resume, and top-up operations,
as only user actions transition a stream to `ACTIVE` state.
If stream allocation is lower than activation fee,
stream activation MUST fail.

Providers MAY alternatively address this attack via off-chain policy
by refusing service to users who pause and resume excessively.

#### Delivery Receipts

The claim operation MAY require delivery receipts as proof of service.
A delivery receipt is an off-chain user-signed message that MUST include
stream identifier, service delivery details, and signature.
If a stream has delivery receipts enabled,
the protocol MUST only allow claims with valid receipts.

Receipt granularity presents a trade-off.
Per-message receipts allow the user to approve each message individually
but require signing each receipt, increasing interaction overhead.
Batched receipts reduce signing overhead
but require the user to approve multiple messages at once.


## Implementation Considerations

This section records LEZ-specific identifiers and canonical signing bytes
for interoperability with the LEZ payment-streams code and its conformance
tests.

### Integration and implementation boundary

Normative MUSTs in this specification apply to user-side and provider-side
software and to the payment-streams guest program on LEZ.
Where this specification omits guest wire layout or error codes,
those details are implementation details of the payment-streams
codebase (guest, core, FFI, Logos modules).

Clock account ids and domain prefix strings in this section are pinned to demo testnet
fixtures in the `lez-payment-streams` reference repository
and MAY change when the network genesis changes.
Implementations MUST follow the deployed network genesis and published
test vectors in that repository when they differ from this section.

### System clock accounts (LEZ demo)

Stream folding and deadline checks use timestamps read from a caller-supplied
system clock account.
The guest accepts exactly three clock program account identifiers
(fixed at network genesis):

| Clock account id (UTF-8 prefix string) | Typical update cadence |
| --- | --- |
| `/LEZ/ClockProgramAccount/0000001` | Highest frequency (finest folding granularity) |
| `/LEZ/ClockProgramAccount/0000010` | Medium frequency |
| `/LEZ/ClockProgramAccount/0000050` | Coarsest frequency |

Each account stores Borsh `ClockAccountData { timestamp }`.
The guest rejects unknown clock account ids and malformed payloads.

Demo tooling MAY default to a specific clock account (for example the
medium-frequency id) for operator convenience.
Any id in the table is valid when its timestamp is monotonic for the
transaction.

### Canonical signing bytes (LEZ demo)

Both signature roles use Schnorr over a 32-byte digest:

```text
digest = SHA-256(domain_prefix || canonical_body_bytes)
```

`domain_prefix` is a fixed 32-byte ASCII string padded with NUL bytes.
`canonical_body_bytes` is defined per signature role in the subsections that follow.
Implementations MUST match the reference test vectors in the
`lez-payment-streams` repository (including cross-language Store parity).

#### Vault owner authorization (`VaultProof.owner_signature`)

Domain prefix (32 bytes):

```text
b"/LEZ/v0.1/VaultOwnerAuth/\x00\x00\x00\x00\x00\x00\x00"
```

`canonical_body_bytes` is Borsh serialization of the following fields in order:

| Field | Borsh type |
| --- | --- |
| `vault_id` | `u64` LE |
| `provider_id` | 32 raw bytes (LEZ `AccountId`) |
| `owner_public_key` | 32 raw bytes (x-only secp256k1 public key) |
| `service_id` | Borsh `string` (4-byte LE length + UTF-8) |
| `rate` | `u64` LE |
| `allocation` | `u128` LE |
| `create_stream_deadline` | `u64` LE |
| `session_public_key` (`StreamProposal.public_key`) | 32 raw bytes |

The signed material MUST cover the accepted `StreamParams`, the session
`StreamProposal.public_key`, and the `VaultProof` identity fields in the table,
matching the vault-proof field requirements in this specification.

#### Store eligibility (`StreamProof.signature`)

Domain prefix (32 bytes):

```text
b"/LEZ/v0.1/StoreEligibility/\x00\x00\x00\x00\x00"
```

`canonical_body_bytes` is Borsh serialization of `CanonicalStoreRequest`
with field order and optional-field encoding matching the Store query request
without eligibility fields (presence-byte optional encoding, Borsh strings,
message hash array, pagination fields).
The demo integration uses the same logical Store query fields as
Logos Delivery `StoreQueryRequest`.

The full wire form used by demo tooling is:

```text
wire = domain_prefix || canonical_body_bytes
digest = SHA-256(wire)
```

`StreamProof.signature` signs `digest`.
Providers recomputing eligibility MUST derive the digest from the same
`wire` bytes as demo tooling, using protobuf `request_data` only for
service payload decoding.

Reference fixture length for the pinned cross-language test vector is
138 bytes for `wire` (32-byte prefix plus Borsh body) for the demo Store
query fields in N8 (`/lez-payment-streams/1/e2e-eligibility/proto`,
empty `messageHashes`). Other queries produce different wire lengths under
the same encoding rules.


## References

### Normative

- [Incentivization for Waku Light Protocols](../../messaging/core/raw/incentivization.md)

### Informative

#### Related Work

- [Off-Chain Payment Protocols: Classification and Architectural Choice](https://forum.vac.dev/t/off-chain-payment-protocols-classification-and-architectural-choice/596)
- [Logos Execution Zone](https://github.com/logos-blockchain/logos-execution-zone)

#### Payment Streaming Protocols

Existing payment streaming protocols
(Sablier Flow, Sablier Lockup, LlamaPay V2, Superfluid)
target EVM-like state architectures.
They use time-based accrual with ERC-20 tokens.
Protocols differ in stream duration.
Some support fixed-duration streams (Sablier Lockup),
while others allow open-ended streams (Sablier Flow).
Deposit architecture also varies.
Singleton managers (Sablier Flow, Sablier Lockup)
require separate deposits per stream.
Per-payer vaults (LlamaPay V2)
allow one deposit to back multiple streams.

- [Sablier Flow](https://github.com/sablier-labs/flow)
- [Sablier Lockup](https://github.com/sablier-labs/lockup)
- [LlamaPay V2](https://github.com/LlamaPay/llamapay-v2)
- [Superfluid Protocol](https://github.com/superfluid-org/protocol-monorepo)

## Appendix A: Illustrative EVM Implementation

This appendix provides an illustrative EVM-based implementation outline.
The actual implementation will target LEZ.

### A.1 Contract Structure

```solidity
contract PaymentVault {
    enum StreamState { ACTIVE, PAUSED, CLOSED }

    struct Stream {
        address token;
        address provider;
        uint128 ratePerSecond;
        uint128 allocation;
        uint64  lastUpdatedAt;
        uint128 accruedBalance;
        StreamState state;
    }

    address public user;
    mapping(address token => uint256) public vaultBalance;
    uint256 public nextStreamId;
    mapping(uint256 => Stream) public streams;
}
```

### A.2 Vault Operations

```solidity
event Deposited(address indexed token, uint256 amount);
event Withdrawn(address indexed token, uint256 amount, address indexed to);

function deposit(address token, uint256 amount) external;
function withdraw(address token, uint256 amount, address to) external;
```

### A.3 Stream Lifecycle

```solidity
event StreamCreated(
    uint256 indexed streamId,
    address indexed provider,
    address indexed token,
    uint128 ratePerSecond,
    uint128 allocation
);
event StreamPaused(uint256 indexed streamId);
event StreamResumed(uint256 indexed streamId);
event StreamToppedUp(uint256 indexed streamId, uint128 additionalAllocation);
event StreamClosed(uint256 indexed streamId, uint128 refundedToVault);
event Claimed(uint256 indexed streamId, address indexed provider, uint128 amount);

/// @notice Create a new stream in ACTIVE state (user only)
/// @dev MUST revert if allocation exceeds available vault balance
function createStream(
    address provider,
    address token,
    uint128 ratePerSecond,
    uint128 allocation
) external returns (uint256 streamId);

/// @notice Pause an ACTIVE stream (user only)
function pauseStream(uint256 streamId) external;

/// @notice Resume a PAUSED stream (user only)
/// @dev MUST revert if remaining allocation (allocation - accruedBalance) is zero
function resumeStream(uint256 streamId) external;

/// @notice Add funds to stream allocation; transitions to ACTIVE (user only)
/// @dev MUST revert if additionalAllocation exceeds available vault balance
function topUpStream(uint256 streamId, uint128 additionalAllocation) external;

/// @notice Close stream permanently
/// @dev Callable by user or provider. Unaccrued funds (allocation - accruedBalance)
///      MUST be returned to vaultBalance. Accrued funds remain claimable by provider.
function closeStream(uint256 streamId) external;

/// @notice Provider claims accrued funds from a stream
/// @dev Callable in any state (ACTIVE, PAUSED, or CLOSED).
///      Transfers full accruedBalance to provider and resets it to zero.
function claim(uint256 streamId) external;
```

### A.4 Internal Accrual

```solidity
/// @notice Update accruedBalance based on elapsed time since lastUpdatedAt
/// @dev Called by pauseStream, resumeStream, topUpStream, closeStream, and claim
///      before modifying stream state. Caps accrual at allocation and
///      transitions to PAUSED when fully accrued (lazy evaluation:
///      state updates on next interaction, not at exact depletion time).
function _accrue(uint256 streamId) internal;
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
