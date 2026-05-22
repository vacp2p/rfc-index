# OVERVIEWCRYPTOECONOMICS

| Field | Value |
| --- | --- |
| Name | [Overview] Cryptoeconomics |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | Thomas Lavaur <thomaslavaur@logos.co> |
| Contributors | Marcin Pawlowski <marcin@logos.co>, Filip Dimitrijevic <filip@logos.co> |

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
| 1.0.0 | Initial revision. | 2026-04-24 |

❗

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

## Introduction

This document provides the formal specification for the fee collection mechanism of the Permanent Storage market. The primary objective is to define a system that is robust, predictable, and economically sustainable. This mechanism is a critical component of the overall Permanent Storage Market Transaction Fee Mechanism (TFM), which is designed as a self-contained, usage-driven market, economically decoupled from the protocol's core consensus and privacy services.

In what follows, Logos Blockchain Storage refers to the Permanent Storage markets and Logos Blockchain Storage Gas refers to the Permanent Storage Gas respectively.

### Requirements and Rationale

The mechanism is designed with the following core requirements, derived from the project's goals:

Predictability: Consumers of the Logos Blockchain Storage require a high degree of cost predictability for their own operational planning.

Robustness: The mechanism must be able to adapt to significant, medium-term shifts in demand without requiring constant, emergency governance intervention.

Fairness: The fee paid by a user must be directly and transparently proportional to the resources they consume.

Simplicity: The on-chain implementation should be as simple as possible to minimize attack surface and ensure auditability.

Justification. As will be discussed later, the tradeoff between adaptability and predictability of the mechanism is determined by its parameters. In scenarios of high volatility, its core design principle is to act as a shock absorber, deliberately filtering out high-frequency, transient volatility by operating over longer timeframes and using a smoothed moving average (EMA). For the primary consumer, reacting to every momentary spike in demand would create untenable price chaos. This model, therefore, intentionally forgoes instantaneous adaptation in favor of providing crucial timeframe-level price certainty, ensuring that fees reflect meaningful, medium-term trends rather than reacting to volatile, short-term market noise.

## Overview

The proposed fee mechanism operates on a simple but powerful principle: the price for Logos Blockchain Storage is fixed and predictable within a given timeframe (epoch for Permanent Storage), but it adjusts smoothly between timeframes based on observed network usage.

When a user submits data, a fee is calculated based on the Logos Blockchain Storage Gas consumption. This fee is determined by a price per Gas, $P\_{STR}$ , which is known in advance for the entire timeframe.

At the end of each timeframe, the protocol tallies the total amount of Logos Blockchain Storage Gas that was stored. It compares this actual usage to an adaptive target—a "healthy" usage level that is itself a dynamic blend of a long-term policy goal and recent historical usage. Based on whether the actual usage was above or below this target, the price $P\_{STR}$ for the next timeframe is adjusted slightly up or down.

This flow can be visualized as follows:

timeframes 's' Begins  
Price P\_STR(s) is Fixed & Known

Data Submission  
- Logos Blockchain Storage Gas: S\_gas  
- Fee = S\_gas \* P\_STR(s) + ...

Protocol State:  
- C\_Usage(s) += S\_gas  
- Fee → Storage Reward Bucket

timeframes 's' Ends  
- Total Usage C\_Usage(s) is Final

Price Update Rule Executed:  
- Calculate Effective Target T\_Effective(s)  
- Compare C\_Usage(s) to T\_Effective(s)  
- Calculate and set new price P\_STR(s+1) for next timeframes

Loop for all blocks in timeframes

​

This model provides the best of both worlds: users have perfect price clarity for the duration of a timeframe, while the system as a whole can gracefully adapt to evolving market conditions over time.

## Construction

This section defines the precise algorithm, constants, and state variables for the Logos Blockchain Storage TFM.

#### Core Fee Equation

The fee for a Logos Blockchain Storage transaction, $F\_{\text{STR}}$ , is a linear function of Logos Blockchain Storage Gas' size, $S\_{\text{gas}}$ , and the price-per-gas for the current timeframe, $P\_{\text{STR}}(s)$ .

$$
F\_{\text{STR}} = S\_{\text{gas}} \cdot P\_{\text{STR}}(s)
$$
FSTR​=Sgas​⋅PSTR​(s)

As a remark, the equation above assumes a linear increase of $F\_\text{STR}$ with respect to $S\_\text{gas}$ . For completeness, a more general version can be

$$
\begin{align\*}
F\_\text{STR}=f(S\_\text{gas})\cdot P\_\text{STR}
\end{align\*}
$$
FSTR​=f(Sgas​)⋅PSTR​​

