# BEDROCK-SERVICE-DECLARATION-PROTOCOL

| Field | Value |
| --- | --- |
| Name | Bedrock Service Declaration Protocol |
| Slug | 87 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski <marcin@logos.co> |
| Contributors | Mehmet Gonen <mehmet@logos.co>, Daniel Sanchez Quiros <danielsq@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Thomas Lavaur <thomaslavaur@logos.co>, Gusto Bacvinka <augustinas@logos.co>, David Rusu <davidrusu@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-service-declaration-protocol.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

---

> **Note on this content sync:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) via katex; tables and headings
> are converted from Notion HTML. Formatting polish (semantic line breaks, code block fences,
> internal cross-references) may still be needed.

---

## Revision History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2026-04-09 |

## Introduction

This document defines a mechanism enabling validators to declare their participation in specific protocols that require a known and agreed-upon list of participants. One example of this is the Blend Network. We create a single repository of identifiers which is used to establish secure communication between validators and provide services. Before being admitted to the repository, the validator proves that it locked at least a minimum stake.

### Requirements

The requirements for the protocol are defined as follows:

A declaration must be backed by a confirmation that the sender of the declaration owns a certain value of the stake.

A declaration is valid until it is withdrawn or is not used for a service-specific amount of time.

## Overview

The SDP enables nodes to declare their eligibility to serve a specific service in the system, and withdraw their declarations.

### Protocol

The protocol defines the following actions:

Declare: A node sends a declaration that confirms its willingness to provide a specific service, which is confirmed by locking a threshold of stake.

Active: A node marks that its participation in the protocol is active according to the service-specific activity logic. This action enables the protocol to monitor the nodes activity. We utilize this as a non-intrusive differentiator of node activity. It is crucial to exclude inactive nodes from the set of active nodes, as it enhances the stability of services.

Withdraw: A node withdraws its declaration and stops providing a service.

The logic of the protocol is straightforward.

A node sends a declaration message for a specific service and proves it has a minimum stake.

The declaration is registered on the Ledger, and the node can commence its service according to the service-specific service logic.

After a service-specific service-providing time, the node confirms its activity.

The node must confirm its activity with a service-specific minimum frequency; otherwise, its declaration is inactive.

After the service-specific locking period, the node can send a withdrawal message, and its declaration is removed from the Ledger (after necessary retention period), which means that the node will no longer provide the service.

The protocol messages are subject to a finality that means messages become part of the immutable ledger after a delay. The delay at which it happens is defined by the consensus. Therefore, the protocols progress must be tracked from the perspective of the last included (finalized) block, not the tip of the chain. Otherwise, the protocol and services using it would need to handle chain reorganizations, which we must avoid due to their potential to break services.

## Construction

In this section, we present the main constructions of the protocol. First, we start with data definitions. Second, we describe the protocol actions. Finally, we present part of the Bedrock Mantle design responsible for storing and processing SDP-related messages and data.

### Data

In this section, we discuss and define data types, messages, and their storage.

#### Service Types

We define the following services which can be used for service declaration:

BN

: for Blend Network service.

class ServiceType(Enum):
BN="BN" # Blend Network

A declaration can be generated for any of the services above. Any declaration that is not one of the above must be rejected. The number of services might grow in the future.

#### Minimum Stake

The minimum stake is a global value that defines the minimum stake a node must have to perform any service.

The

MinStake

is a structure that holds the value of the stake

stake\_threshold

and the block number it was set at

timestamp

, which is a

BlockHeight

at which the threshold was set; its

uint64

.

class MinStake:
stake\_threshold: StakeThreshold
timestamp: BlockHeight

The

stake\_thresholds

is a structure aggregating all defined

MinStake

values.

stake\_thresholds: list[MinStake]

