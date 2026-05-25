# ANALYSIS-COMMUNICATION-ON-TREES

| Field | Value |
| --- | --- |
| Name | [Analysis] Communication on Trees |
| Slug | 187 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-communication-on-trees.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-communication-on-trees.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-08-25 |

# Introduction

We would like to understand how to reduce probability of a communication failure, i.e. when a message sent by a node is “lost” somewhere in the network and not broadcasted. The latter is a main concern as a naive approach of retransmission increases the delay and bandwidth, and reduces anonymity. We have identified two approaches with a potential to reduce communication failure. In the first approach, the sender node uses multiple independent linear paths, i.e. linear trees, to send a message. However, initial analysis suggests that to reduce communication failure in the latter, one must increase the number of communication paths significantly which would have detrimental effect on the bandwidth of a sending node. In the second approach, where the sender node is root of a branching tree, bandwidth of a sending node is only weakly affected by the number communication paths.

First, we assume that a fraction of nodes in the network is adversarial and compute the probability of broadcast and anonymity failures for broadcasting on linear trees. We note that if each communication path has at least one adversarial node then this is considered to be a broadcasting failure and if there is at least one path where all nodes are adversarial then this considered to be anonymity failure. Probabilities are parametrised by the fraction of adversarial nodes, number of paths and number of nodes per path. Second, we compute failure probabilities for broadcasting on branching trees. Assuming the same number of paths, we compare results for linear and branching trees and we find that the linear tree design has better broadcast failure properties than the branching tree design, but worse anonymity failure properties. Finally, we assume that, in addition to adversarial nodes, we also have “faulty” nodes in the network. The latter are unable to relay a messages and their faultiness is a result of some “natural” process. Here we find only quantitative differences with the scenario when only adversarial nodes are considered, but we expect that the model which accounts for “natural” failures to be more realistic.

> Details of mathematical derivations, with references to literature, and additional numerical results are provided in the [Appendix](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8).

# Overview

This document investigates methods to reduce communication failures in network messaging by comparing two primary designs: linear trees and branching trees. The study focuses on minimizing broadcast failures (lost messages) and anonymity failures (privacy breaches) while considering bandwidth constraints.

The analysis uses probabilistic models and recursive equations to compute failure probabilities under adversarial and faulty node conditions. For linear trees, broadcast and anonymity failures are derived based on path length and the number of independent paths. For branching trees, recursive methods determine critical thresholds where failures become inevitable.

A two-variable model is introduced to separate natural faults from adversarial behavior, improving realism. Simulations validate theoretical results, showing trade-offs:

- Linear trees offer better broadcast reliability but worse anonymity and higher bandwidth costs.
- Branching trees reduce anonymity risks and bandwidth usage but are more vulnerable to shared-node failures.

The findings guide design choices based on network priorities (e.g., reliability vs. privacy) and constraints (e.g., node bandwidth). The appendix includes detailed derivations and simulation results.

# Analysis

## Communication on Linear Trees

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6c66aa27-de8a-46a9-93d1-9eca55256101%2FScreenshot_2024-12-16_at_13.58.54.png?table=block&id=1fd261aa-09df-8110-ac5d-cfb2adf7ffed&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=850&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We assume that a node sends a message through $K$ communication paths where each path is a linear tree constructed from exactly $L$ nodes (see figure above). We assumed that $L\times K$ nodes were sampled (with replacement) from the population of $N$ nodes where $N_F$ nodes are “faulty”. If a path contains at least one faulty node then communication failure occurred. If all $K$ paths have communication failure then broadcast failure occurred.

If nodes in communication paths are sampled with replacement from the $N$ network nodes with $N_F<N$ faulty nodes then the probability that a node is faulty is $q=N_F/N$. The probability of broadcast failure is given by

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that in the limit $L\rightarrow\infty$, such that $K/L\rightarrow0$, the probability of broadcast failure $\mathrm{P}_b\rightarrow1$ and in the limit $K\rightarrow\infty$, such that $L/K\rightarrow0$, the probability $\mathrm{P}_b\rightarrow0$.

Let us now assume that $q$ is the probability that a node is “curious”. Then the event "there is at least one path where all nodes are curious" is the anonymity failure. The probability of anonymity failure is given by

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that in the limit $L\rightarrow\infty$, such that $K/L\rightarrow0$, the probability of anonymity failure $\mathrm{P}_a\rightarrow0$ and in the limit $K\rightarrow\infty$, such that $L/K\rightarrow0$, the probability $\mathrm{P}_a\rightarrow1$.

Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3A459195ec-e882-4619-9fb8-143596ea986f%3A6d6c66f1-dfc7-4f35-a075-438f7c7f505a.png?table=block&id=1fd261aa-09df-811a-b335-eea36fd7cbc9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A9ca4e133-adfd-49f9-abf1-5ceceacae414%3A4156e6f1-bb01-4611-862a-67df20934f71.png?table=block&id=1fd261aa-09df-81a5-ab4d-cd69eb4a3b45&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that the number of samples $M$ in above figures is equivalent to the number of messages sent by a sender node.

## Communication on Branching Trees

### Assumptions

