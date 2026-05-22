# ANALYSISIMPACT-OF-THE-SERVICE-DECLARATION-PROTOCOL-ON-THE-STATISTICAL-INFERENCE-OF-RELATIVE-STAKE

| Field | Value |
| --- | --- |
| Name | [Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
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

Authors: Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-08-22
Introduction
The Service Declaration Protocol (SDP) introduces a piece of a priori information: the knowledge that a node's relative stake cannot be less than a known threshold, 
𝛼
0
α
0
	​

. Our research investigates the significance of the impact of this information on the statistical inference of relative stake. We propose a new estimator which explicitly utilises 
𝛼
0
α
0
	​

 by setting any estimated stake below this threshold to 
𝛼
0
α
0
	​

.
Our new estimator works better because it fixes estimation errors at the lower end. When a node's true stake value (
𝛼
𝑖
α
i
	​

) is close to the minimum threshold (
𝛼
0
α
0
	​

), the standard maximum likelihood (ML) estimator often produces values that are too low. By automatically adjusting these too-low estimates up to the minimum threshold (
𝛼
0
α
0
	​

), our new approach reduces errors. This improvement can be measured as a lower mean squared error (MSE) compared to the true stake value (
𝛼
𝑖
α
i
	​

). Thus any party, including potential adversaries, performing stake inference gains in accuracy by using the new estimator.  
Numerical experiments demonstrate reduction in MSE of the new estimator compared to the ML estimator, particularly for stakes near 
𝛼
0
α
0
	​

. For example, for 
𝛼
0
=
10
−
4
α
0
	​

=10
−4
 used in experiments, a reduction of MSE by a (approx.) factor of at most 
1
/
2
1/2 was observed. Furthermore, the probability, measured in the same experiment, that the inferred stake falls within a desired accuracy interval is higher (by factor of (approx.) 
3
3 at least) when the new estimator is used. While the advantage diminishes for much higher stake values where both estimators converge, the heightened accuracy near the critical 
𝛼
0
α
0
	​

 threshold presents a meaningful enhancement for any party performing stake inference, including potential adversaries.
Key Findings
Introduction of a priori information: The Service Declaration Protocol (SDP) introduces the knowledge that a node's relative stake cannot be less than a threshold (
𝛼
0
α
0
	​

), which impacts statistical inference of relative stake⁠⁠.
New estimator proposed: The research introduces a new estimator that explicitly uses α₀ by setting any estimated stake below this threshold to 
𝛼
0
α
0
	​

⁠⁠.
Improved accuracy: The new estimator performs better because it corrects estimation errors at the lower end, particularly when a node's true stake value is close to the minimum threshold⁠⁠.
Measurable improvements: Numerical experiments show:
Reduction in Mean Squared Error (MSE) of the new estimator compared to the ML estimator, particularly for stakes near 
𝛼
0
α
0
	​

⁠⁠.
For 
𝛼
0
=
10
−
4
α
0
	​

=10
−4
, MSE reduction by a factor of approximately 
1
/
2
1/2 was observed⁠⁠.
Higher probability (by a factor of approximately 3) that inferred stake falls within desired accuracy intervals⁠⁠.
Statistical significance: The advantage diminishes for much higher stake values where both estimators converge, but the enhanced accuracy near the critical α₀ threshold presents a meaningful improvement for any party performing stake inference⁠⁠.
Security implications: This improvement benefits anyone performing stake inference, including potential adversaries⁠⁠.
The research provides mathematical proof and numerical simulations to validate these findings, showing that the proposed estimator is both unbiased and consistent in the limit of large number of observations⁠⁠.
Overview
This document examines the impact of minimum stake threshold, introduced in the SDP, on the statistical inference of relative stake along the following points:
In particular: 
We consider the Leader Election Process where nodes allowed to participate only if their relative stake is no less than some prescribed by SDP threshold. 
We assume that the Adversary observes wins (and losses) of nodes and uses statistical inference to infer relative stake of nodes.
The Adversary knows the SDP stake threshold, and using this information, the Adversary constructs a statistical estimator. 
This New estimator improves inference of stake when compared with an estimator which doesn’t use the SDP threshold. The simulation of adversarial inference shows that those most affected by this improvement are the nodes with values of relative stake close to the threshold. 
Analysis 
The Model
The relative stake of node 
𝑖
i, 
𝛼
𝑖
α
i
	​

, is computed via the formula 
𝛼
𝑖
=
𝑤
𝑖
/
∑
𝑗
=
1
𝑁
𝑤
𝑗
α
i
	​

=w
i
	​

/∑
j=1
N
	​

w
j
	​

, where 
𝑤
𝑖
w
i
	​

 is the stake of node 
𝑖
i. We assume that the total stake 
∑
𝑗
=
1
𝑁
𝑤
𝑗
∑
j=1
N
	​

w
j
	​

 can be inferred (with high accuracy) by using the total stake inference algorithm.  We note that for the set 
{
𝛼
1
,
…
,
𝛼
𝑁
}
{α
1
	​

,…,α
N
	​

}, i.e. relative stakes of all nodes, it is possible that 
{
𝛼
1
,
…
,
𝛼
𝑁
}
=
{
𝛼
𝑖
 
∣
 
𝛼
𝑖
<
𝛼
0
}
∪
{
𝛼
𝑖
 
∣
 
𝛼
𝑖
≥
𝛼
0
}
{α
1
	​

,…,α
N
	​

}={α
i
	​

∣α
i
	​

<α
0
	​

}∪{α
i
	​

∣α
i
	​

≥α
0
	​

}. It is known, through the declaration of the Service Declaration Protocol (SDP), that the relative stake of a node is at least 
𝛼
0
α
0
	​

.  For 
𝛼
𝑖
∈
{
𝛼
𝑖
 
∣
 
𝛼
𝑖
≥
𝛼
0
}
α
i
	​

∈{α
i
	​

∣α
i
	​

≥α
0
	​

}, the relative stake of a node 
𝑖
i can be written as 
𝛼
𝑖
=
𝛽
𝑖
+
𝛼
0
α
i
	​

=β
i
	​

+α
0
	​

, where 
𝛽
𝑖
≥
0
β
i
	​

≥0 is unknown. Intuitively, this suggests that if, relative to the 
𝛼
𝑖
α
i
	​

, the minimum stake 
𝛼
0
α
0
	​

 is large, then then there is less “uncertainty” about the relative stake 
𝛼
𝑖
α
i
	​

.
Node 
𝑖
i participates in the leader election and its probability of winning is given by the “lottery” function
𝜙
(
𝛼
𝑖
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
𝑖
,
ϕ(α
i
	​

)=1−(1−f)
α
i
	​

,
where 
𝑓
∈
(
0
,
1
)
f∈(0,1) is the parameter of the consensus. Since the lottery function 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

) is a monotonically increasing function of relative stake, for the relative stake 
𝛼
𝑖
=
𝛽
𝑖
+
𝛼
0
α
i
	​

=β
i
	​

+α
0
	​

 we have 
𝜙
(
𝛽
𝑖
+
𝛼
0
)
≥
𝜙
(
𝛼
0
)
ϕ(β
i
	​

+α
0
	​

)≥ϕ(α
0
	​

), i.e. the prob. of winning for nodes with relative stake greater than 
𝛼
0
α
0
	​

 is higher.  
Inference of relative stake 
For the fraction of wins 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) in the 
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
≥
1
∑
t=1
T
	​

η
i
	​

(t)≥1 observations of the leader election process of a node the (naive) statistical estimator of 
𝛼
α, 
𝛼
^
𝑖
α
^
i
	​

, is the solution of the equation 
𝑃
^
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
^
i
	​

(1)=ϕ(α
i
	​

) given by
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

We note that for 
𝑃
^
𝑖
(
1
)
=
0
P
^
i
	​

(1)=0 we have that 
𝛼
^
𝑖
=
0
α
^
i
	​

