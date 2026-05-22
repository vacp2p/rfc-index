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

> **Note on this import:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) rendered via katex; tables and headings
> are converted from Notion HTML. A formatting polish (semantic line breaks, code block fences
> for code samples, internal cross-references) is still recommended.

---

## Revision History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision | 2026-04-24 |

❗

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

## Introduction

This document provides a formal mathematical analysis of the proposed fee mechanism. We model the price update rule as a discrete-time dynamical system to evaluate its stability, long-term behaviour, and incentive properties rigorously.

## System Dynamics and Equilibrium

Let's define the state of the system at the end of timeframe $s$ by the price $P\_s$ and the usage EMA, $T\_{\text{RA}, s}$ . The core of the mechanism is the price update rule:

$$
P\_{s+1} = P\_s \cdot \left(1 + \text{clamped\\_adjustment}(s)\right)
$$
Ps+1​=Ps​⋅(1+clamped\_adjustment(s))

Where the adjustment is a function of the timeframe's usage, $C\_s$ . For this analysis, let's assume usage $C\_s$ is a function of the price, $C(P\_s)$ , where $C' < 0$ (demand decreases as price increases).

The system is in equilibrium when the price no longer changes between timeframes, i.e., $P\_{s+1} = P\_s$ . This occurs if and only if the

clamped\_adjustment

term is zero. This condition implies:

$$
C(P^\*) = T\_{\text{effective}}(P^\*)
$$
C(P∗)=Teffective​(P∗)

where $P^\*$ is the equilibrium price. The effective target itself depends on the usage EMA, which at equilibrium will have stabilized such that $T\_{\text{RA}, s} = T\_{\text{RA}, s-1} = C(P^\*)$ . Substituting this into the effective target equation:

$$
T\_{\text{effective}}(P^\*) = w \cdot T\_{\text{base}} + (1-w) \cdot C(P^\*)
$$
Teffective​(P∗)=w⋅Tbase​+(1−w)⋅C(P∗)

Therefore, the equilibrium condition simplifies to:

$$
\begin{align\*}
C(P^\*) &= w \cdot T\_{\text{base}} + (1-w) \cdot C(P^\*)\\
w \cdot C(P^\*) &= w \cdot T\_{\text{base}}\\
\implies& {C(P^\*) = T\_{\text{base}}}
\end{align\*}
$$
C(P∗)w⋅C(P∗)⟹​=w⋅Tbase​+(1−w)⋅C(P∗)=w⋅Tbase​C(P∗)=Tbase​​

Conclusion: The system is designed to reach equilibrium when the long-term average usage, dictated by the market's demand curve $C(P)$ , equals the static, governance-set baseline target $T\_{\text{base}}$ (note that by governance we refer to clients and protocol design, not on-chain governance). The equilibrium price $P^\*$ is therefore the price that induces exactly $T\_{\text{base}}$ Gas of usage from the market. This proves that the parameter $T\_{\text{base}}$ acts as the effective long-term controller of network usage.

## Price Stability Analysis

Stability determines whether the system will naturally converge to the equilibrium price $P^\*$ after a shock. We can analyze this by examining how a small deviation from equilibrium evolves.

Let's consider the un-clamped adjustment for simplicity, as the clamping factor $\alpha$ only serves to dampen the dynamics and enhance stability. The price update function is:

$$
P\_{s+1} = P\_s \left(1 + \frac{C(P\_s) - T\_{\text{effective}, s}}{T\_{\text{effective}, s}}\right) = P\_s \frac{C(P\_s)}{T\_{\text{effective}, s}}
$$
Ps+1​=Ps​(1+Teffective,s​C(Ps​)−Teffective,s​​)=Ps​Teffective,s​C(Ps​)​

To analyze the stability around the equilibrium $P^\*$ , we can linearize this system. Let's find the derivative of $P\_{s+1}$ with respect to $P\_s$ and evaluate it at $P^\*$ . A system is stable if the absolute value of this derivative is less than 1.

$$
\frac{dP\_{s+1}}{dP\_s} \bigg|\_{P=P^\*} = \frac{C(P^\*)}{T\_{\text{effective}}(P^\*)} + P^\* \frac{C'(P^\*)T\_{\text{effective}}(P^\*) - C(P^\*)T'\_{\text{effective}}(P^\*)}{T\_{\text{effective}}(P^\*)^2}
$$
dPs​dPs+1​​​P=P∗​=Teffective​(P∗)C(P∗)​+P∗Teffective​(P∗)2C′(P∗)Teffective​(P∗)−C(P∗)Teffective′​(P∗)​

At equilibrium, $C(P^\*) = T\_{\text{effective}}(P^\*) = T\_{\text{base}}$ . The expression simplifies to:

$$
= 1 + P^\* \frac{C'(P^\*)T\_{\text{base}} - T\_{\text{base}}T'\_{\text{effective}}(P^\*)}{T\_{\text{base}}^2} = 1 + \frac{P^\*}{T\_{\text{base}}}(C'(P^\*) - T'\_{\text{effective}}(P^\*))
$$
=1+P∗Tbase2​C′(P∗)Tbase​−Tbase​Teffective′​(P∗)​=1+Tbase​P∗​(C′(P∗)−Teffective′​(P∗))

