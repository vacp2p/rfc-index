---
title: SDP
name: Service Declaration Protocol Specification
status: raw
category: 
tags: participation, validators, declarations
editor: Marcin Pawlowski <marcin@status.im>
contributors:
- Mehmet <mehmet@status.im>
- Daniel Sanchez Quiros <danielsq@status.im>
- Álvaro Castro-Castilla <alvaro@status.im>
- Thomas Lavaur <thomaslavaur@status.im>
- Filip Dimitrijevic <filip@status.im>
---

## Introduction

This document defines a mechanism enabling validators
to declare their participation in specific protocols
that require a known and agreed-upon list of participants.
Some examples of this are Data Availability and the Blend Network.
We create a single repository of identifiers
which is then used to establish secure communication between validators and provide services.
Before being admitted to the repository,
the validator proves that it locked at least a minimum stake.

## Requirements

The requirements for the protocol are defined as follows:

- A declaration must be backed by a confirmation that the sender of the declaration owns a certain value of the stake.
- A declaration is valid until it is withdrawn or is not used for a service-specific amount of time.

## Overview

The SDP enables nodes to declare their eligibility to serve a specific service in the system, and withdraw their declarations.

### Protocol

- **Declare**: A node sends a declaration that confirms its willingness to provide a specific service,
which is confirmed by locking a threshold of stake.
- **Active**: A node marks that its participation in the protocol is active
according to the service-specific activity logic.
This action enables the protocol to monitor the node’s activity.
We utilize this as a non-intrusive differentiator of node activity.
It is crucial to exclude inactive nodes from the set of active nodes,
as it enhances the stability of services.
- **Withdraw**: A node withdraws its declaration and stops providing a service.

The logic of the protocol:

1. A node sends a declaration message for a specific service
and proves it has a minimum stake.
2. The declaration is registered on the ledger,
and the node can commence its service according to the service-specific service logic.
3. After a service-specific service-providing time,
the node can confirms its activity.
4. The node must confirm its activity with a service-specific minimum frequency;
otherwise, its declaration is inactive.
5. After the service-specific locking period,
the node can send a withdrawal message,
and its declaration is removed from the ledger,
which means that the node will no longer provide the service.

💡 The protocol messages are subject to a finality
that means messages become part of the immutable ledger after a delay.
The delay at which it happens is defined by the consensus.

## Construction

In this section, we present the main constructions of the protocol.
First, we start with data definitions.
Second, we describe the protocol actions.
Finally, we present part of the Bedrock Mantle design
responsible for storing and processing SDP-related messages and data.

### Data

In this section, we discuss and define data types, messages, and their storage.

#### Service Types

We define the following services which can be used for service declaration:

- **BN** : for Blend Network service  
- **DA** : for Data Availability service  
- **EX** : for Executor Network service  
- **RS** : for Generic Restaking service

A declaration can be generated for any of the services above.
Any declaration that is not one of the above must be rejected.
The number of services might grow in the future.

#### Minimum Stake

The minimum stake is a global value that defines the minimum stake a node must have to perform any service.

The `Min_Stake` is a structure that holds the value of the stake `Stake_Threshold` and
the block number it was set at: `Timestamp`.

```python
Min_Stake = {
    "Stake_Threshold": Stake_Threshold,
    "Timestamp": Block_Number,
}
```

The `Stake_Thresholds` is a structure aggregating all defined `Min_Stake` values.

```python
Stake_Thresholds: Set[Min_Stake]
```

For more information on how the minimum stake is calculated,
please refer to the Nomos documentation.
<!--- Get the url for the minimum stake calculation documentation --->

#### Service Parameters

The service parameters structure defines the parameters set necessary for correctly handling
interaction between the protocol and services.
The service types defined above must be mapped to a set of the following parameters:

- `Lock_Period` defines the minimum time (as a number of blocks) during which the
declaration cannot be withdrawn.
- `Inactivity_Period` defines the maximum time (as a number of blocks)
during which an activation message must be sent;
otherwise, the declaration is considered inactive.
- `Retention_Period` defines the time (as a number of blocks)
after which the declaration can be safely deleted
by the Garbage Collection mechanism.
- `Activity_Contract` defines the address of a service-specific contract
defining the rules of node activity.
This is an abstraction that is used to point to a service-specific node activity logic.
- `Timestamp` defines the block number at which the parameter was set.

```python
Service_Parameters = {
    Service_Type: {
        "Lock_Period": Number_of_Blocks,
        "Inactivity_Period": Number_of_Blocks,
        "Retention_Period": Number_of_Blocks,
        "Activity_Contract": Contract_Address,
        "Timestamp": Block_Number,
    }
}
```

The `Parameters` is a structure aggregating all defined `Service_Parameters` values.

```python
Parameters: Set[Service_Parameters]
```

#### Locators

A `Locator` is the address of a validator which
is used to establish secure communication between validators.
It consists of a cryptographic key and network identifier of the validator.
It can be realized for example by URI-defined scheme plus authority.