=0. The estimator 
𝛼
^
𝑖
α
^
i
	​

 is biased because 
⟨
𝛼
^
𝑖
⟩
=
⟨
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
⟩
≠
log
⁡
(
1
−
𝜙
(
𝛼
𝑖
)
)
log
⁡
(
1
−
𝑓
)
=
𝛼
𝑖
⟨
α
^
i
	​

⟩=⟨
log(1−f)
log(1−
P
^
i
	​

(1))
	​

⟩

=
log(1−f)
log(1−ϕ(α
i
	​

))
	​

=α
i
	​

where the average 
⟨
{
⋯
 
}
⟩
⟨{⋯}⟩ is defined in the Appendix. However, the average 
⟨
𝑃
^
𝑖
(
1
)
⟩
=
𝜙
(
𝛼
𝑖
)
⟨
P
^
i
	​

(1)⟩=ϕ(α
i
	​

) and the variance 
V
a
r
[
𝑃
^
𝑖
(
1
)
]
→
0
Var[
P
^
i
	​

(1)]→0.  If 
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
→
∞
∑
t=1
T
	​

η
i
	​

(t)→∞ when 
𝑇
→
∞
T→∞ then in this (”large number of observations”) limit we have 
𝛼
^
𝑖
→
log
⁡
(
1
−
𝜙
(
𝛼
𝑖
)
)
log
⁡
(
1
−
𝑓
)
=
𝛼
𝑖
α
^
i
	​

→
log(1−f)
log(1−ϕ(α
i
	​

))
	​

=α
i
	​

 i.e. 
𝛼
^
𝑖
α
^
i
	​

 is consistent estimator of the relative stake 
𝛼
𝑖
α
i
	​

.
Similarly to the estimator of 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

), we construct new estimator of relative stake
A
[
𝛼
^
𝑖
]
=
{
𝛼
^
𝑖
 if 
𝛼
^
𝑖
>
𝛼
0


𝛼
0
 if 
𝛼
^
𝑖
≤
𝛼
0
}
A[
α
^
i
	​

]={
α
^
i
	​

 if 
α
^
i
	​

>α
0
	​

α
0
	​

 if 
α
^
i
	​

≤α
0
	​

	​

}
The above can be written as follows 
A
[
𝛼
^
𝑖
]
=
𝛼
^
𝑖
1
[
𝛼
^
𝑖
>
𝛼
0
]
+
𝛼
0
1
[
𝛼
^
𝑖
≤
𝛼
0
]
      
=
𝛼
^
𝑖
+
1
[
𝛼
^
𝑖
≤
𝛼
0
]
{
𝛼
0
−
𝛼
^
𝑖
}
                 
=
𝛼
^
𝑖
+
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝛼
0
−
𝛼
^
𝑖
}
A[
α
^
i
	​

]=
α
^
i
	​

1[
α
^
i
	​

>α
0
	​

]+α
0
	​

1[
α
^
i
	​

≤α
0
	​

]
      =
α
^
i
	​

+1[
α
^
i
	​

≤α
0
	​

]{α
0
	​

−
α
^
i
	​

}
                 =
α
^
i
	​

+1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{α
0
	​

−
α
^
i
	​

}
We note that 
A
[
𝛼
^
𝑖
]
≤
𝛼
^
𝑖
+
𝛼
0
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
A[
α
^
i
	​

]≤
α
^
i
	​

+α
0
	​

1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)] from which follows that 
⟨
𝛼
^
𝑖
⟩
≤
⟨
A
[
𝛼
^
𝑖
]
⟩
≤
⟨
𝛼
^
𝑖
⟩
+
𝛼
0
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
⟩
⟨
α
^
i
	​

⟩≤⟨A[
α
^
i
	​

]⟩≤⟨
α
^
i
	​

⟩+α
0
	​

⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]⟩
 but we showed that 
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
⟩
→
0
⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]⟩→0 for a large number of observations, and hence 
⟨
A
[
𝛼
^
𝑖
]
⟩
→
⟨
𝛼
^
𝑖
⟩
⟨A[
α
^
i
	​

]⟩→⟨
α
^
i
	​

⟩ in this limit. 
Let us consider the (squared) distance 
∣
𝛼
𝑖
−
A
[
𝛼
^
𝑖
]
∣
2
=
(
𝛼
𝑖
−
𝛼
^
𝑖
−
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝛼
0
−
𝛼
^
𝑖
}
)
2
                                       
=
(
𝛼
𝑖
−
𝛼
^
𝑖
)
2
−
2
 
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
(
𝛼
𝑖
−
𝛼
^
𝑖
)
(
𝛼
0
−
𝛼
^
𝑖
)
                                             
+
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
(
𝛼
0
−
𝛼
^
𝑖
)
2
∣α
i
	​

−A[
α
^
i
	​

]∣
2
=(α
i
	​

−
α
^
i
	​

−1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{α
0
	​

−
α
^
i
	​

})
2
                                       =(α
i
	​

−
α
^
i
	​

)
2
−21[
P
^
i
	​

(1)≤ϕ(α
0
	​

)](α
i
	​

−
α
^
i
	​

)(α
0
	​

−
α
^
i
	​

)
                                             +1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)](α
0
	​

−
α
^
i
	​

)
2
From the above follows the difference 
⟨
∣
𝛼
𝑖
−
A
[
𝛼
^
𝑖
]
∣
2
⟩
−
⟨
∣
𝛼
𝑖
−
𝛼
^
𝑖
∣
2
⟩
   
=
−
2
 
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
(
𝛼
𝑖
−
𝛼
^
𝑖
)
(
𝛼
0
−
𝛼
^
𝑖
)
⟩
                                         
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
(
𝛼
0
−
𝛼
^
𝑖
)
2
⟩
                                         
=
−
2
 
⟨
1
[
𝛼
^
𝑖
≤
𝛼
0
]
(
𝛼
𝑖
−
𝛼
^
𝑖
)
(
𝛼
0
−
𝛼
^
𝑖
)
⟩
                                
+
⟨
1
[
𝛼
^
𝑖
≤
𝛼
0
]
(
𝛼
0
−
𝛼
^
𝑖
)
2
⟩
⟨∣α
i
	​

−A[
α
^
i
	​

]∣
2
⟩−⟨∣α
i
	​

−
α
^
i
	​

∣
2
⟩   =−2⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)](α
i
	​

−
α
^
i
	​

)(α
0
	​

−
α
^
i
	​

)⟩
                                         +⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)](α
0
	​

−
α
^
i
	​

)
2
⟩
                                         =−2⟨1[
α
^
i
	​

≤α
0
	​

](α
i
	​

−
α
^
i
	​

)(α
0
	​

−
α
^
i
	​

)⟩
                                +⟨1[
α
^
i
	​

≤α
0
	​

](α
0
	​

−
α
^
i
	​

)
2
⟩
Now, because 
𝛼
^
𝑖
≤
𝛼
0
≤
𝛼
𝑖
α
^
i
	​

≤α
0
	​

≤α
i
	​

, we have the following inequality 
⟨
1
[
𝛼
^
𝑖
≤
𝛼
0
]
(
𝛼
𝑖
−
𝛼
^
𝑖
)
(
𝛼
0
−
𝛼
^
𝑖
)
⟩
≥
⟨
1
[
𝛼
^
𝑖
≤
𝛼
0
]
(
𝛼
0
−
𝛼
^
𝑖
)
2
⟩
⟨1[
α
^
i
	​

≤α
0
	​

](α
i
	​

−
α
^
i
	​

)(α
0
	​

−
α
^
i
	​

)⟩≥⟨1[
α
^
i
	​

≤α
0
	​

](α
0
	​

−
α
^
i
	​

)
2
⟩
and hence 
⟨
∣
𝛼
𝑖
−
A
[
𝛼
^
𝑖
]
∣
2
⟩
−
⟨
∣
𝛼
𝑖
−
𝛼
^
𝑖
∣
2
⟩
≤
0
⟨∣α
i
	​

