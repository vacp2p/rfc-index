# NOMOS-CRYPTARCHIA-V1-PROTOCOL

| Field | Value |
| --- | --- |
| Name | Nomos Cryptarchia v1 Protocol Specification |
| Slug | 92 |
| Status | raw |
| Category | Standards Track |
| Editor | David Rusu <david@logos.co> |
| Contributors | Álvaro Castro-Castilla <alvaro@logos.co>, Giacomo Pasini <giacomo@logos.co>, Thomas Lavaur <thomas@logos.co>, Mehmet <mehmet@logos.co>, Marcin Pawlowski <marcin@logos.co>, Daniel Sanchez Quiros <daniel@logos.co>, Youngjoon Lee <youngjoon@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/nomos-cryptarchia-v1-protocol.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/nomos-cryptarchia-v1-protocol.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

# Introduction

Cryptarchia is the consensus protocol of the Logos Blockchain’s Bedrock layer. This document specifies how Bedrock comes to agreement to a single history of blocks.

The values that Cryptarchia optimizes for are resilience and privacy. These come at the cost of block times and finality. These values have significant implications on user experience and we should understand them well.

## Resilience

In consensus, we are presented with a choice of prioritizing either safety or liveness in the presence of catastrophic failure (this is a re-formalization of the CAP theorem). Choosing safety means the chain never forks, instead the chain halts until the network heals. On the other hand, choosing liveness (a la Bitcoin/Ethereum) means that block production continues but finality will stall, leading to confusion around which blocks are on the honest chain.

On the surface both options seem to provide similar guarantees. If finality is delayed indefinitely, is this not equivalent to a halted chain? The differences come down to how safety or liveness is implemented.

### Prioritizing Safety

Chains that provide a safety guarantee do so using quorum-based consensus. This requires a known set of participants (i.e. a permissioned network) and extensive communication between them to reach agreement. This restricts the number of participants in the network. Furthermore, quorum based consensus can only tolerate up to 1/3rd of the participants becoming faulty.

A small participant set and low threshold for faults generally pushes these networks to put large barriers to entry, either through large staking requirements or politics.

### Prioritizing Liveness

Chains that prioritize liveness generally do so by relying on fork choice rules such as the longest chain rule from Nakamoto consensus. These protocols allow each participant to make a local choice about which fork to follow, and therefore do not require quorums and thus can be permissionless.

Additionally, due to a lack of quorums, these protocols can be quite message efficient. Thus, participation does not need to be artificially reduced to remain within bandwidth restrictions.

These protocols tolerate up to 1/2 of participants becoming faulty. The large fault tolerance threshold and the large number of participants provides for much higher resilience to corruption.

## Privacy

The motivation behind the design of Cryptarchia can be boiled down to this statement:

Working to give leaders confidence in this statement has had ripple effects throughout the protocol, including that:

- The block proposals should not be linkable to a leader. An adversary should not be able to connect together the block proposals of a leader in order to build a profile. In particular, one should not be able to infer a proposer's stake from their past on-chain activity.
- Cryptarchia must not reveal the stake of the leader - that is, it must be a Private Proof of Stake (PPoS) protocol. If the activity of the leader reveals their stake values (e.g. through weighted voting), then this value can be used to reduce the anonymity set for the leader by bucketing the leader as high/low stake and can open him up to targeting.
- Leaders should be protected against network triangulation attacks. This is outside of the scope of this document, but it suffices to say that in-protocol cryptographic privacy is not sufficient to guarantee a leader's privacy. This topic is dealt with directly in [🔀[1.0.0] Blend Protocol](https://nomos-tech.notion.site/1-0-0-Blend-Protocol-215261aa09df81ae8857d71066a80084?pvs=24).

## Limitations of Cryptarchia V1

Despite our best efforts, we cannot provide perfect privacy and censorship resistance to all parties. In particular:

- We are unable to protect leaders from leaking information about themselves based on the contents of blocks they propose. The tagging attack is an example of this, where an adversary may distribute a transaction to only a small subset of the network. If the block proposal includes this transaction, the adversary learns that the leader was one of those nodes in that subset.
- The leader is a single point of failure (SPOF). Despite all the efforts we go through to protect the leader, the network can be easily censored by the leader. The leader may choose to exclude certain types of transactions from blocks, leading to a worse UX for targeted parties.

As far as we can tell, these limitations are not insurmountable and we have sketches towards solutions that we will develop in following iterations of the protocol.