Examples:

- `ip://123.4.5.6:port`,
- `onion://validonionaddress:port`,
- multiaddr (libp2p)

Constraints:

- Max length: 329 characters
- Max `locators` per declaration: 8
- Syntax of every `Locator entry` must be validated

#### Identifiers

We define the following set of identifiers which
are used for service-specific cryptographic operations.

- `Provider_ID`: used to authenticate the validator.
- `Locators`: used to establish secure network links between validators.

#### Declaration Message

The construction of the declaration message is as follows.

```python
Declaration_Message = {
    "Service_Type": "BN" | "DA" | "EX" | "RS",
    "Locators": [Locator],
    "Provider_ID": Ed25519_Public_Key,
}
```

The `Locators` field length must be limited to reduce the potential for abuse.
Therefore, the number of `Locator` values that can be defined is 8.

#### Declaration Storage

Only valid declaration messages can be stored on the ledger.
We define the `Provider_Info` as follows:

```python
Provider_Info = {
    "Provider_ID": Ed25519_Public_Key,
    "Declaration_ID": Declaration_ID,
    "Created": Block_Number,
    "Active": Block_Number,
    "Withdrawn": Block_Number,
}
```

where `Declaration_ID` is a unique identifier of the declaration and is defined below,
the `Created` refers to the block number of the block that contained the declaration,
the `Active` refers to the latest block number for which the active message was sent
(it is set to `Created` by default),
and the `Withdrawn` refers to the block number for which the service declaration was withdrawn
(it is set to 0 by default).

All `Provider_Info` entries are stored in the `Providers`:

```python
Providers: Set[Provider_Info]
```

Now we define a `Declaration` structure where:

- `Declaration_ID` is a unique identifier of the `Declaration` calculated as a hash from the
- `Locators set`. The implementation of the hash function is `blake2b`.
- `Locators` are a copy of the `Locators` from the `Declaration_Message`.
- `Services` are a mapping of a `Service_Type` on the `Provider_ID` set.

```python
Declaration = {
    "Declaration_ID": Hash([Locator]),
    "Locators": [Locator],
    "Services": {
        Service_Type: [Provider_ID],
    }
}
```

The `Declaration` enables us to aggregate all `Provider_Info` entries
under the same set of locators, which saves storage space.
We allow for 1 to many mapping of `Service_Type` to `Provider_ID`
as we do not verify the ownership of the `Locators` at the moment.
Therefore, we eliminate the risk of an adversary overwriting the `Provider_ID`.
All `Declaration` entries are stored in the `Declarations`:

```python
Declarations: Set[Declaration]
```

#### Active Message

The construction of the active message is as follows:

```python
Active_Message = {
    "Declaration": Declaration_ID,
    "Service": Service_Type,
    "Provider_ID": Ed25519_Public_Key,
    "Nonce": Nonce,
    "Metadata": Metadata,
}
```

Where `Metadata` is a service-specific node activeness metadata.

#### Withdraw Message

The construction of the withdraw message is as follows:

```python
Withdraw_Message = {
    "Declaration": Declaration_ID,
    "Service": Service_Type,
    "Provider_ID": Ed25519_Public_Key,
    "Nonce": Nonce,
}
```

#### Indexing

Every event must be correctly indexed to enable lighter synchronization of the changes.
Therefore, we index every `Provider_ID` according to `Event_Type`, `Service_Type`, and `Timestamp`.
Where `Event_Type = { Declared, Active, Withdrawn }` follows the type of the message.

```python
Events = {
    Event_Type: {
        Service_Type: {
            Timestamp: {
                "Providers": [Provider_ID]
            }
        }
    }
}
```

### Protocal

#### Declare

The Declare action associates a validator with a service it wants to provide.
It requires sending a valid `Declaration_Message` (as defined in ),
which then is processed (as defined below) and stored (as defined in).
The declaration message is considered valid when all of the following are met:

- The sender meets the stake requirements.
- The sender knows the secret behind the `Provider_ID` identifier.
- The Provider_ID is generated either for `BN`, `DA`, `EX` or `RS`.
- The length of the `locators` list must not be longer than 8.
If all of the above conditions are fulfilled, then the message is stored on the ledger;
otherwise, the message is discarded.

#### Active

The Active action enables marking the provider as actively providing a service.
It requires sending a valid `Active_Message`,
which is relayed to the service-specific node activity logic (as indicated by the `Activity_Contract`).

The SDP active action logic is:

1. A node sends an `Active_Message` transaction.

2. The `Active_Message` is verified by the SDP logic:

    a. The `Active_Message` is signed by the `Provider_ID`.  
    b. The `Provider_ID` matches a `Service` in the `Declaration` as provided in the message.  
    c. The `Withdrawn` from `Provider_Info` of the `Provider_ID` is set to zero.  
    d. The `Nonce` is unique.

3. If any of the above is not correct, then discard the message and stop.

