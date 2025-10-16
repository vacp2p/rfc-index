---
slug: codex-purchase
title: CODEX-PURCHASE
name: Codex Purchase Module
status: raw
category: Standards Track
tags: codex, storage, marketplace, state-machine
editor: Codex Team and Filip Dimitrijevic <filip@status.im>
contributors:
- Filip Dimitrijevic <filip@status.im>
---

## Abstract

This specification defines the client role in the [Codex](https://github.com/codex-storage/nim-codex) marketplace protocol. A client is a Codex node that purchases storage by creating storage requests, submitting them to the marketplace smart contract, and managing the request lifecycle until completion or failure.

The specification outlines the protocol-level requirements for clients, including storage request creation, marketplace interactions, fund management, and request state monitoring. Implementation approaches, such as state machines and recovery mechanisms, are provided as suggestions.

## Background

In the Codex marketplace protocol, clients purchase storage by creating and submitting storage requests to the marketplace smart contract. Each storage request specifies the data to be stored (identified by a CID), storage parameters (duration, collateral requirements, proof parameters), and the number of storage slots needed.

The marketplace smart contract manages the storage request lifecycle, including request fulfillment, slot management, and fund distribution. Clients must interact with the marketplace to submit requests, monitor request state, and withdraw funds when requests complete or fail.

This specification defines what the protocol requires from clients. The marketplace smart contract governs these requirements—how individual Codex nodes implement them internally (state machines, recovery mechanisms, etc.) is an implementation detail covered in the Implementation Suggestions section.

## Client Protocol Requirements

This section defines the normative requirements for client implementations to participate in the Codex marketplace.

### Storage Request Creation

Clients MUST create storage requests with the following parameters:

- **client**: The client's address (identifying the requester)
- **ask**: Storage parameters including proof probability, pricing, collateral, slots, slot size, duration, and maximum slot loss
- **content**: Content identification using CID and merkle root
- **expiry**: Expiration timestamp for the request (uint64)
- **nonce**: Unique nonce value to ensure request uniqueness

### Marketplace Interactions

Clients MUST implement the following smart contract interactions:

- **requestStorage(request)**: Submit a new storage request to the marketplace along with required payment. Returns a unique `requestId` for tracking the request.

- **getRequest(requestId)**: Retrieve the full `StorageRequest` data from the marketplace. Used for recovery and state verification.

- **requestState(requestId)**: Query the current state of a storage request. Used for recovery and monitoring request progress.

- **withdrawFunds(requestId)**: Withdraw funds locked by the marketplace when a request completes, is cancelled, or fails. Clients MUST call this function to release locked funds.

### Event Subscriptions

Clients MUST subscribe to the following marketplace events:

- **RequestFulfilled(requestId)**: Emitted when a storage request has enough filled slots to start. Clients monitor this event to determine when their request becomes active.

- **RequestFailed(requestId)**: Emitted when a storage request fails due to proof failures or other reasons. Clients observe this event to detect failed requests and initiate fund withdrawal.

### Request Lifecycle Management

Clients MUST monitor storage requests through their lifecycle:

- After submitting a request with `requestStorage`, clients wait for the `RequestFulfilled` event or expiry timeout
- Once fulfilled, clients monitor for the request duration to complete successfully or for a `RequestFailed` event
- When a request completes (finished), is cancelled (expired before fulfillment), or fails, clients MUST call `withdrawFunds` to release locked funds

### Fund Management

Clients MUST:

- Provide sufficient payment when calling `requestStorage` to cover the storage request cost (based on slots, duration, and pricing parameters)
- Call `withdrawFunds` when a request completes, is cancelled, or fails to release any locked funds

## Implementation Suggestions

This section describes implementation approaches used in the nim-codex reference implementation. These are suggestions and not normative requirements.

The nim-codex implementation uses a state machine pattern to manage purchase lifecycles, providing deterministic state transitions, explicit terminal states, and recovery support. The state machine definitions (state identifiers, transitions, state descriptions, requirements, data models, and interfaces) are documented in the subsections below.

> **Note**: The Purchase module terminology and state machine design are specific to the nim-codex implementation. The protocol only requires that clients interact with the marketplace smart contract as specified in the Client Protocol Requirements section.

### State Identifiers

- PurchasePending: `pending`
- PurchaseSubmitted: `submitted`
- PurchaseStarted: `started`
- PurchaseFinished: `finished`
- PurchaseErrored: `errored`
- PurchaseCancelled: `cancelled`
- PurchaseFailed: `failed`
- PurchaseUnknown: `unknown`

### General Rules for All States

- If a `CancelledError` is raised, the state machine logs the cancellation message and takes no further action.
- If a `CatchableError` is raised, the state machine moves to `errored` with the error message.

### State Transitions

```text
                                                                      |
                                                                      v
                                         ------------------------- unknown
        |                               /                             /
        v                              v                             /
     pending ----> submitted ----> started ---------> finished <----/
                        \              \                           /
                         \              ------------> failed <----/
                          \                                      /
                           --> cancelled <-----------------------
```

**Note:**

Any state can transition to errored upon a `CatchableError`.
`failed` is an intermediate state before `errored`.
`finished`, `cancelled`, and `errored` are terminal states.

### State Descriptions

**Pending State (`pending`)**

A storage request is being created by making a call `on-chain`. If the storage request creation fails, the state machine moves to the `errored` state with the corresponding error.

**Submitted State (`submitted`)**

The storage request has been created and the purchase waits for the request to start. When it starts, an `on-chain` event `RequestFulfilled` is emitted, triggering the subscription callback, and the state machine moves to the `started` state. If the expiry is reached before the callback is called, the state machine moves to the `cancelled` state.

**Started State (`started`)**

The purchase is active and waits until the end of the request, defined by the storage request parameters, before moving to the `finished` state. A subscription is made to the marketplace to be notified about request failure. If a request failure is notified, the state machine moves to `failed`.

Marketplace subscription signature:

```nim
method subscribeRequestFailed*(market: Market, requestId: RequestId, callback: OnRequestFailed): Future[Subscription] {.base, async.}
```

**Finished State (`finished`)**

The purchase is considered successful and cleanup routines are called. The purchase module calls `marketplace.withdrawFunds` to release the funds locked by the marketplace:

```nim
method withdrawFunds*(market: Market, requestId: RequestId) {.base, async: (raises: [CancelledError, MarketError]).}
```

After that, the purchase is done; no more states are called and the state machine stops successfully.

**Failed State (`failed`)**

If the marketplace emits a `RequestFailed` event, the state machine moves to the `failed` state and the purchase module calls `marketplace.withdrawFunds` (same signature as above) to release the funds locked by the marketplace. After that, the state machine moves to `errored`.

**Cancelled State (`cancelled`)**

The purchase is cancelled and the purchase module calls `marketplace.withdrawFunds` to release the funds locked by the marketplace (same signature as above). After that, the purchase is terminated; no more states are called and the state machine stops with the reason of failure as error.

**Errored State (`errored`)**

The purchase is terminated; no more states are called and the state machine stops with the reason of failure as error.

**Unknown State (`unknown`)**

The purchase is in recovery mode, meaning that the state has to be determined. The purchase module calls the marketplace to get the request data (`getRequest`) and the request state (`requestState`):

```nim
method getRequest*(market: Market, id: RequestId): Future[?StorageRequest] {.base, async: (raises: [CancelledError]).}

method requestState*(market: Market, requestId: RequestId): Future[?RequestState] {.base, async.}
```

Based on this information, it moves to the corresponding next state.

> **Note**: Functional and non-functional requirements for the client role are summarized in the [Codex Marketplace Specification](https://github.com/codex-storage/codex-spec/blob/master/specs/marketplace.md). The requirements listed below are specific to the nim-codex Purchase module implementation.

### Functional Requirements

#### Purchase Definition

- Every purchase MUST represent exactly one `StorageRequest`
- The purchase MUST have a unique, deterministic identifier `PurchaseId` derived from `requestId`
- It MUST be possible to restore any purchase from its `requestId` after a restart
- A purchase is considered expired when the expiry timestamp in its `StorageRequest` is reached before the request start, i.e, an event `RequestFulfilled` is emitted by the `marketplace`

#### State Machine Progression

- New purchases MUST start in the `pending` state (submission flow)
- Recovered purchases MUST start in the `unknown` state (recovery flow)
- The state machine MUST progress step-by-step until a deterministic terminal state is reached
- The choice of terminal state MUST be based on the `RequestState` returned by the `marketplace`

#### Failure Handling

- On marketplace failure events, the purchase MUST immediately transition to `errored` without retries
- If a `CancelledError` is raised, the state machine MUST log the cancellation and stop further processing
- If a `CatchableError` is raised, the state machine MUST transition to `errored` and record the error

### Non-Functional Requirements

#### Execution Model

A purchase MUST be handled by a single thread; only one worker SHOULD process a given purchase instance at a time.

#### Reliability

`load` supports recovery after process restarts.

#### Performance

State transitions should be non-blocking; all I/O is async.

#### Logging

All state transitions and errors should be clearly logged for traceability.

#### Safety

- Avoid side effects during `new` other than initialising internal fields; `on-chain` interactions are delegated to states using `marketplace` dependency.
- Retry policy for external calls.

#### Testing

- Unit tests check that each state handles success and error properly.
- Integration tests check that a full purchase flows correctly through states.

### Data Models (Wire Format)

#### Purchase

```nim
Purchase* = ref object of Machine
  future*: Future[void]
  market*: Market
  clock*: Clock
  requestId*: RequestId
  request*: ?StorageRequest
```

Extends the `Machine` type from the asyncstatemachine framework. Contains a `future` for async state machine execution, references to the `market` and `clock` dependencies, the `requestId` identifier, and an optional `request` field for the `StorageRequest`.

#### StorageRequest

```nim
StorageRequest* = object
  client* {.serialize.}: Address
  ask* {.serialize.}: StorageAsk
  content* {.serialize.}: StorageContent
  expiry* {.serialize.}: uint64
  nonce*: Nonce
```

Contains the `client` address, storage parameters in `ask`, content identification in `content`, an `expiry` timestamp (uint64), and a unique `nonce`. Fields are marked with `{.serialize.}` for serialization support.

#### StorageAsk

```nim
StorageAsk* = object
  proofProbability* {.serialize.}: UInt256
  pricePerBytePerSecond* {.serialize.}: UInt256
  collateralPerByte* {.serialize.}: UInt256
  slots* {.serialize.}: uint64
  slotSize* {.serialize.}: uint64
  duration* {.serialize.}: uint64
  maxSlotLoss* {.serialize.}: uint64
```

Defines storage agreement parameters: `proofProbability` and pricing in `pricePerBytePerSecond`, `collateralPerByte` for collateral requirements, `slots` and `slotSize` for storage distribution, `duration` for agreement length, and `maxSlotLoss` for fault tolerance. Numeric fields use `UInt256` for large values or `uint64` for counts and durations.

#### StorageContent

```nim
StorageContent* = object
  cid* {.serialize.}: Cid
  merkleRoot*: array[32, byte]
```

Identifies content to be stored using a `cid` (Content Identifier) and a `merkleRoot` (32-byte array) for verification purposes.

#### RequestId

```nim
RequestId* = distinct array[32, byte]
```

A distinct 32-byte array type used as a unique identifier for storage requests. Provides type safety through Nim's distinct types.

#### Nonce

```nim
Nonce* = distinct array[32, byte]
```

A distinct 32-byte array type used as a unique nonce value in `StorageRequest` to ensure request uniqueness.

### Interfaces

| Interface (Nim) | Description | Input | Output |
| --------------- | ----------- | ----- | ------ |
| `func new(_: type Purchase, requestId: RequestId, market: Market, clock: Clock): Purchase` | Construct a purchase from a storage request identifier. Used to recover a purchase. | `requestId: RequestId`, `market: Market`, `clock: Clock` | `Purchase` |
| `func new(_: type Purchase, request: StorageRequest, market: Market, clock: Clock): Purchase` | Create a purchase from a full `StorageRequest`. | `request: StorageRequest`, `market: Market`, `clock: Clock` | `Purchase` |
| `proc start*(purchase: Purchase)` | Start the state machine in pending mode (new on-chain submission flow). | `purchase: Purchase` | `void` |
| `proc load*(purchase: Purchase)` | Start the state machine in unknown mode (restore/recover after restart). | `purchase: Purchase` | `void` |
| `proc wait*(purchase: Purchase) {.async.}` | Await terminal state: completes on success or raises on failure. | `purchase: Purchase` | `Future[void]` |
| `func id*(purchase: Purchase): PurchaseId` | Stable identifier derived from `requestId`. | `purchase: Purchase` | `PurchaseId` |
| `func finished*(purchase: Purchase): bool` | Check whether the purchase completed successfully. | `purchase: Purchase` | `bool` |
| `func error*(purchase: Purchase): ?(ref CatchableError)` | Get error if the purchase failed. | `purchase: Purchase` | `Option[ref CatchableError]` |
| `func state*(purchase: Purchase): ?string` | Query current state name via the state machine. | `purchase: Purchase` | `Option[string]` |
| `proc hash*(x: PurchaseId): Hash` | Compute hash for `PurchaseId`. | `x: PurchaseId` | `Hash` |
| `proc ==*(x, y: PurchaseId): bool` | Equality comparison for `PurchaseId`. | `x: PurchaseId`, `y: PurchaseId` | `bool` |
| `proc toHex*(x: PurchaseId): string` | Hex string representation of `PurchaseId`. | `x: PurchaseId` | `string` |
| `method run*(state: PurchasePending, machine: Machine): Future[?State] {.async: (raises: []).}` | Submit request to market. | `state: PurchasePending`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseSubmitted, machine: Machine): Future[?State] {.async: (raises: []).}` | Await purchase start. | `state: PurchaseSubmitted`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseStarted, machine: Machine): Future[?State] {.async: (raises: []).}` | Run the purchase. | `state: PurchaseStarted`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseFinished, machine: Machine): Future[?State] {.async: (raises: []).}` | Purchase completed. | `state: PurchaseFinished`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseErrored, machine: Machine): Future[?State] {.async: (raises: []).}` | Purchase failed. | `state: PurchaseErrored`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseCancelled, machine: Machine): Future[?State] {.async: (raises: []).}` | Purchase cancelled or timed out. | `state: PurchaseCancelled`, `machine: Machine` | `Future[Option[State]]` |
| `method run*(state: PurchaseUnknown, machine: Machine): Future[?State] {.async: (raises: []).}` | Recover a purchase. | `state: PurchaseUnknown`, `machine: Machine` | `Future[Option[State]]` |

### Dependencies

The Purchase module requires the following dependencies:

- **marketplace** - Used for `requestStorage`, `withdrawFunds`, and subscriptions for request events
- **clock** - Provides timing utilities for expiry and scheduling logic
- **nim-chronos** - Async runtime for futures, awaiting I/O, and cancellation handling
- **asyncstatemachine** - Base state machine framework for implementing the purchase lifecycle
- **hashes** - Standard Nim hashing for `PurchaseId`
- **questionable** - Used for optional fields like `request`

### State Machine Implementation

Based on the specification, implementations should use the `asyncstatemachine` framework as the base for the Purchase state machine. The `Purchase` object extends `Machine` from this framework.

### Recovery Implementation

The `unknown` state implements recovery by:

1. Calling `marketplace.getRequest` to retrieve the `StorageRequest` data
2. Calling `marketplace.requestState` to determine the current `RequestState`
3. Transitioning to the appropriate state based on the marketplace response

### Fund Withdrawal

Terminal states (`finished`, `failed`, `cancelled`) all call `marketplace.withdrawFunds` to release locked funds. Implementations must ensure this call is made before the state machine stops.

## Security/Privacy Considerations

### Safety Requirements

The specification defines the following safety requirements:

- Implementations must avoid side effects during `new` other than initialising internal fields
- `on-chain` interactions must be delegated to states using `marketplace` dependency
- A retry policy for external calls should be implemented

### State Machine Safety

The deterministic state machine design ensures:

- Every purchase reaches exactly one terminal state (`finished`, `cancelled`, or `errored`)
- The `failed` state is an intermediate state that always transitions to `errored`
- State transitions follow the defined state diagram without cycles in terminal states

### Fund Management Safety

All terminal paths (`finished`, `failed`, `cancelled`) call `marketplace.withdrawFunds` as specified in the state descriptions. This ensures locked funds are released when purchases complete or fail.

### Recovery Safety

The `unknown` state enables recovery after restarts by querying the marketplace for current state. The specification requires that it must be possible to restore any purchase from its `requestId` after a restart.

## Rationale

This specification is based on the Purchase module component specification from the Codex project.

### State Machine Pattern

The specification uses a state machine pattern for managing purchase lifecycles. This design provides:

- **Deterministic state transitions**: As documented in the state diagram, purchases follow well-defined paths
- **Explicit terminal states**: Three terminal states (`finished`, `cancelled`, `errored`) clearly indicate final outcomes
- **Recovery support**: The `unknown` state enables restoration after process restarts as specified in the functional requirements

### Marketplace Abstraction

The marketplace abstraction allows for different backend implementations (on-chain or custom storage systems). The specification notes that "the abstraction could be replaceable: it could point to a different backend or custom storage system in future implementations."

This design separates purchase lifecycle management from marketplace implementation details, with all on-chain interactions delegated to states using the `marketplace` dependency as specified in the safety requirements.

### Async State Machine Framework

The specification requires the `asyncstatemachine` dependency for the base state machine framework and `nim-chronos` for async runtime. The `Purchase` object extends `Machine` from this framework, and state transitions are non-blocking with async I/O as specified in the performance requirements.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### normative

- **Codex Marketplace Specification**: [Marketplace Spec](https://github.com/codex-storage/codex-spec/blob/master/specs/marketplace.md) - Defines the client role and protocol requirements
- **Codex Purchase Implementation**: [GitHub - codex-storage/nim-codex](https://github.com/codex-storage/nim-codex)
- **Codex Documentation**: [Codex Docs - Component Specification - Purchase](https://github.com/codex-storage/codex-docs-obsidian/blob/main/10%20Notes/Specs/Component%20Specification%20-%20Purchase.md)

### informative

- **Nim Chronos**: [GitHub - status-im/nim-chronos](https://github.com/status-im/nim-chronos) - Async/await framework for Nim
- **RFC 2119**: Key words for use in RFCs to Indicate Requirement Levels
- **Codex Marketplace**: Smart contract or backend system managing storage agreements
