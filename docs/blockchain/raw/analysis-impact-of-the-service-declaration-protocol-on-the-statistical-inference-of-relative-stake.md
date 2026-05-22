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

> **Note on this import:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) rendered via katex; tables and headings
> are converted from Notion HTML. A formatting polish (semantic line breaks, code block fences
> for code samples, internal cross-references) is still recommended.

---

## Revision History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2025-08-22 |

## Introduction

The Service Declaration Protocol (SDP) introduces a piece of a priori information: the knowledge that a node's relative stake cannot be less than a known threshold, $\alpha\_0$ . Our research investigates the significance of the impact of this information on the statistical inference of relative stake. We propose a new estimator which explicitly utilises $\alpha\_0$ by setting any estimated stake below this threshold to $\alpha\_0$ .

Our new estimator works better because it fixes estimation errors at the lower end. When a node's true stake value ( $\alpha\_i$ ) is close to the minimum threshold ( $\alpha\_0$ ), the standard maximum likelihood (ML) estimator often produces values that are too low. By automatically adjusting these too-low estimates up to the minimum threshold ( $α\_0$ ), our new approach reduces errors. This improvement can be measured as a lower mean squared error (MSE) compared to the true stake value ( $\alpha\_i$ ). Thus any party, including potential adversaries, performing stake inference gains in accuracy by using the new estimator.

Numerical experiments demonstrate reduction in MSE of the new estimator compared to the ML estimator, particularly for stakes near  $α\_0$ . For example, for  $\alpha\_0=10^{-4}$  used in experiments, a reduction of MSE by a (approx.) factor of at most  $1/2$  was observed. Furthermore, the probability, measured in the same experiment, that the inferred stake falls within a desired accuracy interval is higher (by factor of (approx.)  $3$  at least) when the new estimator is used. While the advantage diminishes for much higher stake values where both estimators converge, the heightened accuracy near the critical  $α\_0$  threshold presents a meaningful enhancement for any party performing stake inference, including potential adversaries.

### Key Findings

Introduction of a priori information: The Service Declaration Protocol (SDP) introduces the knowledge that a node's relative stake cannot be less than a threshold ( $α₀$ ), which impacts statistical inference of relative stake⁠⁠.

New estimator proposed: The research introduces a new estimator that explicitly uses α₀ by setting any estimated stake below this threshold to $α₀$ ⁠⁠.

Improved accuracy: The new estimator performs better because it corrects estimation errors at the lower end, particularly when a node's true stake value is close to the minimum threshold⁠⁠.

Measurable improvements: Numerical experiments show:

Reduction in Mean Squared Error (MSE) of the new estimator compared to the ML estimator, particularly for stakes near $α₀$ ⁠⁠.

For $α₀=10⁻⁴$ , MSE reduction by a factor of approximately $1/2$ was observed⁠⁠.

Higher probability (by a factor of approximately 3) that inferred stake falls within desired accuracy intervals⁠⁠.

Statistical significance: The advantage diminishes for much higher stake values where both estimators converge, but the enhanced accuracy near the critical α₀ threshold presents a meaningful improvement for any party performing stake inference⁠⁠.

Security implications: This improvement benefits anyone performing stake inference, including potential adversaries⁠⁠.

The research provides mathematical proof and numerical simulations to validate these findings, showing that the proposed estimator is both unbiased and consistent in the limit of large number of observations⁠⁠.

## Overview

This document examines the impact of minimum stake threshold, introduced in the SDP, on the statistical inference of relative stake along the following points:

![](/image/attachment%3Aaf3bbdfb-1a69-4f1e-a947-fc843b63d24e%3AChatGPT_Image_Jul_9_2025_12_26_01_PM.png?table=block&id=22b261aa-09df-80ae-a152-ea44acd86a1d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=350&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In particular:

We consider the Leader Election Process where nodes allowed to participate only if their relative stake is no less than some prescribed by SDP threshold.

We assume that the Adversary observes wins (and losses) of nodes and uses statistical inference to infer relative stake of nodes.

The Adversary knows the SDP stake threshold, and using this information, the Adversary constructs a statistical estimator.

This New estimator improves inference of stake when compared with an estimator which doesn’t use the SDP threshold. The simulation of adversarial inference shows that those most affected by this improvement are the nodes with values of relative stake close to the threshold.

## Analysis

### The Model

The relative stake of node $i$ , $\alpha\_i$ , is computed via the formula $\alpha\_i=w\_i/\sum\_{j=1}^Nw\_j$ , where $w\_i$ is the stake of node $i$ . We assume that the total stake $\sum\_{j=1}^Nw\_j$ can be inferred (with high accuracy) by using the [total stake inference](/237261aa09df800285cccbb00b3aeb0a?pvs=25) algorithm. We note that for the set  $\{\alpha\_1,\ldots,\alpha\_N\}$ , i.e. relative stakes of all nodes, it is possible that  $\{\alpha\_1,\ldots,\alpha\_N\} = \{\alpha\_i\,\vert\,\alpha\_i<\alpha\_0\}\cup\{\alpha\_i\,\vert\,\alpha\_i\geq\alpha\_0\}$ . It is known, through the declaration of the [Service Declaration Protocol](/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25) (SDP), that the relative stake of a node is at least  $\alpha\_0$ . For $\alpha\_i\in \{\alpha\_i\,\vert\,\alpha\_i\geq\alpha\_0\}$ , the relative stake of a node $i$ can be written as $\alpha\_i=\beta\_i+\alpha\_0$ , where  $\beta\_i\geq 0$  is unknown. Intuitively, this suggests that if, relative to the  $\alpha\_i$ , the minimum stake  $\alpha\_0$  is large, then then there is less “uncertainty” about the relative stake  $\alpha\_i$ .

Node  $i$  participates in the leader election and its probability of winning is given by the “lottery” function

$$
\phi(\alpha\_i)=1-(1-f)^{\alpha\_i},
$$
ϕ(αi​)=1−(1−f)αi​,

where $f\in(0,1)$ is the parameter of the [consensus](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8139be03eb565f1e419d). Since the lottery function  $\phi(\alpha\_i)$  is a monotonically increasing function of relative stake, for the relative stake  $\alpha\_i=\beta\_i+\alpha\_0$  we have  $\phi(\beta\_i+\alpha\_0)\geq \phi(\alpha\_0)$ , i.e. the prob. of winning for nodes with relative stake greater than  $\alpha\_0$  is higher.

### Inference of relative stake

For the [fraction](/206261aa09df807bad8afccf8474c6c9?pvs=25#8b87515ad4d04a17b3ad0d275f7b3796) [of wins](/206261aa09df807bad8afccf8474c6c9?pvs=25#8b87515ad4d04a17b3ad0d275f7b3796)  $\hat{P}\_i(1)$  in the  $\sum\_{t=1}^T\eta\_i(t)\geq1$  observations of the leader election process of a node the [(naive) statistical estimator](/1fd261aa09df8181a428f52251e173c4?pvs=25) of  $\alpha$ ,  $\hat{\alpha}\_i$ , is the solution of the equation  $\hat{P}\_i(1)=\phi(\alpha\_i)$  given by

$$
\hat{\alpha}\_i=\frac{\log\left(1-\hat{P}\_i(1)\right)}{\log(1-f)}
$$
α^i​=log(1−f)log(1−P^i​(1))​

We note that for  $\hat{P}\_i(1)=0$  we have that  $\hat{\alpha}\_i=0$ . The estimator $\hat{\alpha}\_i$ is biased because

$$
\langle\hat{\alpha}\_i\rangle=\left\langle\frac{\log\left(1-\hat{P}\_i(1)\right)}{\log(1-f)}\right\rangle\neq\frac{\log\left(1-\phi(\alpha\_i)\right)}{\log(1-f)}=\alpha\_i
$$
⟨α^i​⟩=⟨log(1−f)log(1−P^i​(1))​⟩=log(1−f)log(1−ϕ(αi​))​=αi​

where the average  $\langle\{\cdots\}\rangle$  is defined in the [Appendix](/206261aa09df807bad8afccf8474c6c9?pvs=25#209261aa09df803d9e07f14c76435c45). However, the [average](/206261aa09df807bad8afccf8474c6c9?pvs=25#08422d534bcd4c218558164d6902e6c0)  $\langle\hat{P}\_i(1)\rangle=\phi(\alpha\_i)$  and the [variance](/206261aa09df807bad8afccf8474c6c9?pvs=25#94a001afe6c5456686827b2832ea7ee4)  $\mathrm{Var}[\hat{P}\_i(1)]\rightarrow0$ .  If  $\sum\_{t=1}^T\eta\_i(t)\rightarrow\infty$  when  $T\rightarrow\infty$  then in this (”large number of observations”) limit we have

$$
\hat{\alpha}\_i\rightarrow\frac{\log\left(1-\phi(\alpha\_i)\right)}{\log(1-f)}=\alpha\_i
$$
α^i​→log(1−f)log(1−ϕ(αi​))​=αi​

i.e.  $\hat{\alpha}\_i$  is consistent estimator of the relative stake  $\alpha\_i$ .

Similarly [to the estimator of](/206261aa09df807bad8afccf8474c6c9?pvs=25#d2cc165b22724b03802603cdc9c020df)  $\phi(\alpha\_i)$ , we construct new estimator of relative stake

$$
\Alpha[\hat{\alpha}\_i]=\left\{
\begin{array}{c}
\hat{\alpha}\_i\text{ if }\hat{\alpha}\_i>\alpha\_0 \\
\alpha\_0 \text{ if }\hat{\alpha}\_i\leq\alpha\_0
\end{array}
\right\}
$$
A[α^i​]={α^i​ if α^i​>α0​α0​ if α^i​≤α0​​}

The above can be written as follows

$$
\Alpha[\hat{\alpha}\_i]=\hat{\alpha}\_i\mathbf{1}[\hat{\alpha}\_i>\alpha\_0]+\alpha\_0\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\\~~~~~~=\hat{\alpha}\_i+\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\left\{\alpha\_0-\hat{\alpha}\_i\right\}\\~~~~~~~~~~~~~~~~~=\hat{\alpha}\_i+\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\alpha\_0-\hat{\alpha}\_i\right\}
$$
A[α^i​]=α^i​1[α^i​>α0​]+α0​1[α^i​≤α0​]      =α^i​+1[α^i​≤α0​]{α0​−α^i​}                 =α^i​+1[P^i​(1)≤ϕ(α0​)]{α0​−α^i​}

We note that $\Alpha[\hat{\alpha}\_i]\leq\hat{\alpha}\_i+\alpha\_0\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]$ from which follows that

$$
\left\langle\hat{\alpha}\_i\right\rangle\leq\left\langle\Alpha[\hat{\alpha}\_i]\right\rangle\leq\left\langle\hat{\alpha}\_i\right\rangle+\alpha\_0\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\right\rangle
$$
⟨α^i​⟩≤⟨A[α^i​]⟩≤⟨α^i​⟩+α0​⟨1[P^i​(1)≤ϕ(α0​)]⟩

but [we showed](/206261aa09df807bad8afccf8474c6c9?pvs=25#a15a45cf4d5848deb204076964b4a79b) that $\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\right\rangle\rightarrow0$ for a large number of observations, and hence $\left\langle\Alpha[\hat{\alpha}\_i]\right\rangle\rightarrow\left\langle\hat{\alpha}\_i\right\rangle$ in this limit.

Let us consider the (squared) distance

$$
\vert \alpha\_i -\Alpha[\hat{\alpha}\_i]\vert^2=\left(\alpha\_i-\hat{\alpha}\_i-\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\alpha\_0-\hat{\alpha}\_i\right\}\right)^2\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\left(\alpha\_i-\hat{\alpha}\_i\right)^2-2\,\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left(\alpha\_i-\hat{\alpha}\_i\right)\left(\alpha\_0-\hat{\alpha}\_i\right)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left(\alpha\_0-\hat{\alpha}\_i\right)^2
$$
∣αi​−A[α^i​]∣2=(αi​−α^i​−1[P^i​(1)≤ϕ(α0​)]{α0​−α^i​})2                                       =(αi​−α^i​)2−21[P^i​(1)≤ϕ(α0​)](αi​−α^i​)(α0​−α^i​)                                             +1[P^i​(1)≤ϕ(α0​)](α0​−α^i​)2

From the above follows the difference

$$
\langle\vert \alpha\_i -\Alpha[\hat{\alpha}\_i]\vert^2\rangle -\langle\vert \alpha\_i -\hat{\alpha}\_i\vert^2\rangle~~~=-2\,\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left(\alpha\_i-\hat{\alpha}\_i\right)\left(\alpha\_0-\hat{\alpha}\_i\right)\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left(\alpha\_0-\hat{\alpha}\_i\right)^2\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=-2\,\left\langle\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\left(\alpha\_i-\hat{\alpha}\_i\right)\left(\alpha\_0-\hat{\alpha}\_i\right)\right\rangle\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\left(\alpha\_0-\hat{\alpha}\_i\right)^2\right\rangle
$$
⟨∣αi​−A[α^i​]∣2⟩−⟨∣αi​−α^i​∣2⟩   =−2⟨1[P^i​(1)≤ϕ(α0​)](αi​−α^i​)(α0​−α^i​)⟩                                         +⟨1[P^i​(1)≤ϕ(α0​)](α0​−α^i​)2⟩                                         =−2⟨1[α^i​≤α0​](αi​−α^i​)(α0​−α^i​)⟩                                +⟨1[α^i​≤α0​](α0​−α^i​)2⟩

Now, because  $\hat{\alpha}\_i \leq \alpha\_0 \leq \alpha\_i$ , we have the following inequality

$$
\left\langle\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\left(\alpha\_i-\hat{\alpha}\_i\right)\left(\alpha\_0-\hat{\alpha}\_i\right)\right\rangle\geq \left\langle\mathbf{1}[\hat{\alpha}\_i\leq\alpha\_0]\left(\alpha\_0-\hat{\alpha}\_i\right)^2\right\rangle
$$
⟨1[α^i​≤α0​](αi​−α^i​)(α0​−α^i​)⟩≥⟨1[α^i​≤α0​](α0​−α^i​)2⟩

and hence

$$
\langle\vert \alpha\_i -\Alpha[\hat{\alpha}\_i]\vert^2\rangle -\langle\vert \alpha\_i -\hat{\alpha}\_i\vert^2\rangle\leq0
$$
⟨∣αi​−A[α^i​]∣2⟩−⟨∣αi​−α^i​∣2⟩≤0

i.e. the [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) of the estimator  $\hat{\alpha}\_i$  is greater than the MSE of the estimator  $\Alpha[\hat{\alpha}\_i]$ . Furthermore, for the MSE of $\hat{\alpha}\_i$ we have

$$
\langle\vert \alpha\_i -\hat{\alpha}\_i\vert^2\rangle=\mathrm{Var}[\hat{\alpha}\_i]+\vert \alpha\_i -\langle\hat{\alpha}\_i\rangle\vert^2
$$
⟨∣αi​−α^i​∣2⟩=Var[α^i​]+∣αi​−⟨α^i​⟩∣2

Now $\hat{\alpha}\_i$ is a consistent estimator of the relative stake $\alpha\_i$ and hence $\langle\vert \alpha\_i -\hat{\alpha}\_i\vert^2\rangle\rightarrow0$ in the large number of observations limit, but $\langle\vert \alpha\_i -\Alpha[\hat{\alpha}\_i]\vert^2\rangle \leq\langle\vert \alpha\_i -\hat{\alpha}\_i\vert^2\rangle$ , so  $\Alpha[\hat{\alpha}\_i]$  is also a consistent estimator of the relative stake  $\alpha\_i$ .

Simulations confirm that MSE of the estimator  $\hat{\alpha}\_i$  is greater than the MSE of the new estimator  $\Alpha[\hat{\alpha}\_i]$ , as can be seen in the figures below.

![](/image/attachment%3A2678cd60-9e32-4836-942c-7b2aaecc4927%3A73cab8dd-4078-4667-9d0c-a9ce90dbcece.png?table=block&id=60c13593-6bd3-4647-b31c-c3fc65955de2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The MSE of the estimator $\hat{\alpha}\_i$ (blue + symbols) and $\Alpha[\hat{\alpha}\_i]$ (red + symbols), obtained in $M=10^3$ simulations of leader election process, as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1$ .

ALT

![](/image/attachment%3A6134b659-a19b-4995-8169-6be4dc9dee5c%3A9885ed6e-8178-4467-944f-b2f1ddad5ece.png?table=block&id=0f4a1c28-af9a-41ac-ba19-6a43d154edb9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The MSE of the estimator $\hat{\alpha}\_i$ (blue + symbols) and $\Alpha[\hat{\alpha}\_i]$ (red + symbols), obtained in $M=10^3$ simulations of leader election process, as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1/10$ .

ALT

![](/image/attachment%3Af40e2e20-3706-4b65-a68f-cc4cbac90ab3%3A8c01a4e6-ffe6-40d3-8040-306fee14cc0c.png?table=block&id=14f31751-9f1a-4527-acf1-f59a0d1f412f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The MSE of the estimator $\hat{\alpha}\_i$ (blue + symbols) and $\Alpha[\hat{\alpha}\_i]$ (red + symbols), obtained in $M=10^3$ simulations of leader election process, as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1/100$ .

ALT

We are interested in the probability  $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$  which can be seen as [adversarial "confidence"](/1fd261aa09df8181a428f52251e173c4?pvs=25). Here  $0<\gamma<1$  prescribes desired “accuracy” of the inference. We note that the probability $\mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ can be [estimated analytically](/1fd261aa09df8181a428f52251e173c4?pvs=25) for large $T$ . If for a given (accuracy) parameter  $\gamma$  we have that  $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right) > \mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$  then the adversary has an advantage by using the new estimator, i.e. an adversary which knows that  $\alpha\_i\geq\alpha\_0$  has a higher confidence than the adversary which doesn’t know the latter.

Recall that $\alpha\_0 \leq \alpha\_i$ . We note that $\alpha\_0 \in [\alpha\_i(1-\lambda), \alpha\_i (1+\lambda)]$ , provided $\alpha\_i(1-\lambda) \leq \alpha\_0$ . Let us assume (without loss of generality) that  $\alpha\_i=n\,\alpha\_0$  for some  $n\geq1$ . Then, from  $\alpha\_i(1-\gamma)\leq\alpha\_0$  follows that  $n\leq \frac{1}{1-\gamma}$ . Hence, if this inequality is satisfied, an adversary may have advantage. We compute the probabilities  $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$  and  $\mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$  using simulation and find that the adversary has advantage for the relative stake  $\alpha\_i\in[\alpha\_0,\frac{\alpha\_0}{1-\gamma}]$ , as can be seen in figures below.

![](/image/attachment%3A77498bf4-d0c3-4245-8d23-051784c9ad2e%3A85c026e3-c782-42aa-b2fd-85fa25526c7c.png?table=block&id=48c26d1a-420b-43c5-a43a-2e3b26de5036&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability $\mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (blue + symbols) and $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (red + symbols), obtained in $M=10^3$ simulations of leader election process for $\gamma=1/10$ , as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1$ .

ALT

![](/image/attachment%3A92137e05-cf14-4727-b836-4c1cb595da56%3Ac91bc5ac-9de4-4f84-833f-7fb64ae521b6.png?table=block&id=300d0df8-6895-49f7-8b89-b45f11966ae3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability $\mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (blue + symbols) and $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (red + symbols), obtained in $M=10^3$ simulations of leader election process for $\gamma=1/10$ , as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1/10$ .

ALT

![](/image/attachment%3Aebcf148c-113f-4aa9-aea4-ed355bf2d258%3Ac63c19d8-0c90-4358-9e26-3c1f6854aea2.png?table=block&id=5cc468cc-8a1d-443e-b4a5-74f7c458695e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability $\mathrm{P}\left(\hat{\alpha}\_i\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (blue + symbols) and $\mathrm{P}\left(\Alpha[\hat{\alpha}\_i]\in[\alpha\_i(1-\gamma), \alpha\_i(1+\gamma)]\right)$ (red + symbols), obtained in $M=10^3$ simulations of leader election process for $\gamma=1/10$ , as a function of true relative stake  $\alpha\_i=n\alpha\_0$ , where  $\alpha\_0=1/10^4$ . The leader election process, with parameter $f=0.05$ , was simulated for $T=432000$ time-slots. The fraction of observed slots is  $q=1/100$ .

ALT

### Numerical Experiments

In this section, we compare performance of the statistical estimators  $\hat{\alpha}\_i$  and  $\Alpha[\hat{\alpha}\_i]$  in a single run of a simulation. This can be seen as a scenario where two adversaries collect the same data from the leader election process, but one of the adversaries knows  $\alpha\_0$  and uses this in the statistical inference. To simulate the statistical inference of relative stake in one epoch ( $T=432000$  time-slots) of the leader election process with parameter  $f=0.05$ , we sampled  $N=2\times10^3$  random (stake) values from the [Pareto distribution](https://en.wikipedia.org/wiki/Pareto_distribution) with shape parameter  $2.5$  and scale parameter  $2$ . The histogram of (relative) stake values is given below

![](/image/attachment%3Ac80b2c2f-3ab0-4aed-85dd-1106b1f36e6a%3AScreenshot_2025-05-30_at_15.35.36.png?table=block&id=4a2a1aab-0f61-4a0a-92b3-ab151a4c5607&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We consider inference only for  $5$  nodes with the highest relative stake and for  $5$  nodes with relative stake just above the threshold  $\alpha\_0=1/10^4$ . We consider a scenario where fraction  $q\in\{1/100,1/10,1\}$  of time-slots of the leader election process are observed by adversary. Here we find differences between estimators only for nodes with relative stake close to  $\alpha\_0$  as can be seen in the figures below.

![](/image/attachment%3Ad0fd7422-7c88-4b0d-a624-9924efef31d4%3A48b85f1a-810d-4fa3-a325-b0aa6eaa9735.png?table=block&id=f9f8159d-2e95-4ba3-a395-a44c97ceb42b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.007482,\ldots,0.013476\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.013476$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1$ .

ALT

![](/image/attachment%3A5603e165-ea7a-4b56-92bf-b32ae06be4a9%3A189eb8a2-1295-450b-b818-81f7f0568090.png?table=block&id=d2daef95-6e55-4cd0-96fb-bfd3e27898d7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.0001004999,\ldots,0.0001018357\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.0001018357$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1$ .

ALT

![](/image/attachment%3A5e7e0ed4-0b31-4fd8-9daa-35b4102c953d%3A0c35a1db-e76c-4ead-b7df-31bd371f732b.png?table=block&id=ad2d984c-81fa-4064-81a5-f6fd7fac3cd3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.007482,\ldots,0.013476\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.013476$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1/10$ .

ALT

![](/image/attachment%3A1843e6fa-b779-4c5f-92d3-5640baaec30b%3Ad5f0b6c2-0a29-4395-844c-6f533ba7b2b9.png?table=block&id=2a75024d-d805-4e73-a880-c045055bfc97&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.0001004999,\ldots,0.0001018357\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.0001018357$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1/10$ .

ALT

![](/image/attachment%3A697554e5-f6ac-48e3-8fec-71dedab492e4%3A6066059d-6d60-44e1-8dab-26fbe24cee5a.png?table=block&id=11cd61af-c167-4819-9767-2ccf7579c1d4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.007482,\ldots,0.013476\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.013476$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1/100$ .

ALT

![](/image/attachment%3Af782ae8a-5d7f-44f5-9441-42d76038b243%3Ab36278f3-c698-4123-8c9f-9d3891d73391.png?table=block&id=e6ca6c54-2e13-4b01-8557-522745e3f4ed&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (relative) stake estimator $\hat{\alpha}$ (left panel) and $\Alpha[\hat{\alpha}\_i]$ (right panel), computed in one epoch ( $T=432000$ time-slots) of the leader election process with parameter $f=0.05$ , plotted as a function of time-slots for five nodes with true (relative stake) $\alpha\in\{0.0001004999,\ldots,0.0001018357\}$ , represented by solid horizontal lines. The boundaries of the interval $[\alpha(1-\gamma), \alpha(1+\gamma)]$ for $\alpha=0.0001018357$ and $\gamma=1/10$ are represented by dashed horizontal lines. The dotted horizontal line corresponds to  $\alpha\_0=1/10^4$ . The fraction of observed slots is  $q=1/100$ .

ALT

## Appendix

### Inference of probability

The [leader election process](/1fd261aa09df8181a428f52251e173c4?pvs=25) is governed by the probability distribution

$$
\mathrm{P}(s\_1(t),\ldots,s\_N(t))=\prod\_{i=1}^N\left[\phi(\alpha\_i)\,\delta\_{1;s\_i(t)}+(1-\phi(\alpha\_i))\,\delta\_{0;s\_i(t)}\right]
$$
P(s1​(t),…,sN​(t))=i=1∏N​[ϕ(αi​)δ1;si​(t)​+(1−ϕ(αi​))δ0;si​(t)​]

of the outcome of election $s\_1(t),\ldots,s\_N(t)$ , where $s\_i(t)\in\{0,1\}$ models outcome ( $0/1\equiv$ loss/win) for node $i$ in time-slot $t$ . The fraction of observed wins of node $i$ in one epoch is

$$
\hat{P}\_i(1)=\frac{1}{\sum\_{t=1}^T\eta\_i(t)}\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}
$$
P^i​(1)=∑t=1T​ηi​(t)1​t=1∑T​ηi​(t)δ1;si​(t)​

where $\sum\_{t=1}^T\eta\_i(t)\geq1$ , with  $\eta\_i(t)\in\{0,1\}$ , is the total number of observations.

The average with respect to the [leader election process](/1fd261aa09df8181a428f52251e173c4?pvs=25) gives us

$$
\langle\hat{P}\_i(1)\rangle=\frac{1}{\sum\_{t=1}^T\eta\_i(t)}\sum\_{t=1}^T\eta\_i(t)\,\langle\delta\_{1;s\_i(t)}\rangle=\phi(\alpha\_i)
$$
⟨P^i​(1)⟩=∑t=1T​ηi​(t)1​t=1∑T​ηi​(t)⟨δ1;si​(t)​⟩=ϕ(αi​)

i.e. $\hat{P}\_i(1)$ is unbiased statistical estimator of prob. of winning $\phi(\alpha\_i)$ . In the above $\langle\{\cdots\}\rangle$ is the averaging “operator” defines as

$$
\langle\{\cdots\}\rangle=\left\{\prod\_{t=1}^T\prod\_{i=1}^N \sum\_{s\_i(t)}\mathrm{P}(s\_i(t))\right\} \{\cdots\}
$$
⟨{⋯}⟩=⎩⎨⎧​t=1∏T​i=1∏N​si​(t)∑​P(si​(t))⎭⎬⎫​{⋯}

where $\mathrm{P}(s\_i(t))=\phi(\alpha\_i)\,\delta\_{1;s\_i(t)}+(1-\phi(\alpha\_i))\,\delta\_{0;s\_i(t)}$ . Since  $\alpha\_i=\beta\_i+\alpha\_0$  and  $\phi(\beta\_i+\alpha\_0)\geq \phi(\alpha\_0)$ , from above follows that $\langle\hat{P}\_i(1)\rangle\geq \phi(\alpha\_0)$ .

The variance of $\hat{P}\_i(1)$ is given by

$$
\mathrm{Var}[\hat{P}\_i(1)]=\langle\hat{P}^2\_i(1)\rangle-\langle\hat{P}\_i(1)\rangle^2\\~~~~~~~~~~~~~~~=\frac{1}{\sum\_{t=1}^T\eta\_i(t)}\phi(\alpha\_i)[1-\phi(\alpha\_i)]
$$
Var[P^i​(1)]=⟨P^i2​(1)⟩−⟨P^i​(1)⟩2               =∑t=1T​ηi​(t)1​ϕ(αi​)[1−ϕ(αi​)]

If $\sum\_{t=1}^T\eta\_i(t)\rightarrow\infty$ as $T\rightarrow\infty$ , i.e. for a large number of observations, then $\mathrm{Var}[\hat{P}\_i(1)]\rightarrow0$ , i.e. $\hat{P}\_i(1)$ is a consistent estimator of the prob. $\phi(\alpha\_i)$ .

Let us define the new estimator of $\phi(\alpha\_i)$ as follows

$$
\Phi[\hat{P}\_i(1)]=\phi(\alpha\_0)\,\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]+\hat{P}\_i(1)\,\mathbf{1}[\hat{P}\_i(1)>\phi(\alpha\_0)]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~=\phi(\alpha\_0)\,\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]+\hat{P}\_i(1)\left\{1-\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\right\}\\~~=\hat{P}\_i(1)+\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}
$$
Φ[P^i​(1)]=ϕ(α0​)1[P^i​(1)≤ϕ(α0​)]+P^i​(1)1[P^i​(1)>ϕ(α0​)]                           =ϕ(α0​)1[P^i​(1)≤ϕ(α0​)]+P^i​(1){1−1[P^i​(1)≤ϕ(α0​)]}  =P^i​(1)+1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}

The average with respect to leader election process gives us

$$
\langle\Phi[\hat{P}\_i(1)]\rangle=\phi(\alpha\_i)+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle
$$
⟨Φ[P^i​(1)]⟩=ϕ(αi​)+⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩

i.e. the estimator $\Phi[\hat{P}\_i(1)]$ has (positive) bias. We expect that in the limit $\sum\_{t=1}^T\eta\_i(t)\rightarrow\infty$ as $T\rightarrow\infty$ , i.e. for a large number of observations, the average $\langle\Phi[\hat{P}\_i(1)]\rangle\rightarrow\phi(\alpha\_i)$ . We note that since $\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\{\phi(\alpha\_0)-\hat{P}\_i(1)\}\geq0$ , we have that

$$
\langle\Phi[\hat{P}\_i(1)]\rangle=\phi(\alpha\_i)+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\\leq \phi(\alpha\_i)+\phi(\alpha\_0)\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\right\rangle
$$
⟨Φ[P^i​(1)]⟩=ϕ(αi​)+⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩≤ϕ(αi​)+ϕ(α0​)⟨1[P^i​(1)≤ϕ(α0​)]⟩

and

$$
\langle\Phi[\hat{P}\_i(1)]\rangle\geq\phi(\alpha\_i)
$$
⟨Φ[P^i​(1)]⟩≥ϕ(αi​)

Now, for $\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))=\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\right\rangle$ by the Markov’s inequality we have

$$
\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))=\mathrm{Prob}\left(\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}\leq\phi(\alpha\_0)\sum\_{t=1}^T\eta\_i(t)\right)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\mathrm{Prob}\left(\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\geq\mathrm{e}^{-\lambda\phi(\alpha\_0)\sum\_{t=1}^T\eta\_i(t)}\right)\\~~\leq\frac{\left\langle\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\right\rangle}{\mathrm{e}^{-\lambda\phi(\alpha\_0)\sum\_{t=1}^T\eta\_i(t)}}
$$
Prob(P^i​(1)≤ϕ(α0​))=Prob(t=1∑T​ηi​(t)δ1;si​(t)​≤ϕ(α0​)t=1∑T​ηi​(t))                                       =Prob(e−λ∑t=1T​ηi​(t)δ1;si​(t)​≥e−λϕ(α0​)∑t=1T​ηi​(t))  ≤e−λϕ(α0​)∑t=1T​ηi​(t)⟨e−λ∑t=1T​ηi​(t)δ1;si​(t)​⟩​

where $\lambda>0$ . Using the [definition](/206261aa09df807bad8afccf8474c6c9?pvs=25#209261aa09df803d9e07f14c76435c45), the average on the RHS of the above can be computed as follows

$$
\left\langle\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\right\rangle=\left\{\prod\_{t=1}^T\prod\_{j=1}^N \sum\_{s\_j(t)}\mathrm{P}(s\_j(t))\right\}\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\\~~~~~~~~~~=\prod\_{t=1}^T\sum\_{s\_i(t)}\mathrm{P}(s\_i(t))\,\mathrm{e}^{-\lambda\eta\_i(t)\,\delta\_{1;s\_i(t)}}\\~~~~~~~~~~~~~~~~~~~=\prod\_{t=1}^T\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda\eta\_i(t)}+1-\phi(\alpha\_i)\right)\\~~~~~~~~~~=\mathrm{e}^{\sum\_{t=1}^T\log\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda\eta\_i(t)}+1-\phi(\alpha\_i)\right)}\\~~~~~~~~~~~~=\mathrm{e}^{\sum\_{t=1}^T\eta\_i(t)\log\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha\_i)\right)}
$$
⟨e−λ∑t=1T​ηi​(t)δ1;si​(t)​⟩=⎩⎨⎧​t=1∏T​j=1∏N​sj​(t)∑​P(sj​(t))⎭⎬⎫​e−λ∑t=1T​ηi​(t)δ1;si​(t)​          =t=1∏T​si​(t)∑​P(si​(t))e−ληi​(t)δ1;si​(t)​                   =t=1∏T​(ϕ(αi​)e−ληi​(t)+1−ϕ(αi​))          =e∑t=1T​log(ϕ(αi​)e−ληi​(t)+1−ϕ(αi​))            =e∑t=1T​ηi​(t)log(ϕ(αi​)e−λ+1−ϕ(αi​))

Using above result in the [inequality](/206261aa09df807bad8afccf8474c6c9?pvs=25#c731d476bd214a4f97d5fcb53a9925ce) we obtain

$$
\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))\leq\mathrm{e}^{\sum\_{t=1}^T\eta\_i(t)\left[\log\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha\_i)\right)+\lambda\phi(\alpha\_0)\right]}
$$
Prob(P^i​(1)≤ϕ(α0​))≤e∑t=1T​ηi​(t)[log(ϕ(αi​)e−λ+1−ϕ(αi​))+λϕ(α0​)]