with $f:\mathbb{N}\to\mathbb{R}\_+$ a monotonically increasing function. Making f sublinear can be understood as accounting for economies of scale, while making $f$ superlinear can be understood as a penalization for using larger data sizes. We decided to go with the linear form of $f$ as it was the least opinionated. Examples of this could be

$$
\begin{align\*}
F\_\text{STR}^\text{exp}&=\exp(\alpha S\_\text{gas})\cdot P\_\text{STR}\quad \alpha >0\\
F\_\text{poly}^\text{exp}&=S^\beta\_\text{gas}\cdot P\_\text{STR},\quad \beta>1\\
\end{align\*}
$$
FSTRexp​Fpolyexp​​=exp(αSgas​)⋅PSTR​α>0=Sgasβ​⋅PSTR​,β>1​

#### Protocol Constants

To ensure on-chain efficiency, the protocol shall use an Exponential Moving Average (EMA) for its adaptive target calculation. The behavior of the TFM is governed by the following on-chain constants, which are set at genesis.

| Symbol | Name | Description | Initial Value | Justification |
| --- | --- | --- | --- | --- |
| $T\_{\text{base}}$ ​ | Baseline Target | A static, policy-driven usage target in Logos Blockchain Storage Gas per timeframe. Acts as a long-term gravitational anchor for the dynamic target. | 0 Permanent Storage Gas per block. | It should represent a conservative initial timeframe capacity. providing a healthy buffer and a clear policy goal. |
| $w$ ​ | Anchor Weight | A coefficient in $[0, 1]$ determining the influence of $T\_{\text{base}}$ . It's the "gravity knob" for the system. | for Permanent Storage: 0 | Allows the target to be primarily driven by recent demand, ensuring adaptability, while the $w$ % pull from $T\_{\text{base}}$ prevents long-term drift. |
| $\alpha$ ​ | Max Adjustment Factor | The maximum fractional amount the price can change per timeframe. Acts as "safety brakes" to bound price volatility. | 0.125 for Permanent Storage | A $100\alpha$ % cap provides strong predictability for users planning across timeframes while allowing the price to respond effectively to sustained demand changes. |
| $\beta$ ​ | EMA Smoothing Factor | A coefficient in $[0, 1]$ controlling the responsiveness of the usage EMA. It governs the speed of adaptation. | 0.5 for Permanent Storage | A value of $\beta$ gives significant weight to the most recent timeframe's usage while incorporating the "memory" of the system with a half-life of 1 timeframe, balancing responsiveness and stability. |
| $T\_{\text{RA}}(-1)$ ​ | Initial Usage EMA | First value for EMA | 0 (= $T\_{\text{base}}$ ) | Given $T\_{\text{base}} = 0$ , this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset. |
| $P\_{\text{STR}}(0)$ ​ | Initial Price | The price on the first epoch | 1 LGO/gas | The initial price is set conservatively low at the beginning and let to discover the true market price |
| $s$ ​ | timeframe | How often things adjust | 1 epoch | Primary users of the Storage market plan operational costs over days or weeks, not block-by-block. |

#### Parameter Justification

For simplicity, we set $T\_\text{base}=0$ as an anchor and $w=0$ as blocks are already constrained by execution. This is to avoid imposing an opinionated choice of parameters, specially at the beginning of the protocol.

The EMA factor ( $\beta=0.5$ ) makes the adaptive target highly sensitive to recent network activity by giving 50% weight to the latest session's usage, creating an effective "memory" of approximately 3 epochs.

The maximum adjustment factor ( $\alpha=0.125$ ) provides a crucial layer of predictability, guaranteeing users that the price cannot change by more than 12.5% between any two epochs, thus fulfilling a core design requirement for stable operational planning.

The seed value for the EMA is set to $T\_{\text{RA}}(-1) = T\_{\text{base}} = 0$ . Given $T\_{\text{base}} = 0$ , this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset.

💡

Why is the index  $-1$ , not  $0$ ? The price update algorithm runs at the end of timeframe $s$ and requires $T\_{\text{RA}}(s-1)$ as its prior EMA value. When $s = 0$ , the algorithm therefore requires $T\_{\text{RA}}(-1)$ as its seed. The value $T\_{\text{RA}}(0)$ is already a
well-defined computed quantity — the EMA produced after the first epoch's observed usage: $T\_{\text{RA}}(0) = \beta \cdot C\_{\text{usage}}(0) + (1-\beta) \cdot T\_{\text{RA}}(-1)$ . Using index $-1$ for the seed avoids a naming collision with this computed value.

> Implementation note. With $w = 0$ and $T\_{\text{RA}}(-1) = 0$ , the effective target
> $T\_{\text{effective}}$ will be zero during the first epoch unless $C\_{\text{usage}}(0) > 0$ .
> The reference implementation handles this correctly via the
>
> if effective\_target == 0: return self.price
>
> guard, which holds the price at $P\_{\text{STR}}(0)$ until the first non-zero usage
> epoch provides a meaningful signal. This is the intended behavior at genesis.

