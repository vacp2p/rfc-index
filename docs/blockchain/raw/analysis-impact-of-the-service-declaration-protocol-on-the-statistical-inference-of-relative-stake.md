# ANALYSIS-IMPACT-OF-THE-SERVICE-DECLARATION-PROTOCOL-ON-THE-STATISTICAL-INFERENCE-OF-RELATIVE-STAKE

| Field | Value |
| --- | --- |
| Name | [Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake |
| Slug | 192 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-impact-of-the-service-declaration-protocol-on-the-statistical-inference-of-relative-stake.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-impact-of-the-service-declaration-protocol-on-the-statistical-inference-of-relative-stake.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-08-22 |

# Introduction

The Service Declaration Protocol (SDP) introduces a piece of a priori information: the knowledge that a node's relative stake cannot be less than a known threshold, $\alpha_0$. Our research investigates the significance of the impact of this information on the statistical inference of relative stake. We propose a new estimator which explicitly utilises $\alpha_0$ by setting any estimated stake below this threshold to $\alpha_0$.

Our new estimator works better because it fixes estimation errors at the lower end. When a node's true stake value ($\alpha_i$) is close to the minimum threshold ($\alpha_0$), the standard maximum likelihood (ML) estimator often produces values that are too low. By automatically adjusting these too-low estimates up to the minimum threshold ($α_0$), our new approach reduces errors. This improvement can be measured as a lower mean squared error (MSE) compared to the true stake value ($\alpha_i$). Thus any party, including potential adversaries, performing stake inference gains in accuracy by using the new estimator.

Numerical experiments demonstrate reduction in MSE of the new estimator compared to the ML estimator, particularly for stakes near $α_0$. For example, for $\alpha_0=10^{-4}$ used in experiments, a reduction of MSE by a (approx.) factor of at most $1/2$ was observed. Furthermore, the probability, measured in the same experiment, that the inferred stake falls within a desired accuracy interval is higher (by factor of (approx.) $3$ at least) when the new estimator is used. While the advantage diminishes for much higher stake values where both estimators converge, the heightened accuracy near the critical $α_0$ threshold presents a meaningful enhancement for any party performing stake inference, including potential adversaries.

## Key Findings

- Introduction of a priori information: The Service Declaration Protocol (SDP) introduces the knowledge that a node's relative stake cannot be less than a threshold ($α₀$), which impacts statistical inference of relative stake⁠⁠.
- New estimator proposed: The research introduces a new estimator that explicitly uses α₀ by setting any estimated stake below this threshold to $α₀$⁠⁠.
- Improved accuracy: The new estimator performs better because it corrects estimation errors at the lower end, particularly when a node's true stake value is close to the minimum threshold⁠⁠.
- Measurable improvements: Numerical experiments show:
    - Reduction in Mean Squared Error (MSE) of the new estimator compared to the ML estimator, particularly for stakes near $α₀$⁠⁠.
    - For $α₀=10⁻⁴$, MSE reduction by a factor of approximately $1/2$ was observed⁠⁠.
    - Higher probability (by a factor of approximately 3) that inferred stake falls within desired accuracy intervals⁠⁠.
- Statistical significance: The advantage diminishes for much higher stake values where both estimators converge, but the enhanced accuracy near the critical α₀ threshold presents a meaningful improvement for any party performing stake inference⁠⁠.
- Security implications: This improvement benefits anyone performing stake inference, including potential adversaries⁠⁠.

The research provides mathematical proof and numerical simulations to validate these findings, showing that the proposed estimator is both unbiased and consistent in the limit of large number of observations⁠⁠.

# Overview

This document examines the impact of minimum stake threshold, introduced in the SDP, on the statistical inference of relative stake along the following points:

![Diagram](https://nomos-tech.notion.site/image/attachment%3Aaf3bbdfb-1a69-4f1e-a947-fc843b63d24e%3AChatGPT_Image_Jul_9_2025_12_26_01_PM.png?table=block&id=22b261aa-09df-80ae-a152-ea44acd86a1d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=350&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In particular:

1. We consider the Leader Election Process where nodes allowed to participate only if their relative stake is no less than some prescribed by SDP threshold.
1. We assume that the Adversary observes wins (and losses) of nodes and uses statistical inference to infer relative stake of nodes.
1. The Adversary knows the SDP stake threshold, and using this information, the Adversary constructs a statistical estimator.
1. This New estimator improves inference of stake when compared with an estimator which doesn’t use the SDP threshold. The simulation of adversarial inference shows that those most affected by this improvement are the nodes with values of relative stake close to the threshold.

# Analysis

## The Model

The relative stake of node $i$, $\alpha_i$, is computed via the formula $\alpha_i=w_i/\sum_{j=1}^Nw_j$, where $w_i$ is the stake of node $i$. We assume that the total stake $\sum_{j=1}^Nw_j$ can be inferred (with high accuracy) by using the [total stake inference](https://nomos-tech.notion.site/237261aa09df800285cccbb00b3aeb0a?pvs=25) algorithm.  We note that for the set $\{\alpha_1,\ldots,\alpha_N\}$, i.e. relative stakes of all nodes, it is possible that $\{\alpha_1,\ldots,\alpha_N\} = \{\alpha_i\,\vert\,\alpha_i<\alpha_0\}\cup\{\alpha_i\,\vert\,\alpha_i\geq\alpha_0\}$. It is known, through the declaration of the [Service Declaration Protocol](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25) (SDP), that the relative stake of a node is at least $\alpha_0$.  For $\alpha_i\in \{\alpha_i\,\vert\,\alpha_i\geq\alpha_0\}$, the relative stake of a node $i$ can be written as $\alpha_i=\beta_i+\alpha_0$, where $\beta_i\geq 0$ is unknown. Intuitively, this suggests that if, relative to the $\alpha_i$, the minimum stake $\alpha_0$ is large, then then there is less “uncertainty” about the relative stake $\alpha_i$.

Node $i$ participates in the leader election and its probability of winning is given by the “lottery” function

$$
\phi(\alpha_i)=1-(1-f)^{\alpha_i},
$$

where $f\in(0,1)$ is the parameter of the [consensus](https://nomos-tech.notion.site/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8139be03eb565f1e419d). Since the lottery function $\phi(\alpha_i)$ is a monotonically increasing function of relative stake, for the relative stake $\alpha_i=\beta_i+\alpha_0$ we have $\phi(\beta_i+\alpha_0)\geq \phi(\alpha_0)$, i.e. the prob. of winning for nodes with relative stake greater than $\alpha_0$ is higher.

## Inference of relative stake

For the [fraction](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#8b87515ad4d04a17b3ad0d275f7b3796)[of wins](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#8b87515ad4d04a17b3ad0d275f7b3796) $\hat{P}_i(1)$ in the $\sum_{t=1}^T\eta_i(t)\geq1$ observations of the leader election process of a node the [(naive) statistical estimator](https://nomos-tech.notion.site/1fd261aa09df8181a428f52251e173c4?pvs=25) of $\alpha$, $\hat{\alpha}_i$, is the solution of the equation $\hat{P}_i(1)=\phi(\alpha_i)$ given by

$$
\hat{\alpha}_i=\frac{\log\left(1-\hat{P}_i(1)\right)}{\log(1-f)}
$$

We note that for $\hat{P}_i(1)=0$ we have that $\hat{\alpha}_i=0$. The estimator $\hat{\alpha}_i$ is biased because

$$
\langle\hat{\alpha}_i\rangle=\left\langle\frac{\log\left(1-\hat{P}_i(1)\right)}{\log(1-f)}\right\rangle\neq\frac{\log\left(1-\phi(\alpha_i)\right)}{\log(1-f)}=\alpha_i
$$

where the average $\langle\{\cdots\}\rangle$ is defined in the [Appendix](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#209261aa09df803d9e07f14c76435c45). However, the [average](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#08422d534bcd4c218558164d6902e6c0) $\langle\hat{P}_i(1)\rangle=\phi(\alpha_i)$ and the [variance](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#94a001afe6c5456686827b2832ea7ee4) $\mathrm{Var}[\hat{P}_i(1)]\rightarrow0$.  If $\sum_{t=1}^T\eta_i(t)\rightarrow\infty$ when $T\rightarrow\infty$ then in this (”large number of observations”) limit we have

$$
\hat{\alpha}_i\rightarrow\frac{\log\left(1-\phi(\alpha_i)\right)}{\log(1-f)}=\alpha_i
$$

i.e. $\hat{\alpha}_i$ is consistent estimator of the relative stake $\alpha_i$.

Similarly [to the estimator of](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#d2cc165b22724b03802603cdc9c020df)$\phi(\alpha_i)$, we construct new estimator of relative stake

$$
\Alpha[\hat{\alpha}_i]=\left\{
\begin{array}{c}
\hat{\alpha}_i\text{ if }\hat{\alpha}_i>\alpha_0 \\
\alpha_0 \text{ if }\hat{\alpha}_i\leq\alpha_0 
\end{array}
\right\}
$$

The above can be written as follows

$$
\Alpha[\hat{\alpha}_i]=\hat{\alpha}_i\mathbf{1}[\hat{\alpha}_i>\alpha_0]+\alpha_0\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\\~~~~~~=\hat{\alpha}_i+\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\left\{\alpha_0-\hat{\alpha}_i\right\}\\~~~~~~~~~~~~~~~~~=\hat{\alpha}_i+\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\alpha_0-\hat{\alpha}_i\right\}
$$

We note that $\Alpha[\hat{\alpha}_i]\leq\hat{\alpha}_i+\alpha_0\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]$ from which follows that

$$
\left\langle\hat{\alpha}_i\right\rangle\leq\left\langle\Alpha[\hat{\alpha}_i]\right\rangle\leq\left\langle\hat{\alpha}_i\right\rangle+\alpha_0\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\right\rangle
$$

but [we showed](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#a15a45cf4d5848deb204076964b4a79b) that $\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\right\rangle\rightarrow0$ for a large number of observations, and hence $\left\langle\Alpha[\hat{\alpha}_i]\right\rangle\rightarrow\left\langle\hat{\alpha}_i\right\rangle$ in this limit.

Let us consider the (squared) distance

$$
\vert \alpha_i -\Alpha[\hat{\alpha}_i]\vert^2=\left(\alpha_i-\hat{\alpha}_i-\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\alpha_0-\hat{\alpha}_i\right\}\right)^2\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\left(\alpha_i-\hat{\alpha}_i\right)^2-2\,\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left(\alpha_i-\hat{\alpha}_i\right)\left(\alpha_0-\hat{\alpha}_i\right)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left(\alpha_0-\hat{\alpha}_i\right)^2
$$

From the above follows the difference

$$
\langle\vert \alpha_i -\Alpha[\hat{\alpha}_i]\vert^2\rangle -\langle\vert \alpha_i -\hat{\alpha}_i\vert^2\rangle~~~=-2\,\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left(\alpha_i-\hat{\alpha}_i\right)\left(\alpha_0-\hat{\alpha}_i\right)\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left(\alpha_0-\hat{\alpha}_i\right)^2\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=-2\,\left\langle\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\left(\alpha_i-\hat{\alpha}_i\right)\left(\alpha_0-\hat{\alpha}_i\right)\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\left(\alpha_0-\hat{\alpha}_i\right)^2\right\rangle
$$

Now, because $\hat{\alpha}_i \leq \alpha_0 \leq \alpha_i$, we have the following inequality

$$
\left\langle\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\left(\alpha_i-\hat{\alpha}_i\right)\left(\alpha_0-\hat{\alpha}_i\right)\right\rangle\geq \left\langle\mathbf{1}[\hat{\alpha}_i\leq\alpha_0]\left(\alpha_0-\hat{\alpha}_i\right)^2\right\rangle
$$

and hence

$$
\langle\vert \alpha_i -\Alpha[\hat{\alpha}_i]\vert^2\rangle -\langle\vert \alpha_i -\hat{\alpha}_i\vert^2\rangle\leq0
$$

i.e. the [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) of the estimator $\hat{\alpha}_i$ is greater than the MSE of the estimator $\Alpha[\hat{\alpha}_i]$. Furthermore, for the MSE of $\hat{\alpha}_i$ we have

$$
\langle\vert \alpha_i -\hat{\alpha}_i\vert^2\rangle=\mathrm{Var}[\hat{\alpha}_i]+\vert \alpha_i -\langle\hat{\alpha}_i\rangle\vert^2
$$

Now $\hat{\alpha}_i$ is a consistent estimator of the relative stake $\alpha_i$ and hence $\langle\vert \alpha_i -\hat{\alpha}_i\vert^2\rangle\rightarrow0$ in the large number of observations limit, but $\langle\vert \alpha_i -\Alpha[\hat{\alpha}_i]\vert^2\rangle \leq\langle\vert \alpha_i -\hat{\alpha}_i\vert^2\rangle$, so $\Alpha[\hat{\alpha}_i]$ is also a consistent estimator of the relative stake $\alpha_i$.

Simulations confirm that MSE of the estimator $\hat{\alpha}_i$ is greater than the MSE of the new estimator $\Alpha[\hat{\alpha}_i]$, as can be seen in the figures below.

![Diagram](https://nomos-tech.notion.site/image/attachment%3A2678cd60-9e32-4836-942c-7b2aaecc4927%3A73cab8dd-4078-4667-9d0c-a9ce90dbcece.png?table=block&id=60c13593-6bd3-4647-b31c-c3fc65955de2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A6134b659-a19b-4995-8169-6be4dc9dee5c%3A9885ed6e-8178-4467-944f-b2f1ddad5ece.png?table=block&id=0f4a1c28-af9a-41ac-ba19-6a43d154edb9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3Af40e2e20-3706-4b65-a68f-cc4cbac90ab3%3A8c01a4e6-ffe6-40d3-8040-306fee14cc0c.png?table=block&id=14f31751-9f1a-4527-acf1-f59a0d1f412f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We are interested in the probability $\mathrm{P}\left(\Alpha[\hat{\alpha}_i]\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right)$ which can be seen as [adversarial "confidence"](https://nomos-tech.notion.site/1fd261aa09df8181a428f52251e173c4?pvs=25). Here $0<\gamma<1$ prescribes desired “accuracy” of the inference. We note that the probability $\mathrm{P}\left(\hat{\alpha}_i\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right)$ can be [estimated analytically](https://nomos-tech.notion.site/1fd261aa09df8181a428f52251e173c4?pvs=25) for large $T$. If for a given (accuracy) parameter $\gamma$ we have that $\mathrm{P}\left(\Alpha[\hat{\alpha}_i]\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right) > \mathrm{P}\left(\hat{\alpha}_i\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right)$ then the adversary has an advantage by using the new estimator, i.e. an adversary which knows that $\alpha_i\geq\alpha_0$ has a higher confidence than the adversary which doesn’t know the latter.

Recall that $\alpha_0 \leq \alpha_i$. We note that $\alpha_0 \in [\alpha_i(1-\lambda), \alpha_i (1+\lambda)]$, provided $\alpha_i(1-\lambda) \leq \alpha_0$. Let us assume (without loss of generality) that $\alpha_i=n\,\alpha_0$ for some $n\geq1$. Then, from $\alpha_i(1-\gamma)\leq\alpha_0$ follows that $n\leq \frac{1}{1-\gamma}$. Hence, if this inequality is satisfied, an adversary may have advantage. We compute the probabilities $\mathrm{P}\left(\Alpha[\hat{\alpha}_i]\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right)$ and $\mathrm{P}\left(\hat{\alpha}_i\in[\alpha_i(1-\gamma), \alpha_i(1+\gamma)]\right)$ using simulation and find that the adversary has advantage for the relative stake $\alpha_i\in[\alpha_0,\frac{\alpha_0}{1-\gamma}]$, as can be seen in figures below.

![Diagram](https://nomos-tech.notion.site/image/attachment%3A77498bf4-d0c3-4245-8d23-051784c9ad2e%3A85c026e3-c782-42aa-b2fd-85fa25526c7c.png?table=block&id=48c26d1a-420b-43c5-a43a-2e3b26de5036&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A92137e05-cf14-4727-b836-4c1cb595da56%3Ac91bc5ac-9de4-4f84-833f-7fb64ae521b6.png?table=block&id=300d0df8-6895-49f7-8b89-b45f11966ae3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3Aebcf148c-113f-4aa9-aea4-ed355bf2d258%3Ac63c19d8-0c90-4358-9e26-3c1f6854aea2.png?table=block&id=5cc468cc-8a1d-443e-b4a5-74f7c458695e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Numerical Experiments

In this section, we compare performance of the statistical estimators $\hat{\alpha}_i$ and $\Alpha[\hat{\alpha}_i]$ in a single run of a simulation. This can be seen as a scenario where two adversaries collect the same data from the leader election process, but one of the adversaries knows $\alpha_0$ and uses this in the statistical inference. To simulate the statistical inference of relative stake in one epoch ($T=432000$ time-slots) of the leader election process with parameter $f=0.05$, we sampled $N=2\times10^3$ random (stake) values from the [Pareto distribution](https://en.wikipedia.org/wiki/Pareto_distribution) with shape parameter $2.5$ and scale parameter $2$. The histogram of (relative) stake values is given below

![Diagram](https://nomos-tech.notion.site/image/attachment%3Ac80b2c2f-3ab0-4aed-85dd-1106b1f36e6a%3AScreenshot_2025-05-30_at_15.35.36.png?table=block&id=4a2a1aab-0f61-4a0a-92b3-ab151a4c5607&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We consider inference only for $5$ nodes with the highest relative stake and for $5$ nodes with relative stake just above the threshold $\alpha_0=1/10^4$.  We consider a scenario where fraction $q\in\{1/100,1/10,1\}$ of time-slots of the leader election process are observed by adversary. Here we find differences between estimators only for nodes with relative stake close to $\alpha_0$ as can be seen in the figures below.

![Diagram](https://nomos-tech.notion.site/image/attachment%3Ad0fd7422-7c88-4b0d-a624-9924efef31d4%3A48b85f1a-810d-4fa3-a325-b0aa6eaa9735.png?table=block&id=f9f8159d-2e95-4ba3-a395-a44c97ceb42b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A5603e165-ea7a-4b56-92bf-b32ae06be4a9%3A189eb8a2-1295-450b-b818-81f7f0568090.png?table=block&id=d2daef95-6e55-4cd0-96fb-bfd3e27898d7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A5e7e0ed4-0b31-4fd8-9daa-35b4102c953d%3A0c35a1db-e76c-4ead-b7df-31bd371f732b.png?table=block&id=ad2d984c-81fa-4064-81a5-f6fd7fac3cd3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A1843e6fa-b779-4c5f-92d3-5640baaec30b%3Ad5f0b6c2-0a29-4395-844c-6f533ba7b2b9.png?table=block&id=2a75024d-d805-4e73-a880-c045055bfc97&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3A697554e5-f6ac-48e3-8fec-71dedab492e4%3A6066059d-6d60-44e1-8dab-26fbe24cee5a.png?table=block&id=11cd61af-c167-4819-9767-2ccf7579c1d4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![Diagram](https://nomos-tech.notion.site/image/attachment%3Af782ae8a-5d7f-44f5-9441-42d76038b243%3Ab36278f3-c698-4123-8c9f-9d3891d73391.png?table=block&id=e6ca6c54-2e13-4b01-8557-522745e3f4ed&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Appendix

## Inference of probability

The [leader election process](https://nomos-tech.notion.site/1fd261aa09df8181a428f52251e173c4?pvs=25) is governed by the probability distribution

$$
\mathrm{P}(s_1(t),\ldots,s_N(t))=\prod_{i=1}^N\left[\phi(\alpha_i)\,\delta_{1;s_i(t)}+(1-\phi(\alpha_i))\,\delta_{0;s_i(t)}\right]
$$

of the outcome of election $s_1(t),\ldots,s_N(t)$, where $s_i(t)\in\{0,1\}$ models outcome ($0/1\equiv$ loss/win) for node $i$ in time-slot $t$. The fraction of observed wins of node $i$ in one epoch is

$$
\hat{P}_i(1)=\frac{1}{\sum_{t=1}^T\eta_i(t)}\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}
$$

where $\sum_{t=1}^T\eta_i(t)\geq1$, with $\eta_i(t)\in\{0,1\}$, is the total number of observations.

The average with respect to the [leader election process](https://nomos-tech.notion.site/1fd261aa09df8181a428f52251e173c4?pvs=25) gives us

$$
\langle\hat{P}_i(1)\rangle=\frac{1}{\sum_{t=1}^T\eta_i(t)}\sum_{t=1}^T\eta_i(t)\,\langle\delta_{1;s_i(t)}\rangle=\phi(\alpha_i)
$$

i.e. $\hat{P}_i(1)$ is unbiased statistical estimator of prob. of winning $\phi(\alpha_i)$. In the above $\langle\{\cdots\}\rangle$ is the averaging “operator” defines as

$$
\langle\{\cdots\}\rangle=\left\{\prod_{t=1}^T\prod_{i=1}^N \sum_{s_i(t)}\mathrm{P}(s_i(t))\right\} \{\cdots\}
$$

where $\mathrm{P}(s_i(t))=\phi(\alpha_i)\,\delta_{1;s_i(t)}+(1-\phi(\alpha_i))\,\delta_{0;s_i(t)}$. Since $\alpha_i=\beta_i+\alpha_0$ and $\phi(\beta_i+\alpha_0)\geq \phi(\alpha_0)$, from above follows that $\langle\hat{P}_i(1)\rangle\geq \phi(\alpha_0)$.

The variance of $\hat{P}_i(1)$ is given by

$$
\mathrm{Var}[\hat{P}_i(1)]=\langle\hat{P}^2_i(1)\rangle-\langle\hat{P}_i(1)\rangle^2\\~~~~~~~~~~~~~~~=\frac{1}{\sum_{t=1}^T\eta_i(t)}\phi(\alpha_i)[1-\phi(\alpha_i)]
$$

If $\sum_{t=1}^T\eta_i(t)\rightarrow\infty$ as $T\rightarrow\infty$, i.e. for a large number of observations, then $\mathrm{Var}[\hat{P}_i(1)]\rightarrow0$, i.e. $\hat{P}_i(1)$ is a consistent estimator of the prob. $\phi(\alpha_i)$.

Let us define the new estimator of $\phi(\alpha_i)$ as follows

$$
\Phi[\hat{P}_i(1)]=\phi(\alpha_0)\,\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]+\hat{P}_i(1)\,\mathbf{1}[\hat{P}_i(1)>\phi(\alpha_0)]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~=\phi(\alpha_0)\,\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]+\hat{P}_i(1)\left\{1-\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\right\}\\~~=\hat{P}_i(1)+\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}
$$

The average with respect to leader election process gives us

$$
\langle\Phi[\hat{P}_i(1)]\rangle=\phi(\alpha_i)+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle
$$

i.e. the estimator $\Phi[\hat{P}_i(1)]$ has (positive) bias. We expect that in the limit $\sum_{t=1}^T\eta_i(t)\rightarrow\infty$ as $T\rightarrow\infty$, i.e. for a large number of observations, the average $\langle\Phi[\hat{P}_i(1)]\rangle\rightarrow\phi(\alpha_i)$. We note that since $\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\{\phi(\alpha_0)-\hat{P}_i(1)\}\geq0$, we have that

$$
\langle\Phi[\hat{P}_i(1)]\rangle=\phi(\alpha_i)+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\\leq \phi(\alpha_i)+\phi(\alpha_0)\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\right\rangle
$$

and

$$
\langle\Phi[\hat{P}_i(1)]\rangle\geq\phi(\alpha_i)
$$

Now, for $\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))=\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\right\rangle$ by the Markov’s inequality we have

$$
\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))=\mathrm{Prob}\left(\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}\leq\phi(\alpha_0)\sum_{t=1}^T\eta_i(t)\right)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\mathrm{Prob}\left(\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\geq\mathrm{e}^{-\lambda\phi(\alpha_0)\sum_{t=1}^T\eta_i(t)}\right)\\~~\leq\frac{\left\langle\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\right\rangle}{\mathrm{e}^{-\lambda\phi(\alpha_0)\sum_{t=1}^T\eta_i(t)}}
$$

where $\lambda>0$. Using the [definition](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#209261aa09df803d9e07f14c76435c45), the average on the RHS of the above can be computed as follows

$$
\left\langle\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\right\rangle=\left\{\prod_{t=1}^T\prod_{j=1}^N \sum_{s_j(t)}\mathrm{P}(s_j(t))\right\}\mathrm{e}^{-\lambda\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}}\\~~~~~~~~~~=\prod_{t=1}^T\sum_{s_i(t)}\mathrm{P}(s_i(t))\,\mathrm{e}^{-\lambda\eta_i(t)\,\delta_{1;s_i(t)}}\\~~~~~~~~~~~~~~~~~~~=\prod_{t=1}^T\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda\eta_i(t)}+1-\phi(\alpha_i)\right)\\~~~~~~~~~~=\mathrm{e}^{\sum_{t=1}^T\log\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda\eta_i(t)}+1-\phi(\alpha_i)\right)}\\~~~~~~~~~~~~=\mathrm{e}^{\sum_{t=1}^T\eta_i(t)\log\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha_i)\right)}
$$