We consider broadcasting on a tree $\mathcal{T}_L$ with layers labeled, from leaf nodes to the root node, by the set $\{0,1,\ldots,L\}$ (see figure below). All nodes in a tree at the same distance from its root constitute a layer. We assume that the root node of $\mathcal{T}_L$ is sending a message to leaf nodes. A node inside $\mathcal{T}_L$ is relaying a message to $b$ nodes, i.e. $\mathcal{T}_L$ is $b$-ary tree.  The set of all leaf node is the “boundary” $\partial\mathcal{T}_L$ of the tree $\mathcal{T}_L$. $b$-ary tree $\mathcal{T}_L$ is balanced and complete if all distances from the root node to a leaf node are the same.

In this document we consider only balanced and complete $b$-ary trees. The number of leaf nodes $\vert\partial\mathcal{T}_L\vert=b^L$ is also the number of paths from the root node to leaf nodes. If all leaf nodes didn't receive a message sent from the root node then broadcast failure occurred. Let us now assume that $q$ is the probability that a node is “curious”. Then the event "there is at least one path where all nodes are curious" is the anonymity failure.

![](https://nomos-tech.notion.site/image/attachment%3A44c558a1-d927-4c77-b310-fe6a3b4bd192%3A59e7423a-596d-4503-874c-ddb21a467930.png?table=block&id=1fd261aa-09df-815a-b157-d198a9e446a4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1220&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Analysis of communication failures

The prob. of broadcast failure $B_{L}$ in the tree with $L$ layers and branching parameter $b$ can be computed recursively (see the [Details of derivations](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8) section) via the following set of equations

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

Solving above equations gives the following results

![](https://nomos-tech.notion.site/image/attachment%3Aae371e21-5edc-40ba-ba5d-91093abe81c7%3A643babd8-68ab-48af-9452-355ee2905117.png?table=block&id=1fd261aa-09df-811e-93b2-d78d0a944f2c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Aa1ddab4a-bfe2-4d84-aaf0-4ce5b596b622%3A0e855edd-89fc-49e5-bab4-4aa1c2f6a0d8.png?table=block&id=1fd261aa-09df-81d0-bbfd-e90fdf7188c1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A59ee57ad-be25-4f2f-87a2-2baed8151525%3A4a80d271-1845-4217-9017-e8f593c44b3f.png?table=block&id=1fd261aa-09df-8148-be03-e9d92374e5f9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Analysis of anonymity failure

The prob. of anonymity failure $A_{L}$ in the tree with $L$ layers and branching parameter $b$ can be computed recursively (see the [Details of derivations](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8) section) via the following set of equations

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

Solving above equations gives the following results

![](https://nomos-tech.notion.site/image/attachment%3Ae042794e-45e4-4ecf-9c56-256bb73d7294%3A2890f7b1-c8bb-4e0e-a314-4d6ac7076a9a.png?table=block&id=1fd261aa-09df-81b6-8f1d-d40612a69a13&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Abafabf73-9a3a-4f08-8e38-e5d98f89293b%3A1cf41f42-7438-4c6a-b21a-88504ae77f06.png?table=block&id=1fd261aa-09df-81cb-a1e9-d7b44e577c62&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Af36b7a09-97f9-4660-a437-0910e745d4b1%3A5146dc9f-3af7-4c5b-964c-d10e08df9018.png?table=block&id=1fd261aa-09df-8152-ae99-e2f5e196f089&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Results of simulations

Above analytic results, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3A6c9475b5-38c6-4fb7-a023-3feac9f3fc93%3Ad2f795ec-49a5-4662-a8bc-e84b85f45e38.png?table=block&id=1fd261aa-09df-815f-8b29-dadd4187e2a0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ac1a92200-54c9-4fad-a249-c0f36a198622%3A360d4576-d85f-4aee-a891-88f9621a3f94.png?table=block&id=1fd261aa-09df-81e4-bc08-d349954513cd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that the number of samples $M$ in above figures is equivalent to the number of messages sent by a sender node.

### Discussion of results for linear and branching tree designs

Discussion of difference between designs

The number of leaf nodes in the branching tree is $b^L$ , where $b$ is the branching parameter and $L$ is the number of layers, which is also the number of communication paths. To compare the two designs we assume that both of them have the same number of communication paths. The latter implies that the total number of nodes used in linear tree design is $1+L b^L$ (the number of nodes in linear tree design is $1+KL$, where $K$ is the number of paths and $L$ is the number of nodes in a path without the sender node) and in branching tree design is $1+b+b^2+\cdots+b^L$. We note that the number of paths grows exponentially with the number of layers $L$ (and branching parameter $b$) as can be seen in the figure below

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F7413d956-0016-4ccf-a150-35fbd9871e3d%2FScreenshot_2024-12-23_at_10.35.05.png?table=block&id=1fd261aa-09df-81dd-b2be-daed51f9082e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The consequences of having $b^L$ comm. paths in both designs is that the out-degree of a sender node in linear design is $b^L$ and in branching design is $b$. However, the out-degree is the number of messages sent by a node and hence the number of messages which have to be sent by a sender node grows exponentially in the linear design, but in the branching design it is a constant, i.e. $b$. This suggests that the out-degree of a sender node (in linear and branching designs) is constrained by bandwidth of a node.

The ratio $\text{num. of nodes}/\text{num. of comm. paths} = L$ in the linear design and in the branching design the $\text{num. of nodes}/\text{num. of comm. paths} = \left(\frac{b^{L+1}-1}{b-1} -1\right)/b^L \leq b/(b-1)$, i.e. the ratio is growing linearly with $L$ in the linear design and it is at most $b/(b-1)$, i.e. a constant, in the branching design.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F31d05305-3eb1-4e33-9e52-9967d3d5a8c9%2FScreenshot_2024-12-23_at_10.40.23.png?table=block&id=1fd261aa-09df-81b5-b13f-d9fbe06d6be0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Given that the number of communication paths is the same in both designs, the bandwidth consumption "pattern" is very different between these two designs. In linear tree design the root node has to send $b^L$ messages to other nodes and other nodes, but leaf nodes, receive a single message and send a single message. In branching tree design the root node sends $b$ number of messages to other nodes and other nodes, but leaf nodes, receive a single message and send $b$ messages. For the branching tree design a node might need to send the same number of messages as in the linear tree design as we might not be able to [encode messages](https://nomos-tech.notion.site/215261aa09df81ae8857d71066a80084?pvs=25#215261aa09df816cb2cdcb5dc8eeb991) in a way that it will be able to use topology efficiently.

For now bandwidth optimisation is not a priority as it depends on possibility of efficient implementation of a communication design which is not investigated at the moment.  Assuming that branching tree design can be implemented efficiently, the root node in the linear case is more "chatty", where the number of messages sent is equal to the number of comm. paths, than in the branching case, where the number of messages sent is equal to the branching parameter and is independent from the number of comm. paths, which would make "anonymity" properties of the sender (root node) in these designs very different which has to be taken in to consideration when making decision on which design to choose.

Discussion of results for failures

We assume that the number of comm. paths in both designs is $K=b^L$ and consider communication and anonymity failures. For anonymity failure we will use the same statistical model as for communication failure, with "faulty" replaced by "curious", and the same probability $q$ that node is faulty or curious. The linear tree design has better communication failure properties than the branching tree design but worse anonymity failure properties as can be seen in two figures below

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fcd1630c6-bdd1-4368-aa76-13d4a2a87f98%2FScreenshot_2024-12-23_at_10.53.56.png?table=block&id=1fd261aa-09df-813e-8684-cf45a5c8e40c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F81c89d55-dc5f-49bb-aa87-944933940ce7%2FScreenshot_2024-12-23_at_10.55.27.png?table=block&id=1fd261aa-09df-8158-8d53-fb1e3d921343&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We want to find a solution that minimises both failure probabilities. Plotting one prob. against another gives us

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fc5f725be-28bd-4982-83e5-d88ca6a00e7c%2FScreenshot_2024-12-23_at_11.01.31.png?table=block&id=1fd261aa-09df-8180-b7fd-f4cbe6d3ec59&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that $L$ in above is increasing from top to bottom. For linear tree design both probabilities are minimal for $L=5$, i.e. maximum number of layers. For branching tree design we can not minimise both probabilities , but the probability of anonymity failure is always less than in the linear tree design for any $L$.  Also, we note that linear trees design has better communication failure properties since it consists of $b^L$ independent paths. Paths in branching trees design share nodes which increases the ramifications of communication failure at an interior node. On the other hand, linear trees has worse anonymity properties since it consists of more nodes to form the $b^L$ paths.

Discussion of failure model

The current approach, where we label a node by a single binary (random) variable, can be used to model only communication failures or anonymity failures but not both.  When both communication and anonymity failures are modelled with a single binary variable then this can be interpreted as a scenario where an adversary controls some number of nodes in a tree. Then it uses these nodes to cause broadcast failure or anonymity failure. Hence here a probability of failure can interpreted as frequency of adversarial opportunities to cause failures.

We note that in above single-variable approach adversary is cause of both communication and anonymity failures, when both of these failures are considered together. However, in real world scenario communication failures can occur “naturally” and independently from adversarial behaviour. The latter can also cause communication failures, but natural failures can for e.g. interfere with adversary’s ability to cause anonymity failure which is not accounted for in the current single-variable model.

We note that an adversary can use communication failures to provoke node operators to increase number of communication paths, but the latter could increase chances of anonymity failure. Such adversarial strategy can be used in the linear design for example.

In order to separate “natural” communication failures from adversarial, we need to introduce two (random) binary variables which will be associated with a node. One variable to model natural communication failures of nodes and the other variable is an adversarial “label”, i.e. second variable labels a node as "adversarial" or "honest". The adversary will choose on how to use nodes it controls. It can use these nodes to cause communication failure, anonymity failure, etc. From analysis perspective a two-variable model is not much more complex than single-variable model, but will allow us to separate better adversarial failures from non-adversarial.

## Communication on Linear Trees: two-variable failure model

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6be5b10e-8533-41e7-a7e3-b4170dcb876e%2FScreenshot_2025-01-02_at_12.37.14.png?table=block&id=1fd261aa-09df-81fd-bde2-c4cc3eaab976&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1200&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We assume that a node sends a message through $K$ communication paths where each path contains exactly $L$ nodes. We assumed that $L\times K$ nodes were sampled with replacement from the population of $N$ nodes.

### Analysis of broadcast failure

We assume that $M_F$ nodes in the population are “faulty” (faulty node is unable to relay a message).  The probability that a node is faulty is $q_F=M_F/N$. If a path contains at least one faulty node then communication failure occurred. If all nodes in a communication path are non-faulty then this is a functioning communication path. If all $K$ paths have communication failure then broadcast failure occurred. The probability of broadcast failure is given by

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that $\mathrm{P}_b$ is (monotonic) decreasing function of $K$ and (monotonic) increasing function of $L$.  Above result is intuitive as increasing number of communications paths (of fixed length) increases chances that at least one of these paths is functional.  Also increasing length of paths (for a fixed number of paths) increases chances that in each path at least one node is faulty.  For $K\rightarrow\infty$, with $L$ fixed, the prob. $\mathrm{P}_b\rightarrow0$ and for $L\rightarrow\infty$, with $K$ fixed, the prob. $\mathrm{P}_b\rightarrow1$.

We note that anonymity properties are improved for larger $L$ (see [Analysis of anonymity failure](https://nomos-tech.notion.site/Analysis-of-anonymity-failure-1fd261aa09df81bbb79ecb2bf3fcf209?pvs=24#1fd261aa09df8160bc7dec266ad5ed6b)) and we would like to find a relation between $K$ and $L$ such that we have both good communication and anonymity properties. Let us assume that $K=f(L)$, where $f(L)\in \mathbb{N}$, and consider the prob. $\mathrm{P}_b$. For the latter we have the following inequality

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

where in above we used $\log(x)\leq x-1$ to obtain inequality.  Hence for $K=f(L)$ we can have $\mathrm{P}_b\rightarrow0$ when $f(L)(1-q_F)^L\rightarrow\infty$ as $L\rightarrow\infty$.

We note that $f(L)(1-q_F)^L=\mathrm{e}^{L[\log(1-q_F)+\frac{1}{L}\log f(L)]}$ and hence for any $\epsilon>0$ the following condition

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

ensures that $\mathrm{P}_b\rightarrow0$ when $L\rightarrow\infty$. Above suggests

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

where $\alpha=\mathrm{e}^\epsilon$, i.e. the number of paths has to grow exponentially with $L$ to ensure that $\mathrm{P}_b\rightarrow0$ when $L\rightarrow\infty$.

### Analysis of anonymity failure

We assume that $M_A$ nodes in the population are “adversarial”;  adversarial nodes are controlled by an adversary which can make nodes faulty, use them for traffic analysis, etc. The probability that a node is adversarial is $q_A=M_A/N$. If there is at least one functioning communication paths where all nodes are adversarial, then adversary has opportunity to cause anonymity failure. The probability of anonymity failure is given by

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that $\mathrm{P}_a$ is (monotonic) increasing function of $K$ and (monotonic) decreasing function of $L$.  Also $\mathrm{P}_a$ is monotonic increasing function of $(1-q_F)\, q_A$ and hence monotonic decreasing function of $q_F$. For $K\rightarrow\infty$, with $L$ fixed, the prob. $\mathrm{P}_a\rightarrow1$ and for $L\rightarrow\infty$, with $K$ fixed, the prob. $\mathrm{P}_a\rightarrow0$.

Let us assume that $K=f(L)$, where $f(L)\in \mathbb{N}$, and consider the prob. $\mathrm{P}_a$. For the latter we have the following inequality

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

Hence for $K=f(L)$ we can have $\mathrm{P}_a\rightarrow0$ when $f(L)\frac{(1-q_F)^L\, q_A^L}{1-(1-q_F)^L\, q_A^L}\rightarrow0$ as $L\rightarrow\infty$. We note that $\frac{(1-q_F)^L\, q_A^L}{1-(1-q_F)^L\, q_A^L}=(1-q_F)^L\, q_A^L+O((1-q_F)^{2L}\, q_A^{2L})$ when $L\rightarrow\infty$ and hence $f(L)(1-q_F)^L\, q_A^L$ is the dominant term in $f(L)\frac{(1-q_F)^L\, q_A^L}{1-(1-q_F)^L\, q_A^L}\rightarrow0$.  Thus $\mathrm{P}_a\rightarrow0$ when $f(L)(1-q_F)^L\, q_A^L\rightarrow0$ as $L\rightarrow\infty$.

Let us assume $f(L)=\left(\frac{\alpha}{1-q_F}\right)^L$ and consider

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

From above follows that $\mathrm{P}_a\rightarrow0$ as $L\rightarrow\infty$ when $\alpha\,q_A<1$.  Hence, if $\alpha$ is such that $1<\alpha<1/q_A$ then the number of comm. paths $f(L)=\left(\frac{\alpha}{1-q_F}\right)^L$ ensures that $\mathrm{P}_b\rightarrow0$ and $\mathrm{P}_a\rightarrow0$ as $L\rightarrow\infty$.

### Analysis of adversarial broadcast-failure

If there is at least one adversarial node in each functioning communication paths then adversary has opportunity to cause broadcast failure. The probability of adversarial broadcast failure is given by

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that $\mathrm{P}_{ab}\leq\left[1-[(1- q_F)(1- q_A)]^L\right]^K$ and hence $\mathrm{P}_{ab}$ is bounded from above by (monotonic) decreasing function of $K$ and (monotonic) increasing function of $L$. For $K\rightarrow\infty$, with $L$ fixed, the prob. $\mathrm{P}_{ab}\rightarrow0$ and for $L\rightarrow\infty$, with $K$ fixed, the prob. $\mathrm{P}_{ab}\rightarrow1$.

Let us assume $K=f(L)$ and consider

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

Hence $\mathrm{P}_{ab}\rightarrow0$ when $f(L)[(1-q_A)(1-q_F)]^L\rightarrow\infty$ as $L\rightarrow\infty$. Furthermore, we can obtain the lower bound on $\mathrm{P}_{ab}$ as follows

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

We note that $(1-q_A)^L(1-q_F)^L \leq (1-q_F)^L$ and hence for $f(L)$ such that $f(L)[(1-q_A)(1-q_F)]^L\rightarrow0$, as $L\rightarrow\infty$, but $f(L)(1-q_F)^L\rightarrow\infty$ we have $\mathrm{P}_{ab}\rightarrow1$.

For $f(L)=\left(\frac{\alpha}{1-q_F}\right)^L$ we have

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

From above, it follows that if $\alpha\,(1-q_A)>1$, which is equivalent to $\alpha>1/(1-q_A)$, then $\mathrm{P}_{ab}\rightarrow0$ when $L\rightarrow\infty$.  Thus to have $\mathrm{P}_b\rightarrow0$, $\mathrm{P}_a\rightarrow0$, and $\mathrm{P}_{ab}\rightarrow0$ as $L\rightarrow\infty$ we have to choose

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

for the number of paths $K$ with

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F226dd7a2-fe6d-417a-9b6f-699f9b141e12%2FScreenshot_2025-01-08_at_10.57.57.png?table=block&id=1fd261aa-09df-81c3-bc80-e74e8a3535bd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Analysis of failures

Using the expression $f(L)=\left(\frac{\alpha}{1-q_F}\right)^L$, where $L$ is the number of nodes in a path and $\alpha$ parameter such that $f(L)\in \mathbb{N}$, for the number of paths in the upper bounds on failure probabilities $\mathrm{P}_b$, $\mathrm{P}_a$, and $\mathrm{P}_{ab}$ we obtain the following inequalities

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

and for any $\alpha\in \left(\frac{1}{1-q_A}, \frac{1}{q_A}\right)$ all of the above are vanishing as $L\rightarrow\infty$.  From above follows that broadcast failure probabilities $\mathrm{P}_b$ and $\mathrm{P}_{ab}$ are tending to $0$ with increasing $L$ at a much higher rate for a larger values of $\alpha$, but the anonymity failure prob. $\mathrm{P}_a$ is tending to $0$ at a much higher rate for a smaller values of $\alpha$.

We note that the number of comm. paths $f(L)$ and the number of nodes involved in communication $L\times  f(L)$, which is bounded by the number of nodes in the network $N$, is growing slowly (with $L$) when $\alpha$ is small and very fast when $\alpha$ is large when we increase the number of nodes per path $L$. For values of $\alpha$ close to $\frac{1}{1-q_A}$ probabilities of broadcast failures are tending to $0$ with increasing $L$ at a much lower rate than the prob. of anonymity failure as can be seen in the figures below

![](https://nomos-tech.notion.site/image/attachment%3A0bceada0-b44d-45cf-a113-e3a888ee75e3%3AScreenshot_2025-01-28_at_22.48.23.png?table=block&id=1fd261aa-09df-8157-8510-c44f641af213&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ff93f5f74-a28b-4fb5-bd46-0c1228aaa667%2FScreenshot_2025-01-13_at_10.28.23.png?table=block&id=1fd261aa-09df-810d-955a-dc9388b461cf&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F304321ec-9252-4f0b-be7e-47db69eb2e4c%2FScreenshot_2025-01-13_at_10.30.58.png?table=block&id=1fd261aa-09df-818d-8769-f5522d98f0b7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fd295c6da-8c04-49d8-847c-2065e25ec133%2FScreenshot_2025-01-13_at_10.32.17.png?table=block&id=1fd261aa-09df-8199-b283-c3cf9ae220df&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For $\alpha$ values closer to $1/q_A$ probabilities of broadcast failures are tending to $0$ with increasing $L$ at a much higher rate than the prob. of anonymity failure as can be seen in the figures below

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fe37585c3-a820-4776-b77f-f1a423d8e8d1%2FScreenshot_2025-01-13_at_10.52.32.png?table=block&id=1fd261aa-09df-818f-aabb-d6d6375c576e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F16b5935c-a1ac-44eb-a4d5-713b9dd81ceb%2FScreenshot_2025-01-13_at_10.53.18.png?table=block&id=1fd261aa-09df-81d3-946e-c105d0e1970e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fddeb1fb0-5d4b-4a27-877b-087f9a07e09d%2FScreenshot_2025-01-13_at_10.54.21.png?table=block&id=1fd261aa-09df-8132-899a-f5e85933f258&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fe4361fcd-4e3d-4510-aae8-842e8e2a2cf2%2FScreenshot_2025-01-13_at_10.55.42.png?table=block&id=1fd261aa-09df-817c-a265-eb67ff030d83&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For $\alpha$ outside of the interval $\left(\frac{1}{1-q_A}, \frac{1}{q_A}\right)$ we have that either the broadcast failure probabilities are increasing and anonymity failure prob. is decreasing with increasing $L$ when $\alpha<\frac{1}{1-q_A}$ or the broadcast failure probabilities are decreasing and anonymity failure prob. is increasing with increasing $L$ when $\alpha >  \frac{1}{q_A}$.

We note that $\mathrm{P}_{b}\leq \mathrm{e}^{-\alpha^L}$, $\mathrm{P}_{ab}\leq \mathrm{e}^{-\alpha^L(1- q_A)^L}$§11, and $\mathrm{e}^{-\alpha^L}\leq \mathrm{e}^{-\alpha^L(1- q_A)^L}$. The latter implies that for finite $L$ the broadcast failure probabilities are reduced when we increase $\alpha$, i.e. when the number of communication paths is increased. However, for finite $L$ the probability of anonymity failure $\mathrm{P}_a$ is reduced when we decrease $\alpha$, i.e. when the number of communication paths is decreased. This behaviour of failure probabilities for finite $L$ can be seen in the plots below.

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fbaa8546c-544b-4781-b4b3-d37d50ffb2f1%2FScreenshot_2025-01-13_at_12.19.17.png?table=block&id=1fd261aa-09df-8148-8e65-d1e86d59cbee&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2d3a31f7-1860-40c2-8bac-0c4372badd6a%2FScreenshot_2025-01-13_at_12.20.36.png?table=block&id=1fd261aa-09df-8102-91ca-d6828be38b3c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fdca052be-f2b2-43ff-9a1f-435b3fe030a1%2FScreenshot_2025-01-13_at_12.21.22.png?table=block&id=1fd261aa-09df-81f7-a506-f910ee62b365&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F7178ada7-dc46-4233-93ee-54ccc117ec3f%2FScreenshot_2025-01-13_at_12.31.14.png?table=block&id=1fd261aa-09df-8128-bc9b-f61a3300c63c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ffcc3bb98-aa4a-467f-bd7f-584af9bd2546%2FScreenshot_2025-01-13_at_12.32.00.png?table=block&id=1fd261aa-09df-8153-a4a0-c1213df5a4f7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2dae1a61-8793-4808-84d5-a4631a1a92de%2FScreenshot_2025-01-13_at_12.33.31.png?table=block&id=1fd261aa-09df-813c-bb48-d2d1e176e77f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Simulation results

Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3A300c896c-6372-46fb-aa39-c9253f3c0c8e%3Ad514d3c7-1a10-48e3-bd5f-8a58cfaece45.png?table=block&id=1fd261aa-09df-8120-a953-d447b3cd8a29&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A89076a08-7b62-458d-a06b-ab71b1ff41fd%3A5f797c88-3c00-4f99-80a8-7cf5965c3397.png?table=block&id=1fd261aa-09df-81f7-832c-e70f2a853d7a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that the number of samples $M$ in above figures is equivalent to the number of messages sent by a sender node.

## Communication on Branching Trees: two-variable failure model

### Assumptions

![](https://nomos-tech.notion.site/image/attachment%3A861aae8f-c975-41c8-b08c-d83810b5f81a%3A9d892dc3-270b-4657-8a44-27cdeaa152b7.png?table=block&id=1fd261aa-09df-81c5-90a3-eab6a373ac66&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We consider broadcast on a tree $\mathcal{T}_L$ (see figure above) constructed from nodes sampled (with replacement) from the $N$ nodes of the network. We assume that $M_F$ nodes in the network are “faulty” (faulty node is unable to relay a message) and the probability that a sampled node is faulty is $q_F=M_F/N$. We assume that $M_A$ nodes in the network are “adversarial” (Adversarial nodes are controlled by an adversary which can make nodes faulty, use them for traffic analysis, etc.) and the probability that a sampled node is adversarial is $q_A=M_A/N$.

We assume that the root node of $\mathcal{T}_L$ sends a message to all leaf nodes. The root node is labeled by $0$ and all leaf nodes constitute the set $\partial\mathcal{T}_L$. We assume that each node can fail to relay the message with probability $q_F$ independently from other nodes. We assume that a node can be adversarial with probability $q_A$ independently from other nodes.

Let us define the binary variable $\sigma_i\in\{0,1\}$ for a node $i$ in some communication path. A node is faulty/not-faulty when $\sigma_i=0/1$ with probability $q_F/(1-q_F)$. If the sum of all $\sigma_i$ variables of nodes on the path from the root $0$ to some leaf node $j$, $\sum_{k\in 0\rightarrow j\setminus0}\sigma_k$, is less than $L$, i.e. then there is at least one faulty node in this path. Hence, node $j$ did not receive the message, i.e. communication failure occurred. If all nodes in a communication path are non-faulty then this is a functioning communication path. If $\max_{j\in\partial\mathcal{T}_L}\sum_{k\in 0\rightarrow j\setminus0}\sigma_k<L$, i.e. each comm. path contains at least one faulty node, then all leaf nodes didn't receive the message, i.e. broadcast failure occurred.

Also we define the binary variable $s_i\in\{0,1\}$. A node is “honest/adversarial” when $s_i=0/1$ with probability $(1-q_A)/q_A$. If $\sum_{j\in\partial\mathcal{T}_L}\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}\sigma_k=L]\,\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}s_k\geq1]=\sum_{j\in\partial\mathcal{T}_L}\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}\sigma_k=L]$ and $\sum_{j\in\partial\mathcal{T}_L}\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}\sigma_k=L]\geq 1$, i.e. all functioning communication paths have at least one adversarial node, then adversary has opportunity to cause broadcast failure. If $\sum_{j\in\partial\mathcal{T}_L}\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}\sigma_k=L]\,\mathrm{1}[\sum_{k\in 0\rightarrow j\setminus0}s_k=L]\geq1$, i.e. there is at least one functioning communication paths where all nodes are adversarial, then adversary has opportunity to cause anonymity failure. We note that above definition of anonymity failure is equivalent to the event $\max_{j\in\partial\mathcal{T}_L}\sum_{k\in 0\rightarrow j\setminus0}\sigma_ks_k=L$. Here the $\sum_{k\in 0\rightarrow j\setminus0}\sigma_ks_k$ counts number of adversarial nodes on the path $0\rightarrow j$.

