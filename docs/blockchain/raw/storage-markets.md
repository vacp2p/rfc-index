# STORAGE-MARKETS

| Field | Value |
| --- | --- |
| Name | Storage Markets |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | Juan Pablo Madrigal-Cianci <jp@logos.co> |
| Contributors | Frederico Teixeira <frederico@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Juan Pablo Madrigal-Cianci <jp@logos.co>, Frederico Teixeira <frederico@logos.co>
Revisions History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2026-04-24
❗
Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.

All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 

Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.
Introduction
This document provides the formal specification for the fee collection mechanism of the Permanent Storage market. The primary objective is to define a system that is robust, predictable, and economically sustainable. This mechanism is a critical component of the overall Permanent Storage Market Transaction Fee Mechanism (TFM), which is designed as a self-contained, usage-driven market, economically decoupled from the protocol's core consensus and privacy services.
In what follows, Logos Blockchain Storage refers to the Permanent Storage markets and Logos Blockchain Storage Gas refers to the Permanent Storage Gas respectively. 
Requirements and Rationale
The mechanism is designed with the following core requirements, derived from the project's goals:
Predictability: Consumers of the Logos Blockchain Storage require a high degree of cost predictability for their own operational planning.
Robustness: The mechanism must be able to adapt to significant, medium-term shifts in demand without requiring constant, emergency governance intervention.
Fairness: The fee paid by a user must be directly and transparently proportional to the resources they consume.
Simplicity: The on-chain implementation should be as simple as possible to minimize attack surface and ensure auditability.
Justification. As will be discussed later, the tradeoff between adaptability and predictability of the mechanism is determined by its parameters. In scenarios of high volatility, its core design principle is to act as a shock absorber, deliberately filtering out high-frequency, transient volatility by operating over longer timeframes and using a smoothed moving average (EMA). For the primary consumer, reacting to every momentary spike in demand would create untenable price chaos. This model, therefore, intentionally forgoes instantaneous adaptation in favor of providing crucial timeframe-level price certainty, ensuring that fees reflect meaningful, medium-term trends rather than reacting to volatile, short-term market noise.
Overview
The proposed fee mechanism operates on a simple but powerful principle: the price for Logos Blockchain Storage is fixed and predictable within a given timeframe (epoch for Permanent Storage), but it adjusts smoothly between timeframes based on observed network usage.
When a user submits data, a fee is calculated based on the Logos Blockchain Storage Gas consumption. This fee is determined by a price per Gas, 
𝑃
𝑆
𝑇
𝑅
P
STR
	​

, which is known in advance for the entire timeframe. 
At the end of each timeframe, the protocol tallies the total amount of Logos Blockchain Storage Gas that was stored. It compares this actual usage to an adaptive target—a "healthy" usage level that is itself a dynamic blend of a long-term policy goal and recent historical usage. Based on whether the actual usage was above or below this target, the price 
𝑃
𝑆
𝑇
𝑅
P
STR
	​

 for the next timeframe is adjusted slightly up or down.
This flow can be visualized as follows: 

timeframes 's' Begins
Price P_STR(s) is Fixed & Known

Data Submission
- Logos Blockchain Storage Gas: S_gas
- Fee = S_gas * P_STR(s) + ...

Protocol State:
- C_Usage(s) += S_gas
- Fee → Storage Reward Bucket

timeframes 's' Ends
- Total Usage C_Usage(s) is Final

Price Update Rule Executed:
- Calculate Effective Target T_Effective(s)
- Compare C_Usage(s) to T_Effective(s)
- Calculate and set new price P_STR(s+1) for next timeframes

Loop for all blocks in timeframes

​
This model provides the best of both worlds: users have perfect price clarity for the duration of a timeframe, while the system as a whole can gracefully adapt to evolving market conditions over time.
Construction
This section defines the precise algorithm, constants, and state variables for the Logos Blockchain Storage TFM.
Core Fee Equation
The fee for a Logos Blockchain Storage transaction, 
𝐹
STR
F
STR
	​

, is a linear function of Logos Blockchain Storage Gas' size, 
𝑆
gas
S
gas
	​

, and the price-per-gas for the current timeframe, 
𝑃
STR
(
𝑠
)
P
STR
	​

(s).
𝐹
STR
=
𝑆
gas
⋅
𝑃
STR
(
𝑠
)
F
STR
	​

=S
gas
	​

⋅P
STR
	​

