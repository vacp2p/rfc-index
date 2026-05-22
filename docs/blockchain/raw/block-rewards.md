# BLOCK-REWARDS

| Field | Value |
| --- | --- |
| Name | Block Rewards |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | Frederico Teixeira <frederico@logos.co> |
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

Authors: Frederico Teixeira <frederico@logos.co>
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
This document outlines the specifications for Logos Blockchain's block rewards mechanism, a critical component of the network's economic model. The mechanism is designed to create a sustainable economic framework that incentivizes network participation while maintaining long-term stability.
The objective is to develop a block rewards system that addresses key challenges specific to Logos Blockchain's architecture, including the unlinkability between block proposal and reward collection, and the inability to directly allocate transaction fees to specific block proposers. These constraints necessitate a carefully designed economic incentive structure.
Building on previous work in blockchain economics, this specification proposes a dynamic token emission system that calibrates LGO issuance according to network Key Performance Indicators (KPIs). The system uses two primary metrics: inferred total stake (as a security indicator) and average burning rate (to maintain supply equilibrium).
The document references internal mathematical models and simulations that demonstrate how the proposed mechanism would behave under various conditions. Key parameters include maximum annual emission rate (
1
%
1%), control responsiveness factors, and target metrics for network security.
The conclusion of our analysis indicates that this KPI-based emission model should achieve several important outcomes:
Initially higher emission rates (capped at 
1
%
1% annually) to bootstrap network participation.
Gradual stabilization of token supply as the system matures, with our baseline simulation showing just 
1.33
%
1.33% total inflation after 
10
10 years.
Self-regulating mechanism where token issuance naturally adjusts to compensate for burned transaction fees.
Built-in safeguards against manipulation through moving averages and bounded functions.
This specification represents a comprehensive approach to creating a robust economic foundation for the Logos Blockchain network that balances security requirements with long-term economic sustainability.
Overview
The Logos Blockchain block rewards mechanism is a KPI-based dynamic token emission system designed to create a sustainable economic framework that incentivizes network participation while maintaining long-term stability. This section provides a high-level understanding of how the system works and its key components.
Key Principles
The design of the rewards system reflects three architectural constraints unique to Logos Blockchain:
Unlinkability: Block proposal and reward collection are intentionally decoupled for privacy, meaning rewards cannot be assigned to a single proposer.
Fee burning: All transaction fees (execution base fees and permanent storage fees) are burned, rather than directly given to block proposers.
Global metrics over local signals: Rewards are computed from network-wide KPIs at block production time, rather than from easily manipulated per-block data.
These principles ensure that the system is censorship-resistant, manipulation-resistant, and aligned with long-term network incentives.
Requirements
Building upon the requirements for Logos Blockchain's block rewards system, the implementation will establish that all transaction fees are burned while block rewards are tied to measurable global metrics that reflect network health and security. This mechanism ensures that if network activity surges substantially, the accelerated burning of tokens will be balanced by compensatory emissions over time. 
For optimal functionality, block rewards should be anchored to specific observable metrics rather than arbitrary values. Block numbers simply track time passage without indicating chain state. Transaction counts per block are vulnerable to manipulation. On the other hand, tracking the number of Blend nodes or inferring total stake provide more robust information about the chain state, specially when they can be compared with targets that are considered “healthy”. 
Crucially, any metric-pegged reward system should aim toward a target value or equilibrium point, creating predictability and stability in the token economics.
High-level System Design
The system dynamically adjusts token emission based on two primary KPIs:
Inferred Total Stake: Measures network security by tracking the total amount staked against a target threshold (e.g., 
30
%
30% of TGE supply).
Average Burning Rate: Tracks transaction fees (both Execution base fees and Permanent Storage) burned to maintain supply equilibrium.
A control function combines these KPIs to determine the emission rate factor, bounded between a minimum and maximum annual issuance. This ensures that:
When security participation is below target, higher issuance attracts more validators.
As usage increases and fees are burned, emissions adjust downward to stabilize supply.
​
The equation that defines the amount of block rewards is given by:
𝐴
𝑡
⋅
𝐼
𝑚
𝑎
𝑥
⋅
𝑆
𝑡
𝑔
𝑒
⋅
Δ
𝑡
𝑓
+
(
1
−
𝐴
𝑡
)
⋅
𝑅
block
A
t
	​

⋅
f
I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

	​

