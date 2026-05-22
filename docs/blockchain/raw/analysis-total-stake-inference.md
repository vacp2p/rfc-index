# ANALYSISTOTAL-STAKE-INFERENCE

| Field | Value |
| --- | --- |
| Name | [Analysis] Total Stake Inference |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Alexander Mozeika <alexander.mozeika@logos.co>, Daniel Kashepava <danielkashepava@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: David Rusu <davidrusu@logos.co>, Alexander Mozeika <alexander.mozeika@logos.co>, Daniel Kashepava <danielkashepava@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2026-04-09
Introduction
Cryptarchia consensus leadership is determined by a lottery in which the chances of winning are higher for eligible nodes with a greater stake relative to the total active stake. At the same time, the true total active stake cannot be known by participants due to the privacy properties of Logos Blockchain notes. This tension is resolved in Cryptarchia by having the network estimate the total active stake based on the observed activity of the network.
Goals
The Cryptarchia total stake inference algorithm must satisfy the following criteria:
The inference process converges quickly, yielding a mean estimate that closely matches the true total stake. However, mean accuracy alone is not sufficient—if the estimator’s variance remains high at steady state, block production rates may fluctuate significantly. Thus, effective total stake inference requires both rapid, accurate mean convergence and low variance to ensure stable, predictable block production throughout the protocol.
The process can be approximated well enough with the information we have in Cryptarchia.
Overview
This document provides an analysis of the Cryptarchia total stake inference algorithm based on the following criteria:
Accuracy: The closeness of the mean inferred total stake to the true total stake; it measures systematic bias in the estimator.
Precision: The degree to which repeated inferences yield similar results at equilibrium; it is quantified by the variance of the estimator and reflects how tightly values cluster around the mean, independent of accuracy.
Stability Conditions: The range of possible values for the learning rate 
𝛽
β that result in the stake inference values converging to the true total stake under stable conditions.
Convergence Speed: The bounds under which the total stake inference values converge exponentially to the true total stake under stable conditions. This analysis also includes an optimal value for 
𝛽
β.
Total Stake Inference Process
The inference algorithm is described in 🔀
[1.0.0] Total Stake Inference - Algorithm. In order to analyze the properties of this algorithm, we model it analytically as the following sequence 
{
𝐷
ℓ
}
ℓ
=
0
∞
{D
ℓ
	​

}
ℓ=0
∞
	​

. We then verify that this model aligns with the algorithm to ensure that the analysis accurately reflects the actual process. 
𝐷
ℓ
+
1
=
𝐷
ℓ
−
𝛽
𝑓
𝐷
ℓ
[
𝑓
−
∑
𝑡
=
1
𝑇
1
[
∑
𝑖
=
1
𝑁
𝑠
𝑖
ℓ
(
𝑡
)
≥
1
]
−
𝑛
(
ℓ
)
𝑇
]
D
ℓ+1
	​

=D
ℓ
	​

−
f
β
	​

D
ℓ
	​

	​

f−
T
∑
t=1
T
	​

1[∑
i=1
N
	​

s
i
ℓ
	​

(t)≥1]−n(ℓ)
	​

	​

where, 
𝐷
ℓ
D
ℓ
	​

 is the inferred total stake at epoch 
ℓ
ℓ; 
𝛽
β is the learning rate which governs how quickly we adjust our estimate to new information; 
𝑓
f is the target slot occupancy rate; 
𝑇
T is the observation period in which we observe the slot occupancy rate; 
1
[
𝑝
]
1[p] is the indicator function resolving to 
1
1 if 
𝑝
p is true, 
0
0 otherwise; 
𝑁
N is the number of nodes in the system; 
𝑠
𝑖
ℓ
(
𝑡
)
∈
{
0
,
1
}
s
i
ℓ
	​

(t)∈{0,1} is the lottery result of node 
𝑖
i at slot 
𝑡
t, in epoch 
ℓ
ℓ; here, 1 signals a win, and 0 signals a loss; 
𝑛
(
ℓ
)
∈
{
0
,
1
,
.
.
.
,
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
ℓ
(
𝑡
)
)
≥
1
]
}
n(ℓ)∈{0,1,...,∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
ℓ
	​

(t))≥1]} is the number of slots in epoch 
ℓ
ℓ that could have extended the honest chain but instead were wasted on orphaned blocks. 
We note that the form above captures how the protocol updates its estimate of the total active stake based on observed network activity, and the actual inference process is described at: 🔀
[1.0.0] Total Stake Inference - Algorithm. Specifically, at each epoch 
ℓ
ℓ, the estimate 
𝐷
ℓ
D
ℓ
	​

 is adjusted according to the difference between the target slot occupancy rate 
𝑓
f and the observed average fraction of slots with at least one block extending the honest chain (after accounting for wasted slots, 
𝑛
(
ℓ
)
n(ℓ)). The learning rate 
𝛽
β and normalization by 
𝑓
f control how aggressively the estimate is updated.
Analysis
Accuracy
The process converges to the following value:
𝐸
[
𝐷
∞
]
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⋅
𝐷
TRUE
E[D
∞
	​

]=
log(1−f/q)
log(1−f)
	​

⋅D
TRUE
	​

where, 
𝐸
[
𝐷
∞
]
E[D
∞
	​

] is the mean fixed point of the inference process; 
𝐷
TRUE
D
TRUE
	​

 is the true total stake active during the consensus protocol execution; 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1] is the honest slot utilization rate representing the rate of occupied slots contributing to the honest chain growth.
