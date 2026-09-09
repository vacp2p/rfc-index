# BEDROCK-ERAS

| Field | Value |
| --- | --- |
| Name | Bedrock Eras |
| Slug | 247 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski <marcin@logos.co> |

# Revision History

| **Version** | **Changes** | **Date** |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-09-04 |

# Introduction

An era is a range of consecutive epochs ([Cryptarchia Protocol](cryptarchia-v1-protocol.md#epoch)) governed by one set of protocol rules.

# Protocol

## Era Schedule

The era schedule is embedded in the node software and is not read from the chain. Each network has its own schedule.

The schedule is a strictly increasing list of epoch numbers. The first entry is 0. Entry $`n`$ (1-based) is the first epoch of era $`n`$, denoted $`E_n`$.

The era of an epoch $`ep`$ is $`\textbf{era}(ep) = \max\{n : E_n \le ep\}`$. The era of a slot $`sl`$ is $`\textbf{era}(\lfloor sl / \text{EPOCH\_LENGTH} \rfloor)`$. $`\text{EPOCH\_LENGTH}`$ is the [epoch length](cryptarchia-v1-protocol.md#epoch-schedule) in slots. The **era in force** is $`\textbf{era}(sl)`$ of the slot given by the local clock.

An era must not change $`k`$ or $`f`$ ([Constants](cryptarchia-v1-protocol.md#constants)). Otherwise every later era boundary moves.

A schedule entry must never change once a release has published it. Otherwise nodes running different releases fork.

An era does not fix the values that [Service Parameters](bedrock-service-declaration-protocol.md#service-parameters) entries set. A new entry changes a value without an era change.

## Interpreting Chain Data

A block, and everything it carries, is parsed, validated and executed under the rules of $`\textbf{era}(sl)`$ of the block's slot. The header fields up to and including `slot` have the same encoding in every era. Otherwise a node cannot parse a block before it knows the block's era.

[Fork choice](fork-choice.md) compares two chains under the era of the slot of their latest common ancestor. The fork choice rule of an era reads only the block tree and the header fields up to and including `slot`. Otherwise it is undefined on the blocks of a later era that re-encodes a field it reads.

A node must implement the rules of every era from $`\textbf{era}(sl_{B_\text{imm}})`$ to the era in force, where $`B_\text{imm}`$ is the [Latest Immutable Block](cryptarchia-v1-protocol.md#latest-immutable-block). A node that must validate a block whose slot lies in an era it does not implement must halt with an error to the operator. A block whose slot precedes that of $`B_\text{imm}`$ is discarded without a halt.

When the era in force changes, a node re-validates every transaction in its mempool under the new era's rules and removes those that fail. Mempool admission applies the rules of the era in force, whichever era's network protocol delivered the transaction.

## Era Migration

Every era after the first defines a migration from its predecessor. A migration is a function of the recorded chain state alone. The recorded chain state is the [ledger](bedrock-v1.1-mantle-specification.md) state, the [Declaration Storage](bedrock-service-declaration-protocol.md#declaration-storage), and the [snapshots](bedrock-service-declaration-protocol.md#snapshots) taken but not yet consumed.

The migration must be:

- **Total**: defined for every state reachable under the predecessor era. A migration undefined for a reachable state halts the network at the boundary.
- **Identity by default**: every state component the new era does not redefine is unchanged.

To validate or execute a block whose parent lies in an earlier era, a node first applies the intervening migrations, in order, to the state after the parent.

The [Epoch State](cryptarchia-v1-protocol.md#epoch-state) of an epoch is computed under the rules of the epoch's era. A value it reads from an earlier epoch is used as it was derived, not recomputed.

## Era Transition Period

The Era Transition Period is the first $`T_\text{era} = 30`$ [rounds](blend-protocol.md#time) after the era in force changes. It applies to the network layer only.

$`T_\text{era}`$ must not be smaller than $`T`$, the Blend [Transition Period](blend-protocol.md#transition-period). Otherwise Blend payloads in flight at the boundary are dropped.

During the Era Transition Period a node must:

1. Run the network protocols of both eras.
2. Validate a Blend message under the era of the connection it arrived on.
3. Keep every input the predecessor era's message checks read until the period ends.

After the Era Transition Period the node must drop the old era's network protocols and must not process its messages.

## Network Protocol Identity

Every libp2p protocol identifier and gossipsub topic is `/<network>/<era>/<protocol>`. `<network>` is `logos-blockchain` for mainnet and `logos-blockchain-testnet` for testnet. Any other network takes its own name. `<era>` is the decimal era number. `<protocol>` is the identifier the protocol's own specification defines.

A node sends a message it generates, and every block, over the identifiers of the era in force. A node relays a Blend message over the era of the connection it arrived on. A [synchronization](cryptarchia-v1-bootstr-sync.md#downloading-blocks) response carries blocks of any era.

## Horizon

Each schedule carries a horizon $`H`$, an epoch number. $`H`$ must not be smaller than the last entry of the schedule. Otherwise the node halts at or before the first slot of its last era.

From the first slot of epoch $`H+1`$ by the local clock, a node halts with an error to the operator. The halt must not be triggered by information received from peers.

If an entry is at or before the $`H`$ of a published release, the nodes of that release do not halt at the new boundary and fork.