+(1−A
t
	​

)⋅R
block
	​

where:
𝐴
𝑡
A
t
	​

 is the emission rate factor on a per year basis.
𝐼
𝑚
𝑎
𝑥
I
max
	​

 is the maximum emission rate per year.
𝑆
𝑡
𝑔
𝑒
S
tge
	​

 denotes the token supply at Token Generation Event (TGE).
Δ
𝑡
Δ
t
	​

 denotes the fraction of year in one time step per e.g., epoch, block, or day.
𝑓
f be the average number of block proposal within 
Δ
𝑡
Δ
t
	​

 units.
𝑅
block
R
block
	​

 denotes the total amount of Execution base fees and Permanent Storage fees that are burned when the block is proposed.
Lifecycle Phases
The system is designed to evolve through different phases:
Bootstrap Phase: Initially higher emission rates (up to 
1
%
1% annually) to incentivize network participation when stake is below target. As it is explained below, this is viable even when Logos Blockchain experiences low activity because the level of activity only plays a role when the network participation gets close to the predefined target.
Stabilization Phase: As Proof-of-Stake (PoS) participation approaches target levels, emission becomes primarily driven by burning rate.
Equilibrium Phase: Supply stabilizes with issuance matching burned fees.
High-Adoption Phase: If burning exceeds maximum emission, supply becomes deflationary.
Benefits
This KPI-based approach delivers several advantages:
Self-regulating mechanism that automatically adjusts to network conditions.
Long-term sustainability with projected total inflation of just 
1.33
%
1.33% after 
10
10 years (assuming constant burning rate of 
0.5
%
0.5% per year).
Built-in safeguards against manipulation through moving averages and bounded functions.
Predictable economic model that balances security incentives with controlled supply.
The overall design creates a robust economic foundation for the Logos Blockchain blockchain that effectively balances the need for strong security incentives with long-term token supply stability.
Construction
The proposed mechanism implements a dynamic token emission system that precisely calibrates LGO issuance according to network performance metrics (KPIs). This adaptive model adjusts emission rates based on how KPIs perform relative to their predetermined targets, while maintaining strict adherence to supply parameters and economic boundaries.
Core Variables
The following variables are input to the model:
𝑆
𝑡
𝑔
𝑒
S
tge
	​

 denotes the token supply at Token Generation Event (TGE).
𝑆
𝑐
𝑎
𝑝
S
cap
	​

 denotes the maximum allowable token supply (hard cap), if any.
Δ
𝑡
Δ
t
	​

 denotes the fraction of year in one time step per e.g., epoch, block, or day:
if the time step is 1 day, then 
Δ
𝑡
=
1
/
365
Δ
t
	​

=1/365.
if the time step is 1 block every 
30
30 seconds, then 
Δ
𝑡
=
1
/
(
365
×
2880
)
Δ
t
	​

=1/(365×2880).
if the time step is 1 epoch, which lasts 7.5 days, then 
Δ
𝑡
=
1
/
(
365
/
7.5
)
=
1
/
48.667
Δ
t
	​

=1/(365/7.5)=1/48.667.
𝑓
f be the average number of block proposal within 
Δ
𝑡
Δ
t
	​

 units:
if the time step is 1 day and blocks are proposed every 30 seconds, then 
𝑓
=
2880
f=2880 (the number of 30 seconds intervals in 1 day).
if the time step is 1 epoch, which lasts 7.5 days, and blocks are processed every 30 seconds, then 
𝑓
=
7.5
×
2880
=
21600
f=7.5×2880=21600 (the number of 30 seconds intervals in 7.5 day).
𝐼
𝑚
𝑖
𝑛
I
min
	​

 is the minimum emission rate per year (default: 
0
%
0%).
𝐼
𝑚
𝑎
𝑥
I
max
	​

 is the maximum emission rate per year (default: 
1
%
1%).
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
i,target
	​

 denotes the target value for the 
𝑖
i-th KPI.
𝑤
𝑖
w
i
	​

 denotes the weight of the 
𝑖
i-th KPI in the normalized deviation from target or in the normalized average; it satisfies 
∑
𝑖
𝑤
𝑖
=
1
∑
i
	​

w
i
	​

=1.
𝛼
𝑑
>
0
α
d
	​

>0 denotes the control responsiveness to KPI deviation metrics.
𝛼
𝑎
>
0
α
a
	​

