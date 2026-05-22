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

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Juan Pablo Madrigal-Cianci <jp@logos.co>

Revisions History

Version 

Changes 

Date

1.0.0 

Initial revision 

2026-04-24

���

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.

All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 

Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

Introduction

Objectives

This specification details the transaction fee mechanism (TFM) for the Logos Blockchain Execution Market, which encompasses the finite resources of on-chain computation. The design is engineered to achieve four primary, interconnected objectives:

To implement a market that allocates execution resources to transactions that derive the highest economic value from it, ensuring the network's limited capacity is used to maximize total utility.

To create an environment where the process of bidding for execution is intuitive and the transaction costs are predictable. This is paramount for fostering a healthy developer ecosystem and serving the professional entities that are the intended primary users of the Logos Blockchain network.

To design a system of rules where the dominant, profit-maximizing strategy for all participants (users and block builders) is to behave honestly and in accordance with the protocol's intended function. This minimizes the potential for manipulative behaviors like transaction censorship or mempool gaming.

To ensure that network usage contributes directly to the economic value of the native Logos Blockchain token, creating a positive feedback loop between network adoption and the health of its underlying asset.

Design Rationale

The design is founded on a target-based mechanism, philosophically aligned with Ethereum's EIP-1559. This model is crucial for long-term network health and security, as it actively steers execution utilization around a predefined target. This ensures the network remains performant and accessible for nodes with minimal hardware specifications, thereby promoting decentralization.

To further enhance security, this specification addresses a known vulnerability in the classic EIP-1559 design. As demonstrated by recent research (Cachin et al., 2023), EIP-1559 is susceptible to base fee manipulation by rational, non-myopic block builders. Our design incorporates a direct mitigation for this threat, as proposed in Cachin et al., 2023: an Exponential Moving Average (EMA) based update rule for the base fee. Given the EMA nature of this update, these enhancements smooth fluctuations in execution gas consumption, making the protocol significantly more resilient to strategic manipulation without compromising its core benefits of responsiveness and predictability

Furthermore, as opposed to the standard EIP-1559 mechanism, where base fee is burned and tips are immediately given to miners, in our setting we burn fees, and later, we mint rewards to which we add tips which are given to the block builders at a later block through the ����[1.0.0] Anonymous Leaders Reward Protocol, for privacy preservation. 

Overview

Our fee mechanism adapts Ethereum's EIP-1559 to the specific economic and security goals of the Logos Blockchain network. It provides predictable execution gas costs for users while creating a robust incentive structure for block builders and Blend nodes that minimizes harmful emergent strategies.

The mechanism operates on four core principles:

Dynamic Base Fee: A protocol-defined 
base_fee for Execution Gas must be paid for a transaction to be included in a block. This fee adjusts automatically based on a smoothed average of recent network demand relative to a predefined capacity target, ensuring sustainable network load. This 
base_fee is the minimal threshold to be paid for the transaction to be accepted by the block builder.

Priority Fee (Tip): To incentivize faster inclusion by block builders, users add a 
priority_fee on top of the base fee. This creates a simple and transparent auction for block space during periods of high demand. The proceeds of this goes to the block builder.

Fee Splitting and Deflation: The two fee components are treated differently. The entire 
base_fee is burned, permanently removing it from the supply. This creates a direct link between network activity and the economic value of the native token, applying deflationary pressure as usage grows. The 
priority_fee is not immediately distributed to the block builder (to preserve privacy), but instead it is directed into the block builders reward stream. 40% of the rewards will be allocated to block builders and the remaining 60% to Blend nodes. Rewards are privacy-preserving via ����[1.0.0] Anonymous Leaders Reward Protocol.

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
c_t >= b_exec[s]

Sort Valid Txs by revenue

Fill Block up to G_max

Previous Block's Execution Usage

Calculate Smoothed Average

Update Base Fees for Block s
b_exec[s]

User Transaction
Specifies how much they will pay: tx.c_t

Fees proposers

���

Incentive Analysis

User Strategy: The mechanism promotes a straightforward bidding strategy. A rational user should set their 
execution_gas_price (ctc_tct���) to their true maximum willingness to pay. Setting it higher provides no advantage and risks overpayment, while setting it lower risks the transaction being delayed if the 
base_fee rises. The 
priority_fee acts as a simple tip to gauge the market rate for priority inclusion during congestion.

