# ANALYSISCRYPTARCHIA-DEANONYMISATION-OF-RELATIVE-STAKE

| Field | Value |
| --- | --- |
| Name | [Analysis] Cryptarchia De-anonymisation of Relative Stake |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Alexander Mozeika <alexander.mozeika@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: David Rusu <davidrusu@logos.co>, Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-08-26
Details of derivations are in the documents Statistical inference of relative stake and Analysis of leader election process in PoS.
Stake Distribution Strategies Based on Adversarial Inference Which Uses a Naive Estimator
The adversary observes the leader election process of a node with the relative stake 
𝛼
α.  
In 
𝑇
T time slots, he/she is able to observe 
𝑛
n wins in 
𝑚
m observations.  
For 
𝑚
≥
1
m≥1  he/she uses the naive estimator 
𝛼
^
=
log
⁡
(
1
−
𝑛
/
𝑚
)
log
⁡
(
1
−
𝑓
)
α
^
=
log(1−f)
log(1−n/m)
	​

 of the true relative stake 
𝛼
α. 
Here 
𝑓
f, known to adversary, is the fraction of time-slots with at least one winner.
For “accuracy” 
𝛾
∈
(
0
,
1
)
γ∈(0,1), the probability that 
𝛼
(
1
−
𝛾
)
≤
𝛼
^
≤
𝛼
(
1
+
𝛾
)
α(1−γ)≤
α
^
≤α(1+γ) for large 
𝑇
T is given by 
P
(
𝛼
^
∈
[
𝛼
(
1
−
𝛾
)
,
𝛼
(
1
+
𝛾
)
]
)
=
2
 
e
r
f
 ⁣
(
𝜖
2
𝜎
2
(
𝑞
)
)
e
r
f
 ⁣
(
𝑠
2
𝜎
2
(
𝑞
)
)
+
e
r
f
 ⁣
(
1
−
𝑠
2
𝜎
2
(
𝑞
)
)
,
P(
α
^
∈[α(1−γ),α(1+γ)])=
erf(
2σ
2
(q)
	​

s
	​

)+erf(
2σ
2
(q)
	​

1−s
	​

)
2erf(
2σ
2
(q)
	​

ϵ
	​

)
	​

, where 
𝑠
≡
𝜙
(
𝛼
)
s≡ϕ(α) is the lottery function, 
𝜖
=
𝛾
𝛼
d
d
𝛼
𝜙
(
𝛼
)
ϵ=γα
dα
d
	​

ϕ(α) and 
𝜎
2
(
𝑞
)
=
𝑠
(
1
−
𝑠
)
/
𝑇
𝑞
σ
2
(q)=s(1−s)/Tq. Here 
𝑞
q is the fraction of observed time-slots such that 
𝑇
𝑞
Tq slots are observed on average.  
An example of above probability is given below.
The probability  that inferred relative stake 
𝛼
^
∈
[
𝛼
(
1
−
𝛾
)
,
𝛼
(
1
+
𝛾
)
]
α
^
∈[α(1−γ),α(1+γ)], i.e. adversarial “confidence”,  as a function of the true relative stake 
𝛼
α obtained in 
𝑇
=
432000
T=432000 time-slots (the number used in Cardano) when fraction 
𝑞
=
0.657
q=0.657 of slots is observed. Here the probability that the stake of a node with the true stake 
𝛼
=
0.0126
α=0.0126 (the max. stake in the Bitcoin network), represented by a red vertical line, is inferred  with an “accuracy” within the fraction 
𝛾
=
0.1
γ=0.1 of relative stake 
𝛼
α, represented by 
𝛼
(
1
±
𝛾
)
α(1±γ) red vertical dotted lines, is approx. 
0.824
0.824.  The red dashed horizontal line corresponds to the threshold 
𝜃
=
0.5
θ=0.5. The blue vertical line at 
𝛼
=
0.00252
α=0.00252 is the result of dividing the stake 
𝛼
=
0.0126
α=0.0126 into 
5
5 nodes.  
Having estimated the fraction of observed time-slots 
𝑞
q and accuracy 
𝛾
γ a node can use its stake 
𝛼
α, to compute the probability 
𝛿
(
𝛼
)
=
P
(
𝛼
^
∈
[
𝛼
(
1
−
𝛾
)
,
𝛼
(
1
+
𝛾
)
]
)
δ(α)=P(
α
^
∈[α(1−γ),α(1+γ)]), i.e. the “confidence”  obtained by an adversary in 
𝑇
T time-slots.  For a node, it is beneficial to reduce the latter, which can be done by distributing its stake among a number of nodes. To this end, the probability 
𝛿
(
𝛼
)
δ(α) is compared with some threshold 
𝜃
θ and if 
𝛿
(
𝛼
)
≥
𝜃
δ(α)≥θ then the stake is divided, i.e. 
𝛼
←
𝛼
/
2
α←α/2, 
𝛼
←
𝛼
/
3
α←α/3, etc., until 
𝛿
(
𝛼
)
<
𝜃
δ(α)<θ. 
The main functions of the algorithm which uses 
𝛿
(
𝛼
)
δ(α) to distribute the stake are as follows:
from math import erf, sqrt, log

