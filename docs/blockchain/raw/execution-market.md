# EXECUTION-MARKET

| Field | Value |
| --- | --- |
| Name | Execution Market |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | Juan Pablo Madrigal-Cianci <jp@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) rendered via katex; tables and headings
> are converted from Notion HTML. A formatting polish (semantic line breaks, code block fences
> for code samples, internal cross-references) is still recommended.

---

## Revisions History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision | 2026-04-24 |

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

## Introduction

### Objectives

This specification details the transaction fee mechanism (TFM) for the Logos Blockchain Execution Market, which encompasses the finite resources of on-chain computation. The design is engineered to achieve four primary, interconnected objectives:

To implement a market that allocates execution resources to transactions that derive the highest economic value from it, ensuring the network's limited capacity is used to maximize total utility.

To create an environment where the process of bidding for execution is intuitive and the transaction costs are predictable. This is paramount for fostering a healthy developer ecosystem and serving the professional entities that are the intended primary users of the Logos Blockchain network.

To design a system of rules where the dominant, profit-maximizing strategy for all participants (users and block builders) is to behave honestly and in accordance with the protocol's intended function. This minimizes the potential for manipulative behaviors like transaction censorship or mempool gaming.

To ensure that network usage contributes directly to the economic value of the native Logos Blockchain token, creating a positive feedback loop between network adoption and the health of its underlying asset.

### Design Rationale

The design is founded on a target-based mechanism, philosophically aligned with Ethereum's EIP-1559. This model is crucial for long-term network health and security, as it actively steers execution utilization around a predefined target. This ensures the network remains performant and accessible for nodes with minimal hardware specifications, thereby promoting decentralization.