We note that for 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1], we have that 
log
⁡
(
1
−
𝑓
)
/
log
⁡
(
1
−
𝑓
/
𝑞
)
≤
1
log(1−f)/log(1−f/q)≤1. This suggests that increased network delay, which reduces the honest slot utilization rate through wasted blocks results in a systematic underestimate of true total stake.
For a derivation of this result, please see 
Accuracy Derivation.
Measuring 
𝑞
q from simulations
In simulation, we can derive the value 
𝑞
q by measuring how many of the active slots contributed towards the honest chain with this formula: 
𝑞
=
total_honest_chain_slots
total_active_slots
q=
total_active_slots
total_honest_chain_slots
	​

Since 
𝑞
q varies by epoch and is impacted by the total stake inference process, measurements should be taken after the system converges to a steady state. From simulations, this tends to be after 5 epochs.
Measured 
𝑞
q value for each epoch under different network delays. 
𝑞
q typically converges after a few epochs for reasonable networks.

𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑁
=
100
,
𝛽
=
1
f=1/30,T=6k/f,N=100,β=1​
Simulation Results
This result predicts that we consistently underestimate true stake by a factor of 
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
log(1−f/q)
log(1−f)
	​

. We verified this prediction in simulations and saw a strong correlation between this prediction and the stake we inferred in simulation:
The percent of total stake that we converged to under varying honest slot utilization rates 
𝑞
q. The model provides a very accurate prediction of the behaviour in simulation. Here, 
𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑘
=
2160
,
𝛽
=
1
f=1/30,T=6k/f,k=2160,β=1.
Connecting Simulation to Logos Blockchain
With our choice of Blend Network parameters, we measured a 
𝑞
q value of 0.85 in simulation, plugging that into our model gives 
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
≈
0.847
log(1−f/q)
log(1−f)
	​

≈0.847. That is, if the Blend Network behaves like our simulation, we expect to infer a total stake that is ~84.7% of the true total stake, or ~15% below true total stake. This loss in accuracy is due to not being able to count blocks off the honest branch.
Precision
The variance at equilibrium is given by
V
a
r
[
𝐷
∞
𝐷
TRUE
]
=
(
𝛽
𝑓
)
2
𝑞
𝑇
(
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
)
2
(
1
−
𝑓
)
𝑓
Var[
D
TRUE
	​

D
∞
	​

	​

]=(
f
β
	​

)
2
T
q
	​

(
log(1−f/q)
log(1−f)
	​

)
2
(1−f)f
Furthermore, because of 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1] and  
log
⁡
(
1
−
𝑓
)
/
log
⁡
(
1
−
𝑓
/
𝑞
)
≤
1
log(1−f)/log(1−f/q)≤1, the variance is bounded above by:
V
a
r
[
𝐷
∞
𝐷
TRUE
]
≤
(
𝛽
/
𝑓
)
2
𝑇
(
1
−
𝑓
)
𝑓
Var[
D
TRUE
	​

D
∞
	​

	​

]≤
T
(β/f)
2
	​

(1−f)f
The implication is that wasted blocks caused by network delays have a stabilizing effect on the inference process. As the network delay grows, the variance in our estimate decreases.
For a derivation of this result, see 
Precision Derivation.
Simulation Results
Checking these predictions in simulations shows very good agreement with analysis:
Here we measure the variance of the inferred total stake after the process has converged. We observe low variance across a wide spectrum of 
𝛽
β values suggesting that our epoch lengths are long enough to give us a sufficiently precise measurement of total stake for any reasonable learning rate. We see strong agreement with predictions from analysis.
We note that 
𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑘
=
2160
f=1/30,T=6k/f,k=2160 and 
𝑞
q is measured as described in 
Measuring $q$ from simulations .
Stability Condition
The inference process is stable for 
𝛽
β values that satisfy the following condition
𝛽
<
2
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
β<
(q−f)log(
1−f/q
1
	​

)
2f
	​

where 
𝑞
q is the honest slot utilization rate as mentioned above.
Note that for 
𝑞
=
1
q=1 (perfect network, all active slots are used by the honest chain), we have a lower bound on the stability condition, meaning we can tolerate a higher learning rate 
𝛽
β and converge faster when the network is inefficient:
2
𝑓
(
1
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
)
≤
2
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
(1−f)log(
1−f
1
	​

)
2f
	​

≤
(q−f)log(
1−f/q
1
	​

)
2f
	​

For a derivation of this result, see 
Stability Condition Derivation.
Simulation Results
In simulations, we see that when we exceed the condition, the spread in 
𝐷
∞
D
∞
	​

 values explodes for 
𝛽
≥
2
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
β≥
(q−f)log(
1−f/q
1
	​

)
2f
	​

.
The plot shows the spread of values observed over 45 epochs after the process has been given sufficient time to converge. We observe that we have high precision when 
𝛽
β is comfortably within the stability condition range and grows rapidly outside of the range. Red line signals the boundary of the convergence condition (
𝛽
=
2
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
β=
(q−f)log(
1−f/q
1
	​

)
2f
	​

).
Here, 
𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑘
=
2160
f=1/30,T=6k/f,k=2160 and 
𝑞
q is measured as described in 
Measuring $q$ from simulations.
Convergence Speed and Optimal Learning Rate
The process converges exponentially with the following bound:
∣
𝐸
[
𝐷
ℓ
]
−
𝐸
[
𝐷
∞
]
𝐷
TRUE
∣
≤
𝐴
 
∣
𝐷
0
−
𝐸
[
𝐷
∞
]
𝐷
TRUE
∣
×
∣
1
−
𝛽
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
∣
ℓ
	​

