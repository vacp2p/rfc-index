# ANALYSIS-TOTAL-STAKE-INFERENCE

| Field | Value |
| --- | --- |
| Name | [Analysis] Total Stake Inference |
| Slug | 198 |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Alexander Mozeika <alexander.mozeika@logos.co>, Daniel Kashepava <danielkashepava@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-total-stake-inference.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-total-stake-inference.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

Authors: David Rusu <davidrusu@status.im>, Alexander Mozeika <alexander.mozeika@status.im>, Daniel Kashepava <danielkashepava@status.im>

# Revision History

# Introduction

Cryptarchia consensus leadership is determined by a lottery in which the chances of winning are higher for eligible nodes with a greater stake relative to the total active stake. At the same time, the true total active stake cannot be known by participants due to the privacy properties of Logos Blockchain notes. This tension is resolved in Cryptarchia by having the network estimate the total active stake based on the observed activity of the network.

## Goals

The Cryptarchia total stake inference algorithm must satisfy the following criteria:

1. The inference process converges quickly, yielding a mean estimate that closely matches the true total stake. However, mean accuracy alone is not sufficient—if the estimator’s variance remains high at steady state, block production rates may fluctuate significantly. Thus, effective total stake inference requires both rapid, accurate mean convergence and low variance to ensure stable, predictable block production throughout the protocol.
1. The process can be approximated well enough with the information we have in Cryptarchia.

# Overview

This document provides an analysis of the Cryptarchia total stake inference algorithm based on the following criteria:

- Accuracy: The closeness of the mean inferred total stake to the true total stake; it measures systematic bias in the estimator.
- Precision: The degree to which repeated inferences yield similar results at equilibrium; it is quantified by the variance of the estimator and reflects how tightly values cluster around the mean, independent of accuracy.
- Stability Conditions: The range of possible values for the learning rate $\beta$ that result in the stake inference values converging to the true total stake under stable conditions.
- Convergence Speed: The bounds under which the total stake inference values converge exponentially to the true total stake under stable conditions. This analysis also includes an optimal value for $\beta$.

## Total Stake Inference Process

