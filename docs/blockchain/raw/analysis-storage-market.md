# ANALYSISSTORAGE-MARKET

| Field | Value |
| --- | --- |
| Name | [Analysis] Storage Market |
| Slug |  |
| Status | raw |
| Category | Informational |
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
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision
	
2026-04-24
❗
Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.

All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 

Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.
Introduction
This document provides a formal mathematical analysis of the proposed fee mechanism. We model the price update rule as a discrete-time dynamical system to evaluate its stability, long-term behaviour, and incentive properties rigorously.
System Dynamics and Equilibrium
Let's define the state of the system at the end of timeframe 
𝑠
s by the price 
𝑃
𝑠
P
s
	​

 and the usage EMA, 
𝑇
RA
,
𝑠
T
RA,s
	​

. The core of the mechanism is the price update rule:
𝑃
𝑠
+
1
=
𝑃
𝑠
⋅
(
1
+
clamped_adjustment
(
𝑠
)
)
P
s+1
	​

=P
s
	​

⋅(1+clamped_adjustment(s))
Where the adjustment is a function of the timeframe's usage, 
𝐶
𝑠
C
s
	​

. For this analysis, let's assume usage 
𝐶
𝑠
C
s
	​

 is a function of the price, 
𝐶
(
𝑃
𝑠
)
C(P
s
	​

), where 
𝐶
′
<
0
C
′
<0 (demand decreases as price increases).
The system is in equilibrium when the price no longer changes between timeframes, i.e., 
𝑃
𝑠
+
1
=
𝑃
𝑠
P
s+1
	​

=P
s
	​

. This occurs if and only if the clamped_adjustment term is zero. This condition implies:
𝐶
(
𝑃
∗
)
=
𝑇
effective
(
𝑃
∗
)
C(P
∗
)=T
effective
	​

(P
∗
)
where 
𝑃
∗
P
∗
 is the equilibrium price. The effective target itself depends on the usage EMA, which at equilibrium will have stabilized such that 
𝑇
RA
,
𝑠
=
𝑇
RA
,
𝑠
−
1
=
𝐶
(
𝑃
∗
)
T
RA,s
	​

=T
RA,s−1
	​