4. The message is forwarded to the `Activity_Contract` alongside the `Active` value  
   indicating the period since the last active message was sent.  
   The `Active` value comes from the `Provider_Info`.

5. If the `Activity_Contract` approves the node active message,
   then the `Active` field of the `Provider_Info` identified by the `Provider_ID`
   is set to the current block height.

#### Withdraw

The withdraw action enables a withdrawal of a service declaration.
It requires sending a valid `Withdraw_Message` (as defined in the specification).
The withdrawal cannot happen before the end of the locking period,
which is defined as the number of blocks counted since `Created`.
This lock period is stored as `Lock_Period` in the `Service_Parameters`.

The logic of the withdraw action is:

1. A node sends a `Withdraw_Message` transaction.

2. The `Withdraw_Message` is verified by the SDP logic:

    a. The `Withdraw_Message` is signed by the `Provider_ID`.  
       If the message is bound to a ZK proof then we can drop the signature,  
       as the ZK proof confirms the knowledge of a secret behind the `Provider_ID`.
    b. The `Provider_ID` matches a `Service` in the `Declaration` as provided in the message.  
    c. The `Withdrawn` from `Provider_Info` of the `Provider_ID` is set to zero.  
    d. The `Nonce` is unique.

3. If any of the above is not correct, then discard the message and stop.

#### Garbage Collection

The protocol requires a garbage collection mechanism
that periodically removes empty `Declaration` entries.
A `Declaration` is considered empty when it does not contain any active `Provider_Info` entries.

The logic of garbage collection is:

1. For every `Declaration` in the `Declarations` set:

    a. For every `Provider_ID` entry of the `Declaration`:
        i. Retrieve `Provider_Info` using `Provider_ID`.
        ii. If `Provider_Info.Withdrawn + Retention_Period` is smaller than the current block
        height, then remove the `Provider_Info` entry.  
        The `Provider_Info` is past the retention period.
        iii. If `Provider_Info.Active + Inactivity_Period + Retention_Period` is smaller than the
        current block height, then remove the `Provider_Info` entry.  
        The `Provider_Info` is inactive for more than the retention period,  
        which qualifies the entry for removal.
    b. If the `Declaration` does not contain any `Provider_Info` entries, then remove the
       `Declaration` entry.

💡 Step "a" of the garbage collection logic can be executed as the last step of
the `Declare`, `Active`, and `Withdraw` actions,
but only in the context of the `Declaration` associated with that action.

#### Query

The protocol must enable querying the ledger in at least the following manner:

- `Get_All_Provider_ID(Timestamp)`  
  Returns all `Provider_ID`s associated with the `Timestamp`.

- `Get_All_Provider_ID_Since(Timestamp)`  
  Returns all `Provider_ID`s since the `Timestamp`.

- `Get_All_Provider_Info(Timestamp)`  
  Returns all `Provider_Info` entries associated with the `Timestamp`.

- `Get_All_Provider_Info_Since(Timestamp)`  
  Returns all `Provider_Info` entries since the `Timestamp`.

- `Get_Provider_Info(Provider_ID)`  
  Returns the `Provider_Info` entry identified by the `Provider_ID`.

- `Get_Declaration(Declaration_ID)`  
  Returns the `Declaration` entry identified by the `Declaration_ID`.

- `Get_Declaration(Provider_ID)`  
  Returns the `Declaration` entry identified by the `Provider_ID`.

- `Get_All_Service_Parameters(Timestamp)`  
  Returns all entries of the `Service_Parameters` store for the requested `Timestamp`.

- `Get_All_Service_Parameters_Since(Timestamp)`  
  Returns all entries of the `Service_Parameters` store since the requested `Timestamp`.

- `Get_Service_Parameters(Service_Type, Timestamp)`  
  Returns the service parameter entry from the `Service_Parameters` store of a `Service_Type` for a specified `Timestamp`.

- `Get_Min_Stake(Timestamp)`  
  Returns the `Min_Stake` structure at the requested `Timestamp`.

- `Get_Min_Stake_Since(Timestamp)`  
  Returns a set of `Min_Stake` structures since the requested `Timestamp`.

Additional notes:

- The query must return an error if the retention period for the delegation has passed
  and the requested information is not available.
- The list of queries may be extended.
- Every query must return information for a finalized state only.

### Mantle and ZK Proof

For more information about the Mantle and ZK proofs, please refer to see [Mantle Specification](https://www.notion.so/Mantle-Specification-1ba8f96fb65c8076ba00ecff00e7a3a4)

## Appendix

### Future Improvements

Refer to the [Mantle Specification](https://www.notion.so/Mantle-Specification-1ba8f96fb65c8076ba00ecff00e7a3a4)
for a list of potential improvements to the protocol.

## References

- Mantle and ZK Proof: [Mantle Specification](https://www.notion.so/Mantle-Specification-1ba8f96fb65c8076ba00ecff00e7a3a4)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
