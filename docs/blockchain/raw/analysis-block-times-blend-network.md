# ANALYSISBLOCK-TIMES-BLEND-NETWORK

| Field | Value |
| --- | --- |
| Name | [Analysis] Block Times & Blend Network |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
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

Authors: David Rusu <davidrusu@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-08-20
Introduction
We are interested in finalizing the Cryptarchia and Blend Network parameters. There are some competing requirements here: the Blend Network would like to have longer block times in order to provide better privacy, while Cryptarchia wants shorter block times in order to provide faster finality.
We need to find the right balance that would give us good enough privacy while not sacrificing finality times too much.
Overview
Adversary Model
The analysis centres on the block-witholding attack where an adversary does not participate in the main chain, instead building a secret side-chain and releasing it on the network in an attempt to trigger the honest chain to reorg.
We first simulate the honest network to build out a block tree.
We then simulate the adversary slot wins.
We also consider the effect of extending from the honest block tree at each block to see how many reorgs the adversary can induce.
This is repeated, with the adversary branch forking off of each block.
The adversary can even boost his attack by continuing abandoned branches.
Network Model
Leader proposing a block through the Blend Network.
blend_network = NetworkParams(
    broadcast_delay_mean=0.5, # seconds
    pol_proof_time=1, # 1 second PoL delay
    blending_delay=3, # seconds spent in each Blend node
    desimenation_delay_mean=0.5, # seconds to disseminate message within Blend
    blend_hops=3, # hops within Blend
)
no_blend_net = replace(blend_net, blend_hops=0)

The Blend Network model used in simulations. 
​
The block delay distribution from the network model looks like this:
Choosing a Block Time
30% Adversary
PATHS = 5
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([15, 30, 60, 120]).repeat(PATHS)]

​
Choosing Blend Parameters
There are two parameters that are of concern here: Number of Hops and the Blending Delay.
The number of hops tells us how many times the block proposal needs to be processed by the network before the proposal is broadcast to the wider network. 
The Blending delay tells us the maximum time each message is processed at each hop.
Number of Hops
1 hop
3 hops
5 hops
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blend_hops=hops)
) for hops in np.array([1, 2, 3]).repeat(PATHS)]

​
From these plots we can see that going above 3 hops begins to induce too many reorgs.
Blending Delay
3 second Blend delay
5 second Blend delay
10 second Blend delay
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blending_delay=delay)
) for delay in np.array([3, 5, 10]).repeat(PATHS)]

​
A blending delay above 3 seconds induces too many reorgs.
Impact of Combinations of Hops and Delays
Checking parameters in combinations shows that again, going above 3 hops or above a 3 second delay leads to divergence from the Cardano baseline.
25 second block times
30 second block times
35 second block times
Powerful Adversaries
With 3 hops and 3 second delays, it’s interesting too look at how the network would behave under different strength adversaries.
10% Adversary
2s blending delay
2s blending delay
Params
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.10,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]


​
30% Adversary
2s blending delay
2s blending delay
35s block times, 3s blending delay
Params
PATHS = 1
target_block_num = 200000
np.random.seed(0)
stake = np.random.pareto(10, 100)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.3,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]


for i, sim in enumerate(sims):
    print(f"simulating {i+1}/{len(sims)}")
    sim.run(seed=i)

print("finished simulation, starting analysis")
advs = [sim.adverserial_analysis() for sim in sims]

print("cardano parameters")
cardano_block_time = 20
cardano_sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * cardano_block_time),
        f=1/cardano_block_time,
    ),
    network=replace(network, blend_hops=0)
) for _ in range(PATHS)]

for i, sim in enumerate(cardano_sims):
    print(f"simulating {i+1}/{len(cardano_sims)}")
    sim.run(seed=i)

cardano_advs = [sim.adverserial_analysis() for sim in cardano_sims]


# -------

PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]



​
40% Adversary
2s blending delay
2s blend delay
Params
PATHS = 5
target_block_num = 40000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.40,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]


​
45% Adversary
2s blending delay
2s blending delay
Params
PATHS = 5
target_block_num = 40000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.45,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]


​
49% Adversary
2s blending delay
2s blending delay
Params
PATHS = 5
target_block_num = 30000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.49,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([30]).repeat(PATHS)]


​
Conclusion
Our conclusion is that 30s block times, 3 blend hops, 2s blending delay are safe and we propose we use this parameter set for Nomos. 
Annex
Exploring Analytical Results from Praos
Praos provides the following theorem about the probability of violating the common prefix property:
In addition to simulations, we could try to use this analytical results to determine the impact of changing block times and network assumptions.
Theorem Condition
First we must satisfy the condition 
𝛼
(
1
−
𝑓
)
Δ
+
1
≥
1
+
𝜖
2
α(1−f)
Δ+1
≥
2
1+ϵ
	​

 where
