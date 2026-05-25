# ANALYSIS-RESILIENCE-AND-ANONYMITY

| Field | Value |
| --- | --- |
| Name | [Analysis] Resilience and Anonymity |
| Slug | 195 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-resilience-and-anonymity.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-resilience-and-anonymity.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

# Introduction

In order to guide a design of the [Blend Network](/215261aa09df81ae8857d71066a80084?pvs=25), this document summarises parameters (and results of analysis) of the [leader election process](/1fd261aa09df8181a428f52251e173c4?pvs=25), [communication on trees](/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25) and [inference of relative stake](/1fd261aa09df8181a428f52251e173c4?pvs=25). In addition to this, we considered sampling of linear trees and derived conditions under which results for communication on trees can be used. Also, we analysed the probability of linking a sender node to its message which allows us to quantify the “unlinkability of block proposer.” All these parameters (and results) were used to design (and implement) the “calculator” which can be used to quantify resilience and anonymity of communication in the Blend Network.

Finally, in this document we also analysed strategies which can be used to reduce anonymity failure and statistical properties of number of time-slots between two consecutive blocks in [Cryptarchia](/1fd261aa09df81618a76e0ac0f7f154f?pvs=25).

# Analysis

## Leader election process

The [leader election process](/1fd261aa09df8181a428f52251e173c4?pvs=25) is organised into epochs and each epoch is divided into $T$ time-slots.

![](https://nomos-tech.notion.site/image/attachment%3A29902138-cf0a-4ae7-9cc2-1ee0727f0b51%3AScreenshot_2025-05-02_at_14.23.31.png?table=block&id=1fd261aa-09df-8132-947c-f18dddfbee58&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=770&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The leader election process has the following parameters

## Sampling of Linear Trees

![](https://nomos-tech.notion.site/image/attachment%3A649de50f-7073-4483-8701-fe98e240d40c%3AScreenshot_2025-02-07_at_12.49.14.png?table=block&id=1fd261aa-09df-81aa-9eaa-f915c3998915&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1000&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The number of nodes in linear tree design is $1+KL$, where $K$ is the number of paths and $L$ is the number of nodes in each path excluding the sender node. In the linear tree design, one node is the sender node and the other $KL$ nodes are mix nodes.

We assume that in each epoch of the protocol there are $n$ sender nodes, labelled by the set $[n]$.  Each of the $n$ sender nodes sample $K \times L$ nodes from the population of $N$ nodes (labeled by the set $[N]$). The total number of nodes involved in communication is $n(1+KL)$.

We assume that each sender node samples $K\times L$ nodes, independently from other nodes, using sampling without replacement. A node among the $K\times L$ nodes sampled from $[N]$ just by chance can also appear in other $n-1$ random subsets of nodes.

The result of the sampling process described above can be represented by the following random factor-graph:

![](https://nomos-tech.notion.site/image/attachment%3Ad892cf87-779b-4c75-979f-ebe2dd150dfe%3AScreenshot_2025-02-07_at_16.18.50.png?table=block&id=1fd261aa-09df-8129-b5fb-e05cf6f66bd0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=980&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A4756879d-93b3-42bd-9462-726f709f3756%3AScreenshot_2025-02-07_at_16.32.55.png?table=block&id=1fd261aa-09df-81b6-8d35-fabff822c957&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1040&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Connectivity of a node $i\in[N]$ is the number of random edges connecting this nodes to factors labelled by the set $[n]$. The connectivity of a node $i \in [N]$ is the number of linear trees that $i$ appears in. The connectivity is a [random number from the binomial distribution](/206261aa09df80509e7dca0605db421b?pvs=25#255261aa09df80028403c5b5e08c1c1f)

$$
\mathrm{P}\left(c\vert n,\frac{KL}{N}\right)={n\choose c}\left(\frac{KL}{N}\right)^c\left(1-\frac{KL}{N}\right)^{n-c}
$$

with parameters $n$ and $\frac{KL}{N}$.

The probability that a node has more than one random connection $\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)$, i.e. the prob. that a mix node participates in more than one subset of mix nodes used in linear trees, for $n\geq2$ is given by the sum

$$
\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)=\sum_{c=2}^n\mathrm{P}\left(c\vert n,\frac{KL}{N}\right)\\~~~~~~~~~~~~~~~~~~~~~~~~=1-\sum_{c=0}^1\mathrm{P}\left(c\vert n,\frac{KL}{N}\right)\\~~~~~~~~~~~~~~~~~=1-\left(1-\frac{KL}{N}\right)^{n}\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-n\left(\frac{KL}{N}\right)\left(1-\frac{KL}{N}\right)^{n-1}\\~~~~~~~~~~~~~~~~~~~~~=1-\left(1-\frac{KL}{N}\right)^{\alpha N}\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-\alpha KL\left(1-\frac{KL}{N}\right)^{\alpha N-1}\\~~~~~~~~~~~~~~~~~~~~~~~~\leq1-\left(1-\frac{KL}{N}\right)^{\alpha N}
$$

where $\alpha=n/N$ with $n\geq2$.

We note that $\mathrm{P}\left(c>1\vert 2,\frac{KL}{N}\right)=\left(\frac{KL}{N}\right)^2$ and $\mathrm{P}\left(c>1\vert n+1,\frac{KL}{N}\right)>\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)$ for $KL<N$, i.e. the probability $\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)$ is monotonic increasing function of $n$ for $KL<N$. Furthermore, the probability $\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)$ is monotonic increasing function of $\frac{KL}{N}$, i.e. increasing the number of nodes , $KL$, in the linear tree sampled by each sender node in $[n]$ increases probability that a node in $[N]$ has more than one random connection.