−A[
α
^
i
	​

]∣
2
⟩−⟨∣α
i
	​

−
α
^
i
	​

∣
2
⟩≤0
i.e. the mean squared error (MSE) of the estimator 
𝛼
^
𝑖
α
^
i
	​

 is greater than the MSE of the estimator 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

]. Furthermore, for the MSE of 
𝛼
^
𝑖
α
^
i
	​

 we have 
⟨
∣
𝛼
𝑖
−
𝛼
^
𝑖
∣
2
⟩
=
V
a
r
[
𝛼
^
𝑖
]
+
∣
𝛼
𝑖
−
⟨
𝛼
^
𝑖
⟩
∣
2
⟨∣α
i
	​

−
α
^
i
	​

∣
2
⟩=Var[
α
^
i
	​

]+∣α
i
	​

−⟨
α
^
i
	​

⟩∣
2
Now 
𝛼
^
𝑖
α
^
i
	​

 is a consistent estimator of the relative stake 
𝛼
𝑖
α
i
	​

 and hence 
⟨
∣
𝛼
𝑖
−
𝛼
^
𝑖
∣
2
⟩
→
0
⟨∣α
i
	​

−
α
^
i
	​

∣
2
⟩→0 in the large number of observations limit, but 
⟨
∣
𝛼
𝑖
−
A
[
𝛼
^
𝑖
]
∣
2
⟩
≤
⟨
∣
𝛼
𝑖
−
𝛼
^
𝑖
∣
2
⟩
⟨∣α
i
	​

−A[
α
^
i
	​

]∣
2
⟩≤⟨∣α
i
	​

−
α
^
i
	​

∣
2
⟩, so 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] is also a consistent estimator of the relative stake 
𝛼
𝑖
α
i
	​

. 
Simulations confirm that MSE of the estimator 
𝛼
^
𝑖
α
^
i
	​

 is greater than the MSE of the new estimator 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

], as can be seen in the figures below. 
The MSE of the estimator 
𝛼
^
𝑖
α
^
i
	​

 (blue + symbols) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
q=1.
The MSE of the estimator 
𝛼
^
𝑖
α
^
i
	​

 (blue + symbols) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
/
10
q=1/10.
The MSE of the estimator 
𝛼
^
𝑖
α
^
i
	​

 (blue + symbols) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
/
100
q=1/100.
We are interested in the probability 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) which can be seen as adversarial "confidence". Here 
0
<
𝛾
<
1
0<γ<1 prescribes desired “accuracy” of the inference. We note that the probability 
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) can be estimated analytically for large 
𝑇
T. If for a given (accuracy) parameter 
𝛾
γ we have that 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
>
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)])>P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) then the adversary has an advantage by using the new estimator, i.e. an adversary which knows that 
𝛼
𝑖
≥
𝛼
0
α
i
	​

≥α
0
	​

 has a higher confidence than the adversary which doesn’t know the latter.
Recall that 
𝛼
0
≤
𝛼
𝑖
α
0
	​

≤α
i
	​

. We note that 
𝛼
0
∈
[
𝛼
𝑖
(
1
−
𝜆
)
,
𝛼
𝑖
(
1
+
𝜆
)
]
α
0
	​

∈[α
i
	​

(1−λ),α
i
	​

(1+λ)], provided 
𝛼
𝑖
(
1
−
𝜆
)
≤
𝛼
0
α
i
	​

(1−λ)≤α
0
	​

. Let us assume (without loss of generality) that 
𝛼
𝑖
=
𝑛
 
𝛼
0
α
i
	​

=nα
0
	​

 for some 
𝑛
≥
1
n≥1. Then, from 
𝛼
𝑖
(
1
−
𝛾
)
≤
𝛼
0
α
i
	​

(1−γ)≤α
0
	​

 follows that 
𝑛
≤
1
1
−
𝛾
n≤
1−γ
1
	​

. Hence, if this inequality is satisfied, an adversary may have advantage. We compute the probabilities 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) and 
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) using simulation and find that the adversary has advantage for the relative stake 
𝛼
𝑖
∈
[
𝛼
0
,
𝛼
0
1
−
𝛾
]
α
i
	​

∈[α
0
	​

,
1−γ
α
0
	​

	​

], as can be seen in figures below.
The probability 
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (blue + symbols) and 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process for 
𝛾
=
1
/
10
γ=1/10, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
q=1.
The probability 
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (blue + symbols) and 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process for 
𝛾
=
1
/
10
γ=1/10, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
/
10
q=1/10.
The probability 
P
(
𝛼
^
𝑖
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(
α
^
i
	​

∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (blue + symbols) and 
P
(
A
[
𝛼
^
𝑖
]
∈
[
𝛼
𝑖
(
1
−
𝛾
)
,
𝛼
𝑖
(
1
+
𝛾
)
]
)
P(A[
α
^
i
	​

]∈[α
i
	​

(1−γ),α
i
	​

(1+γ)]) (red + symbols), obtained in 
𝑀
=
10
3
M=10
3
 simulations of leader election process for 
𝛾
=
1
/
10
γ=1/10, as a function of true relative stake 
𝛼
𝑖
=
𝑛
𝛼
0
α
i
	​

=nα
0
	​

, where 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The leader election process, with parameter
𝑓
=
0.05
f=0.05, was simulated for 
𝑇
=
432000
T=432000 time-slots. The fraction of observed slots is 
𝑞
=
1
/
100
q=1/100.
Numerical Experiments
In this section, we compare performance of the statistical estimators 
𝛼
^
𝑖
α
^
i
	​

 and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] in a single run of a simulation. This can be seen as a scenario where two adversaries collect the same data from the leader election process, but one of the adversaries knows 
𝛼
0
α
0
	​

 and uses this in the statistical inference. To simulate the statistical inference of relative stake in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, we sampled 
𝑁
=
2
×
10
3
N=2×10
3
 random (stake) values from the Pareto distribution with shape parameter 
2.5
2.5 and scale parameter 
2
2. The histogram of (relative) stake values is given below
We consider inference only for 
5
5 nodes with the highest relative stake and for 
5
5 nodes with relative stake just above the threshold 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
.  We consider a scenario where fraction 
𝑞
∈
{
1
/
100
,
1
/
10
,
1
}
q∈{1/100,1/10,1} of time-slots of the leader election process are observed by adversary. Here we find differences between estimators only for nodes with relative stake close to 
𝛼
0
α
0
	​

 as can be seen in the figures below.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.007482
,
…
,
0.013476
}
α∈{0.007482,…,0.013476}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.013476
α=0.013476 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
q=1.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.0001004999
,
…
,
0.0001018357
}
α∈{0.0001004999,…,0.0001018357}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.0001018357
α=0.0001018357 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
q=1.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.007482
,
…
,
0.013476
}
α∈{0.007482,…,0.013476}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.013476
α=0.013476 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
/
10
q=1/10.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.0001004999
,
…
,
0.0001018357
}
α∈{0.0001004999,…,0.0001018357}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.0001018357
α=0.0001018357 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
/
10
q=1/10.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.007482
,
…
,
0.013476
}
α∈{0.007482,…,0.013476}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.013476
α=0.013476 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
/
100
q=1/100.
The (relative) stake estimator 
𝛼
^
α
^
 (left panel) and 
A
[
𝛼
^
𝑖
]
A[
α
^
i
	​

] (right panel), computed in one epoch (
𝑇
=
432000
T=432000 time-slots) of the leader election process with parameter 
𝑓
=
0.05
f=0.05, plotted as a function of time-slots for five nodes with true (relative stake) 
𝛼
∈
{
0.0001004999
,
…
,
0.0001018357
}
α∈{0.0001004999,…,0.0001018357}, represented by solid horizontal lines. The boundaries of the interval 
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
[α(1−γ),α(1+γ)] for 
𝛼
=
0.0001018357
α=0.0001018357 and 
𝛾
=
1
/
10
γ=1/10 are represented by dashed horizontal lines. The dotted horizontal line corresponds to 
𝛼
0
=
1
/
10
4
α
0
	​