# Overview

Cryptarchia is a probabilistic consensus protocol with properties similar to Bitcoin’s Nakamoto Consensus.

At a high level, Cryptarchia divides time into slots and at each slot, a leadership lottery is run. To participate in the lottery, a node must have held stake in the chain in the form of a note for a minimum time period. Given a sufficiently aged note, you can check if it has won a slot lottery by cryptographically flipping a weighted coin. The weight of the coin is proportional to the value of your note, thus higher valued notes lead to increased chances of winning. To ensure privacy and avoid revealing the note value, this lottery result is proven within a ZK proof system.

Our design starts from the solid foundation provided by [Ouroboros Crypsinous: Privacy-Preserving Proof-of-Stake](https://nomos-tech.notion.site/Ouroboros-Crypsinous-Privacy-Preserving-Proof-of-Stake-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df818bbb09eddde2179cc4)  and builds upon it, incorporating the latest research at the intersection of cryptography, consensus and network engineering.

# Protocol

## Constants

## Notation

## Latest Immutable Block

The latest immutable block $B_\text{imm}$ is the most recent block considered permanently finalized. The blocks deeper than $B_\text{imm}$ in the local chain $c_{loc}$ are never to be reorganized.

This is maintained locally by the [Chain Maintenance](https://nomos-tech.notion.site/Chain-Maintenance-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81de81bac3a3286dc212) procedure. When the [Online fork choice rule](/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df812caa08ce2f637a6278) is in use, $B_\text{imm}$ corresponds to the $k$-deep block. However, it may be deeper than the $k$-deep block if the fork choice rule has been switched from Online to [Bootstrap](/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df81e4a352dd365c9ebe8c). Unlike the $k$-deep block, $B_\text{imm}$ does not advance as new blocks are added unless the Online fork choice rule is used.

The details of fork choice rule transitions are defined in the bootstrap spec: [🔀[1.0.0] Cryptarchia Bootstrapping & Synchronization](https://nomos-tech.notion.site/1-0-0-Cryptarchia-Bootstrapping-Synchronization-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24)

## Slot

Time is divided up into slots of equal length, where one instance of the leadership lottery is held in each slot. A slot is said to be occupied if some validator has won the leadership lottery and proposed a block for that slot, otherwise the slot is said to be unoccupied.

## Epoch

Cryptarchia has a few global variables that are adjusted periodically in order for consensus to function. Namely, we need:

- Dynamic participation, thus the eligible notes must be refreshed regularly.
- An unpredictable source of randomness for the leadership lottery. This source of randomness is derived from in-protocol activity and thus must be selected carefully to avoid giving adversaries an advantage.
- Approximately constant block production rate achieved by dynamically adjusting the lottery difficulty based on observed participation levels.

The order in which these variables are calculated is important and is done w.r.t. the epoch schedule.

### Epoch Schedule

An epoch is divided into 3 phases, as outlined below.

The epoch length is the sum of the individual phases: $3\lfloor \frac{k}{f} \rfloor + 3\lfloor \frac{k}{f} \rfloor + 4\lfloor \frac{k}{f} \rfloor =10 \lfloor \frac{k}{f} \rfloor$ slots.

### Epoch State

The epoch state holds the variables derived over the course of the epoch schedule. It is the 3-tuple $(\mathbb{C}_\text{LEAD}, \eta, D)$ described below.

### Eligible Leader Notes

A note is eligible to participate in the leadership lottery if it has not been spent and was a member of the note set at the beginning of the previous epoch, i.e. they are members of $\mathbb{C}_\text{LEAD}$.

Note Ageing

If an adversary knows the epoch nonce $\eta$, they may grind a note that wins the lottery more frequently than should be statistically expected. Thus, it’s critical that notes participating in the lottery are sufficiently old to ensure that they have no predictive power over $\eta$.

### Epoch Nonce

The epoch nonce $\eta$ is evolved after each block.

Given block $B = (parent,sl, \rho_\text{LEAD},\dots)$ where

- $parent$ is the parent of block $B$​
- $sl$ is the slot that $B$ is occupying.
- $\rho_\text{LEAD}$ is the epoch nonce entropy contribution from the block’s leadership proof

Then, $\eta_B$ is derived as

where $\text{Fr}(sl)$ maps the slot number to the corresponding scalser in Poseidon’s scalar field and $\text{zkHASH}(..)$ is Poseidon2 as specified in [🔀[1.0.2] Common Cryptographic Components](https://nomos-tech.notion.site/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24) .

The epoch nonce used in the next epoch is $\eta_{B'}$ where $B'$ is the last block before the start of the “Lottery Constants Finalization” phase in the epoch schedule.

### Total Stake Inference

Given that stake is private in Cryptarchia, and that we want to maintain an approximately constant block rate, we must therefore adjust the difficulty of the slot lottery somehow based on the level of participation. The details can be found in the following document:

[🔀[1.0.0] Total Stake Inference](https://nomos-tech.notion.site/1-0-0-Total-Stake-Inference-22d261aa09df8051a454caa46ec54b34?pvs=24)

### Epoch State Pseudocode

At the start of each epoch, each validator must derive the new epoch state variables. This is done through the following protocol:

$\text{define } \textbf{compute\_epoch\_state}(ep, tip \in T)\rarr(\mathbb{C}_\text{LEAD}^{ep},\eta^{ep},D^{ep})$ :

## Leadership Lottery

A lottery is run for every slot to decide who is eligible to propose a block. For each slot, we can have 0 or more winners. In fact, it’s desirable to have short slots and many empty slots to allow for the network to propagate blocks and to reduce the chances of two leaders winning the same slot which are guaranteed forks.

### Proof of Leadership

The specifications of how a leader can prove that they have won the lottery are specified in the following document:

### Leader Rewards

As an incentive for producing blocks, leaders are rewarded with every block proposal. The rewarding protocol is specified in [🔀[1.0.0] Anonymous Leaders Reward Protocol](https://nomos-tech.notion.site/1-0-0-Anonymous-Leaders-Reward-Protocol-206261aa09df8120a49ffa49c71ba70d?pvs=24).

## Block Chain

### Fork Choice Rule

We use two fork choice rules, one during bootstrapping and a second once a node completes bootstrapping.

During bootstrapping, we must be resilient to malicious peers feeding us false chains, this calls for a more expensive fork choice rule that can differentiate between malicious long-range attacks and honest chains.

After bootstrapping we commit to the most honest looking chain we found and switch to a fork choice rule that rejects chains that diverge by more than $k$ blocks

[🔀[1.0.0] Cryptarchia Fork Choice Rule](https://nomos-tech.notion.site/1-0-0-Cryptarchia-Fork-Choice-Rule-21b261aa09df811584dfd362abb26627?pvs=24)

### Block ID

Block ID is defined by the hash of the block header [Block Header](https://nomos-tech.notion.site/Block-Header-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df8186bc6cec1fc01e4cf5), where hash is Blake2b as specified in [🔀[1.0.2] Common Cryptographic Components](https://nomos-tech.notion.site/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24)

```
> Loading Python code…​
```

### Block Header

```
> Loading Python code…​
```

### Block

[🔀[1.1.1] Block Construction, Validation and Execution](https://nomos-tech.notion.site/1-1-1-Block-Construction-Validation-and-Execution-33e261aa09df806c8fe3e10ede80918d?pvs=24)​

### Block Header Validation

Given block $B=(header, transactions)$ and the block tree $T$ where:

- $header$ is the header defined in [🔀[1.1.1] Block Construction, Validation and Execution - Header](https://nomos-tech.notion.site/Header-33e261aa09df806c8fe3e10ede80918d?pvs=24#39d261aa09df839cba2e0111e1ca9f99)​
- $transactions$ is the sequence of transactions in the block

We say $\textbf{valid\_header}(B)$ returns True if all of the following constraints hold, otherwise it returns False.

1. $header.\text{version}.\text{bedrock\_version} = 1$​
    Ensure bedrock version number.
1. $\textbf{bytes}(transactions) < \text{MAX\_BLOCK\_SIZE}$​
    Ensure block size is smaller than the maximum allowed block size
1. $\textbf{length}(transactions) < \text{MAX\_BLOCK\_TXS}$​
    Ensure the number of transactions in the block is below the limit
1. $\textbf{merkle\_root}(transactions) = header.\text{block\_root}$​
    Ensure block root is over the transaction list.
1. $header.\text{slot} > \textbf{fetch\_header}(header.\text{parent\_block}).\text{slot}$​
    Ensure the block’s slot comes after the parent block’s slot.
1. $\textbf{wallclock\_time}().\textbf{to\_slot}() \ge header\text{.slot}$​
    Ensure this block’s slot time has elapsed. Local time is used in this validation. See [Clocks](https://nomos-tech.notion.site/Clocks-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81b78f91d0ab1f31edd6) for discussion around clock synchronization.
1. $header.\text{parent} \in T$​
    Ensure we have already accepted the block’s parent into the block tree.
1. $\textbf{height}(B) > \textbf{height}(B_{imm})$​
    Ensure the block comes after the latest immutable block. Assuming that $T$ prunes all forks diverged deeper than $B_\text{imm}$, this step, along with step 5, ensures that $B$ is descendant from $B_\text{imm}$. If all forks cannot be pruned completely in the implementation, this step must be replaced with $\textbf{is\_ancestor}(B_\text{imm}, B)$, which checks whether $B_\text{imm}$ is an ancestor of $B$.
1. Verify the leader’s right to propose and ensure it is the one proposing this block:
    Given leadership proof $\pi_\text{LEAD} = (\pi_\text{PoL},P_\text{LEAD},\sigma)$, where
    - $\pi_\text{PoL}$ is the slot lottery win proof as defined in [🔀[1.1.0] Proof of Leadership](https://nomos-tech.notion.site/1-1-0-Proof-of-Leadership-2e9261aa09df80058244c902defc6da2?pvs=24)
    - $P_\text{LEAD}$ is the public key committed to in $\pi_\text{PoL}$.
    - $\sigma$ is a signature.
    A leaders proposal is valid if
    - $\textbf{verify\_PoL}(T, parent,sl,P_\text{LEAD}, \pi_\text{PoL})=True$​
    - $\textbf{verify\_signature}(\textbf{block\_id}(H), \sigma, P_\text{LEAD})=True$​
        Ensure that the leader who won the lottery is actually proposing this block since PoL’s are not bound to blocks directly.

### Chain Maintenance

We define the chain maintenance procedure $\textbf{on\_block}(state,B)$ that governs how the block tree $T$ is updated.

Note: It’s assumed that block contents have already been validated by the execution layer w.r.t. the parent block’s execution state.

$\text{define } \textbf{on\_block}(state, B)\rarr state'$:

### Commit

We define the procedure that commits to the block, which is $depth$ deep from $c_{loc}$. This procedure computes the new latest immutable block $B_\text{imm}$.

$\text{define } \textbf{commit}(T,c_{loc},depth)\rarr (T', B_\text{imm}):$​

### Fork Pruning

We define the fork pruning procedure that removes all blocks which are part of forks diverged deeper than a certain block.

$\text{define } \textbf{prune\_forks}(T, B)\rarr T':$​

$\text{define } \textbf{prune\_blocks}(B_\text{new}, B_\text{old}, T)\rarr T’:$​

### Versioning and Protocol Upgrades

Protocol versions are signalled through the bedrock_version field of the block header. Protocol upgrades need to be co-ordinated well in advance to ensure that node operators have enough time to update their node. We will use block height to schedule the activation of protocol updates. E.g. bedrock version 35 will be active after block height 32000.

# Annexes

## Proof of Stake vs. Proof of Work

From a privacy and resiliency point of view, Proof of Work is highly attractive. The amount of hashing power of a node is private, they can provide a new public key for each block he mines ensuring that his blocks cannot be connected by this identity, and PoW is not susceptible to long range attacks as is PoS. Unfortunately, it is wasteful and demands that leaders have powerful machines. We want to ensure strong decentralization by having a low barrier to entry and we believe we can achieve a good enough level of security given by having participants have an economic stake in the protocol.

## Clocks

Cryptarchia depends on honest nodes having relatively in-sync clocks. We are currently rely on NTP to synchronize clocks, this may be improved upon in the future, borrowing ideas from [Ouroboros Chronos: Permissionless Clock Synchronization via …](https://nomos-tech.notion.site/Ouroboros-Chronos-Permissionless-Clock-Synchronization-via-Proof-of-Stake-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81078a86de606bde1f2d)

## References

1. Ouroboros Crypsinous: Privacy-Preserving Proof-of-Stake
[eprint.iacr.org](https://eprint.iacr.org/2018/1132.pdf)​
1. Ouroboros Chronos: Permissionless Clock Synchronization via Proof-of-Stake  [eprint.iacr.org](https://eprint.iacr.org/2019/838.pdf)​