(s)
As a remark, the equation above assumes a linear increase of 
𝐹
STR
F
STR
	​

 with respect to 
𝑆
gas
S
gas
	​

. For completeness, a more general version can be
𝐹
STR
=
𝑓
(
𝑆
gas
)
⋅
𝑃
STR
F
STR
	​

=f(S
gas
	​

)⋅P
STR
	​

	​

with 
𝑓
:
𝑁
→
𝑅
+
f:N→R
+
	​

 a monotonically increasing function. Making f sublinear can be understood as accounting for economies of scale, while making 
𝑓
f superlinear can be understood as a penalization for using larger data sizes. We decided to go with the linear form of 
𝑓
f as it was the least opinionated. Examples of this could be
𝐹
STR
exp
	
=
exp
⁡
(
𝛼
𝑆
gas
)
⋅
𝑃
STR
𝛼
>
0


𝐹
poly
exp
	
=
𝑆
gas
𝛽
⋅
𝑃
STR
,
𝛽
>
1
F
STR
exp
	​

F
poly
exp
	​

	​

=exp(αS
gas
	​

)⋅P
STR
	​

α>0
=S
gas
β
	​

⋅P
STR
	​

,β>1
	​

Protocol Constants
To ensure on-chain efficiency, the protocol shall use an Exponential Moving Average (EMA) for its adaptive target calculation. The behavior of the TFM is governed by the following on-chain constants, which are set at genesis. 
Symbol
	
Name
	
Description
	
Initial Value
	
Justification


𝑇
base
T
base
	​

​
	
Baseline Target
	
A static, policy-driven usage target in Logos Blockchain Storage Gas per timeframe. Acts as a long-term gravitational anchor for the dynamic target.
	
0 Permanent Storage Gas per block.
	
It should represent a conservative initial timeframe capacity. providing a healthy buffer and a clear policy goal.


𝑤
w​
	
Anchor Weight
	
A coefficient in 
[
0
,
1
]
[0,1] determining the influence of 
𝑇
base
T
base
	​

. It's the "gravity knob" for the system.
	
for Permanent Storage: 0
	
Allows the target to be primarily driven by recent demand, ensuring adaptability, while the 
𝑤
w% pull from 
𝑇
base
T
base
	​

 prevents long-term drift.


𝛼
α​
	
Max Adjustment Factor
	
The maximum fractional amount the price can change per timeframe. Acts as "safety brakes" to bound price volatility.
	
0.125 for Permanent Storage
	
A 
100
𝛼
100α% cap provides strong predictability for users planning across timeframes while allowing the price to respond effectively to sustained demand changes.


𝛽
β​
	
EMA Smoothing Factor
	
A coefficient in 
[
0
,
1
]
[0,1] controlling the responsiveness of the usage EMA. It governs the speed of adaptation.
	
0.5 for Permanent Storage
	
A value of 
𝛽
β gives significant weight to the most recent timeframe's usage while incorporating the "memory" of the system with a half-life of 1 timeframe, balancing responsiveness and stability.


𝑇
RA
(
−
1
)
T
RA
	​

(−1)​
	
Initial Usage EMA
	
First value for EMA
	
0 (=
𝑇
base
T
base
	​

)
	
Given 
𝑇
base
=
0
T
base
	​

=0, this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market
activity and anchors the EMA to the long-term policy goal from the outset.


𝑃
STR
(
0
)
P
STR
	​

(0)​
	
Initial Price
	
The price on the first epoch
	
1 LGO/gas
	
The initial price is set conservatively low at the beginning and let to discover the true market price


𝑠
s​
	
timeframe
	
How often things adjust
	
1 epoch
	
Primary users of the Storage market plan operational costs over days or weeks, not block-by-block. 
Parameter Justification
For simplicity, we set 
𝑇
base
=
0
T
base
	​

=0 as an anchor and 
𝑤
=
0
w=0 as blocks are already constrained by execution. This is to avoid imposing an opinionated choice of parameters, specially at the beginning of the protocol. 
The EMA factor (
𝛽
=
0.5
β=0.5) makes the adaptive target highly sensitive to recent network activity by giving 50% weight to the latest session's usage, creating an effective "memory" of approximately 3 epochs.
The maximum adjustment factor (
𝛼
=
0.125
α=0.125) provides a crucial layer of predictability, guaranteeing users that the price cannot change by more than 12.5% between any two epochs, thus fulfilling a core design requirement for stable operational planning. 
The seed value for the EMA is set to 
𝑇
RA
(
−
1
)
=
𝑇
base
=
0
T
RA
	​