The inference algorithm is described in [🔀[1.0.0] Total Stake Inference - Algorithm](https://nomos-tech.notion.site/Algorithm-22d261aa09df8051a454caa46ec54b34?pvs=24#22d261aa09df8015bf22fb28aa0c0ea1). In order to analyze the properties of this algorithm, we model it analytically as the following sequence $\{D_\ell\}_{\ell=0}^\infty$. We then verify that this model aligns with the algorithm to ensure that the analysis accurately reflects the actual process.

$$
D_{\ell+1}=D_{\ell}-\frac{\beta}{f}D_\ell\left[f-\frac{\sum_{t=1}^T \mathbf{1}\left[\sum_{i=1}^N s^\ell_i(t)\geq1\right] - n(\ell)}{T}\right]
$$

where,

- $D_{\ell}$ is the inferred total stake at epoch $\ell$;
- $\beta$ is the learning rate which governs how quickly we adjust our estimate to new information;
- $f$ is the target slot occupancy rate;
- $T$ is the observation period in which we observe the slot occupancy rate;
- $\mathbf{1}[p]$ is the indicator function resolving to $1$ if $p$ is true, $0$ otherwise;
- $N$ is the number of nodes in the system;
- $s^\ell_i(t)\in \{0,1\}$ is the lottery result of node $i$ at slot $t$, in epoch $\ell$; here, 1 signals a win, and 0 signals a loss;
- $n(\ell) \in \left\{0,1,...,\sum_{t=1}^T \mathbf{1}\left[\left(\sum_{i=1}^N s^\ell_i(t)\right)\geq1\right] \right\}$ is the number of slots in epoch $\ell$ that could have extended the honest chain but instead were wasted on orphaned blocks.

We note that the form above captures how the protocol updates its estimate of the total active stake based on observed network activity, and the actual inference process is described at: [🔀[1.0.0] Total Stake Inference - Algorithm](https://nomos-tech.notion.site/Algorithm-22d261aa09df8051a454caa46ec54b34?pvs=24#22d261aa09df8015bf22fb28aa0c0ea1). Specifically, at each epoch $\ell$, the estimate $D_\ell$ is adjusted according to the difference between the target slot occupancy rate $f$ and the observed average fraction of slots with at least one block extending the honest chain (after accounting for wasted slots, $n(\ell)$). The learning rate $\beta$ and normalization by $f$ control how aggressively the estimate is updated.

# Analysis

## Accuracy

The process converges to the following value:

$$
\mathbb{E}\left[ D_{\infty}\right] = \frac{\log(1-f)}{\log(1-f/q)}\cdot D_\text{TRUE}
$$

where,

- $\mathbb{E}\left[D_\infty\right]$ is the mean fixed point of the inference process;
- $D_\text{TRUE}$ is the true total stake active during the consensus protocol execution;
- $q\in(f,1]$ is the honest slot utilization rate representing the rate of occupied slots contributing to the honest chain growth.

We note that for $q\in(f,1]$, we have that $\log(1-f)/\log(1-f/q)\leq1$. This suggests that increased network delay, which reduces the honest slot utilization rate through wasted blocks results in a systematic underestimate of true total stake.

For a derivation of this result, please see [Accuracy Derivation](https://nomos-tech.notion.site/Accuracy-Derivation-237261aa09df800285cccbb00b3aeb0a?pvs=24#239261aa09df80aa982edf0fd6dddf8f).

### Measuring $q$ from simulations

In simulation, we can derive the value $q$ by measuring how many of the active slots contributed towards the honest chain with this formula:

$$
\small{q = \frac{\text{total\_honest\_chain\_slots}}{\text{total\_active\_slots}}}
$$

Since $q$ varies by epoch and is impacted by the total stake inference process, measurements should be taken after the system converges to a steady state. From simulations, this tends to be after 5 epochs.

![](https://nomos-tech.notion.site/image/attachment%3A40662e98-e80e-451c-a88a-e675f6800415%3Aimage.png?table=block&id=245261aa-09df-80d5-9dcd-c992d62fb912&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=580&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Simulation Results

This result predicts that we consistently underestimate true stake by a factor of $\frac{\log(1-f)}{\log(1-f/q)}$. We verified this prediction in simulations and saw a strong correlation between this prediction and the stake we inferred in simulation:

![](https://nomos-tech.notion.site/image/attachment%3A2045459c-797a-46d8-aab0-45ccce995414%3Aimage.png?table=block&id=242261aa-09df-8012-a38f-ee4a8ba95045&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1350&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Connecting Simulation to Logos Blockchain

With our choice of Blend Network parameters, we measured a $q$ value of 0.85 in simulation, plugging that into our model gives $\frac{\log(1-f)}{\log(1-f/q)}\approx 0.847$. That is, if the Blend Network behaves like our simulation, we expect to infer a total stake that is ~84.7% of the true total stake, or ~15% below true total stake. This loss in accuracy is due to not being able to count blocks off the honest branch.

## Precision

The variance at equilibrium is given by

$$
\mathrm{Var}\left[\frac{D_{\infty}}{D_\text{TRUE}}\right]=\left(\frac{\beta}{f}\right)^2\frac{q}{T}\left(\frac{\log(1-f)}{\log(1-f/q)}\right)^2(1-f)f
$$

Furthermore, because of $q\in(f,1]$ and  $\log (1-f) / \log (1-f/q) \leq1$, the variance is bounded above by:

$$
\mathrm{Var}\left[\frac{D_{\infty}}{D_\text{TRUE}}\right]\leq \frac{(\beta/f)^2}{T}(1-f)f
$$

The implication is that wasted blocks caused by network delays have a stabilizing effect on the inference process. As the network delay grows, the variance in our estimate decreases.

For a derivation of this result, see [Precision Derivation](https://nomos-tech.notion.site/Precision-Derivation-237261aa09df800285cccbb00b3aeb0a?pvs=24#239261aa09df80d685cfdfca09836a2e).

### Simulation Results

Checking these predictions in simulations shows very good agreement with analysis:

![](https://nomos-tech.notion.site/image/attachment%3A7cda3113-eae3-4ced-b4c7-66a455c6e14c%3Avar_with_converged_q.png?table=block&id=239261aa-09df-8090-9a39-d6d700c2da2f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Stability Condition

The inference process is stable for $\beta$ values that satisfy the following condition

$$
\beta < \frac{2f}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)}
$$

where $q$ is the honest slot utilization rate as mentioned above.

Note that for $q=1$ (perfect network, all active slots are used by the honest chain), we have a lower bound on the stability condition, meaning we can tolerate a higher learning rate $\beta$ and converge faster when the network is inefficient:

$$
\frac{2f}{\left(1 -f \right) \log \! \left(\frac{1}{1-f}\right)} \le  \frac{2f}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)}
$$

For a derivation of this result, see [Stability Condition Derivation](https://nomos-tech.notion.site/Stability-Condition-Derivation-237261aa09df800285cccbb00b3aeb0a?pvs=24#239261aa09df80c88c38ea1981a7fa4c).

### Simulation Results

In simulations, we see that when we exceed the condition, the spread in $D_\infty$ values explodes for $\beta \ge \frac{2f}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)}$.

![](https://nomos-tech.notion.site/image/attachment%3A21099e55-964b-4689-a48e-22405703d097%3Aconvergence-with-q.png?table=block&id=237261aa-09df-808a-b6bf-e43738f04a39&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Convergence Speed and Optimal Learning Rate

The process converges exponentially with the following bound:

$$
\left| \frac{\mathbb{E}\left[ D_\ell\right] - \mathbb{E}\left[ D_\infty \right]}{D_\text{TRUE}} \right| 

\leq A\, \left|\frac{D_0 - \mathbb{E}\left[ D_\infty \right]}{D_\text{TRUE}} \right| \times \left\vert1-\frac{\beta}{f} \left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)\right\vert^\ell
$$

That is, for some constant $A>0$, at epoch $\ell$, the distance between the value for the total stake $D_\ell$ and the equilibrium estimate $D_\infty$ falls exponentially. Moreover, this result predicts an optimal convergence rate

$$
\beta=\frac{f}{\left(q -f \right)\log \! \left(\frac{1}{1-\frac{f}{q}}\right) }
$$

For reasonable $q$ values, this gives us a $\beta$ slightly higher than 1. Choosing a smaller $\beta$ can only improve the stability of the inference algorithm. This fact, combined with the uncertainty in selecting a $q$ value suggests that we should just select $\beta=1$ as our learning rate.

![](https://nomos-tech.notion.site/image/attachment%3Ab69810b6-9fbd-4e4a-9e34-f40083af4d79%3Aimage.png?table=block&id=23b261aa-09df-808f-9bcb-c97e7b92f606&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For a derivation of this result, see [Convergence Speed and Optimal Learning Rate Derivation](https://nomos-tech.notion.site/Convergence-Speed-and-Optimal-Learning-Rate-Derivation-237261aa09df800285cccbb00b3aeb0a?pvs=24#239261aa09df80c38aa6dcb253267961).

### Simulation Results

We verified these results in simulations, showing that the bound holds for varying $\beta$’s.

The plots show the measured normalized error $\left|\frac{\langle D_\ell\rangle - \langle D_\infty \rangle}{D_\text{TRUE}} \right|$ decreasing as epoch $\ell$ increases. Cryptarchia parameters for all plots were $f=1/30,T=6k/f,k=2160,q=0.85$.

![](https://nomos-tech.notion.site/image/attachment%3Ad0af5a00-2fe0-4463-a38a-761fe421cfed%3Aimage.png?table=block&id=239261aa-09df-8040-8a0e-c23ba6dc18a4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A23eb9a70-a31c-427f-a5f9-d3c326262e34%3Aimage.png?table=block&id=239261aa-09df-80a9-8c4e-c0d30d48cd6e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A3166a54d-02c9-4136-be93-196640ec9687%3Aimage.png?table=block&id=239261aa-09df-80cd-991b-d4386b6386ca&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A038ebd73-d0f3-43b6-9f4f-22ed7676a31b%3Aimage.png?table=block&id=239261aa-09df-8068-94c9-d29043cb2e19&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Optimal convergence was checked as well showing that with [optimal](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80d5ae07d87365c93139)[/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80d5ae07d87365c93139](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80d5ae07d87365c93139)$\beta$, even with massive shocks to total stake, we can converge within 2 epochs.

Plots show the distribution of normalized error $\left|\frac{\langle D_\ell\rangle - \langle D_\infty \rangle}{D_\text{TRUE}} \right|$ at each epoch $\ell$ for the optimal $\beta$ parameter under different initial conditions. Cryptarchia parameters for all plots were $f=1/30,T=6k/f,k=2160,q=0.85,\beta=1$.

![](https://nomos-tech.notion.site/image/attachment%3Ae412953b-84c0-4061-8190-bc2cb457ce49%3Aimage.png?table=block&id=239261aa-09df-80ed-a464-e7d667f45c9f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ae79a6dc9-2b5b-469c-9fc1-c1d175f32506%3Aimage.png?table=block&id=239261aa-09df-80f7-b62b-c1d4c4d97efb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Details

## Accuracy Derivation

The following is the derivation for the property described in [Accuracy](https://nomos-tech.notion.site/Accuracy-237261aa09df800285cccbb00b3aeb0a?pvs=24#237261aa09df80e2a19ccca6b79912d9).

- The total stake inference equation is given by

$$
D_{\ell+1}=D_{\ell}-h(\ell)\left[f-\frac{1}{T}\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_\ell\bigg)\geq1\bigg]\right],
$$

where  $h(\ell)>0$ is the learning rate. In the above, we write $s_i(t)\vert D_\ell$ to emphasise that the random variable $s_i(t)$ is conditional on $D_\ell$.

- In the [equation used in inference of total stake](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df8096a67cc0fdc312541a), we take $h(\ell) = \frac{\beta}{f} D_\ell$ but the starting point of our analysis uses a more general learning rate $h(\ell)$.
- We note that $\sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]$ is the number of active slots, i.e. slots with at least one winner, in the $\ell$-th epoch.
- For the outcome of leader election process $\mathbf{s}(t)=(s_1(t),\ldots,s_N(t))$ at the time-slot $t$, the probability of outcomes $\left(\mathbf{s}(1),\ldots,\mathbf{s}(T)\right)$ at times $t\in[T]$ is given by

$$
\mathrm{P}[\mathbf{s}(1),\ldots,\mathbf{s}(T)\vert D_{\ell}]=\prod_{t=1}^T\prod_{i=1}^N \left[\phi_f(w_i/D_{\ell})\,\delta_{1;s_i(t)}+(1-\phi_f(w_i/D_{\ell}))\,\delta_{0;s_i(t)}\right],
$$

where

$$
\phi_f(\alpha)=1-(1-f)^{\alpha}
$$

is the probability of winning and $w_i$ is the stake of node $i$.

- We note that $D_\ell$ is a random variable.
- Node $i$ uses its (local) copy of the blockchain in the inference of the total stake and the latter can give a different count for the number of active slots  because of a number of slots being “wasted”.
- To model this scenario, we introduce variable $n(\ell)\vert \sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]\in\left\{0,1,\ldots,\sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]\right\}$, i.e. $n(\ell)$ is conditional on $\sum_{t=1}^T \mathbf{1}\big[\left(\sum_{i=1}^N s_i(t)\vert D_\ell \right)\geq1\big]$, such that

$$
\sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]-n(\ell)\bigg\vert \sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]
$$