Block Builder Strategy: The dominant strategy for a rational, profit-maximizing block builder is to follow the prescribed block construction algorithm honestly. The block builder's revenue is derived from (a) priority fees and (b) block rewards in accordance with network Key Performance Indicators (KPIs) as described in ����[1.0.0] Block Rewards, which incentivize them to include the transactions that maximize their revenue. Because the 
base_fee is determined algorithmically based on historical data, a block builder cannot manipulate it for their own immediate gain.

Economic Properties

Sustainable Resource Management: The TFM automatically steers network usage toward the target (GtargetG_\text{target}Gtarget���). By increasing the cost of Execution Gas during high demand, the protocol prevents network overload. This protects the ability of nodes with modest hardware to participate, safeguarding decentralization.

Deflationary Pressure: Burning the 
base_fee (and minting later a proportion of it back as rewards, cf ����[1.0.0] Block Rewards) establishes a direct link between network activity and the intrinsic economic utility of the Logos Blockchain token. As usage grows, the rate of token burn increases, applying deflationary pressure on the total supply and creating a sustainable economic flywheel.

Security Properties: Mitigation of Base Fee Manipulation

A critical feature of this design is its resilience to the base fee manipulation attack identified in classic EIP-1559. Our EMA-based update rule directly mitigates this vulnerability in two ways:

Impact Dampening: The influence of any single block's Execution Gas consumption (e.g., an empty block) on the fee update is dampened by a factor of (1���q1���q1���q), preventing sharp, manipulative drops in the 
base_fee.

Exponential Decay: The effect of a manipulative block on subsequent 
base_fee calculations decays exponentially, making it economically infeasible for an attacker to sustain the attack.

Construction

Notation

Symbol

Name

Value

Description

sss��� 

Block Number 

- 

The index of a block in the chain.

ttt��� 

Transaction 

- 

A single transaction submitted by a user.

gtg_tgt������ 

Execution Gas Consumed 

- 

The actual amount of Execution Gas consumed by transaction ttt upon execution.

ctc_tct������ 

Execution Gas Price 

- 

The user-specified price per unit of execution gas they will pay.

bexec[s]b_{\mathrm{exec}}[s]bexec���[s]��� 

Base Fee 

- 

The protocol-defined Execution Gas price for inclusion in block sss. This is initialized at 1 for the first block.

ptp_tpt������ 

Priority Fee 

- 

The portion of the Execution Gas price that serves as a tip to the block builder (pt=ct���bexec[s]p_t = c_t - b_{\mathrm{exec}}[s]pt���=ct������bexec���[s]).

G[s]G[s]G[s]��� 

Total Execution Gas Used 

- 

The sum of Execution Gas consumed by all transactions in block sss.

Gavg[s]G_{\mathrm{avg}}[s]Gavg���[s]��� 

Smoothed Average Execution Gas 

- 

The Exponential Moving Average (EMA) of Execution Gas used up to block sss.

Gmax���G_{\max}Gmax������ 

Max Execution Gas Per Block 

3,193,460 

A protocol constant defining the hard limit on G[s]G[s]G[s]. 

GtargetG_{\mathrm{target}}Gtarget������ 

Target Execution Gas Per Block 

1,596,730 

A protocol constant for the ideal Execution Gas usage. The TFM steers usage towards this target. This is set to half of GmaxG_{max}Gmax��� execution gas units.

��\phi����� 

Fee Adjustment Rate 

1/8 

A protocol constant controlling how quickly the base fee adjusts to demand.

qqq��� 

EMA Smoothing Factor 

9/10 

A protocol constant defining the weight of historical average in the EMA update rule.

FtF_tFt������ 

Total fee 

- 

Ft=gt������(bexec[s]+pt)=gt���ctF_t = g_t \,\cdot\bigl(b_{\mathrm{exec}}[s] + p_t\bigr)= g_t\cdot c_tFt���=gt������(bexec���[s]+pt���)=gt������ct������

R^burned[s]\hat{R}_{\mathrm{burned}}[s]R^burned���[s]��� 

Amount of base fees burnt 

- 

This is used as an input to compute the block rewards

Parameter Justification

We set ��=1/8\phi=1/8��=1/8, which results in up to a ��\pm��12.5% increase or decrease in the fee at every block. This choice of parameter is made following empirical evidence on other protocols where it has worked sufficiently well, such as Ethereum (cf. EIP 1559: A transaction fee market proposal).