def phi(alpha):
    global f
    return 1 - (1 - f)**alpha

def dphi(alpha):
    global f
    return -((1 - f)**alpha) * log(1 - f)

def Prob2(alpha, epsilon, T, q):    
    sqrt2 = sqrt(2.0)
    numerator = -2.0 * erf(sqrt2 * epsilon / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q))))
    denominator = (-erf(phi(alpha) * sqrt2 / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))) + erf(sqrt2 * (phi(alpha) - 1) / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))))
    return numerator / denominator

​
The above functions are then used to find minimum number of nodes such that distributing the stake into these nodes reduces the probability 
𝛿
(
𝛼
)
δ(α) to 
𝜃
θ as follows 
import math

# Define parameters
T = 432000  # number of time-slots in one epoch
theta = 0.5  # adversarial confidence threshold
gamma0 = 0.1  # adversarial accuracy
a = 0.3  # fraction of compromised paths in the mixnet
r = 3  # redundancy in messages sent through the mixnet
q0 = 1 - (1 - a)**r  # fraction of compromised messages
f = 0.05
n_max = 10  # maximum number of iterations
alpha0 = 0.0126 #initial stake 

# Initialize relative stake alpha and delta
alpha = alpha0
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)

# Loop until delta <= theta or n reaches n_max
n = 2
while delta > theta and n <= n_max:
    alpha = alpha0 / n
    epsilon = dphi(alpha) * alpha * gamma0
    delta = Prob2(alpha, epsilon, T, q0)
    n += 1

# Update alpha and Prob
alpha = alpha0 / (n - 1)
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)

print("Final num. of nodes:", n-1)
print("Final alpha:", alpha)
print("Final Prob:", delta)


​
The above program suggests that the stake 
𝛼
=
0.0126
α=0.0126 has to be divided among 5 nodes for the adversarial confidence 
𝛿
(
𝛼
)
<
0.5
δ(α)<0.5 when 
0.3
0.3 of paths in the mixnet are compromised (this is 
80
×
3
80×3, where 
3
3 is the number of layers, with a mixnet sampled from 
800
800 nodes with 
400
400 adversarial nodes) and each message is sent 
3
3 times giving 
0.657
0.657 for the fraction of messages being compromised.
Analysis of Naive Estimator
The naive estimator of relative stake 
𝛼
^
𝑖
=
log
⁡
(
1
−
𝑃
^
𝑖
(
1
)
)
log
⁡
(
1
−
𝑓
)
α
^
i
	​

=
log(1−f)
log(1−
P
^
i
	​

(1))
	​

 is obtained from the maximum likelihood (ML) estimator by setting 
𝜆
=
0
λ=0.
The probability that 
𝛼
𝑖
−
𝜖
≤
𝛼
^
𝑖
≤
𝛼
𝑖
+
𝜖
α
i
	​

−ϵ≤
α
^
i
	​

≤α
i
	​

+ϵ, where 
𝛼
𝑖
α
i
	​

 is true relative stake and 