D
TRUE
	​

E[D
ℓ
	​

]−E[D
∞
	​

]
	​

	​

≤A
	​

D
TRUE
	​

D
0
	​

−E[D
∞
	​

]
	​

	​

×
	​

1−
f
β
	​

(q−f)log(
1−f/q
1
	​

)
	​

ℓ
That is, for some constant 
𝐴
>
0
A>0, at epoch 
ℓ
ℓ, the distance between the value for the total stake 
𝐷
ℓ
D
ℓ
	​

 and the equilibrium estimate 
𝐷
∞
D
∞
	​

 falls exponentially. Moreover, this result predicts an optimal convergence rate
𝛽
=
𝑓
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
𝑞
)
β=
(q−f)log(
1−
q
f
	​

1
	​

)
f
	​

For reasonable 
𝑞
q values, this gives us a 
𝛽
β slightly higher than 1. Choosing a smaller 
𝛽
β can only improve the stability of the inference algorithm. This fact, combined with the uncertainty in selecting a 
𝑞
q value suggests that we should just select 
𝛽
=
1
β=1 as our learning rate.
Plotting optimal 
𝛽
β under varying 
𝑞
q values shows that 
𝛽
=
1
β=1 is a close enough approximation to the optimal learning rate. Here 
𝑓
=
1
/
30
f=1/30. 
For a derivation of this result, see 
Convergence Speed and Optimal Learning Rate Derivation.
Simulation Results
We verified these results in simulations, showing that the bound holds for varying 
𝛽
β’s.
The plots show the measured normalized error 
∣
⟨
𝐷
ℓ
⟩
−
⟨
𝐷
∞
⟩
𝐷
TRUE
∣
	​

D
TRUE
	​

⟨D
ℓ
	​

⟩−⟨D
∞
	​

⟩
	​

	​

 decreasing as epoch 
ℓ
ℓ increases. Cryptarchia parameters for all plots were 
𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑘
=
2160
,
𝑞
=
0.85
f=1/30,T=6k/f,k=2160,q=0.85. 
Optimal convergence was checked as well showing that with optimal 
𝛽
β, even with massive shocks to total stake, we can converge within 2 epochs.
Plots show the distribution of normalized error 
∣
⟨
𝐷
ℓ
⟩
−
⟨
𝐷
∞
⟩
𝐷
TRUE
∣
	​

D
TRUE
	​

⟨D
ℓ
	​

⟩−⟨D
∞
	​

⟩
	​

	​

 at each epoch 
ℓ
ℓ for the optimal 
𝛽
β parameter under different initial conditions. Cryptarchia parameters for all plots were 
𝑓
=
1
/
30
,
𝑇
=
6
𝑘
/
𝑓
,
𝑘
=
2160
,
𝑞
=
0.85
,
𝛽
=
1
f=1/30,T=6k/f,k=2160,q=0.85,β=1.
Converging to new equilibrium after losing half active stake.
Converging to new equilibrium after doubling active stake.
Details
Accuracy Derivation
The following is the derivation for the property described in 
Accuracy.
The total stake inference equation is given by 
𝐷
ℓ
+
1
=
𝐷
ℓ
−
ℎ
(
ℓ
)
[
𝑓
−
1
𝑇
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
]
,
D
ℓ+1
	​

=D
ℓ
	​

−h(ℓ)[f−
T
1
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]],
where  
ℎ
(
ℓ
)
>
0
h(ℓ)>0 is the learning rate. In the above, we write 
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
s
i
	​

(t)∣D
ℓ
	​

 to emphasise that the random variable 
𝑠
𝑖
(
𝑡
)
s
i
	​

(t) is conditional on 
𝐷
ℓ
D
ℓ
	​

.
In the equation used in inference of total stake, we take 
ℎ
(
ℓ
)
=
𝛽
𝑓
𝐷
ℓ
h(ℓ)=
f
β
	​

D
ℓ
	​

 but the starting point of our analysis uses a more general learning rate 
ℎ
(
ℓ
)
h(ℓ).
We note that 
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1] is the number of active slots, i.e. slots with at least one winner, in the 
ℓ
ℓ-th epoch.
For the outcome of leader election process 
𝑠
(
𝑡
)
=
(
𝑠
1
(
𝑡
)
,
…
,
𝑠
𝑁
(
𝑡
)
)
s(t)=(s
1
	​

(t),…,s
N
	​

(t)) at the time-slot 
𝑡
t, the probability of outcomes 
(
𝑠
(
1
)
,
…
,
𝑠
(
𝑇
)
)
(s(1),…,s(T)) at times 
𝑡
∈
[
𝑇
]
t∈[T] is given by 
P
[
𝑠
(
1
)
,
…
,
𝑠
(
𝑇
)
∣
𝐷
ℓ
]
=
∏
𝑡
=
1
𝑇
∏
𝑖
=
1
𝑁
[
𝜙
𝑓
(
𝑤
𝑖
/
𝐷
ℓ
)
 
𝛿
1
;
𝑠
𝑖
(
𝑡
)
+
(
1
−
𝜙
𝑓
(
𝑤
𝑖
/
𝐷
ℓ
)
)
 
𝛿
0
;
𝑠
𝑖
(
𝑡
)
]
,
P[s(1),…,s(T)∣D
ℓ
	​

]=
t=1
∏
T
	​

i=1
∏
N
	​

[ϕ
f
	​

(w
i
	​

/D
ℓ
	​

)δ
1;s
i
	​

(t)
	​

+(1−ϕ
f
	​

(w
i
	​

/D
ℓ
	​

))δ
0;s
i
	​

(t)
	​

],
where 
𝜙
𝑓
(
𝛼
)
=
1
−
(
1
−
𝑓
)
𝛼
ϕ
f
	​