(−1)=T
base
	​

=0.  Given 
𝑇
base
=
0
T
base
	​

=0, this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset.
💡
Why is the index 
−
1
−1, not 
0
0? The price update algorithm runs at the end of timeframe 
𝑠
s and requires 
𝑇
RA
(
𝑠
−
1
)
T
RA
	​

(s−1) as its prior EMA value. When 
𝑠
=
0
s=0, the algorithm therefore requires 
𝑇
RA
(
−
1
)
T
RA
	​

(−1) as its seed. The value 
𝑇
RA
(
0
)
T
RA
	​

(0) is already a
well-defined computed quantity — the EMA produced after the first epoch's observed usage: 
𝑇
RA
(
0
)
=
𝛽
⋅
𝐶
usage
(
0
)
+
(
1
−
𝛽
)
⋅
𝑇
RA
(
−
1
)
T
RA
	​

(0)=β⋅C
usage
	​

(0)+(1−β)⋅T
RA
	​

(−1). Using index 
−
1
−1 for the seed avoids a naming collision with this computed value.
Implementation note. With 
𝑤
=
0
w=0 and 
𝑇
RA
(
−
1
)
=
0
T
RA
	​

(−1)=0, the effective target

𝑇
effective
T
effective
	​

 will be zero during the first epoch unless 
𝐶
usage
(
0
)
>
0
C
usage
	​

(0)>0.
The reference implementation handles this correctly via the if effective_target == 0: return self.price guard, which holds the price at 
𝑃
STR
(
0
)
P
STR
	​

(0) until the first non-zero usage
epoch provides a meaningful signal. This is the intended behavior at genesis.
The precise value of 
𝑃
STR
(
0
)
P
STR
	​

(0) is not critical to the long-term behavior of the mechanism. As established in the equilibrium analysis, the price update rule converges autonomously to the market-clearing price 
𝑃
∗
P
∗
 regardless of the starting point, provided the stability condition 
(
∗
)
(∗) holds (see 🔀
[1.0.0][Analysis] Storage Market - Price Stability Analysis). The only hard requirement is for 
𝑃
STR
(
0
)
P
STR
	​

(0) to be sufficiently low so as not to suppress early adoption before the mechanism has observed enough demand to self-correct. 
More precisely, since the price can increase by at most 
𝛼
=
12.5
%
α=12.5% per epoch, the number
of epochs required to reach a target price 
𝑃
∗
P
∗
 from an initial price 
𝑃
STR
(
0
)
<
𝑃
∗
P
STR
	​

(0)<P
∗
 is bounded above by:
𝑁
≤
⌈
log
⁡
1
+
𝛼
 ⁣
(
𝑃
∗
𝑃
STR
(
0
)
)
⌉
=
⌈
ln
⁡
(
𝑃
∗
/
𝑃
STR
(
0
)
)
ln
⁡
(
1.125
)
⌉
N≤⌈log
1+α
	​

(
P
STR
	​

(0)
P
∗
	​

)⌉=⌈
ln(1.125)
ln(P
∗
/P
STR
	​

(0))
	​

⌉
For example, if 
𝑃
STR
(
0
)
P
STR
	​

(0) is set to one tenth of the true equilibrium price, the mechanism reaches 
𝑃
∗
P
∗
 within at most 
⌈
ln
⁡
(
10
)
/
ln
⁡
(
1.125
)
⌉
=
20
⌈ln(10)/ln(1.125)⌉=20 epochs. Starting
one hundredth below requires at most 
40
40 epochs. Both are negligible relative to the expected lifetime of the network.
We therefore set:
𝑃
STR
(
0
)
=
1
 LGO per Permanent Storage Gas
P
STR
	​

(0)=1 LGO per Permanent Storage Gas
This corresponds to a cost of 1 LGO per permanently stored byte. Genesis governance may adjust this value based on the LGO price at TGE, but the adjustment has no long-term consequence: the mechanism will converge to the true market price 
𝑃
∗
P
∗
 within 
𝑂
(
log
⁡
𝑃
∗
/
𝑃
STR
(
0
)
)
O(logP
∗
/P
STR
	​

(0)) epochs regardless.
The timeframe 
𝑠
s corresponds to one epoch. The core reason is that the primary users of the Storage market plan operational costs over days or weeks, not block-by-block. An epoch-length timeframe provides price certainty over hundreds of blocks, directly fulfilling the predictability requirement. It also ensures the EMA aggregates a meaningful volume of usage data before influencing the price, rather than reacting to per-block noise.
State Variables
The protocol must maintain the following state variables, updated at the end of each timeframe:
Symbol
	
