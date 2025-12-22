# NOMOS-SDP

| Field | Value |
| --- | --- |
| Name | Nomos Service Declaration Protocol Specification |
| Status | raw |
| Editor | Marcin Pawlowski <marcin@status.im> |
| Contributors | Mehmet <mehmet@status.im>, Daniel Sanchez Quiros <danielsq@status.im>, Álvaro Castro-Castilla <alvaro@status.im>, Thomas Lavaur <thomaslavaur@status.im>, Filip Dimitrijevic <filip@status.im>, Gusto Bacvinka <augustinas@status.im>, David Rusu <davidrusu@status.im> |

## Introduction

This document defines a mechanism enabling validators to declare their participation in specific protocols that require a known and agreed-upon list of participants. Some examples of this are Data Availability and the Blend Network. We create a single repository of identifiers which is used to establish secure communication between validators and provide services. Before being admitted to the repository, the validator proves that it locked at least a minimum stake.

## Requirements

The requirements for the protocol are defined as follows:

- A declaration must be backed by a confirmation that the sender of the declaration owns a certain value of the stake.
- A declaration is valid until it is withdrawn or is not used for a service-specific amount of time.

## Overview

The SDP enables nodes to declare their eligibility to serve a specific service in the system, and withdraw their declarations.

### Protocol Actions

The protocol defines the following actions:

- **Declare**: A node sends a declaration that confirms its willingness to provide a specific service, which is confirmed by locking a threshold of stake.
- **Active**: A node marks that its participation in the protocol is active according to the service-specific activity logic. This action enables the protocol to monitor the node's activity. We utilize this as a non-intrusive differentiator of node activity. It is crucial to exclude inactive nodes from the set of active nodes, as it enhances the stability of services.
- **Withdraw**: A node withdraws its declaration and stops providing a service.

The logic of the protocol is straightforward:

1. A node sends a declaration message for a specific service and proves it has a minimum stake.
2. The declaration is registered on the ledger, and the node can commence its service according to the service-specific service logic.
3. After a service-specific service-providing time, the node confirms its activity.
4. The node must confirm its activity with a service-specific minimum frequency; otherwise, its declaration is inactive.
5. After the service-specific locking period, the node can send a withdrawal message, and its declaration is removed from the ledger, which means that the node will no longer provide the service.

💡 The protocol messages are subject to a finality that means messages become part of the immutable ledger after a delay. The delay at which it happens is defined by the consensus.

## Construction

In this section, we present the main constructions of the protocol. First, we start with data definitions. Second, we describe the protocol actions. Finally, we present part of the Bedrock Mantle design responsible for storing and processing SDP-related messages and data.

### Data

In this section, we discuss and define data types, messages, and their storage.

#### Service Types

We define the following services which can be used for service declaration:

- `BN`: for Blend Network service.
- `DA`: for Data Availability service.

```python
class ServiceType(Enum):
    BN="BN"  # Blend Network
    DA="DA"  # Data Availability
```

A declaration can be generated for any of the services above. Any declaration that is not one of the above must be rejected. The number of services might grow in the future.

#### Minimum Stake

The minimum stake is a global value that defines the minimum stake a node must have to perform any service.

The `MinStake` is a structure that holds the value of the stake `stake_threshold` and the block number it was set at: `timestamp`.

```python
class MinStake:
    stake_threshold: StakeThreshold
    timestamp: BlockNumber
```

The `stake_thresholds` is a structure aggregating all defined `MinStake` values.

```python
stake_thresholds: list[MinStake]
```

For more information on how the minimum stake is calculated, please refer to the Nomos documentation.

#### Service Parameters

The service parameters structure defines the parameters set necessary for correctly handling interaction between the protocol and services. Each of the service types defined above must be mapped to a set of the following parameters:

- `session_length` defines the session length expressed as the number of blocks; the sessions are counted from block `timestamp`.
- `lock_period` defines the minimum time (as a number of sessions) during which the declaration cannot be withdrawn, this time must include the period necessary for finalizing the declaration (which might be implicit) and provision of a service for least a single session; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `inactivity_period` defines the maximum time (as a number of sessions) during which an activation message must be sent; otherwise, the declaration is considered inactive; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `retention_period` defines the time (as a number of sessions) after which the declaration can be safely deleted by the Garbage Collection mechanism; it can be expressed as the number of blocks by multiplying its value by the `session_length`.
- `timestamp` defines the block number at which the parameter was set.