>0 denotes the control responsiveness to KPI average metrics.
𝑇
T be the number of periods in the look-back window for the moving average.
Let us define the following variables:
𝑆
𝑡
S
t
	​

 denotes the token circulating supply at time 
𝑡
t.
𝐴
𝑡
∈
[
0
,
1
]
A
t
	​

∈[0,1] denotes the emission rate factor on a per year basis.
This implies that 
𝐴
𝑡
⋅
𝐼
𝑚
𝑎
𝑥
⋅
Δ
𝑡
A
t
	​

⋅I
max
	​

⋅Δ
t
	​

 denotes the emission within the time-step.
𝐷
𝑖
,
𝑡
D
i,t
	​

 denotes the 
𝑖
i-th key performance indicator at time 
𝑡
t (e.g., TVL, staked amount, active users).
𝑅
block
R
block
	​

 denotes the total amount of Execution Gas and Permanent Storage fees burnt in a block. Refer to 🔀
[1.0.0] Execution Market and 🔀
[1.0.0] Storage Markets for how to compute 
𝑅
𝑏
𝑙
𝑜
𝑐
𝑘
R
block
	​

.
Parametrization
Symbol
	
Definition
	
Default Value
	
Explanation


𝑆
𝑡
𝑔
𝑒
S
tge
	​

​
	
Token supply at TGE
	
10 billion LGO
	
N.A.


𝑇
T​
	
The number of periods in the look-back window for the moving average.
	
120
120​
	
As the system is expected to mint 1 block every 30 seconds, this look-back window defines that the minting averages the fees burned in the last hour. 


𝛼
𝑎
α
a
	​

​
	
Denotes the control responsiveness to KPI average metrics.
	
1
1​
	
This parameter drives the token emission from the burn rate. It must be one-to-one.


𝛼
𝑑
α
d
	​

​
	
Denotes the control responsiveness to KPI deviation metrics.
	
1
/
4
1/4​
	
See 
No access, for details.


𝑤
𝑖
w
i
	​

​
	
Denotes the weight of the 
𝑖
i-th KPI in the normalized deviation from target
	
1
1​
	
There's only one KPI of this type in our system.


𝐷
0
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
0,target
	​

​
	
Denotes the target value for the first KPI based on stake.
	
3 billion LOGOS
	
30
%
30% of the token supply. 


𝐷
1
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
1,target
	​

​
	
Denotes the target value for the second KPI based on fees.
	
10
10 billon LOGOS
	
In the context of this KPI, this value behaves as a normalizer


𝐼
𝑚
𝑎
𝑥
I
max
	​

​
	
The maximum emission rate per year
	
1
%
1%​
	
This value guarantees that, when the total inferred stake reaches 
𝐷
0
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
0,target
	​

, then the APY for validation is ~3.33%.


𝐼
𝑚
𝑖
𝑛
I
min
	​

​
	
The minimum emission rate per year
	
0
%
0%​
	
This avoids inflationary token emissions.


𝑓
f​
	
The average number of block proposal within 
Δ
𝑡
Δ
t
	​

 units
	
1
1​
	
The time step 
Δ
𝑡
Δ
t
	​

 was chosen so that 
𝑓
f equals to 
1
1. 


Δ
𝑡
Δ
t
	​

​
	
Time step, the fraction of year in one time step (per e.g., epoch, block, or day)
	
1
/
(
365
×
2880
)
1/(365×2880)​
	
The time step is 1 block every 
30
30 seconds; there are 2880 blocks of 30 seconds in a day.
The calibration of these parameters can be found in 🔀
[1.0.0][Analysis] Block Reward Parameter Calibration.
Block Rewards
The amount of tokens to be rewarded in a block depends on the emission rate factor 
𝐴
𝑡
A
t
	​

. This controls how much is minted from inflation and how much is diverted from transaction fees. The following behavior is expected:
When the aggregate KPI is far from the target, 
𝐴
𝑡
→
1
A
t
	​

→1, then the emission of new tokens  (inflation) is maximized, and most of the transaction fees aren't minted back. The amount of tokens burned does not impact the block rewards in this situation. This means that the system can burn more tokens than it mints.
When the aggregate KPI is close to the target, 
𝐴
𝑡
→
0
A
t
	​

