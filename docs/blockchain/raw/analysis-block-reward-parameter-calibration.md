# ANALYSISBLOCK-REWARD-PARAMETER-CALIBRATION

| Field | Value |
| --- | --- |
| Name | [Analysis] Block Reward Parameter Calibration |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | Frederico Teixeira <frederico@logos.co> |
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
| 1.0.0 | Initial revision. | 2026-04-24 |

❗

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

## Introduction

This document outlines the specifications for Logos Blockchain's block rewards mechanism, a critical component of the network's economic model. The mechanism is designed to create a sustainable economic framework that incentivizes network participation while maintaining long-term stability.

The objective is to develop a block rewards system that addresses key challenges specific to Logos Blockchain's architecture, including the unlinkability between block proposal and reward collection, and the inability to directly allocate transaction fees to specific block proposers. These constraints necessitate a carefully designed economic incentive structure.

Building on previous work in blockchain economics, this specification proposes a dynamic token emission system that calibrates LGO issuance according to network Key Performance Indicators (KPIs). The system uses two primary metrics: inferred total stake (as a security indicator) and average burning rate (to maintain supply equilibrium).

The document references internal mathematical models and simulations that demonstrate how the proposed mechanism would behave under various conditions. Key parameters include maximum annual emission rate ( $1\%$ ), control responsiveness factors, and target metrics for network security.

The conclusion of our analysis indicates that this KPI-based emission model should achieve several important outcomes:

Initially higher emission rates (capped at $1\%$ annually) to bootstrap network participation.

Gradual stabilization of token supply as the system matures, with our baseline simulation showing just  $1.33\%$  total inflation after  $10$  years.

Self-regulating mechanism where token issuance naturally adjusts to compensate for burned transaction fees.

Built-in safeguards against manipulation through moving averages and bounded functions.

This specification represents a comprehensive approach to creating a robust economic foundation for the Logos Blockchain network that balances security requirements with long-term economic sustainability.

## Overview

The Logos Blockchain block rewards mechanism is a KPI-based dynamic token emission system designed to create a sustainable economic framework that incentivizes network participation while maintaining long-term stability. This section provides a high-level understanding of how the system works and its key components.

### Key Principles

The design of the rewards system reflects three architectural constraints unique to Logos Blockchain:

Unlinkability: Block proposal and reward collection are intentionally decoupled for privacy, meaning rewards cannot be assigned to a single proposer.

Fee burning: All transaction fees (execution base fees and permanent storage fees) are burned, rather than directly given to block proposers.

Global metrics over local signals: Rewards are computed from network-wide KPIs at block production time, rather than from easily manipulated per-block data.

These principles ensure that the system is censorship-resistant, manipulation-resistant, and aligned with long-term network incentives.

### Requirements

Building upon the requirements for Logos Blockchain's block rewards system, the implementation will establish that all transaction fees are burned while block rewards are tied to measurable global metrics that reflect network health and security. This mechanism ensures that if network activity surges substantially, the accelerated burning of tokens will be balanced by compensatory emissions over time.

For optimal functionality, block rewards should be anchored to specific observable metrics rather than arbitrary values. Block numbers simply track time passage without indicating chain state. Transaction counts per block are vulnerable to manipulation. On the other hand, tracking the number of Blend nodes or inferring total stake provide more robust information about the chain state, specially when they can be compared with targets that are considered “healthy”.

Crucially, any metric-pegged reward system should aim toward a target value or equilibrium point, creating predictability and stability in the token economics.

### High-level System Design

The system dynamically adjusts token emission based on two primary KPIs:

Inferred Total Stake: Measures network security by tracking the total amount staked against a target threshold (e.g., $30\%$ of TGE supply).

Average Burning Rate: Tracks transaction fees (both Execution base fees and Permanent Storage) burned to maintain supply equilibrium.

A control function combines these KPIs to determine the emission rate factor, bounded between a minimum and maximum annual issuance. This ensures that:

When security participation is below target, higher issuance attracts more validators.

As usage increases and fees are burned, emissions adjust downward to stabilize supply.

​

The equation that defines the amount of block rewards is given by:

$$
A\_t \cdot \dfrac{I\_{max} \cdot S\_{tge} \cdot \Delta\_t}{f} + (1-A\_t) \cdot R\_\text{block}
$$
At​⋅fImax​⋅Stge​⋅Δt​​+(1−At​)⋅Rblock​