=C(P
∗
). Substituting this into the effective target equation:
𝑇
effective
(
𝑃
∗
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
𝐶
(
𝑃
∗
)
T
effective
	​

(P
∗
)=w⋅T
base
	​

+(1−w)⋅C(P
∗
)
Therefore, the equilibrium condition simplifies to:
𝐶
(
𝑃
∗
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
𝐶
(
𝑃
∗
)


𝑤
⋅
𝐶
(
𝑃
∗
)
	
=
𝑤
⋅
𝑇
base


  
⟹
  
	
𝐶
(
𝑃
∗
)
=
𝑇
base
C(P
∗
)
w⋅C(P
∗
)
⟹
	​

=w⋅T
base
	​

+(1−w)⋅C(P
∗
)
=w⋅T
base
	​

C(P
∗
)=T
base
	​

	​

Conclusion: The system is designed to reach equilibrium when the long-term average usage, dictated by the market's demand curve 
𝐶
(
𝑃
)
C(P), equals the static, governance-set baseline target 
𝑇
base
T
base
	​

 (note that by governance we refer to clients and protocol design, not on-chain governance). The equilibrium price 
𝑃
∗
P
∗
 is therefore the price that induces exactly 
𝑇
base
T
base
	​

 Gas of usage from the market. This proves that the parameter 
𝑇
base
T
base
	​

 acts as the effective long-term controller of network usage.
Price Stability Analysis
Stability determines whether the system will naturally converge to the equilibrium price 
𝑃
∗
P
∗
 after a shock. We can analyze this by examining how a small deviation from equilibrium evolves.
Let's consider the un-clamped adjustment for simplicity, as the clamping factor 
𝛼
α only serves to dampen the dynamics and enhance stability. The price update function is:
𝑃
𝑠
+
1
=
𝑃
𝑠
(
1
+
𝐶
(
𝑃
𝑠
)
−
𝑇
effective
,
𝑠
𝑇
effective
,
𝑠
)
=
𝑃
𝑠
𝐶
(
𝑃
𝑠
)
𝑇
effective
,
𝑠
P
s+1
	​

=P
s
	​

(1+
T
effective,s
	​

C(P
s
	​

)−T
effective,s
	​

	​

)=P
s
	​

T
effective,s
	​

C(P
s
	​

)
	​

To analyze the stability around the equilibrium 
𝑃
∗
P
∗
, we can linearize this system. Let's find the derivative of 
𝑃
𝑠
+
1
P
s+1
	​

 with respect to 
𝑃
𝑠
P
s
	​

 and evaluate it at 
𝑃
∗
P
∗
. A system is stable if the absolute value of this derivative is less than 1.
𝑑
𝑃
𝑠
+
1
𝑑
𝑃
𝑠
∣
𝑃
=
𝑃
∗
=
𝐶
(
𝑃
∗
)
𝑇
effective
(
𝑃
∗
)
+
𝑃
∗
𝐶
′
(
𝑃
∗
)
𝑇
effective
(
𝑃
∗
)
−
𝐶
(
𝑃
∗
)
𝑇
effective
′
(
𝑃
∗
)
𝑇
effective
(
𝑃
∗
)
2
dP
s
	​

dP
s+1
	​

	​

	​

P=P
∗
	​

=
T
effective
	​

(P
∗
)
C(P
∗
)
	​

+P
∗
T
effective
	​

(P
∗
)
2
C
′
(P
∗
)T
effective
	​

(P
∗
)−C(P
∗
)T
effective
′
	​

(P
∗
)
	​

At equilibrium, 
𝐶
(
𝑃
∗
)
=
𝑇
effective
(
𝑃
∗
)
=
𝑇
base
C(P
∗
)=T
effective
	​

(P
∗
)=T
base
	​

. The expression simplifies to:
=
1
+
𝑃
∗
𝐶
′
(
𝑃
∗
)
𝑇
base
−
𝑇
base
𝑇
effective
′
(
𝑃
∗
)
𝑇
base
2
=
1
+
𝑃
∗
𝑇
base
(
𝐶
′
(
𝑃
∗
)
−
𝑇
effective
′
(
𝑃
∗
)
)
=1+P
∗
T
base
2
	​

C
′
(P
∗
)T
base
	​

−T
base
	​

T
effective
′
	​

(P
∗
)
	​

=1+
T
base
	​

P
∗
	​

(C
′
(P
∗
)−T
effective
′
	​

(P
∗
))
The derivative of the effective target is 
𝑇
effective
′
(
𝑃
∗
)
=
(
1
−
𝑤
)
⋅
𝛽
⋅
𝐶
′
(
𝑃
∗
)
T
effective
′
	​

(P
∗
)=(1−w)⋅β⋅C
′
(P
∗
). Substituting this in:
	
=
1
+
𝑃
∗
𝑇
base
(
𝐶
′
(
𝑃
∗
)
−
(
1
−
𝑤
)
𝛽
𝐶
′
(
𝑃
∗
)
)


	
=
1
+
𝑃
∗
𝐶
′
(
𝑃
∗
)
𝑇
base
(
1
−
(
1
−
𝑤
)
𝛽
)
	​

=1+
T
base
	​

P
∗
	​

(C
′
(P
∗
)−(1−w)βC
′
(P
∗
))
=1+
T
base
	​

P
∗
C
′
(P
∗
)
	​

(1−(1−w)β)
	​

For stability, we require 
∣
𝑑
𝑃
𝑠
+
1
𝑑
𝑃
𝑠
∣
<
1
	​

dP
s
	​

dP
s+1
	​

	​

	​

<1, which means:
−
2
<
𝑃
∗
𝐶
′
(
𝑃
∗
)
𝑇
base
(
1
−
(
1
−
𝑤
)
𝛽
)
<
0
−2<
T
base
	​

P
∗
C
′
(P
∗
)
	​

(1−(1−w)β)<0
Since 
𝐶
′
(
𝑃
∗
)
<
0
C
′
(P
∗
)<0 (demand falls with price) and 
(
1
−
(
1
−
𝑤
)
𝛽
)
>
0
(1−(1−w)β)>0 for reasonable parameter choices, the right-hand inequality is always satisfied. The left-hand inequality defines the stability condition:
	
∣
𝑃
∗
𝐶
′
(
𝑃
∗
)
𝑇
base
∣
<
2
1
−
(
1
−
𝑤
)
𝛽
		
(*)
	​

T
base
	​

P
∗
C
′
(P
∗
)
	​

	​

<
1−(1−w)β
2
	​

(*)
The term on the left is the price elasticity of demand at equilibrium.
Conclusion: The system is guaranteed to be stable if the elasticity of demand is not excessively high (see Eq. 
(
∗
)
(∗)  above), i.e., if the market is so sensitive that a small price increase to curb overuse causes a demand crash so severe that the system begins to oscillate uncontrollably.  The parameters 
1
−
𝑤
1−w and 
𝛽
β directly contribute to stability; higher values (stronger anchor, faster EMA) relax the stability condition, making the system robust against a wider range of market behaviors. The clamping factor 
𝛼
α provides an additional, powerful guarantee of stability by bounding the adjustment step, ensuring that even under extreme demand shocks, the price cannot diverge uncontrollably.
If Equation 
(
∗
)
(∗) wouldn’t hold, this just cause price to become more unpredictable. That said, we have the levers of 
𝑤
w, 
𝛽
β and 
𝛼
α to adjust should this be the case. Specifically,  
𝛼
α privdes a hard limit in the amount that these storage fees can increase and decrease by, hence reducing this unpredictability.
Long-Term Price Behavior Under Demand Shifts
Consider a permanent upward shift in demand, where a new demand curve 
𝐶
~
(
𝑃
)
C
~
(P) replaces 
𝐶
(
𝑃
)
C(P) such that 
𝐶
~
(
𝑃
)
>
𝐶
(
𝑃
)
C
~
(P)>C(P) for all 
𝑃
P.
Immediately after the shift, usage will be consistently above the effective target. The price update rule will cause 
𝑃
𝑠
P
s
	​

 to increase in each timeframe. At the end of this first high-usage session, the protocol observes the overuse. This single event triggers two parallel responses:
Usage 
𝐶
~
(
𝑃
𝑠
)
C
~
(P
s
	​

) will begin to decrease due to the higher price.
The usage EMA, 
𝑇
RA
,
𝑠
T
RA,s
	​

, will rise, pulling the effective target 
𝑇
effective
,
𝑠
T
effective,s
	​

 upwards.
This begins a "chasing" dynamic across subsequent sessions. As long as the new, higher demand persists, usage will likely remain above the (now rising) effective target. Each session's high usage continues to send the same two signals to the protocol: "increase the price" and "increase the EMA." The system will seek a new equilibrium price 
𝑃
~
∗
P
~
∗
 where 
𝐶
~
(
𝑃
~
∗
)
=
𝑇
base
C
~
(
P
~
∗
)=T
base
	​

. Since 
𝐶
~
>
𝐶
 and 
𝑇
base
C
~
>C and T
base
	​

 is constant, it must be that 
𝑃
~
∗
>
𝑃
∗
.
P
~
∗
>P
∗
. 
The anchor weight 
𝑤
w is critical here. If 
𝑤
=
0
w=0 (no anchor), the equilibrium condition becomes 
𝐶
(
𝑃
∗
)
=
𝑇
RA
C(P
∗
)=T
RA
	​

, which means the target would simply follow the demand, and the price would not effectively respond to the new normal. The non-zero anchor weight 
𝑤
w ensures the system always feels a "pull" back towards the governance-set target 
𝑇
base
T
base
	​

, forcing the price to adjust until usage realigns with this long-term policy goal.
Conclusion: The mechanism is proven to autonomously guide the market to a new, stable equilibrium price that respects the long-term usage target, even in the face of permanent shifts in market demand. It avoids the failure modes of purely static models (which would see chronic overuse) and purely adaptive models (which would normalize the new, higher usage level instead of controlling it).