Furthermore, optimising the RHS in above with respect to $\lambda$ we obtain the inequality

$$
\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))\leq \mathrm{e}^{\sum\_{t=1}^T\eta\_i(t)\left[\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha\_0) }\right)-\log \left(\frac{\phi(\alpha\_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{ 1-\phi(\alpha\_0) }\right) \phi(\alpha\_0)\right]}
$$
Prob(P^i​(1)≤ϕ(α0​))≤e∑t=1T​ηi​(t)[log(1−ϕ(α0​)1−ϕ(α)​)−log(ϕ(α)ϕ(α0​)​1−ϕ(α0​)1−ϕ(α)​)ϕ(α0​)]

We note that $\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha\_0) }\right)-\log \left(\frac{\phi(\alpha\_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{ 1-\phi(\alpha\_0) }\right) \phi(\alpha\_0)$ is monotonic decreasing function of $\phi(\alpha)$ which is exactly zero when $\phi(\alpha)=\phi(\alpha\_0)$ and hence this function is negative for $\phi(\alpha)\geq\phi(\alpha\_0)$ . Hence we have the following inequality

$$
\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))\leq \mathrm{e}^{-\sum\_{t=1}^T\eta\_i(t)\left[-\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha\_0) }\right)+\log \left(\frac{\phi(\alpha\_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{ 1-\phi(\alpha\_0) }\right) \phi(\alpha\_0)\right]}
$$
Prob(P^i​(1)≤ϕ(α0​))≤e−∑t=1T​ηi​(t)[−log(1−ϕ(α0​)1−ϕ(α)​)+log(ϕ(α)ϕ(α0​)​1−ϕ(α0​)1−ϕ(α)​)ϕ(α0​)]