where:

$A\_t$ is the emission rate factor on a per year basis.

$I\_{max}$ is the maximum emission rate per year.

$S\_{tge}$ denotes the token supply at Token Generation Event (TGE).

$\Delta\_t$ denotes the fraction of year in one time step per e.g., epoch, block, or day.

$f$ be the average number of block proposal within $\Delta\_{t}$ units.

$R\_\text{block}$ denotes the total amount of Execution base fees and Permanent Storage fees that are burned when the block is proposed.

### Lifecycle Phases

The system is designed to evolve through different phases:

Bootstrap Phase: Initially higher emission rates (up to $1\%$ annually) to incentivize network participation when stake is below target. As it is explained below, this is viable even when Logos Blockchain experiences low activity because the level of activity only plays a role when the network participation gets close to the predefined target.

Stabilization Phase: As Proof-of-Stake (PoS) participation approaches target levels, emission becomes primarily driven by burning rate.

Equilibrium Phase: Supply stabilizes with issuance matching burned fees.

High-Adoption Phase: If burning exceeds maximum emission, supply becomes deflationary.

### Benefits

This KPI-based approach delivers several advantages:

Self-regulating mechanism that automatically adjusts to network conditions.

Long-term sustainability with projected total inflation of just  $1.33\%$  after  $10$  years (assuming constant burning rate of  $0.5\%$  per year).

Built-in safeguards against manipulation through moving averages and bounded functions.

Predictable economic model that balances security incentives with controlled supply.

The overall design creates a robust economic foundation for the Logos Blockchain blockchain that effectively balances the need for strong security incentives with long-term token supply stability.

## Construction

The proposed mechanism implements a dynamic token emission system that precisely calibrates LGO issuance according to network performance metrics (KPIs). This adaptive model adjusts emission rates based on how KPIs perform relative to their predetermined targets, while maintaining strict adherence to supply parameters and economic boundaries.

### Core Variables

The following variables are input to the model:

$S\_{tge}$ denotes the token supply at Token Generation Event (TGE).

$S\_{cap}$ denotes the maximum allowable token supply (hard cap), if any.

$\Delta\_t$ denotes the fraction of year in one time step per e.g., epoch, block, or day:

if the time step is 1 day, then $\Delta\_t = 1/365$ .

if the time step is 1 block every $30$ seconds, then $\Delta\_t = 1/(365 \times 2880)$ .

if the time step is 1 epoch, which lasts 7.5 days, then $\Delta\_t = 1/(365/7.5) = 1/48.667$ .

$f$ be the average number of block proposal within $\Delta\_{t}$ units:

if the time step is 1 day and blocks are proposed every 30 seconds, then $f=2880$ (the number of 30 seconds intervals in 1 day).

if the time step is 1 epoch, which lasts 7.5 days, and blocks are processed every 30 seconds, then $f = 7.5 \times 2880 = 21600$ (the number of 30 seconds intervals in 7.5 day).

$I\_{min}$ is the minimum emission rate per year (default: $0\%$ ).

$I\_{max}$ is the maximum emission rate per year (default: $1\%$ ).

$D\_{i,target}$ denotes the target value for the $i$ -th KPI.

$w\_i$ denotes the weight of the $i$ -th KPI in the normalized deviation from target or in the normalized average; it satisfies $\sum\_i w\_i = 1$ .

$\alpha\_d > 0$ denotes the control responsiveness to KPI deviation metrics.

$\alpha\_a > 0$ denotes the control responsiveness to KPI average metrics.

$T$ be the number of periods in the look-back window for the moving average.

Let us define the following variables:

$S\_t$ denotes the token circulating supply at time $t$ .

$A\_t \in [0,1]$ denotes the emission rate factor on a per year basis.

This implies that $A\_t \cdot I\_{max} \cdot \Delta\_t$ denotes the emission within the time-step.

$D\_{i,t}$ denotes the $i$ -th key performance indicator at time $t$ (e.g., TVL, staked amount, active users).