𝜖
ϵ is “accuracy”, is given by   
𝑃
(
𝜙
𝑓
(
𝛼
𝑖
−
𝜖
)
 
𝑚
≤
𝑛
≤
𝜙
𝑓
(
𝛼
𝑖
+
𝜖
)
 
𝑚
∣
𝑚
>
0
)
=
∑
𝑚
=
1
𝑇
∑
𝑛
=
0
𝑚
𝑃
(
𝑚
∣
𝑇
)
𝑃
(
𝑛
∣
𝑚
)
1
−
(
1
−
𝑞
)
𝑇
1
[
𝜙
𝑓
(
𝛼
𝑖
−
𝜖
)
 
𝑚
≤
𝑛
≤
𝜙
𝑓
(
𝛼
𝑖
+
𝜖
)
 
𝑚
]
P(ϕ
f
	​

(α
i
	​

−ϵ)m≤n≤ϕ
f
	​

(α
i
	​

+ϵ)m∣m>0)=∑
m=1
T
	​

∑
n=0
m
	​

1−(1−q)
T
P(m∣T)P(n∣m)
	​

1[ϕ
f
	​

(α
i
	​

−ϵ)m≤n≤ϕ
f
	​

(α
i
	​

+ϵ)m], where 
𝑃
(
𝑚
∣
𝑇
)
P(m∣T) is the binomial distribution of number of observations 
𝑚
m, with the parameter 
𝑞
q such that 
𝑞
 
𝑇
qT is the average number of observations, and 
𝑃
(
𝑛
∣
𝑚
)
P(n∣m) is the binomial distribution of the number of observed wins n, with the parameter 
𝜙
𝑓
(
𝛼
𝑖
)
ϕ
f
	​

(α
i
	​

) such that 
𝜙
𝑓
(
𝛼
𝑖
)
 
𝑚
ϕ
f
	​

(α
i
	​

)m is the average number of observed wins.
The probability of 
𝛼
𝑖
−
𝜖
≤
𝛼
^
𝑖
≤
𝛼
𝑖
+
𝜖
α
i
	​

−ϵ≤
α
^
i
	​

≤α
i
	​

+ϵ can be interpreted as “confidence”. The probability that 
𝛼
𝑖
−
𝜖
≤
𝛼
^
𝑖
α
i
	​

−ϵ≤
α
^
i
	​

, given by 
𝑃
(
𝜙
𝑓
(
𝛼
𝑖
−
𝜖
)
 
𝑚
≤
𝑛
∣
𝑚
>
0
)
P(ϕ
f
	​

(α
i
	​

−ϵ)m≤n∣m>0), is also of interest. However, for 
𝑃
^
𝑖
(
1
)
>
𝑓
P
^
i
	​

(1)>f, which can happen for short observation times  
𝑇
T,  the estimator 
𝛼
^
𝑖
>
1
α
^
i
	​

>1 (and hence the probability of 
𝛼
𝑖
−
𝜖
≤
𝛼
^
𝑖
α
i
	​

−ϵ≤
α
^
i
	​

) can be considered only for long observation times 
𝑇
T where the probability of the event 
𝛼
^
𝑖
>
1
α
^
i
	​