We set a value of q=0.9q=0.9q=0.9 as it robustly achieves the primary security goal of mitigating base fee manipulation while retaining sufficient market responsiveness. This setting heavily dampens the influence of any single block's gas usage on the new smoothed average to a mere 10%, making manipulation attacks prohibitively expensive for their limited impact. This is economically equivalent to a lookback period of approximately 19 blocks.

Furthermore, we set Gmax=3,193,460G_\text{max} = 3,193,460Gmax���=3,193,460 Execution Gas units (cf as explained in ����[1.0.0][Overview] Cryptoeconomics), and Gtarget=1,596,730G_\text{target} = 1,596,730Gtarget���=1,596,730 Execution Gas units. The 50% target creates a perfectly symmetrical buffer, giving the network equal capacity to elastically expand block sizes to absorb demand spikes or contract them during lulls. Any other value would create an asymmetric system, making it either too volatile and over-reactive to demand increases (e.g., a 75% target) or too sluggish to respond to periods of low activity. This rationale is also borrowed from Ethereum���s EIP-1559 (cf EIP 1559: A transaction fee market proposal) and is also used in (Base Fee Manipulation In Ethereum���s EIP-1559 Transaction Fee Mechanism).

Block Builder Mechanism: Block Construction

A rational, profit-maximizing block builder must follow this algorithm to construct a valid and optimal block sss.

Algorithm Steps:

Fetch State: Retrieve the current base fee for the block to be built, bexec[s]b_{\mathrm{exec}}[s]bexec���[s].

Filter Mempool: From the set of all available transactions M\mathcal{M}M, create a candidate set M���\mathcal{M}'M��� containing only valid transactions where the user's Execution Gas price cap is sufficient to pay the base fee.

M���={���t���M���ct���bexec[s]���}\mathcal{M}' = \{\,t \in \mathcal{M} \mid c_t \ge b_{\mathrm{exec}}[s] \,\}M���={t���M���ct������bexec���[s]}

Sort Candidates: Sort the valid transactions in M���\mathcal{M}'M��� in descending order of revenue

Greedy Inclusion: Initialize an empty block and a running total for Execution Gas used, 
current_block_gas = 0. Iterate through the sorted transactions and add them to the block one by one, as long as the block's total Execution Gas does not exceed the Gmax���G_{\max}Gmax��� limit.

Pseudocode for Block Construction:

def construct_block(mempool, base_fee, gt, G_max):
# Step 2: Filter Mempool
valid_txs = [tx for tx in mempool if tx.execution_gas_price >= base_fee]

# Step 3: Sort Candidates by priority fee (descending)
valid_txs.sort(key=lambda tx: tx.revenue, reverse=True)

# Step 4: Greedy Inclusion
block_txs = []
current_block_gas = 0
for tx in valid_txs:
if current_block_gas + tx.gas_limit <= G_max:
block_txs.append(tx)
current_block_gas += tx.gas_limit # Using gas_limit for packing

return block_txs

���

On-Chain Rules: Fee Update and Revenue

After a block sss is executed and its total Execution Gas usage G[s]G[s]G[s] is known, the protocol deterministically applies the following rules.

Base Fee Update Rule

The base fee for the next block, s+1s+1s+1, is calculated based on the state of block sss.

Total Execution Gas Used: First, sum the actual Execution Gas consumed, gtg_tgt���, for all transactions ttt in the block Bs\mathcal{B}_sBs���.

G[s]=���t���BsgtG[s] = \sum_{t \in \mathcal{B}_s} g_tG[s]=t���Bs���������gt���

Smoothed Average Update: Update the EMA of Execution Gas usage.

Gavg[s]=(1���q)���G[s]+q���Gavg[s���1]G_{\mathrm{avg}}[s] = (1 - q) \cdot G[s] + q \cdot G_{\mathrm{avg}}[s-1]Gavg���[s]=(1���q)���G[s]+q���Gavg���[s���1]

Next Base Fee Calculation: Update the base fee for block s+1s+1s+1.