The probability $\mathrm{P}\left(c>1\vert n,\frac{KL}{N}\right)$ is computed using the following parameters

## Communication on Linear Trees

We consider the following communication system

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6be5b10e-8533-41e7-a7e3-b4170dcb876e%2FScreenshot_2025-01-02_at_12.37.14.png?table=block&id=1fd261aa-09df-81f8-a9d8-f3bf17954d0a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1200&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We assume that $M_F$ nodes in the population are “faulty” (faulty node is unable to relay a message) and the probability that a node is faulty is $q_F=M_F/N$.

We assume that $M_A$ nodes in the population are “adversarial” (adversarial nodes are controlled by an adversary which can make nodes faulty, use them for traffic analysis, etc.) and the probability that a node is adversarial is $q_A=M_A/N$.

If a path contains at least one faulty node then communication failure occurred.

If a path does not have any faulty nodes then this path is functioning.

If all $K$ paths have a communication failure then broadcast failure occurred.

The probability of broadcast failure is given by

$$
\mathrm{P}_b(K,L,q_F)=\left[1-(1-q_F)^L\right]^{K}
$$

We note that $q_F(C)=\frac{C-2}{C-1}$ is the [site percolation threshold of random regular graph (RRG) with connectivity C](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df811eb66afc94559fa6c4), i.e. for $q_F>q_F(C)$ the RRG becomes disconnected with high probability as $N\rightarrow\infty$. The latter suggests if our model of the network is RRG then for the fraction of faulty nodes $q_F > q_F(C)$ the communication is not possible with high probability in $N\rightarrow\infty$.

If all nodes in a communication path are non-faulty then this is a functioning communication path.

If there is at least one functioning communication paths where all nodes are adversarial, then adversary has opportunity to cause anonymity failure.

The probability of anonymity failure is given by

$$
\mathrm{P}_a(K,L,q_F,q_A)=1-\left[1-[(1-q_F)\, q_A]^L\right]^{K}
$$

If there is at least one adversarial node in each functioning communication paths then the adversary has an opportunity to cause broadcast failure. The probability of adversarial broadcast failure is given by

$$
\mathrm{P}_{ab}(K,L,q_F,q_A)=\left[1-[(1- q_F)(1- q_A)]^L\right]^K-\left[1-(1- q_F)^L\right]^{K}
$$

The probabilities $\mathrm{P}_a$, $\mathrm{P}_b$ and $\mathrm{P}_{ab}$ are computed the following parameters

The code which computes above probabilities is given below

```
def Prob_b(K, L, qF):
"""
 Compute the probability of broadcast failure.
 Formula: (1 - (1 - qF)^L)^K
 """
return (1 - (1 - qF) ** L) ** K

def Prob_ab(K, L, qF, qA):
"""
 Compute the probability of adversarial broadcast failure.
 Formula: (1 - ((1 - qF)^L * (1 - qA)^L))^K - (1 - (1 - qF)^L)^K
 """
 term1 = (1 - qF) ** L
 term2 = (1 - qA) ** L
 return (1 - (term1 * term2)) ** K - (1 - term1) ** K

def Prob_a(K, L, qF, qA):
"""
 Compute the probability of anonymity failure.
 Formula: 1 - (1 - ((1 - qF)^L * qA^L))^K
 """
 term1 = (1 - qF) ** L
 term2 = qA ** L
 return 1 - (1 - (term1 * term2)) ** K
```

## Inference of relative stake

The [adversary observes the leader election process](/1fd261aa09df8181a428f52251e173c4?pvs=25) of a node with the relative stake $\alpha$.