where $-\log \left(\frac{1-\phi(\alpha)}{1-\phi(\alpha\_0) }\right)+\log \left(\frac{\phi(\alpha\_0)}{\phi(\alpha)}\frac{ 1-\phi(\alpha)}{ 1-\phi(\alpha\_0) }\right) \phi(\alpha\_0)> 0$ when $\phi(\alpha)>\phi(\alpha\_0)$ .

From above follows that $\mathrm{Prob}(\hat{P}\_i(1)\leq\phi(\alpha\_0))\rightarrow0$ in the limit $\sum\_{t=1}^T\eta\_i(t)\rightarrow\infty$ as $T\rightarrow\infty$ , i.e. for a large number of observations. Using the latter in the [upper bound](/206261aa09df807bad8afccf8474c6c9?pvs=25#585561b1774d4c8f9f089c9d47891bca) gives us that $\langle\Phi[\hat{P}\_i(1)]\rangle\rightarrow\phi(\alpha\_i)$ in this limit. If in the limit of large number of observations we also have that the $\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\rightarrow0$ then $\Phi[\hat{P}\_i(1)]$ is a consistent estimator of the prob. $\phi(\alpha\_i)$ .

For $\Phi[\hat{P}\_i(1)]=\hat{P}\_i(1)+\xi\_i$ , where we defined $\xi\_i=\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}$ , the $\mathrm{Var}[\Phi[\hat{P}\_i(1)]]$ is given by