is the number of blocks on the chain of an honest node, i.e. the number of “honest” slots. The latter will be used for inference by an honest node as follows

$$
D_{\ell+1}=D_{\ell}-h(\ell)\left[f-\frac{1}{T}\left\{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_\ell\bigg)\geq1\bigg]-n(\ell)\right\}\right],
$$

where in above $n(\ell)\equiv n(\ell)\vert \sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]$.

- We note that

$$
\begin{align*}
D_{\ell+1} &= D_{\ell}-h(\ell)\left[f-\frac{1}{T}\left\{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_\ell\bigg)\geq1\bigg]-n(\ell)\right\}\right] \\
  &\leq D_{\ell}-h(\ell)\left[f-\frac{1}{T}\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_\ell\bigg)\geq1\bigg]\right]
\end{align*}
$$

i.e. for the same $D_\ell$, the $D_{\ell+1}$ of the honest node’s [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df80c7a5c6f9f0c3cdbd46) is bounded above by the $D_{\ell+1}$ of the idealised [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df8078a24fdd48297f42f7).

- Let us assume that $n(\ell)$ is a random variable from the binomial distribution with the parameters $p(\ell)$ and $\sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]$.
- Here $p(\ell)$ is the probability that a slot is “wasted” in epoch $\ell$ and hence there are (on average) $p(\ell) \sum_{t=1}^T \mathbf{1}\big[\big(\sum_{i=1}^N s_i(t)\vert D_\ell\big)\geq1\big]$ number of slots wasted in epoch $\ell$.
- We note that the above assumption about $n(\ell)$ is mathematically convenient but not necessary true. However it is the simplest non-trivial assumption, and its validity can be tested in simulations.
- We first consider the equation