>1 is small.
The bounds and (large time T) asymptotic estimates on the probability   
𝑃
(
𝜙
𝑓
(
𝛼
𝑖
−
𝜖
)
 
𝑚
≤
𝑛
≤
𝜙
𝑓
(
𝛼
𝑖
+
𝜖
)
 
𝑚
∣
𝑚
>
0
)
P(ϕ
f
	​

(α
i
	​

−ϵ)m≤n≤ϕ
f
	​

(α
i
	​

+ϵ)m∣m>0), as well as on the probability 
𝑃
(
𝜙
𝑓
(
𝛼
𝑖
−
𝜖
)
 
𝑚
≤
𝑛
∣
𝑚
>
0
)
P(ϕ
f
	​

(α
i
	​

−ϵ)m≤n∣m>0), can be obtained by adopting the results in Analysis of leader election process in proof of stake consensus model.
Numerical Results  
The maximum likelihood (ML) estimator performance is dependent on the fraction of observed nodes 
𝑞
q (or the mixnet failure probability) and the number of slots  
𝑇
T. The [erformance of the estimator improves as  
𝑇
T increases, as can be seen in this plot:
The (naive) ML estimator, given by the frequency of elections won, as a function of the number of slots 
𝑇
T plotted for a number of nodes with relative stakes 
𝛼
α.  Here on average the fraction 
𝑞
=
0.8
q=0.8 of slots was observed.
The performance of ML estimators was also evaluated using the Jaccard Index. The index evaluates the estimators’ ability to correctly classify nodes as “high” or “low” stake. The simulation was done across multiple mixnet failure probabilities 
𝑞
q.
The  performance of the (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here the N=2000 stake values were drawn from the 
Pareto
(
𝑚
=
2
,
𝑠
=
1
)
Pareto(m=2,s=1) distribution and T=432000. For q close 1, i.e. all nodes are observed, most high stake nodes are inferred correctly (Jaccard index is close to 1). As q (i.e. fraction of observed nodes) decreases, the accuracy decreases and for  
𝑞
>
10
−
2
q>10
−2
 is significantly reduced (Jaccard index is close to 0).    
Analysis was also done using Cardano’s real world stake values. Clearly, Cardano’s stake distribution incentives somehow seem to protect against inferring top 1pct of stakers. More analysis is needed:
The performance of (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here T=432000 and  N=2500 stake values were obtained from Cardano.  
Analysis of ML Estimator: Inference of Lagrange Multiplier
The naive estimator above assumed the Lagrange multiplier, which ensures that inferred relative stake is normalized , 
𝜆
=
0
λ=0. A more sophisticated estimator can be derived from the ML framework by inferring 
𝜆
λ for a given sample.
The Lagrange multiplier 
𝜆
λ is inferred by minimizing the distance between the LHS and RHS of equation (18) :
𝐷
(
1
−
𝑓
∣
∣
∏
𝑖
=
1
𝑁
[
1
−
𝜙
^
𝑖
(
𝜆
)
]
)
D(1−f∣∣
i=1
∏
N
	​

[1−
ϕ
^
	​

i
	​

(λ)])
In the above, the “distance” used is the relative entropy. Computing the partial derivative w.r.t. 
𝜆
λ gives us a gradient which we can then follow using gradient descent, or any other algorithm which uses a gradient, to discover the choice of 
𝜆
λ which minimizes the above distance.
Inferred Distributions of Relative Stake 
Relative stake obtained in 1000 inferences for stake distribution drawn from 
Pareto
(
2
,
1
)
Pareto(2,1)
 
𝑞
=
1
q=1​
 
𝑞
=
0.1
q=0.1​
 
𝑞
=
0.01
q=0.01​
Here 
𝑞
q is the fraction of observed time-slots (or the “mixnet failure probability”)  out of the total 
𝑇
=
432
,
000
T=432,000 time-slots.  The  small, grad and naive above refer to the 
𝜆
→
0
λ→0 approximation, the inferred 
𝜆
λ, and the 
𝜆
=
0
λ=0 estimators respectively. The inferred 
𝜆
λ estimator produces a smoother distribution for small 
𝑞
q. The  small and naive estimators produce near identical inferred distributions.
 The Total of Inferred Relative Stake
The sum of all relative stake (by definition) must sum to 1. Here we plot the error in inferred total stake for the different estimators:
Plotting the squared distance to 1 of the sum of inferred relative stakes. The inferred 
𝜆
λ estimator produces a much lower and constant error across 
𝑞
q values on this metric.
Classification Performance
Despite the reduced error in total relative stake inference, and the smoother histogram, the naive estimator performed identically to the inferred 
𝜆
λ estimator when tasked to identify the top stakers of the distribution.
We ask the question: given the top 10% of inferred stakers, is the true top staker among those inferred top 10%.
Naive and grad estimators performed identically at this task.
Plot of the Jaccard Index: J(inferred 90th pct, true 90th pct). High Jaccard index tells us there is a high degree of overlap between the two sets, low index tells us that the sets are nearly disjoint.
Estimator Accuracy
Here we measure the accuracy of estimators. The left plot shows inferred vs true relative stake for one simulation, right plot shows mean squared error between inferred and true relative stakes. We find that both naive and inferred 
𝜆
λ estimators produce similar results.
X-axis is the true relative stake, Y-axis is the inferred relative stake. Perfect inference would produce the solid black line. All estimators perform nearly identically.
Simulation parameters:

𝑞
=
0.5
q=0.5, 
𝑓
=
0.05
f=0.05, 
𝑇
=
432
,
000
T=432,000
stake distribution=np.linspace(1, 100, 1000)
Plotting the Mean Squared Error (i.e. average squared distance between true and inferred relative stake pairs) against 
𝑞
q.
Simulation Parameters:

𝑓
=
0.05
,
𝑇
=
432
,
000
f=0.05,T=432,000
stake distribution = Cardano
Statistical Inference of Relative Stake  
Leader election process: at time-slot 
𝑡
t the probability of a node 
𝑖
∈
{
1
,
…
,
𝑁
}
i∈{1,…,N} winning the election is given by the “lottery” function 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

), where 
𝛼
𝑖
α
i
	​

 is the relative stake of node 
𝑖
i. 
Observation process: the outcome of the election for node 
𝑖
i is observed with the probability 
𝑞
q. 
Statistical inference: we define the log-likelihood 
𝐿
=
∑
𝑡
=
1
𝑇
∑
𝑖
=
1
𝑁
𝜂
𝑖
(
𝑡
)
log
⁡
𝑃
𝑖
(
𝑠
𝑖
(
𝑡
)
)
L=∑
t=1
T
	​

∑
i=1
N
	​

η
i
	​

(t)logP
i
	​

(s
i
	​

(t)) , where 
𝑠
𝑖
(
𝑡
)
=
1
/
0
s
i
	​

(t)=1/0  is the outcome of the election for node 
𝑖
i at time-slot t, 
𝑃
𝑖
(
1
)
=
𝜙
(
𝛼
𝑖
)
P
i
	​

(1)=ϕ(α
i
	​

) and 
𝜂
𝑖
(
𝑡
)
=
1
/
0
η
i
	​

(t)=1/0 for observed/unobserved 
𝑠
𝑖
(
𝑡
)
s
i
	​

(t).
Maximisation of 
𝐿
L, subject to constraint 
∑
𝑖
=
1
𝑁
𝛼
𝑖
=
1
∑
i=1
N
	​

α
i
	​

=1, gives the ML estimator of relative stake 
𝛼
^
𝑖
α
^
i
	​

 which is a solution of the equation 
𝜙
(
𝛼
𝑖
)
=
𝑃
^
𝑖
(
1
)
/
(
1
+
𝜆
log
⁡
 ⁣
(
1
−
𝑓
)
∑
𝑡
=
1
𝑇
𝜂
𝑖
(
𝑡
)
)
ϕ(α
i
	​

)=
P
^
i
	​

(1)/(1+
log(1−f)∑
t=1
T
	​

η
i
	​

(t)
λ
	​

) for 
𝛼
𝑖
α
i
	​

. 
Here 
𝑃
^
𝑖
(
1
)
=
∑
𝑡
=
1
𝑇
𝜂
𝑖
(
𝑡
)
 
𝛿
1
;
𝑠
𝑖
(
𝑡
)
/
∑
𝑡
~
=
1
𝑇
𝜂
𝑖
(
𝑡
~
)
P
^
i
	​

(1)=∑
t=1
T
	​

η
i
	​

(t)δ
1;s
i
	​

(t)
	​

/∑
t
~
=1
T
	​

η
i
	​

(
t
~
), i.e. the number of 1’s observed divided by the total number of observations, and 
𝜆
λ is a parameter which ensures that  
∑
𝑖
=
1
𝑁
𝛼
^
𝑖
=
1
∑
i=1
N
	​

α
^
i
	​

=1. 
The leader election and observation processes. Node 
𝑖
i participates in the leader election (or ``lottery'') at times 
𝑡
1
,
…
,
𝑡
𝑇
t
1
	​

,…,t
T
	​

. The (binary) outcome of this lottery,  where 0/1 corresponds to lost/won, is either observed (numbers in square brackets) or unobserved. 
Appendix
Analysis of leader election process in proof of stake consensus model
Analysis_of_leader_election_process_in_PoS.pdf
326.3 KB
Statistical inference of relative stake
Statistical_inference_of_relative_stake.pdf
314.7 KB
Cardano Stake Distribution
Data was pulled from Cexplorer to determine the stake value of every pool in Cardano
pools.csv
232.8KB
The histogram seems to shows it seems to follow a classic power law
Anomalies in the Distribution
Removing the low stakers from the distribution reveals a few peaks and a sharp decline after 70MM ADA:
These two peaks occur at 32.7MM ADA and 69.9MM ADA respectively.
Doing some research shows that Cardano has a concept of “Pool Saturation”, that is controlled by a global “Saturation Parameter (
𝑘
k)”. This parameter sets the target number of pools in the network. The target is enforced through a soft “stake cap”, i.e. a pool with 200 ADA when the stake cap is 100 ADA will earn the same rewards as a pool with 100 ADA.
Currently 
𝑘
=
500
k=500, this sets the stake cap at 64MM ADA. The IOHK blog posts suggest that there is a plan to move to 
𝑘
=
1000
k=1000 in the future, which would correspond to a stake cap of 32.7MM ADA.
We suspect the peak at ~70MM ADA we see in the data is the result of pool operators who are slightly over their target of 64MM but don’t yet feel the incentive to split into smaller pools.
The other peak at 32MM ADA likely corresponds to pools who are anticipating the switch to 
𝑘
=
1000
k=1000 and hoping to avoid any lost revenue due to the stake cap.
The sharp decline after 70MM ADA is likely explained by this Saturation Parameter incentivizing smaller pools.
The IOHK blog post announcing the change to 
𝑘
=
500
k=500 and a plan to increase 
𝑘
k to 1000 in 2021 (didn’t seem to happen) https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/
Reddit discussion anticipating the change to 
𝑘
=
1000
k=1000 https://www.reddit.com/r/cardano/comments/nfor5t/when_is_a_pools_saturation_too_high/
Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Cryptarchia De-anonymisation of Relative Stake
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Cryptarchia De-anonymisation of Relative Stake
Authors: David Rusu <davidrusu@logos.co>, Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Table
Details of derivations are in the documents Statistical inference of relative stake and Analysis of leader election process in PoS.
Stake Distribution Strategies Based on Adversarial Inference Which Uses a Naive Estimator
The adversary observes the leader election process of a node with the relative stake 
Σ
Equation
.
In 
Σ
Equation
 time slots, he/she is able to observe 
Σ
Equation
 wins in 
Σ
Equation
 observations.
For 
Σ
Equation
 he/she uses the naive estimator 
Σ
Equation
 of the true relative stake 
Σ
Equation
.
Here 
Σ
Equation
, known to adversary, is the fraction of time-slots with at least one winner.
For “accuracy” 
Σ
Equation
, the probability that 
Σ
Equation
 for large 
Σ
Equation
 is given by 
Σ
Equation
 where 
Σ
Equation
 is the lottery function, 
Σ
Equation
 and 
Σ
Equation
. Here 
Σ
Equation
 is the fraction of observed time-slots such that 
Σ
Equation
 slots are observed on average.
An example of above probability is given below.
Having estimated the fraction of observed time-slots 
Σ
Equation
 and accuracy 
Σ
Equation
 a node can use its stake 
Σ
Equation
, to compute the probability 
Σ
Equation
, i.e. the “confidence” obtained by an adversary in 
Σ
Equation
 time-slots. For a node, it is beneficial to reduce the latter, which can be done by distributing its stake among a number of nodes. To this end, the probability 
Σ
Equation
 is compared with some threshold 
Σ
Equation
 and if 
Σ
Equation
 then the stake is divided, i.e. 
Σ
Equation
, 
Σ
Equation
, etc., until 
Σ
Equation
.
The main functions of the algorithm which uses 
Σ
Equation
 to distribute the stake are as follows:
from math import erf, sqrt, log

def phi(alpha):
    global f
    return 1 - (1 - f)**alpha

def dphi(alpha):
    global f
    return -((1 - f)**alpha) * log(1 - f)

def Prob2(alpha, epsilon, T, q):    
    sqrt2 = sqrt(2.0)
    numerator = -2.0 * erf(sqrt2 * epsilon / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q))))
    denominator = (-erf(phi(alpha) * sqrt2 / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))) + erf(sqrt2 * (phi(alpha) - 1) / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))))
    return numerator / denominator
