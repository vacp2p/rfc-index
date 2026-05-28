# SERVICE-DECLARATION-PROTOCOL

| Field | Value |
| --- | --- |
| Name | Service Declaration Protocol |
| Slug | 87 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski <marcin@logos.co> |
| Contributors | Mehmet Gonen <mehmet@logos.co>, Daniel Sanchez Quiros <danielsq@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Thomas Lavaur <thomaslavaur@logos.co>, Gusto Bacvinka <augustinas@logos.co>, David Rusu <davidrusu@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-27** — [`b7602ed`](https://github.com/logos-co/logos-lips/blob/b7602ed8a225d41ca0bfaaa432524dc84d2ded7e/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — chore: move blockchain specs from notion to github
- **2026-05-18** — [`58b5698`](https://github.com/logos-co/logos-lips/blob/58b56988429f4d69a9e10a9fc118725e229e37c5/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — chore(blockchain): migrate contributor emails to @logos.co (#338)
- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

| **Version** | **Changes** | **Date** |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-04-09 |

# Introduction

This document defines a mechanism enabling validators to declare their participation in specific protocols that require a known and agreed-upon list of participants. One example of this is the Blend Network. We create a single repository of identifiers which is used to establish secure communication between validators and provide services. Before being admitted to the repository, the validator proves that it locked at least a minimum stake.

## Requirements

The requirements for the protocol are defined as follows:

- A declaration must be backed by a confirmation that the sender of the declaration owns a certain value of the stake.
- A declaration is valid until it is withdrawn or is not used for a service-specific amount of time.

# Overview

The SDP enables nodes to declare their eligibility to serve a specific service in the system, and withdraw their declarations.

## Protocol

The protocol defines the following actions:

- **Declare:** A node sends a declaration that confirms its willingness to provide a specific service, which is confirmed by locking a threshold of stake.
- **Active:** A node marks that its participation in the protocol is active according to the service-specific activity logic. This action enables the protocol to monitor the node’s activity. We utilize this as a non-intrusive differentiator of node activity. It is crucial to exclude inactive nodes from the set of active nodes, as it enhances the stability of services.
- **Withdraw:** A node withdraws its declaration and stops providing a service.

The logic of the protocol is straightforward.

1. A node sends a declaration message for a specific service and proves it has a minimum stake.
2. The declaration is registered on the Ledger, and the node can commence its service according to the service-specific service logic.
3. After a service-specific service-providing time, the node confirms its activity.
4. The node must confirm its activity with a service-specific minimum frequency; otherwise, its declaration is inactive.
5. After the service-specific locking period, the node can send a withdrawal message, and its declaration is removed from the Ledger (after necessary retention period), which means that the node will no longer provide the service.

  The protocol messages are subject to a finality that means messages become part of the immutable ledger after a delay. The delay at which it happens is defined by the consensus. Therefore, the protocol’s progress must be tracked from the perspective of the latest finalized block, not the tip of the chain. Otherwise, the protocol and services using it would need to handle chain reorganizations, which we must avoid due to their potential to break services.

# Construction

In this section, we present the main constructions of the protocol. First, we start with data definitions. Second, we describe the protocol actions. Finally, we present part of the Bedrock Mantle design responsible for storing and processing SDP-related messages and data.

## Data

In this section, we discuss and define data types, messages, and their storage.

### **Service Types**

We define the following services which can be used for service declaration:

- `BN`: for Blend Network service.

```python
class ServiceType(Enum):
    BN="BN" # Blend Network
```

A declaration can be generated for any of the services above. Any declaration that is not one of the above must be rejected. The number of services might grow in the future.

### Minimum Stake

The minimum stake is a global value that defines the minimum stake a node must have to perform any service.

The `MinStake` is a structure that holds the value of the stake `stake_threshold` and the block number it was set at `timestamp`, which is a `BlockHeight` at which the threshold was set; its `uint64`.

```python
class MinStake:
    stake_threshold: StakeThreshold
    timestamp: BlockHeight
```

The `stake_thresholds` is a structure aggregating all defined `MinStake` values.

```python
stake_thresholds: list[MinStake]
```

For more information on how the minimum stake is calculated, please refer to the [\[1.0.0\]\[Analysis\] Static Minimum Stake Estimation for Service Declaration Protocol](analysis-static-minimum-stake-estimation-for-service-declaration-protocol.md).

### **Service Parameters**

The service parameters structure defines the parameters set necessary for correctly handling interaction between the protocol and services. Each of the service types defined above must be mapped to a set of the following parameters:

- `session_length` defines the session length expressed as the number of blocks; the sessions are counted from block `timestamp`.
- `lock_period` defines the minimum time (as a number of sessions) during which the declaration cannot be withdrawn, this time must include the period necessary for finalizing the declaration (which might be implicit) and provision of a service for at least a single session; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `inactivity_period` defines the maximum time (as a number of sessions) during which an activation message must be sent; otherwise, the declaration is considered inactive; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `retention_period` defines the time (as a number of sessions) after which the declaration can be safely deleted by the Garbage Collection mechanism; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `timestamp` defines the block height at which the parameter was set; its `uint64`.

```python
class ServiceParameters:
    session_length: NumberOfBlocks
    lock_period: NumberOfSessions
    inactivity_period: NumberOfSessions
    retention_period: NumberOfSessions
    timestamp: BlockHeight
```

The `parameters` is a structure aggregating all defined `ServiceParameters` values.

```python
parameters: list[ServiceParameters]
```

### Session Tracking

A session is a fixed-length window defined per service via `ServiceParameters.session_length`. The session length must be at least `k`, which is consensus finality parameter.

Session numbers start at 0 and are computed as follows:

```python
def get_session_number(current_block_number, service_parameters):
    return current_block_number // service_parameters.session_length
```

At the start of session $`n`$, each node takes a snapshot (`get_snapshot_at_block`) of the SDP registry at a specified block height from the finalized part of the chain:

```python
def get_session_snapshot(session_number, service_parameters):
    if session_number < 2:
            # We take the genesis block for the first two sessions
        return get_snapshot_at_block(0)
    # We take the last block of the previous session for the rest of sessions
    return get_snapshot_at_block((session_number - 1) * service_parameters.session_length - 1)
```

The function `get_snapshot_at_block(block_number)` returns the state of the SDP registry at `block_number`, and includes state changes made by that block. This snapshot defines the declaration state for the session—each snapshot updates the common view of the registry. Changes to the declaration registry take effect with a one-session delay: messages sent during session `n` are included in the next snapshot (for session `n+1`).

Sessions 0 and 1 read the snapshot at block 0, because the chain has not yet progressed far enough to provide a later finalized block.

### Identifiers

We define the following set of identifiers which are used for service-specific cryptographic operations

- `provider_id`: used to sign the SDP messages and to establish secure links between validators; it is `Ed25519PublicKey`.
- `zk_id`: used for zero-knowledge operations by the validator that includes rewarding ([Zero Knowledge Signature Scheme (ZkSignature)](bedrock-v1.1-mantle-specification.md#zero-knowledge-signature-scheme-zksignature)).

### **Locators**

A `Locator` is the address of a validator which is used to establish secure communication between validators. It follows the [multiaddr addressing scheme from libp2p](https://docs.libp2p.io/concepts/fundamentals/addressing/), but it must contain only the location part and must not contain the node identity (`peer_id`).

The `provider_id` must be used as the node identity. Therefore, the `Locator` must be completed by adding the `provider_id` at the end of it, which makes the `Locator` usable in the context of libp2p.

The length of the `Locator` is restricted to 329 characters.

The syntax of every `Locator` entry must be validated.

**The common formatting of every** `Locator` **must be applied to maintain its unambiguity, to make deterministic ID generation work consistently.** The `Locator` must at least contain only lower case letters and every part of the address must be explicit (no implicit defaults).

### **Declaration Message**

The construction of the declaration message is as follows.

```python
class DeclarationMessage:
    service_type: ServiceType
    locators: list[Locator]
    provider_id: Ed25519PublicKey
    locked_note_id: NoteId
    zk_id: ZkPublicKey
```

The `locators` list length must be limited to reduce the potential for abuse. Therefore, the length of the list cannot be longer than 8.

The message must be signed by the `provider_id` key to prove ownership of the key that is used for network-level authentication of the validator.

The `locked_node_id` points to a locked node used for minimum stake threshold verification purposes.

The message is also signed by the `zk_id` key.

### **Declaration Storage**

Only valid declaration messages can be stored on the ledger. We define the `DeclarationInfo` as follows:

```python
class DeclarationInfo:
    service: ServiceType
    provider_id: Ed25519PublicKey
    locked_note_id: NoteId
    zk_id: ZkPublicKey
    locators: list[Locator]
    created: BlockHeight
    active: BlockHeight
    withdrawn: BlockHeight
    nonce: Nonce
```

Where:

- `service` defines the service type of the declaration;
- `provider_id` is an `Ed25519PublicKey` used to sign the message by the validator;
- `locked_note_id` is a `NoteId` used for minimum stake threshold verification purposes;
- `zk_id` is used for zero-knowledge operations by the validator that includes rewarding;
- `locators` are a copy of the `locators` from the `DeclarationMessage`;
- `created` refers to the block number of the block that contained the declaration;
- `active` refers to the latest block number for which the active message was sent (it is set to `created` by default);
- `withdrawn` refers to the block number for which the service declaration was withdrawn (it is set to 0 by default).
- The `nonce` must be set to 0 for the declaration message and must increase monotonically by every message sent for the `declaration_id`.

We also define the `declaration_id` (of a `DeclarationId` type) that is the unique identifier of `DeclarationInfo` calculated as a hash of the concatenation of `service`, `provider_id`,  `locators` and `zk_id`. The implementation of the hash function is `blake2b` using 256 bits of the output.

```python
declaration_id = Hash(service||provider_id||zk_id||locators)
```

The `declaration_id` is not stored as part of the `DeclarationInfo` but it is used to index it.

All `DeclarationInfo` references are stored in the `declarations` and are indexed by `declaration_id`.

```python
declarations: list[declaration_id]
```

### Active Message

The construction of the active message is as follows:

```python
class ActiveMessage:
    declaration_id: DeclarationId
    nonce: Nonce
    metadata: Metadata
```

where `metadata` is a service-specific node activeness metadata.

The message must be signed by the `zk_id` key associated with the `declaration_id`.

The `nonce` must increase monotonically by every message sent for the `declaration_id`.

### Withdraw Message

The construction of the withdraw message is as follows:

```python
class WithdrawMessage:
    declaration_id: DeclarationId
    locked_note_id: NoteId
    nonce: Nonce
```

The message must be signed by the `zk_id` key from the `declaration_id`.

The `locked_note_id` is a `NoteId` that was used for minimum stake threshold verification purposes and will be unlocked after withdrawal.

The `nonce` must increase monotonically by every message sent for the `declaration_id`.

### Indexing

Every event must be correctly indexed to enable lighter synchronization of the changes. Therefore, we index every `declaration_id` according to `EventType`, `ServiceType`, and `Timestamp`. Where `EventType = { "created", "active", "withdrawn" }` follows the type of the message.

```python
events = {
    event_type: {
        service_type: {
            timestamp: {
                declarations: list[declaration_id]
            }
        }
    }
}
```

## Protocol

### Declare

The Declare action associates a validator with a service it wants to provide. It requires sending a valid `DeclarationMessage` (as defined in [**Declaration Message**](#declaration-message)), which is then processed (as defined below) and stored (as defined in [**Declaration Storage**](#declaration-storage)).

The declaration message is considered valid when all of the following are met:

- The sender meets the stake requirements and its `locked_note_id` is valid.
- The `declaration_id` is unique.
- The sender knows the secret behind the `provider_id` identifier.
- The length of the `locators` list must not be longer than 8.
- The `nonce` increases monotonically.

If all of the above conditions are fulfilled, then the message is stored on the ledger; otherwise, the message is discarded.

### Active

The Active action enables marking the provider as actively providing a service. It requires sending a valid `ActiveMessage` (as defined in [Active Message](#active-message) ), which is relayed to the service-specific node activity logic (as indicated by the service type in [Common SDP Structures](bedrock-v1.1-mantle-specification.md#common-sdp-structures)).

The Active action updates the `active` value of the `DeclarationInfo`, which means that it also activates inactive (but not expired) providers.

The SDP active action logic is:

1. A node sends a `ActiveMessage` transaction.
2. The `ActiveMessage` is verified by the SDP logic.
1. The `declaration_id` returns an existing `DeclarationInfo`.
2. The transaction containing `ActiveMessage` is signed by the `zk_id`.
3. The `withdrawn` from the `DeclarationInfo` is set to zero.
4. The `nonce` increases monotonically.

3. If any of these conditions fail, discard the message and stop processing.
4. The message is processed by the service-specific activity logic alongside the `active` value indicating the period since the last active message was sent. The `active` value comes from the `DeclarationInfo`.
5. If the service-specific activity logic approves the node active message, then the `active` field of the `DeclarationInfo` is set to the current block height.

### **Withdraw**

The withdraw action enables a withdrawal of a service declaration. It requires sending a valid `WithdrawMessage` (as defined in [Withdraw Message](#withdraw-message)). The withdrawal cannot happen before the end of the locking period, which is defined as the number of blocks counted since `created`. This lock period is stored as `lock_period` in the [**Service Parameters**](#service-parameters).

The logic of the withdraw action is:

1. A node sends a `WithdrawMessage` transaction.
2. The `WithdrawMessage` is verified by the SDP logic.
1. The `declaration_id` returns an existing `DeclarationInfo`.
2. The transaction containing `WithdrawMessage` is signed by the `zk_id`.
3. The `withdrawn` from `DeclarationInfo` is set to zero.
4. The `nonce` increases monotonically.

3. If any of the above is not correct, then discard the message and stop.
4. Set the `withdrawn` from the `DeclarationInfo` to the current block height.
5. Unlock the stake (release the `locked_note_id`).

### Garbage Collection

The protocol requires a garbage collection mechanism that periodically removes unused `DeclarationInfo` entries.

The logic of garbage collection is:

For every `DeclarationInfo` in the `declarations` set, remove the entry if either:

1. The entry is past the retention period: `withdrawn + (retention_period * session_length) < current_block_height`.
2. The entry is inactive beyond the inactivity and retention periods: `active + (inactivity_period + retention_period) * session_length < current_block_height`.

### Query

The protocol must enable querying the ledger in at least the following manner:

- `GetAllProviderId(timestamp)`, returns all `provider_id`s associated with the `timestamp`.
- `GetAllProviderIdSince(timestamp)`, returns all `provider_id`s since the `timestamp`.
- `GetAllDeclarationInfo(timestamp)`, returns all `DeclarationInfo` entries associated with the `timestamp`.
- `GetAllDeclarationInfoSince(timestamp)`, returns all `DeclarationInfo` entries since the `timestamp`.
- `GetDeclarationInfo(provider_id)`, returns the `DeclarationInfo` entry identified by the `provider_id`.
- `GetDeclarationInfo(declaration_id)`, returns the `DeclarationInfo` entry identified by the `declaration_id`.
- `GetAllServiceParameters(timestamp)`, returns all entries of the `ServiceParameters` store for the requested `timestamp`.
- `GetAllServiceParametersSince(timestamp)`, returns all entries of the `ServiceParameters` store since the requested `timestamp`.
- `GetServiceParameters(service_type, timestamp)`, returns the service parameter entry from the `ServiceParameters` store of a `service_type` for a specified `timestamp`.
- `GetMinStake(timestamp)`, returns the `MinStake` structure at the requested `timestamp`.
- `GetMinStakeSince(timestamp)`, returns a set of `MinStake` structures since the requested `timestamp`.

The query must return an error if the retention period for the delegation has passed and the requested information is not available.

The list of queries may be extended.

Every query must return information for a finalized state only.

## Mantle and ZK Proofs

For more information about Mantle and ZK proofs, please refer to [[1.5.0] Mantle](bedrock-v1.1-mantle-specification.md).

# Default Service Parameters

## Blend Network

```python
class BlendNetworkServiceParameters:
    session_length: 21600 # follows the length of an epoch
    lock_period: 1
    inactivity_period: 1
    retention_period: 1
```

The `session_length` follows the length of an epoch as indicated in *Session* is a time during which the same set of core nodes is executing the protocol. When the session ends, a new one starts, and the set of core nodes is refreshed. In this version of the protocol, the length of the session follows the length of an epoch. However, we define the length of a session as the average number of blocks in an epoch, i.e. 648,000 slots, that is, $`21,600`$ blocks. This value is based on the fact that a single block is proposed on average every $`30`$ slots, for the justification see [The Number of Time-Slots Between Two Consecutive Blocks](analysis-resilience-and-anonymity.md#the-number-of-time-slots-between-two-consecutive-blocks)