$$
D_{1}=D_0-h(0)\left[f-\frac{1}{T}\left\{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]-n(0)\right\}\right]
$$

- Averaging above over the random variable $n(0)$ gives us the equation

$$
D_{1}=D_0-h(0)\left[f-\frac{1-p(0)}{T}\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]\right]
$$

- Now, let us assume that $D_0$ is deterministic and consider the average of $D_1$, $\langle D_1\rangle_0$, with respect to the [distribution](/237261aa09df800285cccbb00b3aeb0a?pvs=25#23a261aa09df803a8185c37e84d12a0e) as follows

$$
\langle D_1\rangle_0=D_{0}-h(0)\left[f-\frac{1-p(0)}{T}\sum_{t=1}^T \left\langle \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]\right\rangle_0\right]\\
%
=D_{0}-h(0)\left[f-\frac{1-p(0)}{T}\sum_{t=1}^T \left\langle \left[1-\mathbf{1}\!\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)=0\bigg]\right]\right\rangle_0\right]\\
%
%=D_{0}-h(0)\left[f-\frac{1}{T}\sum_{t=1}^T \eta_i(t)\, \left\{1-\left\langle\mathbf{1}\!\bigg[\sum_{i=1}^N s_i(t)=0\bigg]\right\rangle_0\right\}\right]\\
%
=D_{0}-h(0)\left[f-  [1-p(0)]\left[1-(1-f)^{D^0[\mathbf{w}]/D_0}\right]\right]
$$