(α)=1−(1−f)
α
is the probability of winning and 
𝑤
𝑖
w
i
	​

 is the stake of node 
𝑖
i. 
We note that 
𝐷
ℓ
D
ℓ
	​

 is a random variable. 
Node 
𝑖
i uses its (local) copy of the blockchain in the inference of the total stake and the latter can give a different count for the number of active slots  because of a number of slots being “wasted”.
To model this scenario, we introduce variable 
𝑛
(
ℓ
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
∈
{
0
,
1
,
…
,
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
}
n(ℓ)∣∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]∈{0,1,…,∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]}, i.e. 
𝑛
(
ℓ
)
n(ℓ) is conditional on 
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1], such that 
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
−
𝑛
(
ℓ
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]−n(ℓ)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]
is the number of blocks on the chain of an honest node, i.e. the number of “honest” slots. The latter will be used for inference by an honest node as follows 
𝐷
ℓ
+
1
=
𝐷
ℓ
−
ℎ
(
ℓ
)
[
𝑓
−
1
𝑇
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
−
𝑛
(
ℓ
)
}
]
,
D
ℓ+1
	​

=D
ℓ
	​

−h(ℓ)[f−
T
1
	​

{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]−n(ℓ)}],
where in above 
𝑛
(
ℓ
)
≡
𝑛
(
ℓ
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
n(ℓ)≡n(ℓ)∣∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1].
We note that 
𝐷
ℓ
+
1
	
=
𝐷
ℓ
−
ℎ
(
ℓ
)
[
𝑓
−
1
𝑇
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
−
𝑛
(
ℓ
)
}
]


	
≤
𝐷
ℓ
−
ℎ
(
ℓ
)
[
𝑓
−
1
𝑇
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
]
D
ℓ+1
	​

	​

=D
ℓ
	​

−h(ℓ)[f−
T
1
	​

{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]−n(ℓ)}]
≤D
ℓ
	​

−h(ℓ)[f−
T
1
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]]
	​

i.e. for the same 
𝐷
ℓ
D
ℓ
	​

, the 
𝐷
ℓ
+
1
D
ℓ+1
	​

 of the honest node’s equation is bounded above by the 
𝐷
ℓ
+
1
D
ℓ+1
	​

 of the idealised equation. 
Let us assume that 
𝑛
(
ℓ
)
n(ℓ) is a random variable from the binomial distribution with the parameters 
𝑝
(
ℓ
)
p(ℓ) and 
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1]. 
Here 
𝑝
(
ℓ
)
p(ℓ) is the probability that a slot is “wasted” in epoch 
ℓ
ℓ and hence there are (on average) 
𝑝
(
ℓ
)
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
ℓ
)
≥
1
]
p(ℓ)∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
ℓ
	​

)≥1] number of slots wasted in epoch 
ℓ
ℓ. 
We note that the above assumption about 
𝑛
(
ℓ
)
n(ℓ) is mathematically convenient but not necessary true. However it is the simplest non-trivial assumption, and its validity can be tested in simulations. 
We first consider the equation 
𝐷
1
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
1
𝑇
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
−
𝑛
(
0
)
}
]
D
1
	​

=D
0
	​

−h(0)[f−
T
1
	​

{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]−n(0)}]
Averaging above over the random variable 
𝑛
(
0
)
n(0) gives us the equation
𝐷
1
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
1
−
𝑝
(
0
)
𝑇
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
D
1
	​

=D
0
	​

−h(0)[f−
T
1−p(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
Now, let us assume that 
𝐷
0
D
0
	​

 is deterministic and consider the average of 
𝐷
1
D
1
	​

, 
⟨
𝐷
1
⟩
0
⟨D
1
	​

⟩
0
	​

, with respect to the distribution as follows 
⟨
𝐷
1
⟩
0
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
1
−
𝑝
(
0
)
𝑇
∑
𝑡
=
1
𝑇
⟨
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
0
]
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
1
−
𝑝
(
0
)
𝑇
∑
𝑡
=
1
𝑇
⟨
[
1
−
1
 ⁣
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
=
0
]
]
⟩
0
]
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
[
1
−
𝑝
(
0
)
]
[
1
−
(
1
−
𝑓
)
𝐷
0
[
𝑤
]
/
𝐷
0
]
]
⟨D
1
	​

⟩
0
	​

=D
0
	​

−h(0)[f−
T
1−p(0)
	​

t=1
∑
T
	​

⟨1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩
0
	​

]
=D
0
	​

−h(0)[f−
T
1−p(0)
	​

t=1
∑
T
	​

⟨[1−1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)=0]]⟩
0
	​

]
=D
0
	​

−h(0)[f−[1−p(0)][1−(1−f)
D
0
[w]/D
0
	​

]]
Thus using in above the definition we obtain the following equation 
⟨
𝐷
1
⟩
0
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
[
1
−
𝑝
(
0
)
]
𝜙
𝑓
(
𝐷
0
[
𝑤
]
/
𝐷
0
)
]
,
⟨D
1
	​

⟩
0
	​

=D
0
	​

−h(0)[f−[1−p(0)]ϕ
f
	​

(D
0
[w]/D
0
	​

)],
where in above 
𝐷
0
[
𝑤
]
D
0
[w] is the true total stake. 
We note that for 
𝑝
(
0
)
=
0
p(0)=0 we recover the following equation
⟨
𝐷
1
⟩
0
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
𝜙
𝑓
(
𝐷
0
[
𝑤
]
/
𝐷
0
)
]
⟨D
1
	​