Using above result in the [inequality](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#c731d476bd214a4f97d5fcb53a9925ce) we obtain

$$
\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))\leq\mathrm{e}^{\sum_{t=1}^T\eta_i(t)\left[\log\left(\phi(\alpha_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha_i)\right)+\lambda\phi(\alpha_0)\right]}
$$

Furthermore, optimising the RHS in above with respect to $\lambda$ we obtain the inequality

$$
\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))\leq \mathrm{e}^{\sum_{t=1}^T\eta_i(t)\left[\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha_0) }\right)-\log \left(\frac{\phi(\alpha_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{  1-\phi(\alpha_0) }\right) \phi(\alpha_0)\right]}
$$

We note that $\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha_0) }\right)-\log \left(\frac{\phi(\alpha_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{  1-\phi(\alpha_0) }\right) \phi(\alpha_0)$ is monotonic decreasing function of $\phi(\alpha)$ which is exactly zero when $\phi(\alpha)=\phi(\alpha_0)$ and hence this function is negative for $\phi(\alpha)\geq\phi(\alpha_0)$. Hence we have the following inequality

$$
\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))\leq \mathrm{e}^{-\sum_{t=1}^T\eta_i(t)\left[-\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha_0) }\right)+\log \left(\frac{\phi(\alpha_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{  1-\phi(\alpha_0) }\right) \phi(\alpha_0)\right]}
$$