Name
	
Description


𝑃
STR
(
𝑠
)
P
STR
	​

(s)​
	
Price Per Logos Blockchain Storage Gas
	
The price per Gas of storage for the current timeframe 
𝑠
s.


𝑇
RA
(
𝑠
)
T
RA
	​

(s)​
	
Usage EMA
	
The Exponential Moving Average of storage usage, updated with the usage from timeframe 
𝑠
s.
Price Update Algorithm
At the conclusion of each timeframe 
𝑠
s, the protocol shall execute the following algorithm to determine the price for the next timeframe, 
𝑃
STR
(
𝑠
+
1
)
P
STR
	​

(s+1). This is done as follows.
Tally Usage: Aggregate the total Logos Blockchain Storage Gas consumed during timeframe 
𝑠
s into a final value, 
𝐶
usage
(
𝑠
)
C
usage
	​

(s):
𝐶
usage
(
𝑠
)
=
∑
𝑡
∈
𝐵
𝑠
𝑆
𝑡
𝑜
𝑟
𝑎
𝑔
𝑒
𝐺
𝑎
𝑠
𝑈
𝑠
𝑒
𝑑
[
𝑡
]
C
usage
	​

(s)=
t∈B
s
	​

∑
	​

StorageGasUsed[t]
Where 
𝐵
𝑠
B
s
	​

 corresponds to one block in timeframe 
𝑠
s and 
𝑆
𝑡
𝑜
𝑟
𝑎
𝑔
𝑒
𝐺
𝑎
𝑠
𝑈
𝑠
𝑒
𝑑
[
𝑡
]
StorageGasUsed[t] corresponds to the Logos Blockchain Storage Gas used by transaction 
𝑡
t.
Update Usage EMA: Update the Exponential Moving Average of usage.
𝑇
RA
(
𝑠
)
=
𝛽
⋅
𝐶
usage
(
𝑠
)
+
(
1
−
𝛽
)
⋅
𝑇
RA
(
𝑠
−
1
)
T
RA
	​

(s)=β⋅C
usage
	​

(s)+(1−β)⋅T
RA
	​

(s−1)
Calculate Effective Target: Calculate the blended, effective target, 
𝑇
effective
(
𝑠
)
T
effective
	​

(s).
𝑇
effective
(
𝑠
)
=
𝑤
⋅
𝑇
base
+
(
1
−
𝑤
)
⋅
𝑇
RA
(
𝑠
)
T
effective
	​

(s)=w⋅T
base
	​

+(1−w)⋅T
RA
	​

(s)
Calculate Adjustment Factor: Determine the fractional deviation of usage from the target and clamp the result to the range 
[
−
𝛼
,
𝛼
]
[−α,α].
adjustment
(
𝑠
)
=
𝐶
usage
(
𝑠
)
−
𝑇
effective
(
𝑠
)
𝑇
effective
(
𝑠
)
adjustment(s)=
T
effective
	​

(s)
C
usage
	​

(s)−T
effective
	​

(s)
	​

clamped_adjustment
(
𝑠
)
=
max
⁡
{
−
𝛼
,
min
⁡
{
𝛼
,
adjustment
(
𝑠
)
}
}
clamped_adjustment(s)=max{−α,min{α,adjustment(s)}}
Update Price: Calculate the price for the next timeframe, 
𝑠
+
1
s+1​
𝑃
STR
(
𝑠
+
1
)
=
𝑃
STR
(
𝑠
)
⋅
[
1
+
clamped_adjustment
(
𝑠
)
]
P
STR
	​

(s+1)=P
STR
	​

(s)⋅[1+clamped_adjustment(s)]
Implementation
Because computation affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.
The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. To we provide here a reference implementation that uses unsigned integers to have a common reference.
First because we have 
𝑤
=
0
w=0, 
𝑇
RA
(
𝑠
)
=
𝑇
effective
(
𝑠
)
T
RA
	​

(s)=T
effective
	​

(s). Then because 
𝛽
=
0.5
β=0.5​
𝑇
R
A
(
𝑠
)
=
𝐶
u
s
a
g
e
(
𝑠
)
+
𝑇
R
A
(
𝑠
−
1
)
2
T
RA
	​