=1/10
4
. The fraction of observed slots is 
𝑞
=
1
/
100
q=1/100.
Appendix
Inference of probability
The leader election process is governed by the probability distribution 
P
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
=
∏
𝑖
=
1
𝑁
[
𝜙
(
𝛼
𝑖
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
(
𝛼
𝑖
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
P(s
1
	​

(t),…,s
N
	​

(t))=
i=1
∏
N
	​

[ϕ(α
i
	​

)δ
1;s
i
	​

(t)
	​

+(1−ϕ(α
i
	​

))δ
0;s
i
	​

(t)
	​

]
of the outcome of election 
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
s
1
	​

(t),…,s
N
	​

(t), where 
𝑠
𝑖
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
	​

(t)∈{0,1} models outcome (
0
/
1
≡
0/1≡ loss/win) for node 
𝑖
i in time-slot 
𝑡
t. The fraction of observed wins of node 
𝑖
i in one epoch is 
𝑃
^
𝑖
(
1
)
=
1
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
P
^
i
	​

(1)=
∑
t=1
T
	​

η
i
	​

(t)
1
	​

t=1
∑
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

where 
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
≥
1
∑
t=1
T
	​

η
i
	​

(t)≥1, with 
𝜂
𝑖
(
𝑡
)
∈
{
0
,
1
}
η
i
	​

(t)∈{0,1}, is the total number of observations. 
The average with respect to the leader election process gives us 
⟨
𝑃
^
𝑖
(
1
)
⟩
=
1
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
 
⟨
𝛿
1
;
𝑠
𝑖
(
𝑡
)
⟩
=
𝜙
(
𝛼
𝑖
)
⟨
P
^
i
	​

(1)⟩=
∑
t=1
T
	​

η
i
	​

(t)
1
	​

t=1
∑
T
	​

η
i
	​

(t)⟨δ
1;s
i
	​

(t)
	​

⟩=ϕ(α
i
	​

)
 i.e. 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) is unbiased statistical estimator of prob. of winning 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

). In the above 
⟨
{
⋯
 
}
⟩
⟨{⋯}⟩ is the averaging “operator” defines as 
⟨
{
⋯
 
}
⟩
=
{
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
∑
𝑠
𝑖
(
𝑡
)
P
(
𝑠
𝑖
(
𝑡
)
)
}
{
⋯
 
}
⟨{⋯}⟩=
⎩
⎨
⎧
	​

t=1
∏
T
	​

i=1
∏
N
	​

s
i
	​

(t)
∑
	​

P(s
i
	​

(t))
⎭
⎬
⎫
	​

{⋯}
where 
P
(
𝑠
𝑖
(
𝑡
)
)
=
𝜙
(
𝛼
𝑖
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
(
𝛼
𝑖
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
P(s
i
	​

(t))=ϕ(α
i
	​

)δ
1;s
i
	​

(t)
	​

+(1−ϕ(α
i
	​

))δ
0;s
i
	​

(t)
	​

. Since 
𝛼
𝑖
=
𝛽
𝑖
+
𝛼
0
α
i
	​

=β
i
	​

+α
0
	​

 and 
𝜙
(
𝛽
𝑖
+
𝛼
0
)
≥
𝜙
(
𝛼
0
)
ϕ(β
i
	​

+α
0
	​

)≥ϕ(α
0
	​

), from above follows that 
⟨
𝑃
^
𝑖
(
1
)
⟩
≥
𝜙
(
𝛼
0
)
⟨
P
^
i
	​

(1)⟩≥ϕ(α
0
	​

).
The variance of 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) is given by 
V
a
r
[
𝑃
^
𝑖
(
1
)
]
=
⟨
𝑃
^
𝑖
2
(
1
)
⟩
−
⟨
𝑃
^
𝑖
(
1
)
⟩
2
               
=
1
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
𝜙
(
𝛼
𝑖
)
[
1
−
𝜙
(
𝛼
𝑖
)
]
Var[
P
^
i
	​

(1)]=⟨
P
^
i
2
	​

(1)⟩−⟨
P
^
i
	​

(1)⟩
2
               =
∑
t=1
T
	​

η
i
	​

(t)
1
	​

ϕ(α
i
	​

)[1−ϕ(α
i
	​

)]
If 
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
→
∞
∑
t=1
T
	​

η
i
	​

(t)→∞ as 
𝑇
→
∞
T→∞, i.e. for a large number of observations, then 
V
a
r
[
𝑃
^
𝑖
(
1
)
]
→
0
Var[
P
^
i
	​

(1)]→0, i.e. 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) is a consistent estimator of the prob. 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

).
Let us define the new estimator of 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

) as follows 
Φ
[
𝑃
^
𝑖
(
1
)
]
=
𝜙
(
𝛼
0
)
 
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
+
𝑃
^
𝑖
(
1
)
 
1
[
𝑃
^
𝑖
(
1
)
>
𝜙
(
𝛼
0
)
]
                           
=
𝜙
(
𝛼
0
)
 
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
+
𝑃
^
𝑖
(
1
)
{
1
−
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
}
  
=
𝑃
^
𝑖
(
1
)
+
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
Φ[
P
^
i
	​

(1)]=ϕ(α
0
	​

)1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]+
P
^
i
	​

(1)1[
P
^
i
	​

(1)>ϕ(α
0
	​

)]
                           =ϕ(α
0
	​

)1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]+
P
^
i
	​

(1){1−1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]}
  =
P
^
i
	​

(1)+1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
The average with respect to leader election process gives us 
⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
=
𝜙
(
𝛼
𝑖
)
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
⟨Φ[
P
^
i
	​

(1)]⟩=ϕ(α
i
	​

)+⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
 i.e. the estimator 
Φ
[
𝑃
^
𝑖
(
1
)
]
Φ[
P
^
i
	​

(1)] has (positive) bias. We expect that in the limit 
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
→
∞
∑
t=1
T
	​

η
i
	​

(t)→∞ as 
𝑇
→
∞
T→∞, i.e. for a large number of observations, the average 
⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
→
𝜙
(
𝛼
𝑖
)
⟨Φ[
P
^
i
	​

(1)]⟩→ϕ(α
i
	​

). We note that since 
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
≥
0
1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}≥0, we have that 
⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
=
𝜙
(
𝛼
𝑖
)
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
≤
𝜙
(
𝛼
𝑖
)
+
𝜙
(
𝛼
0
)
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
⟩
⟨Φ[
P
^
i
	​

(1)]⟩=ϕ(α
i
	​

)+⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
≤ϕ(α
i
	​

)+ϕ(α
0
	​

)⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]⟩
and 


⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
≥
𝜙
(
𝛼
𝑖
)
⟨Φ[
P
^
i
	​

(1)]⟩≥ϕ(α
i
	​

)
Now, for 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
=
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
⟩
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))=⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]⟩ by the Markov’s inequality we have 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
=
P
r
o
b
(
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
≤
𝜙
(
𝛼
0
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
                                       
=
P
r
o
b
(
e
−
𝜆
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
≥
e
−
𝜆
𝜙
(
𝛼
0
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
  
≤
⟨
e
−
𝜆
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
⟩
e
−
𝜆
𝜙
(
𝛼
0
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
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))=Prob(
t=1
∑
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

≤ϕ(α
0
	​

)
t=1
∑
T
	​

η
i
	​

(t))
                                       =Prob(e
−λ∑
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

≥e
−λϕ(α
0
	​

)∑
t=1
T
	​

η
i
	​

(t)
)
  ≤
e
−λϕ(α
0
	​

)∑
t=1
T
	​

η
i
	​

(t)
⟨e
−λ∑
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

⟩
	​

where 
𝜆
>
0
λ>0. Using the definition, the average on the RHS of the above can be computed as follows 
⟨
e
−
𝜆
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
⟩
=
{
∏
𝑡
=
1
𝑇
∏
𝑗
=
1
𝑁
∑
𝑠
𝑗
(
𝑡
)
P
(
𝑠
𝑗
(
𝑡
)
)
}
e
−
𝜆
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
          
=
∏
𝑡
=
1
𝑇
∑
𝑠
𝑖
(
𝑡
)
P
(
𝑠
𝑖
(
𝑡
)
)
 
e
−
𝜆
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
                   
=
∏
𝑡
=
1
𝑇
(
𝜙
(
𝛼
𝑖
)
 
e
−
𝜆
𝜂
𝑖
(
𝑡
)
+
1
−
𝜙
(
𝛼
𝑖
)
)
          
=
e
∑
𝑡
=
1
𝑇
log
⁡
(
𝜙
(
𝛼
𝑖
)
 
e
−
𝜆
𝜂
𝑖
(
𝑡
)
+
1
−
𝜙
(
𝛼
𝑖
)
)
            
=
e
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
log
⁡
(
𝜙
(
𝛼
𝑖
)
 
e
−
𝜆
+
1
−
𝜙
(
𝛼
𝑖
)
)
⟨e
−λ∑
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

⟩=
⎩
⎨
⎧
	​

t=1
∏
T
	​

j=1
∏
N
	​

s
j
	​

(t)
∑
	​

P(s
j
	​

(t))
⎭
⎬
⎫
	​

e
−λ∑
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

          =
t=1
∏
T
	​

s
i
	​

(t)
∑
	​

P(s
i
	​

(t))e
−λη
i
	​

(t)δ
1;s
i
	​

(t)
	​

                   =
t=1
∏
T
	​

(ϕ(α
i
	​

)e
−λη
i
	​

(t)
+1−ϕ(α
i
	​

))
          =e
∑
t=1
T
	​

log(ϕ(α
i
	​

)e
−λη
i
	​

(t)
+1−ϕ(α
i
	​

))
            =e
∑
t=1
T
	​

η
i
	​

(t)log(ϕ(α
i
	​

)e
−λ
+1−ϕ(α
i
	​

))
Using above result in the inequality we obtain 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
≤
e
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
[
log
⁡
(
𝜙
(
𝛼
𝑖
)
 
e
−
𝜆
+
1
−
𝜙
(
𝛼
𝑖
)
)
+
𝜆
𝜙
(
𝛼
0
)
]
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))≤e
∑
t=1
T
	​

η
i
	​

(t)[log(ϕ(α
i
	​

)e
−λ
+1−ϕ(α
i
	​

))+λϕ(α
0
	​

)]
Furthermore, optimising the RHS in above with respect to 
𝜆
λ we obtain the inequality 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
≤
e
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
[
log
⁡
(
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
−
log
⁡
(
𝜙
(
𝛼
0
)
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
𝜙
(
𝛼
0
)
]
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))≤e
∑
t=1
T
	​

η
i
	​

(t)[log(
1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)−log(
ϕ(α)
ϕ(α
0
	​

)
	​

1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)ϕ(α
0
	​

)]
We note that 
log
⁡
(
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
−
log
⁡
(
𝜙
(
𝛼
0
)
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
𝜙
(
𝛼
0
)
log(
1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)−log(
ϕ(α)
ϕ(α
0
	​

)
	​

1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)ϕ(α
0
	​

) is monotonic decreasing function of 
𝜙
(
𝛼
)
ϕ(α) which is exactly zero when 
𝜙
(
𝛼
)
=
𝜙
(
𝛼
0
)
ϕ(α)=ϕ(α
0
	​

) and hence this function is negative for 
𝜙
(
𝛼
)
≥
𝜙
(
𝛼
0
)
ϕ(α)≥ϕ(α
0
	​

). Hence we have the following inequality 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
≤
e
−
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
[
−
log
⁡
(
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
+
log
⁡
(
𝜙
(
𝛼
0
)
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
𝜙
(
𝛼
0
)
]
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))≤e
−∑
t=1
T
	​

η
i
	​

(t)[−log(
1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)+log(
ϕ(α)
ϕ(α
0
	​

)
	​

1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)ϕ(α
0
	​

)]
where 
−
log
⁡
(
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
+
log
⁡
(
𝜙
(
𝛼
0
)
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
)
1
−
𝜙
(
𝛼
0
)
)
𝜙
(
𝛼
0
)
>
0
−log(
1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)+log(
ϕ(α)
ϕ(α
0
	​

)
	​

1−ϕ(α
0
	​

)
1−ϕ(α)
	​

)ϕ(α
0
	​

)>0 when 
𝜙
(
𝛼
)
>
𝜙
(
𝛼
0
)
ϕ(α)>ϕ(α
0
	​

).
From above follows that 
P
r
o
b
(
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
)
→
0
Prob(
P
^
i
	​

(1)≤ϕ(α
0
	​

))→0 in the limit 
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
→
∞
∑
t=1
T
	​

η
i
	​

(t)→∞ as 
𝑇
→
∞
T→∞, i.e. for a large number of observations. Using the latter in the upper bound gives us that 
⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
→
𝜙
(
𝛼
𝑖
)
⟨Φ[
P
^
i
	​

(1)]⟩→ϕ(α
i
	​

) in this limit. If in the limit of large number of observations we also have that the 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
→
0
Var[Φ[
P
^
i
	​

(1)]]→0 then 
Φ
[
𝑃
^
𝑖
(
1
)
]
Φ[
P
^
i
	​

(1)] is a consistent estimator of the prob. 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

). 
For 
Φ
[
𝑃
^
𝑖
(
1
)
]
=
𝑃
^
𝑖
(
1
)
+
𝜉
𝑖
Φ[
P
^
i
	​

(1)]=
P
^
i
	​

(1)+ξ
i
	​

, where we defined 
𝜉
𝑖
=
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
ξ
i
	​

=1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}, the 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
Var[Φ[
P
^
i
	​

(1)]] is given by 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
=
V
a
r
[
𝑃
^
𝑖
(
1
)
+
𝜉
𝑖
]
=
V
a
r
[
𝑃
^
𝑖
(
1
)
]
+
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
V
a
r
[
𝜉
𝑖
]
.
Var[Φ[
P
^
i
	​

(1)]]=Var[
P
^
i
	​

(1)+ξ
i
	​

]=Var[
P
^
i
	​

(1)]+2Cov[
P
^
i
	​

(1),ξ
i
	​

]+Var[ξ
i
	​

].
In the Variance section we show that 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
≤
V
a
r
[
𝑃
^
𝑖
(
1
)
]
.
Var[Φ[
P
^
i
	​

(1)]]≤Var[
P
^
i
	​

(1)].
Hence in the limit of large number of observations 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
→
0
Var[Φ[
P
^
i
	​

(1)]]→0. 
Thus from above follows that 
Φ
[
𝑃
^
𝑖
(
1
)
]
=
𝑃
^
𝑖
(
1
)
+
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
Φ[
P
^
i
	​

(1)]=
P
^
i
	​

(1)+1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
is unbiased and consistent estimator of the prob. 
𝜙
(
𝛼
𝑖
)
ϕ(α
i
	​

) in the limit of large number of observations 
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
→
∞
∑
t=1
T
	​

η
i
	​

(t)→∞ as 
𝑇
→
∞
T→∞.
For 
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
≥
1
∑
t=1
T
	​

η
i
	​

(t)≥1 the mean squared error (MSE) of the estimator 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) is given by 
⟨
∣
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
∣
2
⟩
=
V
a
r
[
𝑃
^
𝑖
(
1
)
]
=
1
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
𝜙
(
𝛼
𝑖
)
[
1
−
𝜙
(
𝛼
𝑖
)
]
⟨∣ϕ(α
i
	​

)−
P
^
i
	​

