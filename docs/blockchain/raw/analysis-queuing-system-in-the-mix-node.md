# ANALYSIS-QUEUING-SYSTEM-IN-THE-MIX-NODE

| Field | Value |
| --- | --- |
| Name | [Analysis] Queuing System in the Mix Node |
| Slug | 194 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-queuing-system-in-the-mix-node.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-queuing-system-in-the-mix-node.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-09-08 |

# Introduction

We consider queuing system of a mix node where coin-flipping algorithm is used to remove messages. We show that the amount of time message spends in a queue is governed by the [Geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution). The consequence of the latter is [memorylessness](https://en.wikipedia.org/wiki/Memorylessness) property, i.e. the amount of time a message will spend in the queue is independent on how long it is already been in the queue, [which is important for anonymity of communication](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25#1fd261aa09df8172b2cbe6d970282cb0).

# Overview

This document analyses how a mix node—a privacy tool that hides message origins—manages delays using randomised queues. Key points:

1. Queue Design:
    - Each connection has an in-queue (FIFO order) and out-queue with randomised removal.
    - A "Relayer" forwards real messages to all out-queues except the sender’s, dropping dummies.
1. Randomised Delays:
    - Messages in the out-queue are shuffled, then each has probability $q$ (e.g., 50%) of being sent per round.
    - This follows a Geometric distribution: ~50% sent in Round 1, ~25% in Round 2, etc.
1. Anonymity Guarantee:
    - The system’s memorylessness ensures delays are independent of past wait times, preventing timing attacks.

Methods used:

- Geometric distribution models rounds until a message is sent.
- Simulations (e.g., sending 10,000 messages) validate the theory.
- Binomial distribution tracks messages removed per round.

Why It Matters:

- Balances privacy (unpredictable delays) with efficiency (tunable via $q$).
- Foundations for Tor-like systems and anonymous networks.

# Analysis

## Assumptions

We assume that node $i$ has $c_i$ connections to other nodes, labelled by the set $[c_i]$, and two queues (”in-queue” and “out-queue”), associated with each connection. Messages which arrive via the connection $\ell\in [c_i]$ are stored in the in-queue $Q_\ell^{in}$. Messages which are sent via the connection $\ell\in [c_i]$ are stored in the out-queue $Q_\ell^{out}$. Messages are added to the back and removed from the front of $Q_\ell^{in}$, i.e. the latter is [the FIFO queue](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics))

![](https://nomos-tech.notion.site/image/attachment%3A6e043ff2-4443-447f-bae6-3f43a78d0e3f%3AScreenshot_2025-05-21_at_12.22.42.png?table=block&id=1fd261aa-09df-81eb-b8b4-fec1e7ae732f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that FIFO queue preserves temporal order of arriving messages.

The Relayer removes a message from the front of $Q_\ell^{in}$ and i) drops it if the message is a dummy or ii) adds the message to the back of all $Q_k^{out}$, where $k\in[c_i]\setminus j$, queues (i.e. all out-queues but $j$) if message is “real”.