The precise value of $P\_{\text{STR}}(0)$ is not critical to the long-term behavior of the mechanism. As established in the equilibrium analysis, the price update rule converges autonomously to the market-clearing price $P^\*$  regardless of the starting point, provided the stability condition  $(\*)$ holds (see [🔀[1.0.0][Analysis] Storage Market - Price Stability Analysis](https://nomos-tech.notion.site/Price-Stability-Analysis-a03261aa09df83f6bcd6815ba73b72e1?pvs=24#fed261aa09df8241b79c01ca67ef6026)). The only hard requirement is for $P\_{\text{STR}}(0)$ to be sufficiently low so as not to suppress early adoption before the mechanism has observed enough demand to self-correct.

More precisely, since the price can increase by at most $\alpha = 12.5\%$ per epoch, the number
of epochs required to reach a target price $P^\*$  from an initial price  $P\_{\text{STR}}(0) < P^\*$  is bounded above by:

$$
N \leq \left\lceil \log\_{1+\alpha}\!\left(\frac{P^\*}{P\_{\text{STR}}(0)}\right) \right\rceil
= \left\lceil \frac{\ln(P^\*/P\_{\text{STR}}(0))}{\ln(1.125)} \right\rceil
$$
N≤⌈log1+α​(PSTR​(0)P∗​)⌉=⌈ln(1.125)ln(P∗/PSTR​(0))​⌉

For example, if $P\_{\text{STR}}(0)$ is set to one tenth of the true equilibrium price, the mechanism reaches $P^\*$ within at most $\lceil \ln(10)/\ln(1.125) \rceil = 20$ epochs. Starting
one hundredth below requires at most $40$ epochs. Both are negligible relative to the expected lifetime of the network.

We therefore set:

$$
P\_{\text{STR}}(0) = 1\ \text{LGO per Permanent Storage Gas}
$$
PSTR​(0)=1 LGO per Permanent Storage Gas

This corresponds to a cost of 1 LGO per permanently stored byte. Genesis governance may adjust this value based on the LGO price at TGE, but the adjustment has no long-term consequence: the mechanism will converge to the true market price $P^\*$  within  $O(\log P^\*/P\_{\text{STR}}(0))$ epochs regardless.

The timeframe $s$ corresponds to one epoch. The core reason is that the primary users of the Storage market plan operational costs over days or weeks, not block-by-block. An epoch-length timeframe provides price certainty over hundreds of blocks, directly fulfilling the predictability requirement. It also ensures the EMA aggregates a meaningful volume of usage data before influencing the price, rather than reacting to per-block noise.

#### State Variables

The protocol must maintain the following state variables, updated at the end of each timeframe:

| Symbol | Name | Description |
| --- | --- | --- |
| $P\_{\text{STR}}(s)$ ​ | Price Per Logos Blockchain Storage Gas | The price per Gas of storage for the current timeframe $s$ . |
| $T\_{\text{RA}}(s)$ ​ | Usage EMA | The Exponential Moving Average of storage usage, updated with the usage from timeframe $s$ . |

#### Price Update Algorithm

At the conclusion of each timeframe $s$ , the protocol shall execute the following algorithm to determine the price for the next timeframe, $P\_{\text{STR}}(s+1)$ . This is done as follows.

Tally Usage: Aggregate the total Logos Blockchain Storage Gas consumed during timeframe $s$ into a final value, $C\_\text{usage}(s)$ :

$$
C\_{\text{usage}}(s)=\sum\_{t\in\mathcal{B}\_s}\mathsf{StorageGasUsed}[t]
$$
Cusage​(s)=t∈Bs​∑​StorageGasUsed[t]

Where $\mathcal{B}\_s$ corresponds to one block in timeframe $s$ and $\mathsf{StorageGasUsed}[t]$ corresponds to the Logos Blockchain Storage Gas used by transaction $t$ .

Update Usage EMA: Update the Exponential Moving Average of usage.

$$
T\_{\text{RA}}(s) = \beta \cdot C\_{\text{usage}}(s) + (1-\beta) \cdot T\_{\text{RA}}(s-1)
$$
TRA​(s)=β⋅Cusage​(s)+(1−β)⋅TRA​(s−1)

Calculate Effective Target: Calculate the blended, effective target, $T\_{\text{effective}}(s)$ .

$$
T\_{\text{effective}}(s) = w \cdot T\_{\text{base}} + (1-w) \cdot T\_{\text{RA}}(s)
$$
Teffective​(s)=w⋅Tbase​+(1−w)⋅TRA​(s)

Calculate Adjustment Factor: Determine the fractional deviation of usage from the target and clamp the result to the range $[-\alpha, \alpha]$ .

$$
\text{adjustment}(s) = \frac{C\_{\text{usage}}(s) - T\_{\text{effective}}(s)}{T\_{\text{effective}}(s)}
$$
adjustment(s)=Teffective​(s)Cusage​(s)−Teffective​(s)​

$$
\text{clamped\\_adjustment}(s) = \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}
$$
clamped\_adjustment(s)=max{−α,min{α,adjustment(s)}}

Update Price: Calculate the price for the next timeframe, $s+1$ ​

$$
P\_{\text{STR}}(s+1) = P\_{\text{STR}}(s) \cdot [1 + \text{clamped\\_adjustment}(s)]
$$
PSTR​(s+1)=PSTR​(s)⋅[1+clamped\_adjustment(s)]

#### Implementation

Because computation affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.

The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. To we provide here a reference implementation that uses unsigned integers to have a common reference.

First because we have $w = 0$ , $T\_\text{RA}(s) = T\_\text{effective}(s)$ . Then because $\beta=0.5$ ​

$$
T\_{\mathrm{RA}}(s)=\frac{C\_{\mathrm{usage}}(s)+T\_{\mathrm{RA}}(s-1)}{2}
$$
TRA​(s)=2Cusage​(s)+TRA​(s−1)​

Secondly, we can rewrite $P\_\text{STR}$ equation:

$$
\begin{align\*}
P\_{\text{STR}}(s+1) &= P\_{\text{STR}}(s) \cdot [1 + \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}]\\
&= P\_{\text{STR}}(s) \cdot \max \{ 1-\alpha, \min \{ 1+ \alpha, 1+\text{adjustment}(s) \} \}\\
&= P\_{\mathrm{STR}}(s)\cdot
\max\left\{\frac78,\min\left\{\frac98,\,
\frac{C\_{\mathrm{usage}}(s)}{T\_{\mathrm{RA}}(s)}
\right\}\right\}
\end{align\*}
$$
PSTR​(s+1)​=PSTR​(s)⋅[1+max{−α,min{α,adjustment(s)}}]=PSTR​(s)⋅max{1−α,min{1+α,1+adjustment(s)}}=PSTR​(s)⋅max{87​,min{89​,TRA​(s)Cusage​(s)​}}​