- Thus using in above the [definition](/237261aa09df800285cccbb00b3aeb0a?pvs=25#247261aa09df802a9a0fd2d2facbccb6) we obtain the following equation

$$
\langle D_1\rangle_0
=D_{0}-h(0)\left[f- [1-p(0)]\phi_f(D^0[\mathbf{w}]/D_0)\right],
$$

where in above $D^0[\mathbf{w}]$ is the true total stake.

- We note that for $p(0)=0$ we recover the following equation

$$
\langle D_{1}\rangle_0=D_{0}-h(0)\left[f- \phi_f(D^0[\mathbf{w}]/D_0)\right]
$$

- Next, we define the normalised inferred stake $\overline{D}_{\ell+1}=\frac{ D_{\ell+1}}{D^0[\mathbf{w}]}$, and the average $\langle \overline{D}_{\ell+1}\rangle=\langle \overline{D}_{\ell+1}\rangle_\ell$, and postulate that the latter satisfies the equation

$$
\langle \overline{D}_{\ell+1}\rangle
=\langle \overline{D}_{\ell}\rangle-\tilde{h}(\ell)\left[f-q(\ell)\,\phi_f(1/\langle \overline{D}_{\ell}\rangle)\right],
$$

where $q(\ell)=1-p(\ell)$, i.e. the probability that a slot is not wasted in epoch $\ell$.

- We note that $q(\ell)\,\phi_f(1/\langle \overline{D}_{\ell}\rangle)\,T$ is the average number of slots not wasted in epoch $\ell$.
- Let us assume that $q(\ell)=q$, i.e. the probability $p(\ell)$ is the same in all epochs, and consider the equation

$$
\langle \overline{D}_{\ell+1}\rangle
=\langle \overline{D}_{\ell}\rangle-\tilde{h}(\ell)\left[f-q\, \phi_f(1/\langle \overline{D}_{\ell}\rangle)\right]
$$

- Then $\langle \overline{D}_{\ell}\rangle$ such that $f=q\, \phi_f(1/\langle \overline{D}_{\ell}\rangle)$ is the fixed point of the above equation. Solving the latter gives us

$$
\boxed{\langle \overline{D}_{\ell}\rangle =\frac{\log(1-f)}{\log(1-f/q)}}
$$

- We note that above solution exists for $q\in (f,1]$. The function $\frac{\log(1-f)}{\log(1-f/q)}$ is monotonic increasing function of $q$ on the interval $(f,1]$ and hence

$$
\boxed{\frac{\log(1-f)}{\log(1-f/q)}\leq1}.
$$

## Precision Derivation

The following is a derivation for the property described in [Precision](https://nomos-tech.notion.site/Precision-237261aa09df800285cccbb00b3aeb0a?pvs=24#239261aa09df807db39bd8d9bef73b45).

- We consider the equation

$$
D_{1}=D_{0}-h(0)\left[f-\frac{1}{T}\left\{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]-n(0)\bigg\vert\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]\right\}\right]
$$

where $n(0)$ is random variable from the binomial distribution with the parameters $p(0)$ and $\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]$.

- The variance of $D_1$ is given by