![](https://nomos-tech.notion.site/image/attachment%3A4688bad9-2877-4408-9416-bcdee0bc9ef8%3AScreenshot_2025-02-13_at_08.26.49.png?table=block&id=1fd261aa-09df-81f1-9deb-f03fe24a8efa&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In $T$ time-slots, the adversary is able to observe fraction $v$ of wins in $m$ observations. The probability of observing the election outcome of a node is $q$. For $m\geq1$ adversary uses the “naive” estimator $\hat{\alpha}=\frac{\log\left(1-v\right)}{\log(1-f)}$ of the true relative stake $\alpha$. For large $T$, the probability that $\alpha(1-\gamma)\leq\hat{\alpha}\leq\alpha(1+\gamma)$ is [given by](/1fd261aa09df8181a428f52251e173c4?pvs=25#255261aa09df802d808dc47be2fdbe05)

$$
\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,T\right)=\frac{2 \,\mathrm{erf}\! \left(\frac{ \epsilon}{\sqrt{2\sigma^2(\alpha,q)}}\right)}{\mathrm{erf}\! \left(\frac{\phi(\alpha) }{ \sqrt{2\sigma^2(\alpha,q)}}\right)+\mathrm{erf}\! \left(\frac{ 1-\phi(\alpha)}{ \sqrt{2\sigma^2(\alpha,q)}}\right)}
$$

In the above, $\phi(\alpha)=1-(1-f)^\alpha$ is the lottery function with parameter $f$, $\epsilon=\gamma\alpha\frac{\mathrm{d}}{\mathrm{d}\alpha}\phi(\alpha)$ and $\sigma^2(\alpha ,q)=\phi(\alpha)[1-\phi(\alpha)]/T q$, where $q$ is the fraction of observed time-slots such that $Tq$ slots are observed on average.

The probability $\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,T\right)$ can be interpreted as adversarial “confidence” and the parameter $\gamma$ as “accuracy”. An example of the above probability is given below

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F694d7ce0-ede2-44dc-ac13-5ad0bb78b47d%2Fadver_conf.png?table=block&id=1fd261aa-09df-813c-9e95-d6a39857faae&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=590&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability $\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,T\right)$, i.e. adversarial “confidence,” is computed using the following parameters:

The code which computes adversarial “confidence” is given below

```
def phi(alpha, f):
return 1 - (1 - f) ** alpha

def dphi(alpha, f):
return -((1 - f) ** alpha) * log(1 - f)
def Prob2(alpha, epsilon, T, q):
	sqrt2 = sqrt(2.0)
 phi_alpha = phi(alpha, f)
# Denominator term
 denominator = (
 								erf((phi_alpha - 1) * sqrt2 / (2 * sqrt(phi_alpha * (1 - phi_alpha) / (T * q))))
- erf(phi_alpha * sqrt2 / (2 * sqrt(phi_alpha * (1 - phi_alpha) / (T * q))))
)
# Numerator term
 numerator = -2.0 * erf(
 							sqrt2 * epsilon / (2 * sqrt(phi_alpha * (1 - phi_alpha) / (T * q)))
)
# Final result
return numerator / denominator
 
# Compute epsilon = dphi(alpha) * alpha * gamma
epsilon = dphi(alpha, f) * alpha * gamma

# Compute Prob2
Prob2_result = Prob2(alpha, epsilon, T, q)
```

The [probability](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8130bc9cc00ece070d4a) can also compute the (minimum) number of time-slots, $t$, such that $\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,t\right)\geq\delta$, for some $\delta\in (0,1)$. Here $t$ is the time needed by an adversary to achieve “confidence” greater than $\delta$. The code which computes $t$ is given below

```
T0 = T # One epoch
T1 = 730 * T # 10 years
dT = 10**3 # Step size
if Prob2_t < delta:
# Increase T until Prob2_result >= delta
	t = T0
 while t <= T1 and Prob2_t < delta:
	 Prob2_t = Prob2(alpha, epsilon, t, result3)
 t += dT
 
else:
# Decrease T until Prob2_result <= delta
 t = T
 while t >= 100 and Prob2_t > delta:
	 Prob2_t = Prob2(alpha, epsilon, t, result3)
 t -= dT 
```

### Adversarial Confidence as a Measure of Statistical “Noise”

The probability $\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,T\right)$, where $q\,T$ is the (average) number of time-slots observed by adversary in one epoch, can be seen as a measure of the magnitude of “noise” which prevents accurate measurements of the relative stake $\alpha$. One source of this noise is the actual (stochastic) leader election process and the other is the sampling (or “observation”), controlled by parameter $q$, of the latter by an adversary. For $q=1$, i.e. all time-slots are observed, and leader election process is the only source of noise. In this regime, for a given accuracy ($\gamma= 0.1$), the relative stake can be inferred with high confidence as can be seen in the figure below