and so:

$P\_{\mathrm{STR}}(s+1)=\begin{cases}\left\lfloor P\_{\mathrm{STR}}(s)\cdot \frac78 \right\rfloor,& \text{if } 8\,C\_{\mathrm{usage}}(s)\le 7\,T\_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P\_{\mathrm{STR}}(s)\cdot \frac98 \right\rfloor,& \text{if } 8\,C\_{\mathrm{usage}}(s)\ge 9\,T\_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P\_{\mathrm{STR}}(s)\cdot\frac{C\_{\mathrm{usage}}(s)}{T\_{\mathrm{RA}}(s)} \right\rfloor,& \text{otherwise.}\end{cases}$ ​

and so we can derive the following reference code:

EMA\_DENOMINATOR = 2 # 1/beta
CLAMP\_DENOMINATOR = 8 # denominator of 1+ alpha and 1-alpha
CLAMP\_DOWN\_NUMERATOR = 7 # numerator of 1-alpha
CLAMP\_UP\_NUMERATOR = 9 # numerator of 1+alpha
def update\_usage(total\_gas\_consumed: int, previous\_usage: int) -> int:
return (total\_gas\_consumed + previous\_usage) // EMA\_DENOMINATOR
def update\_storage\_price(prev\_price: int, total\_gas\_consumed: int, usage: int) -> int:
if CLAMP\_DENOMINATOR \* total\_gas\_consumed <= CLAMP\_DOWN\_NUMERATOR \* usage:
return prev\_price \* CLAMP\_DOWN\_NUMERATOR // CLAMP\_DENOMINATOR
elif CLAMP\_DENOMINATOR \* total\_gas\_consumed >= CLAMP\_UP\_NUMERATOR \* usage:
return prev\_price \* CLAMP\_UP\_NUMERATOR // CLAMP\_DENOMINATOR
else:
return prev\_price \* total\_gas\_consumed // usage
def update\_storage\_fee(total\_gas\_consumed: int, prev\_price: int, prev\_usage: int) -> tuple[int, int]:
usage = update\_usage(total\_gas\_consumed, prev\_usage)
price = update\_storage\_price(prev\_price, total\_gas\_consumed, usage)
return price, usage

​

#### Genesis State

The initial state of the TFM at network launch shall be configured as follows:

Initial Price

P\_STR(0)

: Set to a pre-determined value established by genesis governance.

Initial Usage EMA 

T\_RA(-1)

: Set to the value of the baseline target, $T\_{\text{base}}$ . This anchors the mechanism to its long-term policy goal from the outset.