### Analysis of broadcast failure

The probability of broadcast failure is give by $\mathrm{P}_b=\left[1-\mathrm{P}_{L-1}\right]^b$, where the prob. $\mathrm{P}_{L-1}$ can be computed recursively (see the [Details of derivations](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8) section) as follows

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

The above equation has only one solution $\mathrm{P}_{\ell}=0$, which corresponds to prob. of broadcast failure being $1$, when $1-q_F<1/b$. However, the fixed point $\mathrm{P}_{\ell}=0$ becomes unstable when $1-q_F>1/b$ and a second (stable) solution $\mathrm{P}_{\ell}>0$, which corresponds to prob. of broadcast failure being less than $1$, emerges.

### Analysis of anonymity failure

The probability of anonymity failure is give by $\mathrm{P}_a=1-\left[1-\mathrm{P}_{L-1}\right]^b$, where $\mathrm{P}_{L-1}$ can be computed recursively (see the [Details of derivations](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8) section) as follows

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

The above equation has only one solution $\mathrm{P}_{\ell}=0$, which corresponds to prob. of anonymity failure being $0$, when $(1-q_F)\,q_A<1/b$. However, the fixed point $\mathrm{P}_{\ell}=0$ becomes unstable when $(1-q_F)\,q_A>1/b$ and a second (stable) solution $\mathrm{P}_{\ell}>0$, which corresponds to prob. of anonymity failure being greater than $0$, emerges.

