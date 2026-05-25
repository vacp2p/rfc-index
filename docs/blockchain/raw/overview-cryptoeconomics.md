# OVERVIEW-CRYPTOECONOMICS

| Field | Value |
| --- | --- |
| Name | [Overview] Cryptoeconomics |
| Slug | 204 |
| Status | raw |
| Category | Informational |
| Editor | Thomas Lavaur <thomaslavaur@logos.co> |
| Contributors | Marcin Pawlowski <marcin@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/overview-cryptoeconomics.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/overview-cryptoeconomics.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revisions History

> Disclamer:
> This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
>
> All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 
>
> Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

# Introduction

This document provides the formal specification for the fee collection mechanism of the Permanent Storage market. The primary objective is to define a system that is robust, predictable, and economically sustainable. This mechanism is a critical component of the overall Permanent Storage Market Transaction Fee Mechanism (TFM), which is designed as a self-contained, usage-driven market, economically decoupled from the protocol's core consensus and privacy services.

In what follows, Logos Blockchain Storage refers to the Permanent Storage markets and Logos Blockchain Storage Gas refers to the Permanent Storage Gas respectively.

## Requirements and Rationale

The mechanism is designed with the following core requirements, derived from the project's goals:

1. Predictability: Consumers of the Logos Blockchain Storage require a high degree of cost predictability for their own operational planning.
1. Robustness: The mechanism must be able to adapt to significant, medium-term shifts in demand without requiring constant, emergency governance intervention.
1. Fairness: The fee paid by a user must be directly and transparently proportional to the resources they consume.
1. Simplicity: The on-chain implementation should be as simple as possible to minimize attack surface and ensure auditability.

Justification. As will be discussed later, the tradeoff between adaptability and predictability of the mechanism is determined by its parameters. In scenarios of high volatility, its core design principle is to act as a shock absorber, deliberately filtering out high-frequency, transient volatility by operating over longer timeframes and using a smoothed moving average (EMA). For the primary consumer, reacting to every momentary spike in demand would create untenable price chaos. This model, therefore, intentionally forgoes instantaneous adaptation in favor of providing crucial timeframe-level price certainty, ensuring that fees reflect meaningful, medium-term trends rather than reacting to volatile, short-term market noise.

# Overview

The proposed fee mechanism operates on a simple but powerful principle: the price for Logos Blockchain Storage is fixed and predictable within a given timeframe (epoch for Permanent Storage), but it adjusts smoothly between timeframes based on observed network usage.

When a user submits data, a fee is calculated based on the Logos Blockchain Storage Gas consumption. This fee is determined by a price per Gas, $P_{STR}$, which is known in advance for the entire timeframe.

At the end of each timeframe, the protocol tallies the total amount of Logos Blockchain Storage Gas that was stored. It compares this actual usage to an adaptive target—a "healthy" usage level that is itself a dynamic blend of a long-term policy goal and recent historical usage. Based on whether the actual usage was above or below this target, the price $P_{STR}$ for the next timeframe is adjusted slightly up or down.

This flow can be visualized as follows:

> **Mermaid diagram** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

This model provides the best of both worlds: users have perfect price clarity for the duration of a timeframe, while the system as a whole can gracefully adapt to evolving market conditions over time.

# Construction

This section defines the precise algorithm, constants, and state variables for the Logos Blockchain Storage TFM.

### Core Fee Equation

The fee for a Logos Blockchain Storage transaction, $F_{\text{STR}}$, is a linear function of Logos Blockchain Storage Gas' size, $S_{\text{gas}}$, and the price-per-gas for the current timeframe, $P_{\text{STR}}(s)$.

$$
F_{\text{STR}} = S_{\text{gas}} \cdot P_{\text{STR}}(s)
$$

As a remark, the equation above assumes a linear increase of $F_\text{STR}$ with respect to $S_\text{gas}$. For completeness, a more general version can be

$$
\begin{align*}
F_\text{STR}=f(S_\text{gas})\cdot P_\text{STR}
\end{align*}
$$

with $f:\mathbb{N}\to\mathbb{R}_+$ a monotonically increasing function. Making f sublinear can be understood as accounting for economies of scale, while making $f$ superlinear can be understood as a penalization for using larger data sizes. We decided to go with the linear form of $f$ as it was the least opinionated. Examples of this could be