$$
\mathrm{Var}[\Phi[\hat{P}\_i(1)]]=\mathrm{Var}[\hat{P}\_i(1)+\xi\_i]=\mathrm{Var}[\hat{P}\_i(1)]+2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\mathrm{Var}[\xi\_i].
$$
Var[Φ[P^i​(1)]]=Var[P^i​(1)+ξi​]=Var[P^i​(1)]+2Cov[P^i​(1),ξi​]+Var[ξi​].

In the [Variance section](/206261aa09df807bad8afccf8474c6c9?pvs=25#b91336f816a345cb89a09c1229fecf95) we show that

$$
\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\leq\mathrm{Var}[\hat{P}\_i(1)].
$$
Var[Φ[P^i​(1)]]≤Var[P^i​(1)].

Hence in the limit of large number of observations $\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\rightarrow0$ .

Thus from above follows that

$$
\Phi[\hat{P}\_i(1)]=\hat{P}\_i(1)+\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}
$$
Φ[P^i​(1)]=P^i​(1)+1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}

is unbiased and consistent estimator of the prob. $\phi(\alpha\_i)$ in the limit of large number of observations $\sum\_{t=1}^T\eta\_i(t)\rightarrow\infty$ as $T\rightarrow\infty$ .

For $\sum\_{t=1}^T\eta\_i(t)\geq1$ the [mean squared error](https://en.wikipedia.org/wiki/Mean_squared_error) (MSE) of the estimator $\hat{P}\_i(1)$ is given by

$$
\langle\vert \phi(\alpha\_i) -\hat{P}\_i(1)\vert^2\rangle =\mathrm{Var}[\hat{P}\_i(1)]=\frac{1}{\sum\_{t=1}^T\eta\_i(t)}\phi(\alpha\_i)[1-\phi(\alpha\_i)]
$$
⟨∣ϕ(αi​)−P^i​(1)∣2⟩=Var[P^i​(1)]=∑t=1T​ηi​(t)1​ϕ(αi​)[1−ϕ(αi​)]

Assuming that the $\eta\_i(t)$ variables are exactly the same as in the above, the MSE of the estimator $\Phi[\hat{P}\_i(1)]$ is given by

$$
\langle\vert \phi(\alpha\_i) -\Phi[\hat{P}\_i(1)]\vert^2\rangle ~~~=\mathrm{Var}[\Phi[\hat{P}\_i(1)]]+\left\vert\phi(\alpha\_i)-\langle\Phi[\hat{P}\_i(1)]\rangle\right\vert^2\\=\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle^2
$$
⟨∣ϕ(αi​)−Φ[P^i​(1)]∣2⟩   =Var[Φ[P^i​(1)]]+​ϕ(αi​)−⟨Φ[P^i​(1)]⟩​2=Var[Φ[P^i​(1)]]                                                                                 +⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩2

Consider the difference $\langle\vert \phi(\alpha\_i) -\Phi[\hat{P}\_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha\_i) -\hat{P}\_i(1)\vert^2\rangle$ as follows

$$
\langle\vert \phi(\alpha\_i) -\Phi[\hat{P}\_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha\_i) -\hat{P}\_i(1)\vert^2\rangle\\=\\\mathrm{Var}[\hat{P}\_i(1)]+2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\mathrm{Var}[\xi\_i]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle^2-\mathrm{Var}[\hat{P}\_i(1)]\\~~~~~~~~~~~~~~~~~~~~=2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\mathrm{Var}[\xi\_i]+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle^2\\~~~=2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}^2\right\rangle
$$
⟨∣ϕ(αi​)−Φ[P^i​(1)]∣2⟩−⟨∣ϕ(αi​)−P^i​(1)∣2⟩=Var[P^i​(1)]+2Cov[P^i​(1),ξi​]+Var[ξi​]                                              +⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩2−Var[P^i​(1)]                    =2Cov[P^i​(1),ξi​]+Var[ξi​]+⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩2   =2Cov[P^i​(1),ξi​]+⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}2⟩