The above functions are then used to find minimum number of nodes such that distributing the stake into these nodes reduces the probability 
Σ
Equation
 to 
Σ
Equation
 as follows
import math

# Define parameters
T = 432000  # number of time-slots in one epoch
theta = 0.5  # adversarial confidence threshold
gamma0 = 0.1  # adversarial accuracy
a = 0.3  # fraction of compromised paths in the mixnet
r = 3  # redundancy in messages sent through the mixnet
q0 = 1 - (1 - a)**r  # fraction of compromised messages
f = 0.05
n_max = 10  # maximum number of iterations
alpha0 = 0.0126 #initial stake 

# Initialize relative stake alpha and delta
alpha = alpha0
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)

# Loop until delta <= theta or n reaches n_max
n = 2
while delta > theta and n <= n_max:
    alpha = alpha0 / n
    epsilon = dphi(alpha) * alpha * gamma0
    delta = Prob2(alpha, epsilon, T, q0)
    n += 1

# Update alpha and Prob
alpha = alpha0 / (n - 1)
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)

print("Final num. of nodes:", n-1)
print("Final alpha:", alpha)
print("Final Prob:", delta)

The above program suggests that the stake 
Σ
Equation
 has to be divided among 5 nodes for the adversarial confidence 
Σ
Equation
 when 