⟩
0
	​

=D
0
	​

−h(0)[f−ϕ
f
	​

(D
0
[w]/D
0
	​

)]
Next, we define the normalised inferred stake 
𝐷
‾
ℓ
+
1
=
𝐷
ℓ
+
1
𝐷
0
[
𝑤
]
D
ℓ+1
	​

=
D
0
[w]
D
ℓ+1
	​

	​

, and the average  
⟨
𝐷
‾
ℓ
+
1
⟩
=
⟨
𝐷
‾
ℓ
+
1
⟩
ℓ
⟨
D
ℓ+1
	​

⟩=⟨
D
ℓ+1
	​

⟩
ℓ
	​

, and postulate that the latter satisfies the equation 
⟨
𝐷
‾
ℓ
+
1
⟩
=
⟨
𝐷
‾
ℓ
⟩
−
ℎ
~
(
ℓ
)
[
𝑓
−
𝑞
(
ℓ
)
 
𝜙
𝑓
(
1
/
⟨
𝐷
‾
ℓ
⟩
)
]
,
⟨
D
ℓ+1
	​

⟩=⟨
D
ℓ
	​

⟩−
h
~
(ℓ)[f−q(ℓ)ϕ
f
	​

(1/⟨
D
ℓ
	​

⟩)],
where 
𝑞
(
ℓ
)
=
1
−
𝑝
(
ℓ
)
q(ℓ)=1−p(ℓ), i.e. the probability that a slot is not wasted in epoch 
ℓ
ℓ. 
We note that 
𝑞
(
ℓ
)
 
𝜙
𝑓
(
1
/
⟨
𝐷
‾
ℓ
⟩
)
 
𝑇
q(ℓ)ϕ
f
	​

(1/⟨
D
ℓ
	​

⟩)T is the average number of slots not wasted in epoch 
ℓ
ℓ.
Let us assume that 
𝑞
(
ℓ
)
=
𝑞
q(ℓ)=q, i.e. the probability 
𝑝
(
ℓ
)
p(ℓ) is the same in all epochs, and consider the equation 
⟨
𝐷
‾
ℓ
+
1
⟩
=
⟨
𝐷
‾
ℓ
⟩
−
ℎ
~
(
ℓ
)
[
𝑓
−
𝑞
 
𝜙
𝑓
(
1
/
⟨
𝐷
‾
ℓ
⟩
)
]
⟨
D
ℓ+1
	​

⟩=⟨
D
ℓ
	​

⟩−
h
~
(ℓ)[f−qϕ
f
	​

(1/⟨
D
ℓ
	​

⟩)]
Then 
⟨
𝐷
‾
ℓ
⟩
⟨
D
ℓ
	​

⟩ such that 
𝑓
=
𝑞
 
𝜙
𝑓
(
1
/
⟨
𝐷
‾
ℓ
⟩
)
f=qϕ
f
	​

(1/⟨
D
ℓ
	​

⟩) is the fixed point of the above equation. Solving the latter gives us 
⟨
𝐷
‾
ℓ
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
ℓ
	​

⟩=
log(1−f/q)
log(1−f)
	​

	​

We note that above solution exists for 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1]. The function 
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
log(1−f/q)
log(1−f)
	​

 is monotonic increasing function of 
𝑞
q on the interval 
(
𝑓
,
1
]
(f,1] and hence 
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
≤
1
.
log(1−f/q)
log(1−f)
	​

≤1
	​

.
Precision Derivation
The following is a derivation for the property described in 
Precision.
We consider the equation 
𝐷
1
=
𝐷
0
−
ℎ
(
0
)
[
𝑓
−
1
𝑇
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
−
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
}
]
D
1
	​

=D
0
	​

−h(0)[f−
T
1
	​

{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]−n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]}]
where 
𝑛
(
0
)
n(0) is random variable from the binomial distribution with the parameters 
𝑝
(
0
)
p(0) and 
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
0
	​

)≥1].
The variance of 
𝐷
1
D
1
	​

 is given by 
V
a
r
[
𝐷
1
]
=
  
ℎ
2
(
0
)
𝑇
2
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
−
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
Var[D
1
	​

]=  
T
2
h
2
(0)
	​

Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]−n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
We note that 
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
−
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
=
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
−
2
 
C
o
v
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
,
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
+
V
a
r
[
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]−n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
=Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]−2Cov[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1],n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]+Var[n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
by the identity. 
First, we consider 
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
=
𝑇
(
1
−
𝑓
)
𝑓
Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]=T(1−f)f
Second, we consider 
C
o
v
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
,
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
       
=
⟨
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
 
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
−
⟨
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
⟨
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
=
𝑝
(
0
)
⟨
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
}
2
⟩
−
𝑝
(
0
)
(
𝑇
𝑓
)
2
=
𝑝
(
0
)
[
𝑇
(
1
−
𝑓
)
𝑓
+
(
𝑇
𝑓
)
2
]
−
𝑝
(
0
)
(
𝑇
𝑓
)
2
=
𝑝
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
Cov[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1],n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
       =⟨
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩−⟨
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩⟨n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩
=p(0)⟨{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]}
2
⟩−p(0)(Tf)
2
=p(0)[T(1−f)f+(Tf)
2
]−p(0)(Tf)
2
=p(0)T(1−f)f
Hence 
C
o
v
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
,
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
                                                              
=
𝑝
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
Cov[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1],n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
                                                              =p(0)T(1−f)f