bexec[s+1]=bexec[s]���(1+�����Gavg[s]���GtargetGtarget)b_{\mathrm{exec}}[s+1] = b_{\mathrm{exec}}[s] \cdot \left(1 + \phi \cdot \frac{G_{\mathrm{avg}}[s] - G_{\mathrm{target}}}{G_{\mathrm{target}}}\right)bexec���[s+1]=bexec���[s]���(1+�����Gtarget���Gavg���[s]���Gtarget������)

Pseudocode for Base Fee Update:

Because base fee computation affects consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.

The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. Therefore we provide here a reference implementation that uses unsigned integers to have a common reference.

First we rewrite

Gavg[s]=(1���0.9)���G[s]+0.9���Gavg[s���1]=G[s]+9���Gavg[s���1]10\begin{align*}
G_{\mathrm{avg}}[s] &= (1 - 0.9) \cdot G[s] + 0.9 \cdot G_{\mathrm{avg}}[s-1]= \frac{G[s] + 9 \cdot G_\text{avg}[s-1]}{10}
\end{align*}Gavg���[s]���=(1���0.9)���G[s]+0.9���Gavg���[s���1]=10G[s]+9���Gavg���[s���1]������

bexec[s+1]=bexec[s]���(1+18���Gavg[s]���GtargetGtarget)=bexec[s]���7���Gtarget+Gavg[s]8���Gtarget\begin{align*} b_\text{exec}[s+1] &= b_\text{exec}[s]\cdot \left( 1 + \frac{1}{8} \cdot \frac{G_\text{avg}[s] - G_\text{target}}{G_\text{target}} \right)\\
&=b_\text{exec}[s] \cdot \frac{7 \cdot G_\text{target} + G_\text{avg}[s]}{8 \cdot G_\text{target}}
\end{align*}bexec���[s+1]���=bexec���[s]���(1+81������Gtarget���Gavg���[s]���Gtarget������)=bexec���[s]���8���Gtarget���7���Gtarget���+Gavg���[s]������

And so we propose the following code reference:

EMA_DENOMINATOR = 10 # from q = 9/10
EMA_PREV_WEIGHT = 9 # from q = 9/10
BASE_FEE_NUMERATOR = 11_176_760 # = 7 * G_target
BASE_FEE_DENOMINATOR = 12_773_440 # = 8 * G_target

def update_g_avg_num(prev_g_avg_num: int, block_gas_used: int) -> int:
numerator = block_gas_used + EMA_PREV_WEIGHT * prev_g_avg_num
return numerator // EMA_DENOMINATOR

def update_base_fee(base_fee: int, g_avg: int) -> int:
numerator = base_fee * (BASE_FEE_NUMERATOR + g_avg)
return numerator // BASE_FEE_DENOMINATOR

���

Fee Distribution

For every transaction t, the effective priority fee is

pt=ct���bexec[s].p_t = c_t - b_{\mathrm{exec}}[s].pt���=ct������bexec���[s].

The final fee FtF_tFt��� paid by the transaction ttt is:

Ft=gt������(bexec[s]+pt)=gt���ct  

F_t = g_t \,\cdot\bigl(b_{\mathrm{exec}}[s] + p_t\bigr)= g_t\cdot c_t
\
\
Ft���=gt������(bexec���[s]+pt���)=gt������ct���  

Let the amount of Execution fee burnt in a block be:

R^burned(s)=���t���Bs(gt���bexec[s]).\hat{R}_{\mathrm{burned}}(s)
= \sum_{t \in \mathcal{B}_s} \bigl(g_t \cdot b_{\mathrm{exec}}[s]\bigr).R^burned���(s)=t���Bs���������(gt������bexec���[s]).

This burned quantity is then used as a input for the computation of the block rewards, as described in ����[1.0.0] Block Rewards.

EMA_DENOMINATOR = 10 # from q = 9/10
EMA_PREV_WEIGHT = 9 # from q = 9/10
BASE_FEE_NUMERATOR = 11_176_760 # = 7 * G_target
BASE_FEE_DENOMINATOR = 12_773_440 # = 8 * G_target

def update_g_avg_num(prev_g_avg_num: int, block_gas_used: int) -> int:
numerator = block_gas_used + EMA_PREV_WEIGHT * prev_g_avg_num
return numerator // EMA_DENOMINATOR

def update_base_fee(base_fee: int, g_avg: int) -> int:
numerator = base_fee * (BASE_FEE_NUMERATOR + g_avg)
return numerator // BASE_FEE_DENOMINATOR