(1)∣
2
⟩=Var[
P
^
i
	​

(1)]=
∑
t=1
T
	​

η
i
	​

(t)
1
	​

ϕ(α
i
	​

)[1−ϕ(α
i
	​

)]
Assuming that the 
𝜂
𝑖
(
𝑡
)
η
i
	​

(t) variables are exactly the same as in the above, the MSE of the estimator 
Φ
[
𝑃
^
𝑖
(
1
)
]
Φ[
P
^
i
	​

(1)] is given by 
⟨
∣
𝜙
(
𝛼
𝑖
)
−
Φ
[
𝑃
^
𝑖
(
1
)
]
∣
2
⟩
   
=
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
+
∣
𝜙
(
𝛼
𝑖
)
−
⟨
Φ
[
𝑃
^
𝑖
(
1
)
]
⟩
∣
2
=
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
                                                                                 
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
2
⟨∣ϕ(α
i
	​

)−Φ[
P
^
i
	​

(1)]∣
2
⟩   =Var[Φ[
P
^
i
	​

(1)]]+
	​

ϕ(α
i
	​

)−⟨Φ[
P
^
i
	​

(1)]⟩
	​

2
=Var[Φ[
P
^
i
	​

(1)]]
                                                                                 +⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
2
Consider the difference
⟨
∣
𝜙
(
𝛼
𝑖
)
−
Φ
[
𝑃
^
𝑖
(
1
)
]
∣
2
⟩
−
⟨
∣
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
∣
2
⟩
⟨∣ϕ(α
i
	​

)−Φ[
P
^
i
	​

(1)]∣
2
⟩−⟨∣ϕ(α
i
	​

)−
P
^
i
	​

(1)∣
2
⟩ as follows
⟨
∣
𝜙
(
𝛼
𝑖
)
−
Φ
[
𝑃
^
𝑖
(
1
)
]
∣
2
⟩
−
⟨
∣
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
∣
2
⟩
=
V
a
r
[
𝑃
^
𝑖
(
1
)
]
+
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
V
a
r
[
𝜉
𝑖
]
                                              
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
2
−
V
a
r
[
𝑃
^
𝑖
(
1
)
]
                    
=
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
V
a
r
[
𝜉
𝑖
]
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
2
   
=
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
2
⟩
⟨∣ϕ(α
i
	​

)−Φ[
P
^
i
	​

(1)]∣
2
⟩−⟨∣ϕ(α
i
	​

)−
P
^
i
	​

(1)∣
2
⟩
=
Var[
P
^
i
	​

(1)]+2Cov[
P
^
i
	​

(1),ξ
i
	​

]+Var[ξ
i
	​

]
                                              +⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
2
−Var[
P
^
i
	​

(1)]
                    =2Cov[
P
^
i
	​

(1),ξ
i
	​

]+Var[ξ
i
	​

]+⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
2
   =2Cov[
P
^
i
	​

(1),ξ
i
	​

]+⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
2
⟩
Now the last line in the above can be bounded as follows 
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
2
⟩
              
=
−
2
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
   
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
2
⟩
               
≤
−
2
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
                
+
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
                                     
=
−
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
2Cov[
P
^
i
	​

(1),ξ
i
	​

]+⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
2
⟩
              =−2⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
   +⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
2
⟩
               ≤−2⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
                +⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
                                     =−⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
 Hence 
⟨
∣
𝜙
(
𝛼
𝑖
)
−
Φ
[
𝑃
^
𝑖
(
1
)
]
∣
2
⟩
−
⟨
∣
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
∣
2
⟩
     
≤
                                                                           
−
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
⟨∣ϕ(α
i
	​

)−Φ[
P
^
i
	​

(1)]∣
2
⟩−⟨∣ϕ(α
i
	​

)−
P
^
i
	​

(1)∣
2
⟩
     ≤
                                                                           −⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
Thus, the MSE of the unbiased estimator 
𝑃
^
𝑖
(
1
)
P
^
i
	​

(1) is greater that the MSE of the biased, but consistent, estimator 
Φ
[
𝑃
^
𝑖
(
1
)
]
Φ[
P
^
i
	​

(1)]. 
Variance of 
Φ
[
𝑃
^
𝑖
(
1
)
]
Φ[
P
^
i
	​

(1)]​
For 
Φ
[
𝑃
^
𝑖
(
1
)
]
=
𝑃
^
𝑖
(
1
)
+
𝜉
𝑖
Φ[
P
^
i
	​

(1)]=
P
^
i
	​

(1)+ξ
i
	​

, where 
𝜉
𝑖
=
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
ξ
i
	​

=1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}, we consider the variance
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
=
V
a
r
[
𝑃
^
𝑖
(
1
)
+
𝜉
𝑖
]
                                                                
=
V
a
r
[
𝑃
^
𝑖
(
1
)
]
+
2
 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
+
V
a
r
[
𝜉
𝑖
]
Var[Φ[
P
^
i
	​

(1)]]=Var[
P
^
i
	​

(1)+ξ
i
	​

]
                                                                =Var[
P
^
i
	​

(1)]+2Cov[
P
^
i
	​

(1),ξ
i
	​

]+Var[ξ
i
	​

]
First, we consider the covariance
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
=
⟨
𝑃
^
𝑖
(
1
)
 
𝜉
𝑖
⟩
−
⟨
𝑃
^
𝑖
(
1
)
⟩
⟨
𝜉
𝑖
⟩
=
⟨
𝑃
^
𝑖
(
1
)
 
𝜉
𝑖
⟩
−
𝜙
(
𝛼
𝑖
)
⟨
𝜉
𝑖
⟩
=
⟨
𝑃
^
𝑖
(
1
)
 
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
−
𝜙
(
𝛼
𝑖
)
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
=
−
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
Cov[
P
^
i
	​

(1),ξ
i
	​

]=⟨
P
^
i
	​

(1)ξ
i
	​

⟩−⟨
P
^
i
	​

(1)⟩⟨ξ
i
	​

⟩
=⟨
P
^
i
	​

(1)ξ
i
	​

⟩−ϕ(α
i
	​

)⟨ξ
i
	​

⟩
=⟨
P
^
i
	​

(1)1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩−ϕ(α
i
	​

)⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
=−⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
Because of 
𝜙
(
𝛼
0
)
≤
𝜙
(
𝛼
𝑖
)
ϕ(α
0
	​

)≤ϕ(α
i
	​

), from the above it follows that 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
≤
0
Cov[
P
^
i
	​

(1),ξ
i
	​

]≤0.
Second, we consider the variance 
V
a
r
[
𝜉
𝑖
]
=
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
2
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
2
⟩
−
⟨
𝜉
𝑖
⟩
2
                             
=
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
−
⟨
𝜉
𝑖
⟩
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
 
=
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
+
𝜙
(
𝛼
0
)
−
𝜙
(
𝛼
𝑖
)
−
⟨
𝜉
𝑖
⟩
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
        
≤
⟨
1
[
𝑃
^
𝑖
(
1
)
≤
𝜙
(
𝛼
0
)
]
{
𝜙
(
𝛼
𝑖
)
−
𝑃
^
𝑖
(
1
)
}
{
𝜙
(
𝛼
0
)
−
𝑃
^
𝑖
(
1
)
}
⟩
=
−
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
Var[ξ
i
	​

]=⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]
2
{ϕ(α
0
	​

)−
P
^
i
	​

(1)}
2
⟩−⟨ξ
i
	​

⟩
2
                             =⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
0
	​

)−
P
^
i
	​

(1)−⟨ξ
i
	​

⟩}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
 =⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)+ϕ(α
0
	​

)−ϕ(α
i
	​

)−⟨ξ
i
	​