where $-\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha_0) }\right)+\log \left(\frac{\phi(\alpha_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{  1-\phi(\alpha_0) }\right) \phi(\alpha_0)> 0$ when $\phi(\alpha)>\phi(\alpha_0)$.

From above follows that $\mathrm{Prob}(\hat{P}_i(1)\leq\phi(\alpha_0))\rightarrow0$ in the limit $\sum_{t=1}^T\eta_i(t)\rightarrow\infty$ as $T\rightarrow\infty$, i.e. for a large number of observations. Using the latter in the [upper bound](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#585561b1774d4c8f9f089c9d47891bca) gives us that $\langle\Phi[\hat{P}_i(1)]\rangle\rightarrow\phi(\alpha_i)$ in this limit. If in the limit of large number of observations we also have that the $\mathrm{Var}[\Phi[\hat{P}_i(1)]]\rightarrow0$ then $\Phi[\hat{P}_i(1)]$ is a consistent estimator of the prob. $\phi(\alpha_i)$.

For $\Phi[\hat{P}_i(1)]=\hat{P}_i(1)+\xi_i$, where we defined $\xi_i=\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}$, the $\mathrm{Var}[\Phi[\hat{P}_i(1)]]$ is given by

$$
\mathrm{Var}[\Phi[\hat{P}_i(1)]]=\mathrm{Var}[\hat{P}_i(1)+\xi_i]=\mathrm{Var}[\hat{P}_i(1)]+2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\mathrm{Var}[\xi_i].
$$

In the [Variance section](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#b91336f816a345cb89a09c1229fecf95) we show that

$$
\mathrm{Var}[\Phi[\hat{P}_i(1)]]\leq\mathrm{Var}[\hat{P}_i(1)].
$$

Hence in the limit of large number of observations $\mathrm{Var}[\Phi[\hat{P}_i(1)]]\rightarrow0$.

Thus from above follows that

$$
\Phi[\hat{P}_i(1)]=\hat{P}_i(1)+\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}
$$

is unbiased and consistent estimator of the prob. $\phi(\alpha_i)$ in the limit of large number of observations $\sum_{t=1}^T\eta_i(t)\rightarrow\infty$ as $T\rightarrow\infty$.

For $\sum_{t=1}^T\eta_i(t)\geq1$ the [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) of the estimator $\hat{P}_i(1)$ is given by

$$
\langle\vert \phi(\alpha_i) -\hat{P}_i(1)\vert^2\rangle =\mathrm{Var}[\hat{P}_i(1)]=\frac{1}{\sum_{t=1}^T\eta_i(t)}\phi(\alpha_i)[1-\phi(\alpha_i)]
$$

Assuming that the $\eta_i(t)$ variables are exactly the same as in the above, the MSE of the estimator $\Phi[\hat{P}_i(1)]$ is given by

$$
\langle\vert \phi(\alpha_i) -\Phi[\hat{P}_i(1)]\vert^2\rangle ~~~=\mathrm{Var}[\Phi[\hat{P}_i(1)]]+\left\vert\phi(\alpha_i)-\langle\Phi[\hat{P}_i(1)]\rangle\right\vert^2\\=\mathrm{Var}[\Phi[\hat{P}_i(1)]]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle^2
$$

Consider the difference$\langle\vert \phi(\alpha_i) -\Phi[\hat{P}_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha_i) -\hat{P}_i(1)\vert^2\rangle$ as follows

$$
\langle\vert \phi(\alpha_i) -\Phi[\hat{P}_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha_i) -\hat{P}_i(1)\vert^2\rangle\\=\\\mathrm{Var}[\hat{P}_i(1)]+2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\mathrm{Var}[\xi_i]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle^2-\mathrm{Var}[\hat{P}_i(1)]\\~~~~~~~~~~~~~~~~~~~~=2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\mathrm{Var}[\xi_i]+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle^2\\~~~=2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}^2\right\rangle
$$

Now the last line in the above can be bounded as follows

$$
2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}^2\right\rangle\\
%
~~~~~~~~~~~~~~=-2\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\
%
~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}^2\right\rangle\\
%
~~~~~~~~~~~~~~~\leq-2\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\
%
~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\
%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=-\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle
$$