Σ
Equation
 of paths in the mixnet are compromised (this is 
Σ
Equation
, where 
Σ
Equation
 is the number of layers, with a mixnet sampled from 
Σ
Equation
 nodes with 
Σ
Equation
 adversarial nodes) and each message is sent 
Σ
Equation
 times giving 
Σ
Equation
 for the fraction of messages being compromised.
Analysis of Naive Estimator
The naive estimator of relative stake 
Σ
Equation
 is obtained from the maximum likelihood (ML) estimator by setting 
Σ
Equation
.
The probability that 
Σ
Equation
, where 
Σ
Equation
 is true relative stake and 
Σ
Equation
 is “accuracy”, is given by 
Σ
Equation
, where 
Σ
Equation
 is the binomial distribution of number of observations 
Σ
Equation
, with the parameter 
Σ
Equation
 such that 
Σ
Equation
 is the average number of observations, and 
Σ
Equation
 is the binomial distribution of the number of observed wins n, with the parameter 
Σ
Equation
 such that 
Σ
Equation
 is the average number of observed wins.
The probability of 
Σ
Equation
 can be interpreted as “confidence”. The probability that 
Σ
Equation
, given by 
Σ
Equation
, is also of interest. However, for 
Σ
Equation
, which can happen for short observation times 
Σ
Equation
, the estimator 
Σ
Equation
 (and hence the probability of 
Σ
Equation
) can be considered only for long observation times 
Σ
Equation
 where the probability of the event 
