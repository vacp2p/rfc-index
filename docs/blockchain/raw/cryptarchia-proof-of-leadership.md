# CRYPTARCHIA-PROOF-OF-LEADERSHIP

| Field | Value |
| --- | --- |
| Name | Cryptarchia Proof of Leadership Specification |
| Slug | 83 |
| Status | raw |
| Category | Standards Track |
| Editor | Thomas Lavaur <thomas@logos.co> |
| Contributors | Mehmet <mehmet@logos.co>, Giacomo Pasini <giacomo@logos.co>, Daniel Sanchez Quiros <daniel@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, David Rusu <david@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/cryptarchia-proof-of-leadership.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/cryptarchia-proof-of-leadership.md) — Chore/mdbook updates (#258)

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
| 1.0.0 | Initial revision. | 2025-11-17 |
| 1.1.0 | ? | 2026-02-06 |
| 1.2.0 | • Removed DA references. • Removed notions of Sovereignty and Rollups and used Zones for simplicity. • Removed Nomos from specifications and DSTs. • Added bridging and decentralized sequencing for channels. | 2026-03-20 |
| 1.2.1 | • Added [Not found](/31e261aa09df80a08146e4978d2da3e0?pvs=24#31e261aa09df80a08146e4978d2da3e0). | 2026-03-24 |
| 1.3.0 | • added [Not found](/31e261aa09df80bc9e02ea4e9affc082?pvs=24#31e261aa09df80bc9e02ea4e9affc082)​ | 2026-04-02 |

## Introduction

Mantle is a foundational element of Bedrock, designed to provide a minimal and efficient execution layer that connects together Bedrock Services in order to provide the necessary functionality for Zones. It can be viewed as the system call interface of Bedrock, exposing a safe and constrained set of Operations to interact with lower-level Bedrock services, similar to syscalls in an operating system.

Mantle Transactions provide Operations for Zones and blockchain Services to interact with Bedrock. For example, a Zone sequencer posting an update to Bedrock, or a node operator declaring its participation in the Blend Network, would be done through the corresponding Operations within a Mantle Transaction.

Mantle manages assets using a note-based ledger that follows an UTXO model. Each Mantle Transaction can include Transfer Operation, and any excess balance serves as the fee payment.

## Overview

### Mantle Transaction

The features of the Logos Blockchain are exposed through Mantle Transactions. Each transaction can contain zero or more Operations. Mantle Transactions enable users to execute multiple Operations atomically.

### Mantle Operations

Logos Blockchain features are exposed through Mantle Operations, which can be combined and executed together in a single Mantle Transaction atomically. These Operations enable transfers and functions such as on-chain data posting, Cross-Zone interactions, SDP interaction, and leader reward claims.

### Mantle Ledger

The Mantle Ledger enables asset transfers using a transparent UTXO model. While a Transfer Operation can consume more tokens than it creates, the Mantle Transaction excess balance must exactly pay for the fees.

### Transaction Fees

Mantle Transaction fees are derived from a gas model. The Logos Blockchain has two different gas markets, accounting for permanent data storage, and execution costs. Each Operation has an associated Execution Gas cost. Users can specify their gas prices in their Mantle Transactions to incentivize the network to include their transaction.

|  |  |  |
| --- | --- | --- |
| Gas Market | Charged On | Pricing Basis |
| Execution Gas | Operations | Fixed per Operation |
| Permanent Storage Gas | Signed Mantle Transaction | Proportional to encoded size |

## Mantle Transaction

Mantle Transactions form the core of Mantle, enabling users to combine multiple Operations to access different functions. Each transaction contains zero or more Operations. The system executes all Operations atomically, while using the Mantle Transaction's excess balance—calculated as the difference between the consumed and created value— as the fee payment.

> Loading Python code…

​

The [hash function used](/1fd261aa09df81ac8ebbe0111e2c2d84?pvs=25#1fd261aa09df81f48afcd5bbe86c4a18), as well as other cryptographic primitives like ZK proofs and signature schemes, are described in [🔀[1.0.2] Common Cryptographic Components](/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24).

A Mantle Transaction must include all relevant signatures and proofs for each Operation.

> Loading Python code…

​

Each proof (op proof and signature) must be cryptographically bound to the

MantleTx

through the

mantle\_txhash

to prevent replay attacks. This binding is achieved by including the

MantleTx

hash as a public input in every ZK proof.

The transaction fee is a sum of two components: the multiplication of the total Execution Gas by the

execution\_gas\_price

, and the total size of the encoded signed Mantle Transaction multiplied by the

permanent\_storage\_gas\_price

.

> Loading Python code…

​

### Validation

Given

> Loading Python code…

​

Mantle validators will ensure the following:

We have a proof or a

None

value for each operation.

> Loading Python code…

​

Each Operation is valid.

> Loading Python code…

​

The Mantle Transaction excess balance pays for the transaction fees.

> Loading Python code…

​

### Execution

Given

> Loading Python code…

​

Mantle Validators execute sequentially each Operation in

ops

according to its opcode.

## Operations

### Opcodes

| Operation | Opcode | Description |
| --- | --- | --- |
| TRANSFER | 0x00 | Consume and create notes. |
| RESERVED | 0x01 - 0x0F |  |
| CHANNEL\_CONFIG | 0x10 | Configure a channel |
| CHANNEL\_INSCRIBE | 0x11 | Write a message permanently onto Mantle. |
| CHANNEL\_DEPOSIT | 0x12 | Deposit assets into a channel |
| CHANNEL\_WITHDRAW | 0x13 | Withdraw assets from a channel |
| RESERVED | 0x14 - 0x1F |  |
| SDP\_DECLARE | 0x20 | Declare intention to participate as a node in a Bedrock Service, locking funds as collateral. |
| SDP\_WITHDRAW | 0x21 | Withdraw participation from a Bedrock Service, unlocking your funds in the process. |
| SDP\_ACTIVE | 0x22 | Signal that you are still an active participant of a Bedrock Service. |
| RESERVED | 0x23 - 0xFF |  |
| LEADER\_CLAIM | 0x30 | Claim leader reward anonymously. |
| RESERVED | 0x31 - 0xFF |  |

### Channel Operations

Channels allow Zones to post their updates on chain. Channels form virtual chains that overlay on top of the Cryptarchia blockchain. Clients and Followers of a Zone can watch its channel to learn the state of that Zone. Each channel has an associated balance, enabling bridging between Zones and Bedrock.

#### Message Ordering

Channels form virtual chains by having each message reference its parent message. The order of messages in these channels is enforced by the sequencer by building a hash chain of messages, i.e. new messages reference the previous messages through a parent hash. Given that Cryptarchia has long finality times, these message parent references allow Zone sequencers to continue to post new updates to channels without having to wait for finality. No matter how Cryptarchia forks and reorgs, the channel messages from honest sequencers will eventually be re-included in a way that satisfies the virtual chain order.

The first time a message is sent to an unclaimed channel, the key that signs the initial message becomes the only accredited key in the list (Note that this key may correspond to a threshold signature key). Accredited keys of a channel forms a committee that can configure the channel, withdraw funds and take turns to write messages to that channel following a round-robin algorithm. Configuring a channel includes modifying the list of accredited keys, the round-robin parameters and the required number of signatures to withdraw funds or establish a new configuration.

Validators must maintain the following state to process channel Operations:

> Loading Python code…

​

💡

Note that the user chooses the ChannelId mapping to the ChannelState (but it’s restricted to 32 bytes). We don't currently impose restrictions on it, but we may do so in the future to prevent undesirable behaviors.

#### Decentralized Sequencing

To determine which sequencer is currently authorized to send messages, we use a round-robin algorithm. When a message is posted to a channel, the following algorithm is used to determine who the sequencer is:

> Loading Python code…

​

#### CHANNEL\_INSCRIBE

Write a message to a channel with the message data being permanently stored on the Logos Blockchain.

Payload

> Loading Python code…

​

Proof

> Loading Python code…

A signature from

signer

over the Mantle txhash containing this inscription.

ALT

​

Execution Gas

Channel Inscribe Operations have a fixed Execution Gas cost of

EXECUTION\_CHANNEL\_INSCRIBE\_GAS

. See [Gas Determination](/Gas-Determination-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81308acfc11b13716fab) for the Execution Gas values.

Validation

Given

> Loading Python code…

​

Validate

> Loading Python code…

​

Execution

Given

> Loading Python code…

​

Execute

If the channel does not exist, create it just-in-time.

> Loading Python code…

​

Update the channel sequencer.

> Loading Python code…

​

Update the channel tip.

> Loading Python code…

​

Example

> Loading Python code…

Sending a greeting to all followers of Zone Earth.

ALT

​

#### CHANNEL\_CONFIG

Overwrite the configuration of a channel.

Payload

> Loading Python code…

​

Proof

> Loading Python code…

​

Execution Gas

Channel Config Operations have a linear Execution Gas cost equal to

EXECUTION\_CHANNEL\_CONFIG\_GAS \* configuration\_threshold

. See [Gas Determination](/Gas-Determination-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81308acfc11b13716fab) for the Execution Gas values.

Validation

Given

> Loading Python code…

​

Validate

> Loading Python code…

​

Execution

Given

> Loading Python code…

​

Execute

If the channel does not exist, create it just-in-time.

> Loading Python code…

​

Update the configuration.

> Loading Python code…

​

Update the channel tip.

> Loading Python code…

​

Example

Suppose the unique sequencer of Zone A wants to add a key to the list of accredited keys:

> Loading Python code…

​

#### CHANNEL\_DEPOSIT

Deposit funds to a channel, reducing the Mantle Transaction balance.

Payload

> Loading Python code…

​

Proof

> Loading Python code…

​

Execution Gas

Channel Deposit Operations have a fixed Execution Gas cost of

EXECUTION\_CHANNEL\_DEPOSIT\_GAS

. See [Gas Determination](/Gas-Determination-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81308acfc11b13716fab) for the Execution Gas values.

Validation

Given

> Loading Python code…

​

Validate

> Loading Python code…

​

Execution

Given

> Loading Python code…

​

Execute

> Loading Python code…

​

Example

Suppose Alice wants to make a deposit of 50 tokens on Zone A.

> Loading Python code…

​

Note that the Zone may wait for the deposit to be finalized before interpreting the deposit in order to guarantee that the deposit will occur on-chain and won't be removed due to reorganization of the chain.

#### CHANNEL\_WITHDRAW

Withdraw funds from a channel, increasing the Mantle Transaction balance.

Payload

> Loading Python code…

​

Proof

> Loading Python code…

​

Execution Gas

Channel Withdraw Operations have a linear Execution Gas cost equal to

EXECUTION\_CHANNEL\_WITHDRAW\_GAS \* withdraw\_threshold

. See [Gas Determination](/Gas-Determination-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81308acfc11b13716fab) for the Execution Gas values.

Validation

Given

> Loading Python code…

​

Validate

> Loading Python code…

​

Execution

Given

> Loading Python code…

​

Execute

> Loading Python code…

​

Example

Suppose the unique sequencer of Zone A wants to withdraw 50 tokens.

Loading...