𝛼
α is the stake held by honest parties
𝑓
f is the active slot coefficient
Δ
Δ is the max network delay
𝜖
>
0
ϵ>0 is the advantage of the honest network over the adversarial network
We want to understand for a given parameter set, what is the required honest stake 
𝛼
α to satisfy the safety condition:
	
𝛼
(
1
−
𝑓
)
Δ
+
1
	
≥
1
+
𝜖
2
		
	
𝛼
	
≥
1
+
𝜖
2
(
1
−
𝑓
)
Δ
+
1
		
α(1−f)
Δ+1
α
	​

≥
2
1+ϵ
	​

≥
2(1−f)
Δ+1
1+ϵ
	​

	​

	​

We can then look at the minimum 
𝛼
α that satisfies this condition for Cardano and Nomos.
Cardano’s parameter set 
𝑓
=
1
/
20
,
𝜖
=
1
𝑒
−
6
f=1/20,ϵ=1e−6​
Nomos’ parameter set 
𝑓
=
1
/
30
,
𝜖
=
1
𝑒
−
6
f=1/30,ϵ=1e−6​
Surprisingly, at at 5s max network delay, we are already requiring ~70% of stake to be honest in Cardano.
On Nomos, based on the network modelling we had done, we had a ~14s max delay. This would require 83% of the network to be honest in order to satisfy this condition.
If we change our blending delay to 2s, then we have a ~11s max delay. This would require 75% of the network to be honest in order to satisfy this condition.
Probability of Violating Common Prefix
The main result of the theorem states that the probability of violating common prefix is bounded above by 
exp
⁡
(
ln
⁡
(
𝑅
)
+
Δ
−
Ω
(
𝑘
)
)
exp(ln(R)+Δ−Ω(k)), where 
Ω
(
𝑘
)
Ω(k) is asymptotic notation reflecting a term that grows at least as fast as 
𝑘
k.
We can ask the question “how does the probability change if we change our parameters from Cardano’s to Nomos’?”
We don’t know the 
Ω
(
𝑘
)
Ω(k) term, but we can get the relative change by dividing the Cardano probability by the Nomos probability, and cancel out the 
Ω
(
𝑘
)
Ω(k) term:
	
exp
⁡
(
𝑙
𝑛
(
𝑅
)
+
Δ
𝑐
𝑎
𝑟
𝑑
𝑎
𝑛
𝑜
−
Ω
(
𝑘
)
)
exp
⁡
(
𝑙
𝑛
(
𝑅
)
+
Δ
𝑛
𝑜
𝑚
𝑜
𝑠
−
Ω
(
𝑘
)
)
	
=
𝑅
𝑒
Δ
𝑐
𝑎
𝑟
𝑑
𝑎
𝑛
𝑜
−
Ω
(
𝑘
)
𝑅
𝑒
Δ
𝑛
𝑜
𝑚
𝑜
𝑠
−
Ω
(
𝑘
)
		
	
	
=
𝑒
Δ
𝑐
𝑎
𝑟
𝑑
𝑎
𝑛
𝑜
−
Δ
𝑛
𝑜
𝑚
𝑜
𝑠
		
exp(ln(R)+Δ
nomos
	​

−Ω(k))
exp(ln(R)+Δ
cardano
	​

−Ω(k))
	​

	​

=
Re
Δ
nomos
	​

−Ω(k)
Re
Δ
cardano
	​

−Ω(k)
	​

=e
Δ
cardano
	​

−Δ
nomos
	​

	​

	​