![](https://nomos-tech.notion.site/image/attachment%3A17d8ecd8-2432-48e8-afff-2ca5ca36c6ae%3AScreenshot_2025-02-26_at_18.55.44.png?table=block&id=1fd261aa-09df-81c5-ad2c-e9d3fc3596b9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For $q<1$, sampling becomes an additional source of noise interfering with measurements done by adversary. Here, for a given accuracy, the confidence deteriorates as $q\rightarrow0$ (see figures below).

![](https://nomos-tech.notion.site/image/attachment%3Af9d351ea-88c6-4042-b160-4e0b3be1b2e1%3AScreenshot_2025-02-27_at_08.42.58.png?table=block&id=1fd261aa-09df-8190-8b30-f301042f7a25&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ac3652184-0c73-41f7-a0b5-9c8acc432944%3AScreenshot_2025-02-26_at_19.02.18.png?table=block&id=1fd261aa-09df-81c3-8aff-c0f8a172694f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A7f99d8cc-7ac6-46b0-b2c6-a0464190d22f%3AScreenshot_2025-02-26_at_19.09.23.png?table=block&id=1fd261aa-09df-81a6-8a72-edc73562fe5d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Abaf50abc-7e9e-464c-959d-971dee6f241b%3AScreenshot_2025-02-26_at_19.17.01.png?table=block&id=1fd261aa-09df-81b1-b947-ed8642714222&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Let us define a function which compares properties of inference for $q=1$ and $q\in(0,1)$ as follows

$$
\log\left(\frac{\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, T\right)}{\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\,\vert\, q\,T\right)}\right)
$$

We note that above is $0$ when $q=1$, i.e. no sampling noise, and is growing when $q\rightarrow0$ (see figure below). Hence, above can be seen as “amplitude” of the sampling noise.