Hence

$$
\langle\vert \phi(\alpha_i) -\Phi[\hat{P}_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha_i) -\hat{P}_i(1)\vert^2\rangle\\
%
~~~~~\leq\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle
$$

Thus, the MSE of the unbiased estimator $\hat{P}_i(1)$ is greater that the MSE of the biased, but consistent, estimator $\Phi[\hat{P}_i(1)]$.

## Variance of $\Phi[\hat{P}_i(1)]$​

For $\Phi[\hat{P}_i(1)]=\hat{P}_i(1)+\xi_i$, where $\xi_i=\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}$, we consider the variance

$$
\mathrm{Var}[\Phi[\hat{P}_i(1)]]=\mathrm{Var}[\hat{P}_i(1)+\xi_i]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\mathrm{Var}[\hat{P}_i(1)]+2\,\mathrm{Cov}[\hat{P}_i(1),\xi_i]+\mathrm{Var}[\xi_i]
$$

First, we consider the covariance

$$
\mathrm{Cov}[\hat{P}_i(1),\xi_i]=\langle\hat{P}_i(1)\,\xi_i\rangle-\langle\hat{P}_i(1)\rangle\langle\xi_i\rangle\\=\langle\hat{P}_i(1)\,\xi_i\rangle-\phi(\alpha_i)\langle\xi_i\rangle\\=\left\langle\hat{P}_i(1)\,\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle-\phi(\alpha_i)\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\=-\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle
$$