Third, we consider the variance 
V
a
r
[
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
=
⟨
{
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
}
2
⟩
−
⟨
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
2
=
(
1
−
𝑝
(
0
)
)
 
𝑝
(
0
)
⟨
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
+
𝑝
2
(
0
)
⟨
{
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
}
2
⟩
−
𝑝
2
(
0
)
(
𝑇
𝑓
)
2
=
(
1
−
𝑝
(
0
)
)
 
𝑝
(
0
)
𝑇
𝑓
+
𝑝
2
(
0
)
[
𝑇
(
1
−
𝑓
)
𝑓
+
(
𝑇
𝑓
)
2
]
−
𝑝
2
(
0
)
(
𝑇
𝑓
)
2
=
(
1
−
𝑝
(
0
)
)
 
𝑝
(
0
)
𝑇
𝑓
+
𝑝
2
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
=
𝑝
(
0
)
𝑇
𝑓
[
1
−
𝑝
(
0
)
+
𝑝
(
0
)
(
1
−
𝑓
)
]
Var[n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
=⟨{n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]}
2
⟩
−⟨n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩
2
=(1−p(0))p(0)⟨
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩+p
2
(0)⟨{
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]}
2
⟩
−p
2
(0)(Tf)
2
=(1−p(0))p(0)Tf+p
2
(0)[T(1−f)f+(Tf)
2
]
−p
2
(0)(Tf)
2
=(1−p(0))p(0)Tf+p
2
(0)T(1−f)f
=p(0)Tf[1−p(0)+p(0)(1−f)]
Hence 
V
a
r
[
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
                                        
=
𝑝
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
Var[n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
                                        =p(0)T(1−f)f
To obtain above, we used identities described in the Annex and the following results 
⟨
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
=
𝑇
𝑓
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
=
𝑇
(
1
−
𝑓
)
𝑓
⟨
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟩
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
                                                                               
=
𝑝
(
0
)
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
⟨
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩=Tf
Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]=T(1−f)f
⟨n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]⟩
	​

∑
t=1
T
	​

1[(∑
i=1
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]
	​

                                                                               =p(0)
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]
Finally, combining all of the above we obtain the following result 
V
a
r
[
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
−
𝑛
(
0
)
∣
∑
𝑡
=
1
𝑇
1
[
(
∑
𝑖
=
1
𝑁
𝑠
𝑖
(
𝑡
)
∣
𝐷
0
)
≥
1
]
]
=
𝑇
(
1
−
𝑓
)
𝑓
                                    
−
2
 
𝑝
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
                                                    
+
𝑝
(
0
)
𝑇
(
1
−
𝑓
)
𝑓
           
=
𝑞
(
0
)
 
𝑇
(
1
−
𝑓
)
𝑓
,
Var[
t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]−n(0)
	​

t=1
∑
T
	​

1[(
i=1
∑
N
	​

s
i
	​

(t)∣D
0
	​

)≥1]]
=T(1−f)f
                                    −2p(0)T(1−f)f
                                                    +p(0)T(1−f)f
           =q(0)T(1−f)f,
where 
𝑞
(
0
)
=
1
−
𝑝
(
0
)
q(0)=1−p(0).
Thus we obtain 
V
a
r
[
𝐷
1
]
=
  
ℎ
2
(
0
)
𝑇
𝑞
(
0
)
 
(
1
−
𝑓
)
𝑓
.
Var[D
1
	​

]=  
T
h
2
(0)
	​

q(0)(1−f)f.
Based on the above, the variance of the normalised total stake 
𝐷
‾
1
=
𝐷
1
/
𝐷
0
[
𝑤
]
D
1
	​

=D
1
	​

/D
0
[w] is given by
V
a
r
[
𝐷
‾
1
]
	
=
ℎ
2
(
0
)
𝑇
(
𝐷
0
[
𝑤
]
)
2
𝑞
(
0
)
(
1
−
𝑓
)
𝑓
.
Var[
D
1
	​

]
	​

=
T(D
0
[w])
2
h
2
(0)
	​

q(0)(1−f)f
	​

.
Now, for 
ℎ
(
0
)
=
ℎ
 
𝐷
0
h(0)=hD
0
	​

, where 
ℎ
>
0
h>0,  we obtain
V
a
r
[
𝐷
‾
1
]
	
=
ℎ
2
 
𝐷
‾
0
2
𝑇
𝑞
(
0
)
(
1
−
𝑓
)
𝑓
.
Var[
D
1
	​

]
	​

=
T
h
2
D
0
2
	​

	​

q(0)(1−f)f
	​

.
Furthermore, if we assume that above is true for all 
ℓ
ℓ, i.e.
V
a
r
[
𝐷
‾
ℓ
+
1
]
=
ℎ
2
𝑞
(
ℓ
)
𝑇
⟨
𝐷
‾
ℓ
⟩
2
(
1
−
𝑓
)
𝑓
,
Var[
D
ℓ+1
	​

]=
T
h
2
q(ℓ)
	​

⟨
D
ℓ
	​

⟩
2
(1−f)f,
where 
𝑞
(
ℓ
)
=
1
−
𝑝
(
ℓ
)
q(ℓ)=1−p(ℓ).  For 
𝑞
(
ℓ
)
=
𝑞
q(ℓ)=q and 
ℓ
→
∞
ℓ→∞ we have 
⟨
𝐷
‾
∞
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
∞
	​

⟩=
log(1−f/q)
log(1−f)
	​

 and hence 
V
a
r
[
𝐷
‾
∞
]
=
ℎ
2
𝑞
𝑇
(
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
)
2
(
1
−
𝑓
)
𝑓
Var[
D
∞
	​

]=
T
h
2
q
	​