→0, then the emission from inflation is minimized, and most of 
𝑅
𝑏
𝑙
𝑜
𝑐
𝑘
R
block
	​

 is minted back for leaders and Blend nodes.
That is, what drives the source of minting is the KPI: if far from the target, the system mints new tokens; if close to the target, the system mints exactly what was burned (up to 
𝐼
𝑚
𝑎
𝑥
I
max
	​

 of TGE).
The emission from inflation within the time step 
Δ
𝑡
Δ
t
	​

 is given by
𝐴
𝑡
⋅
𝐼
𝑚
𝑎
𝑥
⋅
𝑆
𝑡
𝑔
𝑒
⋅
Δ
𝑡
.
A
t
	​

⋅I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

.
The actual amount of tokens minted per block (because of inflation) also depends on how many blocks are expected to be proposed between 
Δ
𝑡
−
1
Δ
t−1
	​

 and 
Δ
𝑡
Δ
t
	​

. This is expressed by the factor 
𝑓
f, as defined above.
The equation that implements the behavior above in terms of 
𝐴
𝑡
A
t
	​

 is given by:
	
𝐴
𝑡
⋅
𝐼
𝑚
𝑎
𝑥
⋅
𝑆
𝑡
𝑔
𝑒
⋅
Δ
𝑡
𝑓
+
(
1
−
𝐴
𝑡
)
⋅
𝑅
block
		
A
t
	​

⋅
f
I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

	​

+(1−A
t
	​

)⋅R
block
	​

	​

	​

where:
𝐴
𝑡
A
t
	​

 is the emission rate factor on a per year basis.
𝐼
𝑚
𝑎
𝑥
I
max
	​

 is the maximum emission rate per year.
𝑆
𝑡
𝑔
𝑒
S
tge
	​

 denotes the token supply at Token Generation Event (TGE).
Δ
𝑡
Δ
t
	​

 denotes the fraction of year in one time step per e.g., epoch, block, or day.
𝑓
f be the average number of block proposal within 
Δ
𝑡
Δ
t
	​

 units.
𝑅
block
=
𝐷
1
,
𝑡
R
block
	​

=D
1,t
	​

 denotes the total amount of Execution base fees and Storage fees that are burned when the block is proposed.
def block_rewards(
		S_tge:float,
    emission_rate_factor:float,
    I_max:float,
    Delta_t:float,
    f:float,
    D_1_t: float
) -> float:
    """
		    Calculate the rewards per block.
		    It implements equation (1).
		"""
    emission_from_inflation = emission_rate_factor * I_max * S_tge * Delta_t / f
    emission_from_rewards = (1. - emission_rate_fator) * R_block_cur
    return emission_from_inflation + emission_from_rewards

​
Emission Rate Factor Function
The emission rate factor 
𝐴
𝑡
∈
[
0
,
1
]
A
t
	​

∈[0,1] determines the portion of 
𝐼
𝑚
𝑎
𝑥
I
max
	​

 that should be emitted based on current values of 
𝛿
𝑡
δ
t
	​

 and 
𝛾
𝑡
γ
t
	​

:
𝐴
𝑡
=
min
⁡
{
1
,
max
⁡
{
0
,
𝛼
𝑑
⋅
𝛿
𝑡
+
𝛼
𝑎
⋅
𝛾
𝑡
+
𝐼
𝑚
𝑖
𝑛
𝐼
𝑚
𝑎
𝑥
}
}
.
A
t
	​

=min{1,max{0,
I
max
	​

α
d
	​

⋅δ
t
	​

+α
a
	​

⋅γ
t
	​

+I
min
	​

	​

}}.
where
𝛼
𝑑
α
d
	​

 controls the responsiveness to KPI deviation metrics.
𝛿
𝑡
δ
t
	​

 is measuring the KPI deviation from targets.
𝛼
𝑎
α
a
	​

 controls the responsiveness to KPI average metrics.
𝛾
𝑡
γ
t
	​

 is measuring the KPI average values of over the last 
𝑇
T steps.
𝐼
𝑚
𝑖
𝑛
I
min
	​

 is the minimum emission rate per year.
𝐼
𝑚
𝑎
𝑥
I
max
	​

 is the maximum emission rate per year.