Now the last line in the above can be bounded as follows

$$
2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}^2\right\rangle\\
%
~~~~~~~~~~~~~~=-2\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\
%
~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}^2\right\rangle\\
%
~~~~~~~~~~~~~~~\leq-2\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\
%
~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\
%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=-\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle
$$
2Cov[P^i​(1),ξi​]+⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}2⟩              =−2⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩   +⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}2⟩               ≤−2⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩                +⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩                                     =−⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩

Hence

$$
\langle\vert \phi(\alpha\_i) -\Phi[\hat{P}\_i(1)]\vert^2\rangle-\langle\vert \phi(\alpha\_i) -\hat{P}\_i(1)\vert^2\rangle\\
%
~~~~~\leq\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle
$$
⟨∣ϕ(αi​)−Φ[P^i​(1)]∣2⟩−⟨∣ϕ(αi​)−P^i​(1)∣2⟩     ≤                                                                           −⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩

Thus, the MSE of the unbiased estimator $\hat{P}\_i(1)$ is greater that the MSE of the biased, but consistent, estimator $\Phi[\hat{P}\_i(1)]$ .

### Variance of $\Phi[\hat{P}\_i(1)]$ ​

For $\Phi[\hat{P}\_i(1)]=\hat{P}\_i(1)+\xi\_i$ , where $\xi\_i=\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}$ , we consider the variance

$$
\mathrm{Var}[\Phi[\hat{P}\_i(1)]]=\mathrm{Var}[\hat{P}\_i(1)+\xi\_i]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\mathrm{Var}[\hat{P}\_i(1)]+2\,\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]+\mathrm{Var}[\xi\_i]
$$
Var[Φ[P^i​(1)]]=Var[P^i​(1)+ξi​]                                                                =Var[P^i​(1)]+2Cov[P^i​(1),ξi​]+Var[ξi​]

First, we consider the covariance

$$
\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]=\langle\hat{P}\_i(1)\,\xi\_i\rangle-\langle\hat{P}\_i(1)\rangle\langle\xi\_i\rangle\\=\langle\hat{P}\_i(1)\,\xi\_i\rangle-\phi(\alpha\_i)\langle\xi\_i\rangle\\=\left\langle\hat{P}\_i(1)\,\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle-\phi(\alpha\_i)\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\=-\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle
$$
Cov[P^i​(1),ξi​]=⟨P^i​(1)ξi​⟩−⟨P^i​(1)⟩⟨ξi​⟩=⟨P^i​(1)ξi​⟩−ϕ(αi​)⟨ξi​⟩=⟨P^i​(1)1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩−ϕ(αi​)⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)}⟩=−⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩

Because of $\phi(\alpha\_0)\leq \phi(\alpha\_i)$ , from the above it follows that $\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]\leq0$ .

Second, we consider the variance

$$
\mathrm{Var}[\xi\_i]=\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]^2\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}^2\right\rangle-\left\langle\xi\_i\right\rangle^2\\
%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)-\left\langle\xi\_i\right\rangle\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\
%
~=\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)+\phi(\alpha\_0)-\phi(\alpha\_i)-\left\langle\xi\_i\right\rangle\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle\\
%
~~~~~~~~\leq \left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_i)-\hat{P}\_i(1)\right\}\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle=-\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]
$$
Var[ξi​]=⟨1[P^i​(1)≤ϕ(α0​)]2{ϕ(α0​)−P^i​(1)}2⟩−⟨ξi​⟩2                             =⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(α0​)−P^i​(1)−⟨ξi​⟩}{ϕ(α0​)−P^i​(1)}⟩ =⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)+ϕ(α0​)−ϕ(αi​)−⟨ξi​⟩}{ϕ(α0​)−P^i​(1)}⟩        ≤⟨1[P^i​(1)≤ϕ(α0​)]{ϕ(αi​)−P^i​(1)}{ϕ(α0​)−P^i​(1)}⟩=−Cov[P^i​(1),ξi​]

Thus, from the above it follows that $\mathrm{Var}[\xi\_i]\leq -\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]$ . The latter with $-\mathrm{Cov}[\hat{P}\_i(1), \xi\_i] \geq 0$ implies $\mathrm{Cov}[\hat{P}\_i(1),\xi\_i]\leq-\mathrm{Var}[\xi\_i]/2$ which using the [variance equation](/206261aa09df807bad8afccf8474c6c9?pvs=25#878222bbfb1b42169fd4092dc6ea1ed1) gives us that

$$
\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\leq\mathrm{Var}[\hat{P}\_i(1)]
$$
Var[Φ[P^i​(1)]]≤Var[P^i​(1)]

\langle\{\cdots\}\rangle=\left\{\prod\_{t=1}^T\prod\_{i=1}^N \sum\_{s\_i(t)}\mathrm{P}(s\_i(t))\right\} \{\cdots\}

\left\langle\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\right\rangle=\left\{\prod\_{t=1}^T\prod\_{j=1}^N \sum\_{s\_j(t)}\mathrm{P}(s\_j(t))\right\}\mathrm{e}^{-\lambda\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}}\\~~~~~~~~~~=\prod\_{t=1}^T\sum\_{s\_i(t)}\mathrm{P}(s\_i(t))\,\mathrm{e}^{-\lambda\eta\_i(t)\,\delta\_{1;s\_i(t)}}\\~~~~~~~~~~~~~~~~~~~=\prod\_{t=1}^T\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda\eta\_i(t)}+1-\phi(\alpha\_i)\right)\\~~~~~~~~~~=\mathrm{e}^{\sum\_{t=1}^T\log\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda\eta\_i(t)}+1-\phi(\alpha\_i)\right)}\\~~~~~~~~~~~~=\mathrm{e}^{\sum\_{t=1}^T\eta\_i(t)\log\left(\phi(\alpha\_i)\,\mathrm{e}^{-\lambda}+1-\phi(\alpha\_i)\right)}

