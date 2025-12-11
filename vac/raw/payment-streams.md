---
title: PAYMENT-STREAMS
name: Payment Streams Protocol for Logos Services
status: raw
category: Standards Track
tags: logos, payment, streams
editor: Sergei Tikhomirov <sergey.s.tikhomirov@gmail.com>
contributors:
---

## Abstract

This document specifies a payment streams protocol for Logos services.
In this protocol, a payer locks up a deposit that is released gradually to a payee who provides services.
Either party may withdraw funds at any time.
The proportion of funds available to each party is determined by the underlying blockchain based on elapsed time.

This approach provides simplicity:
parties need not store old states or handle dispute closures as required in payment channel protocols.
The unidirectional nature maps well to use cases where payers and payees have distinct roles.

The protocol is designed to be lightweight, secure, private, and to avoid on-chain communication on every payment.
It targets Nescience, a privacy-focused blockchain with state separation architecture,
as the home for its on-chain component.

This document provides a functional specification of the first MVP version of the protocol.
It clarifies requirements for the MVP and facilitates discussion with Nescience developers
regarding implementation feasibility, challenges, and integration considerations.

## Motivation

Logos is a privacy-focused tech stack that includes Logos Messaging, Logos Blockchain, and Logos Storage.

Logos Messaging comprises a suite of communication protocols with both P2P and request-response structures.
While the backbone P2P protocols use tit-for-tat mechanisms,
we plan to introduce incentivization for auxiliary request-response protocols where client and server roles are well defined.
One such protocol is Store,
which allows a client to query historical messages from Logos Messaging relay nodes.

Incentivization requires a payment protocol that is lightweight, secure, private,
and does not require on-chain communication for every payment.
After reviewing prior work on related systems including payment channels, streams, e-cash, and tickets,
we converged on payment streams as the first off-chain payment mechanism.

Nescience is a privacy-focused blockchain under development, planned as part of the Logos Blockchain stack.
Its core innovation is state separation architecture (NSSA), which enables both transparent and shielded execution.
Targeting Nescience for the on-chain component of the payment protocol is a natural fit.
However, Nescience is still in development, and certain architectural aspects remain in progress.

This document aims to provide clarity on MVP payment protocol requirements
and facilitate discussion with Nescience developers to determine:
whether the required functionality can be implemented,
which parts are most challenging and whether they can be simplified,
and other considerations for integrating Nescience with off-chain payment streams for privacy and scalability.



## Related Work

### Sablier Flow

Sablier Flow implements open-ended streaming debt with a rate per second parameter.
The core formula is: amount owed equals rate per second multiplied by elapsed time.
Streams have no predetermined end time and accrue continuously.
Anyone can trigger settlement to realize accrued debt.
Uses standard ERC-20 tokens.

### Sablier Lockup

Sablier Lockup implements a deposit-to-continuous-emission-to-refund-remainder pattern.
Streams have fixed duration determined at creation.
The total deposit amount is locked upfront.
Tokens are released according to a predetermined schedule.
Settlement happens automatically based on time.
Uses singleton stream manager architecture and standard ERC-20 tokens.

### LlamaPay V2

LlamaPay V2 deploys one vault contract per payer.
Each vault can manage multiple outgoing streams to different recipients using multiple tokens.
Streams are open-ended with rate per second accrual.
The protocol tracks debt when streams exceed available vault balance.
Either recipient or payer can trigger settlement.
Includes whitelisting for delegated vault management.
Uses standard ERC-20 tokens.
Licensed under AGPL-3.0.

### Superfluid

Superfluid implements real-time finance with continuous money flows.
Streams are open-ended with rate per second accrual.
Uses a host-agreements framework: a central host contract routes operations to pluggable agreement contracts.
Constant Flow Agreement handles streaming, Instant Distribution Agreement handles one-to-many distributions.
Balances update in real-time; settlement is automatic when balances are queried.
Requires wrapping standard tokens into Super Tokens.
Supports one sender streaming to multiple recipients.

