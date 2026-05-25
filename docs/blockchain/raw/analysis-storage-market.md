# ANALYSIS-STORAGE-MARKET

| Field | Value |
| --- | --- |
| Name | [Analysis] Storage Market |
| Slug | 197 |
| Status | raw |
| Category | Informational |
| Editor | Juan Pablo Madrigal-Cianci <jp@logos.co> |
| Contributors | Frederico Teixeira <frederico@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-storage-market.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-storage-market.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

> Disclamer:
> This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
>
> All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 
>
> Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

# Introduction

This document provides a formal mathematical analysis of the proposed fee mechanism. We model the price update rule as a discrete-time dynamical system to evaluate its stability, long-term behaviour, and incentive properties rigorously.

# System Dynamics and Equilibrium

Let's define the state of the system at the end of timeframe $s$ by the price $P_s$ and the usage EMA, $T_{\text{RA}, s}$. The core of the mechanism is the price update rule:

$$
P_{s+1} = P_s \cdot \left(1 + \text{clamped\_adjustment}(s)\right)
$$

Where the adjustment is a function of the timeframe's usage, $C_s$. For this analysis, let's assume usage $C_s$ is a function of the price, $C(P_s)$, where $C' < 0$ (demand decreases as price increases).

The system is in equilibrium when the price no longer changes between timeframes, i.e., $P_{s+1} = P_s$. This occurs if and only if the clamped_adjustment term is zero. This condition implies:

$$
C(P^*) = T_{\text{effective}}(P^*)
$$

where $P^*$ is the equilibrium price. The effective target itself depends on the usage EMA, which at equilibrium will have stabilized such that $T_{\text{RA}, s} = T_{\text{RA}, s-1} = C(P^*)$. Substituting this into the effective target equation:

$$
T_{\text{effective}}(P^*) = w \cdot T_{\text{base}} + (1-w) \cdot C(P^*)
$$

Therefore, the equilibrium condition simplifies to:

$$
\begin{align*}
C(P^*) &= w \cdot T_{\text{base}} + (1-w) \cdot C(P^*)\\
w \cdot C(P^*) &= w \cdot T_{\text{base}}\\
\implies& {C(P^*) = T_{\text{base}}}
\end{align*}
$$

Conclusion: The system is designed to reach equilibrium when the long-term average usage, dictated by the market's demand curve $C(P)$, equals the static, governance-set baseline target $T_{\text{base}}$ (note that by governance we refer to clients and protocol design, not on-chain governance). The equilibrium price $P^*$ is therefore the price that induces exactly $T_{\text{base}}$ Gas of usage from the market. This proves that the parameter $T_{\text{base}}$ acts as the effective long-term controller of network usage.

# Price Stability Analysis

Stability determines whether the system will naturally converge to the equilibrium price $P^*$ after a shock. We can analyze this by examining how a small deviation from equilibrium evolves.

Let's consider the un-clamped adjustment for simplicity, as the clamping factor $\alpha$ only serves to dampen the dynamics and enhance stability. The price update function is:

$$
P_{s+1} = P_s \left(1 + \frac{C(P_s) - T_{\text{effective}, s}}{T_{\text{effective}, s}}\right) = P_s \frac{C(P_s)}{T_{\text{effective}, s}}
$$

To analyze the stability around the equilibrium $P^*$, we can linearize this system. Let's find the derivative of $P_{s+1}$ with respect to $P_s$ and evaluate it at $P^*$. A system is stable if the absolute value of this derivative is less than 1.

$$
\frac{dP_{s+1}}{dP_s} \bigg|_{P=P^*} = \frac{C(P^*)}{T_{\text{effective}}(P^*)} + P^* \frac{C'(P^*)T_{\text{effective}}(P^*) - C(P^*)T'_{\text{effective}}(P^*)}{T_{\text{effective}}(P^*)^2}
$$

At equilibrium, $C(P^*) = T_{\text{effective}}(P^*) = T_{\text{base}}$. The expression simplifies to:

$$
= 1 + P^* \frac{C'(P^*)T_{\text{base}} - T_{\text{base}}T'_{\text{effective}}(P^*)}{T_{\text{base}}^2} = 1 + \frac{P^*}{T_{\text{base}}}(C'(P^*) - T'_{\text{effective}}(P^*))
$$

The derivative of the effective target is $T'_{\text{effective}}(P^*) = (1-w) \cdot \beta \cdot C'(P^*)$. Substituting this in:

$$
\begin{align*}
&= 1 + \frac{P^*}{T_{\text{base}}}(C'(P^*) - (1-w)\beta C'(P^*))\\
&= 1 + \frac{P^* C'(P^*)}{T_{\text{base}}}(1 - (1-w)\beta)
\end{align*}
$$

For stability, we require $\left| \frac{dP_{s+1}}{dP_s} \right| < 1$, which means:

$$
-2 < \frac{P^* C'(P^*)}{T_{\text{base}}}(1 - (1-w)\beta) < 0
$$

Since $C'(P^*) < 0$ (demand falls with price) and $(1 - (1-w)\beta) > 0$ for reasonable parameter choices, the right-hand inequality is always satisfied. The left-hand inequality defines the stability condition:

$$
\tag{*}{\left| \frac{P^* C'(P^*)}{T_{\text{base}}} \right| < \frac{2}{1 - (1-w)\beta}}
$$

The term on the left is the price elasticity of demand at equilibrium.

Conclusion: The system is guaranteed to be stable if the elasticity of demand is not excessively high (see Eq. $(*)$  above), i.e., if the market is so sensitive that a small price increase to curb overuse causes a demand crash so severe that the system begins to oscillate uncontrollably.  The parameters ${1-w}$ and $\beta$ directly contribute to stability; higher values (stronger anchor, faster EMA) relax the stability condition, making the system robust against a wider range of market behaviors. The clamping factor ${\alpha}$ provides an additional, powerful guarantee of stability by bounding the adjustment step, ensuring that even under extreme demand shocks, the price cannot diverge uncontrollably.

> If Equation $(*)$ wouldn’t hold, this just cause price to become more unpredictable. That said, we have the levers of $w$, $\beta$ and $\alpha$ to adjust should this be the case. Specifically,  $\alpha$ privdes a hard limit in the amount that these storage fees can increase and decrease by, hence reducing this unpredictability.

# Long-Term Price Behavior Under Demand Shifts

Consider a permanent upward shift in demand, where a new demand curve $\tilde{C}(P)$ replaces $C(P)$ such that $\tilde{C}(P) > C(P)$ for all $P$.

Immediately after the shift, usage will be consistently above the effective target. The price update rule will cause $P_s$ to increase in each timeframe. At the end of this first high-usage session, the protocol observes the overuse. This single event triggers two parallel responses:

1. Usage $\tilde{C}(P_s)$ will begin to decrease due to the higher price.
1. The usage EMA, $T_{\text{RA},s}$, will rise, pulling the effective target $T_{\text{effective},s}$ upwards.

This begins a "chasing" dynamic across subsequent sessions. As long as the new, higher demand persists, usage will likely remain above the (now rising) effective target. Each session's high usage continues to send the same two signals to the protocol: "increase the price" and "increase the EMA." The system will seek a new equilibrium price $\tilde{P}^*$ where $\tilde{C}(\tilde{P}^*) = T_{\text{base}}$. Since $\tilde{C} > C \text{ and } T_{\text{base}}$ is constant, it must be that $\tilde{P}^* > P^*.$

The anchor weight ${w}$ is critical here. If $w=0$ (no anchor), the equilibrium condition becomes $C(P^*) = T_{\text{RA}}$, which means the target would simply follow the demand, and the price would not effectively respond to the new normal. The non-zero anchor weight $w$ ensures the system always feels a "pull" back towards the governance-set target $T_{\text{base}}$, forcing the price to adjust until usage realigns with this long-term policy goal.

Conclusion: The mechanism is proven to autonomously guide the market to a new, stable equilibrium price that respects the long-term usage target, even in the face of permanent shifts in market demand. It avoids the failure modes of purely static models (which would see chronic overuse) and purely adaptive models (which would normalize the new, higher usage level instead of controlling it).