\langle\vert \phi(\alpha\_i) -\Phi[\hat{P}\_i(1)]\vert^2\rangle ~~~=\mathrm{Var}[\Phi[\hat{P}\_i(1)]]+\left\vert\phi(\alpha\_i)-\langle\Phi[\hat{P}\_i(1)]\rangle\right\vert^2\\=\mathrm{Var}[\Phi[\hat{P}\_i(1)]]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left\langle\mathbf{1}[\hat{P}\_i(1)\leq\phi(\alpha\_0)]\left\{\phi(\alpha\_0)-\hat{P}\_i(1)\right\}\right\rangle^2

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Impact-of-the-Service-Declaration-Protocol-on-the-Statistical-Inference-of-Relative-206261aa09df807bad8afccf8474c6c9?pvs=26&qid=1:b00b1549-7b6d-4cef-887f-564e3c7fe0f1:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Impact of the Service Declaration Protocol on the Statistical Inference of Relative Stake

Revision History

Table

Introduction

The Service Declaration Protocol (SDP) introduces a piece of a priori information: the knowledge that a node's relative stake cannot be less than a known threshold, ΣEquation. Our research investigates the significance of the impact of this information on the statistical inference of relative stake. We propose a new estimator which explicitly utilises ΣEquation by setting any estimated stake below this threshold to ΣEquation.

Our new estimator works better because it fixes estimation errors at the lower end. When a node's true stake value (ΣEquation) is close to the minimum threshold (ΣEquation), the standard maximum likelihood (ML) estimator often produces values that are too low. By automatically adjusting these too-low estimates up to the minimum threshold (ΣEquation), our new approach reduces errors. This improvement can be measured as a lower mean squared error (MSE) compared to the true stake value (ΣEquation). Thus any party, including potential adversaries, performing stake inference gains in accuracy by using the new estimator.

Numerical experiments demonstrate reduction in MSE of the new estimator compared to the ML estimator, particularly for stakes near ΣEquation. For example, for ΣEquation used in experiments, a reduction of MSE by a (approx.) factor of at most ΣEquation was observed. Furthermore, the probability, measured in the same experiment, that the inferred stake falls within a desired accuracy interval is higher (by factor of (approx.) ΣEquation at least) when the new estimator is used. While the advantage diminishes for much higher stake values where both estimators converge, the heightened accuracy near the critical ΣEquation threshold presents a meaningful enhancement for any party performing stake inference, including potential adversaries.

Key Findings

- Introduction of a priori information: The Service Declaration Protocol (SDP) introduces the knowledge that a node's relative stake cannot be less than a threshold (ΣEquation), which impacts statistical inference of relative stake⁠⁠.
- New estimator proposed: The research introduces a new estimator that explicitly uses α₀ by setting any estimated stake below this threshold to ΣEquation⁠⁠.
- Improved accuracy: The new estimator performs better because it corrects estimation errors at the lower end, particularly when a node's true stake value is close to the minimum threshold⁠⁠.
- Measurable improvements: Numerical experiments show:

  - Reduction in Mean Squared Error (MSE) of the new estimator compared to the ML estimator, particularly for stakes near ΣEquation⁠⁠.
  - For ΣEquation, MSE reduction by a factor of approximately ΣEquation was observed⁠⁠.
  - Higher probability (by a factor of approximately 3) that inferred stake falls within desired accuracy intervals⁠⁠.
- Statistical significance: The advantage diminishes for much higher stake values where both estimators converge, but the enhanced accuracy near the critical α₀ threshold presents a meaningful improvement for any party performing stake inference⁠⁠.
- Security implications: This improvement benefits anyone performing stake inference, including potential adversaries⁠⁠.

The research provides mathematical proof and numerical simulations to validate these findings, showing that the proposed estimator is both unbiased and consistent in the limit of large number of observations⁠⁠.

Overview

This document examines the impact of minimum stake threshold, introduced in the SDP, on the statistical inference of relative stake along the following points:

![](/image/attachment%3Aaf3bbdfb-1a69-4f1e-a947-fc843b63d24e%3AChatGPT_Image_Jul_9_2025_12_26_01_PM.png?table=block&id=22b261aa-09df-80ae-a152-ea44acd86a1d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In particular:

1. We consider the Leader Election Process where nodes allowed to participate only if their relative stake is no less than some prescribed by SDP threshold.
2. We assume that the Adversary observes wins (and losses) of nodes and uses statistical inference to infer relative stake of nodes.
3. The Adversary knows the SDP stake threshold, and using this information, the Adversary constructs a statistical estimator.
4. This New estimator improves inference of stake when compared with an estimator which doesn’t use the SDP threshold. The simulation of adversarial inference shows that those most affected by this improvement are the nodes with values of relative stake close to the threshold.

Analysis

The Model

The relative stake of node ΣEquation, ΣEquation, is computed via the formula ΣEquation, where ΣEquation is the stake of node ΣEquation. We assume that the total stake ΣEquation can be inferred (with high accuracy) by using the total stake inference algorithm. We note that for the set ΣEquation, i.e. relative stakes of all nodes, it is possible that ΣEquation. It is known, through the declaration of the Service Declaration Protocol (SDP), that the relative stake of a node is at least ΣEquation. For ΣEquation, the relative stake of a node ΣEquation can be written as ΣEquation, where ΣEquation is unknown. Intuitively, this suggests that if, relative to the ΣEquation, the minimum stake ΣEquation is large, then then there is less “uncertainty” about the relative stake ΣEquation.

Node ΣEquation participates in the leader election and its probability of winning is given by the “lottery” function

📈Equation

where ΣEquation is the parameter of the consensus. Since the lottery function ΣEquation is a monotonically increasing function of relative stake, for the relative stake ΣEquation we have ΣEquation, i.e. the prob. of winning for nodes with relative stake greater than ΣEquation is higher.

Inference of relative stake

For the fraction of wins ΣEquation in the ΣEquation observations of the leader election process of a node the (naive) statistical estimator of ΣEquation, ΣEquation, is the solution of the equation ΣEquation given by

📈Equation

We note that for ΣEquation we have that ΣEquation. The estimator ΣEquation is biased because

📈Equation

where the average ΣEquation is defined in the Appendix. However, the average ΣEquation and the variance ΣEquation. If ΣEquation when ΣEquation then in this (”large number of observations”) limit we have

📈Equation

i.e. ΣEquation is consistent estimator of the relative stake ΣEquation.

Similarly to the estimator of ΣEquation, we construct new estimator of relative stake

📈Equation

The above can be written as follows

📈Equation

We note that ΣEquation from which follows that

📈Equation

but we showed that ΣEquation for a large number of observations, and hence ΣEquation in this limit.

Let us consider the (squared) distance

📈Equation

From the above follows the difference

📈Equation

Now, because ΣEquation, we have the following inequality

📈Equation

and hence

📈Equation

i.e. the mean squared error (MSE) of the estimator ΣEquation is greater than the MSE of the estimator ΣEquation. Furthermore, for the MSE of ΣEquation we have

📈Equation

Now ΣEquation is a consistent estimator of the relative stake ΣEquation and hence ΣEquation in the large number of observations limit, but ΣEquation, so ΣEquation is also a consistent estimator of the relative stake ΣEquation.

Simulations confirm that MSE of the estimator ΣEquation is greater than the MSE of the new estimator ΣEquation, as can be seen in the figures below.

![](/image/attachment%3A2678cd60-9e32-4836-942c-7b2aaecc4927%3A73cab8dd-4078-4667-9d0c-a9ce90dbcece.png?table=block&id=60c13593-6bd3-4647-b31c-c3fc65955de2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A6134b659-a19b-4995-8169-6be4dc9dee5c%3A9885ed6e-8178-4467-944f-b2f1ddad5ece.png?table=block&id=0f4a1c28-af9a-41ac-ba19-6a43d154edb9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3Af40e2e20-3706-4b65-a68f-cc4cbac90ab3%3A8c01a4e6-ffe6-40d3-8040-306fee14cc0c.png?table=block&id=14f31751-9f1a-4527-acf1-f59a0d1f412f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We are interested in the probability ΣEquation which can be seen as adversarial "confidence". Here ΣEquation prescribes desired “accuracy” of the inference. We note that the probability ΣEquation can be estimated analytically for large ΣEquation. If for a given (accuracy) parameter ΣEquation we have that ΣEquation then the adversary has an advantage by using the new estimator, i.e. an adversary which knows that ΣEquation has a higher confidence than the adversary which doesn’t know the latter.

Recall that ΣEquation. We note that ΣEquation, provided ΣEquation. Let us assume (without loss of generality) that ΣEquation for some ΣEquation. Then, from ΣEquation follows that ΣEquation. Hence, if this inequality is satisfied, an adversary may have advantage. We compute the probabilities ΣEquation and ΣEquation using simulation and find that the adversary has advantage for the relative stake ΣEquation, as can be seen in figures below.

![](/image/attachment%3A77498bf4-d0c3-4245-8d23-051784c9ad2e%3A85c026e3-c782-42aa-b2fd-85fa25526c7c.png?table=block&id=48c26d1a-420b-43c5-a43a-2e3b26de5036&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A92137e05-cf14-4727-b836-4c1cb595da56%3Ac91bc5ac-9de4-4f84-833f-7fb64ae521b6.png?table=block&id=300d0df8-6895-49f7-8b89-b45f11966ae3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3Aebcf148c-113f-4aa9-aea4-ed355bf2d258%3Ac63c19d8-0c90-4358-9e26-3c1f6854aea2.png?table=block&id=5cc468cc-8a1d-443e-b4a5-74f7c458695e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Numerical Experiments

In this section, we compare performance of the statistical estimators ΣEquation and ΣEquation in a single run of a simulation. This can be seen as a scenario where two adversaries collect the same data from the leader election process, but one of the adversaries knows ΣEquation and uses this in the statistical inference. To simulate the statistical inference of relative stake in one epoch (ΣEquation time-slots) of the leader election process with parameter ΣEquation, we sampled ΣEquation random (stake) values from the Pareto distribution with shape parameter ΣEquation and scale parameter ΣEquation. The histogram of (relative) stake values is given below

![](/image/attachment%3Ac80b2c2f-3ab0-4aed-85dd-1106b1f36e6a%3AScreenshot_2025-05-30_at_15.35.36.png?table=block&id=4a2a1aab-0f61-4a0a-92b3-ab151a4c5607&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We consider inference only for ΣEquation nodes with the highest relative stake and for ΣEquation nodes with relative stake just above the threshold ΣEquation. We consider a scenario where fraction ΣEquation of time-slots of the leader election process are observed by adversary. Here we find differences between estimators only for nodes with relative stake close to ΣEquation as can be seen in the figures below.

![](/image/attachment%3Ad0fd7422-7c88-4b0d-a624-9924efef31d4%3A48b85f1a-810d-4fa3-a325-b0aa6eaa9735.png?table=block&id=f9f8159d-2e95-4ba3-a395-a44c97ceb42b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A5603e165-ea7a-4b56-92bf-b32ae06be4a9%3A189eb8a2-1295-450b-b818-81f7f0568090.png?table=block&id=d2daef95-6e55-4cd0-96fb-bfd3e27898d7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A5e7e0ed4-0b31-4fd8-9daa-35b4102c953d%3A0c35a1db-e76c-4ead-b7df-31bd371f732b.png?table=block&id=ad2d984c-81fa-4064-81a5-f6fd7fac3cd3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A1843e6fa-b779-4c5f-92d3-5640baaec30b%3Ad5f0b6c2-0a29-4395-844c-6f533ba7b2b9.png?table=block&id=2a75024d-d805-4e73-a880-c045055bfc97&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3A697554e5-f6ac-48e3-8fec-71dedab492e4%3A6066059d-6d60-44e1-8dab-26fbe24cee5a.png?table=block&id=11cd61af-c167-4819-9767-2ccf7579c1d4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/attachment%3Af782ae8a-5d7f-44f5-9441-42d76038b243%3Ab36278f3-c698-4123-8c9f-9d3891d73391.png?table=block&id=e6ca6c54-2e13-4b01-8557-522745e3f4ed&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Appendix

Inference of probability

The leader election process is governed by the probability distribution

📈Equation

of the outcome of election ΣEquation, where ΣEquation models outcome (ΣEquation loss/win) for node ΣEquation in time-slot ΣEquation. The fraction of observed wins of node ΣEquation in one epoch is

📈Equation

where ΣEquation, with ΣEquation, is the total number of observations.

The average with respect to the leader election process gives us

📈Equation

i.e. ΣEquation is unbiased statistical estimator of prob. of winning ΣEquation. In the above ΣEquation is the averaging “operator” defines as

📈Equation

where ΣEquation. Since ΣEquation and ΣEquation, from above follows that ΣEquation.

The variance of ΣEquation is given by

📈Equation

If ΣEquation as ΣEquation, i.e. for a large number of observations, then ΣEquation, i.e. ΣEquation is a consistent estimator of the prob. ΣEquation.

Let us define the new estimator of ΣEquation as follows

📈Equation

The average with respect to leader election process gives us

📈Equation

i.e. the estimator ΣEquation has (positive) bias. We expect that in the limit ΣEquation as ΣEquation, i.e. for a large number of observations, the average ΣEquation. We note that since ΣEquation, we have that

📈Equation

and

📈Equation

Now, for ΣEquation by the Markov’s inequality we have

📈Equation

where ΣEquation. Using the definition, the average on the RHS of the above can be computed as follows

📈Equation

Using above result in the inequality we obtain

📈Equation

Furthermore, optimising the RHS in above with respect to ΣEquation we obtain the inequality

📈Equation

We note that ΣEquation is monotonic decreasing function of ΣEquation which is exactly zero when ΣEquation and hence this function is negative for ΣEquation. Hence we have the following inequality

📈Equation

where ΣEquation when ΣEquation.

From above follows that ΣEquation in the limit ΣEquation as ΣEquation, i.e. for a large number of observations. Using the latter in the upper bound gives us that ΣEquation in this limit. If in the limit of large number of observations we also have that the ΣEquation then ΣEquation is a consistent estimator of the prob. ΣEquation.

For ΣEquation, where we defined ΣEquation, the ΣEquation is given by

📈Equation

In the Variance section we show that

📈Equation

Hence in the limit of large number of observations ΣEquation.

Thus from above follows that

📈Equation

is unbiased and consistent estimator of the prob. ΣEquation in the limit of large number of observations ΣEquation as ΣEquation.

For ΣEquation the mean squared error (MSE) of the estimator ΣEquation is given by

📈Equation

Assuming that the ΣEquation variables are exactly the same as in the above, the MSE of the estimator ΣEquation is given by

📈Equation

Consider the differenceΣEquation as follows

📈Equation

Now the last line in the above can be bounded as follows

📈Equation

Hence

📈Equation

Thus, the MSE of the unbiased estimator ΣEquation is greater that the MSE of the biased, but consistent, estimator ΣEquation.

Variance of ΣEquation

For ΣEquation, where ΣEquation, we consider the variance

📈Equation

First, we consider the covariance

📈Equation

Because of ΣEquation, from the above it follows that ΣEquation.

Second, we consider the variance

📈Equation

Thus, from the above it follows that ΣEquation. The latter with ΣEquation implies ΣEquation which using the variance equation gives us that

📈Equation

- Open in new tab