Σ
Equation
 is small.
The bounds and (large time T) asymptotic estimates on the probability 
Σ
Equation
, as well as on the probability 
Σ
Equation
, can be obtained by adopting the results in Analysis of leader election process in proof of stake consensus model.
Numerical Results
The maximum likelihood (ML) estimator performance is dependent on the fraction of observed nodes 
Σ
Equation
 (or the mixnet failure probability) and the number of slots 
Σ
Equation
. The [erformance of the estimator improves as 
Σ
Equation
 increases, as can be seen in this plot:
The performance of ML estimators was also evaluated using the Jaccard Index. The index evaluates the estimators’ ability to correctly classify nodes as “high” or “low” stake. The simulation was done across multiple mixnet failure probabilities 
Σ
Equation
.
Analysis was also done using Cardano’s real world stake values. Clearly, Cardano’s stake distribution incentives somehow seem to protect against inferring top 1pct of stakers. More analysis is needed:
Analysis of ML Estimator: Inference of Lagrange Multiplier
The naive estimator above assumed the Lagrange multiplier, which ensures that inferred relative stake is normalized , 
Σ
Equation
. A more sophisticated estimator can be derived from the ML framework by inferring 
Σ
Equation
 for a given sample.
The Lagrange multiplier 
Σ
Equation
 is inferred by minimizing the distance between the LHS and RHS of equation (18) :
📈
Equation
In the above, the “distance” used is the relative entropy. Computing the partial derivative w.r.t. 
Σ
Equation
 gives us a gradient which we can then follow using gradient descent, or any other algorithm which uses a gradient, to discover the choice of 
Σ
Equation
 which minimizes the above distance.
Inferred Distributions of Relative Stake
Here 
Σ
Equation
 is the fraction of observed time-slots (or the “mixnet failure probability”) out of the total 
Σ
Equation
 time-slots. The small, grad and naive above refer to the 
Σ
Equation
 approximation, the inferred 
Σ
Equation
, and the 
Σ
Equation
 estimators respectively. The inferred 
Σ
Equation
 estimator produces a smoother distribution for small 
Σ
Equation
. The small and naive estimators produce near identical inferred distributions.
The Total of Inferred Relative Stake
The sum of all relative stake (by definition) must sum to 1. Here we plot the error in inferred total stake for the different estimators:
Classification Performance
Despite the reduced error in total relative stake inference, and the smoother histogram, the naive estimator performed identically to the inferred 
Σ
Equation
 estimator when tasked to identify the top stakers of the distribution.
Estimator Accuracy
Here we measure the accuracy of estimators. The left plot shows inferred vs true relative stake for one simulation, right plot shows mean squared error between inferred and true relative stakes. We find that both naive and inferred 
Σ
Equation
 estimators produce similar results.
Statistical Inference of Relative Stake
Leader election process: at time-slot 
Σ
Equation
 the probability of a node 
Σ
Equation
 winning the election is given by the “lottery” function 
Σ
Equation
, where 
Σ
Equation
 is the relative stake of node 
Σ
Equation
.
Observation process: the outcome of the election for node 
Σ
Equation
 is observed with the probability 
Σ
Equation
.
Statistical inference: we define the log-likelihood 
Σ
Equation
 , where 
Σ
Equation
 is the outcome of the election for node 
Σ
Equation
 at time-slot t, 
Σ
Equation
 and 
Σ
Equation
 for observed/unobserved 
Σ
Equation
.
Maximisation of 
Σ
Equation
, subject to constraint 
Σ
Equation
, gives the ML estimator of relative stake 
Σ
Equation
 which is a solution of the equation 
Σ
Equation
 for 
Σ
Equation
.
Here 
Σ
Equation
, i.e. the number of 1’s observed divided by the total number of observations, and 
Σ
Equation
 is a parameter which ensures that 
Σ
Equation
.
Appendix
Analysis of leader election process in proof of stake consensus model
📎
File
Statistical inference of relative stake
📎
File
Cardano Stake Distribution
Data was pulled from Cexplorer to determine the stake value of every pool in Cardano
📎
File
The histogram seems to shows it seems to follow a classic power law
Anomalies in the Distribution
Removing the low stakers from the distribution reveals a few peaks and a sharp decline after 70MM ADA:
These two peaks occur at 32.7MM ADA and 69.9MM ADA respectively.
Doing some research shows that Cardano has a concept of “Pool Saturation”, that is controlled by a global “Saturation Parameter (
Σ
Equation
)”. This parameter sets the target number of pools in the network. The target is enforced through a soft “stake cap”, i.e. a pool with 200 ADA when the stake cap is 100 ADA will earn the same rewards as a pool with 100 ADA.
Currently 
Σ
Equation
, this sets the stake cap at 64MM ADA. The IOHK blog posts suggest that there is a plan to move to 
Σ
Equation
 in the future, which would correspond to a stake cap of 32.7MM ADA.
We suspect the peak at ~70MM ADA we see in the data is the result of pool operators who are slightly over their target of 64MM but don’t yet feel the incentive to split into smaller pools.
The other peak at 32MM ADA likely corresponds to pools who are anticipating the switch to 
Σ
Equation
 and hoping to avoid any lost revenue due to the stake cap.
The sharp decline after 70MM ADA is likely explained by this Saturation Parameter incentivizing smaller pools.
The IOHK blog post announcing the change to 
Σ
Equation
 and a plan to increase 
Σ
Equation
 to 1000 in 2021 (didn’t seem to happen) https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/
Reddit discussion anticipating the change to 
Σ
Equation
 https://www.reddit.com/r/cardano/comments/nfor5t/when_is_a_pools_saturation_too_high/
Open in new tab