Because of $\phi(\alpha_0)\leq \phi(\alpha_i)$, from the above it follows that $\mathrm{Cov}[\hat{P}_i(1),\xi_i]\leq0$.

Second, we consider the variance

$$
\mathrm{Var}[\xi_i]=\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]^2\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}^2\right\rangle-\left\langle\xi_i\right\rangle^2\\
%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_0)-\hat{P}_i(1)-\left\langle\xi_i\right\rangle\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\
%
~=\left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)+\phi(\alpha_0)-\phi(\alpha_i)-\left\langle\xi_i\right\rangle\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle\\
%
~~~~~~~~\leq \left\langle\mathbf{1}[\hat{P}_i(1)\leq\phi(\alpha_0)]\left\{\phi(\alpha_i)-\hat{P}_i(1)\right\}\left\{\phi(\alpha_0)-\hat{P}_i(1)\right\}\right\rangle=-\mathrm{Cov}[\hat{P}_i(1),\xi_i]
$$

Thus, from the above it follows that $\mathrm{Var}[\xi_i]\leq -\mathrm{Cov}[\hat{P}_i(1),\xi_i]$. The latter with $-\mathrm{Cov}[\hat{P}_i(1), \xi_i] \geq 0$ implies $\mathrm{Cov}[\hat{P}_i(1),\xi_i]\leq-\mathrm{Var}[\xi_i]/2$ which using the [variance equation](https://nomos-tech.notion.site/206261aa09df807bad8afccf8474c6c9?pvs=25#878222bbfb1b42169fd4092dc6ea1ed1) gives us that

$$
\mathrm{Var}[\Phi[\hat{P}_i(1)]]\leq\mathrm{Var}[\hat{P}_i(1)]
$$