$$
\mathrm{Var}[D_{1}]=~~\frac{h^2(0)}{T^2}\mathrm{Var}\left[\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]-n(0)\bigg\vert\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]\right]
$$

- We note that

$$
\mathrm{Var}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}-n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
%
=\mathrm{Var}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]-2\,\mathrm{Cov}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]},n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]+\mathrm{Var}\left[n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]
$$

by the [identity](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df807dafbdc3dca7232e13).

- First, we consider

$$
\mathrm{Var}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]= T(1-f)f
$$

- Second, we consider

$$
\mathrm{Cov}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]},n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
%
~~~~~~~=\left\langle\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\,n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle-\left\langle\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle \left \langle n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle\\
%
=p(0)\left\langle\left\{\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\}^2\right\rangle-p(0)(Tf)^2\\=
%
p(0)\left[T(1-f)f+(Tf)^2\right]-p(0)(Tf)^2\\
%
=p(0)T(1-f)f
$$

- Hence

$$
\mathrm{Cov}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]},n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=p(0)T(1-f)f
$$

- Third, we consider the variance

$$
\mathrm{Var}\left[n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
%
=\left\langle \left\{n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\}^2\right\rangle\\
%
-\left\langle n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle^2\\
%
= (1-p(0))\,p(0) \left\langle\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle+p^2(0) \left\langle\left\{\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\}^2\right\rangle\\
%
- p^2(0)(Tf)^2\\
%
=(1-p(0))\,p(0) Tf+p^2(0) \left[T(1-f)f+(Tf)^2\right]\\
%
- p^2(0)(Tf)^2\\
%
=(1-p(0))\,p(0) Tf+p^2(0) T(1-f)f\\
%
=p(0) Tf[1-p(0)+p(0) (1-f)]
$$

- Hence

$$
\mathrm{Var}\left[n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
%
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=p(0)T(1-f)f
$$

- To obtain above, we used identities described in the [Annex](/237261aa09df800285cccbb00b3aeb0a?pvs=25#23e261aa09df80b4a438d0e3f3b5cab5) and the following results

$$
\left\langle\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle= Tf\\
%
\mathrm{Var}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]= T(1-f)f\\
%
\left\langle n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right\rangle\bigg\vert_{\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}}\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=p(0)\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}
$$

- Finally, combining all of the above we obtain the following result

$$
\mathrm{Var}\left[\small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}-n(0)\bigg\vert \small{\sum_{t=1}^T \mathbf{1}\bigg[\bigg(\sum_{i=1}^N s_i(t)\vert D_0\bigg)\geq1\bigg]}\right]\\
%
=T(1-f)f\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-2 \,p(0)T(1-f)f\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+p(0)T(1-f)f\\
%
~~~~~~~~~~~=q(0)\,T(1-f)f,
$$

where $q(0)=1-p(0)$.

- Thus we obtain

$$
\mathrm{Var}[D_{1}]=~~\frac{h^2(0)}{T}q(0)\,(1-f)f.
$$

- Based on the above, the variance of the normalised total stake $\overline{D}_1=D_1/D^0[\mathbf{w}]$ is given by

$$
\begin{align*}
\mathrm{Var}[\overline{D}_{1}] 

&=\frac{h^2(0)}{T(D^0[\mathbf{w}])^2}q(0)(1-f)f
\end{align*}.
$$

- Now, for $h(0)=h\, D_0$, where $h>0$,  we obtain

$$
\begin{align*}
\mathrm{Var}[\overline{D}_{1}] 

&=\frac{h^2\,\overline{D}^2_0}{T}q(0)(1-f)f
\end{align*}.
$$

- Furthermore, if we assume that above is true for all $\ell$, i.e.

$$
\mathrm{Var}[\overline{D}_{\ell+1}]=\frac{h^2q(\ell)}{T}\langle \overline{D}_{\ell}\rangle^2(1-f)f,
$$

where $q(\ell)=1-p(\ell)$.  For $q(\ell)=q$ and $\ell\rightarrow\infty$ we have $\langle \overline{D}_{\infty}\rangle =\frac{\log(1-f)}{\log(1-f/q)}$ and hence

$$
\boxed{\mathrm{Var}[\overline{D}_{\infty}]=\frac{h^2q}{T}\left(\frac{\log(1-f)}{\log(1-f/q)}\right)^2(1-f)f}
$$