From above follows that we would like to have $1-q_F>1/b$ and $(1-q_F)\,q_A<1/b$ as it allows us to make failure prob. arbitrarily small by increasing the number of layers $L$ . The latter gives us conditions for this in the inequalities $q_F<1-\frac{1}{b}=q_F(b)$ and $q_A <\frac{1}{b(1-q_F)}=q_A(b,q_F)$. The threshold $q_F(b)$ is increasing with the branching ratio $b$, i.e. $\mathrm{P}_b\rightarrow0$ when $L\rightarrow\infty$ for higher values of $q_F$, but the threshold $q_A(b,q_F)$ is decreasing with $b$, i.e. $\mathrm{P}_a\rightarrow0$ when $L\rightarrow\infty$ for lower values of $q_F$. Also $q_A(b,q_F)$ is increasing function of $q_F$.

### Analysis of adversarial broadcast-failure

We have exploited a recursive property of $\max$ on trees (see equation (48) in the [Details of derivations](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81a18261c4d16d5db8d8)) to derive expressions for the prob. of broadcast and anonymity failures, however if such recursive approach is possible in analysis of adversarial broadcast-failure is not clear. In particular we don’t know how to estimate probability of the event

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

analytically. However for $q_F=0$, i.e. there are no faulty nodes, we know from our[ earlier analysis](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df8157a67ce3aa45e41aa6) that the probability of adversarial broadcast failure $\mathrm{P}_{ab}$ is strictly less than $1$ as $L\rightarrow\infty$ when $q_A < 1-\frac{1}{b}$.