(
log(1−f/q)
log(1−f)
	​

)
2
(1−f)f
	​

We note that for 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1] we have 
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
≤
1
log(1−f/q)
log(1−f)
	​

≤1 and from the latter follows
ℎ
2
𝑞
𝑇
(
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
)
2
(
1
−
𝑓
)
𝑓
≤
ℎ
2
𝑇
(
1
−
𝑓
)
𝑓
.
T
h
2
q
	​

(
log(1−f/q)
log(1−f)
	​

)
2
(1−f)f≤
T
h
2
	​

(1−f)f.
Thus assuming that the equation is correct, we have shown that 
V
a
r
[
𝐷
‾
∞
]
≤
ℎ
2
𝑇
(
1
−
𝑓
)
𝑓
,
Var[
D
∞
	​

]≤
T
h
2
	​

(1−f)f
	​

,
i.e. the variance for 
𝑞
≤
1
q≤1 is bounded from above by the variance for 
𝑞
=
1
q=1.
Stability Condition Derivation
The following is a derivation for the property described in 
Stability Condition.
Let us assume that 
ℎ
~
(
ℓ
)
=
ℎ
⟨
𝐷
‾
ℓ
⟩
h
~
(ℓ)=h⟨
D
ℓ
	​

⟩ and consider the equation for 
⟨
𝐷
‾
ℓ
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
+
𝜖
(
ℓ
)
⟨
D
ℓ
	​

⟩=
log(1−f/q)
log(1−f)
	​

+ϵ(ℓ), where 
∣
𝜖
(
ℓ
)
∣
≪
1
∣ϵ(ℓ)∣≪1, as follows 
𝜖
(
ℓ
+
1
)
=
𝜖
(
ℓ
)
−
ℎ
[
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
+
𝜖
(
ℓ
)
]
[
𝑓
−
𝑞
[
1
−
(
1
−
𝑓
)
1
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
+
𝜖
(
ℓ
)
]
]
=
[
1
−
ℎ
(
𝑓
−
𝑞
)
log
⁡
 ⁣
(
𝑞
−
𝑓
𝑞
)
]
𝜖
(
ℓ
)
+
𝑂
(
𝜖
2
(
ℓ
)
)
.
ϵ(ℓ+1)=ϵ(ℓ)−h[
log(1−f/q)
log(1−f)
	​

+ϵ(ℓ)][f−q[1−(1−f)
log(1−f/q)
log(1−f)
	​

+ϵ(ℓ)
1
	​

]]
=[1−h(f−q)log(
q
q−f
	​

)]ϵ(ℓ)+O(ϵ
2
(ℓ)).
The above suggests that the solution 
⟨
𝐷
‾
ℓ
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
ℓ
	​

⟩=
log(1−f/q)
log(1−f)
	​

is stable when 
∣
1
−
ℎ
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
∣
<
1.
	​

1−h(q−f)log(
1−f/q
1
	​

)
	​

<1.
We note that above is equivalent to 
0
<
ℎ
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
<
2.
0<h(q−f)log(
1−f/q
1
	​

)<2.
Thus the solution 
⟨
𝐷
‾
ℓ
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
ℓ
	​

⟩=
log(1−f/q)
log(1−f)
	​

 is stable for 
ℎ
<
2
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
.
h<
(q−f)log(
1−f/q
1
	​

)
2
	​

	​

.
Furthermore, 
2
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
(q−f)log(
1−f/q
1
	​

)
2
	​

 is a monotonic decreasing function of 
𝑞
∈
(
0
,
1
]
q∈(0,1] and hence 
2
(
1
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
)
≤
2
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
,
(1−f)log(
1−f
1
	​

)
2
	​

≤
(q−f)log(
1−f/q
1
	​

)
2
	​

,
i.e. the equation is stable for larger values of the learning rate 
ℎ
h when 
𝑞
<
1
q<1.
Convergence Speed and Optimal Learning Rate Derivation
The following is a derivation for the properties described in 
Convergence Speed and Optimal Learning Rate.
Applying Corollary 2.1 to the equation with 
ℎ
~
(
ℓ
)
=
ℎ
⟨
𝐷
‾
ℓ
⟩
h
~
(ℓ)=h⟨
D
ℓ
	​

⟩ we obtain 
∣
⟨
𝐷
‾
ℓ
⟩
−
⟨
𝐷
‾
∞
⟩
∣
≤
𝐴
 
∣
𝐷
‾
0
−
⟨
𝐷
‾
∞
⟩
∣
×
∣
1
−
ℎ
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
∣
ℓ
∣⟨
D
ℓ
	​

⟩−⟨
D
∞
	​

⟩∣≤A∣
D
0
	​

−⟨
D
∞
	​

⟩∣×
	​

1−h(q−f)log(
1−f/q
1
	​

)
	​

ℓ
	​

where 
⟨
𝐷
‾
∞
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
∞
	​

⟩=
log(1−f/q)
log(1−f)
	​

, for some constant 
𝐴
>
0
A>0. 
We note that for the learning rate  
ℎ
=
ℎ
0
h=h
0
	​

, where 
ℎ
0
=
1
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
𝑞
)
h
0
	​

=
(q−f)log(
1−
q
f
	​

1
	​

)
1
	​

the base function 
∣
1
−
ℎ
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
/
𝑞
)
∣
	​

1−h(q−f)log(
1−f/q
1
	​

)
	​

 is exactly zero suggesting that 