All terms are displayed in annualized form to ease comparison.
def calculate_emission_rate_factor(
		alpha_dev:float,
    weighted_target_deviation: float,
    alpha_avg:float
    weighted_avg: float,
    i_min: float = 0.0,
    i_max: float = 0.01
) -> float:
    """It calculates the current emission rate factor"""
    emission_rate:float = alpha_dev * weighted_target_deviation + alpha_avg * weighted_avg + i_min
    emission_rate_factor:float = emission_rate / i_max
    emission_rate_factor = min(1.0, max(emission_rate_factor, 0.0))
    return emission_rate_factor

​
KPI Deviation from Target
The weighted deviation from target
𝛿
𝑡
=
∑
𝑖
𝑤
𝑖
×
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
−
𝐷
𝑖
,
𝑡
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
.
δ
t
	​

=
i
∑
	​

w
i
	​

×
D
i,target
	​

D
i,target
	​

−D
i,t
	​

	​

.
def weighted_deviation_from_target(
    kpi_weights: List[float],
    kpi_deviations: List[float]
) -> float:
    """
    Calculate the normalized deviation (delta_t).
    Inputs:
    * kpi_weights: constant list of floats
    * kpi_deviations: for each KPI, it contains the results of "deviation_from_target"
    Returns:
    * a normalized annualized KPI in units of %.
    """
    assert len(kpi_weights) == len(kpi_deviations)
    
    weighted_target_deviation:float = 0.0
    
    for deviation, weight in zip(kpi_deviations, kpi_weights):
        weighted_target_deviation += weight * deviation value

    return weighted_target_deviation

​
It implies that:
𝛿
𝑡
>
0
δ
t
	​

>0 → KPI below target → should increase the token emission by a factor of 
𝛼
𝑑
⋅
𝛿
𝑡
α
d
	​

⋅δ
t
	​

.
𝛿
𝑡
=
0
δ
t
	​

=0 → KPI at target → should not change the token emission.
𝛿
𝑡
<
0
δ
t
	​

<0 → KPI above target → should reduce the token emission by a factor of 
𝛼
𝑑
⋅
𝛿
𝑡
α
d
	​

⋅δ
t
	​

.
💡
To measure the deviation, only the total estimated stake KPI is used in this part of the computation
KPI Average
The weighted average metric is defined as
𝛾
𝑡
=
1
Δ
𝑡
∑
𝑖
𝑤
𝑖
⋅
(
1
𝑇
∑
𝜏
=
𝑡
−
𝑇
+
1
𝑡
𝐷
𝑖
,
𝜏
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
)
.
γ
t
	​

=
Δ
t
	​

1
	​

i
∑
	​

w
i
	​

⋅(
T
1
	​

τ=t−T+1
∑
t
	​

D
i,target
	​

D
i,τ
	​

	​

).
where:
The value 
𝐷
𝑗
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
j,target
	​

 can be any number with the same units of 
𝐷
𝑗
,
𝑖
D
j,i
	​

.
The factor 
1
Δ
𝑡
Δ
t
	​

1
	​

 turns 
𝛾
𝑡
γ
t
	​

 into an annualized quantity. This depends on the specific KPI.
def weighted_average(
    kpi_weights: List[float],
    kpi_average: List[float]
) -> float:
    """
    Calculate the weighted average metric (gamma_t)
    * kpi_weights: constant list of floats
    * kpi_average: for each KPI, it contains the results of "average_kpi"
    """
    assert len(kpi_weights) == len(kpi_deviations)
    
    weighted_avg:float = 0.0
    
    for avg, weight in zip(kpi_average, kpi_weights):
        weighted_avg += weight * avg

    return weighted_avg

​
The weighted average metric features:
𝛾
𝑡
>
0
γ
t
	​

>0 → should increase the token emission by a factor of 
𝛼
𝑎
𝛾
𝑡
α
a
	​

γ
t
	​

.
𝛾
𝑡
=
0
γ
t
	​

=0 → should not change the token emission.
𝛾
𝑡
<
0
γ
t
	​

<0 → should reduce the token emission by a factor of 
𝛼
𝑎
𝛾
𝑡
α
a
	​

γ
t
	​

.
💡
To measure the average, only the average burning rate KPI is used in this part of the computation
Key Performance Indicator(s)
KPI 1 - The Inferred Total Stake
Given the privacy features of Logos Blockchain and the fact that the token TGE supply is known, the inferred total stake is the most appropriate indicator of the system's security.
Let:
𝐷
0
,
𝑡
D
0,t
	​

 denotes the evolution of the inferred total stake.