![](https://nomos-tech.notion.site/image/attachment%3Adc02fe63-4092-4f35-97aa-c3160ff2c076%3AScreenshot_2025-05-20_at_15.58.37.png?table=block&id=1fd261aa-09df-8105-9d2f-e59104962ef6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Above operation is repeated by Relayer for all $j\in [c_i]$

![](https://nomos-tech.notion.site/image/attachment%3A5665675c-f365-4b73-81df-84a4685846b4%3AScreenshot_2025-05-20_at_15.59.57.png?table=block&id=1fd261aa-09df-819d-818e-ce706434487d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Analysis of a single out-queue

Let us consider, without loss of generality, the out-queue $Q_1^{out}$ and assume that the front of $Q_1^{out}$ holds $n$ messages which arrived at times $t_1\leq t_2\leq\cdots\leq t_n$.  Furthermore, we assume that messages which arrive at times after time $t_n$, $t_i > t_n$, are labelled by $i\in \mathbb{N}\setminus [n]$, i.e. we assume that messages are labelled by the set $\mathbb{N}$.

The above $n$ messages are shuffled, which is equivalent to random permutation, then each message is removed from the queue with probability $q$ and sent.  In above removal of a message which arrived at time $t_i$ can be modeled by the binary variable $x_i\in\{0,1\}$, where $0/1$ corresponds to not-removed/removed.  We note that number of removed messages in this process is the random variable from binomial distribution with parameters $n$ and $q$. Hence above process on average (and (approx.) typically) removes $q\, n$ messages from the queue $Q_1^{out}$. The above algorithm can be seen as a variant of the pool mix (see the [article](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25#1fd261aa09df81609a91c4e9127d06ab))

![](https://nomos-tech.notion.site/image/attachment%3Ab32c6736-933e-4137-ac23-e8a70926b742%3AScreenshot_2025-02-17_at_11.54.08.png?table=block&id=1fd261aa-09df-8168-b98c-d281f452fe13&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

However, in the pool mix model a fixed number (of randomly selected messages) is removed and sent, but in the algorithm this number is random.

Let us assume that messages are removed from the front of the out-queue $Q_1^{out}$ in rounds (or epochs) and if a message which arrived at time $t_i$, where $i\in \mathbb{N}$, was removed at round $r$ then $x_i(r)=1$ and $x_i(k)=0$ for $1\leq k<r$. We assume that after each round of removal the removed messages are replaced with new messages and the front $n$ messages in the queue are shuffled before the next round of removal.  We assume that round $r\in\mathbb{N}$ follows the [Geometric distributio](https://en.wikipedia.org/wiki/Geometric_distribution)n

$$
\mathrm{P}_q(r)=(1-q)^{r-1}q
$$

To test above hypothesis we consider the following random process.

![](https://nomos-tech.notion.site/image/attachment%3Ae8093575-6084-4b91-a33d-00a391d12f8a%3Amessages2.png?table=block&id=1fd261aa-09df-81a9-a3d1-fb10f421b376&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=740&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Computing the histogram of “the number of rounds a messages stays in the queue” random variable confirms that the latter follows the Geometric distribution.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F958f3f7b-d957-44f9-ae82-d1b2b5ae5d6d%2FScreenshot_2024-07-17_at_13.19.35.png?table=block&id=1fd261aa-09df-812b-9fbb-d46e2f572530&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=930&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Decreasing $q$ reduces number of messages removed per round as can be seen below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa1bad5ad-23cb-4443-a57a-e02668e82ab0%2FScreenshot_2024-07-17_at_15.28.10.png?table=block&id=1fd261aa-09df-8101-b022-deb44c85b72e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Increasing $q$ increases number of messages removed per round as can be seen below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F5023a1c2-f432-4d52-94ff-faaaa3e59638%2FScreenshot_2024-07-17_at_15.32.58.png?table=block&id=1fd261aa-09df-8166-b4ba-f5e80d080c48&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The Geometric distribution $\mathrm{P}_q(r)$ is increasing function of $q$ for $1/q>r$ and decreasing function of $q$ for $1/q<r$.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0c5df5a7-caff-4562-a365-0071984ecc0c%2FScreenshot_2024-07-17_at_17.24.17.png?table=block&id=1fd261aa-09df-8167-b34f-e48609b4bfca&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Assuming that the duration of round $k$ is $\Delta_k$ the message which arrived at time $t_i$ will be removed from the queue at time $t_i+\sum_{k=1}^r\Delta_k$, where $r$ is random variable from the Geometric distribution $\mathrm{P}_{q}(r)$. We expect that $\Delta_k$ is a function of the number $n_1(k)$ of messages removed at round $k$, i.e. $\Delta_k\equiv \Delta(n_1(k))$. Here $n_1(k)$ is random number from the binomial distribution with parameters $n$ ( size of queue) and $q$ (prob. of dequeuing a message). We note that at most $n$ messages can be removed and $\Delta(n_1(k))\leq \Delta(n)$. The latter implies that $t_i+\sum_{k=1}^r\Delta(n_1(k))\leq  t_i+ r\Delta$ , where we defined $\Delta=\Delta(n)$. Thus a message is delayed in the out-queue $Q_1^{out}$ by at most $r\Delta$, where $r$ is the random variable from the distribution $\mathrm{P}_q(r)$.

Furthermore, the probability $\mathrm{P}(r\leq R-1)=1-(1-q)^{R-1}$ for the random variable $r$ from the Geometric distribution $\mathrm{P}_q(r)$. Hence

$$
\mathrm{P}(r\geq R)=1-\mathrm{P}(r\leq R-1)= (1-q)^{R-1}.
$$

Thus a message is delayed by $r\Delta\geq R\Delta$ with the probability $(1-q)^{R-1}$. We note that for the random variable $r$ from the Geometric distribution $\mathrm{P}_q(r)$ we can show that $\mathrm{P}(R>m+n\vert R>m)=\mathrm{P}(R>n)$. The latter is memorylessness property of Geometric distribution and the consequence of the latter is that the amount of time a message will spend in the queue is independent on how long it is already been in the queue.

# Bibliography

Das D., Diaz C., Kiayias A., Zacharias T. (2024). Are continuous stop-and-go mixnets provably secure? Proceedings on Privacy Enhancing Technologies. [https://eprint.iacr.org/2023/1311](https://eprint.iacr.org/2023/1311)

Serjantov, A., Danezis, G. (2003). Towards an Information Theoretic Metric for Anonymity. In: Dingledine, R., Syverson, P. (eds) Privacy Enhancing Technologies. PET 2002. Lecture Notes in Computer Science, vol 2482. Springer, Berlin, Heidelberg. [https://doi.org/10.1007/3-540-36467-6_4](https://doi.org/10.1007/3-540-36467-6_4)