∣
⟨
𝐷
‾
ℓ
⟩
−
⟨
𝐷
‾
∞
⟩
∣
=
0
∣⟨
D
ℓ
	​

⟩−⟨
D
∞
	​

⟩∣=0 for any 
ℓ
ℓ  at 
ℎ
=
ℎ
0
h=h
0
	​

.  The latter is not possible and hence the bound, which assumes that the first order derivative of the map exists, can not be applied when 
ℎ
=
ℎ
0
h=h
0
	​

. 
However, for any 
∣
𝛿
∣
>
0
∣δ∣>0 and learning rate 
ℎ
=
ℎ
0
(
1
+
𝛿
)
h=h
0
	​

(1+δ) the bound can be used and the speed of convergence is 
∝
∣
𝛿
∣
ℓ
∝∣δ∣
ℓ
.
What happens when 
ℎ
=
ℎ
0
h=h
0
	​

? Considering the equation for 
ℎ
=
ℎ
0
h=h
0
	​

, the latter gives us  
𝜖
(
ℓ
+
1
)
=
log
⁡
 ⁣
(
1
−
𝑓
𝑞
)
2
2
log
⁡
 ⁣
(
1
−
𝑓
)
𝜖
2
(
ℓ
)
+
𝑂
(
𝜖
3
(
ℓ
)
)
.
ϵ(ℓ+1)=
2log(1−f)
log(1−
q
f
	​

)
2
	​

ϵ
2
(ℓ)+O(ϵ
3
(ℓ)).
Ignoring the higher order terms in above and solving 
𝜖
(
ℓ
+
1
)
=
𝐴
(
𝑞
,
𝑓
)
𝜖
2
(
ℓ
)
ϵ(ℓ+1)=A(q,f)ϵ
2
(ℓ), where 
𝐴
(
𝑞
,
𝑓
)
=
log
⁡
 ⁣
(
1
−
𝑓
𝑞
)
2
2
log
⁡
 ⁣
(
1
−
𝑓
)
A(q,f)=
2log(1−f)
log(1−
q
f
	​

)
2
	​

, for some initial 
𝜖
(
0
)
ϵ(0)  gives us the equation 
𝜖
(
ℓ
)
=
1
𝐴
(
𝑞
,
𝑓
)
[
𝐴
(
𝑞
,
𝑓
)
 
𝜖
(
0
)
]
2
ℓ
ϵ(ℓ)=
A(q,f)
1
	​

[A(q,f)ϵ(0)]
2
ℓ
	​

We note that for 
∣
𝐴
(
𝑞
,
𝑓
)
 
𝜖
(
0
)
∣
<
1
∣A(q,f)ϵ(0)∣<1 the  
𝜖
(
ℓ
)
→
0
−
ϵ(ℓ)→0
−
 is doubly-exponential  as 
ℓ
→
∞
ℓ→∞.  
Thus locally, i.e. for  
⟨
𝐷
‾
ℓ
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
+
𝜖
(
ℓ
)
⟨
D
ℓ
	​

⟩=
log(1−f/q)
log(1−f)
	​

+ϵ(ℓ) with 
∣
𝜖
(
ℓ
)
∣
≪
1
∣ϵ(ℓ)∣≪1, the speed of convergence to 
⟨
𝐷
‾
∞
⟩
=
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
⟨
D
∞
	​

⟩=
log(1−f/q)
log(1−f)
	​

 is doubly-exponential. The latter suggests that for 
𝑞
∈
(
𝑓
,
1
]
q∈(f,1] the learning rate 
ℎ
=
1
(
𝑞
−
𝑓
)
log
⁡
 ⁣
(
1
1
−
𝑓
𝑞
)
h=
(q−f)log(
1−
q
f
	​

1
	​

)
1
	​

	​

is optimal. 
The double exponential form dominates convergence to the fixed point 
⟨
𝐷
‾
∞
⟩
⟨
D
∞
	​

⟩ for small 
𝜖
(
0
)
=
𝐷
‾
0
−
⟨
𝐷
‾
∞
⟩
ϵ(0)=
D
0
	​

−⟨
D
∞
	​

⟩ as can be seen in the figures below 
The difference between average (normalised) stake at epoch 
ℓ
ℓ and its equilibrium value 
𝜖
(
ℓ
)
=
⟨
𝐷
‾
ℓ
⟩
−
log
⁡
(
1
−
𝑓
)
log
⁡
(
1
−
𝑓
/
𝑞
)
ϵ(ℓ)=⟨
D
ℓ
	​

⟩−
log(1−f/q)
log(1−f)
	​

 plotted as a function of 
ℓ
ℓ for 
𝑓
=
1
/
30
f=1/30 and 
𝑞
=
0.85
q=0.85. The solid (red) line is  the solution of the difference equation using optimal learning rate and the dashed (blue) line is the double exponential. Here for 
log
⁡
(
1
−
𝑓
)
/
log
⁡
(
1
−
𝑓
/
𝑞
)
≈
0.847
log(1−f)/log(1−f/q)≈0.847 and  
𝜖
(
0
)
∈
{
2
×
0.847
,
0.847
/
2
,
0.847
/
10
,
0.847
/
100
}
ϵ(0)∈{2×0.847,0.847/2,0.847/10,0.847/100} (top left, top right, bottom left, bottom right) the 
𝜖
(
1
)
ϵ(1) is, respectively, of order 
{
10
−
2
,
10
−
3
,
10
−
4
,
10
−
6
}
{10
−2
,10
−3
,10
−4
,10
−6
}. 
Annex
Why Use Total Active Stake instead of Total Supply
Loading...
