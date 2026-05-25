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

# Revision History

# Introduction

Mantle is a foundational element of Bedrock, designed to provide a minimal and efficient execution layer that connects together Bedrock Services in order to provide the necessary functionality for Zones. It can be viewed as the system call interface of Bedrock, exposing a safe and constrained set of Operations to interact with lower-level Bedrock services, similar to syscalls in an operating system.

Mantle Transactions provide Operations for Zones and blockchain Services to interact with Bedrock. For example, a Zone sequencer posting an update to Bedrock, or a node operator declaring its participation in the Blend Network, would be done through the corresponding Operations within a Mantle Transaction.

Mantle manages assets using a note-based ledger that follows an UTXO model. Each Mantle Transaction can include Transfer Operation, and any excess balance serves as the fee payment.

# Overview

## Mantle Transaction

The features of the Logos Blockchain are exposed through Mantle Transactions. Each transaction can contain zero or more Operations. Mantle Transactions enable users to execute multiple Operations atomically.

## Mantle Operations

Logos Blockchain features are exposed through Mantle Operations, which can be combined and executed together in a single Mantle Transaction atomically. These Operations enable transfers and functions such as on-chain data posting, Cross-Zone interactions, SDP interaction, and leader reward claims.

## Mantle Ledger

The Mantle Ledger enables asset transfers using a transparent UTXO model. While a Transfer Operation can consume more tokens than it creates, the Mantle Transaction excess balance must exactly pay for the fees.

## Transaction Fees

Mantle Transaction fees are derived from a gas model. The Logos Blockchain has two different gas markets, accounting for permanent data storage, and execution costs. Each Operation has an associated Execution Gas cost. Users can specify their gas prices in their Mantle Transactions to incentivize the network to include their transaction.

# Mantle Transaction

Mantle Transactions form the core of Mantle, enabling users to combine multiple Operations to access different functions. Each transaction contains zero or more Operations. The system executes all Operations atomically, while using the Mantle Transaction's excess balance—calculated as the difference between the consumed and created value— as the fee payment.

```
> Loading Python code…​
```

The [hash function used](/1fd261aa09df81ac8ebbe0111e2c2d84?pvs=25#1fd261aa09df81f48afcd5bbe86c4a18), as well as other cryptographic primitives like ZK proofs and signature schemes, are described in [🔀[1.0.2] Common Cryptographic Components](/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24).

A Mantle Transaction must include all relevant signatures and proofs for each Operation.

```
> Loading Python code…​
```

Each proof (op proof and signature) must be cryptographically bound to the MantleTx through the mantle_txhash to prevent replay attacks. This binding is achieved by including the MantleTx hash as a public input in every ZK proof.

The transaction fee is a sum of two components: the multiplication of the total Execution Gas by the execution_gas_price, and the total size of the encoded signed Mantle Transaction multiplied by the permanent_storage_gas_price.

```
> Loading Python code…​
```

## Validation

Given

```
> Loading Python code…​
```

Mantle validators will ensure the following:

1. We have a proof or a None value for each operation.
    ```
    > Loading Python code…​
    ```
1. Each Operation is valid.
    ```
    > Loading Python code…​
    ```
1. The Mantle Transaction excess balance pays for the transaction fees.
    ```
    > Loading Python code…​
    ```

## Execution

Given

```
> Loading Python code…​
```

Mantle Validators execute sequentially each Operation in ops according to its opcode.

# Operations

## Opcodes

## Channel Operations

Channels allow Zones to post their updates on chain. Channels form virtual chains that overlay on top of the Cryptarchia blockchain. Clients and Followers of a Zone can watch its channel to learn the state of that Zone. Each channel has an associated balance, enabling bridging between Zones and Bedrock.

### Message Ordering

Channels form virtual chains by having each message reference its parent message. The order of messages in these channels is enforced by the sequencer by building a hash chain of messages, i.e. new messages reference the previous messages through a parent hash. Given that Cryptarchia has long finality times, these message parent references allow Zone sequencers to continue to post new updates to channels without having to wait for finality. No matter how Cryptarchia forks and reorgs, the channel messages from honest sequencers will eventually be re-included in a way that satisfies the virtual chain order.

The first time a message is sent to an unclaimed channel, the key that signs the initial message becomes the only accredited key in the list (Note that this key may correspond to a threshold signature key). Accredited keys of a channel forms a committee that can configure the channel, withdraw funds and take turns to write messages to that channel following a round-robin algorithm. Configuring a channel includes modifying the list of accredited keys, the round-robin parameters and the required number of signatures to withdraw funds or establish a new configuration.

Validators must maintain the following state to process channel Operations:

```
> Loading Python code…​
```

> Note that the user chooses the ChannelId mapping to the ChannelState (but it’s restricted to 32 bytes). We don't currently impose restrictions on it, but we may do so in the future to prevent undesirable behaviors.

### Decentralized Sequencing

To determine which sequencer is currently authorized to send messages, we use a round-robin algorithm. When a message is posted to a channel, the following algorithm is used to determine who the sequencer is:

```
> Loading Python code…​
```

### CHANNEL_INSCRIBE

Write a message to a channel with the message data being permanently stored on the Logos Blockchain.

Payload

Proof

Execution Gas

Validation

Execution

Example

### CHANNEL_CONFIG

Overwrite the configuration of a channel.

Payload

Proof

Execution Gas

Validation

Execution

Example

### CHANNEL_DEPOSIT

Deposit funds to a channel, reducing the Mantle Transaction balance.

Payload

Proof

Execution Gas

Validation

Execution

Example

### CHANNEL_WITHDRAW

Withdraw funds from a channel, increasing the Mantle Transaction balance.

Payload

Proof

Execution Gas

Validation

Execution

Example