### Simulation results

Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3Ad16903de-3ab6-4442-a80f-8a70355e5611%3A05ba286c-97b0-4cfd-bedf-3e10b9f458bf.png?table=block&id=1fd261aa-09df-8184-8d09-d6511e0ec7fe&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Aa97817ba-a682-4b50-a52f-339e94d6ab32%3A3a51e28a-5c72-49d4-a1a3-fca1b38043ad.png?table=block&id=1fd261aa-09df-812b-869a-daef0e586c0a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Discussion of results for linear and branching tree designs: two-variable failure model

To compare linear and branching tree designs we assume that both have the same number of paths $b^L$, where $b$ is branching parameter and $L$ is the number of layers (see diagram of [linear trees](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81fdbde2c4cc3eaab976) and diagram of [branching tree](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81c590a3eab6a373ac66)). The differences between designs when above assumption is used were discussed [above](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25).

First, we consider the prob. of broadcast failure for values of $q_F$ below and above the threshold $q_F(b)$ plotted in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3A456844fd-2ca7-4413-9612-e6b0f6e49836%3AScreenshot_2025-01-31_at_12.54.49.png?table=block&id=1fd261aa-09df-813e-b721-f7882d2a16b7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=960&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For the branching parameter $b=2$ the prob. of broadcast failure, $\mathrm{P}_b$, in linear trees is smaller than in the branching trees as can be seen in the figure below. We note that in linear trees the prob. $\mathrm{P}_b\rightarrow0$ as $L\rightarrow\infty$ when $q_F<1/2$ and $\mathrm{P}_b\rightarrow1$ when $q_F>1/2$. The threshold $1/2$ follows from the condition $b(1-q_F)>1$, which ensures $\mathrm{P}_b\rightarrow0$, in the [linear trees analysis](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df8180a435ce3e9f937c9f).