- We note that for $q\in(f,1]$ we have $\frac{\log(1-f)}{\log(1-f/q)}\leq1$ and from the latter follows

$$
\frac{h^2q}{T}\left(\frac{\log(1-f)}{\log(1-f/q)}\right)^2(1-f)f\leq \frac{h^2}{T}(1-f)f.
$$

- Thus assuming that the [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#23b261aa09df80e89e9ae03b1b52a139) is correct, we have shown that

$$
\boxed{\mathrm{Var}[\overline{D}_{\infty}]\leq \frac{h^2}{T}(1-f)f},
$$

i.e. the variance for $q\leq1$ is bounded from above by the variance for $q=1$.

## Stability Condition Derivation

The following is a derivation for the property described in [Stability Condition](https://nomos-tech.notion.site/Stability-Condition-237261aa09df800285cccbb00b3aeb0a?pvs=24#237261aa09df80448ca0e8764617da10).

- Let us assume that $\tilde{h}(\ell)=h\langle \overline{D}_{\ell}\rangle$ and consider the [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df80b0a0def3ee23950abb) for $\langle \overline{D}_{\ell}\rangle=\frac{\log(1-f)}{\log(1-f/q)}+\epsilon(\ell)$, where $\vert\epsilon(\ell)\vert\ll1$, as follows

$$
\epsilon(\ell+1)
=\epsilon(\ell)-h\left[\frac{\log(1-f)}{\log(1-f/q)}+\epsilon(\ell)\right]\left[f-q \left[1-(1-f)^{\frac{1}{\frac{\log(1-f)}{\log(1-f/q)}+\epsilon(\ell)}}\right]\right]\\=\left[1-h \left(f -q \right) \log \! \left(\frac{q -f}{q}\right)\right]\epsilon(\ell)+O(\epsilon^2(\ell)).
$$

- The above suggests that the solution $\langle \overline{D}_{\ell}\rangle =\frac{\log(1-f)}{\log(1-f/q)}$is stable when

$$
\left\vert1-h \left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)\right\vert<1.
$$

- We note that above is equivalent to

$$
0<h \left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)  <2.
$$

- Thus the solution $\langle \overline{D}_{\ell}\rangle =\frac{\log(1-f)}{\log(1-f/q)}$ is stable for

$$
\boxed{h   <\frac{2}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)}}.
$$

- Furthermore, $\frac{2}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)}$ is a monotonic decreasing function of $q\in(0,1]$ and hence

$$
\frac{2}{\left(1 -f \right) \log \! \left(\frac{1}{1-f}\right)}   \leq\frac{2}{\left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)},
$$

i.e. the [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df80b0a0def3ee23950abb) is stable for larger values of the learning rate $h$ when $q<1$.

## Convergence Speed and Optimal Learning Rate Derivation

The following is a derivation for the properties described in [Convergence Speed and Optimal Learning Rate](https://nomos-tech.notion.site/Convergence-Speed-and-Optimal-Learning-Rate-237261aa09df800285cccbb00b3aeb0a?pvs=24#237261aa09df80c5bde0f5a22ff4d09b).

- Applying [Corollary 2.1](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80c08a50fc273f053a6e) to the [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df80b0a0def3ee23950abb) with $\tilde{h}(\ell)=h\langle \overline{D}_{\ell}\rangle$ we obtain

$$
\boxed{\vert \langle \overline{D}_{\ell}\rangle-\langle \overline{D}_{\infty}\rangle\vert\leq A\,\vert \overline{D}_0-\langle \overline{D}_{\infty}\rangle\vert\times\left\vert1-h \left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)\right\vert^\ell}
$$

where $\langle \overline{D}_{\infty}\rangle =\frac{\log(1-f)}{\log(1-f/q)}$, for some constant $A>0$.

- We note that for the learning rate  $h=h_0$, where

$$
h_0=\frac{1}{\left(q -f \right)\log \! \left(\frac{1}{1-\frac{f}{q}}\right) }
$$

the base function $\left\vert1-h \left(q -f \right) \log \! \left(\frac{1}{1-f/q}\right)\right\vert$ is exactly zero suggesting that $\vert \langle \overline{D}_{\ell}\rangle-\langle \overline{D}_{\infty}\rangle\vert=0$ for any $\ell$  at $h=h_0$.  The latter is not possible and hence the [bound](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80d6861aea3677923a9a), which assumes that the first order derivative of the [map](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df80b0a0def3ee23950abb) exists, can not be applied when $h=h_0$.