```python
class ServiceParameters:
    session_length: NumberOfBlocks
    lock_period: NumberOfSessions
    inactivity_period: NumberOfSessions
    retention_period: NumberOfSessions
    timestamp: BlockNumber
```

The `parameters` is a structure aggregating all defined `ServiceParameters` values.

```python
parameters: list[ServiceParameters]
```

#### Identifiers

We define the following set of identifiers which are used for service-specific cryptographic operations:

- `provider_id`: used to sign the SDP messages and to establish secure links between validators; it is `Ed25519PublicKey`.
- `zk_id`: used for zero-knowledge operations by the validator that includes rewarding ([Zero Knowledge Signature Scheme (ZkSignature)](https://www.notion.so/Zero-Knowledge-Signature-Scheme-ZkSignature-21c261aa09df8119bfb2dc74a3430df6?pvs=21)).

#### Locators

A `Locator` is the address of a validator which is used to establish secure communication between validators. It follows the [multiaddr addressing scheme from libp2p](https://docs.libp2p.io/concepts/fundamentals/addressing/), but it must contain only the location part and must not contain the node identity (`peer_id`).

The `provider_id` must be used as the node identity. Therefore, the `Locator` must be completed by adding the `provider_id` at the end of it, which makes the `Locator` usable in the context of libp2p.

The length of the `Locator` is restricted to 329 characters.

The syntax of every `Locator` entry must be validated.

**The common formatting of every** `Locator` **must be applied to maintain its unambiguity, to make deterministic ID generation work consistently.** The `Locator` must at least contain only lower case letters and every part of the address must be explicit (no implicit defaults).

#### Declaration Message

The construction of the declaration message is as follows:

```python
class DeclarationMessage:
    service_type: ServiceType
    locators: list[Locator]
    provider_id: Ed25519PublicKey 
    zk_id: ZkPublicKey
```

The `locators` list length must be limited to reduce the potential for abuse. Therefore, the length of the list cannot be longer than 8.

The message must be signed by the `provider_id` key to prove ownership of the key that is used for network-level authentication of the validator. The message is also signed by the `zk_id` key (by default all Mantle transactions are signed with `zk_id` key).

#### Declaration Storage

Only valid declaration messages can be stored on the ledger. We define the `DeclarationInfo` as follows:

```python
class DeclarationInfo:
    service: ServiceType
    provider_id: Ed25519PublicKey
    zk_id: ZkPublicKey
    locators: list[Locator]
    created: BlockNumber
    active: BlockNumber
    withdrawn: BlockNumber
    nonce: Nonce
```

Where:

- `service` defines the service type of the declaration;
- `provider_id` is an `Ed25519PublicKey` used to sign the message by the validator;
- `zk_id` is used for zero-knowledge operations by the validator that includes rewarding ([Zero Knowledge Signature Scheme (ZkSignature)](https://www.notion.so/Zero-Knowledge-Signature-Scheme-ZkSignature-21c261aa09df8119bfb2dc74a3430df6?pvs=21));
- `locators` are a copy of the `locators` from the `DeclarationMessage`;
- `created` refers to the block number of the block that contained the declaration;
- `active` refers to the latest block number for which the active message was sent (it is set to `created` by default);
- `withdrawn` refers to the block number for which the service declaration was withdrawn (it is set to 0 by default).
- The `nonce` must be set to 0 for the declaration message and must increase monotonically by every message sent for the `declaration_id`.

We also define the `declaration_id` (of a `DeclarationId` type) that is the unique identifier of `DeclarationInfo` calculated as a hash of the concatenation of `service`, `provider_id`, `locators` and `zk_id`. The implementation of the hash function is `blake2b` using 256 bits of the output.

```python
declaration_id = Hash(service||provider_id||zk_id||locators)
```

The `declaration_id` is not stored as part of the `DeclarationInfo` but it is used to index it.

All `DeclarationInfo` references are stored in the `declarations` and are indexed by `declaration_id`.

```python
declarations: list[declaration_id]
```

#### Active Message

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

#### Withdraw Message

The construction of the withdraw message is as follows:

```python
class WithdrawMessage:
    declaration_id: DeclarationId
    nonce: Nonce
```

The message must be signed by the `zk_id` key from the `declaration_id`.

The `nonce` must increase monotonically by every message sent for the `declaration_id`.

#### Indexing

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

### Protocol

#### Declare

The Declare action associates a validator with a service it wants to provide. It requires sending a valid `DeclarationMessage` (as defined in Declaration Message), which is then processed (as defined below) and stored (as defined in Declaration Storage).

The declaration message is considered valid when all of the following are met:

- The sender meets the stake requirements.
- The `declaration_id` is unique.
- The sender knows the secret behind the `provider_id` identifier.
- The length of the `locators` list must not be longer than 8.
- The `nonce` is increasing monotonically.

If all of the above conditions are fulfilled, then the message is stored on the ledger; otherwise, the message is discarded.

#### Active

The Active action enables marking the provider as actively providing a service. It requires sending a valid `ActiveMessage` (as defined in Active Message), which is relayed to the service-specific node activity logic (as indicated by the service type in Common SDP Structures).

The Active action updates the `active` value of the `DeclarationInfo`, which means that it also activates inactive (but not expired) providers.

The SDP active action logic is:

1. A node sends a `ActiveMessage` transaction.
2. The `ActiveMessage` is verified by the SDP logic.
    a. The `declaration_id` returns an existing `DeclarationInfo`.
    b. The transaction containing `ActiveMessage` is signed by the `zk_id`.
    c. The `withdrawn` from the `DeclarationInfo` is set to zero.
    d. The `nonce` is increasing monotonically.
3. If any of these conditions fail, discard the message and stop processing.
4. The message is processed by the service-specific activity logic alongside the `active` value indicating the period since the last active message was sent. The `active` value comes from the `DeclarationInfo`.
5. If the service-specific activity logic approves the node active message, then the `active` field of the `DeclarationInfo` is set to the current block height.

#### Withdraw

The withdraw action enables a withdrawal of a service declaration. It requires sending a valid `WithdrawMessage` (as defined in Withdraw Message). The withdrawal cannot happen before the end of the locking period, which is defined as the number of blocks counted since `created`. This lock period is stored as `lock_period` in the Service Parameters.

The logic of the withdraw action is:

1. A node sends a `WithdrawMessage` transaction.
2. The `WithdrawMessage` is verified by the SDP logic:
    a. The `declaration_id` returns an existing `DeclarationInfo`.
    b. The transaction containing `WithdrawMessage` is signed by the `zk_id`.
    c. The `withdrawn` from `DeclarationInfo` is set to zero.
    d. The `nonce` is increasing monotonically.
3. If any of the above is not correct, then discard the message and stop.
4. Set the `withdrawn` from the `DeclarationInfo` to the current block height.
5. Unlock the stake.

#### Garbage Collection

The protocol requires a garbage collection mechanism that periodically removes unused `DeclarationInfo` entries.

The logic of garbage collection is:

For every `DeclarationInfo` in the `declarations` set, remove the entry if either:

1. The entry is past the retention period: `withdrawn + retention_period < current_block_height`.
2. The entry is inactive beyond the inactivity and retention periods: `active + inactivity_period + retention_period < current_block_height`.

#### Query

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

### Mantle and ZK Proof

For more information about the Mantle and ZK proofs, please refer to [Mantle Specification](https://www.notion.so/Mantle-Specification-21c261aa09df810c8820fab1d78b53d9?pvs=21).

## Appendix

### Future Improvements

Refer to the [Mantle Specification](https://www.notion.so/Mantle-Specification-21c261aa09df810c8820fab1d78b53d9?pvs=21) for a list of potential improvements to the protocol.

## References

- Mantle and ZK Proof: [Mantle Specification](https://www.notion.so/Mantle-Specification-21c261aa09df810c8820fab1d78b53d9?pvs=21)
- Ed25519 Digital Signatures: [RFC 8032](https://datatracker.ietf.org/doc/html/rfc8032)
- BLAKE2b Cryptographic Hash: [RFC 7693](https://datatracker.ietf.org/doc/html/rfc7693)
- libp2p Multiaddr: [Addressing Specification](https://docs.libp2p.io/concepts/fundamentals/addressing/)
- Zero Knowledge Signatures: [ZkSignature Scheme](https://www.notion.so/Zero-Knowledge-Signature-Scheme-ZkSignature-21c261aa09df8119bfb2dc74a3430df6?pvs=21)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