![](https://nomos-tech.notion.site/image/attachment%3A3a4b667d-6651-4b08-bf2e-cddb5739bfdc%3AScreenshot_2025-01-31_at_12.37.21.png?table=block&id=1fd261aa-09df-819d-956d-e161fbf5ae4e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

However, the number of nodes involved in communication grows much faster in linear trees as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3Af5964ce4-84b2-4177-a8a9-b791b4239b2f%3AScreenshot_2025-01-31_at_12.49.43.png?table=block&id=1fd261aa-09df-81e7-9f61-cabed4681a86&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

As we increase the branching parameter $b$ the probability of broadcast failure is reduced for each number of layers $L$ as can be seen in the figure below

![](https://nomos-tech.notion.site/image/attachment%3Af2548243-0410-4b79-a30f-8459f24affab%3AScreenshot_2025-01-31_at_14.31.40.png?table=block&id=1fd261aa-09df-8115-8286-f437cd5d8d73&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

However, the number of nodes involved in communication is growing much faster with the number of layers $L$ for higher values of the branching parameter $b$ (cf. figure below and figure [above](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81e79f61cabed4681a86))

![](https://nomos-tech.notion.site/image/attachment%3Add10beca-1fdf-40b7-9e86-ed83f62d1c85%3AScreenshot_2025-01-31_at_14.32.37.png?table=block&id=1fd261aa-09df-8165-ae88-cd3cccf49a8e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Second, we consider the prob. of anonymity failure for values of $q_A$ below and above the threshold $q_A(b,q_F)$ plotted in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3A3d9fa2bb-10f5-4397-8a1a-a1a2d806efcb%3AScreenshot_2025-01-31_at_14.58.38.png?table=block&id=1fd261aa-09df-81fa-a9c5-e5b41ffafd97&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

For the branching parameter $b=2$ the prob. of anonymity failure, $\mathrm{P}_a$, in linear trees is higher than in the branching trees as can be seen in the figure below. We note that in linear trees the prob. $\mathrm{P}_a\rightarrow0$ as $L\rightarrow\infty$ when $q_A<1/1.8$ and $\mathrm{P}_a\rightarrow1$ when $q_A>1/1.8$. The threshold $1/1.8$ follows from the condition $b(1-q_F)q_A<1$, which ensures $\mathrm{P}_a\rightarrow0$, in the [linear trees analysis](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df81de9a84f2296b8ffa22). For branching trees we have $\mathrm{P}_a\rightarrow0$ as $L\rightarrow\infty$ when $q_A<1/1.8$ but $\mathrm{P}_a<1$ when $q_A>1/1.8$.

![](https://nomos-tech.notion.site/image/attachment%3A52f69243-adef-4275-a246-383c3c234d2e%3AScreenshot_2025-01-31_at_15.01.18.png?table=block&id=1fd261aa-09df-81f7-8807-f387b1b80248&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

As we increase $q_F$ the probability of anonymity failure is reduced for each number of layers $L$ as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3Aed36edf6-5f57-4df3-be17-7ff2145a1907%3AScreenshot_2025-02-03_at_11.38.24.png?table=block&id=1fd261aa-09df-8157-9b5e-fa06a6df03e1&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3A0c951390-7a56-4237-9e3d-e17b174d6eef%3AScreenshot_2025-02-03_at_11.44.27.png?table=block&id=1fd261aa-09df-8107-9bcd-f9efbf5dff7d&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

As we increase the branching parameter $b$ the probability of anonymity failure is increased for each number of layers $L$ as can be seen in figures below

![](https://nomos-tech.notion.site/image/attachment%3A36fbae2c-90ae-4bd9-95f0-b0df59565e6d%3AScreenshot_2025-02-03_at_12.17.52.png?table=block&id=1fd261aa-09df-8102-a5b7-d89ada27b542&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ae802f6ef-9d4f-497c-a354-390dd5d5a233%3AScreenshot_2025-02-03_at_12.23.08.png?table=block&id=1fd261aa-09df-814d-9266-c8b08831b9b5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Acb9b15ee-452f-489c-8dfa-89c60806654e%3AScreenshot_2025-02-03_at_12.35.32.png?table=block&id=1fd261aa-09df-81b0-aa40-ccfa939902e6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Finally, we consider the prob. of adversarial broadcast failure $\mathrm{P}_{ab}$. Here for branching trees we have only simulation results and we compare the latter with analytic results for linear trees. We note that in linear trees the prob. $\mathrm{P}_{ab}\rightarrow0$ as $L\rightarrow\infty$ when $b\,(1-q_F)(1-q_A)>1$ and $\mathrm{P}_{ab}\rightarrow1$ when $b\,(1-q_F)(1-q_A)<1$ and $b\,(1-q_F)>1$ (see the [linear trees analysis](https://nomos-tech.notion.site/1fd261aa09df81bbb79ecb2bf3fcf209?pvs=25#1fd261aa09df813799b4dae2e771b34c)). The latter gives us $q_F<1-1/b$, i.e. the condition for the prob. of broadcast failure $\mathrm{P}_b\rightarrow0$ in linear and branching trees. For the branching parameter $b=2$ the prob. of adversarial broadcast failure, $\mathrm{P}_{ab}$, in linear trees is higher than in the branching trees as can be seen in the figure below.

![](https://nomos-tech.notion.site/image/attachment%3Ab4f5acb4-aff8-4f6c-b7ef-2efb89a61ec8%3AScreenshot_2025-02-04_at_12.27.34.png?table=block&id=1fd261aa-09df-8146-974c-d514e731b789&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=970&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](https://nomos-tech.notion.site/image/attachment%3Ac3f1fb7d-7c79-4f91-adde-78ce1d92454c%3AScreenshot_2025-02-04_at_19.01.32.png?table=block&id=1fd261aa-09df-8127-8bb8-e8e2b41e5ff9&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=990&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Appendix

## Details of derivations

> **PDF attachment** (link not captured by the Notion scrape).