$R\_\text{block}$ denotes the total amount of Execution Gas and Permanent Storage fees burnt in a block. Refer to [🔀[1.0.0] Execution Market](https://nomos-tech.notion.site/1-0-0-Execution-Market-d19261aa09df83998ba601723bc29d11?pvs=24) and [🔀[1.0.0] Storage Markets](https://nomos-tech.notion.site/1-0-0-Storage-Markets-0fb261aa09df8366916a81cd45d78def?pvs=24) for how to compute $R\_{block}$ .

### Parametrization

| Symbol | Definition | Default Value | Explanation |
| --- | --- | --- | --- |
| $S\_{tge}$ ​ | Token supply at TGE | 10 billion LGO | N.A. |
| $T$ ​ | The number of periods in the look-back window for the moving average. | $120$ ​ | As the system is expected to mint 1 block every 30 seconds, this look-back window defines that the minting averages the fees burned in the last hour. |
| $\alpha\_a$ ​ | Denotes the control responsiveness to KPI average metrics. | $1$ ​ | This parameter drives the token emission from the burn rate. It must be one-to-one. |
| $\alpha\_d$ ​ | Denotes the control responsiveness to KPI deviation metrics. | $1/4$ ​ | See [No access](/326261aa09df80f79169dff0eb884f78?pvs=24#326261aa09df80f79169dff0eb884f78), for details. |
| $w\_i$ ​ | Denotes the weight of the $i$ -th KPI in the normalized deviation from target | $1$ ​ | There's only one KPI of this type in our system. |
| $D\_{0,target}$ ​ | Denotes the target value for the first KPI based on stake. | 3 billion LOGOS | $30\%$ of the token supply. |
| $D\_{1,target}$ ​ | Denotes the target value for the second KPI based on fees. | $10$ billon LOGOS | In the context of this KPI, this value behaves as a normalizer |
| $I\_{max}$ ​ | The maximum emission rate per year | $1\%$ ​ | This value guarantees that, when the total inferred stake reaches $D\_{0,target}$ , then the APY for validation is ~3.33%. |
| $I\_{min}$ ​ | The minimum emission rate per year | $0\%$ ​ | This avoids inflationary token emissions. |
| $f$ ​ | The average number of block proposal within $\Delta\_{t}$ units | $1$ ​ | The time step $\Delta\_t$ was chosen so that $f$ equals to $1$ . |
| $\Delta\_t$ ​ | Time step, the fraction of year in one time step (per e.g., epoch, block, or day) | $1/(365 \times 2880)$ ​ | The time step is 1 block every $30$ seconds; there are 2880 blocks of 30 seconds in a day. |

The calibration of these parameters can be found in [🔀[1.0.0][Analysis] Block Reward Parameter Calibration](https://nomos-tech.notion.site/1-0-0-Analysis-Block-Reward-Parameter-Calibration-ff0261aa09df83b1b7cf8199e4707ae7?pvs=24).

### Block Rewards

The amount of tokens to be rewarded in a block depends on the emission rate factor $A\_t$ . This controls how much is minted from inflation and how much is diverted from transaction fees. The following behavior is expected:

When the aggregate KPI is far from the target, $A\_t \rightarrow 1$ , then the emission of new tokens (inflation) is maximized, and most of the transaction fees aren't minted back. The amount of tokens burned does not impact the block rewards in this situation. This means that the system can burn more tokens than it mints.

When the aggregate KPI is close to the target, $A\_t \rightarrow 0$ , then the emission from inflation is minimized, and most of $R\_{block}$ is minted back for leaders and Blend nodes.

That is, what drives the source of minting is the KPI: if far from the target, the system mints new tokens; if close to the target, the system mints exactly what was burned (up to $I\_{max}$ of TGE).

The emission from inflation within the time step $\Delta\_t$ is given by

$$
A\_t \cdot I\_{max} \cdot S\_{tge} \cdot \Delta\_t.
$$
At​⋅Imax​⋅Stge​⋅Δt​.

The actual amount of tokens minted per block (because of inflation) also depends on how many blocks are expected to be proposed between $\Delta\_{t-1}$ and $\Delta\_{t}$ . This is expressed by the factor $f$ , as defined [above](/d96261aa09df838ca36601b4b27b49b4?pvs=25#52d261aa09df828e9ced81f25b064b9c).

The equation that implements the behavior above in terms of $A\_t$ is given by:

$$
\begin{equation}
A\_t \cdot \dfrac{I\_{max} \cdot S\_{tge} \cdot \Delta\_t}{f} + (1-A\_t) \cdot R\_\text{block}
\end{equation}
$$
At​⋅fImax​⋅Stge​⋅Δt​​+(1−At​)⋅Rblock​​​

where:

$A\_t$ is the emission rate factor on a per year basis.

$I\_{max}$ is the maximum emission rate per year.

$S\_{tge}$ denotes the token supply at Token Generation Event (TGE).

$\Delta\_t$ denotes the fraction of year in one time step per e.g., epoch, block, or day.

$f$ be the average number of block proposal within $\Delta\_{t}$ units.

$R\_\text{block} = D\_{1,t}$ denotes the total amount of Execution base fees and Storage fees that are burned when the block is proposed.

def block\_rewards(
S\_tge:float,
emission\_rate\_factor:float,
I\_max:float,
Delta\_t:float,
f:float,
D\_1\_t: float
) -> float:
"""
Calculate the rewards per block.
It implements equation (1).
"""
emission\_from\_inflation = emission\_rate\_factor \* I\_max \* S\_tge \* Delta\_t / f
emission\_from\_rewards = (1. - emission\_rate\_fator) \* R\_block\_cur
return emission\_from\_inflation + emission\_from\_rewards

​

### Emission Rate Factor Function

The emission rate factor $A\_t \in [0,1]$ determines the portion of $I\_{max}$ that should be emitted based on current values of $\delta\_t$ and $\gamma\_t$ :

$$
A\_t = \min \Bigl\{ 1, \max \Bigl\{ 0, \dfrac{ \alpha\_d \cdot \delta\_t + \alpha\_a \cdot \gamma\_t + I\_{min}}{I\_{max}} \Bigr\} \Bigr\}.
$$
At​=min{1,max{0,Imax​αd​⋅δt​+αa​⋅γt​+Imin​​}}.

where

$\alpha\_d$ controls the responsiveness to KPI deviation metrics.

$\delta\_t$ is measuring the KPI deviation from targets.

$\alpha\_a$ controls the responsiveness to KPI average metrics.

$\gamma\_t$ is measuring the KPI average values of over the last $T$ steps.

$I\_{min}$ is the minimum emission rate per year.

$I\_{max}$ is the maximum emission rate per year.

All terms are displayed in annualized form to ease comparison.

def calculate\_emission\_rate\_factor(
alpha\_dev:float,
weighted\_target\_deviation: float,
alpha\_avg:float
weighted\_avg: float,
i\_min: float = 0.0,
i\_max: float = 0.01
) -> float:
"""It calculates the current emission rate factor"""
emission\_rate:float = alpha\_dev \* weighted\_target\_deviation + alpha\_avg \* weighted\_avg + i\_min
emission\_rate\_factor:float = emission\_rate / i\_max
emission\_rate\_factor = min(1.0, max(emission\_rate\_factor, 0.0))
return emission\_rate\_factor

​

#### KPI Deviation from Target

The weighted deviation from target

$$
\delta\_t = \sum\_i w\_i \times
\dfrac{D\_{i,target} - D\_{i,t}}{D\_{i,target}}.
$$
δt​=i∑​wi​×Di,target​Di,target​−Di,t​​.

def weighted\_deviation\_from\_target(
kpi\_weights: List[float],
kpi\_deviations: List[float]
) -> float:
"""
Calculate the normalized deviation (delta\_t).
Inputs:
\* kpi\_weights: constant list of floats
\* kpi\_deviations: for each KPI, it contains the results of "deviation\_from\_target"
Returns:
\* a normalized annualized KPI in units of %.
"""
assert len(kpi\_weights) == len(kpi\_deviations)
weighted\_target\_deviation:float = 0.0
for deviation, weight in zip(kpi\_deviations, kpi\_weights):
weighted\_target\_deviation += weight \* deviation value
return weighted\_target\_deviation

​

It implies that:

$\delta\_t > 0$ → KPI below target → should increase the token emission by a factor of $\alpha\_d \cdot \delta\_t$ .

$\delta\_t = 0$ → KPI at target → should not change the token emission.

$\delta\_t < 0$ → KPI above target → should reduce the token emission by a factor of $\alpha\_d \cdot \delta\_t$ .

💡

To measure the deviation, only the total estimated stake KPI is used in this part of the computation

#### KPI Average

The weighted average metric is defined as

$$
\gamma\_t = \dfrac{1}{\Delta\_t} \sum\_i w\_i \cdot \Bigl(\dfrac{1}{T} \sum\_{\tau=t-T+1}^t \dfrac{ D\_{i,\tau}}{D\_{i,target}} \Bigr).
$$
γt​=Δt​1​i∑​wi​⋅(T1​τ=t−T+1∑t​Di,target​Di,τ​​).

where:

The value $D\_{j,target}$ can be any number with the same units of $D\_{j,i}$ .

The factor $\dfrac{1}{\Delta\_t}$ turns $\gamma\_t$ into an annualized quantity. This depends on the specific KPI.

def weighted\_average(
kpi\_weights: List[float],
kpi\_average: List[float]
) -> float:
"""
Calculate the weighted average metric (gamma\_t)
\* kpi\_weights: constant list of floats
\* kpi\_average: for each KPI, it contains the results of "average\_kpi"
"""
assert len(kpi\_weights) == len(kpi\_deviations)
weighted\_avg:float = 0.0
for avg, weight in zip(kpi\_average, kpi\_weights):
weighted\_avg += weight \* avg
return weighted\_avg

​

The weighted average metric features:

$\gamma\_t > 0$ → should increase the token emission by a factor of $\alpha\_a \gamma\_t$ .

$\gamma\_t = 0$ → should not change the token emission.

$\gamma\_t < 0$ → should reduce the token emission by a factor of $\alpha\_a \gamma\_t$ .

💡

To measure the average, only the average burning rate KPI is used in this part of the computation

### Key Performance Indicator(s)

#### KPI 1 - The Inferred Total Stake

Given the privacy features of Logos Blockchain and the fact that the token TGE supply is known, the inferred total stake is the most appropriate indicator of the system's security.

Let:

$D\_{0,t}$ denotes the evolution of the inferred total stake.

$D\_{0,target}$ denotes the total stake that is considered secure. For the blockchain to be secure, we aim for $30\%$ of the TGE supply.

The inferred total stake affects the emission rate through the "normalized deviation from target." The deviation implied by this KPI is characterized by the plot below.

![](/image/attachment%3Abb31da74-9e18-4881-ab10-b249daceaf03%3AScreenshot_2025-06-15_at_19.44.01.png?table=block&id=cc1261aa-09df-82f0-ace9-81b7dd81a13a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 1

ALT

This happens because, when the blockchain starts, $D\_{0,t} \vert\_{t=0}$ is very likely a small number compared to the target. Therefore, the equation [above](/d96261aa09df838ca36601b4b27b49b4?pvs=25#27b261aa09df82e69b39018bd2083bb7) tilts towards $1$ (or $100\%$ ) at that moment. As time passes and more stake participates in the PoS, the difference between the current total stake and the target diminishes. The equation [above](/d96261aa09df838ca36601b4b27b49b4?pvs=25#27b261aa09df82e69b39018bd2083bb7) oscillates around 0 (or $0\%$ ) when $D\_{0,t}$ oscillates around $D\_{0,target}$ .

Let the Logos Blockchain’s security level be defined by:

$$
\text{Security Level} = \dfrac{D\_{0,target}}{S\_{tge}}.
$$
Security Level=Stge​D0,target​​.

#### KPI 2 - The Average Burning Rate

In the long run, Logos Blockchain should mint only enough tokens to compensate for the burned transaction fees.

Let

$D\_{1,t}$ denote the amount of Storage fees and Execution base fees burned since $t-1$ .

$D\_{1,target}=S\_{tge}$ denote the "normalizing factor" (it is the TGE supply, in this case).

This choice of "target" implies that $\gamma\_t$ evaluates the annualized average burning rate with respect to the TGE supply. This makes the equation [above](/d96261aa09df838ca36601b4b27b49b4?pvs=25#a0b261aa09df8315811301dd66c6660c) consistent.

## Float Precision for Implementation

Because block rewards affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic. This is especially important because the current document already notes floating-point concerns in the KPI helper functions and then introduces a final integer rewrite for the reward computation. The issue is therefore not whether integers should be used, but how to present that integer formulation in a way that remains auditable and clearly derived from the protocol parameters.

The goal of this section is not to change the reward mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. In particular, the reward logic remains driven by the same two KPI components described previously: the inferred total stake relative to its target, and the moving average of burned fees over the look-back window. Likewise, the reward still interpolates between inflationary issuance and burned-fee compensation through the emission factor $A\_t$ .

$$
A\_t = \min \Bigl\{ 1, \max \Bigl\{ 0, \dfrac{ \alpha\_d \cdot \delta\_t + \alpha\_a \cdot \gamma\_t + I\_{min}}{I\_{max}} \Bigr\} \Bigr\}.
$$
At​=min{1,max{0,Imax​αd​⋅δt​+αa​⋅γt​+Imin​​}}.

Because we have

$$
\alpha\_d=\frac{1}{4},\quad
\alpha\_a=1,\quad
I\_{\max}=10^{-2},\qquad
T=120,\quad
f=1,\quad R\_\text{block} = D\_{1,t}\\
D\_{0,\mathrm{target}}=3\cdot 10^9,\qquad
D\_{1,\mathrm{target}}=S\_{\mathrm{tge}}=10^{10},\qquad
\Delta\_t=\frac{1}{365\cdot 2880},
$$
αd​=41​,αa​=1,Imax​=10−2,T=120,f=1,Rblock​=D1,t​D0,target​=3⋅109,D1,target​=Stge​=1010,Δt​=365⋅28801​,

$$
\delta\_t = \sum\_i w\_i \times
\dfrac{D\_{i,target} - D\_{i,t}}{D\_{i,target}},
$$
δt​=i∑​wi​×Di,target​Di,target​−Di,t​​,

$$
\gamma\_t = \dfrac{1}{\Delta\_t} \sum\_i w\_i \cdot \Bigl(\dfrac{1}{T} \sum\_{\tau=t-T+1}^t \dfrac{ D\_{i,\tau}}{D\_{i,target}} \Bigr),
$$
γt​=Δt​1​i∑​wi​⋅(T1​τ=t−T+1∑t​Di,target​Di,τ​​),

and $w\_i$ denotes the weight of the $i$ -th KPI in the normalized deviation from target or in the normalized average; it satisfies $\sum\_i w\_i = 1$ .

Therefore,

$$
\frac{\alpha\_d}{I\_{\max}}\delta\_t
=
\frac{1/4}{10^{-2}}\cdot \frac{D\_{0,\mathrm{target}}-D\_{0,t}}{D\_{0,\mathrm{target}}}
=
25\cdot \frac{3\cdot 10^9-D\_{0,t}}{3\cdot 10^9}
=
\frac{3\cdot 10^9-D\_{0,t}}{12\cdot 10^7}.
$$
Imax​αd​​δt​=10−21/4​⋅D0,target​D0,target​−D0,t​​=25⋅3⋅1093⋅109−D0,t​​=12⋅1073⋅109−D0,t​​.

and

$$
\frac{\alpha\_a}{I\_{\max}}\gamma\_t=\frac{1}{10^{-2}}\cdot \frac{1}{\Delta\_t}\cdot \frac{1}{T}\sum\_{\tau=t-T+1}^{t}\frac{D\_{1,\tau}}{D\_{1,\mathrm{target}}}=\\\frac{1}{10^{-2}}\cdot \frac{1}{\Delta\_t}\cdot \frac{1}{T}\cdot\frac{1}{{D\_{1,\mathrm{target}}}}\sum\_{\tau=t-T+1}^{t}{D\_{1,\tau}}=\\
\\100\cdot \frac{1}{\frac{1}{365\cdot 2880}}\cdot \frac{1}{120}\cdot\frac{1}{10^{10}}\sum\_{\tau=t-120+1}^{t}{D\_{1,\tau}}=\\
100\cdot \frac{365\cdot 2880}{120\cdot 10^{10}}\sum\_{\tau=t-120+1}^{t} D\_{1,\tau}=\\
\frac{10512}{12\cdot 10^7}\sum\_{\tau=t-120+1}^{t} D\_{1,\tau}.
$$
Imax​αa​​γt​=10−21​⋅Δt​1​⋅T1​τ=t−T+1∑t​D1,target​D1,τ​​=10−21​⋅Δt​1​⋅T1​⋅D1,target​1​τ=t−T+1∑t​D1,τ​=100⋅365⋅28801​1​⋅1201​⋅10101​τ=t−120+1∑t​D1,τ​=100⋅120⋅1010365⋅2880​τ=t−120+1∑t​D1,τ​=12⋅10710512​τ=t−120+1∑t​D1,τ​.

So we rewrite $A\_t$ by

$$
A\_t=\min\!\left\{1,\max\!\left\{0,\quad \frac{3\cdot 10^9-D\_{0,t}+10512\sum\_{\tau=t-120+1}^{t}D\_{1,\tau}}{12\cdot 10^7}\right\}\right\}.
$$
At​=min{1,max{0,12⋅1073⋅109−D0,t​+10512∑τ=t−120+1t​D1,τ​​}}.

And by denoting

$$
A\_t'
=
\min\!\left\{12\cdot 10^7,\max\!\left\{0,\quad3\cdot 10^9-D\_{0,t}+10512\sum\_{\tau=t-120+1}^{t}D\_{1,\tau}\right\}\right\},
\\
A\_t=\frac{A\_t'}{12\cdot 10^7}.
$$
At′​=min{12⋅107,max{0,3⋅109−D0,t​+10512τ=t−120+1∑t​D1,τ​}},At​=12⋅107At′​​.

We can compute the block reward using only integers:

$$
\text{Rewards}\_t= A\_t \cdot \dfrac{I\_{max} \cdot S\_{tge} \cdot \Delta\_t}{f} + (1-A\_t) \cdot R\_\text{block} =\\
\frac{A\_t'}{12\cdot 10^7} \cdot \dfrac{I\_{max} \cdot S\_{tge} \cdot \Delta\_t}{f} + (1-\frac{A\_t'}{12\cdot 10^7}) \cdot D\_{1,t}
$$
Rewardst​=At​⋅fImax​⋅Stge​⋅Δt​​+(1−At​)⋅Rblock​=12⋅107At′​​⋅fImax​⋅Stge​⋅Δt​​+(1−12⋅107At′​​)⋅D1,t​

and

$$
\frac{I\_{\max} \cdot S\_{\mathrm{tge}}\cdot \Delta\_t}{f}=\frac{10^{-2}\cdot 10^{10}}{365\cdot 2880}=\frac{10^8}{1051200}=\frac{62500}{657}.
$$
fImax​⋅Stge​⋅Δt​​=365⋅288010−2⋅1010​=1051200108​=65762500​.

So:

$$
\text{Rewards}\_t=
\frac{A\_t'}{12\cdot 10^7} \cdot \frac{62500}{657} + (1-\frac{A\_t'}{12\cdot 10^7})\cdot D\_{1,t} =\\
\frac{62500\cdot A\_t' + 657\cdot(12\cdot 10^7-A\_t')\cdot D\_{1,t}}{657\cdot 12\cdot 10^7}
.
$$
Rewardst​=12⋅107At′​​⋅65762500​+(1−12⋅107At′​​)⋅D1,t​=657⋅12⋅10762500⋅At′​+657⋅(12⋅107−At′​)⋅D1,t​​.

So we propose a reference implementation that uses integers:

const A\_SCALE: u128 = 120\_000\_000; // denominator of 1/(I\_max \* D1\_target \* Delta\_t \* T) 
const INFLATION\_NUM: u128 = 62\_500; // numerator of I\_max \* S\_TGE \* DELTA\_t / f
const INFLATION\_DEN: u128 = 657; // denominator of I\_max \* S\_TGE \* DELTA\_t / f
const FEE\_AVG\_NUM: u128 = 10\_512; // numerator of 1/(I\_max \* D1\_target \* Delta\_t \* T) 
const STAKE\_TARGET: u128 = 3e9;
fn block\_reward(total\_stake: u64, burned\_fees\_window: [u64; 120]) -> (u64, u64) {
let sum\_fees: u128 = burned\_fees\_window.iter().map(|x| \*x as u128).sum();
let last\_burned\_fee: u128 = \*burned\_fees\_window.last().unwrap() as u128;
let a\_num = STAKE\_TARGET
.saturating\_add(FEE\_AVG\_NUM.saturating\_mul(sum\_fees))
.saturating\_sub(total\_stake as u128)
.min(A\_SCALE);
let reward\_num =
INFLATION\_NUM \* a\_num
+ INFLATION\_DEN \* (A\_SCALE - a\_num) \* last\_burned\_fee;
let reward\_den = INFLATION\_DEN \* A\_SCALE;
// 60% Blend, 40% leader, with truncation applied only once per share
let blend\_reward = (reward\_num \* 6 / (reward\_den \* 10)) as u64;
let leader\_reward = (reward\_num \* 4 / (reward\_den \* 10)) as u64;
(blend\_reward, leader\_reward)
}

​