To further enhance security, this specification addresses a known vulnerability in the classic EIP-1559 design. As demonstrated by recent research ([Cachin et al., 2023](https://arxiv.org/pdf/2304.11478)), EIP-1559 is susceptible to base fee manipulation by rational, non-myopic block builders. Our design incorporates a direct mitigation for this threat, as proposed in [Cachin et al., 2023](https://arxiv.org/pdf/2304.11478): an Exponential Moving Average (EMA) based update rule for the base fee. Given the EMA nature of this update, these enhancements smooth fluctuations in execution gas consumption, making the protocol significantly more resilient to strategic manipulation without compromising its core benefits of responsiveness and predictability

Furthermore, as opposed to the standard EIP-1559 mechanism, where base fee is burned and tips are immediately given to miners, in our setting we burn fees, and later, we mint rewards to which we add tips which are given to the block builders at a later block through the [[1.0.0] Anonymous Leaders Reward Protocol](https://nomos-tech.notion.site/1-0-0-Anonymous-Leaders-Reward-Protocol-206261aa09df8120a49ffa49c71ba70d?pvs=24), for privacy preservation.

## Overview

Our fee mechanism adapts Ethereum's EIP-1559 to the specific economic and security goals of the Logos Blockchain network. It provides predictable execution gas costs for users while creating a robust incentive structure for block builders and Blend nodes that minimizes harmful emergent strategies.

The mechanism operates on four core principles:

Dynamic Base Fee: A protocol-defined

base\_fee

for Execution Gas must be paid for a transaction to be included in a block. This fee adjusts automatically based on a smoothed average of recent network demand relative to a predefined capacity target, ensuring sustainable network load. This

base\_fee

is the minimal threshold to be paid for the transaction to be accepted by the block builder.

Priority Fee (Tip): To incentivize faster inclusion by block builders, users add a

priority\_fee

on top of the base fee. This creates a simple and transparent auction for block space during periods of high demand. The proceeds of this goes to the block builder.

Fee Splitting and Deflation: The two fee components are treated differently. The entire

base\_fee

 is burned, permanently removing it from the supply. This creates a direct link between network activity and the economic value of the native token, applying deflationary pressure as usage grows. The

priority\_fee

 is not immediately distributed to the block builder (to preserve privacy), but instead it is directed into the block builders reward stream. 40% of the rewards will be allocated to block builders and the remaining 60% to Blend nodes. Rewards are privacy-preserving via [[1.0.0] Anonymous Leaders Reward Protocol](https://nomos-tech.notion.site/1-0-0-Anonymous-Leaders-Reward-Protocol-206261aa09df8120a49ffa49c71ba70d?pvs=24).

The entire lifecycle can be visualized in the following flow:

Rewards

Fee Burn

Proposer Actions

Protocol Logic

User

Mint tips to leaders reward pool later

Burned fees

Mint from burned fees at a later block

Mempool

Filter Mempool  
c\_t >= b\_exec[s]

Sort Valid Txs by revenue

Fill Block up to G\_max

Previous Block's Execution Usage

Calculate Smoothed Average

Update Base Fees for Block s  
b\_exec[s]

User Transaction  
Specifies how much they will pay: tx.c\_t

Fees proposers

### Incentive Analysis

User Strategy: The mechanism promotes a straightforward bidding strategy. A rational user should set their

execution\_gas\_price

( $c\_t$ ) to their true maximum willingness to pay. Setting it higher provides no advantage and risks overpayment, while setting it lower risks the transaction being delayed if the

base\_fee

rises. The

priority\_fee

acts as a simple tip to gauge the market rate for priority inclusion during congestion.

Block Builder Strategy: The dominant strategy for a rational, profit-maximizing block builder is to follow the prescribed block construction algorithm honestly. The block builder's revenue is derived from (a) priority fees and (b) block rewards in accordance with network Key Performance Indicators (KPIs) as described in [[1.0.0] Block Rewards](https://nomos-tech.notion.site/1-0-0-Block-Rewards-d96261aa09df838ca36601b4b27b49b4?pvs=24), which incentivize them to include the transactions that maximize their revenue. Because the

base\_fee

is determined algorithmically based on historical data, a block builder cannot manipulate it for their own immediate gain.

### Economic Properties

Sustainable Resource Management: The TFM automatically steers network usage toward the target ( $G\_\text{target}$ ). By increasing the cost of Execution Gas during high demand, the protocol prevents network overload. This protects the ability of nodes with modest hardware to participate, safeguarding decentralization.

Deflationary Pressure: Burning the

base\_fee

(and minting later a proportion of it back as rewards, cf [[1.0.0] Block Rewards](https://nomos-tech.notion.site/1-0-0-Block-Rewards-d96261aa09df838ca36601b4b27b49b4?pvs=24)) establishes a direct link between network activity and the intrinsic economic utility of the Logos Blockchain token. As usage grows, the rate of token burn increases, applying deflationary pressure on the total supply and creating a sustainable economic flywheel.

### Security Properties: Mitigation of Base Fee Manipulation

A critical feature of this design is its resilience to the base fee manipulation attack identified in classic EIP-1559. Our EMA-based update rule directly mitigates this vulnerability in two ways:

Impact Dampening: The influence of any single block's Execution Gas consumption (e.g., an empty block) on the fee update is dampened by a factor of ( $1q$ ), preventing sharp, manipulative drops in the

base\_fee

.

Exponential Decay: The effect of a manipulative block on subsequent

base\_fee

calculations decays exponentially, making it economically infeasible for an attacker to sustain the attack.

## Construction

### Notation

| Symbol | Name | Value | Description |
| --- | --- | --- | --- |
| $s$  | Block Number | - | The index of a block in the chain. |
| $t$  | Transaction | - | A single transaction submitted by a user. |
| $g\_t$  | Execution Gas Consumed | - | The actual amount of Execution Gas consumed by transaction $t$ upon execution. |
| $c\_t$  | Execution Gas Price | - | The user-specified price per unit of execution gas they will pay. |
| $b\_{\mathrm{exec}}[s]$  | Base Fee | - | The protocol-defined Execution Gas price for inclusion in block $s$ . This is initialized at 1 for the first block. |
| $p\_t$  | Priority Fee | - | The portion of the Execution Gas price that serves as a tip to the block builder ( $p\_t = c\_t - b\_{\mathrm{exec}}[s]$ ). |
| $G[s]$  | Total Execution Gas Used | - | The sum of Execution Gas consumed by all transactions in block $s$ . |
| $G\_{\mathrm{avg}}[s]$  | Smoothed Average Execution Gas | - | The Exponential Moving Average (EMA) of Execution Gas used up to block $s$ . |
| $G\_{\max}$  | Max Execution Gas Per Block | 3,193,460 | A protocol constant defining the hard limit on $G[s]$ . |
| $G\_{\mathrm{target}}$  | Target Execution Gas Per Block | 1,596,730 | A protocol constant for the ideal Execution Gas usage. The TFM steers usage towards this target. This is set to half of $G\_{max}$ execution gas units. |
| $\phi$  | Fee Adjustment Rate | 1/8 | A protocol constant controlling how quickly the base fee adjusts to demand. |
| $q$  | EMA Smoothing Factor | 9/10 | A protocol constant defining the weight of historical average in the EMA update rule. |
| $F\_t$  | Total fee | - | $F\_t = g\_t \,\cdot\bigl(b\_{\mathrm{exec}}[s] + p\_t\bigr)= g\_t\cdot c\_t$  |
| $\hat{R}\_{\mathrm{burned}}[s]$  | Amount of base fees burnt | - | This is used as an input to compute the block rewards |

#### Parameter Justification

We set  $\phi=1/8$ , which results in up to a  $\pm$ 12.5% increase or decrease in the fee at every block. This choice of parameter is made following empirical evidence on other protocols where it has worked sufficiently well, such as Ethereum (cf. [EIP 1559: A transaction fee market proposal](https://ethereum.github.io/abm1559/notebooks/eip1559.html)).

We set a value of  $q=0.9$  as it robustly achieves the primary security goal of mitigating base fee manipulation while retaining sufficient market responsiveness. This setting heavily dampens the influence of any single block's gas usage on the new smoothed average to a mere 10%, making manipulation attacks prohibitively expensive for their limited impact. This is economically equivalent to a lookback period of approximately 19 blocks.

Furthermore, we set $G\_\text{max} = 3,193,460$ Execution Gas units (cf as explained in [[1.0.0][Overview] Cryptoeconomics](https://nomos-tech.notion.site/1-0-0-Overview-Cryptoeconomics-4d6261aa09df82b4977c81722de0027f?pvs=24)), and $G\_\text{target} = 1,596,730$ Execution Gas units. The 50% target creates a perfectly symmetrical buffer, giving the network equal capacity to elastically expand block sizes to absorb demand spikes or contract them during lulls. Any other value would create an asymmetric system, making it either too volatile and over-reactive to demand increases (e.g., a 75% target) or too sluggish to respond to periods of low activity. This rationale is also borrowed from Ethereums EIP-1559 (cf [EIP 1559: A transaction fee market proposal](https://ethereum.github.io/abm1559/notebooks/eip1559.html)) and is also used in ([Base Fee Manipulation In Ethereums EIP-1559 Transaction Fee Mechanism](https://arxiv.org/pdf/2304.11478)).

### Block Builder Mechanism: Block Construction

A rational, profit-maximizing block builder must follow this algorithm to construct a valid and optimal block $s$ .

Algorithm Steps:

Fetch State: Retrieve the current base fee for the block to be built, $b\_{\mathrm{exec}}[s]$ .

Filter Mempool: From the set of all available transactions $\mathcal{M}$ , create a candidate set $\mathcal{M}'$ containing only valid transactions where the user's Execution Gas price cap is sufficient to pay the base fee.

$$
\mathcal{M}' = \{\,t \in \mathcal{M} \mid c\_t \ge b\_{\mathrm{exec}}[s] \,\}
$$
M={tMctbexec[s]}

Sort Candidates: Sort the valid transactions in $\mathcal{M}'$ in descending order of revenue

Greedy Inclusion: Initialize an empty block and a running total for Execution Gas used,

current\_block\_gas = 0

. Iterate through the sorted transactions and add them to the block one by one, as long as the block's total Execution Gas does not exceed the $G\_{\max}$ limit.

Pseudocode for Block Construction:

def construct\_block(mempool, base\_fee, gt, G\_max):
# Step 2: Filter Mempool
valid\_txs = [tx for tx in mempool if tx.execution\_gas\_price >= base\_fee]
# Step 3: Sort Candidates by priority fee (descending)
valid\_txs.sort(key=lambda tx: tx.revenue, reverse=True)
# Step 4: Greedy Inclusion
block\_txs = []
current\_block\_gas = 0
for tx in valid\_txs:
if current\_block\_gas + tx.gas\_limit <= G\_max:
block\_txs.append(tx)
current\_block\_gas += tx.gas\_limit # Using gas\_limit for packing
return block\_txs

### On-Chain Rules: Fee Update and Revenue

After a block $s$ is executed and its total Execution Gas usage $G[s]$ is known, the protocol deterministically applies the following rules.

#### Base Fee Update Rule

The base fee for the next block, $s+1$ , is calculated based on the state of block $s$ .

Total Execution Gas Used: First, sum the actual Execution Gas consumed, $g\_t$ , for all transactions $t$ in the block $\mathcal{B}\_s$ .

$$
G[s] = \sum\_{t \in \mathcal{B}\_s} g\_t
$$
G[s]=tBsgt

Smoothed Average Update: Update the EMA of Execution Gas usage.

$$
G\_{\mathrm{avg}}[s] = (1 - q) \cdot G[s] + q \cdot G\_{\mathrm{avg}}[s-1]
$$
Gavg[s]=(1q)G[s]+qGavg[s1]

Next Base Fee Calculation: Update the base fee for block $s+1$ .

$$
b\_{\mathrm{exec}}[s+1] = b\_{\mathrm{exec}}[s] \cdot \left(1 + \phi \cdot \frac{G\_{\mathrm{avg}}[s] - G\_{\mathrm{target}}}{G\_{\mathrm{target}}}\right)
$$
bexec[s+1]=bexec[s](1+GtargetGavg[s]Gtarget)

Pseudocode for Base Fee Update:

Because base fee computation affects consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.

The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. Therefore we provide here a reference implementation that uses unsigned integers to have a common reference.

First we rewrite

$$
\begin{align\*}
G\_{\mathrm{avg}}[s] &= (1 - 0.9) \cdot G[s] + 0.9 \cdot G\_{\mathrm{avg}}[s-1]= \frac{G[s] + 9 \cdot G\_\text{avg}[s-1]}{10}
\end{align\*}
$$
Gavg[s]=(10.9)G[s]+0.9Gavg[s1]=10G[s]+9Gavg[s1]

$$
\begin{align\*} b\_\text{exec}[s+1] &= b\_\text{exec}[s]\cdot \left( 1 + \frac{1}{8} \cdot \frac{G\_\text{avg}[s] - G\_\text{target}}{G\_\text{target}} \right)\\
&=b\_\text{exec}[s] \cdot \frac{7 \cdot G\_\text{target} + G\_\text{avg}[s]}{8 \cdot G\_\text{target}}
\end{align\*}
$$
bexec[s+1]=bexec[s](1+81GtargetGavg[s]Gtarget)=bexec[s]8Gtarget7Gtarget+Gavg[s]

And so we propose the following code reference:

EMA\_DENOMINATOR = 10 # from q = 9/10
EMA\_PREV\_WEIGHT = 9 # from q = 9/10
BASE\_FEE\_NUMERATOR = 11\_176\_760 # = 7 \* G\_target
BASE\_FEE\_DENOMINATOR = 12\_773\_440 # = 8 \* G\_target
def update\_g\_avg\_num(prev\_g\_avg\_num: int, block\_gas\_used: int) -> int:
numerator = block\_gas\_used + EMA\_PREV\_WEIGHT \* prev\_g\_avg\_num
return numerator // EMA\_DENOMINATOR
def update\_base\_fee(base\_fee: int, g\_avg: int) -> int:
numerator = base\_fee \* (BASE\_FEE\_NUMERATOR + g\_avg)
return numerator // BASE\_FEE\_DENOMINATOR

#### Fee Distribution

For every transaction t, the effective priority fee is

$$
p\_t = c\_t - b\_{\mathrm{exec}}[s].
$$
pt=ctbexec[s].

The final fee $F\_t$ paid by the transaction $t$ is:

$$
F\_t = g\_t \,\cdot\bigl(b\_{\mathrm{exec}}[s] + p\_t\bigr)= g\_t\cdot c\_t
\
\
$$
Ft=gt(bexec[s]+pt)=gtct

Let the amount of Execution fee burnt in a block be:

$$
\hat{R}\_{\mathrm{burned}}(s)
= \sum\_{t \in \mathcal{B}\_s} \bigl(g\_t \cdot b\_{\mathrm{exec}}[s]\bigr).
$$
R^burned(s)=tBs(gtbexec[s]).

This burned quantity is then used as a input for the computation of the block rewards, as described in [[1.0.0] Block Rewards](https://nomos-tech.notion.site/1-0-0-Block-Rewards-d96261aa09df838ca36601b4b27b49b4?pvs=24).

EMA\_DENOMINATOR = 10 # from q = 9/10
EMA\_PREV\_WEIGHT = 9 # from q = 9/10
BASE\_FEE\_NUMERATOR = 11\_176\_760 # = 7 \* G\_target
BASE\_FEE\_DENOMINATOR = 12\_773\_440 # = 8 \* G\_target
def update\_g\_avg\_num(prev\_g\_avg\_num: int, block\_gas\_used: int) -> int:
numerator = block\_gas\_used + EMA\_PREV\_WEIGHT \* prev\_g\_avg\_num
return numerator // EMA\_DENOMINATOR
def update\_base\_fee(base\_fee: int, g\_avg: int) -> int:
numerator = base\_fee \* (BASE\_FEE\_NUMERATOR + g\_avg)
return numerator // BASE\_FEE\_DENOMINATOR