### Comparison

| Design Dimension | Sablier Flow | Sablier Lockup | LlamaPay V2 | Superfluid |
|----------------|--------------|----------------|-------------|------------|
| Stream duration | Open-ended | Fixed duration | Open-ended | Open-ended |
| Accrual mechanism | Rate per second, debt tracking | Fixed schedule, no debt | Rate per second, debt tracking | Rate per second, real-time balance |
| Architecture | Singleton manager | Singleton manager | Per-payer vault | Host-agreements framework |
| Multi-recipient from one payer | No | No | Yes | Yes |
| Spending controls | None | Total deposit fixed upfront | None | Solvency checks only |
| Settlement trigger | Anyone can settle | Automatic time-based | Recipient or payer | Automatic on balance check |
| Token requirements | Standard ERC-20 | Standard ERC-20 | Standard ERC-20 | Super Tokens only |

Key trade-offs between architectures:
Singleton managers (Sablier Flow, Sablier Lockup) require separate deposits per stream but provide simpler global state management.
Per-payer vaults (LlamaPay V2) allow deposit sharing across multiple streams but increase per-payer deployment costs.
Host-agreements framework (Superfluid) provides extensibility and composability at the cost of complexity and non-standard token requirements.

## Theory and Semantics

### Terminology

| Term | Description |
|------|-------------|
| User | The party paying for services (payer) |
| Provider | The party delivering services and receiving payment (payee) |
| Vault | User's deposit holding funds that can back multiple streams |
| Stream | Individual payment flow from vault to one provider, with allocated funds and accrual rate |
| Allocation | Portion of vault funds committed to back a specific stream |
| Rate | Amount of tokens per second that accrue to provider while stream is active |
| Accrual | Process of calculating provider's earned balance based on elapsed time and rate |
| Claim | Provider retrieving accrued funds from a stream, available at any time from any stream state |
| Withdraw | User retrieving unallocated funds from vault or unaccrued funds from closed stream |
| Top-up | User adding funds to a stream's allocation |

### High-level protocol semantics

The overall goal of the protocol is to enable payments for services.

This specification is written with Nescience blockchain as the target platform.
Nescience provides state separation architecture that enables both transparent and shielded execution.
The protocol design leverages these privacy capabilities while remaining functionally defined.

We aim for the following high-level requirements:

- Performance: Payments must be efficient in latency and fees.
- Security: The protocol must limit loss exposure through spending controls.
- Privacy: The protocol must break links between payments and service provision across providers.
- Extendability: The protocol must allow simple initial versions that can be enhanced later.


### Assumptions

We assume the parties agree on stream parameters before stream creation.
The discovery protocol provides a way for providers to advertise their services and expected payment,
or for users and providers to negotiate stream parameters off-chain.

We assume users monitor service delivery and take action when providers stop delivering service.
Since users are typically online to receive service,
monitoring service quality and pausing or closing streams when issues arise is not an unreasonable burden.
The user's risk exposure is bounded by the stream allocation size and the time to detect and respond to service degradation.


### Roles and responsibilities

There are two parties: a user (payer) and a service provider (payee).
Funds flow unidirectionally from user to provider.


### Architecture Overview

The protocol uses a two-level architecture:

Vault - User's deposit of funds that can back multiple payment streams.
A vault holds the total balance available for streaming payments.
Each user has their own vault.

Stream - Individual payment channel from a vault to one provider.
When creating a stream, the user allocates a portion of vault funds to back that stream.
Each stream specifies a rate per second at which funds accrue to the provider.

Relationship:
One vault can have multiple streams to different providers.
Each stream belongs to exactly one vault.
Streams are isolated from each other to prevent linking user activity across providers.

The protocol enforces that total allocated funds across all streams cannot exceed vault balance.


### Vault Lifecycle

A vault is created when a user first deposits funds.
The vault persists as long as the user maintains it.

Vault operations:

Deposit - User adds tokens to the vault.
The vault balance increases.

