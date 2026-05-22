# ANALYSISQUEUING-SYSTEM-IN-THE-MIX-NODE

| Field | Value |
| --- | --- |
| Name | [Analysis] Queuing System in the Mix Node |
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
| 1.0.0 | Initial revision. | 2025-09-08 |

## Introduction

We consider queuing system of a mix node where coin-flipping algorithm is used to remove messages. We show that the amount of time message spends in a queue is governed by the [Geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution). The consequence of the latter is [memorylessness](https://en.wikipedia.org/wiki/Memorylessness) property, i.e. the amount of time a message will spend in the queue is independent on how long it is already been in the queue, [which is important for anonymity of communication](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25#1fd261aa09df8172b2cbe6d970282cb0).

## Overview

This document analyses how a mix node—a privacy tool that hides message origins—manages delays using randomised queues. Key points:

Queue Design:

Each connection has an in-queue (FIFO order) and out-queue with randomised removal.

A "Relayer" forwards real messages to all out-queues except the sender’s, dropping dummies.

Randomised Delays:

Messages in the out-queue are shuffled, then each has probability $q$ (e.g., 50%) of being sent per round.

This follows a Geometric distribution: ~50% sent in Round 1, ~25% in Round 2, etc.

Anonymity Guarantee:

The system’s memorylessness ensures delays are independent of past wait times, preventing timing attacks.

Methods used:

Geometric distribution models rounds until a message is sent.

Simulations (e.g., sending 10,000 messages) validate the theory.

Binomial distribution tracks messages removed per round.

Why It Matters:

Balances privacy (unpredictable delays) with efficiency (tunable via $q$ ).

Foundations for Tor-like systems and anonymous networks.

## Analysis

### Assumptions

We assume that node $i$ has $c\_i$ connections to other nodes, labelled by the set $[c\_i]$ , and two queues (”in-queue” and “out-queue”), associated with each connection. Messages which arrive via the connection $\ell\in [c\_i]$ are stored in the in-queue $Q\_\ell^{in}$ . Messages which are sent via the connection $\ell\in [c\_i]$ are stored in the out-queue $Q\_\ell^{out}$ . Messages are added to the back and removed from the front of $Q\_\ell^{in}$ , i.e. the latter is [the FIFO queue](https://en.wikipedia.org/wiki/FIFO_(computing_and_electronics))

![](/image/attachment%3A6e043ff2-4443-447f-bae6-3f43a78d0e3f%3AScreenshot_2025-05-21_at_12.22.42.png?table=block&id=1fd261aa-09df-81eb-b8b4-fec1e7ae732f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Representation of a FIFO (first in, first out) queue.

ALT

We note that FIFO queue preserves temporal order of arriving messages.

The Relayer removes a message from the front of $Q\_\ell^{in}$ and i) drops it if the message is a dummy or ii) adds the message to the back of all $Q\_k^{out}$ , where $k\in[c\_i]\setminus j$ , queues (i.e. all out-queues but $j$ ) if message is “real”.

![](/image/attachment%3Adc02fe63-4092-4f35-97aa-c3160ff2c076%3AScreenshot_2025-05-20_at_15.58.37.png?table=block&id=1fd261aa-09df-8105-9d2f-e59104962ef6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Above operation is repeated by Relayer for all $j\in [c\_i]$

![](/image/attachment%3A5665675c-f365-4b73-81df-84a4685846b4%3AScreenshot_2025-05-20_at_15.59.57.png?table=block&id=1fd261aa-09df-819d-818e-ce706434487d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Analysis of a single out-queue

Let us consider, without loss of generality, the out-queue $Q\_1^{out}$ and assume that the front of $Q\_1^{out}$ holds $n$ messages which arrived at times $t\_1\leq t\_2\leq\cdots\leq t\_n$ . Furthermore, we assume that messages which arrive at times after time $t\_n$ , $t\_i > t\_n$ , are labelled by $i\in \mathbb{N}\setminus [n]$ , i.e. we assume that messages are labelled by the set $\mathbb{N}$ .

The above $n$ messages are shuffled, which is equivalent to random permutation, then each message is removed from the queue with probability $q$ and sent. In above removal of a message which arrived at time $t\_i$ can be modeled by the binary variable $x\_i\in\{0,1\}$ , where $0/1$ corresponds to not-removed/removed. We note that number of removed messages in this process is the random variable from binomial distribution with parameters $n$ and $q$ . Hence above process on average (and (approx.) typically) removes $q\, n$ messages from the queue $Q\_1^{out}$ . The above algorithm can be seen as a variant of the pool mix (see the [article](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25#1fd261aa09df81609a91c4e9127d06ab))

![](/image/attachment%3Ab32c6736-933e-4137-ac23-e8a70926b742%3AScreenshot_2025-02-17_at_11.54.08.png?table=block&id=1fd261aa-09df-8168-b98c-d281f452fe13&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

A pool mix.

ALT

However, in the pool mix model a fixed number (of randomly selected messages) is removed and sent, but in the algorithm this number is random.

Let us assume that messages are removed from the front of the out-queue $Q\_1^{out}$ in rounds (or epochs) and if a message which arrived at time $t\_i$ , where $i\in \mathbb{N}$ , was removed at round $r$ then $x\_i(r)=1$ and $x\_i(k)=0$ for $1\leq kGeometric distribution

$$
\mathrm{P}\_q(r)=(1-q)^{r-1}q
$$
Pq​(r)=(1−q)r−1q

To test above hypothesis we consider the following random process.

![](/image/attachment%3Ae8093575-6084-4b91-a33d-00a391d12f8a%3Amessages2.png?table=block&id=1fd261aa-09df-81a9-a3d1-fb10f421b376&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=740&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The message removal process in the out-queue $Q\_1^{out}$ . At round $0$ the front of the queue contained $n=10$ messages. Here messages are labelled by the set $\mathbb{N}$ (top row). In round $1$ , and in subsequent rounds, each message is removed, with the prob. $q=1/2$ , and replaced with a next message from the queue $Q\_1^{out}$ .

ALT

Computing the histogram of “the number of rounds a messages stays in the queue” random variable confirms that the latter follows the Geometric distribution.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F958f3f7b-d957-44f9-ae82-d1b2b5ae5d6d%2FScreenshot_2024-07-17_at_13.19.35.png?table=block&id=1fd261aa-09df-812b-9fbb-d46e2f572530&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=930&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Histogram of the number of messages removed from the front of the queue $Q\_1^{out}$ at round $1$ , $2$ , etc. of the random message removal process with $q=1/2$ . At round $0$ the front of the queue contained $n=10^4$ messages. Here the simulation (red histogram bars) is compared with the prediction $n\,\mathrm{P}\_q(r)$ of Geometric distribution (square boxes). We note that for $q=1/2$ on average $n/2$ messages were removed at round $1$ , $n/4$ messages were removed at round $2$ , etc.

ALT

Decreasing $q$ reduces number of messages removed per round as can be seen below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa1bad5ad-23cb-4443-a57a-e02668e82ab0%2FScreenshot_2024-07-17_at_15.28.10.png?table=block&id=1fd261aa-09df-8101-b022-deb44c85b72e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Histogram of the number of messages removed from the front of the queue $Q\_1^{out}$ at round $1$ , $2$ , etc. of the random message removal process with $q=1/4$ . At round $0$ the front of queue contained $n=10^4$ messages. Here the simulation (red histogram bars) is compared with the prediction $n\,\mathrm{P}\_q(r)$ of Geometric distribution (square boxes). We note that for $q=1/4$ on average $n/4$ messages were removed at round $1$ , $(n-n/4)/4$ messages were removed at round $2$ , etc.

ALT

Increasing $q$ increases number of messages removed per round as can be seen below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F5023a1c2-f432-4d52-94ff-faaaa3e59638%2FScreenshot_2024-07-17_at_15.32.58.png?table=block&id=1fd261aa-09df-8166-b4ba-f5e80d080c48&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Histogram of the number of messages removed from the front of the queue $Q\_1^{out}$ at round $1$ , $2$ , etc. of the random message removal process with $q=3/4$ . At round $0$ the front of queue contained $n=10^4$ messages. Here the simulation (red histogram bars) is compared with the prediction $n\,\mathrm{P}\_q(r)$ of Geometric distribution (square boxes). We note that for $q=3/4$ on average $3n/4$ messages were removed at round $1$ , $3(n-3n/4)/4$ messages were removed at round $2$ , etc.

ALT

The Geometric distribution $\mathrm{P}\_q(r)$ is increasing function of $q$ for $1/q>r$ and decreasing function of $q$ for $1/q

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0c5df5a7-caff-4562-a365-0071984ecc0c%2FScreenshot_2024-07-17_at_17.24.17.png?table=block&id=1fd261aa-09df-8167-b34f-e48609b4bfca&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The Geometric distribution $\mathrm{P}\_q(r)$ plotted as the function of $r\in\mathbb{N}$ for $q\in\{1/4,1/2,3/4\}$ (magenta, red, blue).

ALT

Assuming that the duration of round $k$ is $\Delta\_k$ the message which arrived at time $t\_i$ will be removed from the queue at time $t\_i+\sum\_{k=1}^r\Delta\_k$ , where $r$ is random variable from the Geometric distribution $\mathrm{P}\_{q}(r)$ . We expect that $\Delta\_k$ is a function of the number $n\_1(k)$ of messages removed at round $k$ , i.e. $\Delta\_k\equiv \Delta(n\_1(k))$ . Here $n\_1(k)$ is random number from the binomial distribution with parameters $n$ ( size of queue) and $q$ (prob. of dequeuing a message). We note that at most $n$ messages can be removed and $\Delta(n\_1(k))\leq \Delta(n)$ . The latter implies that $t\_i+\sum\_{k=1}^r\Delta(n\_1(k))\leq t\_i+ r\Delta$ , where we defined $\Delta=\Delta(n)$ . Thus a message is delayed in the out-queue $Q\_1^{out}$ by at most $r\Delta$ , where $r$ is the random variable from the distribution $\mathrm{P}\_q(r)$ .

Furthermore, the probability $\mathrm{P}(r\leq R-1)=1-(1-q)^{R-1}$ for the random variable $r$ from the Geometric distribution $\mathrm{P}\_q(r)$ . Hence

$$
\mathrm{P}(r\geq R)=1-\mathrm{P}(r\leq R-1)= (1-q)^{R-1}.
$$
P(r≥R)=1−P(r≤R−1)=(1−q)R−1.

Thus a message is delayed by $r\Delta\geq R\Delta$ with the probability $(1-q)^{R-1}$ . We note that for the random variable $r$ from the Geometric distribution $\mathrm{P}\_q(r)$ we can show that $\mathrm{P}(R>m+n\vert R>m)=\mathrm{P}(R>n)$ . The latter is memorylessness property of Geometric distribution and the consequence of the latter is that the amount of time a message will spend in the queue is independent on how long it is already been in the queue.

## Bibliography

Das D., Diaz C., Kiayias A., Zacharias T. (2024). Are continuous stop-and-go mixnets provably secure? Proceedings on Privacy Enhancing Technologies. <https://eprint.iacr.org/2023/1311>

Serjantov, A., Danezis, G. (2003). Towards an Information Theoretic Metric for Anonymity. In: Dingledine, R., Syverson, P. (eds) Privacy Enhancing Technologies. PET 2002. Lecture Notes in Computer Science, vol 2482. Springer, Berlin, Heidelberg. <https://doi.org/10.1007/3-540-36467-6_4>

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Queuing System in the Mix Node

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Queuing-System-in-the-Mix-Node-1fd261aa09df81dcb90bdad3e6d88b21?pvs=26&qid=1:7de72893-5ab7-41cd-bb41-6997c0e6358c:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Queuing System in the Mix Node

Revision History

Table

Introduction

We consider queuing system of a mix node where coin-flipping algorithm is used to remove messages. We show that the amount of time message spends in a queue is governed by the Geometric distribution. The consequence of the latter is memorylessness property, i.e. the amount of time a message will spend in the queue is independent on how long it is already been in the queue, which is important for anonymity of communication.

Overview

This document analyses how a mix node—a privacy tool that hides message origins—manages delays using randomised queues. Key points:

1. Queue Design:

   - Each connection has an in-queue (FIFO order) and out-queue with randomised removal.
   - A "Relayer" forwards real messages to all out-queues except the sender’s, dropping dummies.
2. Randomised Delays:

   - Messages in the out-queue are shuffled, then each has probability ΣEquation (e.g., 50%) of being sent per round.
   - This follows a Geometric distribution: ~50% sent in Round 1, ~25% in Round 2, etc.
3. Anonymity Guarantee:

   - The system’s memorylessness ensures delays are independent of past wait times, preventing timing attacks.

Methods used:

- Geometric distribution models rounds until a message is sent.
- Simulations (e.g., sending 10,000 messages) validate the theory.
- Binomial distribution tracks messages removed per round.

Why It Matters:

- Balances privacy (unpredictable delays) with efficiency (tunable via ΣEquation).
- Foundations for Tor-like systems and anonymous networks.

Analysis

Assumptions

We assume that node ΣEquation has ΣEquation connections to other nodes, labelled by the set ΣEquation, and two queues (”in-queue” and “out-queue”), associated with each connection. Messages which arrive via the connection ΣEquation are stored in the in-queue ΣEquation. Messages which are sent via the connection ΣEquation are stored in the out-queue ΣEquation. Messages are added to the back and removed from the front of ΣEquation, i.e. the latter is the FIFO queue

![](/image/attachment%3A6e043ff2-4443-447f-bae6-3f43a78d0e3f%3AScreenshot_2025-05-21_at_12.22.42.png?table=block&id=1fd261aa-09df-81eb-b8b4-fec1e7ae732f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that FIFO queue preserves temporal order of arriving messages.

The Relayer removes a message from the front of ΣEquation and i) drops it if the message is a dummy or ii) adds the message to the back of all ΣEquation, where ΣEquation, queues (i.e. all out-queues but ΣEquation) if message is “real”.

![](/image/attachment%3Adc02fe63-4092-4f35-97aa-c3160ff2c076%3AScreenshot_2025-05-20_at_15.58.37.png?table=block&id=1fd261aa-09df-8105-9d2f-e59104962ef6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Above operation is repeated by Relayer for all ΣEquation

![](/image/attachment%3A5665675c-f365-4b73-81df-84a4685846b4%3AScreenshot_2025-05-20_at_15.59.57.png?table=block&id=1fd261aa-09df-819d-818e-ce706434487d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Analysis of a single out-queue

Let us consider, without loss of generality, the out-queue ΣEquation and assume that the front of ΣEquation holds ΣEquation messages which arrived at times ΣEquation. Furthermore, we assume that messages which arrive at times after time ΣEquation, ΣEquation, are labelled by ΣEquation, i.e. we assume that messages are labelled by the set ΣEquation.

The above ΣEquation messages are shuffled, which is equivalent to random permutation, then each message is removed from the queue with probability ΣEquation and sent. In above removal of a message which arrived at time ΣEquation can be modeled by the binary variable ΣEquation, where ΣEquation corresponds to not-removed/removed. We note that number of removed messages in this process is the random variable from binomial distribution with parameters ΣEquation and ΣEquation. Hence above process on average (and (approx.) typically) removes ΣEquation messages from the queue ΣEquation. The above algorithm can be seen as a variant of the pool mix (see the article)

![](/image/attachment%3Ab32c6736-933e-4137-ac23-e8a70926b742%3AScreenshot_2025-02-17_at_11.54.08.png?table=block&id=1fd261aa-09df-8168-b98c-d281f452fe13&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

However, in the pool mix model a fixed number (of randomly selected messages) is removed and sent, but in the algorithm this number is random.

Let us assume that messages are removed from the front of the out-queue ΣEquation in rounds (or epochs) and if a message which arrived at time ΣEquation, where ΣEquation, was removed at round ΣEquation then ΣEquation and ΣEquation for ΣEquation. We assume that after each round of removal the removed messages are replaced with new messages and the front ΣEquation messages in the queue are shuffled before the next round of removal. We assume that round ΣEquation follows the Geometric distribution

📈Equation

To test above hypothesis we consider the following random process.

![](/image/attachment%3Ae8093575-6084-4b91-a33d-00a391d12f8a%3Amessages2.png?table=block&id=1fd261aa-09df-81a9-a3d1-fb10f421b376&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Computing the histogram of “the number of rounds a messages stays in the queue” random variable confirms that the latter follows the Geometric distribution.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F958f3f7b-d957-44f9-ae82-d1b2b5ae5d6d%2FScreenshot_2024-07-17_at_13.19.35.png?table=block&id=1fd261aa-09df-812b-9fbb-d46e2f572530&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Decreasing ΣEquation reduces number of messages removed per round as can be seen below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa1bad5ad-23cb-4443-a57a-e02668e82ab0%2FScreenshot_2024-07-17_at_15.28.10.png?table=block&id=1fd261aa-09df-8101-b022-deb44c85b72e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Increasing ΣEquation increases number of messages removed per round as can be seen below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F5023a1c2-f432-4d52-94ff-faaaa3e59638%2FScreenshot_2024-07-17_at_15.32.58.png?table=block&id=1fd261aa-09df-8166-b4ba-f5e80d080c48&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The Geometric distribution ΣEquation is increasing function of ΣEquation for ΣEquation and decreasing function of ΣEquation for ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0c5df5a7-caff-4562-a365-0071984ecc0c%2FScreenshot_2024-07-17_at_17.24.17.png?table=block&id=1fd261aa-09df-8167-b34f-e48609b4bfca&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Assuming that the duration of round ΣEquation is ΣEquation the message which arrived at time ΣEquation will be removed from the queue at time ΣEquation, where ΣEquation is random variable from the Geometric distribution ΣEquation. We expect that ΣEquation is a function of the number ΣEquation of messages removed at round ΣEquation, i.e. ΣEquation. Here ΣEquation is random number from the binomial distribution with parameters ΣEquation ( size of queue) and ΣEquation (prob. of dequeuing a message). We note that at most ΣEquation messages can be removed and ΣEquation. The latter implies that ΣEquation , where we defined ΣEquation. Thus a message is delayed in the out-queue ΣEquation by at most ΣEquation, where ΣEquation is the random variable from the distribution ΣEquation.

Furthermore, the probability ΣEquation for the random variable ΣEquation from the Geometric distribution ΣEquation. Hence

📈Equation

Thus a message is delayed by ΣEquation with the probability ΣEquation. We note that for the random variable ΣEquation from the Geometric distribution ΣEquation we can show that ΣEquation. The latter is memorylessness property of Geometric distribution and the consequence of the latter is that the amount of time a message will spend in the queue is independent on how long it is already been in the queue.

Bibliography

Das D., Diaz C., Kiayias A., Zacharias T. (2024). Are continuous stop-and-go mixnets provably secure? Proceedings on Privacy Enhancing Technologies. https://eprint.iacr.org/2023/1311

Serjantov, A., Danezis, G. (2003). Towards an Information Theoretic Metric for Anonymity. In: Dingledine, R., Syverson, P. (eds) Privacy Enhancing Technologies. PET 2002. Lecture Notes in Computer Science, vol 2482. Springer, Berlin, Heidelberg. https://doi.org/10.1007/3-540-36467-6\_4

- Open in new tab