For more information on how the minimum stake is calculated, please refer to the [[1.0.0][Analysis] Static Minimum Stake Estimation for Service Declaration Protocol](https://nomos-tech.notion.site/1-0-0-Analysis-Static-Minimum-Stake-Estimation-for-Service-Declaration-Protocol-3a2261aa09df83e2a104012e29c21f34?pvs=24).

#### Service Parameters

The service parameters structure defines the parameters set necessary for correctly handling interaction between the protocol and services. Each of the service types defined above must be mapped to a set of the following parameters:

session\_length

defines the session length expressed as the number of blocks; the sessions are counted from block

timestamp

.

lock\_period

defines the minimum time (as a number of sessions) during which the declaration cannot be withdrawn, this time must include the period necessary for finalizing the declaration (which might be implicit) and provision of a service for at least a single session; it can be expressed as the number of blocks by multiplying its value by the

session\_length

.

inactivity\_period

defines the maximum time (as a number of sessions) during which an activation message must be sent; otherwise, the declaration is considered inactive; it can be expressed as the number of blocks by multiplying its value by the

session\_length

.

retention\_period

defines the time (as a number of sessions) after which the declaration can be safely deleted by the Garbage Collection mechanism; it can be expressed as the number of blocks by multiplying its value by the

session\_length

.

timestamp

defines the block height at which the parameter was set; its

uint64

.

class ServiceParameters:
session\_length: NumberOfBlocks
lock\_period: NumberOfSessions
inactivity\_period: NumberOfSessions
retention\_period: NumberOfSessions
timestamp: BlockHeight

The

parameters

is a structure aggregating all defined

ServiceParameters

values.

parameters: list[ServiceParameters]

#### Session Tracking

A session is a fixed-length window defined per service via

ServiceParameters.session\_length

. The session length must be at least

k

, which is consensus finality parameter.

Session numbers start at 0 and are computed as follows:

def get\_session\_number(current\_block\_number, service\_parameters):
return current\_block\_number // service\_parameters.session\_length

At the start of session $n$ , each node takes a snapshot (

get\_snapshot\_at\_block

) of the SDP registry at a specified block height from the finalized part of the chain:

def get\_session\_snapshot(session\_number, service\_parameters):
if session\_number < 2:
# We take the genesis block for the first two sessions
return get\_snapshot\_at\_block(0)
# We take the last block of the previous session for the rest of sessions
return get\_snapshot\_at\_block((session\_number - 1) \* service\_parameters.session\_length - 1)

The function

get\_snapshot\_at\_block(block\_number)

returns the state of the SDP registry at

block\_number

, and includes state changes made by that block. This snapshot defines the declaration state for the sessioneach snapshot updates the common view of the registry. Changes to the declaration registry take effect with a one-session delay: messages sent during session

n

are included in the next snapshot (for session

n+1

).

Sessions 0 and 1 read the snapshot at block 0, because the chain has not yet progressed far enough to provide a later finalized block.

#### Identifiers

We define the following set of identifiers which are used for service-specific cryptographic operations

provider\_id

: used to sign the SDP messages and to establish secure links between validators; it is 

Ed25519PublicKey

.

zk\_id

: used for zero-knowledge operations by the validator that includes rewarding ([[1.5.0] Mantle - Zero Knowledge Signature Scheme (ZkSignature)](https://nomos-tech.notion.site/Zero-Knowledge-Signature-Scheme-ZkSignature-33d261aa09df8051b0d0cd4d5ddade85?pvs=24#18a261aa09df83a1a2ee81032493cef4)).

#### Locators

A

Locator

is the address of a validator which is used to establish secure communication between validators. It follows the [multiaddr addressing scheme from libp2p](https://docs.libp2p.io/concepts/fundamentals/addressing/), but it must contain only the location part and must not contain the node identity (

peer\_id

).

The 

provider\_id

 must be used as the node identity. Therefore, the 

Locator

 must be completed by adding the 

provider\_id

 at the end of it, which makes the 

Locator

 usable in the context of libp2p.

The length of the

Locator

is restricted to 329 characters.

The syntax of every

Locator

entry must be validated.

The common formatting of every 

Locator

 must be applied to maintain its unambiguity, to make deterministic ID generation work consistently. The

Locator

must at least contain only lower case letters and every part of the address must be explicit (no implicit defaults).

#### Declaration Message

The construction of the declaration message is as follows.

class DeclarationMessage:
service\_type: ServiceType
locators: list[Locator]
provider\_id: Ed25519PublicKey
locked\_note\_id: NoteId
zk\_id: ZkPublicKey

The

locators

list length must be limited to reduce the potential for abuse. Therefore, the length of the list cannot be longer than 8.

The message must be signed by the 

provider\_id

 key to prove ownership of the key that is used for network-level authentication of the validator.

The

locked\_node\_id

points to a locked node used for minimum stake threshold verification purposes.

The message is also signed by the 

zk\_id

 key.

#### Declaration Storage

Only valid declaration messages can be stored on the ledger. We define the

DeclarationInfo

as follows:

class DeclarationInfo:
service: ServiceType
provider\_id: Ed25519PublicKey
locked\_note\_id: NoteId
zk\_id: ZkPublicKey
locators: list[Locator]
created: BlockHeight
active: BlockHeight
withdrawn: BlockHeight
nonce: Nonce

Where:

service

defines the service type of the declaration;

provider\_id

is an

Ed25519PublicKey

used to sign the message by the validator;

locked\_note\_id

is a

NoteId

used for minimum stake threshold verification purposes;

zk\_id

is used for zero-knowledge operations by the validator that includes rewarding;

locators

are a copy of the

locators

from the

DeclarationMessage

;

created

refers to the block number of the block that contained the declaration;

active

refers to the latest block number for which the active message was sent (it is set to

created

by default);

withdrawn

refers to the block number for which the service declaration was withdrawn (it is set to 0 by default).

The

nonce

must be set to 0 for the declaration message and must increase monotonically by every message sent for the

declaration\_id

.

We also define the 

declaration\_id

 (of a 

DeclarationId

 type) that is the unique identifier of 

DeclarationInfo

 calculated as a hash of the concatenation of 

service

, 

provider\_id

, 

locators

 and 

zk\_id

. The implementation of the hash function is 

blake2b

 using 256 bits of the output.

declaration\_id = Hash(service||provider\_id||zk\_id||locators)

The 

declaration\_id

 is not stored as part of the 

DeclarationInfo

 but it is used to index it.

All

DeclarationInfo

references are stored in the

declarations

and are indexed by

declaration\_id

.

declarations: list[declaration\_id]

#### Active Message

The construction of the active message is as follows:

class ActiveMessage:
declaration\_id: DeclarationId
nonce: Nonce
metadata: Metadata

where

metadata

is a service-specific node activeness metadata.

The message must be signed by the

zk\_id

key associated with the

declaration\_id

.

The

nonce

must increase monotonically by every message sent for the

declaration\_id

.

#### Withdraw Message

The construction of the withdraw message is as follows:

class WithdrawMessage:
declaration\_id: DeclarationId
locked\_note\_id: NoteId
nonce: Nonce

The message must be signed by the

zk\_id

key from the

declaration\_id

.

The

locked\_note\_id

is a

NoteId

that was used for minimum stake threshold verification purposes and will be unlocked after withdrawal.

The

nonce

must increase monotonically by every message sent for the

declaration\_id

.

#### Indexing

Every event must be correctly indexed to enable lighter synchronization of the changes. Therefore, we index every

declaration\_id

according to

EventType

,

ServiceType

, and

Timestamp

. Where

EventType = { "created", "active", "withdrawn" }

follows the type of the message.

events = {
event\_type: {
service\_type: {
timestamp: {
declarations: list[declaration\_id]
}
}
}
}

### Protocol

#### Declare

The Declare action associates a validator with a service it wants to provide. It requires sending a valid

DeclarationMessage

(as defined in [Declaration Message](https://nomos-tech.notion.site/Declaration-Message-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24#1fd261aa09df8192949ae1be9950c7e3)), which is then processed (as defined below) and stored (as defined in [Declaration Storage](https://nomos-tech.notion.site/Declaration-Storage-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24#1fd261aa09df81e18abbcbcbaee5d54a)).

The declaration message is considered valid when all of the following are met:

The sender meets the stake requirements and its

locked\_note\_id

is valid.

The

declaration\_id

is unique.

The sender knows the secret behind the

provider\_id

identifier.

The length of the

locators

list must not be longer than 8.

The

nonce

increases monotonically.

If all of the above conditions are fulfilled, then the message is stored on the ledger; otherwise, the message is discarded.

#### Active

The Active action enables marking the provider as actively providing a service. It requires sending a valid

ActiveMessage

(as defined in [Active Message](https://nomos-tech.notion.site/Active-Message-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24#1fd261aa09df81f1a0b5cc8956c70660) ), which is relayed to the service-specific node activity logic (as indicated by the service type in [[1.5.0] Mantle - Common SDP Structures](https://nomos-tech.notion.site/Common-SDP-Structures-33d261aa09df8051b0d0cd4d5ddade85?pvs=24#b26261aa09df828ea4f1818e1cd3152d)).

The Active action updates the

active

value of the

DeclarationInfo

, which means that it also activates inactive (but not expired) providers.

The SDP active action logic is:

A node sends a

ActiveMessage

transaction.

The

ActiveMessage

is verified by the SDP logic.

The

declaration\_id

returns an existing

DeclarationInfo

.

The transaction containing

ActiveMessage

is signed by the

zk\_id

.

The

withdrawn

from the

DeclarationInfo

is set to zero.

The

nonce

increases monotonically.

If any of these conditions fail, discard the message and stop processing.

The message is processed by the service-specific activity logic alongside the

active

value indicating the period since the last active message was sent. The

active

value comes from the

DeclarationInfo

.

If the service-specific activity logic approves the node active message, then the

active

field of the

DeclarationInfo

is set to the current block height.

#### Withdraw

The withdraw action enables a withdrawal of a service declaration. It requires sending a valid

WithdrawMessage

(as defined in [Withdraw Message](https://nomos-tech.notion.site/Withdraw-Message-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24#1fd261aa09df817bad97f88bc40ba0c9)). The withdrawal cannot happen before the end of the locking period, which is defined as the number of blocks counted since

created

. This lock period is stored as

lock\_period

in the [Service Parameters](https://nomos-tech.notion.site/Service-Parameters-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24#1fd261aa09df813c86a1f25d243359d5).

The logic of the withdraw action is:

A node sends a

WithdrawMessage

transaction.

The

WithdrawMessage

is verified by the SDP logic.

The

declaration\_id

returns an existing

DeclarationInfo

.

The transaction containing

WithdrawMessage

is signed by the

zk\_id

.

The

withdrawn

from

DeclarationInfo

is set to zero.

The

nonce

increases monotonically.

If any of the above is not correct, then discard the message and stop.

Set the

withdrawn

from the

DeclarationInfo

to the current block height.

Unlock the stake (release the

locked\_note\_id

).

#### Garbage Collection

The protocol requires a garbage collection mechanism that periodically removes unused 

DeclarationInfo

 entries.

The logic of garbage collection is:

For every 

DeclarationInfo

 in the 

declarations

 set, remove the entry if either:

The entry is past the retention period: 

withdrawn + (retention\_period \* session\_length) < current\_block\_height

.

The entry is inactive beyond the inactivity and retention periods: 

active + (inactivity\_period + retention\_period) \* session\_length < current\_block\_height

.

#### Query

The protocol must enable querying the ledger in at least the following manner:

GetAllProviderId(timestamp)

, returns all

provider\_id

s associated with the

timestamp

.

GetAllProviderIdSince(timestamp)

, returns all

provider\_id

s since the

timestamp

.

GetAllDeclarationInfo(timestamp)

, returns all

DeclarationInfo

entries associated with the

timestamp

.

GetAllDeclarationInfoSince(timestamp)

, returns all

DeclarationInfo

entries since the

timestamp

.

GetDeclarationInfo(provider\_id)

, returns the

DeclarationInfo

entry identified by the

provider\_id

.

GetDeclarationInfo(declaration\_id)

, returns the

DeclarationInfo

entry identified by the

declaration\_id

.

GetAllServiceParameters(timestamp)

, returns all entries of the

ServiceParameters

store for the requested

timestamp

.

GetAllServiceParametersSince(timestamp)

, returns all entries of the

ServiceParameters

store since the requested

timestamp

.

GetServiceParameters(service\_type, timestamp)

, returns the service parameter entry from the

ServiceParameters

store of a

service\_type

for a specified

timestamp

.

GetMinStake(timestamp)

, returns the

MinStake

structure at the requested

timestamp

.

GetMinStakeSince(timestamp)

, returns a set of

MinStake

structures since the requested

timestamp

.

The query must return an error if the retention period for the delegation has passed and the requested information is not available.

The list of queries may be extended.

Every query must return information for a finalized state only.

### Mantle and ZK Proofs

For more information about Mantle and ZK proofs, please refer to [[1.5.0] Mantle](https://nomos-tech.notion.site/1-5-0-Mantle-33d261aa09df8051b0d0cd4d5ddade85?pvs=24).

## Default Service Parameters

### Blend Network

class BlendNetworkServiceParameters:
 session\_length: 21600 # follows the length of an epoch
 lock\_period: 1
inactivity\_period: 1
retention\_period: 1

The

session\_length

follows the length of an epoch as indicated in [[1.0.0] Blend Protocol - Session is a time during which the same set of core nodes is](https://nomos-tech.notion.site/Session-is-a-time-during-which-the-same-set-of-core-nodes-is-executing-the-protocol-When-the-sessio-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df8133a0ead533627fbb93)..