⟩}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩
        ≤⟨1[
P
^
i
	​

(1)≤ϕ(α
0
	​

)]{ϕ(α
i
	​

)−
P
^
i
	​

(1)}{ϕ(α
0
	​

)−
P
^
i
	​

(1)}⟩=−Cov[
P
^
i
	​

(1),ξ
i
	​

]
Thus, from the above it follows that 
V
a
r
[
𝜉
𝑖
]
≤
−
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
Var[ξ
i
	​

]≤−Cov[
P
^
i
	​

(1),ξ
i
	​

]. The latter with 
−
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
≥
0
−Cov[
P
^
i
	​

(1),ξ
i
	​

]≥0 implies 
C
o
v
[
𝑃
^
𝑖
(
1
)
,
𝜉
𝑖
]
≤
−
V
a
r
[
𝜉
𝑖
]
/
2
Cov[
P
^
i
	​

(1),ξ
i
	​

]≤−Var[ξ
i
	​

]/2 which using the variance equation gives us that 
V
a
r
[
Φ
[
𝑃
^
𝑖
(
1
)
]
]
≤
V
a
r
[
𝑃
^
𝑖
(
1
)
]
Var[Φ[
P
^
i
	​

(1)]]≤Var[
P
^
i
	​

(1)]
\langle\{\cdots\}\rangle=\left\{\prod_{t=1}^T\prod_{i=1}^N \sum_{s_i(t)}\mathrm{P}(s_i(t))\right\} \{\cdots\}

\left\langle\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\right\rangle=\left\{\prod_{t=1}^T\prod_{j=1}^N \sum_{s_j(t)}\mathrm{P}(s_j(t))\right\}\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\\~~~~~~~~~~=\prod_{t=1}^T\sum_{s_i(t)}\mathrm{P}(s_i(t))\,\mathrm{e}^{-\lambda\eta_i(t)\,\delta_{1;s_i(t)}}\\~~~~~~~~~~~~~~~~~~~=\prod_{t=1}^T\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda\eta_i(t)}+1-\phi(\alpha_i)\right)\\~~~~~~~~~~=\mathrm{e}^{\sum_{t=1}^T\log\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda\eta_i(t)}+1-\phi(\alpha_i)\right)}\\~~~~~~~~~~~~=\mathrm{e}^{\sum_{t=1}^T\eta_i(t)\log\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha_i)\right)}

\langle\vert \phi(\alpha_i) -\Phi[\hat{P}_i(1)]\vert^2\rangle ~~~=\mathrm{Var}[\Phi[\hat{P}_i(1)]]+\left\vert\phi(\alpha_i)-\langle\Phi[\hat{P}_i(1)]\rangle\right\vert^2\\=\mathrm{Var}[\Phi[\hat{P}_i(1)]]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle^2

Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake
Authors: Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Table
Introduction
The Service Declaration Protocol (SDP) introduces a piece of a priori information: the knowledge that a node's relative stake cannot be less than a known threshold, 
Σ
Equation
. Our research investigates the significance of the impact of this information on the statistical inference of relative stake. We propose a new estimator which explicitly utilises 
Σ
Equation
 by setting any estimated stake below this threshold to 
Σ
Equation
.
Our new estimator works better because it fixes estimation errors at the lower end. When a node's true stake value (
Σ
Equation
) is close to the minimum threshold (
Σ
Equation
), the standard maximum likelihood (ML) estimator often produces values that are too low. By automatically adjusting these too-low estimates up to the minimum threshold (
Σ
Equation
), our new approach reduces errors. This improvement can be measured as a lower mean squared error (MSE) compared to the true stake value (
Σ
Equation
). Thus any party, including potential adversaries, performing stake inference gains in accuracy by using the new estimator.
Numerical experiments demonstrate reduction in MSE of the new estimator compared to the ML estimator, particularly for stakes near 
Σ
Equation
. For example, for 
Σ
Equation
 used in experiments, a reduction of MSE by a (approx.) factor of at most 
Σ
Equation
 was observed. Furthermore, the probability, measured in the same experiment, that the inferred stake falls within a desired accuracy interval is higher (by factor of (approx.) 
Σ
Equation
 at least) when the new estimator is used. While the advantage diminishes for much higher stake values where both estimators converge, the heightened accuracy near the critical 
Σ
Equation
 threshold presents a meaningful enhancement for any party performing stake inference, including potential adversaries.
Key Findings
Introduction of a priori information: The Service Declaration Protocol (SDP) introduces the knowledge that a node's relative stake cannot be less than a threshold (
Σ
Equation
), which impacts statistical inference of relative stake⁠⁠.
New estimator proposed: The research introduces a new estimator that explicitly uses α₀ by setting any estimated stake below this threshold to 
Σ
Equation
⁠⁠.
Improved accuracy: The new estimator performs better because it corrects estimation errors at the lower end, particularly when a node's true stake value is close to the minimum threshold⁠⁠.
Measurable improvements: Numerical experiments show:
Reduction in Mean Squared Error (MSE) of the new estimator compared to the ML estimator, particularly for stakes near 
Σ
Equation
⁠⁠.
For 
Σ
Equation
, MSE reduction by a factor of approximately 
Σ
Equation
 was observed⁠⁠.
Higher probability (by a factor of approximately 3) that inferred stake falls within desired accuracy intervals⁠⁠.
Statistical significance: The advantage diminishes for much higher stake values where both estimators converge, but the enhanced accuracy near the critical α₀ threshold presents a meaningful improvement for any party performing stake inference⁠⁠.
Security implications: This improvement benefits anyone performing stake inference, including potential adversaries⁠⁠.
The research provides mathematical proof and numerical simulations to validate these findings, showing that the proposed estimator is both unbiased and consistent in the limit of large number of observations⁠⁠.
Overview
This document examines the impact of minimum stake threshold, introduced in the SDP, on the statistical inference of relative stake along the following points:
In particular:
We consider the Leader Election Process where nodes allowed to participate only if their relative stake is no less than some prescribed by SDP threshold.
We assume that the Adversary observes wins (and losses) of nodes and uses statistical inference to infer relative stake of nodes.
The Adversary knows the SDP stake threshold, and using this information, the Adversary constructs a statistical estimator.
This New estimator improves inference of stake when compared with an estimator which doesn’t use the SDP threshold. The simulation of adversarial inference shows that those most affected by this improvement are the nodes with values of relative stake close to the threshold.
Analysis
The Model
The relative stake of node 
Σ
Equation
, 
Σ
Equation
, is computed via the formula 
Σ
Equation
, where 
Σ
Equation
 is the stake of node 
Σ
Equation
. We assume that the total stake 
Σ
Equation
 can be inferred (with high accuracy) by using the total stake inference algorithm. We note that for the set 
Σ
Equation
, i.e. relative stakes of all nodes, it is possible that 
Σ
Equation
. It is known, through the declaration of the Service Declaration Protocol (SDP), that the relative stake of a node is at least 
Σ
Equation
. For 
Σ
Equation
, the relative stake of a node 
Σ
Equation
 can be written as 
Σ
Equation
, where 
Σ
Equation
 is unknown. Intuitively, this suggests that if, relative to the 
Σ
Equation
, the minimum stake 
Σ
Equation
 is large, then then there is less “uncertainty” about the relative stake 
Σ
Equation
.
Node 
Σ
Equation
 participates in the leader election and its probability of winning is given by the “lottery” function
📈
Equation
where 
Σ
Equation
 is the parameter of the consensus. Since the lottery function 
Σ
Equation
 is a monotonically increasing function of relative stake, for the relative stake 
Σ
Equation
 we have 
Σ
Equation
, i.e. the prob. of winning for nodes with relative stake greater than 
Σ
Equation
 is higher.
Inference of relative stake
For the fraction of wins 
Σ
Equation
 in the 
Σ
Equation
 observations of the leader election process of a node the (naive) statistical estimator of 
