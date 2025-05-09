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

This document defines a mechanism enabling validators to declare their participation in specific protocols that require a known and agreed-upon list of participants. Some examples of this are Data Availability and the Blend Network. We create a single repository of identifiers which is then used to establish secure communication between validators and provide services. Before being admitted to the repository, the validator proves that it locked at least a minimum stake.

## Requirements

The requirements for the protocol are defined as follows:

- A declaration must be backed by a confirmation that the sender of the declaration owns a certain value of the stake.
- A declaration is valid until it is withdrawn or is not used for a service-specific amount of time.

## Overview

The SDP enables nodes to declare their eligibility to serve a specific service in the system, and withdraw their declarations.

## Protocol

### Actions

- **Declare**: A node sends a declaration that confirms its willingness to provide a
specific service, which is confirmed by locking a threshold of stake.
- **Active**: A node marks that its participation in the protocol is active according
to the service-specific activity logic. This action enables the protocol to
monitor the node’s activity. We utilize this as a non-intrusive differentiator of
node activity. It is crucial to exclude inactive nodes from the set of active
nodes, as it enhances the stability of services.
- **Withdraw**: A node withdraws its declaration and stops providing a service.

The logic of the protocol:

1. A node sends a declaration message for a specific service and proves it has a minimum stake.
2. The declaration is registered on the ledger, and the node can commence its service according to the service-specific service logic.
3. After a service-specific service-providing time, the node can confirms its activity.
4. The node must confirm its activity with a service-specific minimum frequency; otherwise, its declaration is inactive.
5. After the service-specific locking period, the node can send a withdrawal message, and its declaration is removed from the ledger, which means that the node will no longer provide the service.sage.

Note: The protocol messages are subject to a finality that means messages become part of the immutable ledger after a delay. The delay at which it happens is defined by the consensus.

## Construction

In this section, we present the main constructions of the protocol. First, we start with data definitions. Second, we describe the protocol actions. Finally, we present part of the Bedrock Mantle design responsible for storing and processing SDP-related messages and data.

### Data

In this section, we define the following services which can be used for service declaration:

#### Service Types

Available service types:

- BN : Blend Network
- DA : Data Availability
- EX : Executor Network
- RS : Generic Restaking

A declaration can be generated for any of the services above. Any declaration that is not one of the above must be rejected. The number of services might grow in the future.d.

#### Minimum Stake

The minimum stake is a global value that defines the minimum stake a node must have to perform any service.
The [Min_Stake] is a structure that holds the value of the stake [Stake_Threshold] and the block number it was set at: [Timestamp].

```python
Min_Stake = {
    "Stake_Threshold": Stake_Threshold,
    "Timestamp": Block_Number,
}
```

The [Stake_Thresholds] is a structure aggregating all defined [Min_Stake] values.

``` Stake_Thresholds: Set[Min_Stake]
```

For more information on how the minimum stake is calculated, please refer to the []

#### Service Parameters

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
Parameters: Set[Service_Parameters]
```

#### Locators

Locator is an address of a validator, e.g., `ip://`, `onion://`, `multiaddr`. Max length: 329 chars. Max 8 locators per message.

#### Identifiers

- `Provider_ID`: Ed25519 public key
- `Locators`: For secure networking

#### Declaration Message

```python
Declaration_Message = {
    "Service_Type": "BN" | "DA" | "EX" | "RS",
    "Locators": [Locator],
    "Provider_ID": Ed25519_Public_Key,
}
```

#### Provider Info

```python
Provider_Info = {
    "Provider_ID": Ed25519_Public_Key,
    "Declaration_ID": Declaration_ID,
    "Created": Block_Number,
    "Active": Block_Number,
    "Withdrawn": Block_Number,
}
Providers: Set[Provider_Info]
```

#### Declaration Structure

```python
Declaration = {
    "Declaration_ID": Hash([Locator]),
    "Locators": [Locator],
    "Services": {
        Service_Type: [Provider_ID],
    }
}
Declarations: Set[Declaration]
```

#### Active Message

```python
Active_Message = {
    "Declaration": Declaration_ID,
    "Service": Service_Type,
    "Provider_ID": Ed25519_Public_Key,
    "Nonce": Nonce,
    "Metadata": Metadata,
}
```

#### Withdraw Message

```python
Withdraw_Message = {
    "Declaration": Declaration_ID,
    "Service": Service_Type,
    "Provider_ID": Ed25519_Public_Key,
    "Nonce": Nonce,
}
```

## Indexing

Index by:

- `Event_Type`: Declared, Active, Withdrawn
- `Service_Type`
- `Timestamp`

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

## Garbage Collection

Performed periodically or after actions.
Removes `Provider_Info` after `Retention_Period` expires.
Removes empty `Declaration` entries.

## Queries

Required:

- `Get_All_Provider_ID(Timestamp)`
- `Get_All_Provider_ID_Since(Timestamp)`
- `Get_All_Provider_Info(Timestamp)`
- `Get_Provider_Info(Provider_ID)`
- `Get_Declaration(Declaration_ID)`
- `Get_Declaration(Provider_ID)`
- `Get_All_Service_Parameters(Timestamp)`
- `Get_Service_Parameters(Service_Type, Timestamp)`
- `Get_Min_Stake(Timestamp)`

Query must return only finalized state. Return error if retention expired.

## Mantle and ZK Proof

See [Mantle Specification](https://www.notion.so/Mantle-Specification-1ba8f96fb65c8076ba00ecff00e7a3a4)

## Appendix

See linked document for future protocol improvements.