𝐷
0
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
0,target
	​

 denotes the total stake that is considered secure. For the blockchain to be secure, we aim for 
30
%
30% of the TGE supply.
The inferred total stake affects the emission rate through the "normalized deviation from target." The deviation implied by this KPI is characterized by the plot below.
Figure 1
This happens because, when the blockchain starts, 
𝐷
0
,
𝑡
∣
𝑡
=
0
D
0,t
	​

∣
t=0
	​

 is very likely a small number compared to the target. Therefore, the equation above tilts towards 
1
1 (or 
100
%
100%) at that moment. As time passes and more stake participates in the PoS, the difference between the current total stake and the target diminishes. The equation above oscillates around 0 (or 
0
%
0%) when 
𝐷
0
,
𝑡
D
0,t
	​

 oscillates around 
𝐷
0
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
D
0,target
	​

.
Let the Logos Blockchain’s security level be defined by:
Security Level
=
𝐷
0
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
𝑆
𝑡
𝑔
𝑒
.
Security Level=
S
tge
	​

D
0,target
	​

	​

.
KPI 2 - The Average Burning Rate
In the long run, Logos Blockchain should mint only enough tokens to compensate for the burned transaction fees.
Let
𝐷
1
,
𝑡
D
1,t
	​

 denote the amount of Storage fees and Execution base fees burned since 
𝑡
−
1
t−1.
𝐷
1
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
=
𝑆
𝑡
𝑔
𝑒
D
1,target
	​

=S
tge
	​

 denote the "normalizing factor" (it is the TGE supply, in this case).
This choice of "target" implies that 
𝛾
𝑡
γ
t
	​

 evaluates the annualized average burning rate with respect to the TGE supply. This makes the equation above consistent.
Float Precision for Implementation
Because block rewards affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic. This is especially important because the current document already notes floating-point concerns in the KPI helper functions and then introduces a final integer rewrite for the reward computation. The issue is therefore not whether integers should be used, but how to present that integer formulation in a way that remains auditable and clearly derived from the protocol parameters.
The goal of this section is not to change the reward mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. In particular, the reward logic remains driven by the same two KPI components described previously: the inferred total stake relative to its target, and the moving average of burned fees over the look-back window. Likewise, the reward still interpolates between inflationary issuance and burned-fee compensation through the emission factor 
𝐴
𝑡
A
t
	​

.
𝐴
𝑡
=
min
⁡
{
1
,
max
⁡
{
0
,
𝛼
𝑑
⋅
𝛿
𝑡
+
𝛼
𝑎
⋅
𝛾
𝑡
+
𝐼
𝑚
𝑖
𝑛
𝐼
𝑚
𝑎
𝑥
}
}
.
A
t
	​

=min{1,max{0,
I
max
	​

α
d
	​

⋅δ
t
	​

+α
a
	​

⋅γ
t
	​

+I
min
	​

	​

}}.
Because we have
𝛼
𝑑
=
1
4
,
𝛼
𝑎
=
1
,
𝐼
max
⁡
=
10
−
2
,
𝑇
=
120
,
𝑓
=
1
,
𝑅
block
=
𝐷
1
,
𝑡
𝐷
0
,
t
a
r
g
e
t
=
3
⋅
10
9
,
𝐷
1
,
t
a
r
g
e
t
=
𝑆
t
g
e
=
10
10
,
Δ
𝑡
=
1
365
⋅
2880
,
α
d
	​

=
4
1
	​

,α
a
	​

=1,I
max
	​

=10
−2
,T=120,f=1,R
block
	​

=D
1,t
	​

D
0,target
	​

=3⋅10
9
,D
1,target
	​

=S
tge
	​

=10
10
,Δ
t
	​

=
365⋅2880
1
	​

,
𝛿
𝑡
=
∑
𝑖
𝑤
𝑖
×
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
−
𝐷
𝑖
,
𝑡
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
,
δ
t
	​

=
i
∑
	​

w
i
	​

×
D
i,target
	​

D
i,target
	​

−D
i,t
	​

	​

,
𝛾
𝑡
=
1
Δ
𝑡
∑
𝑖
𝑤
𝑖
⋅
(
1
𝑇
∑
𝜏
=
𝑡
−
𝑇
+
1
𝑡
𝐷
𝑖
,
𝜏
𝐷
𝑖
,
𝑡
𝑎
𝑟
𝑔
𝑒
𝑡
)
,
γ
t
	​

