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

This document explains the rationale behind the parameter values proposed in [🔀[1.0.0] Block Rewards](https://nomos-tech.notion.site/1-0-0-Block-Rewards-d96261aa09df838ca36601b4b27b49b4?pvs=24).

The block reward mechanism adjusts the protocol’s token emission rate based on on-chain signals such as the deviation of the inferred total stake from its target and the moving average of the fee-burning rate. The parameters calibrated here control how strongly the emission rate reacts to those signals, how quickly it transitions between regimes, and the bounds it must respect.

The goal of this calibration is to make incentives predictable and robust: provide sufficient security while the chain is below its target staking level, and converge toward a more stable long-run regime in which issuance is primarily constrained by fee burns rather than persistent inflation.

## The Parameter $\alpha\_d$ ​

The normalized deviation from target, namely $\delta\_t$ , is measured in percentage units.

The parameter $\alpha\_d$ , defined [here](/d96261aa09df838ca36601b4b27b49b4?pvs=25), can be described as the “unit of emission rate per unit of target deviation”. This parameter should be defined based on the expected variance of the KPI with respect to the target.

For the sake of an example, let's set $\alpha\_d = 1$ , $\alpha\_a=0$ , $I\_{min}=0\%$ , and $I\_{max}=1\%$ .

The figure below shows a KPI whose deviation around the target has a standard deviation $1$ .

![](/image/attachment%3Ad4a327d9-4476-4082-bc55-3f1851e1b281%3AScreenshot_2025-07-29_at_12.35.22.png?table=block&id=995261aa-09df-83eb-9bd6-8147e7b7403b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 2

ALT

As a consequence, the emission rate $I\_t$ frequently reaches the maximum value.

![](/image/attachment%3A8525cc9f-0120-4533-8a50-785c8a02d884%3AScreenshot_2025-07-29_at_12.35.48.png?table=block&id=5a7261aa-09df-826e-8a19-814f8697368d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 3

ALT

Let's now consider a scenario where the volatility of the KPI deviation decreases to $0.1$ . The figure below shows an example (the difference in the signal oscillation with respect to Figure 2 is very subtle).

![](/image/attachment%3Acc6044a2-6fc4-4923-9d86-d6e26e29b00f%3AScreenshot_2025-07-29_at_12.36.24.png?table=block&id=8d5261aa-09df-8386-9ae9-01565c543c16&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 4

ALT

As a consequence, all else equal, the annualized token emission rate becomes considerably less volatile.

![](/image/attachment%3A79138903-054b-44e0-952d-5555eae398ad%3AScreenshot_2025-07-29_at_12.37.15.png?table=block&id=ba2261aa-09df-8226-a76d-815ed44a09c9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 5

ALT

The parameter $\alpha\_d$ also controls the sensitivity of the normalized deviation from target ( $\delta\_t$ ) in the [emission rate factor function](/d96261aa09df838ca36601b4b27b49b4?pvs=25#3f1261aa09df82a38e5181140f0e091c) ( $A\_t$ ):

If $\alpha\_d$ is too high, for example $\alpha\_d>1$ , a small value of $\delta\_t$ turns $A\_t$ to 1, so that the system stays in the maximum inflationary regime driven by $I\_{max}$ , see equation [(1)](/d96261aa09df838ca36601b4b27b49b4?pvs=25#820261aa09df83949c400177c46b2514).

If $\alpha\_d$ is too low, for example $\alpha\_d = 0.01$ , the system needs to be too much off-target to stay in the maximum inflationary regime driven by $I\_{max}$ .

The parameter $\alpha\_d$ therefore allows for a smooth transition from the maximum inflationary regime (driven by $I\_{max}$ ) to the stable regime (driven by the averaged burned fees).

The value $\alpha\_d=1/6$ is chosen so that when the total inferred stake is off target by $16.6\%$ (i.e. $\delta\_t=16.6\%$ ), the system starts moving from the maximum inflationary regime to the regime driven by the burned fees. If $D\_{0,target}=30\%$ , this means that this happens when the security level reaches $25\%$ .

### The Parameter $\alpha\_a$ ​

The weighted average metric, namely $\gamma\_t$ , is measured in percentage units.

The parameter $\alpha\_a$ , defined [here](/d96261aa09df838ca36601b4b27b49b4?pvs=25), can be described as the "unit of emission rate per unit of averaged KPI." This parameter should be defined based on the expected magnitude of the KPI.

For the sake of an example, let's set $\alpha\_d = 0$ , $\alpha\_a=1$ , $I\_{min}=0\%$ , and $I\_{max}=1\%$ .

The figure below shows a KPI whose deviation around the target has a standard deviation of $100\%.$ ​

![](/image/attachment%3A0bc68e9c-e88e-4609-8816-68ded1107f78%3AScreenshot_2025-07-29_at_12.45.04.png?table=block&id=14d261aa-09df-836c-8f08-015f805d66de&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 6

ALT

As a consequence of the parametrization, specifically $\alpha\_a=1$ , the emission rate $I\_t$ never reaches the maximum value.

![](/image/attachment%3A0aacf5b4-424e-4c51-8c53-cad4e4a5bdcc%3AScreenshot_2025-07-29_at_12.45.39.png?table=block&id=577261aa-09df-838c-b2f4-01601bb47ec3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 7

ALT

If we set $\alpha\_a=2$ , then the emission rate $I\_t$ reaches the maximum value, but never surpasses it.

![](/image/attachment%3Ab40b6e96-ed78-4142-8913-da0e374eca0e%3AScreenshot_2025-07-29_at_12.46.25.png?table=block&id=d82261aa-09df-82cb-a169-81f733cc62ab&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Figure 8

ALT

### The Inferred Total Stake ( $D\_{0,target}$ )

This section explains the rationale for defining the target $\text{Security Level}$ as $30\%$ of the TGE supply.

The TGE supply of the LGO token has to account for:

The tokens disbursed as rewards to team, investors, ecosystem, etc. (subject to different vesting schemes),

The security of the blockchain.

Access to the blockchain utility.

The first allocation is fixed. The second and third should be balanced to ensure sufficient security while facilitating access to the blockchain utility.

Assuming a constant growth rate of the inferred total stake:

if $\text{Security Level}$ is too high, the inferred total stake will take longer to achieve the predefined target → resulting in more token inflation before the regime stabilizes around the burning rate.

if $\text{Security Level}$ is too low, the inferred total stake will take less time to achieve the predefined target → resulting in less token inflation before the regime stabilizes around the burning rate.

There is no closed formula for defining the appropriate $\text{Security Level}$ . Our rationale was guided by observations from existing blockchains.

This [website](https://www.stakingrewards.com/assets/proof-of-stake?sort=real_reward_rate&timeframe=7d&order=asc&byChange=false&columns=staking_ratio%2Creal_reward_rate%2Ctotal_roi_365d%2Cinflation_rate) shows the PoS participation ratio of several blockchains. When examining chains that haven't defined a $\text{Security Level}$ upfront, we observe a negative correlation between utility in the chain and staked amount (at the time of writing). This means that for Logos Blockchain, which aims to become a chain with utility, data suggests that a very high $\text{Security Level}$ (e.g., $> 50\%$ ) is not recommended.

On the other hand, data also shows that many blockchains have their $\text{Security Level}$ in the range of $30\%-50\%$ . Given that the proposed token emission mechanism is pegged to the deviation from the $\text{Security Level}$ target, the decision to peg the system behavior to the lower end of this range is meant to stop token inflation sooner.

### The Burning Rate Average Factor ( $D\_{1,target}$ )

As already described above, $D\_{1,target}$ is taken to be equal to $S\_{tge}$ so that $\gamma\_t$ evaluates the annualized average burning rate with respect to the TGE supply. This makes the equation [above](/d96261aa09df838ca36601b4b27b49b4?pvs=25#a0b261aa09df8315811301dd66c6660c) consistent.

### Maximum Emission Rate ( $I\_{max}$ )

The maximum emission rate $I\_{max}$ caps only the number of tokens that will be minted per year by the block reward protocol. It is unrelated to the tokens that will be burned over the same period. The following information is available:

The net inflation/deflation rate is the difference between the actual emission rate and the actual burning rate. By thinking in terms of $I\_{max}$ , we consider the worst-case minting scenario.

Various sources indicate that gold's inflation rate, defined as the total increase in supply compared to existing stock, ranges from $1\% - 2\%$ per year.

$I\_{max}$ is the main variable that impacts the nodes' APY, while the inferred total stake is below the target security level.

Analysis of other blockchain networks indicates that an $8\%$ emission rate is excessively high.

A burning rate between $1\%-2\%$ is feasible for chains with very high demand.

If Logos Blockchain features similar issuance behavior as gold, when operating under an (net) inflationary regime, then the following conclusions can be reached:

$I\_{max} < 1\%$ is too conservative. There is insufficient evidence to support such a recommendation.

$I\_{max} = 1\% - 3\%$ per year is moderate. Although spikes in the burn rate may make the system too deflationary and unpredictable, these are not expected to be common.

$I\_{max}=3\% - 5\%$ per year is moderate, but risks overpaying for security. Logos Blockchain would need an average $2\%$ burning rate to achieve a reasonable net inflation rate (similar to gold). However, given the target security level of $30\%$ , this range would distribute $10\%$ to $16.6\%$ APY to nodes (see [Table 1](/d96261aa09df838ca36601b4b27b49b4?pvs=25) below), which would currently place Logos Blockchain in the top $10\%$ (see Real Reward Rate [here](https://www.stakingrewards.com/assets/proof-of-stake?sort=real_reward_rate&timeframe=7d&order=desc&byChange=false&columns=staking_ratio%2Creal_reward_rate%2Ctotal_roi_365d%2Cinflation_rate)).

$I\_{max}> 5\%$ per year is aggressive. Values above $5\%$ should be justified by very high expected usage of the blockchain, which would cause high burning rates. Given the cyclical behavior of economic activity, this may trigger hyperinflation.

Constraining $I\_{max}$ to the range $[1\%, 3\%]$ , the decision for $I\_{max} = 1\%$ is taken so that the rewards APY stabilizes around $3.34\%$ (see [Table 1](/d96261aa09df838ca36601b4b27b49b4?pvs=25)) as the inferred total stake approaches the target security level.

### Minimum Emission Rate ( $I\_{min}$ )

The recommendation is $I\_{min} = 0$ . While $I\_{min} > 0$ has a slight inflationary bias and $I\_{min} < 0$ a slight deflationary bias, both need a strong argument to be defined. There is currently no evidence for $I\_{min} \neq 0$ .