The derivative of the effective target is $T'\_{\text{effective}}(P^\*) = (1-w) \cdot \beta \cdot C'(P^\*)$ . Substituting this in:

$$
\begin{align\*}
&= 1 + \frac{P^\*}{T\_{\text{base}}}(C'(P^\*) - (1-w)\beta C'(P^\*))\\
&= 1 + \frac{P^\* C'(P^\*)}{T\_{\text{base}}}(1 - (1-w)\beta)
\end{align\*}
$$
​=1+Tbase​P∗​(C′(P∗)−(1−w)βC′(P∗))=1+Tbase​P∗C′(P∗)​(1−(1−w)β)​

For stability, we require $\left| \frac{dP\_{s+1}}{dP\_s} \right| < 1$ , which means:

$$
-2 < \frac{P^\* C'(P^\*)}{T\_{\text{base}}}(1 - (1-w)\beta) < 0
$$
−2<Tbase​P∗C′(P∗)​(1−(1−w)β)<0

Since $C'(P^\*) < 0$ (demand falls with price) and $(1 - (1-w)\beta) > 0$ for reasonable parameter choices, the right-hand inequality is always satisfied. The left-hand inequality defines the stability condition:

$$
\tag{\*}{\left| \frac{P^\* C'(P^\*)}{T\_{\text{base}}} \right| < \frac{2}{1 - (1-w)\beta}}
$$
​Tbase​P∗C′(P∗)​​<1−(1−w)β2​(\*)

The term on the left is the price elasticity of demand at equilibrium.

Conclusion: The system is guaranteed to be stable if the elasticity of demand is not excessively high (see Eq. $(\*)$ above), i.e., if the market is so sensitive that a small price increase to curb overuse causes a demand crash so severe that the system begins to oscillate uncontrollably. The parameters ${1-w}$ and $\beta$ directly contribute to stability; higher values (stronger anchor, faster EMA) relax the stability condition, making the system robust against a wider range of market behaviors. The clamping factor ${\alpha}$ provides an additional, powerful guarantee of stability by bounding the adjustment step, ensuring that even under extreme demand shocks, the price cannot diverge uncontrollably.

⚠️

If Equation $(\*)$ wouldn’t hold, this just cause price to become more unpredictable. That said, we have the levers of $w$ , $\beta$ and $\alpha$ to adjust should this be the case. Specifically, $\alpha$ privdes a hard limit in the amount that these storage fees can increase and decrease by, hence reducing this unpredictability.

## Long-Term Price Behavior Under Demand Shifts

Consider a permanent upward shift in demand, where a new demand curve $\tilde{C}(P)$ replaces $C(P)$ such that $\tilde{C}(P) > C(P)$ for all $P$ .

Immediately after the shift, usage will be consistently above the effective target. The price update rule will cause $P\_s$ to increase in each timeframe. At the end of this first high-usage session, the protocol observes the overuse. This single event triggers two parallel responses:

Usage $\tilde{C}(P\_s)$ will begin to decrease due to the higher price.

The usage EMA, $T\_{\text{RA},s}$ , will rise, pulling the effective target $T\_{\text{effective},s}$ upwards.

This begins a "chasing" dynamic across subsequent sessions. As long as the new, higher demand persists, usage will likely remain above the (now rising) effective target. Each session's high usage continues to send the same two signals to the protocol: "increase the price" and "increase the EMA." The system will seek a new equilibrium price $\tilde{P}^\*$  where  $\tilde{C}(\tilde{P}^\*) = T\_{\text{base}}$ . Since $\tilde{C} > C \text{ and } T\_{\text{base}}$ is constant, it must be that $\tilde{P}^\* > P^\*.$

The anchor weight ${w}$ is critical here. If $w=0$ (no anchor), the equilibrium condition becomes $C(P^\*) = T\_{\text{RA}}$ , which means the target would simply follow the demand, and the price would not effectively respond to the new normal. The non-zero anchor weight $w$ ensures the system always feels a "pull" back towards the governance-set target $T\_{\text{base}}$ , forcing the price to adjust until usage realigns with this long-term policy goal.

Conclusion: The mechanism is proven to autonomously guide the market to a new, stable equilibrium price that respects the long-term usage target, even in the face of permanent shifts in market demand. It avoids the failure modes of purely static models (which would see chronic overuse) and purely adaptive models (which would normalize the new, higher usage level instead of controlling it).

\frac{dP\_{s+1}}{dP\_s} \bigg|\_{P=P^\*} = \frac{C(P^\*)}{T\_{\text{effective}}(P^\*)} + P^\* \frac{C'(P^\*)T\_{\text{effective}}(P^\*) - C(P^\*)T'\_{\text{effective}}(P^\*)}{T\_{\text{effective}}(P^\*)^2}

\tag{\*}{\left| \frac{P^\* C'(P^\*)}{T\_{\text{base}}} \right| < \frac{2}{1 - (1-w)\beta}}

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Storage Market

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Storage-Market-a03261aa09df83f6bcd6815ba73b72e1?pvs=26&qid=1:ca2c2833-9921-4c60-89f1-b7ba3932aeed:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Storage Market

Revision History

Table

❗

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

Introduction

This document provides a formal mathematical analysis of the proposed fee mechanism. We model the price update rule as a discrete-time dynamical system to evaluate its stability, long-term behaviour, and incentive properties rigorously.

System Dynamics and Equilibrium

Let's define the state of the system at the end of timeframe ΣEquation by the price ΣEquation and the usage EMA, ΣEquation. The core of the mechanism is the price update rule:

📈Equation

Where the adjustment is a function of the timeframe's usage, ΣEquation. For this analysis, let's assume usage ΣEquation is a function of the price, ΣEquation, where ΣEquation (demand decreases as price increases).

The system is in equilibrium when the price no longer changes between timeframes, i.e., ΣEquation. This occurs if and only if the clamped\_adjustment term is zero. This condition implies:

📈Equation

where ΣEquation is the equilibrium price. The effective target itself depends on the usage EMA, which at equilibrium will have stabilized such that ΣEquation. Substituting this into the effective target equation:

📈Equation

Therefore, the equilibrium condition simplifies to:

📈Equation

Conclusion: The system is designed to reach equilibrium when the long-term average usage, dictated by the market's demand curve ΣEquation, equals the static, governance-set baseline target ΣEquation (note that by governance we refer to clients and protocol design, not on-chain governance). The equilibrium price ΣEquation is therefore the price that induces exactly ΣEquation Gas of usage from the market. This proves that the parameter ΣEquation acts as the effective long-term controller of network usage.

Price Stability Analysis

Stability determines whether the system will naturally converge to the equilibrium price ΣEquation after a shock. We can analyze this by examining how a small deviation from equilibrium evolves.

Let's consider the un-clamped adjustment for simplicity, as the clamping factor ΣEquation only serves to dampen the dynamics and enhance stability. The price update function is:

📈Equation

To analyze the stability around the equilibrium ΣEquation, we can linearize this system. Let's find the derivative of ΣEquation with respect to ΣEquation and evaluate it at ΣEquation. A system is stable if the absolute value of this derivative is less than 1.

📈Equation

At equilibrium, ΣEquation. The expression simplifies to:

📈Equation

The derivative of the effective target is ΣEquation. Substituting this in:

📈Equation

For stability, we require ΣEquation, which means:

📈Equation

Since ΣEquation (demand falls with price) and ΣEquation for reasonable parameter choices, the right-hand inequality is always satisfied. The left-hand inequality defines the stability condition:

📈Equation

The term on the left is the price elasticity of demand at equilibrium.

Conclusion: The system is guaranteed to be stable if the elasticity of demand is not excessively high (see Eq. ΣEquation above), i.e., if the market is so sensitive that a small price increase to curb overuse causes a demand crash so severe that the system begins to oscillate uncontrollably. The parameters ΣEquation and ΣEquation directly contribute to stability; higher values (stronger anchor, faster EMA) relax the stability condition, making the system robust against a wider range of market behaviors. The clamping factor ΣEquation provides an additional, powerful guarantee of stability by bounding the adjustment step, ensuring that even under extreme demand shocks, the price cannot diverge uncontrollably.

⚠️

If Equation ΣEquation wouldn’t hold, this just cause price to become more unpredictable. That said, we have the levers of ΣEquation, ΣEquation and ΣEquation to adjust should this be the case. Specifically, ΣEquation privdes a hard limit in the amount that these storage fees can increase and decrease by, hence reducing this unpredictability.

Long-Term Price Behavior Under Demand Shifts

Consider a permanent upward shift in demand, where a new demand curve ΣEquation replaces ΣEquation such that ΣEquation for all ΣEquation.

Immediately after the shift, usage will be consistently above the effective target. The price update rule will cause ΣEquation to increase in each timeframe. At the end of this first high-usage session, the protocol observes the overuse. This single event triggers two parallel responses:

1. Usage ΣEquation will begin to decrease due to the higher price.
2. The usage EMA, ΣEquation, will rise, pulling the effective target ΣEquation upwards.

This begins a "chasing" dynamic across subsequent sessions. As long as the new, higher demand persists, usage will likely remain above the (now rising) effective target. Each session's high usage continues to send the same two signals to the protocol: "increase the price" and "increase the EMA." The system will seek a new equilibrium price ΣEquation where ΣEquation. Since ΣEquation is constant, it must be that ΣEquation

The anchor weight ΣEquation is critical here. If ΣEquation (no anchor), the equilibrium condition becomes ΣEquation, which means the target would simply follow the demand, and the price would not effectively respond to the new normal. The non-zero anchor weight ΣEquation ensures the system always feels a "pull" back towards the governance-set target ΣEquation, forcing the price to adjust until usage realigns with this long-term policy goal.

Conclusion: The mechanism is proven to autonomously guide the market to a new, stable equilibrium price that respects the long-term usage target, even in the face of permanent shifts in market demand. It avoids the failure modes of purely static models (which would see chronic overuse) and purely adaptive models (which would normalize the new, higher usage level instead of controlling it).

- Open in new tab