=
Δ
t
	​

1
	​

i
∑
	​

w
i
	​

⋅(
T
1
	​

τ=t−T+1
∑
t
	​

D
i,target
	​

D
i,τ
	​

	​

),
and 
𝑤
𝑖
w
i
	​

 denotes the weight of the 
𝑖
i-th KPI in the normalized deviation from target or in the normalized average; it satisfies 
∑
𝑖
𝑤
𝑖
=
1
∑
i
	​

w
i
	​

=1.
Therefore,
𝛼
𝑑
𝐼
max
⁡
𝛿
𝑡
=
1
/
4
10
−
2
⋅
𝐷
0
,
t
a
r
g
e
t
−
𝐷
0
,
𝑡
𝐷
0
,
t
a
r
g
e
t
=
25
⋅
3
⋅
10
9
−
𝐷
0
,
𝑡
3
⋅
10
9
=
3
⋅
10
9
−
𝐷
0
,
𝑡
12
⋅
10
7
.
I
max
	​

α
d
	​

	​

δ
t
	​

=
10
−2
1/4
	​

⋅
D
0,target
	​

D
0,target
	​

−D
0,t
	​

	​

=25⋅
3⋅10
9
3⋅10
9
−D
0,t
	​

	​

=
12⋅10
7
3⋅10
9
−D
0,t
	​

	​

.
and
𝛼
𝑎
𝐼
max
⁡
𝛾
𝑡
=
1
10
−
2
⋅
1
Δ
𝑡
⋅
1
𝑇
∑
𝜏
=
𝑡
−
𝑇
+
1
𝑡
𝐷
1
,
𝜏
𝐷
1
,
t
a
r
g
e
t
=
1
10
−
2
⋅
1
Δ
𝑡
⋅
1
𝑇
⋅
1
𝐷
1
,
t
a
r
g
e
t
∑
𝜏
=
𝑡
−
𝑇
+
1
𝑡
𝐷
1
,
𝜏
=
100
⋅
1
1
365
⋅
2880
⋅
1
120
⋅
1
10
10
∑
𝜏
=
𝑡
−
120
+
1
𝑡
𝐷
1
,
𝜏
=
100
⋅
365
⋅
2880
120
⋅
10
10
∑
𝜏
=
𝑡
−
120
+
1
𝑡
𝐷
1
,
𝜏
=
10512
12
⋅
10
7
∑
𝜏
=
𝑡
−
120
+
1
𝑡
𝐷
1
,
𝜏
.
I
max
	​

α
a
	​

	​

γ
t
	​

=
10
−2
1
	​

⋅
Δ
t
	​

1
	​

⋅
T
1
	​

τ=t−T+1
∑
t
	​

D
1,target
	​

D
1,τ
	​

	​

=
10
−2
1
	​

⋅
Δ
t
	​

1
	​

⋅
T
1
	​

⋅
D
1,target
	​

1
	​

τ=t−T+1
∑
t
	​

D
1,τ
	​

=
100⋅
365⋅2880
1
	​

1
	​

⋅
120
1
	​

⋅
10
10
1
	​

τ=t−120+1
∑
t
	​

D
1,τ
	​

=
100⋅
120⋅10
10
365⋅2880
	​

τ=t−120+1
∑
t
	​

D
1,τ
	​

=
12⋅10
7
10512
	​

τ=t−120+1
∑
t
	​

D
1,τ
	​

.
So we rewrite 
𝐴
𝑡
A
t
	​

 by
𝐴
𝑡
=
min
⁡
 ⁣
{
1
,
max
⁡
 ⁣
{
0
,
3
⋅
10
9
−
𝐷
0
,
𝑡
+
10512
∑
𝜏
=
𝑡
−
120
+
1
𝑡
𝐷
1
,
𝜏
12
⋅
10
7
}
}
.
A
t
	​

=min{1,max{0,
12⋅10
7
3⋅10
9
−D
0,t
	​

+10512∑
τ=t−120+1
t
	​

D
1,τ
	​

	​

}}.
And by denoting 
𝐴
𝑡
′
=
min
⁡
 ⁣
{
12
⋅
10
7
,
max
⁡
 ⁣
{
0
,
3
⋅
10
9
−
𝐷
0
,
𝑡
+
10512
∑
𝜏
=
𝑡
−
120
+
1
𝑡
𝐷
1
,
𝜏
}
}
,
𝐴
𝑡
=
𝐴
𝑡
′
12
⋅
10
7
.
A
t
′
	​

