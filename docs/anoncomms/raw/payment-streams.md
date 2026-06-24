# Payment Streams

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

Users deposit into vaults and allocate payment streams that accrue to providers over time.
The chain enforces allocation accounting and lazy accrual on each stream-touching operation
using a monotonic timestamp.

Off-chain request-response service uses `VaultProof`, `StreamProposal`, and `StreamProof`
so providers grant service when proofs and on-chain stream state satisfy advertised policy.
The specification covers generic on-chain and off-chain protocols,
LEZ and Logos Delivery reference bindings,
security and privacy considerations,
and optional extensions.

## Language

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
in this document are to be interpreted as described in
[RFC 2119](http://tools.ietf.org/html/rfc2119).

Protobuf `uint64` timestamp fields use the chain integration time unit
defined for on-chain accrual unless stated otherwise.

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

We target low latency and fees (streams accrue continuously without per-request settlement),
limited loss exposure (`allocation` caps provider payout),
on-chain deposit identity unlinkable from off-chain service when privacy tiers and wallets are used correctly,
and a simple vault-plus-stream core with optional extensions.

Payment streams enable unidirectional time-based fund flows.
Streams map well to our use case.
Unlike alternatives (payment channels, e-cash),
payment streams avoid storing old states or initiating disputes,
and do not rely on a centralized mint.

The document proceeds from on-chain streams,
to stream-backed request-response eligibility,
to the LEZ and Logos Delivery reference binding,
then security and privacy considerations.


## On-Chain Payment Streams Protocol

This document refers to payment streams as streams.

### Roles

The protocol has two roles:

- User: the party paying for services.
- Provider: the party delivering services and receiving payment.

On-chain privacy text uses funder for the user in the vault-funding role
(see [Security and privacy considerations](#security-and-privacy-considerations)).

### Vaults and streams

The protocol uses a two-level architecture
of vaults and streams.

A vault holds a user's deposit in the vault token.
In the base protocol the vault token is the chain native token.
A user MAY have multiple vaults.
One vault MAY back multiple streams, possibly to different providers.

A stream represents an individual flow of funds from a vault to one provider.
Each stream MUST belong to exactly one vault.
Each stream MUST record a provider identifier (`provider_id`)
in chain-specific encoding.
That identifier MUST designate the party authorized to claim accrued funds.
Each chain integration MUST define how `provider_id` binds to the on-chain provider account.
Each stream MUST specify an accrual rate in the vault token per time unit.
This specification does not fix the time unit.
Each chain integration MUST define the time unit used by rates and accrual.

To start using the protocol,
the user MUST deposit the vault's token into a vault.
The funds deposited into a vault are initially `unallocated`.
When creating a stream,
the user MUST allocate a portion of `unallocated` vault funds to that stream.
For each stream, `allocation` is the portion of vault funds reserved for that stream.

Let `balance` be the vault balance.
Let `total_allocated` be the sum of all `allocation` values for streams in a vault.
For each stream, funds within `allocation` accrue from the user to the provider.
Thus each `allocation` is divided into `accrued` and `unaccrued`.

The following identities MUST hold:

```text
balance = total_allocated + unallocated
allocation = accrued + unaccrued
```

Vault operations include:

- Initialize: create an empty vault.
- Deposit: increase `balance` and `unallocated`.
- Withdraw: decrease `balance` by at most `unallocated`.

The user MAY withdraw unallocated funds at any time.
Vault operations MUST NOT modify allocated funds.

Any change to a stream's `allocation` MUST be funded only from that vault's
`unallocated` balance.
An increase to `allocation` MUST decrease `unallocated` by the same amount,
increase `total_allocated` by the same amount,
and MUST NOT change vault `balance`.
An operation that increases `allocation` MUST fail when `unallocated` is
insufficient.

### Stream lifecycle

At any point in time, a stream MUST be in one of the following states:
`ACTIVE`, `PAUSED`, `CLOSED`.

A stream is depleted when `unaccrued = 0`.

State transition diagram:

```mermaid
graph LR;
    ACTIVE -->|pause / deplete| PAUSED;
    PAUSED -->|resume / top-up| ACTIVE;
    ACTIVE -->|close| CLOSED;
    PAUSED -->|close| CLOSED;
```

Stream operations include:

- Create: bind a provider, set rate and initial `allocation`.
- Pause: stop accrual when the stream is `ACTIVE`.
- Resume: resume accrual when the stream is `PAUSED` and not depleted.
- Top-up: increase the stream's `allocation`.
- Close: release remaining `unaccrued` to vault `unallocated` and mark the stream `CLOSED`.
- Claim: transfer all `accrued` funds to the provider; set `accrued` to zero and
  decrease `allocation` and the vault's `total_allocated` by the claimed amount.

The user MAY create a stream if the vault has `unallocated` funds.
Stream creation MUST assign a stable `stream_id` in chain-specific encoding.
A newly created stream MUST be `ACTIVE`.
Funds MUST accrue only while the stream is `ACTIVE`.

The user MAY pause a stream while the stream is `ACTIVE`.
The stream also transitions from `ACTIVE` to `PAUSED` automatically
when the stream becomes depleted.

The user MAY resume a stream while the stream is `PAUSED`.
Resume MUST fail if the stream is depleted.

The user MAY top-up a stream.
Top-up MUST increase the stream's `allocation` under the allocation increase rules above.
Top-up MUST transition the stream to `ACTIVE`.
To add funds and keep the stream `PAUSED`,
the user MUST pause the stream after top-up.

Either user or provider MAY close the stream from any non-`CLOSED` state.
Unaccrued funds of a `CLOSED` stream MUST be immediately transferred to the vault's `unallocated` balance.
A `CLOSED` stream MUST NOT transition to any other state.
Accrued funds of a `CLOSED` stream remain available for the provider to claim.

The provider MAY claim accrued funds from a stream in any state.
A claim MUST transfer the full accrued funds to the provider.

### Lazy accrual and folding

A chain integration MUST expose a monotonic system timestamp.
The integration MUST define which accounts or system values supply that timestamp.
Accrual MUST be computed relative to the timestamp.

As stream state is a pure function of stored on-chain fields,
stream parameters, lifecycle state, and the timestamp at fold time,
any party can compute the effective stream state locally.
On-chain state remains the source of truth for protocol operations.
Lifecycle and balances can change with passing time,
but stored on-chain fields can only be updated as a result of a transaction.

Stored `accrued`, stored `unaccrued`,
and a depletion-driven transition to `PAUSED` MAY lag behind the effective
state at the current timestamp.
To fold a stream means to advance on-chain fields to match a fold timestamp.
The fold timestamp is the monotonic chain time up to which accrual is applied in that fold.
Any stream operation MUST fold the stream before executing its logic.

Each stream MUST record an accrual anchor:
the stored timestamp through which the stored `accrued` value has been computed.
When folding at timestamp `t`, let `Δt` be `t` minus the accrual anchor.
If the stream is not `ACTIVE`,
folding MUST leave `accrued` and the accrual anchor unchanged.
Otherwise the fold MUST set:

```text
accrued := min(allocation, accrued + rate × Δt)
```

If after folding the stream is depleted,
the accrual anchor MUST be set to the timestamp at which depletion occurred
(MAY be earlier than `t`.
When `rate` is non-zero,
that time RECOMMENDED equals `accrual_anchor + (allocation - accrued_before_fold) / rate`
where `accrued_before_fold` is the stored `accrued` before the fold step,
using the chain integration time unit).
Otherwise the accrual anchor MUST be set to `t`.

### On-chain protocol extensions

This section describes optional modifications
to the streams protocol.

#### Auto-Pause

In the base streams protocol,
the user SHOULD pause or close a stream when the provider stops delivering service.
If the user is offline,
a stream that is `ACTIVE` MAY keep accruing until the stream is depleted,
which increases loss exposure while service is unavailable.

The auto-pause extension limits offline exposure by time,
in addition to the funds cap from `allocation`.
When creating a stream,
the user MAY specify an auto-pause duration in the chain integration time unit.
When that duration elapses since stream creation or since the last resume,
the stream MUST automatically transition to `PAUSED`.
The user MAY resume the stream.
Each resume MUST restart the auto-pause duration from the time of that resume.

#### Automatic Claim on Closure

In the base streams protocol,
close does not pay the provider.
Accrued funds remain on a `CLOSED` stream until the provider claims them.

The automatic claim on closure extension merges close and claim.
When creating a stream,
the user MAY enable auto-claim.
When auto-claim is enabled,
close MUST transfer all accrued funds to the provider in the same operation,
so the closed stream holds no funds afterward.

This removes the need for the provider to track or claim balances on closed streams.
Trade-offs include:

- The provider can no longer batch claims across streams.
- Close and payout happen in one transaction,
  which can increase timing correlation for observers.
- When the user initiates close on a fee-charging chain,
  the same transaction runs the provider payout logic,
  so the user pays transaction fees for that logic,
  instead of the provider paying via a separate claim.
- If the payout fails,
  close fails atomically and the stream does not transition to the `CLOSED` state.

#### Activation Fee

In the base streams protocol,
accrual runs only while the stream is `ACTIVE`.
The user MAY pause at any time and MAY resume while the stream is `PAUSED`
and not depleted.
A user can leave the stream `PAUSED` for long periods,
resume briefly to obtain service,
and pay only for the short intervals while the stream is `ACTIVE`.

The activation fee extension charges a fee when accrual starts.
When creating a stream,
the user MAY specify an activation fee.
Whenever an operation transitions the stream to `ACTIVE`,
a fixed amount MUST be accrued in addition to regular time-based accrual.
Folding MUST NOT apply the activation fee.
The fee is charged only in the operation that performs the transition.
The fee SHOULD reflect the provider's minimum acceptable payment for a service session.
If `unaccrued` is less than the activation fee,
activation MUST fail.

Providers MAY also mitigate pause-and-resume attacks through off-chain policy.

#### Multi-Token Vaults

In the base streams protocol,
the vault token is the chain native token
and needs no on-chain identity field.

The multi-token vaults extension allows settling in other assets.
When enabled,
each vault MUST record exactly one token identity in chain-specific form.
Every stream in that vault MUST denominate
rate, `allocation`, `accrued`, and claims in that vault's token.
A vault MUST NOT mix multiple token types.

#### Delivery Receipts

In the base streams protocol,
funds accrue based purely on on-chain stream state.
The provider does not submit off-chain proof that service was delivered.

The delivery receipts extension ties claim to user acknowledgment.
When creating a stream,
the user MAY require delivery receipts for claim.
When receipts are required,
claim MUST include valid receipts.

A delivery receipt is an off-chain message signed by the user.
It MUST include the on-chain stream identifier
(as assigned at stream creation, in chain-specific encoding),
service delivery details covered by the claim,
and a signature over those fields.

Integrations choose how many deliveries each receipt covers.
Trade-offs include:

- Per-message receipts let the user approve each delivery separately
  but increase signing and coordination overhead.
- Batched receipts reduce signing overhead
  but require the user to approve multiple deliveries in one step.

## Stream-Backed Eligibility for Request-Response Services

Streams back service eligibility in the incentivization request-response framework,
where each request carries an eligibility proof and each response carries
an eligibility status.
It extends the generic `ServiceRequest`, `ServiceResponse`,
`EligibilityProof`, and `EligibilityStatus` envelope from the
[incentivization specification](../../messaging/core/raw/incentivization.md)
with stream-backed proof types.

Off-chain messages coordinate stream lifecycle and service delivery.
On-chain [Vaults and streams](#vaults-and-streams) and [Stream lifecycle](#stream-lifecycle)
semantics are the source of truth for fund allocation, accrual, and stream state.

This section builds on the user and provider roles and stream accounting from the
[On-Chain Payment Streams Protocol](#on-chain-payment-streams-protocol).

### Protocol overview

The protocol consists of the following stages:

- Discovery.
  Providers advertise `StreamProviderPolicy`.
  Discovery mechanics are out of scope for this specification.
- Initial request-response exchange.
  The user sends a `StreamProposal` in the first `ServiceRequest`;
  the provider MAY accept and serve the first unit.
- Stream-proof-backed request-response.
  Each further `ServiceRequest` carries a `StreamProof`.
- Termination.
  The provider ends service with `ServiceTermination`
  (standalone or inside `ServiceResponse.eligibility_status`).

```mermaid
sequenceDiagram
  participant User
  participant Provider
  participant Chain as On-chain streams

  Note over User,Provider: Discovery (mechanics out of scope)
  User->>Provider: ServiceRequest (EligibilityProof.stream_proposal)
  Provider->>User: ServiceResponse
  User->>Chain: Open stream on-chain
  loop Stream-proof-backed request-response
    User->>Provider: ServiceRequest (EligibilityProof.stream_proof)
    Provider->>User: ServiceResponse
  end
  Provider->>User: ServiceTermination (optional standalone or in ServiceResponse)
```

### Cryptographic commitments

Cryptographic commitments (`VaultProof.owner_signature`, `StreamProof.signature`)
MUST use a chain-specific canonical form.
A chain integration MUST define how signed material covers the required fields.

The `owner_public_key` field identifies the key used to verify `owner_signature`.
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
and canonical signed payload are chain-specific details.
They MUST be deterministic and covered by test vectors.

Chain-specific integrations MUST define how `provider_id`
maps or binds to the on-chain provider identifier used by that chain.

`StreamProof.signature` follows the same encoding and signing rules as
`VaultProof.owner_signature`.

### Message structure

Protobuf excerpts below are normative wire shapes.
ASCII trees are illustrative summaries of nesting.

The message structure is as follows.

Request path:

```text
ServiceRequest
├── request_data
└── eligibility_proof: EligibilityProof
    └── exactly one of:
        ├── stream_proposal: StreamProposal
        │   ├── vault_proof: VaultProof
        │   ├── stream_params: StreamParams
        │   └── public_key
        └── stream_proof: StreamProof
            ├── stream_id
            └── signature
```

Response path:

```text
ServiceResponse
├── eligibility_status (status_code, status_desc; MAY carry termination fields)
└── response_data (if the request is served)

ServiceTermination (standalone or equivalent fields in eligibility_status)
```

#### `ServiceRequest`

A `ServiceRequest` has the fields shown in the request path.

#### `ServiceResponse`

A `ServiceResponse` MUST include:

- `eligibility_status`: an `EligibilityStatus` with:
  - `status_code`: indicating acceptance,
    parameter rejection, proof invalidity, etc.
  - `status_desc`: human-readable description
    (RECOMMENDED to include actionable guidance
    on parameter rejection)
- `response_data`: service-specific payload
  (included if and only if the request is served)

Stream-backed eligibility uses the following `EligibilityStatus.status_code` values:

| `status_code` | Name | Meaning |
| --- | --- | --- |
| 0 | `OK` | Request served. |
| 1 | `PARAMS_REJECTED` | Unacceptable stream or policy parameters, including missed `create_stream_deadline` obligations. User MAY retry with adjusted parameters. |
| 2 | `PROOF_INVALID` | Malformed proof, failed signature, or failed cryptographic verification. |
| 3 | `STREAM_NOT_ACTIVE` | No on-chain stream for `stream_id`, or stream lifecycle state is not `ACTIVE`. |

#### `EligibilityProof`

```protobuf
message EligibilityProof {
  optional bytes proof_of_payment = 1; // unused in stream-backed mode
  optional bytes stream_proposal = 2;
  optional bytes stream_proof = 3;
}
```
The user MUST NOT set `proof_of_payment` or other non-stream incentivization
fields when using stream-backed eligibility.
Exactly one of `stream_proposal` or `stream_proof` MUST be present.
If both are absent, or both are present, the provider MUST treat the proof as
malformed and respond with `PROOF_INVALID`.

#### `StreamProposal`

```protobuf
message StreamProposal {
  VaultProof vault_proof = 1;
  StreamParams stream_params = 2;
  bytes public_key = 3; // session key for StreamProof signatures
}
```

The session key is the key pair committed in `public_key`.
The user signs each `StreamProof` with the session key private key.

#### `StreamProof`

A `StreamProof` links a request to an active stream.

```protobuf
message StreamProof {
  bytes stream_id = 1; // on-chain identifier of the stream
  bytes signature = 2; // signature over request_data using committed public_key
}
```

#### `VaultProof`

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

The `provider_id` field is the provider identity used by this protocol.
It prevents replaying a `VaultProof` between providers.
For example, a chain integration MAY bind `provider_id`
to a long-lived service identity,
and separately bind that service identity
to the chain account that receives stream claims.

#### `StreamParams`

```protobuf
message StreamParams {
  bytes service_id = 1; // identifier of the requested service
  uint64 stream_rate = 2; // proposed accrual rate (tokens per time unit)
  uint64 allocation = 3; // proposed initial allocation
  uint64 create_stream_deadline = 4; // latest create_stream time (absolute timestamp)
}
```

`StreamParams` holds the proposed stream fields for one `StreamProposal`.
`service_id` identifies the request-response service for the stream session.
The provider assigns or advertises acceptable `service_id` values via discovery.
The user MUST set `service_id` to a value the provider accepts for that session.

#### `StreamProviderPolicy`

The provider advertises its policy in the following message:

```protobuf
message StreamProviderPolicy {
  uint64 min_rate = 1;
  uint64 min_allocation = 2;
  uint64 max_create_stream_deadline_delay = 3;
  uint64 vault_proof_max_response_bytes = 4;
}
```

Allocation caps on-chain payment exposure but does not attest to service quality;
providers MAY adjust serving policy when users abuse pause, resume, or request patterns.

#### `ServiceTermination`

```protobuf
message ServiceTermination {
  enum TerminationType {
    TEMPORARY = 0;
    PERMANENT = 1;
  }
  TerminationType termination_type = 1;
  uint64 resume_after = 2;
}
```

For `PERMANENT` termination, `resume_after` MUST be zero.
For `TEMPORARY` termination, `resume_after` MUST be a chain timestamp
after which service MAY resume.

### Protocol Flow

#### Discovery

Parties MUST agree on stream parameters before stream creation.
A separate discovery protocol SHOULD enable providers to advertise their policies.

The provider SHOULD also announce accepted eligibility proof types.
If a provider accepts stream-backed eligibility proofs,
its advertisement MUST include a `StreamProviderPolicy`.
If the provider accepts more than one asset,
the advertisement MUST also state which assets are accepted.

New `StreamProviderPolicy` advertisements apply only to new proposals.
Later stream-proof verification MUST use the policy pinned at service session acceptance
(see [Initial request-response exchange](#initial-request-response-exchange)).
The user SHOULD read the advertised policy before building a `StreamProposal`.
The provider MUST reject a proposal that does not conform to its current policy.

#### Initial request-response exchange

The initial request MUST carry a stream proposal.
The provider MUST verify the vault proof and proposal parameters against
on-chain vault state and against its current policy,
verify the owner signature with the declared public key over the
canonical proposal payload,
and confirm that public key matches the vault owner on-chain for
the vault named in the proof.
The provider MUST reject the proposal when proposed allocation exceeds
unallocated funds.
A user MUST NOT send a new `StreamProposal` to the same vault-provider
pair while another is pending.

A policy defines a maximum time interval
from proposal verification
until the stream MUST be open on-chain
(RECOMMENDED default: 300 seconds).
At proposal verification time `t`,
the provider MUST verify that the deadline is
between `t` and `t` plus the policy-defined interval.
The user MUST set the deadline within these bounds in the stream proposal.
If chain time passes the deadline without acceptance,
negotiation for that proposal MUST be treated as failed.
The provider MUST NOT accept that proposal afterward.
The user MAY withdraw unallocated funds, fund other streams, and
MAY send a new proposal to any provider.

If the proof is invalid, the provider MUST respond with
`PROOF_INVALID`.
If parameters fail policy, the provider MUST respond with
`PARAMS_REJECTED`.
The user MAY send a new proposal with adjusted parameters.
The provider SHOULD limit parameter-rejection retries
to a RECOMMENDED maximum of 5 per vault
within a RECOMMENDED time window of 600 seconds.

A service session is the provider's off-chain record for delivering
service under one accepted `StreamProposal`.
When the provider accepts a proposal,
it MUST respond with `OK` and a response payload.
The provider MUST record service session state for the accepted
proposal.
Session state includes accepted `StreamParams`,
session public key,
the agreed-upon `StreamProviderPolicy`,
`VaultProof` fields used for verification
(`vault_id`, `provider_id`, `owner_public_key`),
and `stream_id` after the first valid stream proof.
Later stream-proof verification MUST use the pinned policy
(see [Discovery](#discovery)).
The provider SHOULD limit the first vault-proof-backed response to
`vault_proof_max_response_bytes` from policy
(RECOMMENDED default: 65536 bytes).

After the provider accepts the proposal,
the user MUST open the stream on-chain before the deadline
from the accepted `StreamParams`.
On-chain rate and stored allocation commitment MUST be at least the signed
proposal terms.
Until the stream exists on-chain or the deadline passes without a compliant
stream, the user MUST keep unallocated at least the accepted allocation.
If creation fails for insufficient unallocated after the service session begins, the user has
breached that obligation.
The provider SHOULD send `PERMANENT` `ServiceTermination`.
The user MUST complete on-chain stream creation before sending another
`StreamProposal` to that provider after the provider accepts the proposal.

#### Stream-proof-backed request-response

Until a compliant stream exists on-chain,
the user MUST NOT send `EligibilityProof.stream_proof`.
After a compliant stream exists on-chain,
each further `ServiceRequest` MUST carry `StreamProof` in `EligibilityProof.stream_proof`.

The provider MUST fold the stream state before verifying compliance.
On every stream-proof request, the provider MUST verify
that a compliant stream exists on-chain for the service session,
the stream proof signature over `request_data`,
that the stream is `ACTIVE`,
that the stream identified by `stream_id` complies with the accepted policy,
and that the request corresponds to the accepted `StreamParams.service_id`
according to the service integration.
`service_id` is fixed for that service session.
Changing `service_id` requires a new signed proposal.

When the stream proof signature fails or the proof is malformed,
the provider MUST respond with `PROOF_INVALID`.
If the stream is not `ACTIVE`, or the stream account is missing,
the provider MUST respond with `STREAM_NOT_ACTIVE`.
When the stream does not comply with the accepted proposal or agreed-upon
`StreamProviderPolicy`, the provider MUST respond with `PARAMS_REJECTED`.

The provider MAY retain session state across user pause.
After resume, the user MAY send further stream proofs under the same
service session.

If the first stream-proof request arrives after `create_stream_deadline`,
the provider MUST reject with `PARAMS_REJECTED`.
If `create_stream_deadline` passes with no compliant stream,
the provider MAY drop session or pending-proposal state.
The proposal failure semantics from the pending state MUST apply.

#### Termination

A service session ends when the provider sends `ServiceTermination`
or drops session state.

The provider SHOULD send a `ServiceTermination` message before stopping service.
The message MAY be sent at any point,
including before a stream is established on-chain.
Wire format and inline `EligibilityStatus` carriage are defined under
[`ServiceTermination`](#servicetermination) in [Message structure](#message-structure).
Termination fields are separate from stream-backed `EligibilityStatus.status_code`
values.
A `ServiceResponse` MAY include both service outcome status and termination metadata.

When the provider has ended service or the user stops requesting service,
the user MAY pause or close the on-chain stream and MAY stop sending stream-proof requests.

For `TEMPORARY` termination,
the user MAY pause the stream until the `resume_after` time.
After `TEMPORARY` `ServiceTermination`,
the provider MAY resume service under the same service session once `resume_after` has passed.

After `PERMANENT` `ServiceTermination`,
the user SHOULD close the stream promptly.
The provider SHOULD treat that service session as closed.
Further service requires a newly accepted `StreamProposal`.

### Request-response protocol extensions

This section describes optional extensions
to the request-response protocol with streams-backed eligibility.

#### Load Cap

In the base request-response protocol,
`StreamProviderPolicy` includes `vault_proof_max_response_bytes`,
which limits the size of one vault-proof-backed response
before a stream exists on-chain.
It does not cap cumulative resource use across a service session.

The load cap extension adds a cumulative limit per stream per time window
(e.g. total bytes or requests per minute).
When this extension is used,
the provider MUST advertise a load cap via discovery.
The provider MAY refuse to serve requests that would exceed the cap.

When sustained load requires a higher cap,
the user SHOULD open multiple streams to the same provider.
Note that the user MAY request work without knowing response size in advance
(such as message history over a time range).

#### Multi-round Stream Parameter Negotiation

In the base request-response protocol,
`PARAMS_REJECTED` does not carry provider counter-proposals.
A future extension MAY allow counter-proposed parameters in a
`PARAMS_REJECTED` response,
enabling iterative negotiation before the first request is served.

## LEZ and Logos Delivery Integration

This section maps the [On-Chain Payment Streams Protocol](#on-chain-payment-streams-protocol)
and [Stream-Backed Eligibility for Request-Response Services](#stream-backed-eligibility-for-request-response-services)
onto LEZ account layout, guest instructions, and reference off-chain bytes.

### Scope and normative boundary

Clock account ids and domain prefix strings below are pinned to demo testnet
fixtures in the `lez-payment-streams` reference repository,
MAY change when network genesis changes,
and guest details omitted here (instruction wire layout, error codes)
are defined in that codebase.
Implementations MUST follow deployed genesis and published test vectors there
when they differ from this section on demo-only fields
(clock account ids, domain prefixes, and similar fixtures).
Normative account layout, authorization, and privacy-tier rules in this section
are not overridden by the reference repository.

### On-chain mapping

The payment-streams guest program uses three account types
(`VaultConfig`, `VaultHolding`, `StreamConfig`).

#### Account types

`VaultConfig` stores vault metadata,
including `total_allocated`,
and the authorization anchor in `owner`.
It records a privacy tier (`Public` or `PseudonymousFunder`),
set at vault initialization and immutable thereafter.
For `PseudonymousFunder`-tier vaults,
`owner` MUST be an identifier derived from a nullifier public key,
distinct from the user's key associated with their public on-chain activity.

`VaultHolding` holds vault token balance.
Its application data stores a version byte.
The guest MUST reject instructions when version bytes across
`VaultConfig`, `VaultHolding`, and `StreamConfig` for a vault do not match.
The reference guest uses version `1` at genesis.

`StreamConfig` holds per-stream on-chain stream state.

#### PDA derivation

`VaultConfig` is a PDA from the owner account identifier
and a user-chosen vault identifier.
`VaultHolding` is derived from the `VaultConfig` address.
`StreamConfig` is a PDA from the `VaultConfig` address
and the stream identifier assigned sequentially on stream creation.
The provider is a field in `StreamConfig`,
not part of the stream PDA seeds,
so one vault MAY back multiple streams to the same provider.

Off-chain vault resolution derives the same `VaultConfig` PDA from
`VaultProof.vault_id` and the account identifier mapped from
`VaultProof.owner_public_key` under [Canonical signing bytes](#canonical-signing-bytes).

#### Deposit path

On deposit, the guest validates vault ownership and amount,
then invokes the platform authenticated-transfer program
to move native balance into `VaultHolding`.

### Guest instructions

`CloseStream` and `Claim` include `VaultConfig.owner`
as an explicit non-signing account,
checked for equality with the vault owner.

| On-chain operation | Reference instruction | Authorizer |
| --- | --- | --- |
| Initialize vault | `InitializeVault` | Vault owner |
| Deposit | `Deposit` | Vault owner |
| Withdraw unallocated | `Withdraw` | Vault owner |
| Create stream | `CreateStream` | Vault owner |
| Pause stream | `PauseStream` | Vault owner |
| Resume stream | `ResumeStream` | Vault owner |
| Top-up stream | `TopUpStream` | Vault owner |
| Close stream | `CloseStream` | Vault owner or stream provider |
| Claim accrued | `Claim` | Stream provider |

### System clock accounts

Stream-touching guest instructions read time from a caller-supplied
system clock account.
The guest accepts exactly three clock program account identifiers
(fixed at network genesis).
Each id is a UTF-8 string of seven decimal digits, zero-padded
(for example `0000010` is decimal ten, not octal):

| Clock account id (UTF-8 prefix string) | Typical update cadence |
| --- | --- |
| `/LEZ/ClockProgramAccount/0000001` | Highest frequency (finest folding granularity) |
| `/LEZ/ClockProgramAccount/0000010` | Medium frequency |
| `/LEZ/ClockProgramAccount/0000050` | Coarsest frequency |

Each account stores Borsh `ClockAccountData { timestamp }`.
The guest rejects unknown clock account ids and malformed payloads.
The caller passes one clock account per instruction;
any id in the table is valid when its timestamp is monotonic for the
transaction.

### Off-chain bytes

#### Identifier encodings

| Field | Encoding |
| --- | --- |
| `VaultProof.vault_id` | Exactly 8 octets, little-endian `VaultId` (`u64`). |
| `StreamProof.stream_id` | Exactly 8 octets, little-endian `StreamId` (`u64`). |
| `VaultProof.provider_id` | Exactly 32 octets, LEZ `AccountId` of the stream provider. |
| `VaultProof.owner_public_key` | Exactly 32 octets, x-only secp256k1 public key. |
| `VaultProof.owner_signature` | Exactly 64 octets, Schnorr signature over the vault-owner digest. |
| `StreamProposal.public_key` | Exactly 32 octets, session key for `StreamProof.signature`. |
| `StreamProof.signature` | Exactly 64 octets, Schnorr signature over the Store eligibility digest. |
| `StreamParams.service_id` | UTF-8, no NUL terminator. Max length 128. |

Decoders MUST reject wrong lengths for fixed-width fields.

On-chain stream `allocation` and the vault-owner Borsh body use `u128`,
zero-extending `StreamParams.allocation` from protobuf `uint64`.

#### Canonical signing bytes

LEZ uses Schnorr signatures over a 32-byte digest
(see [Cryptographic commitments](#cryptographic-commitments)):

```text
digest = SHA-256(domain_prefix || canonical_body_bytes)
```

`domain_prefix` is a fixed 32-byte ASCII string padded with NUL bytes.
`canonical_body_bytes` is defined per signature role below.
Implementations MUST match the reference test vectors in the
`lez-payment-streams` repository (including cross-language Store parity).

`VaultProof.owner_public_key` binds to `VaultConfig.owner`
via the LEZ account-identifier derivation in the reference implementation.
`VaultProof.provider_id` equals `StreamConfig.provider` with octet equality.

#### Vault owner authorization (`VaultProof.owner_signature`)

Domain prefix (32 bytes):

```text
/LEZ/v0.1/VaultOwnerAuth/ followed by seven NUL bytes (32 bytes total)
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

#### Store eligibility signature

Domain prefix (32 bytes):

```text
/LEZ/v0.1/StoreEligibility/ followed by five NUL bytes (32 bytes total)
```

`canonical_body_bytes` is Borsh serialization of `CanonicalStoreRequest`
with field order and optional-field encoding matching Logos Delivery
`StoreQueryRequest` without eligibility fields
(presence-byte optional encoding, Borsh strings,
message hash array, pagination fields).

Providers derive `digest` by decoding the Store query from `request_data`
and applying the encoding rules above.

#### Logos Delivery Store query integration

The demo binding uses `StreamParams.service_id`
`/vac/waku/store-query/3.0.0`
with [Store eligibility signature](#store-eligibility-signature) signing above.

## Security and privacy considerations

Privacy goals,
on-chain visibility,
and wallet and provider obligations follow.

### Privacy goals

In this section, funder means the user in the role of funding a vault on chain.

The primary goal is funder unlinkability:
separating the user's primary public key from on-chain vault and stream activity.

The secondary goal is provider receiving privacy:
limiting linkage between on-chain claims and the provider's real receiving addresses.

### On-chain visibility

Vault and stream accounts are public.
An observer can read each stream's terms and accrual state in `StreamConfig`
and reconstruct the vault-to-stream graph from account identifiers.

Transparent and shielded transactions run the same guest logic;
they differ in which signing identities and transfer endpoints appear on chain.
Shielded execution can hide the funder behind private signing accounts
and hide claim destinations,
but it does not hide the vault-to-stream relationship or how streams accrue.
Coarser [system clock accounts](#system-clock-accounts) reduce how often
folding updates visible timestamps on stream accounts.

### Funder unlinkability

A transparent stream creation permanently links the funder on chain;
later shielded operations cannot remove that linkage.

Privacy tiers (see [Account types](#account-types)) express intent at vault creation:

- `Public`: transparent or shielded use is allowed;
  shielded operations alone do not yield funder unlinkability
  after any transparent vault or stream activity.
- `PseudonymousFunder`: intended for shielded-only use;
  the guest does not enforce execution mode,
  and `VaultConfig.owner` remains a visible pseudonym
  (not the user's primary public key).

To obtain funder unlinkability on a `PseudonymousFunder` vault,
the user MUST run all vault and stream operations through shielded transactions
and MUST pre-shield funds before deposit so no transparent path
links the primary public key to the vault.

### Wallet obligations

Because execution mode is outside guest visibility,
any submitter can still post transparent transactions against public accounts.
Wallets MUST NOT transfer directly into a `VaultHolding` for
`PseudonymousFunder` vaults,
because that links a funder address to the vault on chain.
Wallets SHOULD avoid transparent paths that link the user's primary public key
to vault activity when unlinkability is intended.

### Provider receiving privacy

`StreamConfig.provider` is public;
observers always see which provider identifier accrues a stream.

To limit address linkage on payout,
the provider SHOULD claim through shielded transactions
to receiving addresses not tied to their primary identity.
Each transparent claim links that stream to the visible receiving address for that claim;
shielded claims to distinct addresses are not linked to each other by the claim alone.

To obtain receiving-address unlinkability,
the provider MUST use shielded claims to addresses unlinked to their primary identity.

Providers can verify stream accrual from chain state given `stream_id`
without learning the user's off-chain identity.


## References

### Normative

- [Incentivization for Waku Light Protocols](../../messaging/core/raw/incentivization.md)

### Informative

#### Related Work

- [Off-Chain Payment Protocols: Classification and Architectural Choice](https://forum.vac.dev/t/off-chain-payment-protocols-classification-and-architectural-choice/596)
- [Logos Execution Zone](https://github.com/logos-blockchain/logos-execution-zone)

#### Payment Streaming Protocols

Existing payment streaming protocols target EVM-like architectures.
Protocols vary in duration
(fixed-duration in Sablier Lockup or open-ended in Sablier Flow)
and in deposit architectures
(stream-level deposits in Sablier or multi-stream vaults in LlamaPay V2).

- [Sablier Flow](https://github.com/sablier-labs/flow)
- [Sablier Lockup](https://github.com/sablier-labs/lockup)
- [LlamaPay V2](https://github.com/LlamaPay/llamapay-v2)
- [Superfluid Protocol](https://github.com/superfluid-org/protocol-monorepo)

## Appendix A: Illustrative EVM Implementation

This appendix provides an illustrative EVM-based implementation outline.
The actual implementation will target LEZ.
The sketch uses one vault per contract and omits multi-vault support from the main protocol.

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
/// @dev Called by createStream, pauseStream, resumeStream, topUpStream, closeStream, and claim
///      before modifying stream state. Caps accrual at allocation and
///      transitions to PAUSED when depleted (lazy evaluation:
///      state updates on next interaction, not at exact depletion time).
function _accrue(uint256 streamId) internal;
```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