- However, for any $\vert\delta\vert>0$ and learning rate $h=h_0(1+\delta)$ the [bound](/237261aa09df800285cccbb00b3aeb0a?pvs=25#239261aa09df80d6861aea3677923a9a) can be used and the speed of convergence is $\propto   \vert\delta\vert^\ell$.
- What happens when $h=h_0$? Considering the [equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df802a9381e22a7e4b8b03) for $h=h_0$, the latter gives us

$$
\epsilon(\ell+1)
=\frac{\log \! \left(1-\frac{f}{q}\right)^{2}}{2 \log \! \left(1-f \right)}\epsilon^2(\ell)+O(\epsilon^3(\ell)).
$$

- Ignoring the higher order terms in above and solving $\epsilon(\ell+1)
=A(q,f)\epsilon^2(\ell)$, where $A(q,f)=\frac{\log \! \left(1-\frac{f}{q}\right)^{2}}{2 \log \! \left(1-f \right)}$, for some initial $\epsilon(0)$  gives us the equation

$$
\boxed{\epsilon(\ell)
=\frac{1}{A(q,f)}[A(q,f)\,\epsilon(0)]^{2^\ell}}
$$

- We note that for $\vert A(q,f)\,\epsilon(0)\vert < 1$ the  $\epsilon(\ell)\rightarrow0^{-}$ is doubly-exponential  as $\ell\rightarrow\infty$.
- Thus locally, i.e. for  $\langle \overline{D}_{\ell}\rangle=\frac{\log(1-f)}{\log(1-f/q)}+\epsilon(\ell)$ with $\vert\epsilon(\ell)\vert\ll1$, the speed of convergence to $\langle\overline{D}_{\infty}\rangle=\frac{\log(1-f)}{\log(1-f/q)}$ is doubly-exponential. The latter suggests that for $q\in(f,1]$ the learning rate

$$
\boxed{h=\frac{1}{\left(q -f \right)\log \! \left(\frac{1}{1-\frac{f}{q}}\right) }}
$$

is optimal.

- The [double exponential](/237261aa09df800285cccbb00b3aeb0a?pvs=25#249261aa09df80aea575c2d715f96803) form dominates convergence to the fixed point $\langle \overline{D}_{\infty}\rangle$ for small $\epsilon(0)= \overline{D}_{0} -\langle\overline{D}_{\infty}\rangle$ as can be seen in the figures below

![](https://nomos-tech.notion.site/image/attachment%3A6b8f4a6d-227f-4b2a-9410-e7840f9031e0%3Aoptimal1.png?table=block&id=24d261aa-09df-8000-8137-e8418c6b9a10&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=740&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A94534def-b1e2-479d-b0ef-cc8f5a854c26%3Aoptimal3.png?table=block&id=24d261aa-09df-8041-9021-e9756d250cfb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=690&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A9ab4d4c8-a4b2-4b3f-bc67-904eac18a445%3Aoptimal2.png?table=block&id=24d261aa-09df-8077-aa59-dda1d42b72b5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=690&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A838adfb8-bc6d-474e-a4b4-01191fcdce03%3Aoptimal4.png?table=block&id=24d261aa-09df-80c8-aa35-d94ac5a8fa72&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=690&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The difference between average (normalised) stake at epoch $\ell$ and its equilibrium value $\epsilon(\ell)=\langle \overline{D}_{\ell}\rangle-\frac{\log(1-f)}{\log(1-f/q)}$ plotted as a function of $\ell$ for $f=1/30$ and $q=0.85$. The solid (red) line is  the solution of the [difference equation](/237261aa09df800285cccbb00b3aeb0a?pvs=25#237261aa09df802a9381e22a7e4b8b03) using [optimal learning rate](/237261aa09df800285cccbb00b3aeb0a?pvs=25#249261aa09df8073a860d292de358d09) and the dashed (blue) line is the [double exponential](/237261aa09df800285cccbb00b3aeb0a?pvs=25#249261aa09df80aea575c2d715f96803). Here for $\log(1-f)/\log(1-f/q)\approx0.847$ and  $\epsilon(0)\in \{2\times0.847,0.847/2,0.847/10,0.847/100\}$ (top left, top right, bottom left, bottom right) the $\epsilon(1)$ is, respectively, of order $\{10^{-2} , 10^{-3}, 10^{-4} , 10^{-6}\}$.

# Annex

## Why Use Total Active Stake instead of Total Supply