=min{12⋅10
7
,max{0,3⋅10
9
−D
0,t
	​

+10512
τ=t−120+1
∑
t
	​

D
1,τ
	​

}},
A
t
	​

=
12⋅10
7
A
t
′
	​

	​

.
We can compute the block reward using only integers:
Rewards
𝑡
=
𝐴
𝑡
⋅
𝐼
𝑚
𝑎
𝑥
⋅
𝑆
𝑡
𝑔
𝑒
⋅
Δ
𝑡
𝑓
+
(
1
−
𝐴
𝑡
)
⋅
𝑅
block
=
𝐴
𝑡
′
12
⋅
10
7
⋅
𝐼
𝑚
𝑎
𝑥
⋅
𝑆
𝑡
𝑔
𝑒
⋅
Δ
𝑡
𝑓
+
(
1
−
𝐴
𝑡
′
12
⋅
10
7
)
⋅
𝐷
1
,
𝑡
Rewards
t
	​

=A
t
	​

⋅
f
I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

	​

+(1−A
t
	​

)⋅R
block
	​

=
12⋅10
7
A
t
′
	​

	​

⋅
f
I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

	​

+(1−
12⋅10
7
A
t
′
	​

	​

)⋅D
1,t
	​

and
𝐼
max
⁡
⋅
𝑆
t
g
e
⋅
Δ
𝑡
𝑓
=
10
−
2
⋅
10
10
365
⋅
2880
=
10
8
1051200
=
62500
657
.
f
I
max
	​

⋅S
tge
	​

⋅Δ
t
	​

	​

=
365⋅2880
10
−2
⋅10
10
	​

=
1051200
10
8
	​

=
657
62500
	​

.
So:
Rewards
𝑡
=
𝐴
𝑡
′
12
⋅
10
7
⋅
62500
657
+
(
1
−
𝐴
𝑡
′
12
⋅
10
7
)
⋅
𝐷
1
,
𝑡
=
62500
⋅
𝐴
𝑡
′
+
657
⋅
(
12
⋅
10
7
−
𝐴
𝑡
′
)
⋅
𝐷
1
,
𝑡
657
⋅
12
⋅
10
7
.
Rewards
t
	​

=
12⋅10
7
A
t
′
	​

	​

⋅
657
62500
	​

+(1−
12⋅10
7
A
t
′
	​

	​

)⋅D
1,t
	​

=
657⋅12⋅10
7
62500⋅A
t
′
	​

+657⋅(12⋅10
7
−A
t
′
	​

)⋅D
1,t
	​

	​

.
So we propose a reference implementation that uses integers:
const A_SCALE: u128 = 120_000_000;  // denominator of 1/(I_max * D1_target * Delta_t * T) 
const INFLATION_NUM: u128 = 62_500; // numerator of I_max * S_TGE * DELTA_t / f
const INFLATION_DEN: u128 = 657;    // denominator of I_max * S_TGE * DELTA_t / f
const FEE_AVG_NUM: u128 = 10_512;   // numerator of 1/(I_max * D1_target * Delta_t * T) 
const STAKE_TARGET: u128 = 3e9;
fn block_reward(total_stake: u64, burned_fees_window: [u64; 120]) -> (u64, u64) {
    let sum_fees: u128 = burned_fees_window.iter().map(|x| *x as u128).sum();
    let last_burned_fee: u128 = *burned_fees_window.last().unwrap() as u128;

    let a_num = STAKE_TARGET
        .saturating_add(FEE_AVG_NUM.saturating_mul(sum_fees))
        .saturating_sub(total_stake as u128)
        .min(A_SCALE);

    let reward_num =
        INFLATION_NUM  * a_num
        + INFLATION_DEN * (A_SCALE  - a_num) * last_burned_fee;

    let reward_den = INFLATION_DEN * A_SCALE;

    // 60% Blend, 40% leader, with truncation applied only once per share
    let blend_reward = (reward_num * 6 / (reward_den * 10)) as u64;
    let leader_reward = (reward_num * 4 / (reward_den * 10)) as u64;

    (blend_reward, leader_reward)
}

​
