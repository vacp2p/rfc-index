# ANALYSIS-ANONYMITY

| Field | Value |
| --- | --- |
| Name | [Analysis] Anonymity |
| Slug | 208 |
| Status | raw |
| Category | Informational |
| Editor |  |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-anonymity.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-anonymity.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-09-08 |

# Introduction

In this document we consider anonymity properties of a network constructed from mix nodes. We assume that [queueing systems](https://nomos-tech.notion.site/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25) of nodes in the network delay messages. This delay is a random variable from the Geometric distribution. Furthermore, we assume that an adversary is able to observe communication links, but can not distinguish between message. Also a fraction of nodes can be corrupted by adversary but in a [static and passive manner](https://nomos-tech.notion.site/1fd261aa09df81af9348d645a3c14446?pvs=25#1fd261aa09df81bcb2cccbdd1307008b).

First, we consider a single (uncorrupted) node observed by an adversary. For this scenario we show that the temporal order of two messages which arrived at the node is preserved, with some probability, when they leave the node. We show that the probability $1/2$ is achieved for a large (average) delay per message and a small difference between the arrival times of messages. For prob. $1/2$ the temporal order of outgoing messages is unbiased and random, and hence adversary does not have advantage over the random guessing.

Second, we consider two (uncorrupted) nodes sending messages, through the path of (uncorrupted) mix nodes, to the receiver node which is corrupted by adversary. We also assume that the adversary is able to observe only communication links connecting sender nodes to the first mix node. Here in this more complicated set up, we show that the probability of preserving temporal order of messages can be $1/2$, i.e adversary does not have advantage over random guessing.

# Analysis

## Single node

- Let us assume that messages $1$ and $2$ arrived, respectively, at a node at the time $t_1^{in}$ and $t_2^{in}$, where $t_2^{in} > t_1^{in}$. Assuming that the message $\mu\in\{1,2\}$ was delayed by $r_\mu\Delta$, where $r_\mu$ is random variable from the Geometric distribution $\mathrm{P}_q(r)$, we have message $\mu$ leaving the node at time $t^{out}_\mu =  t^{in}_\mu +r_\mu\Delta$.
- We are interested in the probability $\mathrm{P}(t^{out}_2>t^{out}_1\vert t^{in}_2>t^{in}_1)$, i.e. the probability that the order of two messages arrived at the node is preserved. The latter, for the (rescaled) time-difference $\Delta_{12}=\frac{t_2^{in} - t_1^{in}}{\Delta}$, is given by

$$
\mathrm{P}(t^{out}_2>t^{out}_1\vert t^{in}_2>t^{in}_1)%=\left[1-\frac{q}{1-(1-q)^2}\right]\mathbb{1}\left[\Delta_{12}=0\right]\\
=\left[1-\frac{q(1-q)^{\Delta_{12}}}{1-(1-q)^2}\right]\mathbb{1}\left[\Delta_{12}>0\right]\mathbb{1}\left[\Delta_{12}\in\mathbb{N}\right]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~+\left[1-\frac{q(1-q)^{\lfloor\Delta_{12}\rfloor+1 }}{1-(1-q)^2}\right]\mathbb{1}\left[\Delta_{12}>0\right]\mathbb{1}\left[\Delta_{12}\in\mathbb{R}^+\setminus\mathbb{N}\right]
$$

![](https://nomos-tech.notion.site/image/attachment%3A28901364-2710-4201-9d73-3af49be89893%3AScreenshot_2025-02-28_at_16.49.53.png?table=block&id=1fd261aa-09df-8186-a247-f6697c344a03&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1010&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Two senders and a single path of mixes scenario: analysis of the FIFO attack

- A detailed description of the FIFO attack is provided in the [Appendix](https://nomos-tech.notion.site/1fd261aa09df81d2aedfef8203fa7f49?pvs=25). Here we develop analysis of the FIFO attack for mix nodes with a queuing system.
- We assume that messages are removed from the out-queue with probability $q$.
- We assume that nodes $1$ and $2$ send messages via the same path going through $k$ nodes.
- We assume that each node sends a message to the node $3$ at time $0$. A message in the node $\mu\in\{1,2\}$ is delayed by (at most) $r_\mu\Delta_\mu$, where $r_\mu$ is random variable from the Geometric distribution with parameter $q$, and it is delayed in the link to the node 3 by $d_{\mu 3}$. Hence a message from node $\mu$ arrives to node 3 at the time $t_\mu^{in}=r_\mu\Delta_\mu + d_{\mu3}$.
- A message from node $\mu\in\{1,2\}$ is delayed by $\sum_{i=3}^{k+2}r^\mu_i\Delta_i+ \sum_{i=3}^{k+1}d_{ii+1}$, where $r^\mu_i$ is random variable from the Geometric distribution with parameter $q$, while travelling through the $k$ nodes. Thus a message from node $\mu$ exits the last node $k+2$ at the time

$$
t_\mu^{out}=t_\mu^{in} +\sum_{i=3}^{k+2}r^\mu_i\Delta_i+ \sum_{i=3}^{k+1}d_{ii+1}.
$$

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F24707ce1-01a5-433c-8bfe-610a705e3b7e%2FFIFO-attack.png?table=block&id=1fd261aa-09df-81e1-9afe-d65bca0d2a68&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The events $E_{2>1}: (t_2^{out}>t_1^{out}) \land  (t_2^{in}>t_1^{in})$ and $E_{2\leq1}: (t_2^{out}\leq t_1^{out}) \land  (t_2^{in}\leq t_1^{in})$, i.e. the temporal order of two messages is preserved. These events are mutually exclusive, and hence the probability $\mathrm{P}(E_{2>1} \cup E_{2\leq1})$ the at least one of these event will happen is equal to $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$.
- The probability $\mathrm{P}(E_{2>1} \cup E_{2\leq1})=\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, i.e. the probability that temporal order of incoming and ougoing messages is preserved, is the probability of success of the FIFO attack.
- Assuming $\Delta_i=\Delta$ we have $t_\mu^{out}=t_\mu^{in} +b_\mu\Delta+ \sum_{i=3}^{k+1}d_{ii+1}$, where $b_\mu$ is random variable from the [negative binomial distribution](https://en.wikipedia.org/wiki/Negative_binomial_distribution#Waiting_time_in_a_Bernoulli_process) with parameters $k$ and $q$. Furthermore, for $d_{13}=d_1$ and $d_{23}=d_2$ the probability

$$
\mathrm{P}(E_{2>1})=\sum_{r_1\geq1} \mathrm{P}_q(r_1)\sum_{r_2\geq1} \mathrm{P}_q(r_2) \sum_{b_1\geq k} \mathrm{P}_{k,q}(b_1)\sum_{b_2\geq k} \mathrm{P}_{k,q}(b_2)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\times\mathbb{1}\left[r_2-r_1+\frac{d_2-d_1}{\Delta}>0\right]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\times\mathbb{1}\left[r_2-r_1+\frac{d_2-d_1}{\Delta}+b_2-b_1>0\right].
$$

- We note that in above the random variables $t^{in}_1=r_1\Delta+d_1$ and $t^{in}_2=r_2\Delta+d_2$, where $r_\mu$ is a random variable from the prob. distr. $\mathrm{P}_q(r_\mu)$, models the arrival times of two messages to the first mix node and the first indicator function ensures that only the event $t_2^{in}>t_1^{in}$ contributes to the probability $\mathrm{P}(E_{2>1})$. Furthermore, the random variables $t_1^{out}=t_1^{in} +b_1\Delta+ \sum_{i=3}^{k+1}d_{ii+1}$ and $t_2^{out}=t_2^{in} +b_2\Delta+ \sum_{i=3}^{k+1}d_{ii+1}$, where $b_\mu$ is a random variable from the prob. distr. $\mathrm{P}_{k,q}(b_\mu)$, model arrival times of two messages to the last (receiver) node and the second indicator function ensures that only the event $t_2^{out}>t_1^{out}$ contributes to the probability $\mathrm{P}(E_{2>1})$.
- In a similar manner, we obtain the probability

$$
\mathrm{P}(E_{2\leq1})=\sum_{r_1\geq1} \mathrm{P}_q(r_1)\sum_{r_2\geq1} \mathrm{P}_q(r_2) \sum_{b_1\geq k} \mathrm{P}_{k,q}(b_1)\sum_{b_2\geq k} \mathrm{P}_{k,q}(b_2)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\times\mathbb{1}\left[r_1-r_2+\frac{d_1-d_2}{\Delta}\geq0\right]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\times\mathbb{1}\left[r_1-r_2+\frac{d_1-d_2}{\Delta}+b_1-b_2\geq0\right].
$$

- The probability $\mathrm{P}(E_{2>1})$ can be approximated by generating a large population of independent random variables $\{r_2(i), r_1(i),b_2(i), b_1(i):i\in[\mathcal{N}]\}$ sampled from the prob. distributions $\mathrm{P}_q(r_1),  \mathrm{P}_q(r_2), \mathrm{P}_{k,q}(b_1)$ and $\mathrm{P}_{k,q}(b_2)$, and computing the (empirical) probability

$$
\mathrm{P}_{\mathcal{N}}(E_{2>1})=\frac{1}{\mathcal{N}}\sum_{i=1}^\mathcal{N} \,\mathbb{1}\left[r_2(i)-r_1(i)+\frac{d_2-d_1}{\Delta}>0\right]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\times\mathbb{1}\left[r_2(i)-r_1(i)+\frac{d_2-d_1}{\Delta}+b_2(i)-b_1(i)>0\right].
$$

- In a similar manner we define $\mathrm{P}_{\mathcal{N}}(E_{2\leq1})$.
- We expect that $\lim_{\mathcal{N}\rightarrow\infty}\mathrm{P}_{\mathcal{N}}(E_{2>1})=\mathrm{P}(E_{2>1})$ by the law of large numbers.
- The (empirical) prob. $\mathrm{P}_{\mathcal{N}}(E_{2>1} \cup E_{2\leq1})=\mathrm{P}_{\mathcal{N}}(E_{2>1})+\mathrm{P}_{\mathcal{N}}(E_{2\leq1})$ allows us to estimate the probability of success of FIFO attack $\mathrm{P}(E_{2>1} \cup E_{2\leq1})$.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F586ff293-f240-48bd-b4a7-d86a79a10cb7%2FScreenshot_2024-07-31_at_22.03.35.png?table=block&id=1fd261aa-09df-8137-a8ff-e205a7301a8d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that the above result, i.e. the probability of success of FIFO attack is a monotonic decreasing function of $k$, is very similar to the result for continuous [mixes](https://nomos-tech.notion.site/1fd261aa09df81d2aedfef8203fa7f49?pvs=25) when $\frac{d_2-d_1}{\Delta}=0$, i.e. the connections 1-3 and 2-3 have the same latency. However, when the latter is not true the prob. $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$ can be much higher as can be seen in the plot below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F90512f08-12f7-447f-8904-84126756ad2b%2FScreenshot_2024-07-31_at_23.00.46.png?table=block&id=1fd261aa-09df-8186-94b6-f21036d2e737&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Let us assume that in our [setup](https://nomos-tech.notion.site/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25) the random variables $r_1$ and $r_2$ are sampled from the Geometric distribution with parameter $q_S$, and for $i\in\{3,\ldots,k+2\}$ the random variable $r^\mu_i$ is sampled from the Geometric distribution with parameter $q_M$. Thus parameters of delays of the sender and mix nodes are different. The latter can be used to reduce the probability of success, $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, of the FIFO attack as can be seen in the plot below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0f8faf25-803d-4458-bd7f-442598040e19%2FScreenshot_2024-08-01_at_14.09.28.png?table=block&id=1fd261aa-09df-8117-8cf6-f6f0c6deb318&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that a message is delayed by the sender node by $1/q_S$ (on average) and by the mix node by $1/q_M$ (on average). We note that a similar setup is used in [continuous mixes](https://nomos-tech.notion.site/1fd261aa09df81d2aedfef8203fa7f49?pvs=25) where the ratio $\rho=q_S/q_M$ plays important role.
- The probability of success of FIFO attack , $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, is decreasing with increasing $\rho$ as can be seen in the plots below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fd870a191-cf86-4e82-a45c-6687ae003fcf%2FScreenshot_2024-08-06_at_14.35.36.png?table=block&id=1fd261aa-09df-8121-a6ef-c68e7f9807e4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F7bcbd40a-d6e6-41ff-bec8-50b40ba7ec5d%2FScreenshot_2024-08-06_at_14.21.36.png?table=block&id=1fd261aa-09df-8111-a39f-dfd950099f82&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6e19b545-01ee-4568-88ad-9864a096ed9b%2FScreenshot_2024-08-06_at_13.30.23.png?table=block&id=1fd261aa-09df-8165-819b-ef36865cebc1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F209567c8-a937-4be3-bf73-159a390a3223%2FScreenshot_2024-08-06_at_14.28.49.png?table=block&id=1fd261aa-09df-8183-9ab9-ceb6e6a4a0da&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Above plots suggest that the probability of success of FIFO attack, $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, approaches $1/2$, i.e. an adversary has no advantage over the case of random guessing, as $k\rightarrow\infty$. Furthermore, the speed of convergence (in $k$) to $1/2$ is monotonic increasing function of the ratio $\rho=q_S/q_M$.
- The probability of success of FIFO attack , $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, is increasing with increasing $\frac{d_2-d_1}{\Delta}>0$, i.e. [the sender connections 1-3 and 2-3](https://nomos-tech.notion.site/1fd261aa09df81af9348d645a3c14446?pvs=25) have different latency, as can be seen by comparing the [figure](https://nomos-tech.notion.site/1fd261aa09df81af9348d645a3c14446?pvs=25) with the plots below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fb00b5eeb-27af-495a-9dad-ff3a00201e19%2FScreenshot_2024-08-06_at_21.10.21.png?table=block&id=1fd261aa-09df-814d-bc53-d2e60d9ffcb3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa5ecfe1c-f4b8-4c4d-a72c-05b140d56316%2FScreenshot_2024-08-07_at_15.41.50.png?table=block&id=1fd261aa-09df-81f7-9b61-c01c97d74972&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Furthermore, the probability of success of FIFO attack , $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$, is not dependent on the (rescaled) difference of latencies $\frac{d_2-d_1}{\Delta}$ when $0\leq\frac{d_2-d_1}{\Delta}\leq1$ and is increasing with increasing $\frac{d_2-d_1}{\Delta}$ when $\frac{d_2-d_1}{\Delta}>1$ as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0beca538-4549-48fe-9e71-4c20d6f3f13d%2FScreenshot_2024-08-07_at_20.40.05.png?table=block&id=1fd261aa-09df-8131-81c4-fbd8c7834346&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- For $\frac{d_2-d_1}{\Delta}<0$ the probability $\mathrm{P}(E_{2>1})+\mathrm{P}(E_{2\leq1})$ behaves in a similar way as when $\frac{d_2-d_1}{\Delta}\geq 0$ as can be seen by comparing above figure with the figure below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fc8a7f493-0a73-471f-ab26-5835d226347a%2FScreenshot_2024-08-08_at_15.54.12.png?table=block&id=1fd261aa-09df-817e-b9cb-f5cf03cbd469&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- However, the $\frac{d_2-d_1}{\Delta}=-1$ and $\frac{d_2-d_1}{\Delta}=1$ cases are different as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0023ec67-7021-48c9-abf7-6572a94e9dd6%2FScreenshot_2024-08-08_at_21.06.02.png?table=block&id=1fd261aa-09df-81b3-aa59-c7cde78b2563&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Summary of FIFO attack analysis

From above analysis, it follows that the probability of success of FIFO attack is reduced by:

- Increasing the number of mix nodes $k$.
- Increasing the ratio $\rho=q_S/q_M$, where a message is delayed by the sender node by $1/q_S$ (on average) and by the mix node by $1/q_M$ (on average).
- Decreasing differences between latencies of communication links.

# Bibliography

Das, D., Diaz, C., Kiayias, A., & Zacharias, T. (2024). Are continuous stop-and-go mixnets provably secure?. Proceedings on Privacy Enhancing Technologies. [https://doi.org/10.56553/popets-2024-0136](https://doi.org/10.56553/popets-2024-0136)

# Appendix

