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

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-01-20 |
| 1.0.1 | Replaced Nomos name with Logos Blockchain | 2026-04-17 |

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

A block proposer should not feel the need to self-censor when proposing a block.

Working to give leaders confidence in this statement has had ripple effects throughout the protocol, including that:

- The block proposals should not be linkable to a leader. An adversary should not be able to connect together the block proposals of a leader in order to build a profile. In particular, one should not be able to infer a proposer's stake from their past on-chain activity.
- Cryptarchia must not reveal the stake of the leader - that is, it must be a Private Proof of Stake (PPoS) protocol. If the activity of the leader reveals their stake values (e.g. through weighted voting), then this value can be used to reduce the anonymity set for the leader by bucketing the leader as high/low stake and can open him up to targeting.
- Leaders should be protected against network triangulation attacks. This is outside of the scope of this document, but it suffices to say that in-protocol cryptographic privacy is not sufficient to guarantee a leader's privacy. This topic is dealt with directly in [🔀\[1.0.0\] Blend Protocol](https://nomos-tech.notion.site/1-0-0-Blend-Protocol-215261aa09df81ae8857d71066a80084?pvs=24).

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

| Symbol | Name | Description | Value |
| --- | --- | --- | --- |
| $f$​ | slot activation coefficient | The target rate of occupied slots. Not all slots contain blocks, many are empty.   (see [🔀\[1.0.0\]\[Analysis\] Block Times & Blend Network](https://nomos-tech.notion.site/1-0-0-Analysis-Block-Times-Blend-Network-1fd261aa09df817fa25ef80b964183cc?pvs=24) for analysis leading to the choice of value) | 1/30 |
| $k$​ | security parameter | Block depth finality. Blocks deeper than $k$ on any given chain are considered immutable. | 2160 blocks |
| none | slot length | The duration of a single slot. | 1 second |
| MAX_BLOCK_SIZE | max block size | The maximum size of the block body (not including the header) | 1 MB |
| MAX_BLOCK_TXS | max block transactions | The maximum number of transactions in a block | 1024 |

## Notation

| Symbol | Name | Description | Value |
| --- | --- | --- | --- |
| $s$​ | slot security parameter | Sufficient slots such that $k$ blocks have been produced with high probability. | $3\lfloor \frac{k}{f}\rfloor$​ |
| $T$​ | the block tree | This is the block tree observed by a node. |  |
| $F_T$​ | tips of block tree $T$​ | The set of concurrent forks of some block tree $T$. | $F_T=\{b\in T:\forall c \in T\space \textbf{parent}(c) \neq b \}$​ |
| $c_{loc}$​ | tip of local chain | The chain that a node considers to be the honest chain. | $c_{loc} \in F_{T}$​ |
| $B_\text{imm}$​ | the latest immutable block | The latest block which was committed (finalized) by the chain maintenance. | $B_\text{imm} \in \textbf{ancestors}(c_{loc})$​ |
| $sl$​ | slot number | Index of slot. $sl=0$ denotes the genesis slot. | $sl=0,1,2,3,\dots$​ |
| $ep$​ | epoch number | Index of epoch. $ep=0$ denotes the genesis epoch. | $ep=0,1,2,3,\dots$​ |

## Latest Immutable Block

The latest immutable block $B_\text{imm}$ is the most recent block considered permanently finalized. The blocks deeper than $B_\text{imm}$ in the local chain $c_{loc}$ are never to be reorganized.

This is maintained locally by the [Chain Maintenance](https://nomos-tech.notion.site/Chain-Maintenance-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81de81bac3a3286dc212) procedure. When the [Online fork choice rule](https://nomos-tech.notion.site/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df812caa08ce2f637a6278) is in use, $B_\text{imm}$ corresponds to the $k$-deep block. However, it may be deeper than the $k$-deep block if the fork choice rule has been switched from Online to [Bootstrap](https://nomos-tech.notion.site/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df81e4a352dd365c9ebe8c). Unlike the $k$-deep block, $B_\text{imm}$ does not advance as new blocks are added unless the Online fork choice rule is used.

The details of fork choice rule transitions are defined in the bootstrap spec: [🔀\[1.0.0\] Cryptarchia Bootstrapping & Synchronization](https://nomos-tech.notion.site/1-0-0-Cryptarchia-Bootstrapping-Synchronization-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24)

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

| Epoch Phase | Phase Length | Description |
| --- | --- | --- |
| Stake Distribution Snapshot | $s$ slots | A snapshot of note commitments are taken at the beginning of the epoch. We wait for this value to finalize before entering the next phase. |
| Buffer phase | $s$ slots | After the stake distribution is finalized, we wait another slot finality period before entering the next phase. This is to further ensure that there is at least one honest leader contributing to the epoch nonce randomness. If an adversary can predict the nonce, they can grind their coin secret keys to gain an advantage. |
| Lottery Constants Finalization | $s+\lfloor\frac{k}{f}\rfloor=4\lfloor\frac{k}{f}\rfloor$ slots | On the $2s^{th}$ slot into the epoch, the epoch nonce $\eta$ and the inferred total stake $D$ can be computed. We wait another $4\frac{k}{f}$ slots for these values to finalize. |

The epoch length is the sum of the individual phases: $3\lfloor \frac{k}{f} \rfloor + 3\lfloor \frac{k}{f} \rfloor + 4\lfloor \frac{k}{f} \rfloor =10 \lfloor \frac{k}{f} \rfloor$ slots.

### Epoch State

The epoch state holds the variables derived over the course of the epoch schedule. It is the 3-tuple $(\mathbb{C}_\text{LEAD}, \eta, D)$ described below.

| Symbol | Name | Description | Value |
| --- | --- | --- | --- |
| $\mathbb{C}_{\text{LEAD}}$​ | Eligible Leader Notes Commitment | A commitment to the set of notes eligible for leadership. | See [Eligible Leader Notes](https://nomos-tech.notion.site/Eligible-Leader-Notes-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df8129a312d36488639b41) |
| $\eta$​ | Epoch Nonce | Randomness used in the leadership lottery (selected once per epoch) | See [Epoch Nonce](https://nomos-tech.notion.site/Epoch-Nonce-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df813b9794d597a383dd05) |
| $D$​ | Inferred Total Stake (Lottery Difficulty) | Total stake inferred from watching the results of the lottery during the course of the epoch. $D$ is used as the stake relativization constant for the following epoch. | See [Total Stake Inference](https://nomos-tech.notion.site/Total-Stake-Inference-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81cf9096c3897182ad36) |

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

$$
\eta_{B} = \text{zkHASH}(\text{EPOCH\_NONCE\_V1}||\eta_{\text{parent}}||\rho_\text{LEAD}||\text{Fr}(sl)))
$$

where $\text{Fr}(sl)$ maps the slot number to the corresponding scalser in Poseidon’s scalar field and $\text{zkHASH}(..)$ is Poseidon2 as specified in [🔀\[1.0.2\] Common Cryptographic Components](https://nomos-tech.notion.site/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24) .

The epoch nonce used in the next epoch is $\eta_{B'}$ where $B'$ is the last block before the start of the “Lottery Constants Finalization” phase in the epoch schedule.

### Total Stake Inference

Given that stake is private in Cryptarchia, and that we want to maintain an approximately constant block rate, we must therefore adjust the difficulty of the slot lottery somehow based on the level of participation. The details can be found in the following document:

[🔀\[1.0.0\] Total Stake Inference](https://nomos-tech.notion.site/1-0-0-Total-Stake-Inference-22d261aa09df8051a454caa46ec54b34?pvs=24)

### Epoch State Pseudocode

At the start of each epoch, each validator must derive the new epoch state variables. This is done through the following protocol:

$\text{define } \textbf{compute\_epoch\_state}(ep, tip \in T)\rarr(\mathbb{C}_\text{LEAD}^{ep},\eta^{ep},D^{ep})$ :

$\textbf{case}\space ep = 0:$​

> The genesis epoch state is hardcoded upon chain initialization.

$\textbf{return}\space (\mathbb{C}_\text{GENESIS}, \eta_\text{GENESIS}, D_\text{GENESIS})$​

$\textbf{otherwise}:$​

> The epoch state is derived w.r.t. observations in the previous epoch. Here we compute the slot at the start of the previous epoch. We will query observations relative to this slot.

$sl_{ep-1} \coloneqq (ep-1) \cdot \text{EPOCH\_LENGTH}$

> Notes eligible for leadership lottery are those present in the commitment root at the start of the previous epoch.

$\mathbb{C}_\text{LEAD}^{ep} \coloneqq \textbf{commitment\_root\_at\_slot}(sl_{ep-1}, tip)$​

> The epoch nonce for epoch $ep$ is the value of $\eta$ at the beginning of the lottery constants finalization phase in the epoch schedule

$\eta^{ep} \coloneqq \textbf{epoch\_nonce\_at\_slot}(sl_{ep-1} + \lfloor6\frac{k}{f}\rfloor, tip)$​

> Total active stake is inferred from the number of blocks produced in the previous epoch during the stake freezing phase. It is also derived from the previous estimate of total stake, thus we recurse here to retrieve the previous epochs estimate $D^{ep-1}$​

$(\_,\_,D^{ep-1}) \coloneqq \textbf{compute\_epoch\_state}(ep-1,tip)$​

> The number of blocks produced during the first $6\frac{k}{f}$ slots of the previous epoch

$N_\text{BLOCKS}^{ep-1} \coloneqq |\{B \in T | sl_{ep - 1} \le sl_B \lt sl_{ep-1}+\lfloor 6\frac{k}{f} \rfloor\}|$

$D^{ep} \coloneqq \textbf{infer\_total\_active\_stake}(D^{ep-1}, N_\text{BLOCKS}^{ep-1})$​

$\textbf{return}\space (\mathbb{C}_\text{LEAD}^{ep}, \eta^{ep}, D^{ep})$​

## Leadership Lottery

A lottery is run for every slot to decide who is eligible to propose a block. For each slot, we can have 0 or more winners. In fact, it’s desirable to have short slots and many empty slots to allow for the network to propagate blocks and to reduce the chances of two leaders winning the same slot which are guaranteed forks.

### Proof of Leadership

The specifications of how a leader can prove that they have won the lottery are specified in the following document:

### Leader Rewards

As an incentive for producing blocks, leaders are rewarded with every block proposal. The rewarding protocol is specified in [🔀\[1.0.0\] Anonymous Leaders Reward Protocol](https://nomos-tech.notion.site/1-0-0-Anonymous-Leaders-Reward-Protocol-206261aa09df8120a49ffa49c71ba70d?pvs=24).

## Block Chain

### Fork Choice Rule

We use two fork choice rules, one during bootstrapping and a second once a node completes bootstrapping.

During bootstrapping, we must be resilient to malicious peers feeding us false chains, this calls for a more expensive fork choice rule that can differentiate between malicious long-range attacks and honest chains.

After bootstrapping we commit to the most honest looking chain we found and switch to a fork choice rule that rejects chains that diverge by more than $k$ blocks

[🔀\[1.0.0\] Cryptarchia Fork Choice Rule](https://nomos-tech.notion.site/1-0-0-Cryptarchia-Fork-Choice-Rule-21b261aa09df811584dfd362abb26627?pvs=24)

### Block ID

Block ID is defined by the hash of the block header [Block Header](https://nomos-tech.notion.site/Block-Header-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df8186bc6cec1fc01e4cf5), where hash is Blake2b as specified in [🔀\[1.0.2\] Common Cryptographic Components](https://nomos-tech.notion.site/1-0-2-Common-Cryptographic-Components-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24)

```text
def block_id(header: Header) -> hash
return hash(
b"BLOCK_ID_V1",
        header.bedrock_version,
        header.parent_block,
        header.slot.to_bytes(8, byteorder='little'),
        header.block_root,
# PoL fields
        header.proof_of_leadership.leader_voucher,
        header.proof_of_leadership.entropy_contribution,
        header.proof_of_leadership.proof.serialize(),
        header.proof_of_leadership.leader_key.compressed(),
)
```

### Block Header

```text
class Header: # 297 bytes
      bedrock_version: byte                    # 1 bytes
      parent_block: hash # 32 bytes
      slot: int # 8 bytes
 block_root: hash # 32 bytes
      proof_of_leadership: ProofOfLeadership   # 224 bytes
class ProofOfLeadership: # 224 bytes
      leader_voucher: zkhash                   # 32 bytes
      entropy_contribution: zkhash             # 32 bytes
      proof: Groth16Proof                      # 128 bytes
      leader_key: Ed25519PublicKey             # 32 bytes
```

### Block

[🔀\[1.1.1\] Block Construction, Validation and Execution](https://nomos-tech.notion.site/1-1-1-Block-Construction-Validation-and-Execution-33e261aa09df806c8fe3e10ede80918d?pvs=24)​

### Block Header Validation

Given block $B=(header, transactions)$ and the block tree $T$ where:

- $header$ is the header defined in [🔀\[1.1.1\] Block Construction, Validation and Execution - Header](https://nomos-tech.notion.site/Header-33e261aa09df806c8fe3e10ede80918d?pvs=24#39d261aa09df839cba2e0111e1ca9f99)​
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
    - $\pi_\text{PoL}$ is the slot lottery win proof as defined in [🔀\[1.1.0\] Proof of Leadership](https://nomos-tech.notion.site/1-1-0-Proof-of-Leadership-2e9261aa09df80058244c902defc6da2?pvs=24)
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

$(c_{loc}, B_\text{imm}, T) \coloneqq state$​

if $B \in T \lor \lnot \textbf{valid\_header}(B)$:

> Either we’ve already seen $B$ or it’s invalid, in both cases we ignore this block

$\textbf{return} \space state$​

$T' \coloneqq T \cup \{B\}$​

$c_{loc}' \coloneqq \begin{cases} 
 B &\text{if } \textbf{parent}(B) = c_{loc}\\
\textbf{fork\_choice}(c_{loc}, F_{T'}, k, s) &\text{if } \textbf{parent}(B) \neq c_{loc}
\end{cases}$

$\text{if } \text{fork\_choice\_rule} = \text{ONLINE}:$​

> Explicitly commit to the $k$-deep block if the [Online Fork Choice Rule](https://nomos-tech.notion.site/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df812caa08ce2f637a6278) is being used.

$(T', B_\text{imm}) \coloneqq \textbf{commit}(T', c_{loc}', k)$​

$\textbf{return} \space (c_{loc}', B_\text{imm}, T')$​

### Commit

We define the procedure that commits to the block, which is $depth$ deep from $c_{loc}$. This procedure computes the new latest immutable block $B_\text{imm}$.

$\text{define } \textbf{commit}(T,c_{loc},depth)\rarr (T', B_\text{imm}):$​

$\textbf{assert } \text{fork\_choice\_rule} = \text{ONLINE}$​

> Compute the latest immutable block, which is $depth$ deep from $c_{loc}$.

$B_\text{imm} \coloneqq \textbf{block\_at\_depth}(c_{loc}, depth)$​

> Prune all forks diverged deeper than $B_\text{imm}$, so that future blocks on those forks can be rejected by [Block Header Validation](https://nomos-tech.notion.site/Block-Header-Validation-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df810bb539f80ba66dba13).

$T' \coloneqq \textbf{prune\_forks}(T, B_\text{imm}, c_{loc})$​

$\textbf{return} \space (T', B_\text{imm})$​

### Fork Pruning

We define the fork pruning procedure that removes all blocks which are part of forks diverged deeper than a certain block.

$\text{define } \textbf{prune\_forks}(T, B)\rarr T':$​

$T' \coloneqq T$​

$\text{for each } B_\text{tip} \in F_T:$​

> If $B_\text{tip}$ is a fork diverged deeper than $B$, prune the fork.

$B_{\text{div}} \coloneqq \textbf{common\_ancestor}(B_\text{tip}, B)$​

$\text{if } B_\text{div} \neq B:$​

$T' \coloneqq \textbf{prune\_blocks}(B_\text{tip}, B_\text{div}, T)$​

$\textbf{return } T'$​

$\text{define } \textbf{prune\_blocks}(B_\text{new}, B_\text{old}, T)\rarr T’:$​

> Remove all blocks in the chain within range $(B_\text{old}, B_\text{new}]$ from $T$.

$(B, T') \coloneqq (B_\text{new}, T)$​

$\text{while } B \ne B_\text{old}:$​

$T' \coloneqq T' \setminus \{B\}$​

$B \coloneqq \textbf{parent}(B)$​

$\textbf{return } T'$​

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