Withdraw - User removes unallocated tokens from the vault.
Only funds not allocated to streams can be withdrawn.

Create Stream - User creates a new stream by allocating a portion of vault funds.
Allocated funds are committed to back that stream.

Top Up Stream - User increases an existing stream's allocation using vault's available balance.
The additional amount is allocated from vault to the stream.

Vault invariants:

Sum of all stream allocations must not exceed total deposited balance.
User can only withdraw funds that are not allocated to streams.
Vault must maintain sufficient balance to cover all stream allocations.


### Stream Lifecycle

A stream exists only when on-chain state is created.
Off-chain negotiation of stream parameters is handled by a separate discovery protocol.

Stream states:

ACTIVE - Funds accrue to provider at the agreed rate per second.
PAUSED - Accrual is stopped by user action, stream can be resumed by user.
DEPLETED - Stream has run out of allocated funds, accrual is stopped automatically.
CLOSED - Stream is permanently terminated, no further state changes possible. This is the terminal state.

Stream state transitions:

Create - User creates stream in ACTIVE state by allocating funds from vault.
Pause - User pauses an ACTIVE stream, stopping accrual.
Resume - User resumes a PAUSED stream, restarting accrual.
Deplete - Automatic transition from ACTIVE when allocated funds are fully accrued.
Top Up - User adds funds to stream from ACTIVE, PAUSED, or DEPLETED states, increasing allocation.
If performed from DEPLETED state, stream transitions to PAUSED.
If performed from ACTIVE or PAUSED state, stream remains in same state.
Close - Either user or provider closes stream from any non-CLOSED state.
Closure is permanent and irreversible.
CLOSED is the terminal state with no outgoing transitions.

Claim operation:
Provider can claim accrued funds at any time from any stream state.
Accrued amount is determined by rate per second multiplied by time in ACTIVE state.
Claim operation is independent of stream state and does not affect state transitions.

Withdraw operation:
User can withdraw unaccrued allocated funds only from CLOSED state.
User can withdraw unallocated funds from vault at any time.
User cannot withdraw allocated funds from non-CLOSED streams.

Top-up operation:
User can add funds to a stream from ACTIVE, PAUSED, or DEPLETED states.
Top-up increases the stream's allocation from vault's available balance.
Vault must have sufficient unallocated balance to cover the top-up amount.
If stream is in DEPLETED state, top-up transitions it to PAUSED.
User must explicitly resume to restart accrual after topping up a depleted stream.
If stream is in ACTIVE or PAUSED state, top-up increases allocation without changing state.

Stream invariants:

Stream starts in ACTIVE state upon creation.
Only user can pause, resume, or top up a stream.
Stream automatically transitions to DEPLETED when allocated funds are fully accrued.
Either party can close a stream at any time from any non-CLOSED state.
Provider can only claim funds that have accrued based on elapsed time and rate.
User's allocated funds remain committed to the stream until stream is closed.
User can only withdraw stream funds after closing the stream.

## Security and Privacy Considerations

This section will address:
- Economic security assumptions and spending controls
- Attack vectors and mitigations
- Privacy guarantees provided by stream isolation
- Trust assumptions between users and providers
- Considerations specific to Nescience state separation architecture

## Open Questions

This section captures unresolved design decisions for discussion with Nescience developers:

- Implementation of vault and stream isolation in Nescience NSSA
- Enforcement of allocation limits across streams in shielded execution
- Mechanisms for preventing over-commitment without revealing cross-provider activity
- State representation and transition enforcement in shielded execution
- Integration with delivery receipt verification for service quality assurance

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### Informative

- [Sablier Flow](https://github.com/sablier-labs/flow) - Open-ended streaming debt protocol
- [Sablier Lockup](https://github.com/sablier-labs/lockup) - Fixed-duration streaming protocol  
- [LlamaPay V2](https://github.com/LlamaPay/llamapay-v2) - Per-payer vault streaming protocol
- [Superfluid Protocol](https://github.com/superfluid-org/protocol-monorepo) - Real-time finance framework