$$
\begin{align*}
F_\text{STR}^\text{exp}&=\exp(\alpha S_\text{gas})\cdot P_\text{STR}\quad \alpha >0\\
F_\text{poly}^\text{exp}&=S^\beta_\text{gas}\cdot P_\text{STR},\quad \beta>1\\
\end{align*}
$$

### Protocol Constants

To ensure on-chain efficiency, the protocol shall use an Exponential Moving Average (EMA) for its adaptive target calculation. The behavior of the TFM is governed by the following on-chain constants, which are set at genesis.

### Parameter Justification

- For simplicity, we set $T_\text{base}=0$ as an anchor and $w=0$ as blocks are already constrained by execution. This is to avoid imposing an opinionated choice of parameters, specially at the beginning of the protocol.
- The EMA factor ($\beta=0.5$) makes the adaptive target highly sensitive to recent network activity by giving 50% weight to the latest session's usage, creating an effective "memory" of approximately 3 epochs.
- The maximum adjustment factor ($\alpha=0.125$) provides a crucial layer of predictability, guaranteeing users that the price cannot change by more than 12.5% between any two epochs, thus fulfilling a core design requirement for stable operational planning.
- The seed value for the EMA is set to $T_{\text{RA}}(-1) = T_{\text{base}} = 0$.  Given $T_{\text{base}} = 0$, this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset.
- The precise value of $P_{\text{STR}}(0)$ is not critical to the long-term behavior of the mechanism. As established in the equilibrium analysis, the price update rule converges autonomously to the market-clearing price $P^*$ regardless of the starting point, provided the stability condition $(*)$ holds (see [🔀[1.0.0][Analysis] Storage Market - Price Stability Analysis](https://nomos-tech.notion.site/Price-Stability-Analysis-a03261aa09df83f6bcd6815ba73b72e1?pvs=24#fed261aa09df8241b79c01ca67ef6026)). The only hard requirement is for $P_{\text{STR}}(0)$ to be sufficiently low so as not to suppress early adoption before the mechanism has observed enough demand to self-correct.
    More precisely, since the price can increase by at most $\alpha = 12.5\%$ per epoch, the number
    of epochs required to reach a target price $P^*$ from an initial price $P_{\text{STR}}(0) < P^*$ is bounded above by:
    $$
    N \leq \left\lceil \log_{1+\alpha}\!\left(\frac{P^*}{P_{\text{STR}}(0)}\right) \right\rceil
    = \left\lceil \frac{\ln(P^*/P_{\text{STR}}(0))}{\ln(1.125)} \right\rceil
    $$
    For example, if $P_{\text{STR}}(0)$ is set to one tenth of the true equilibrium price, the mechanism reaches $P^*$ within at most $\lceil \ln(10)/\ln(1.125) \rceil = 20$ epochs. Starting
    one hundredth below requires at most $40$ epochs. Both are negligible relative to the expected lifetime of the network.
    We therefore set:
    $$
    P_{\text{STR}}(0) = 1\ \text{LGO per Permanent Storage Gas}
    $$

This corresponds to a cost of 1 LGO per permanently stored byte. Genesis governance may adjust this value based on the LGO price at TGE, but the adjustment has no long-term consequence: the mechanism will converge to the true market price $P^*$ within $O(\log P^*/P_{\text{STR}}(0))$ epochs regardless.

- The timeframe $s$ corresponds to one epoch. The core reason is that the primary users of the Storage market plan operational costs over days or weeks, not block-by-block. An epoch-length timeframe provides price certainty over hundreds of blocks, directly fulfilling the predictability requirement. It also ensures the EMA aggregates a meaningful volume of usage data before influencing the price, rather than reacting to per-block noise.

### State Variables

The protocol must maintain the following state variables, updated at the end of each timeframe:

### Price Update Algorithm

At the conclusion of each timeframe $s$, the protocol shall execute the following algorithm to determine the price for the next timeframe, $P_{\text{STR}}(s+1)$. This is done as follows.

1. Tally Usage: Aggregate the total Logos Blockchain Storage Gas consumed during timeframe $s$ into a final value, $C_\text{usage}(s)$:

$$
C_{\text{usage}}(s)=\sum_{t\in\mathcal{B}_s}\mathsf{StorageGasUsed}[t]
$$

Where $\mathcal{B}_s$ corresponds to one block in timeframe $s$ and $\mathsf{StorageGasUsed}[t]$ corresponds to the Logos Blockchain Storage Gas used by transaction $t$.

1. Update Usage EMA: Update the Exponential Moving Average of usage.

$$
T_{\text{RA}}(s) = \beta \cdot C_{\text{usage}}(s) + (1-\beta) \cdot T_{\text{RA}}(s-1)
$$

1. Calculate Effective Target: Calculate the blended, effective target, $T_{\text{effective}}(s)$.

$$
T_{\text{effective}}(s) = w \cdot T_{\text{base}} + (1-w) \cdot T_{\text{RA}}(s)
$$

1. Calculate Adjustment Factor: Determine the fractional deviation of usage from the target and clamp the result to the range $[-\alpha, \alpha]$.

$$
\text{adjustment}(s) = \frac{C_{\text{usage}}(s) - T_{\text{effective}}(s)}{T_{\text{effective}}(s)}
$$

$$
\text{clamped\_adjustment}(s) = \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}
$$

1. Update Price: Calculate the price for the next timeframe, $s+1$​

$$
P_{\text{STR}}(s+1) = P_{\text{STR}}(s) \cdot [1 + \text{clamped\_adjustment}(s)]
$$

### Implementation

Because computation affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.

The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. To we provide here a reference implementation that uses unsigned integers to have a common reference.

First because we have $w = 0$, $T_\text{RA}(s) = T_\text{effective}(s)$. Then because $\beta=0.5$​

$$
T_{\mathrm{RA}}(s)=\frac{C_{\mathrm{usage}}(s)+T_{\mathrm{RA}}(s-1)}{2}
$$

Secondly, we can rewrite $P_\text{STR}$ equation:

$$
\begin{align*}
P_{\text{STR}}(s+1) &= P_{\text{STR}}(s) \cdot [1 + \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}]\\
&= P_{\text{STR}}(s) \cdot \max \{ 1-\alpha, \min \{ 1+ \alpha, 1+\text{adjustment}(s) \} \}\\
&= P_{\mathrm{STR}}(s)\cdot
\max\left\{\frac78,\min\left\{\frac98,\,
\frac{C_{\mathrm{usage}}(s)}{T_{\mathrm{RA}}(s)}
\right\}\right\}
\end{align*}
$$