![](https://nomos-tech.notion.site/image/attachment%3A5d56e8a2-b792-4379-af82-bc879c5c707c%3AScreenshot_2025-03-28_at_17.27.21.png?table=block&id=1fd261aa-09df-815c-85c7-d0813b45f345&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1000&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## The Unlinkability of Block Proposers

We assume that node $\mathrm{S}$ wins the [election](/1fd261aa09df8181a428f52251e173c4?pvs=25) and broadcasts message $\mathrm{m}$ to the network using [linear trees](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8126abdcf963ec121066). We assume that in the network the sender node $\mathrm{S}$ has $C$ neighbouring nodes. Message $\mathrm{m}$ is first sent to the neighbouring nodes then, via the latter, to the rest of the network. A node in the neighbourhood $\partial\mathrm{S}$, where $\vert\partial\mathrm{S}\vert=C$, is adversarial with the prob. $q_A$. The prob. that at least one node in $\partial\mathrm{S}$ is adversarial is $1-(1-q_A)^C$.

If $\mathrm{S}$ has at least one adversarial neighbour and [anonymity failure](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81d18726e5b63a96b432) occurred then the message $\mathrm{m}$ can linked to the sender node $\mathrm{S}$. We note that just occurrence of the [anonymity failure](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81d18726e5b63a96b432) alone is not sufficient to link $\mathrm{m}$ to $\mathrm{S}$ and at least one compromised node is also needed in $\partial\mathrm{S}$. Furthermore, an adversary may need not one but at least $n_A$ compromised nodes in $\partial\mathrm{S}$. The probability of the latter is given by the binomial

$$
\mathrm{P}(n\geq n_A\vert C,q_A)=\sum_{n=n_A}^C{C\choose n}[1-q_A]^{C-n}q_A^n
$$

We note that the case one adversarial node in $\partial\mathrm{S}$ is recovered by setting $n_A=1$ in the above. The probability of above event, given that $\mathrm{S}$ won the election, is the product of two probabilities

$$
\mathrm{P}(n\geq n_A\vert C,q_A)\,\mathrm{P}_a(K,L,0,q_A)
$$

We note that in above we assumed that $q_F=0$, i.e. there are no faulty nodes in the network. The probability above is an upper bound for a scenario with faulty nodes. Since $\mathrm{P}(n\geq n_A\vert C,q_A)<1$ for $n_A\geq1$, the prob. of anonymity failure $\mathrm{P}_a(K,L,0,q_A)$ is an upper bound on the above prob. If node $\mathrm{S}$ has (relative) stake $\alpha$ then the prob. of node $\mathrm{S}$ winning is $\phi(\alpha)$, where $\phi(\alpha)$ is the[ lottery function](/1fd261aa09df8181a428f52251e173c4?pvs=25). Hence, the prob. that the message $\mathrm{m}$, sent by the winning node $\mathrm{S}$, can be linked to $\mathrm{S}$ is given by

$$
\phi(\alpha)\, \mathrm{P}(n\geq n_A\vert C,q_A)\,\mathrm{P}_a(K,L,0,q_A)
$$

The prob. that message $\mathrm{m}$ can not be linked to the sender $\mathrm{S}$ is

$$
1-\phi(\alpha)\, \mathrm{P}(n\geq n_A\vert C,q_A)\,\mathrm{P}_a(K,L,0,q_A)
$$

Hence the prob. that any message sent by node $\mathrm{S}$ can be linked to $\mathrm{S}$ in $t$ elections is given by

$$
1-\left[1-\phi(\alpha)\, \mathrm{P}(n\geq n_A\vert C,q_A)\,\mathrm{P}_a(K,L,0,q_A)\right]^t
$$

For the above prob. to be greater than some threshold $\theta$ (for example $\theta=1/2$) the number of elections $t$ has to satisfy the following inequality

$$
t>\left\lceil\frac{\log(1-\theta)}{\log(1-\phi(\alpha)\, \mathrm{P}(n\geq n_A\vert C,q_A)\,\mathrm{P}_a(K,L,0,q_A))}\right\rceil
$$

The minimum $t$ for which above inequality holds $t(\theta)$, which is the RHS of the above, is computed using the following parameters

The code which computes $t(\theta)$ is given below

```
def phi(alpha, f):
return 1 - (1 - f) ** alpha

def calculate_t(qA, L, K, alpha, f, C, nA, theta):
#compute prob. Pa
 x = 1 - pow(qA, L)
 Pa = (1 - pow(x, K))
#compute prob. Pan
 p = 1 - qA
 Pan = 0
for n in range(nA, C + 1):
 Pan += comb(C, n) * (p ** (C - n)) * (qA ** n)
#compute prod. of prob.
 Prob = Pan * Pa
 
 #compute t
 numerator = log(1 - theta)
 denominator = log(1 - phi(alpha, f) * Prob)
 t = ceil(numerator / denominator)
return t
```

## Design of the “Calculator”

Here we combine the results for leader election process, sampling of linear trees, broadcasting on linear trees and inference of relative stake to design a calculator which takes parameters of the latter and computes properties of a node related to the resilience and anonymity of communication. The calculator has the following modules:

The dependencies between modules can be represented as the following diagram

Using above diagram of dependencies a first and later versions of the calculator were implemented as an online app. The input and output of the most recent version is presented below. The app is available in the [repository.](https://github.com/AMozeika/Calculator)

![](https://nomos-tech.notion.site/image/attachment%3Aa2d264a0-5a7a-4107-94d7-0db5e5f1e373%3AScreenshot_2025-03-25_at_21.00.02.png?table=block&id=1fd261aa-09df-817b-9867-ff1d5eda6d4d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Strategies to Reduce Anonymity Failure

Let us assume that a node won at time $t$ of the [election process](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8139be03eb565f1e419d) and it broadcasts a message to the network using [linear trees](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8126abdcf963ec121066). Furthermore, assume that the neighbourhood of this node has at least one adversarial node. Conditioned that these two assumptions are true, the probability of anonymity failure is given by

$$
\mathrm{P}_a(K,L,q_F,q_A)=1-\left[1-(1-q_F)^L\, q_A^L\right]^{K}
$$

Above corresponds to a scenario when a node at time $t$ sends a message through $K$ paths of length $L$ (see [figure](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81aa9eaaf915c3998915)) constructed from nodes sampled (with replacement) from the set of network nodes $[N]$. Here $q_F$ and $q_A$ is, respectively, the fraction of faulty and adversarial nodes in the network.

For $K=1$, i.e. a message is sent through one path, the probability of anonymity failure is given by

$$
\mathrm{P}_a(1,L,q_F,q_A)=1-\left[1-[(1-q_F)\, q_A]^L\right]\\~~~~~~~~=(1-q_F)^L\, q_A^L
$$

We note that in above $(1-q_F)^L$ is the prob. that path is functional and $q_A^L$ is the prob. that every single node on this path is adversarial. Hence $1-(1-q_F)^L\, q_A^L$ is the prob. that either the path is not functional or at least one node in the path is not adversarial.

Now let us assume that node sends the same message (or different messages) through different paths of length $L$ at times $t_1<t_2<\cdots<t_K$ (see figure below)

![](https://nomos-tech.notion.site/image/attachment%3A8302fc7c-3058-4960-8722-e20c90e26982%3AScreenshot_2025-04-01_at_18.24.05.png?table=block&id=1fd261aa-09df-8199-b602-e80244ff5dc0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=900&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

After sending the first message at time $t_1$ the prob. of anonymity failure is $\mathrm{P}_a(1,L,q_F,q_A)=(1-q_F)^L\, q_A^L$, after sending the second message at time $t_2$ the prob. of anonymity failure is $\mathrm{P}_a(2,L,q_F,q_A)=1-\left[1-[(1-q_F)\, q_A]^L\right]^2$, etc. Thus after sending the last message at time $t_K$ the prob. anonymity failure is $\mathrm{P}_a(K,L,q_F,q_A)$, i.e. the same as [sending a message through ](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81aa9eaaf915c3998915)$K$ paths simultaneously. We note that for fixed $L$ the prob. $\mathrm{P}_a(K,L,q_F,q_A)$ is [monotonic increasing function](/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25) of $K$ and hence $\mathrm{P}_a(n_{m},L,q_F,q_A)$ is monotonic increasing function of the number of sent messages $n_{m}\in\{1,\ldots,K\}$ as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3Ab2f25c07-4351-47d0-9b5f-0f2b3fd7bc80%3AScreenshot_2025-04-02_at_15.07.44.png?table=block&id=1fd261aa-09df-8126-8b44-d03a7c40471c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1040&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Furthermore, the probability that no anonymity failure occurred after sending $n_m$ messages is given by

$$
1-\mathrm{P}_a(n_m,L,q_F,q_A)=\left[1-(1-q_F)^L\, q_A^L\right]^{n_m}
$$

From above, it follows that for $n_m\leq K$ we have

$$
\frac{1-\mathrm{P}_a(n_m,L,q_F,q_A)}{1-\mathrm{P}_a(K,L,q_F,q_A)}=\frac{1}{\left[1-(1-q_F)^L\, q_A^L\right]^{K-n_m}}\geq1
$$

Hence the probability that no anonymity failure occurred is much larger if the number of messages sent $n_m$ is much less than $K$. Equivalently, the probability of anonymity failure is much smaller if the number of messages sent $n_m$ is much less than $K$.

We now consider the prob. of broadcast failure

$$
\mathrm{P}_b(K,L,q_F)=\left[1-(1-q_F)^L\right]^{K}
$$

which is a [monotonic decreasing function](/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25) of $K$ when $L$ is fixed. Hence $\mathrm{P}_b(n_{m},L,q_F)$ is monotonic decreasing function of the number of sent messages $n_{m}\in\{1,\ldots,K\}$ as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3A257fe07a-6ae4-419a-870b-313751b1c4e2%3AScreenshot_2025-04-02_at_15.41.16.png?table=block&id=1fd261aa-09df-81c5-bb23-e9518270b1b0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1000&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that the [probability of adversarial broadcast-failure](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81f7901bed38662b9882) behaves in a similar way as can be seen in the figure below

![](https://nomos-tech.notion.site/image/attachment%3A298bbdcb-04e9-4e22-a6d1-f9116a23a543%3AScreenshot_2025-04-02_at_15.48.32.png?table=block&id=1fd261aa-09df-817d-9a8c-eb0486d2873d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1010&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The number of nodes used for broadcasting of $n_m$ messages is $n_mL$, i.e. grows linearly with the number of messages $n_m$.

![](https://nomos-tech.notion.site/image/attachment%3A6fde278c-9e77-49e4-aadc-2c692ce21ed0%3AScreenshot_2025-04-02_at_15.52.04.png?table=block&id=1fd261aa-09df-8103-80d1-d641677cc17e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1010&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that

$$
\left[\prod_{i=1}^{t-1}\mathrm{P}_b(i,L,q_F)\right]\left[1-\mathrm{P}_b(t,L,q_F)\right]
$$

is the probability that the first occurrence of a successful broadcast requires sending $t$ messages. We note that above is generalisation of the [Geometric prob. distribution](https://en.wikipedia.org/wiki/Geometric_distribution).

![](https://nomos-tech.notion.site/image/attachment%3Ad9518838-0a1c-4690-9ff8-47104da89aef%3AScreenshot_2025-04-03_at_18.56.20.png?table=block&id=1fd261aa-09df-8198-a8ff-e319ff4e7b0c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=990&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

From the above, it follows that

$$
1-\sum_{t=1}^n\left[\prod_{i=1}^{t-1}\mathrm{P}_b(i,L,q_F)\right]\left[1-\mathrm{P}_b(t,L,q_F)\right]
$$

is the prob. that the first occurrence of a successful broadcast requires sending more than $n$ messages.

![](https://nomos-tech.notion.site/image/attachment%3A1405ba3a-093c-4517-91ef-372c411f6141%3AScreenshot_2025-04-03_at_18.57.44.png?table=block&id=1fd261aa-09df-81ef-baa7-d67e73eb5bea&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=980&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

In a similar manner, we obtain the probability

$$
\left[\prod_{i=1}^{t-1}\left[1-\mathrm{P}_a(i,L,q_F,q_A)\right]\right]\mathrm{P}_a(t,L,q_F,q_A)
$$

that the first occurrence of anonymity failure requires sending $t$ messages.

![](https://nomos-tech.notion.site/image/attachment%3A582d11e9-c134-427b-b64b-906c3a6072ae%3AScreenshot_2025-04-04_at_15.56.26.png?table=block&id=1fd261aa-09df-8144-993d-d4d618b78845&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=970&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

From the above, it follows that

$$
\sum_{t=1}^{n-1}\left[\prod_{i=1}^{t-1}\left[1-\mathrm{P}_a(i,L,q_F,q_A)\right]\right]\mathrm{P}_a(t,L,q_F,q_A)
$$

is the prob. that the first occurrence of anonymity failure requires sending less than $n$ messages.

![](https://nomos-tech.notion.site/image/attachment%3A7d26b0b3-c45a-4f15-8d66-5dda44de6e0b%3AScreenshot_2025-04-04_at_16.10.18.png?table=block&id=1fd261aa-09df-810b-b79d-d351f5519165&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=990&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A5f480cac-2c2a-46c4-8b99-46ef5d62c07f%3AScreenshot_2025-04-04_at_16.15.16.png?table=block&id=1fd261aa-09df-81f1-ada1-c48c09e799e7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1000&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Analysis of Latency

We consider a network $\mathcal{N}$ constructed from $N=\vert\mathcal{N} \vert$ nodes. We assume that a message sent from node $0\in \mathcal{N}$, via $L$ nodes of $\mathcal{N}$, to the network $\mathcal{N}$using the broadcast method of communication. The message is delayed at the node $0$ by the $\Delta_0$ amount of time, at the node $1$ by the $\Delta_1$ amount of time, etc. Furthermore, a message traveling between the nodes $i$ and $i+1$ is delayed by $d_{i\,i+1}$ due to the latency of broadcast on $\mathcal{N}$ used for communication.

![](https://nomos-tech.notion.site/image/attachment%3Aa169e038-ac36-4237-849a-58042f1762e0%3AScreenshot_2025-04-09_at_18.10.23.png?table=block&id=1fd261aa-09df-8177-83d3-eb0b07a5c71b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Assuming that the message was successfully broadcasted by the last node $L$ to the network $\mathcal{N}$, the total delay is given by $\sum_{i=0}^L\left[\Delta_i+ d_{i\,i+1}\right]$. We note that for $\Delta=\max_{i}\Delta_i$ and $d=\max_{i}d_{i\,i+1}$ we have a simple upper bound

$$
\sum_{i=0}^L\left[\Delta_i+ d_{i\,i+1}\right]\leq (L+1)[\Delta + d]
$$

We note that we have equality in the above when $\Delta=\Delta_i$ and $d=d_{i\,i+1}$, i.e. all delays are the same.

Assuming that sender node monitors, via observation of broadcasts on $\mathcal{N}$, how a message is propagated along the [path](/1fd261aa09df814a9967efc9aa479eba?pvs=25), the sender node sends first messages and if this message is not broadcasted to $\mathcal{N}$ after some time, for example after time $\sum_{i=0}^1\left[\Delta_{i}(1)+ d_{i\,i+1}(1)\right]$, it will send a second message and if this message is not broadcasted it send a third message, etc. We note that a worst case scenario of above strategy is when the 1st message “travels” to the last node $L$, but is not broadcasted to the network $\mathcal{N}$. Then nodes send a 2nd message and again this message is not broadcasted by the last node, etc. Assuming that the $K$-th message is broadcasted by the last node to $\mathcal{N}$, gives us that the total delay in the [sequential scenario](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8199b602e80244ff5dc0) is at most

$$
\sum_{\ell=1}^K\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]
$$

if the delay on each $\ell$-th path, i.e. the value of $\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]$, is known exactly.

Furthermore, we have the following inequality

$$
\sum_{\ell=1}^K\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]\leq K(L+1)[\Delta + d]
$$

where $\Delta=\max_{i,\ell}\Delta_i(\ell)$ and $d=\max_{i,\ell}d_{i\,i+1}(\ell)$. We can assume that $\Delta=10s$ and $d=5s$.

We note that when $K$ messages are sent [simultaneously](/1fd261aa09df814a9967efc9aa479eba?pvs=25) and if at least one of them is successfully broadcasted by a last node to the network $\mathcal{N}$, then the total delay is at most

$$
\max_{\ell\in[K]}\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]
$$

if the delay on each $\ell$-th path, i.e. the value of $\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]$, is known exactly. Furthermore, for $\Delta=\max_{i,\ell}\Delta_i(\ell)$ and $d=\max_{i,\ell}d_{i\,i+1}(\ell)$ we have the following inequality

$$
\max_{\ell\in[K]}\sum_{i=0}^L\left[\Delta_{i}(\ell)+ d_{i\,i+1}(\ell)\right]\leq (L+1)[\Delta + d]
$$

From the above, it follows that in the worst case the latency of [sequential](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8199b602e80244ff5dc0) communication is $K$ times the latency of [synchronous](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81f8a9d8f3bf17954d0a) communication.

Let us assume that $\Delta=10s$, $d=5s$ and sender node is not delaying messages. The latter gives us the upper bound $\Delta L+ d(L+1)= 15\times L+5\,s$ on latency in [synchronous](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df81aa9eaaf915c3998915) communication and $K[\Delta L+ d(L+1)]= K[15\times L+5]\,s$ for the upper bound on latency of [sequential](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8199b602e80244ff5dc0) communication.

## The Number of Time-Slots Between Two Consecutive Blocks

In the [leader election process](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8139be03eb565f1e419d) the probability of winning a slot is $f=1/30$ and the number of time-slots per epoch is $T=648000$. Assuming that winning a slots results in generation of a valid block, the number of time-slots between two consecutive blocks, $n_0$, follow the [geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution)

$$
\mathrm{P}(n_0)=(1-f)^{n_0}f
$$

where $n_0\in\mathbb{N}\cup\{0\}$. Follows from above that the average of $n_0$ is $\langle n_0\rangle=(1-f)/f\approx0.967/0.033=29$, i.e. on average we expected to see a next block after $29$ time-slots. The probability that $n_0$ is greater than the average $\langle n_0\rangle$ is given by

$$
\mathrm{P}(n_0> \langle n_0\rangle)=(1-f)^{\langle n_0\rangle+1}
$$

For $f=1/30$, the above gives us $\mathrm{P}(n_0> 29)=(1-1/30)^{30}\approx0.362$. Furthermore, the maximum of $n_0$ observed in $T$ time-slots (approximately) follows the [distribution](/1fd261aa09df814a9967efc9aa479eba?pvs=25#1fd261aa09df8199a984c7f1688f60da)

$$
\mathrm{P}\left(x\right)=\int_{-\infty}^{\infty} \mathrm{e}^{-t-\mathrm{e}^{-t}}\delta\left(x-\frac{t+\log(T(1-p))}{\log(1/p)}\right)\mathrm{d} t\\~~~~~~~~~~~=\vert\log(p)\vert\, \mathrm{e}^{-\left[x\log(p)+\log(T(1-p))\right]-\mathrm{e}^{-\left[x\log(p)+\log(T(1-p))\right]}}
$$

where $p=1-f$.

![](https://nomos-tech.notion.site/image/attachment%3Ae5ba9f8f-3deb-4248-9b13-005f4244ec26%3AScreenshot_2025-05-21_at_17.33.30.png?table=block&id=1fd261aa-09df-81c2-9b70-df6e52ab9176&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1000&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that the mode of $\mathrm{P}\left(x\right)$ is at $x=\frac{\log(T(1-p))}{\log(1/p)}$ and hence the typical value of the maximum of $n_0$ observed in $T=648000$ time-slots for $f=1/30$ is $\approx 295$. The prob. that the maximum of $n_0$ observed in $T=648000$ time-slots for $f=1/30$ is greater than $295$ can be computed with high accuracy from simulations and is $\approx 0.62$ as suggested by the simulation data tabulated below.

The histogram of the maximum of $n_0$ obtained in one such simulation is presented below

![](https://nomos-tech.notion.site/image/attachment%3A50d3989f-c2aa-4080-8b0d-b1581e254e5b%3AScreenshot_2025-05-22_at_08.28.07.png?table=block&id=1fd261aa-09df-8106-8b30-df0034a2e6d9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Bibliography

Svante Janson. (2009). On percolation in random graphs with given vertex degrees. Electron. J. Probab. 14: 86 - 118. [https://doi.org/10.1214/EJP.v14-603](https://doi.org/10.1214/EJP.v14-603)

Gordon, L., Schilling, M. F. and Waterman, M. S. (1986). An extreme value theory for long head runs.  Probability Theory and Related Fields  72: 279-287. [https://doi.org/10.1007/BF00699107](https://doi.org/10.1007/BF00699107)