(s)=
2
C
usage
	​

(s)+T
RA
	​

(s−1)
	​

Secondly, we can rewrite 
𝑃
STR
P
STR
	​

 equation:
𝑃
STR
(
𝑠
+
1
)
	
=
𝑃
STR
(
𝑠
)
⋅
[
1
+
max
⁡
{
−
𝛼
,
min
⁡
{
𝛼
,
adjustment
(
𝑠
)
}
}
]


	
=
𝑃
STR
(
𝑠
)
⋅
max
⁡
{
1
−
𝛼
,
min
⁡
{
1
+
𝛼
,
1
+
adjustment
(
𝑠
)
}
}


	
=
𝑃
S
T
R
(
𝑠
)
⋅
max
⁡
{
7
8
,
min
⁡
{
9
8
,
 
𝐶
u
s
a
g
e
(
𝑠
)
𝑇
R
A
(
𝑠
)
}
}
P
STR
	​

(s+1)
	​

=P
STR
	​

(s)⋅[1+max{−α,min{α,adjustment(s)}}]
=P
STR
	​

(s)⋅max{1−α,min{1+α,1+adjustment(s)}}
=P
STR
	​

(s)⋅max{
8
7
	​

,min{
8
9
	​

,
T
RA
	​

(s)
C
usage
	​

(s)
	​

}}
	​

and so:
𝑃
S
T
R
(
𝑠
+
1
)
=
{
⌊
𝑃
S
T
R
(
𝑠
)
⋅
7
8
⌋
,
	
if 
8
 
𝐶
u
s
a
g
e
(
𝑠
)
≤
7
 
𝑇
R
A
(
𝑠
)
,


⌊
𝑃
S
T
R
(
𝑠
)
⋅
9
8
⌋
,
	
if 
8
 
𝐶
u
s
a
g
e
(
𝑠
)
≥
9
 
𝑇
R
A
(
𝑠
)
,


⌊
𝑃
S
T
R
(
𝑠
)
⋅
𝐶
u
s
a
g
e
(
𝑠
)
𝑇
R
A
(
𝑠
)
⌋
,
	
otherwise.
P
STR
	​

(s+1)=
⎩
⎨
⎧
	​

⌊P
STR
	​

(s)⋅
8
7
	​

⌋,
⌊P
STR
	​

(s)⋅
8
9
	​

⌋,
⌊P
STR
	​

(s)⋅
T
RA
	​

(s)
C
usage
	​

(s)
	​

⌋,
	​

if 8C
usage
	​

(s)≤7T
RA
	​

(s),
if 8C
usage
	​

(s)≥9T
RA
	​

(s),
otherwise.
	​

​
and so we can derive the following reference code:
EMA_DENOMINATOR = 2         # 1/beta
CLAMP_DENOMINATOR = 8       # denominator of 1+ alpha and 1-alpha
CLAMP_DOWN_NUMERATOR = 7    # numerator of 1-alpha
CLAMP_UP_NUMERATOR = 9      # numerator of 1+alpha

def update_usage(total_gas_consumed: int, previous_usage: int) -> int:
    return (total_gas_consumed + previous_usage) // EMA_DENOMINATOR

def update_storage_price(prev_price: int, total_gas_consumed: int, usage: int) -> int:
    if CLAMP_DENOMINATOR * total_gas_consumed <= CLAMP_DOWN_NUMERATOR * usage:
        return prev_price * CLAMP_DOWN_NUMERATOR // CLAMP_DENOMINATOR
    elif CLAMP_DENOMINATOR * total_gas_consumed >= CLAMP_UP_NUMERATOR * usage:
        return prev_price * CLAMP_UP_NUMERATOR // CLAMP_DENOMINATOR
    else:
        return prev_price * total_gas_consumed // usage

def update_storage_fee(total_gas_consumed: int, prev_price: int, prev_usage: int) -> tuple[int, int]:
    usage = update_usage(total_gas_consumed, prev_usage)
    price = update_storage_price(prev_price, total_gas_consumed, usage)
    return price, usage

​
Genesis State
The initial state of the TFM at network launch shall be configured as follows:
Initial Price P_STR(0): Set to a pre-determined value established by genesis governance.
Initial Usage EMA T_RA(-1): Set to the value of the baseline target, 
𝑇
base
T
base
	​

. This anchors the mechanism to its long-term policy goal from the outset.