So, we have the ratio 
𝑃
(
violate common prefix in cardano
)
𝑃
(
violate common prefix in nomos
=
exp
⁡
(
Δ
𝑐
𝑎
𝑟
𝑑
𝑎
𝑛
𝑜
−
Δ
𝑛
𝑜
𝑚
𝑜
𝑠
)
P(violate common prefix in nomos
P(violate common prefix in cardano)
	​

=exp(Δ
cardano
	​

−Δ
nomos
	​

). Plotting this for 
Δ
𝑐
𝑎
𝑟
𝑑
𝑎
𝑛
𝑜
=
5
Δ
cardano
	​

=5 against different network delays in Nomos gives this plot:
My interpretation of this result is that this probability 
exp
⁡
(
ln
⁡
(
𝑅
)
+
Δ
−
Ω
(
𝑘
)
)
exp(ln(R)+Δ−Ω(k)) is a very loose upper bound. e.g. reducing network delay by 1s leads to a ~2.7x lower probability, and adding 1 second of delay leads again to a 2.7x higher probability, it’s too sensitive to make useful interpretations.
Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Block Times & Blend Network
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Block Times & Blend Network
Authors: David Rusu <davidrusu@logos.co>
Revision History
Table
Introduction
We are interested in finalizing the Cryptarchia and Blend Network parameters. There are some competing requirements here: the Blend Network would like to have longer block times in order to provide better privacy, while Cryptarchia wants shorter block times in order to provide faster finality.
We need to find the right balance that would give us good enough privacy while not sacrificing finality times too much.
Overview
Adversary Model
The analysis centres on the block-witholding attack where an adversary does not participate in the main chain, instead building a secret side-chain and releasing it on the network in an attempt to trigger the honest chain to reorg.
Network Model
blend_network = NetworkParams(
    broadcast_delay_mean=0.5, # seconds
    pol_proof_time=1, # 1 second PoL delay
    blending_delay=3, # seconds spent in each Blend node
    desimenation_delay_mean=0.5, # seconds to disseminate message within Blend
    blend_hops=3, # hops within Blend
)
no_blend_net = replace(blend_net, blend_hops=0)
The block delay distribution from the network model looks like this:
Choosing a Block Time
PATHS = 5
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
network = blend_net
sim_params = Params(
    SLOTS=0,
    f=0.05,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=replace(
        sim_params,
        SLOTS=int(target_block_num * block_time),
        f=1/block_time
    ),
    network=network
) for block_time in np.array([15, 30, 60, 120]).repeat(PATHS)]
Choosing Blend Parameters
There are two parameters that are of concern here: Number of Hops and the Blending Delay.
The number of hops tells us how many times the block proposal needs to be processed by the network before the proposal is broadcast to the wider network.
The Blending delay tells us the maximum time each message is processed at each hop.
Number of Hops
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blend_hops=hops)
) for hops in np.array([1, 2, 3]).repeat(PATHS)]
From these plots we can see that going above 3 hops begins to induce too many reorgs.
Blending Delay
PATHS = 3
target_block_num = 20000
np.random.seed(0)
stake = np.random.pareto(10, 1000)
block_time = 30
sim_params = Params(
    SLOTS=int(target_block_num * block_time),
    f=1/block_time,
    adversary_control = 0.30,
    honest_stake = stake
)
np.random.seed(1)
sims = [Sim(
    params=sim_params,
    network=replace(blend_net, blending_delay=delay)
) for delay in np.array([3, 5, 10]).repeat(PATHS)]
A blending delay above 3 seconds induces too many reorgs.
Impact of Combinations of Hops and Delays
Checking parameters in combinations shows that again, going above 3 hops or above a 3 second delay leads to divergence from the Cardano baseline.
Powerful Adversaries
With 3 hops and 3 second delays, it’s interesting too look at how the network would behave under different strength adversaries.
10% Adversary
Params
30% Adversary
35s block times, 3s blending delay
Params
40% Adversary
Params
45% Adversary
Params
49% Adversary
Params
Conclusion
Our conclusion is that 30s block times, 3 blend hops, 2s blending delay are safe and we propose we use this parameter set for Nomos.
Annex
Exploring Analytical Results from Praos
Praos provides the following theorem about the probability of violating the common prefix property:
In addition to simulations, we could try to use this analytical results to determine the impact of changing block times and network assumptions.
Theorem Condition
First we must satisfy the condition 
Σ
Equation
 where
Σ
Equation
 is the stake held by honest parties
Σ
Equation
 is the active slot coefficient
Σ
Equation
 is the max network delay
Σ
Equation
 is the advantage of the honest network over the adversarial network
We want to understand for a given parameter set, what is the required honest stake 
Σ
Equation
 to satisfy the safety condition:
📈
Equation
We can then look at the minimum 
Σ
Equation
 that satisfies this condition for Cardano and Nomos.
Surprisingly, at at 5s max network delay, we are already requiring ~70% of stake to be honest in Cardano.
On Nomos, based on the network modelling we had done, we had a ~14s max delay. This would require 83% of the network to be honest in order to satisfy this condition.
If we change our blending delay to 2s, then we have a ~11s max delay. This would require 75% of the network to be honest in order to satisfy this condition.
Probability of Violating Common Prefix
The main result of the theorem states that the probability of violating common prefix is bounded above by 
Σ
Equation
, where 
Σ
Equation
 is asymptotic notation reflecting a term that grows at least as fast as 
Σ
Equation
.
We can ask the question “how does the probability change if we change our parameters from Cardano’s to Nomos’?”
We don’t know the 
Σ
Equation
 term, but we can get the relative change by dividing the Cardano probability by the Nomos probability, and cancel out the 
Σ
Equation
 term:
📈
Equation
So, we have the ratio 
Σ
Equation
. Plotting this for 
Σ
Equation
 against different network delays in Nomos gives this plot:
My interpretation of this result is that this probability 
Σ
Equation
 is a very loose upper bound. e.g. reducing network delay by 1s leads to a ~2.7x lower probability, and adding 1 second of delay leads again to a 2.7x higher probability, it’s too sensitive to make useful interpretations.
Open in new tab