and so:

$P_{\mathrm{STR}}(s+1)=\begin{cases}\left\lfloor P_{\mathrm{STR}}(s)\cdot \frac78 \right\rfloor,& \text{if } 8\,C_{\mathrm{usage}}(s)\le 7\,T_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P_{\mathrm{STR}}(s)\cdot \frac98 \right\rfloor,& \text{if } 8\,C_{\mathrm{usage}}(s)\ge 9\,T_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P_{\mathrm{STR}}(s)\cdot\frac{C_{\mathrm{usage}}(s)}{T_{\mathrm{RA}}(s)} \right\rfloor,& \text{otherwise.}\end{cases}$​

and so we can derive the following reference code:

```
EMA_DENOMINATOR = 2         # 1/beta
CLAMP_DENOMINATOR = 8       # denominator of 1+ alpha and 1-alpha
CLAMP_DOWN_NUMERATOR = 7    # numerator of 1-alpha
CLAMP_UP_NUMERATOR = 9      # numerator of 1+alpha

def update_usage(total_gas_consumed: int, previous_usage: int) -> int:
return (total_gas_consumed + previous_usage) // EMA_DENOMINATOR

def update_storage_price(prev_price: int, total_gas_consumed: int, usage: int) -> int:
if CLAMP_DENOMINATOR * total_gas_consumed <= CLAMP_DOWN_NUMERATOR * usage:
return prev_price * CLAMP_DOWN_NUMERATOR // CLAMP_DENOMINATOR
    elif CLAMP_DENOMINATOR * total_gas_consumed >= CLAMP_UP_NUMERATOR * usage:
return prev_price * CLAMP_UP_NUMERATOR // CLAMP_DENOMINATOR
else:
return prev_price * total_gas_consumed // usage

def update_storage_fee(total_gas_consumed: int, prev_price: int, prev_usage: int) -> tuple[int, int]:
    usage = update_usage(total_gas_consumed, prev_usage)
    price = update_storage_price(prev_price, total_gas_consumed, usage)
return price, usage
```

### Genesis State

The initial state of the TFM at network launch shall be configured as follows:

- Initial Price P_STR(0): Set to a pre-determined value established by genesis governance.
- Initial Usage EMA T_RA(-1): Set to the value of the baseline target, $T_{\text{base}}$. This anchors the mechanism to its long-term policy goal from the outset.