Σ
Equation
, 
Σ
Equation
, is the solution of the equation 
Σ
Equation
 given by
📈
Equation
We note that for 
Σ
Equation
 we have that 
Σ
Equation
. The estimator 
Σ
Equation
 is biased because
📈
Equation
where the average 
Σ
Equation
 is defined in the Appendix. However, the average 
Σ
Equation
 and the variance 
Σ
Equation
. If 
Σ
Equation
 when 
Σ
Equation
 then in this (”large number of observations”) limit we have
📈
Equation
i.e. 
Σ
Equation
 is consistent estimator of the relative stake 
Σ
Equation
.
Similarly to the estimator of 
Σ
Equation
, we construct new estimator of relative stake
📈
Equation
The above can be written as follows
📈
Equation
We note that 
Σ
Equation
 from which follows that
📈
Equation
but we showed that 
Σ
Equation
 for a large number of observations, and hence 
Σ
Equation
 in this limit.
Let us consider the (squared) distance
📈
Equation
From the above follows the difference
📈
Equation
Now, because 
Σ
Equation
, we have the following inequality
📈
Equation
and hence
📈
Equation
i.e. the mean squared error (MSE) of the estimator 
Σ
Equation
 is greater than the MSE of the estimator 
Σ
Equation
. Furthermore, for the MSE of 
Σ
Equation
 we have
📈
Equation
Now 
Σ
Equation
 is a consistent estimator of the relative stake 
Σ
Equation
 and hence 
Σ
Equation
 in the large number of observations limit, but 
Σ
Equation
, so 
Σ
Equation
 is also a consistent estimator of the relative stake 
Σ
Equation
.
Simulations confirm that MSE of the estimator 
Σ
Equation
 is greater than the MSE of the new estimator 
Σ
Equation
, as can be seen in the figures below.
We are interested in the probability 
Σ
Equation
 which can be seen as adversarial "confidence". Here 
Σ
Equation
 prescribes desired “accuracy” of the inference. We note that the probability 
Σ
Equation
 can be estimated analytically for large 
Σ
Equation
. If for a given (accuracy) parameter 
Σ
Equation
 we have that 
Σ
Equation
 then the adversary has an advantage by using the new estimator, i.e. an adversary which knows that 
Σ
Equation
 has a higher confidence than the adversary which doesn’t know the latter.
Recall that 
Σ
Equation
. We note that 
Σ
Equation
, provided 
Σ
Equation
. Let us assume (without loss of generality) that 
Σ
Equation
 for some 
Σ
Equation
. Then, from 
Σ
Equation
 follows that 
Σ
Equation
. Hence, if this inequality is satisfied, an adversary may have advantage. We compute the probabilities 
Σ
Equation
 and 
Σ
Equation
 using simulation and find that the adversary has advantage for the relative stake 
Σ
Equation
, as can be seen in figures below.
Numerical Experiments
In this section, we compare performance of the statistical estimators 
Σ
Equation
 and 
Σ
Equation
 in a single run of a simulation. This can be seen as a scenario where two adversaries collect the same data from the leader election process, but one of the adversaries knows 
Σ
Equation
 and uses this in the statistical inference. To simulate the statistical inference of relative stake in one epoch (
Σ
Equation
 time-slots) of the leader election process with parameter 
Σ
Equation
, we sampled 
Σ
Equation
 random (stake) values from the Pareto distribution with shape parameter 
Σ
Equation
 and scale parameter 
Σ
Equation
. The histogram of (relative) stake values is given below
We consider inference only for 
Σ
Equation
 nodes with the highest relative stake and for 
Σ
Equation
 nodes with relative stake just above the threshold 
Σ
Equation
. We consider a scenario where fraction 
Σ
Equation
 of time-slots of the leader election process are observed by adversary. Here we find differences between estimators only for nodes with relative stake close to 
Σ
Equation
 as can be seen in the figures below.
Appendix
Inference of probability
The leader election process is governed by the probability distribution
📈
Equation
of the outcome of election 
Σ
Equation
, where 
Σ
Equation
 models outcome (
Σ
Equation
 loss/win) for node 
Σ
Equation
 in time-slot 
Σ
Equation
. The fraction of observed wins of node 
Σ
Equation
 in one epoch is
📈
Equation
where 
Σ
Equation
, with 
Σ
Equation
, is the total number of observations.
The average with respect to the leader election process gives us
📈
Equation
i.e. 
Σ
Equation
 is unbiased statistical estimator of prob. of winning 
Σ
Equation
. In the above 
Σ
Equation
 is the averaging “operator” defines as
📈
Equation
where 
Σ
Equation
. Since 
Σ
Equation
 and 
Σ
Equation
, from above follows that 
Σ
Equation
.
The variance of 
Σ
Equation
 is given by
📈
Equation
If 
Σ
Equation
 as 
Σ
Equation
, i.e. for a large number of observations, then 
Σ
Equation
, i.e. 
Σ
Equation
 is a consistent estimator of the prob. 
Σ
Equation
.
Let us define the new estimator of 
Σ
Equation
 as follows
📈
Equation
The average with respect to leader election process gives us
📈
Equation
i.e. the estimator 
Σ
Equation
 has (positive) bias. We expect that in the limit 
Σ
Equation
 as 
Σ
Equation
, i.e. for a large number of observations, the average 
Σ
Equation
. We note that since 
Σ
Equation
, we have that
📈
Equation
and
📈
Equation
Now, for 
Σ
Equation
 by the Markov’s inequality we have
📈
Equation
where 
Σ
Equation
. Using the definition, the average on the RHS of the above can be computed as follows
📈
Equation
Using above result in the inequality we obtain
📈
Equation
Furthermore, optimising the RHS in above with respect to 
Σ
Equation
 we obtain the inequality
📈
Equation
We note that 
Σ
Equation
 is monotonic decreasing function of 
Σ
Equation
 which is exactly zero when 
Σ
Equation
 and hence this function is negative for 
Σ
Equation
. Hence we have the following inequality
📈
Equation
where 
Σ
Equation
 when 
Σ
Equation
.
From above follows that 
Σ
Equation
 in the limit 
Σ
Equation
 as 
Σ
Equation
, i.e. for a large number of observations. Using the latter in the upper bound gives us that 
Σ
Equation
 in this limit. If in the limit of large number of observations we also have that the 
Σ
Equation
 then 
Σ
Equation
 is a consistent estimator of the prob. 
Σ
Equation
.
For 
Σ
Equation
, where we defined 
Σ
Equation
, the 
Σ
Equation
 is given by
📈
Equation
In the Variance section we show that
📈
Equation
Hence in the limit of large number of observations 
Σ
Equation
.
Thus from above follows that
📈
Equation
is unbiased and consistent estimator of the prob. 
Σ
Equation
 in the limit of large number of observations 
Σ
Equation
 as 
Σ
Equation
.
For 
Σ
Equation
 the mean squared error (MSE) of the estimator 
Σ
Equation
 is given by
📈
Equation
Assuming that the 
Σ
Equation
 variables are exactly the same as in the above, the MSE of the estimator 
Σ
Equation
 is given by
📈
Equation
Consider the difference
Σ
Equation
 as follows
📈
Equation
Now the last line in the above can be bounded as follows
📈
Equation
Hence
📈
Equation
Thus, the MSE of the unbiased estimator 
Σ
Equation
 is greater that the MSE of the biased, but consistent, estimator 
Σ
Equation
.
Variance of 
Σ
Equation
For 
Σ
Equation
, where 
Σ
Equation
, we consider the variance
📈
Equation
First, we consider the covariance
📈
Equation
Because of 
Σ
Equation
, from the above it follows that 
Σ
Equation
.
Second, we consider the variance
📈
Equation
Thus, from the above it follows that 
Σ
Equation
. The latter with 
Σ
Equation
 implies 
Σ
Equation
 which using the variance equation gives us that
📈
Equation
Open in new tab
