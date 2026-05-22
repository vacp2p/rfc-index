# ANALYSISLATENCY

| Field | Value |
| --- | --- |
| Name | [Analysis] Latency |
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
| 1.0.0 | Initial revision. | 2026-03-20 |

## Introduction

We consider latency of a broadcast on the network constructed from mix nodes which use [queues](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25) to store in-coming and out-going messages. A message is removed from the queue with probability $q$ which delays messages by a random amount of time governed by the Geometric distribution with parameter $q$ . The other source of message delays are due to the latency in communication links which we assume to be “frozen”, i.e. not changing with time. We show that for a single path constructed from $k$ mix nodes the average message latency is proportional to $k/q$ and we estimate the probability of latency being greater than the average. Furthermore, we consider latency of a broadcast on the network with the topology of a random regular graph with connectivity $c$ . Here we find that the latency of broadcast, divided by $\log(N)$ , is approaching $\frac{2(c-1)}{c(c-2)}\frac{1}{\log(1+q)}$ for a small probability of message removal $q$ as the number of nodes in the network $N$ is growing. However, for finite $N$ the distribution of latency can have long tails. We note that the latter result is established semi-analytically and only for trees we managed to develop a complete analytical framework which can be used to compute the latency of a broadcast. Finally, in this document we propose a simple model of communication latency in consensus.

## Analysis

### Single Node

Assuming that a message is removed from the queue of a node with probability $q$ (see the [document](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25)), a message in node $i$ is delayed by (at most) $r\_i\Delta\_i$ , where $r\_i$ is a random variable from the Geometric distribution with parameter $q$ and $\Delta\_i$ is a “cost” of one attempt of removing a message.

Assuming that node $i$ has $c$ connections and it puts a message into all out-queues associated with these connections, i.e. the node $i$ is sending a message. The message will be delayed by (at most) $r\_i(1)\Delta\_i$ in the queue $1$ , by $r\_i(2)\Delta\_i$ in the queue $2$ , etc., where $r\_i(1),\ldots,r\_i(c)$ is sample from the Geometric distr. with parameter $q$ .

Assuming that node $i$ has $c$ connections and it puts a message into all out-queues but not the queue associated with the connection labelled by $c$ , i.e. the node is relaying a message, the message will be delayed by (at most) $r\_i(1)\Delta\_i$ in the queue $1$ , by $r\_i(2)\Delta\_i$ in the queue $2$ , etc., where $r\_i(1),\ldots,r\_i(c-1)$ is sample from the Geometric distr. with parameter $q$ .

### Single Path

Without loss of generality, we consider a message traveling from node $1$ to node $k$ . A message is delayed at the node $1$ by $r\_1\Delta\_1$ , at the node $2$ by $r\_2\Delta\_2$ , etc. For node $i$ we assume that $r\_i$ is a random variable from the Geometric distribution with parameter $q$ and that $\Delta\_i>0$ . The latter is prop. to a max. time elapsed between attempts to “flip a coin”. Furthermore, a message traveling between the nodes $i$ and $j$ is delayed by $d\_{ij}$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F013ef215-15a4-430a-b311-43fd396c6406%2Fk-path-delay.png?table=block&id=1fd261aa-09df-8109-bdc3-ce8b91179527&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Using above the total delay is given by $\sum\_{i=1}^kr\_i\Delta\_i+ \sum\_{i=1}^{k-1}d\_{ii+1}$ . We note that for $\Delta=\max\_{i\in[k]}\Delta\_i$ and $d=\max\_{i\in[k-1]}d\_{ii+1}$ we have

$$
\sum\_{i=1}^kr\_i\Delta\_i+ \sum\_{i=1}^{k-1}d\_{ii+1}\leq \Delta\sum\_{i=1}^kr\_i+ (k-1)d
$$
i=1∑k​ri​Δi​+i=1∑k−1​dii+1​≤Δi=1∑k​ri​+(k−1)d

The sum $r=\sum\_{i=1}^kr\_i$ is random variable from the negative binomial distribution

$$
P\_{k,q}(r)={r-1\choose k-1}q^k(1-q)^{r-k},\mathrm{where}\,\, r\in\{k,k+1,\ldots\}.
$$
Pk,q​(r)=(k−1r−1​)qk(1−q)r−k,wherer∈{k,k+1,…}.

Using that $r\_i$ is a random variable from the Geometric distribution with parameter $q$ the average and variance of the total delay $\sum\_{i=1}^kr\_i\Delta\_i+ \sum\_{i=1}^{k-1}d\_{ii+1}$ is given, respectively, by $\sum\_{i=1}^k\Delta\_i/q+ \sum\_{i=1}^{k-1}d\_{ii+1}$ and $\frac{1-q}{q^2}\sum\_{i=1}^k\Delta^2\_i$ . The latter, for $\Delta=\Delta\_i$ and $d=d\_{ii+1}$ , is simplifies to $k\Delta/q+ (k-1)d$ and $\frac{1-q}{q^2}k\Delta^2$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F3c2fe8c0-504b-42ed-9664-892feb5f484e%2FScreenshot_2024-07-24_at_17.34.49.png?table=block&id=1fd261aa-09df-81f2-9a1c-e10d0112a61c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The histogram of delays $\sum\_{i=1}^kr\_i\Delta\_i+ \sum\_{i=1}^{k-1}d\_{ii+1}$ of $N\_m=10^6$ messages traveling through $k=5$ nodes (red histogram bars) is compared with negative binomial (o symbols) with parameters $k=5$ and $q=1/2$ . Here we assumed that $\Delta\_i=1$ and $d\_{ii+1}=0$ .

ALT

The mean of sum $\sum\_{i=1}^kr\_i$ is equals to $k/q$ . For $\epsilon>0$ the probability $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)$ can bounded from above as follows

$$
\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)\leq\left(\frac{q \left(\epsilon -1\right)+1}{1-q}\right)^{k} \left(\frac{q \left(\epsilon -1\right)+1}{\left(1-q \right) \left(\epsilon q +1\right)}\right)^{-\frac{k \left(1+\epsilon \right)}{q}}
$$
P(i=1∑k​ri​≥(1+ϵ)k/q)≤(1−qq(ϵ−1)+1​)k((1−q)(ϵq+1)q(ϵ−1)+1​)−qk(1+ϵ)​

To show the above we used $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)=\mathrm{P}\left(\mathrm{e}^{\lambda\sum\_{i=1}^kr\_i}\geq \mathrm{e}^{\lambda(1+\epsilon)k/q}\right)$ for any $\lambda>0$ and Markov’s inequality.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F47c901a7-f83f-4ec2-8b0a-7cf3371b90ee%2FScreenshot_2024-07-29_at_13.15.54.png?table=block&id=1fd261aa-09df-81c5-9635-d2b020ed4146&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The prob. $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=1/2$ and $\epsilon=1$ . Here the simulation (red + symbols) is compared with the [upper bound](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81578ed2e637fc724d10) (blue square symbols). In simulation the prob. distr. of $\sum\_{i=1}^kr\_i$ was represented by $N=10^6$ samples of random variables $r\_1,\ldots,r\_k$ generated from the Geometric distribution with parameter $q$ .

ALT

The probability $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)$ is increasing with decreasing $q$ for $q<1/2$ ​

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F18a470cb-61f2-45f3-9efb-c3e9f80c3965%2FScreenshot_2024-07-29_at_13.12.19.png?table=block&id=1fd261aa-09df-8111-9f95-de9b603ff42b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The prob. $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=1/4$ and $\epsilon=1$ . Here the simulation (red + symbols) is compared with the [upper bound](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81578ed2e637fc724d10) (blue square symbols). In simulation the prob. distr. of $\sum\_{i=1}^kr\_i$ was represented by $N=10^6$ samples of random variables $r\_1,\ldots,r\_k$ generated from the Geometric distribution with parameter $q$ .

ALT

and decreasing with increasing $q$ for $q>1/2$

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F10a16762-a53e-42b2-b207-35f6dd413b6c%2FScreenshot_2024-07-29_at_13.14.07.png?table=block&id=1fd261aa-09df-813d-8d29-db9b3b622edc&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The prob. $\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=3/4$ and $\epsilon=1$ . Here the simulation (red + symbols) is compared with the [upper bound](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81578ed2e637fc724d10) (blue square symbols). In simulation the prob. distr. of $\sum\_{i=1}^kr\_i$ was represented by $N=10^6$ samples of random variables $r\_1,\ldots,r\_k$ generated from the Geometric distribution with parameter $q$ .

ALT

We note that the [upper bound](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81578ed2e637fc724d10) can be represented as

$$
\mathrm{P}\left(\sum\_{i=1}^kr\_i\geq (1+\epsilon)k/q\right)\leq f^k(q,\epsilon)\mathrm{, where}\\ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~f(q,\epsilon)=\left(\frac{q \left(\epsilon -1\right)+1}{1-q}\right) \left(\frac{q \left(\epsilon -1\right)+1}{\left(1-q \right) \left(\epsilon q +1\right)}\right)^{-\frac{ \left(1+\epsilon \right)}{q}} .
$$
P(i=1∑k​ri​≥(1+ϵ)k/q)≤fk(q,ϵ),where                                         f(q,ϵ)=(1−qq(ϵ−1)+1​)((1−q)(ϵq+1)q(ϵ−1)+1​)−q(1+ϵ)​.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2a7892f1-e643-4c14-a1f2-62e99e5b2cba%2Ff_q_eps.png?table=block&id=1fd261aa-09df-810f-b0df-fcf9e6fbacb0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=590&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

$f(q,\epsilon)$ as a function of $q$ and $\epsilon$ .

ALT

Plotting $f(q,\epsilon)$ suggests that the upper bound is monotonic decreasing function of $k$ , $\epsilon$ and $q$ .

### Random Networks

#### Configuration Model

Let us consider the probability distribution $\mathrm{P}(c)$ over the non-negative integers $c\geq0$ such that $\sum\_{c\geq0}\mathrm{P}(c)\,c<\infty$ and define the probability distribution

$$
\mathrm{Q}(c)=\frac{c\,\mathrm{P}(c)}{\sum\_{\tilde{c}\geq0}\tilde{c}\,\mathrm{P}(\tilde{c})}
$$
Q(c)=∑c~≥0​c~P(c~)cP(c)​

We consider the random rooted tree generated as follows. First, we sample $c$ from the distr. $\mathrm{P}(c)$ and connect the root node to $c$ offspring nodes. Second, for each offspring node we sample $c$ from the distr. $\mathrm{Q}(c)$ and connect to $c-1$ nodes. The latter is repeated until the tree $\mathcal{T}(h)$ of height $h$ is generated.

We consider the random graph $G\_N=(V\_N,E\_N)$ , where $V\_N=[N]$ is the set of nodes and $E\_N$ is the set of edges, generated by connecting nodes with connectivities sampled from the probability distribution $\mathrm{P}(c)$ , i.e. the [“configuration model”.](https://en.wikipedia.org/wiki/Configuration_model)

For $N\rightarrow\infty$ we have that $B\_i(h)\simeq\mathcal{T}(h)$ , where $B\_i(h)$ is the subgraph of $G\_N$ induced by nodes at a distance (length of shortest path between two nodes) at most $h$ from the node $i\in[N]$ , with [high probability](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81eda385ced4c5493781).

A special case $G\_N$ is a random regular graph (RRG) of connectivity $c$ , i.e. each node in $G\_N$ is connected to exactly $c$ nodes.

#### Distance on a graph and latency of a broadcast

Let us assume, without loss of generality, that node $1$ in this network wants to send a message to the all $N-1$ nodes of network.

A node puts a message in to all of its out-queues. Assuming that coin-flipping algorithm is used to remove a message from the queue, we have that a message is delayed by (at most) $r\Delta\_1$ (see previous [section](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df812a963bfdb9a383cf43)), where $r$ random variable from the [Geometric distribution](/1fd261aa09df81dcb90bdad3e6d88b21?pvs=25) with parameter $q$ . A message is delayed further in a communication link and hence, for example, a message sent from the node $1$ to the node $2$ is delayed (at most) by $r\_{12}\Delta\_1+d\_{12}$ . We note that copies of the same message, sent to other neighbours of node $1$ , are delayed in a similar manner.

For node $i$ sending a message to its neighbour $j$ the delay is $r\_{ij}\Delta\_i+d\_{ij}$ .

The total delay of a message sent from the node $1$ to the node $i\in[N]\setminus1$ is the sum of delays

$$
\sum\_{(i,j)\in 1\rightarrow i}\{r\_{ij}(1) \Delta\_i+d\_{ij}\}
$$
(i,j)∈1→i∑​{rij​(1)Δi​+dij​}

along the (directed) path from node $1$ to node $i$ , $1\rightarrow i$ .

Let us define the distance between node 1 and node $i\in[N]\setminus1$ as the

$$
D\_{1\rightarrow i}[G\_N]=\min\_{1\rightarrow i}\sum\_{(i,j)\in 1\rightarrow i}\{r\_{ij}(1) \Delta\_i+d\_{ij}\}
$$
D1→i​[GN​]=1→imin​(i,j)∈1→i∑​{rij​(1)Δi​+dij​}

i.e. the minimum total delay over all (directed) paths from node 1 to node i.

Now the maximum distance

$$
\max\_{i\in[N]\setminus1} D\_{1\rightarrow i}[G\_N]=\max\_{i\in[N]\setminus1}\min\_{1\rightarrow i}\sum\_{(i,j)\in 1\rightarrow i}\{r\_{ij}(1) \Delta\_i+d\_{ij}\}
$$
i∈[N]∖1max​D1→i​[GN​]=i∈[N]∖1max​1→imin​(i,j)∈1→i∑​{rij​(1)Δi​+dij​}

i.e. the maximum over distances between node $1$ and all other nodes, is the time that elapsed from the event “node $1$ sent a message” to the event “the message was delivered to all nodes”.

Thus $\max\_{i\in[N]\setminus1} D\_{1\rightarrow i}[G\_n]$ is the latency of broadcast from node $1$ . Let us define the latter as

$$
\mathcal{L}\_1[G\_N]=\max\_{i\in[N]\setminus1} D\_{1\rightarrow i}[G\_N]
$$
L1​[GN​]=i∈[N]∖1max​D1→i​[GN​]

We note that maximum distance can be computed using [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#:~:text=Dijkstra%27s%20algorithm%20(%2F%CB%88da%C9%AA,and%20published%20three%20years%20later.).

Finally, for all pairs of distinct nodes we define the diameter of $G\_N$ as follows

$$
\mathcal{D}[G\_N]=\max\_{i\neq j} D\_{i\rightarrow j}[G\_N]
$$
D[GN​]=i=jmax​Di→j​[GN​]

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0a4ec471-d769-49b8-b692-531ce87075e1%2Fbroadcast-channel.png?table=block&id=1fd261aa-09df-81e1-932a-c0c873f2b808&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

A single message is sent from node $1$ to all $N-1$ nodes of the network. The latter has topology of a random regular graph of connectivity $c=3$ which is locally tree-like for large $N$ . The total delay of a message sent from node $1$ to node $4$ , via the nodes $2$ and $3$ , is given by the sum $\sum\_{j=2}^4[ r\_{j-1j}\Delta\_{j-1}+d\_{j-1j}]$ .

ALT

#### Results for a High Connectivity Regime

We consider networks with topology of a random regular graph in the high connectivity regime of $c=\alpha N$ , where $\alpha\in (0,1)$ , with $\Delta\_i=1$ and $d\_{ij}=0$ .

First we consider the case of $c=N-1$ , i.e. the network is a complete graph, where the least latency is expected. Measuring the latency of broadcast for $N=\{10,10^2,10^3\}$ , we see that it is increasing as $q\rightarrow0$ and decreasing as $q\rightarrow1$ as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ffbfc94c8-55b0-47c6-a015-75fe9ca02fe8%2F7552_latency.png?table=block&id=1fd261aa-09df-81f5-9cb3-eb2cb6e173eb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Statistics of message latencies computed for the number of messages $M\in\{10^5,10^6\}$ (bottom, top and middle) broadcasted on the network of $N\in\{10, 10^2, 10^3\}$ nodes. The latter has the topology of a complete graph. The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$ . The black dashed horizontal line corresponds to $2$ . The blue dashed horizontal line corresponds to $0$ .

ALT

Furthermore, as $N$ is increased from $N=10$ to $N=10^3$ the latency of broadcast becomes more concentrated on the value of 2 as can be seen in figures below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F831f5e81-13a4-4299-9d60-52b3278996cc%2F4910_latency_hist.png?table=block&id=1fd261aa-09df-81a8-bb3b-d4048c885aa0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The histogram of message latencies computed for the $M\in\{10^5,10^6\}$ (top and middle, bottom) messages broadcasted for the network of $N=\{10,10^2,10^3\}$ nodes. The latter has topology of a complete graph. The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with the parameter $q=\{1/10, 1/2,9/10\}$ (left, middle, right).

ALT

Finally, we consider random regular graph in the high connectivity regime of $c=\alpha N$ , where $\alpha\in (0,1)$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F1451a5f4-6cda-48cc-bb16-956113e29234%2F9123515c-56f3-49eb-b278-ff3865c0c91a.png?table=block&id=1fd261aa-09df-8186-ad5c-f01297023e24&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1600&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Statistics of message latencies computed for $M\in\{10^5,10^6\}$ (bottom, top and middle) messages broadcasted on the network of $N\in\{10, 10^2, 10^3\}$ nodes. The latter has topology of a random regular graph with connectivity $N/2$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$ . The black dashed horizontal line corresponds to $2$ . The blue dashed horizontal line corresponds to $0$ .

ALT

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F193ca3e9-4d42-466a-99d8-302f98845d2e%2F11ed4881-e9f8-433b-a5b0-f618b9135c6e.png?table=block&id=1fd261aa-09df-815b-8d52-d720953cfe09&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1790&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The histogram of message latencies computed for the $M\in\{10^5,10^6\}$ (top and middle, bottom) messages broadcasted for the network of $N=\{10,10^2,10^3\}$ nodes. The latter has topology of a random regular graph of connectivity $N/2$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with the parameter $q=\{1/10, 1/2,9/10\}$ (left, middle, right).

ALT

#### Results for a Finite Connectivity Regime

We consider broadcast on networks with topology of a random regular graph in the finite connectivity regime of $c\ll N$ with $\Delta\_i=1$ and $d\_{ij}=0$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0b8a8800-d227-4928-a9d5-98235b2bd183%2FScreenshot_2024-09-03_at_12.25.01.png?table=block&id=1fd261aa-09df-811b-ade7-e462828efc7c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ff9b00a6b-2a41-4246-b187-5ff47f5f86fa%2FScreenshot_2024-09-03_at_12.26.49.png?table=block&id=1fd261aa-09df-8134-8947-e8edefe98d63&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Top: Statistics of message latencies computed for the number of messages $M=10^5$ broadcasted on the network of $N=10^3$ nodes. The latter has topology of a random regular graph with connectivity $c=4$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$ . Bottom: The histogram of message latencies computed for $q=\{1/10, 1/2,9/10\}$ (left, middle, right).

ALT

Dividing the latency of broadcast by $\log(N)$ suggests that the latter is converging to some value, dependent on $q$ and connectivity $c$ , as $N\rightarrow\infty$ as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6cbe78f5-4be8-4a0c-8b7f-fed2279d059f%2FScreenshot_2024-09-09_at_10.28.54.png?table=block&id=1fd261aa-09df-8153-8ba1-c2c82131d99c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The average latency of broadcast $\pm$ standard deviation (divided by $\log(N)$ ) plotted as a function of network size $N$ for $q\in\{1/10, 1/2, 9/10\}$ (left, middle, right). The number of messages broadcasted is $M=10^4$ . The network has topology of a random regular graph with connectivity $c=4$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q$ .

ALT

For $q\rightarrow0$ distribution of the random variable $q\,r\_{ij}$ , where $r\_{ij}$ is sampled from the geometric distribution with parameter $q$ , is exponential distribution with parameter $1$ . The latter follows from the properties of the [Geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution).

Furthermore, the [latency of broadcast](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df814ab1e5dfa271da02ef), $\mathcal{L}\_1[G\_N]$ , for delays sampled from the exponential distribution with parameter $1$ and $N\rightarrow\infty$ is

$$
\frac{\mathcal{L}\_1[G\_N]}{\log(N)}\xrightarrow{\text{Prob.}}
\frac{1}{c-2}+\frac{1}{c},
$$
log(N)L1​[GN​]​Prob.​c−21​+c1​,

i.e. the latency of broadcast is $\frac{2(c-1)}{c(c-2)}\log(N)$ [with](https://projecteuclid.org/journals/annals-of-applied-probability/volume-25/issue-3/The-diameter-of-weighted-random-graphs/10.1214/14-AAP1034.full) [high probability](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81f3a1f2df61373d6e04) when $N$ is large.

The above two points suggest that for small $q$ , the latency of broadcast is approximately $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ when $r\_{ij}$ are sampled from the geometric distribution with parameter $q$ , i.e. the latency of broadcast is diverging as $q\rightarrow0$ . The latter is consistent with latency measured in [simulations](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df811bade7e462828efc7c).

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F780b2449-ba5e-48b8-a214-e0b25283642e%2FScreenshot_2024-09-09_at_14.23.13.png?table=block&id=1fd261aa-09df-817e-912f-c5380a0691c2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Statistics of message latencies computed for the number of messages $M=10^5$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c=4$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$ . The dashed black line is the function $\frac{2c-2}{c(c-2)}\frac{\log(N)}{q}$ .

ALT

For larger values of q, the average latency of broadcast computed numerically deviates from the asymptotic $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ as can be seen in the figure above.

We note that the (asymptotic) latency of broadcast $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ is a special case of $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{f(q)}$ for some (unknown) function $f(q)$ .

Assuming that the latency of broadcast $\mathcal{L}\_1[G\_N]=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{f(q)}$ , with high prob. as $N\rightarrow\infty$ , and inverting this expression gives us $f(q)= \frac{2(c-1)}{c(c-2)}\frac{\log(N)}{ \mathcal{L}\_1[G\_N]}$ . Using the [data](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df817e912fc5380a0691c2) to plot the latter suggests the form $f(q)=\alpha\log(1+q)$ for some parameter $\alpha>0$ as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F93c1ccd5-8abb-4418-986b-f4de93e8b67e%2FScreenshot_2024-09-10_at_17.02.02.png?table=block&id=1fd261aa-09df-8103-9995-f3f4e442c2f5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The function $f(q)=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{ \mathcal{L}\_1[G\_N]}$ as function of $q$ . Solid line is $f(q)=q$ and dashed line is $f(q)=\alpha\log(1+q)$ with $\alpha=0.95$ . Here for the broadcast latency $\mathcal{L}\_1[G\_N]$ the (empirical) mean from the [figure](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df817e912fc5380a0691c2) was used.

ALT

We note that for $f(q)=\alpha\log(1+q)$ we have $f(q)= \alpha\,(q-q^2/2+O(q^3))$ as $q\rightarrow0$ .

Furthermore, fitting $\mathcal{L}\_1[G\_N]=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ to the mean of [data](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df817e912fc5380a0691c2) gives us

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F3dfe8b3f-d35f-4607-beb0-131e552c3161%2FScreenshot_2024-09-10_at_21.38.51.png?table=block&id=1fd261aa-09df-81af-92dc-e769c066daf2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The mean latency of broadcast (+ symbols), computed from the [data](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df817e912fc5380a0691c2), is explained by $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ (dashed line). Here the value of $\alpha$ , obtained by fitting, is $0.9534770$ .

ALT

Testing the expression $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ for the mean value of broadcast obtained numerically suggests that the latter is accurate when the connectivity $c$ and q are small but significantly diverges from the data when $c$ and $q$ are large as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F4f54e665-3f7d-4bd7-9dee-a085cac78d4f%2FScreenshot_2024-09-16_at_10.00.45.png?table=block&id=1fd261aa-09df-8117-80cd-f85d63fddce3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The mean latency of broadcast, represented by symbols, as a function of $q$ computed for the number of messages $M=10^4$ broadcasted on the network of $N=10^4$ nodes. The latter has topology of a random regular graph with connectivity $c\in\{3,5,8,13,21,34\}$ (top to bottom). The lines were obtained by fitting the $\alpha$ parameter in the expression $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q$ .

ALT

The probability that the latency of broadcast is greater than some threshold $t$ decreases with the connectivity $c$ as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0f621a59-7dcc-4cb2-8260-c13f13ce57ec%2FScreenshot_2024-09-23_at_13.28.26.png?table=block&id=1fd261aa-09df-81ea-b0f9-fac097fa63c8&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c\in\{3,4,7,11\}$ (top to bottom). The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$ .

ALT

We note that random regular graph is [locally tree-like](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81eda385ced4c5493781), i.e. when $N$ is large any node is a root of a tree of some height $h$ with high probability.

For the node connectivity $c>2$ the number of nodes in the tree of height $h$ , rooted at node $1$ , is given by

$$
1+c+c(c-1)+c(c-1)^2+\cdots+c(c-1)^{h-1}=1+c\frac{(c-1)^{h}-1}{c-2}.
$$
1+c+c(c−1)+c(c−1)2+⋯+c(c−1)h−1=1+cc−2(c−1)h−1​.

In above we assumed that root node has $c$ children and every internal node has $c-1$ children (see [figure](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81e1932ac0c873f2b808)).

For $N$ nodes, the minimum $h$ such that $N\leq1+c\frac{(c-1)^{h}-1}{c-2}$ is given by

$$
\left\lceil\frac{\log\left(\frac{N(c - 2) + 2}{c}\right)}{\log(c - 1)}\right\rceil
$$
​log(c−1)log(cN(c−2)+2​)​​

The latency of broadcast on a tree of $N$ nodes is expected to be higher than on random regular with the same $N$ and the same connectivity $c$ . This is due to the presence of loops in the latter.

The numerical results for (average) latency of broadcast on a tree of $N$ nodes suggest that this average is an upper bound on the average latency of broadcast on on random regular with the same $N$ and the same connectivity $c$ as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0b27c6ed-ffc2-48a3-b7bb-2216234d96c9%2FScreenshot_2024-09-28_at_09.06.48.png?table=block&id=1fd261aa-09df-81f6-be83-dc48ad28ff08&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The average latency of broadcast as a function of connectivity $c$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c$ or of a balanced complete tree, rooted at node 1, with the same $N$ and $c$ . The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$ .

ALT

Furthermore, numerical results for latency of broadcast on trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9619b896-d06a-4025-875e-41563ddc2666%2FScreenshot_2024-09-23_at_13.54.02.png?table=block&id=1fd261aa-09df-819b-abe1-c72b63e27281&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c=4$ or of a balanced complete tree rooted at node 1. The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$ .

ALT

We note that the latency of broadcast on a tree of finite size is equivalent to the latency of broadcast in finite neighbourhood of a sender node in large random regular graph. In the latter, as $N\rightarrow\infty$ the finite neighbourhood of a node is (with high prob.) a Cayley tree (see figure below) up to some distance, measured in by number edges between the node and any other node.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Faaf7c477-da06-4466-afd6-2e361f1a46f5%2FScreenshot_2024-09-30_at_11.27.43.png?table=block&id=1fd261aa-09df-81e1-b50e-f57550e2e255&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The neighbourhood of node $1$ in a very large random regular graph of connectivity $c=3$ . The weights in the latter are independent random variables from geometric distribution with parameter $q=1/2$ .

ALT

The numerical results for latency of broadcast on Cayley trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F26f68811-b1c2-4c89-9d1e-2af30e19374c%2FScreenshot_2024-09-30_at_11.42.28.png?table=block&id=1fd261aa-09df-81d9-9901-f16358cafad4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N\in\{94, 190, 382, 766, 10^3, 1534\}$ nodes. The latter for $N=10^3$ has the topology of a random regular graph with connectivity $c=4$ and for $N\neq10^3$ is a Cayley tree rooted at node 1. The delay model, for a message sent from node $i$ to its neighbours $j$ , used is $r\_{ij}\Delta\_i+d\_{ij}$ , where $\Delta\_i=1$ , $d\_{ij}=0$ and $r\_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$ .

ALT

The latency of broadcast on a tree can be computed iteratively. The latter uses the property

$$
\max\{J\_1+J\_2,J\_1+J\_3\}=J\_1+\max\{J\_2,J\_3\},\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\text{where } J\_i>0.
$$
max{J1​+J2​,J1​+J3​}=J1​+max{J2​,J3​},                                                                                   where Ji​>0.

To show this we consider the latency of broadcast on a tree of $N$ nodes $\mathcal{T}\_N$ rooted at node $1$ (see [figure](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81e1932ac0c873f2b808)) as follows.

First, we define the latency of communication a message, sent from node $1$ to all nodes in $\mathcal{T}\_N$ , when it is relayed from the node $i$ to $j$ as $J\_{ij}(1)=r\_{ij}(1) \Delta\_i+d\_{ij}$ then the latency of broadcast

$$
\mathcal{L}\_1[\mathcal{T}\_N]=\max\_{i\in[N]\setminus1} D\_{1\rightarrow i}[\mathcal{T}\_N]\\~~~~~~~~~~~~~~~~~~~~~~~~~~~=\max\_{i\in[N]\setminus1}\min\_{1\rightarrow i}\sum\_{(i,j)\in 1\rightarrow i}J\_{ij}(1)\\~~~~~~~~~~~~~~~~~~~~=\max\_{i\in[N]\setminus1}\sum\_{(i,j)\in 1\rightarrow i}J\_{ij}(1)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\max\_{i\in \partial\mathcal{T}\_N}\sum\_{(i,j)\in 1\rightarrow i}J\_{ij}(1)\text{, where }\partial\mathcal{T}\_N\text{ is the set }\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \text{of leaf nodes}
$$
L1​[TN​]=i∈[N]∖1max​D1→i​[TN​]                           =i∈[N]∖1max​1→imin​(i,j)∈1→i∑​Jij​(1)                    =i∈[N]∖1max​(i,j)∈1→i∑​Jij​(1)                                                         =i∈∂TN​max​(i,j)∈1→i∑​Jij​(1), where ∂TN​ is the set                                                                                        of leaf nodes

Second, we consider the latency of broadcast

$$
\mathcal{L}\_1[\mathcal{T}\_N]=\max\_{i\in \partial\mathcal{T}\_N}\sum\_{(i,j)\in 1\rightarrow i}J\_{ij}(1)\\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~=\max\_{i\in\partial1}\left\{J\_{1i}(1)+\max\_{k\in \partial\mathcal{T}\_N}D\_{i\rightarrow k}[\mathcal{T}\_N]\right\},\\~~~~~~~~~~~~~~~~~~~~~~~~~~~\text{ where } D\_{i\rightarrow k}[\mathcal{T}\_N] \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\text{ is the distance from } i \text{ to } k
$$
L1​[TN​]=i∈∂TN​max​(i,j)∈1→i∑​Jij​(1)                                    =i∈∂1max​{J1i​(1)+k∈∂TN​max​Di→k​[TN​]},                            where Di→k​[TN​]                                                                           is the distance from i to k

Now the maximum distance from node $i$ to a leaf node $k$ , $\max\_{k\in \partial\mathcal{T}\_N}D\_{i\rightarrow k}[\mathcal{T}\_N]$ , can be computed as follows

$$
\max\_{k\in \partial\mathcal{T}\_N}D\_{i\rightarrow k}[\mathcal{T}\_N]=\max\_{j\in\partial i\setminus1}\left\{J\_{ij}(1)+\max\_{k\in \partial\mathcal{T}\_N}D\_{j\rightarrow k}[\mathcal{T}\_N]\right\}
$$
k∈∂TN​max​Di→k​[TN​]=j∈∂i∖1max​{Jij​(1)+k∈∂TN​max​Dj→k​[TN​]}

Furthermore, if node $j$ is adjacent only to leaf nodes but one then

$$
\max\_{k\in \partial\mathcal{T}\_N}D\_{j\rightarrow k}[\mathcal{T}\_N]=\max\_{k\in\partial j\setminus i}\{J\_{jk}(1)\}
$$
k∈∂TN​max​Dj→k​[TN​]=k∈∂j∖imax​{Jjk​(1)}

For node $j$ not adjacent to leaf nodes the $\max\_{k\in \partial\mathcal{T}\_N}D\_{j\rightarrow k}[\mathcal{T}\_N]$ can be computed via equation similar to the [equation](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81ab9edbfb2cdd64da4c). The latter suggests that the latency of broadcast $\mathcal{L}\_1[\mathcal{T}\_N]$ can be computed recursively using above equations and numerical complexity of this computation is $O(N)$ . This is better than $O(N\log N)$ when Dijkstra's algorithm is used to compute $\mathcal{L}\_1[\mathcal{T}\_N]$ .

The distribution of the latency of broadcast $\mathcal{L}\_1[\mathcal{T}\_N]$ on a Cayley tree of height $T+2$ can computed by the [population dynamics algorithm](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81d2b433f31ffb793a74) as follows.

First, for each $\ell\in[M]$ compute boundary conditions as follows

$$
r\_k\sim\mathrm{Geom}(q)\\ ~~~~~~~~~~~~~~~~~~~~~~h\_\ell(0)=\max\left\{r\_1,\ldots,r\_{c-1}\right\}
$$
rk​∼Geom(q)                      hℓ​(0)=max{r1​,…,rc−1​}

Second, for each $t\in\{0,1,\ldots,T\}$ do the following for each $\ell\in[M]$

$$
r\_k\sim\mathrm{Geom}(q)\\\ell\_k\sim \mathcal{U}\{[M]\}\\ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~h\_\ell(t+1)=\max\left\{r\_1+h\_{\ell\_1}(t),\ldots,r\_{c-1}+h\_{ \ell\_{c-1}}(t)\right\}
$$
rk​∼Geom(q)ℓk​∼U{[M]}                                                    hℓ​(t+1)=max{r1​+hℓ1​​(t),…,rc−1​+hℓc−1​​(t)}

Finally, for each $\ell\in[M]$ compute

$$
r\_k\sim\mathrm{Geom}(q)\\\ell\_k\sim \mathcal{U}\{[M]\}\\ ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~H\_\ell(T)=\max\left\{r\_1+h\_{\ell\_1}(T),\ldots,r\_{c}+h\_{ \ell\_{c}}(T)\right\}
$$
rk​∼Geom(q)ℓk​∼U{[M]}                                                     Hℓ​(T)=max{r1​+hℓ1​​(T),…,rc​+hℓc​​(T)}

The prob. distribution of $\mathcal{L}\_1[\mathcal{T}\_N]$ for a Cayley tree of height $T+2$ can be estimated by the density

$$
\mathrm{P}\_M(H)=\frac{1}{M}\sum\_{\ell=1}^M\delta\_{H;\,H\_\ell(T)}
$$
PM​(H)=M1​ℓ=1∑M​δH;Hℓ​(T)​

The above dynamics can be described by the equation

$$
\mathrm{P}\_{t+1}(h)=\sum\_{h\_1}\cdots\sum\_{h\_{c-1}}\prod\_{\ell=1}^{c-1}\mathrm{P}\_{t}(h\_\ell)\\~~~~~~~~~~~~~~~~~~~\times\sum\_{r\_1}\cdots\sum\_{r\_{c-1}}\prod\_{\ell=1}^{c-1}\mathrm{P}\_{q}(r\_\ell)\\~~~~~~~~~~~~~~~~~~~~~~~~~\times\delta\_{h;\,\max\left\{r\_1+h\_1,\ldots,r\_{c-1}+h\_{c-1}\right\}}
$$
Pt+1​(h)=h1​∑​⋯hc−1​∑​ℓ=1∏c−1​Pt​(hℓ​)                   ×r1​∑​⋯rc−1​∑​ℓ=1∏c−1​Pq​(rℓ​)                         ×δh;max{r1​+h1​,…,rc−1​+hc−1​}​

The boundary condition corresponding to the Cayley tree is given by

$$
\mathrm{P}\_{0}(h)=\sum\_{r\_1}\cdots\sum\_{r\_{c-1}}\left\{\prod\_{\ell-1}^{c-1}\mathrm{P}\_{q}(r\_\ell)\right\}\,\delta\_{h;\,\max\left\{r\_1,\ldots,r\_{c-1}\right\}}
$$
P0​(h)=r1​∑​⋯rc−1​∑​{ℓ−1∏c−1​Pq​(rℓ​)}δh;max{r1​,…,rc−1​}​

The prob. distribution of $\mathcal{L}\_1[\mathcal{T}\_N]$ for a Cayley tree of height $T+2$ is given by

$$
\mathrm{P}\_{T+2}(H)=\sum\_{h\_1}\cdots\sum\_{h\_{c}}\prod\_{\ell=1}^{c}\mathrm{P}\_{T}(h\_\ell)\\~~~~~~~~~~~~~~~~~~~\times\sum\_{r\_1}\cdots\sum\_{r\_{c}}\prod\_{\ell=1}^{c}\mathrm{P}\_{q}(r\_\ell)\\~~~~~~~~~~~~~~~~~~~~~~~~~\times\delta\_{H;\,\max\left\{r\_1+h\_1,\ldots,r\_{c}+h\_{c}\right\}}
$$
PT+2​(H)=h1​∑​⋯hc​∑​ℓ=1∏c​PT​(hℓ​)                   ×r1​∑​⋯rc​∑​ℓ=1∏c​Pq​(rℓ​)                         ×δH;max{r1​+h1​,…,rc​+hc​}​

Using that the prob. distribution $\mathrm{P}\_q(r)$ is geometric with parameter $q$ , one could try to solve above equations analytically. Also one could consider a single loop and see how this will change the [equation](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81ab9edbfb2cdd64da4c).

For $q=1$ we have $r\_{ji}=1$ with prob. $1$ and hence the latency of broadcast is dominated by the diameter $d$ of a random regular graph, i.e. the largest distance between any two nodes. The bounds (using the [Theorems 1 and 3](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81fd84cbeaffe272a77b)) for the latter for (very small) $\epsilon>0$ are given by

$$
\lfloor\log\_{c-1}(N)\rfloor+\left\lfloor\log\_{c-1}\left(\log(N)\frac{c-2}{6c}\right)\right\rfloor+1\leq d \\~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~\leq \left\lceil\log\_{c-1}(N)+\log\_{c-1}((2+\epsilon)\,c\log(N))\right\rceil+1.
$$
⌊logc−1​(N)⌋+⌊logc−1​(log(N)6cc−2​)⌋+1≤d                                                           ≤⌈logc−1​(N)+logc−1​((2+ϵ)clog(N))⌉+1.

### A Simple Model of Communication Latency in Consensus

To model the communication latency of a node participating in consensus, we assume that latency has two dominant components which are due to delays in “mixing“ and “broadcast” (cf. the formula “Mixnet delay (gamma distribution) sampled once per block + PoL (constant) + final broadcast from exit mixnode (exponential distribution) sampled per node” used in consensus simulations).

We assume that given a network of $N$ nodes, a gossiping-like mode of communication is used.

Let us assume that the network topology used is a random regular graph $G\_N=(V\_N,E\_N)$ , where $V\_N=[N]$ is the set of nodes and $E\_N$ is the set of edges, with connectivity $c$ . The latter is sampled only once and remains fixed for the duration of a consensus protocol.

Furthermore, to each edge $\{i,j\}\in E\_N$ we assign a random variable $d\_{ij}$ , sampled from some probability distribution, to model delays in communication links. This gives rise to the weighted graph $G\_N[\{d\_{ij}\}]$ . The probability distribution could be [exponential](https://en.wikipedia.org/wiki/Exponential_distribution), with parameter $\lambda$ such that $1/\lambda$ is the average and $1/\lambda^2$ is the variance, or $d\_{ij}=d$ for all $\{i,j\}\in E\_N$ (cf. the “300ms” constant delay used in current estimates of latency).

To model the mixing delay we assume, without loss of generality, that node $1$ sends (via $k$ mix nodes) a message to node $k+2$ , and adopt the [single-path model](/1fd261aa09df811b87bafccc589bc724?pvs=25#1fd261aa09df81ccb10cc982e68b58d6) as follows

$$
\Delta\sum\_{\ell=1}^{k+1}r\_\ell+ \sum\_{\ell=1}^{k+1}D\_{\ell\rightarrow \ell+1}%[G\_N[\{d^\ell\_{ij}\}]]
$$
Δℓ=1∑k+1​rℓ​+ℓ=1∑k+1​Dℓ→ℓ+1​

In above we assume that $k$ mix nodes, and the sender node $1$ , introduce delays modeled by random variables $r\_i$ sampled from the Geometric distribution with the parameter $q=1/2$ . The latter models a queue which uses coin-flipping to remove a message. Here $\Delta$ is a cost of attempt to remove a message, measured in units of time, from the queue.

The second part of above equation models the contribution of gossiping to the delay. Here $D\_{i\_1\rightarrow i\_2}\equiv D\_{i\_1\rightarrow i\_2}[G\_N[\{d\_{ij}\}]]$ is the “distance”, measured in units of time, between the nodes $i\_1$ and $i\_2$ on the graph $G\_N[\{d\_{ij}\}]$ which is defined as follows

$$
D\_{i\_1\rightarrow i\_2}%[G\_N[\{d\_{ij}\}]]
=\min\_{i\_1\rightarrow i\_2 }\sum\_{(i,j)\in i\_1\rightarrow i\_2}d\_{ij}
$$
Di1​→i2​​=i1​→i2​min​(i,j)∈i1​→i2​∑​dij​

Furthermore, the distance $D\_{\ell\rightarrow \ell+1}\equiv D\_{\ell\rightarrow \ell+1}[G\_N[\{d^\ell\_{ij}\}]]$ , i.e. samples of random variables $\{d^\ell\_{ij}\}$ are different for different $\ell$ to model the gossiping aspect of communication.

The distance $D\_{i\_1\rightarrow i\_2}$ can be interpreted as the latency of (communication) path between the sender node $i\_1$ and the receiver node $i\_2$ when the gossiping mode of communication is used.

We note that in a weighted graph $G\_N[\{d\_{ij}\}]$ the distance $D\_{i\_1\rightarrow i\_2}$ can computed by using the [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm#:~:text=Dijkstra%27s%20algorithm%20(%2F%CB%88da%C9%AA,and%20published%20three%20years%20later.).

To model the broadcast delay we assume, without loss of generality, that the node $k+2$ broadcasts the message, received from node $1$ , to all nodes in the network. Assuming that gossiping is used the delay is $D\_{k+2\rightarrow \ell}[G\_N[\{d^\ell\_{ij}\}]]$ for each node $\ell\in [N]\setminus k+2$ .

To simulate the mixing and broadcast delays in a consensus simulation the following algorithm can be used

Generate a random regular graph $G\_N$ with connectivity $c$ .

For the sender node $i\_S$ , sending a message to the receiver node $i\_R$ , sample (without replacement) the mix nodes $i\_1,\ldots,i\_k$ and $i\_R$ from the set of all available nodes $[N]\setminus i\_S$ .

Sample the random delays $r\_1,\ldots,r\_{k+1}$ , from the geometric distribution with parameter $q=1/2$ .

Given the random regular graph $G\_N$ , generate the sequence of weighted graphs $G\_N[\{d^1\_{ij}\}],\ldots, G\_N[\{d^{k+1}\_{ij}\}]$ associated with each directed edge in the path $i\_S\rightarrow i\_1\rightarrow\ldots\rightarrow i\_k\rightarrow i\_R$ and compute the distances $D\_{i\_S\rightarrow i\_1}, D\_{i\_1\rightarrow i\_2},\ldots, D\_{i\_k\rightarrow i\_R}$ on these graphs.

Compute the mixing delay $\Delta\sum\_{\ell=1}^{k+1}r\_\ell+ D\_{i\_S\rightarrow i\_1}+ D\_{i\_1\rightarrow i\_2}+\cdots+ D\_{i\_k\rightarrow i\_R}$ ​

Given the same random regular graph $G\_N$ , generate the graph with random weights $G\_N[\{d\_{ij}\}]$ and for the node $i\_R$ compute the distance $D\_{i\_R\rightarrow i}$ for all $i\in [N]\setminus i\_R$ . The latter are broadcast delays.

Repeat the steps 2 to 6 for each sender node.

We note that when $d\_{ij}=d$ , i.e. all communication links have the same latency, then all distances $D\_{i\rightarrow j}$ on the weighted graph $G\_N[\{d\_{ij}=d\}]$ can be precomputed which simplifies the steps 4 and 6 in the above algorithm.

Also the algorithm can be easily adopted to use other models of random graphs, and other models of mixing and communication delays.

## Bibliography

Amir Dembo. Andrea Montanari. "Ising models on locally tree-like graphs." Ann. Appl. Probab. 20 (2) 565 - 592, April 2010. <https://doi.org/10.1214/09-AAP627>

Hamed Amini. Marc Lelarge. "The diameter of weighted random graphs." Ann. Appl. Probab. 25 (3) 1686 - 1727, June 2015. <https://doi.org/10.1214/14-AAP1034>

Mézard, M., Parisi, G. “The Bethe lattice spin glass revisited.” Eur. Phys. J. B 20, 217–233 (2001). <https://doi.org/10.1007/PL00011099>

Bollobás, B., Fernandez de la Vega, W. “The diameter of random regular graphs.” Combinatorica 2, 125–134 (1982). <https://doi.org/10.1007/BF02579310>

\frac{\mathcal{L}\_1[G\_N]}{\log(N)}\xrightarrow{\text{Prob.}}
\frac{1}{c-2}+\frac{1}{c},

\left\lceil\frac{\log\left(\frac{N(c - 2) + 2}{c}\right)}{\log(c - 1)}\right\rceil

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Latency

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Latency-1fd261aa09df811b87bafccc589bc724?pvs=26&qid=1:d430d6b8-8962-4391-be55-e1eec5c388a8:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Latency

Revision History

Table

Introduction

We consider latency of a broadcast on the network constructed from mix nodes which use queues to store in-coming and out-going messages. A message is removed from the queue with probability ΣEquation which delays messages by a random amount of time governed by the Geometric distribution with parameter ΣEquation. The other source of message delays are due to the latency in communication links which we assume to be “frozen”, i.e. not changing with time. We show that for a single path constructed from ΣEquation mix nodes the average message latency is proportional to ΣEquation and we estimate the probability of latency being greater than the average. Furthermore, we consider latency of a broadcast on the network with the topology of a random regular graph with connectivity ΣEquation. Here we find that the latency of broadcast, divided by ΣEquation, is approaching ΣEquation for a small probability of message removal ΣEquation as the number of nodes in the network ΣEquation is growing. However, for finite ΣEquation the distribution of latency can have long tails. We note that the latter result is established semi-analytically and only for trees we managed to develop a complete analytical framework which can be used to compute the latency of a broadcast. Finally, in this document we propose a simple model of communication latency in consensus.

Analysis

Single Node

- Assuming that a message is removed from the queue of a node with probability ΣEquation (see the document), a message in node ΣEquation is delayed by (at most) ΣEquation, where ΣEquation is a random variable from the Geometric distribution with parameter ΣEquation and ΣEquation is a “cost” of one attempt of removing a message.
- Assuming that node ΣEquation has ΣEquation connections and it puts a message into all out-queues associated with these connections, i.e. the node ΣEquation is sending a message. The message will be delayed by (at most) ΣEquation in the queue ΣEquation, by ΣEquation in the queue ΣEquation, etc., where ΣEquation is sample from the Geometric distr. with parameter ΣEquation.
- Assuming that node ΣEquation has ΣEquation connections and it puts a message into all out-queues but not the queue associated with the connection labelled by ΣEquation, i.e. the node is relaying a message, the message will be delayed by (at most) ΣEquation in the queue ΣEquation, by ΣEquationin the queue ΣEquation, etc., where ΣEquation is sample from the Geometric distr. with parameter ΣEquation.

Single Path

- Without loss of generality, we consider a message traveling from node ΣEquation to node ΣEquation. A message is delayed at the node ΣEquation by ΣEquation, at the node ΣEquation by ΣEquation, etc. For node ΣEquation we assume that ΣEquation is a random variable from the Geometric distribution with parameter ΣEquation and that ΣEquation. The latter is prop. to a max. time elapsed between attempts to “flip a coin”. Furthermore, a message traveling between the nodes ΣEquation and ΣEquation is delayed by ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F013ef215-15a4-430a-b311-43fd396c6406%2Fk-path-delay.png?table=block&id=1fd261aa-09df-8109-bdc3-ce8b91179527&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Using above the total delay is given by ΣEquation. We note that for ΣEquation and ΣEquation we have

📈Equation

- The sum ΣEquation is random variable from the negative binomial distribution

📈Equation

- Using that ΣEquation is a random variable from the Geometric distribution with parameter ΣEquation the average and variance of the total delay ΣEquation is given, respectively, by ΣEquation and ΣEquation. The latter, for ΣEquation and ΣEquation , is simplifies to ΣEquation and ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F3c2fe8c0-504b-42ed-9664-892feb5f484e%2FScreenshot_2024-07-24_at_17.34.49.png?table=block&id=1fd261aa-09df-81f2-9a1c-e10d0112a61c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The mean of sum ΣEquation is equals to ΣEquation. For ΣEquation the probability ΣEquation can bounded from above as follows

📈Equation

- To show the above we used ΣEquation for any ΣEquation and Markov’s inequality.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F47c901a7-f83f-4ec2-8b0a-7cf3371b90ee%2FScreenshot_2024-07-29_at_13.15.54.png?table=block&id=1fd261aa-09df-81c5-9635-d2b020ed4146&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The probability ΣEquation is increasing with decreasing ΣEquation for ΣEquation

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F18a470cb-61f2-45f3-9efb-c3e9f80c3965%2FScreenshot_2024-07-29_at_13.12.19.png?table=block&id=1fd261aa-09df-8111-9f95-de9b603ff42b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- and decreasing with increasing ΣEquation for ΣEquation

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F10a16762-a53e-42b2-b207-35f6dd413b6c%2FScreenshot_2024-07-29_at_13.14.07.png?table=block&id=1fd261aa-09df-813d-8d29-db9b3b622edc&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that the upper bound can be represented as

📈Equation

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2a7892f1-e643-4c14-a1f2-62e99e5b2cba%2Ff_q_eps.png?table=block&id=1fd261aa-09df-810f-b0df-fcf9e6fbacb0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Plotting ΣEquation suggests that the upper bound is monotonic decreasing function of ΣEquation, ΣEquation and ΣEquation.

Random Networks

Configuration Model

- Let us consider the probability distribution ΣEquation over the non-negative integers ΣEquation such that ΣEquation and define the probability distribution

📈Equation

- We consider the random rooted tree generated as follows. First, we sample ΣEquation from the distr. ΣEquation and connect the root node to ΣEquation offspring nodes. Second, for each offspring node we sample ΣEquation from the distr. ΣEquation and connect to ΣEquation nodes. The latter is repeated until the tree ΣEquation of height ΣEquation is generated.
- We consider the random graph ΣEquation, where ΣEquation is the set of nodes and ΣEquation is the set of edges, generated by connecting nodes with connectivities sampled from the probability distribution ΣEquation, i.e. the “configuration model”.
- For ΣEquation we have that ΣEquation, where ΣEquation is the subgraph of ΣEquation induced by nodes at a distance (length of shortest path between two nodes) at most ΣEquation from the node ΣEquation, with high probability.
- A special case ΣEquation is a random regular graph (RRG) of connectivity ΣEquation, i.e. each node in ΣEquation is connected to exactly ΣEquation nodes.

Distance on a graph and latency of a broadcast

- Let us assume, without loss of generality, that node ΣEquation in this network wants to send a message to the all ΣEquation nodes of network.
- A node puts a message in to all of its out-queues. Assuming that coin-flipping algorithm is used to remove a message from the queue, we have that a message is delayed by (at most) ΣEquation (see previous section), where ΣEquation random variable from the Geometric distribution with parameter ΣEquation. A message is delayed further in a communication link and hence, for example, a message sent from the node ΣEquation to the node ΣEquation is delayed (at most) by ΣEquation. We note that copies of the same message, sent to other neighbours of node ΣEquation, are delayed in a similar manner.
- For node ΣEquation sending a message to its neighbour ΣEquation the delay is ΣEquation.
- The total delay of a message sent from the node ΣEquation to the node ΣEquation is the sum of delays

📈Equation

along the (directed) path from node ΣEquation to node ΣEquation, ΣEquation .

- Let us define the distance between node 1 and node ΣEquation as the

📈Equation

i.e. the minimum total delay over all (directed) paths from node 1 to node i.

- Now the maximum distance

📈Equation

i.e. the maximum over distances between node ΣEquation and all other nodes, is the time that elapsed from the event “node ΣEquation sent a message” to the event “the message was delivered to all nodes”.

- Thus ΣEquation is the latency of broadcast from node ΣEquation. Let us define the latter as

📈Equation

- We note that maximum distance can be computed using Dijkstra's algorithm.
- Finally, for all pairs of distinct nodes we define the diameter of ΣEquation as follows

📈Equation

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0a4ec471-d769-49b8-b692-531ce87075e1%2Fbroadcast-channel.png?table=block&id=1fd261aa-09df-81e1-932a-c0c873f2b808&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Results for a High Connectivity Regime

- We consider networks with topology of a random regular graph in the high connectivity regime of ΣEquation, where ΣEquation, with ΣEquation and ΣEquation.
- First we consider the case of ΣEquation, i.e. the network is a complete graph, where the least latency is expected. Measuring the latency of broadcast for ΣEquation, we see that it is increasing as ΣEquation and decreasing as ΣEquation as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ffbfc94c8-55b0-47c6-a015-75fe9ca02fe8%2F7552_latency.png?table=block&id=1fd261aa-09df-81f5-9cb3-eb2cb6e173eb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Furthermore, as ΣEquation is increased from ΣEquation to ΣEquation the latency of broadcast becomes more concentrated on the value of 2 as can be seen in figures below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F831f5e81-13a4-4299-9d60-52b3278996cc%2F4910_latency_hist.png?table=block&id=1fd261aa-09df-81a8-bb3b-d4048c885aa0&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Finally, we consider random regular graph in the high connectivity regime of ΣEquation, where ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F1451a5f4-6cda-48cc-bb16-956113e29234%2F9123515c-56f3-49eb-b278-ff3865c0c91a.png?table=block&id=1fd261aa-09df-8186-ad5c-f01297023e24&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F193ca3e9-4d42-466a-99d8-302f98845d2e%2F11ed4881-e9f8-433b-a5b0-f618b9135c6e.png?table=block&id=1fd261aa-09df-815b-8d52-d720953cfe09&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Results for a Finite Connectivity Regime

- We consider broadcast on networks with topology of a random regular graph in the finite connectivity regime of ΣEquation with ΣEquation and ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0b8a8800-d227-4928-a9d5-98235b2bd183%2FScreenshot_2024-09-03_at_12.25.01.png?table=block&id=1fd261aa-09df-811b-ade7-e462828efc7c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Ff9b00a6b-2a41-4246-b187-5ff47f5f86fa%2FScreenshot_2024-09-03_at_12.26.49.png?table=block&id=1fd261aa-09df-8134-8947-e8edefe98d63&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Dividing the latency of broadcast by ΣEquation suggests that the latter is converging to some value, dependent on ΣEquation and connectivity ΣEquation, as ΣEquation as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F6cbe78f5-4be8-4a0c-8b7f-fed2279d059f%2FScreenshot_2024-09-09_at_10.28.54.png?table=block&id=1fd261aa-09df-8153-8ba1-c2c82131d99c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- For ΣEquation distribution of the random variable ΣEquation, where ΣEquation is sampled from the geometric distribution with parameter ΣEquation, is exponential distribution with parameter ΣEquation. The latter follows from the properties of the Geometric distribution.
- Furthermore, the latency of broadcast, ΣEquation, for delays sampled from the exponential distribution with parameter ΣEquation and ΣEquation is

📈Equation

i.e. the latency of broadcast is ΣEquation with high probability when ΣEquation is large.

- The above two points suggest that for small ΣEquation, the latency of broadcast is approximately ΣEquation when ΣEquation are sampled from the geometric distribution with parameter ΣEquation, i.e. the latency of broadcast is diverging as ΣEquation. The latter is consistent with latency measured in simulations.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F780b2449-ba5e-48b8-a214-e0b25283642e%2FScreenshot_2024-09-09_at_14.23.13.png?table=block&id=1fd261aa-09df-817e-912f-c5380a0691c2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- For larger values of q, the average latency of broadcast computed numerically deviates from the asymptotic ΣEquation as can be seen in the figure above.
- We note that the (asymptotic) latency of broadcast ΣEquation is a special case of ΣEquation for some (unknown) function ΣEquation.
- Assuming that the latency of broadcast ΣEquation, with high prob. as ΣEquation, and inverting this expression gives us ΣEquation. Using the data to plot the latter suggests the form ΣEquation for some parameter ΣEquation as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F93c1ccd5-8abb-4418-986b-f4de93e8b67e%2FScreenshot_2024-09-10_at_17.02.02.png?table=block&id=1fd261aa-09df-8103-9995-f3f4e442c2f5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that for ΣEquation we have ΣEquation as ΣEquation.
- Furthermore, fitting ΣEquation to the mean of data gives us

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F3dfe8b3f-d35f-4607-beb0-131e552c3161%2FScreenshot_2024-09-10_at_21.38.51.png?table=block&id=1fd261aa-09df-81af-92dc-e769c066daf2&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Testing the expression ΣEquation for the mean value of broadcast obtained numerically suggests that the latter is accurate when the connectivity ΣEquation and q are small but significantly diverges from the data when ΣEquation and ΣEquation are large as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F4f54e665-3f7d-4bd7-9dee-a085cac78d4f%2FScreenshot_2024-09-16_at_10.00.45.png?table=block&id=1fd261aa-09df-8117-80cd-f85d63fddce3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The probability that the latency of broadcast is greater than some threshold ΣEquation decreases with the connectivity ΣEquation as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0f621a59-7dcc-4cb2-8260-c13f13ce57ec%2FScreenshot_2024-09-23_at_13.28.26.png?table=block&id=1fd261aa-09df-81ea-b0f9-fac097fa63c8&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that random regular graph is locally tree-like, i.e. when ΣEquation is large any node is a root of a tree of some height ΣEquation with high probability.
- For the node connectivity ΣEquation the number of nodes in the tree of height ΣEquation, rooted at node ΣEquation, is given by

📈Equation

- In above we assumed that root node has ΣEquation children and every internal node has ΣEquation children (see figure).
- For ΣEquation nodes, the minimum ΣEquation such that ΣEquation is given by

📈Equation

- The latency of broadcast on a tree of ΣEquation nodes is expected to be higher than on random regular with the same ΣEquation and the same connectivity ΣEquation. This is due to the presence of loops in the latter.
- The numerical results for (average) latency of broadcast on a tree of ΣEquation nodes suggest that this average is an upper bound on the average latency of broadcast on on random regular with the same ΣEquation and the same connectivity ΣEquation as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F0b27c6ed-ffc2-48a3-b7bb-2216234d96c9%2FScreenshot_2024-09-28_at_09.06.48.png?table=block&id=1fd261aa-09df-81f6-be83-dc48ad28ff08&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Furthermore, numerical results for latency of broadcast on trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9619b896-d06a-4025-875e-41563ddc2666%2FScreenshot_2024-09-23_at_13.54.02.png?table=block&id=1fd261aa-09df-819b-abe1-c72b63e27281&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that the latency of broadcast on a tree of finite size is equivalent to the latency of broadcast in finite neighbourhood of a sender node in large random regular graph. In the latter, as ΣEquation the finite neighbourhood of a node is (with high prob.) a Cayley tree (see figure below) up to some distance, measured in by number edges between the node and any other node.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Faaf7c477-da06-4466-afd6-2e361f1a46f5%2FScreenshot_2024-09-30_at_11.27.43.png?table=block&id=1fd261aa-09df-81e1-b50e-f57550e2e255&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The numerical results for latency of broadcast on Cayley trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F26f68811-b1c2-4c89-9d1e-2af30e19374c%2FScreenshot_2024-09-30_at_11.42.28.png?table=block&id=1fd261aa-09df-81d9-9901-f16358cafad4&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- The latency of broadcast on a tree can be computed iteratively. The latter uses the property

📈Equation

- To show this we consider the latency of broadcast on a tree of ΣEquation nodes ΣEquation rooted at node ΣEquation (see figure) as follows.
- First, we define the latency of communication a message, sent from node ΣEquation to all nodes inΣEquation, when it is relayed from the node ΣEquation to ΣEquation as ΣEquation then the latency of broadcast

📈Equation

- Second, we consider the latency of broadcast

📈Equation

- Now the maximum distance from node ΣEquation to a leaf node ΣEquation, ΣEquation, can be computed as follows

📈Equation

- Furthermore, if node ΣEquation is adjacent only to leaf nodes but one then

📈Equation

- For node ΣEquation not adjacent to leaf nodes the ΣEquation can be computed via equation similar to the equation. The latter suggests that the latency of broadcast ΣEquation can be computed recursively using above equations and numerical complexity of this computation is ΣEquation. This is better than ΣEquation when Dijkstra's algorithm is used to compute ΣEquation.
- The distribution of the latency of broadcast ΣEquation on a Cayley tree of height ΣEquation can computed by the population dynamics algorithm as follows.
- First, for each ΣEquation compute boundary conditions as follows

📈Equation

- Second, for each ΣEquation do the following for each ΣEquation

📈Equation

- Finally, for each ΣEquation compute

📈Equation

- The prob. distribution of ΣEquation for a Cayley tree of height ΣEquation can be estimated by the density

📈Equation

- The above dynamics can be described by the equation

📈Equation

- The boundary condition corresponding to the Cayley tree is given by

📈Equation

- The prob. distribution of ΣEquation for a Cayley tree of height ΣEquation is given by

📈Equation

- Using that the prob. distribution ΣEquation is geometric with parameter ΣEquation, one could try to solve above equations analytically. Also one could consider a single loop and see how this will change the equation.
- For ΣEquation we have ΣEquation with prob. ΣEquation and hence the latency of broadcast is dominated by the diameter ΣEquation of a random regular graph, i.e. the largest distance between any two nodes. The bounds (using the Theorems 1 and 3) for the latter for (very small) ΣEquation are given by

📈Equation

A Simple Model of Communication Latency in Consensus

- To model the communication latency of a node participating in consensus, we assume that latency has two dominant components which are due to delays in “mixing“ and “broadcast” (cf. the formula “Mixnet delay (gamma distribution) sampled once per block + PoL (constant) + final broadcast from exit mixnode (exponential distribution) sampled per node” used in consensus simulations).
- We assume that given a network of ΣEquation nodes, a gossiping-like mode of communication is used.
- Let us assume that the network topology used is a random regular graph ΣEquation, where ΣEquation is the set of nodes and ΣEquation is the set of edges, with connectivity ΣEquation. The latter is sampled only once and remains fixed for the duration of a consensus protocol.
- Furthermore, to each edge ΣEquation we assign a random variable ΣEquation, sampled from some probability distribution, to model delays in communication links. This gives rise to the weighted graph ΣEquation. The probability distribution could be exponential, with parameter ΣEquation such that ΣEquation is the average and ΣEquation is the variance, or ΣEquation for all ΣEquation (cf. the “300ms” constant delay used in current estimates of latency).
- To model the mixing delay we assume, without loss of generality, that node ΣEquation sends (via ΣEquation mix nodes) a message to node ΣEquation, and adopt the single-path model as follows

📈Equation

- In above we assume that ΣEquation mix nodes, and the sender node ΣEquation, introduce delays modeled by random variables ΣEquation sampled from the Geometric distribution with the parameter ΣEquation. The latter models a queue which uses coin-flipping to remove a message. Here ΣEquation is a cost of attempt to remove a message, measured in units of time, from the queue.
- The second part of above equation models the contribution of gossiping to the delay. Here ΣEquation is the “distance”, measured in units of time, between the nodes ΣEquation and ΣEquation on the graph ΣEquation which is defined as follows

📈Equation

- Furthermore, the distance ΣEquation, i.e. samples of random variables ΣEquation are different for different ΣEquation to model the gossiping aspect of communication.
- The distance ΣEquation can be interpreted as the latency of (communication) path between the sender node ΣEquation and the receiver node ΣEquation when the gossiping mode of communication is used.
- We note that in a weighted graph ΣEquation the distance ΣEquation can computed by using the Dijkstra's algorithm.
- To model the broadcast delay we assume, without loss of generality, that the node ΣEquation broadcasts the message, received from node ΣEquation, to all nodes in the network. Assuming that gossiping is used the delay is ΣEquation for each node ΣEquation.
- To simulate the mixing and broadcast delays in a consensus simulation the following algorithm can be used

  1. Generate a random regular graph ΣEquation with connectivity ΣEquation.
  2. For the sender node ΣEquation, sending a message to the receiver node ΣEquation, sample (without replacement) the mix nodes ΣEquation and ΣEquation from the set of all available nodes ΣEquation.
  3. Sample the random delays ΣEquation, from the geometric distribution with parameter ΣEquation.
  4. Given the random regular graph ΣEquation, generate the sequence of weighted graphs ΣEquation associated with each directed edge in the path ΣEquation and compute the distances ΣEquation on these graphs.
  5. Compute the mixing delay ΣEquation
  6. Given the same random regular graph ΣEquation, generate the graph with random weights ΣEquation and for the node ΣEquation compute the distance ΣEquation for all ΣEquation . The latter are broadcast delays.
  7. Repeat the steps 2 to 6 for each sender node.
- We note that when ΣEquation, i.e. all communication links have the same latency, then all distances ΣEquation on the weighted graph ΣEquation can be precomputed which simplifies the steps 4 and 6 in the above algorithm.
- Also the algorithm can be easily adopted to use other models of random graphs, and other models of mixing and communication delays.

Bibliography

Amir Dembo. Andrea Montanari. "Ising models on locally tree-like graphs." Ann. Appl. Probab. 20 (2) 565 - 592, April 2010. https://doi.org/10.1214/09-AAP627

Hamed Amini. Marc Lelarge. "The diameter of weighted random graphs." Ann. Appl. Probab. 25 (3) 1686 - 1727, June 2015. https://doi.org/10.1214/14-AAP1034

Mézard, M., Parisi, G. “The Bethe lattice spin glass revisited.” Eur. Phys. J. B 20, 217–233 (2001). https://doi.org/10.1007/PL00011099

Bollobás, B., Fernandez de la Vega, W. “The diameter of random regular graphs.” Combinatorica 2, 125–134 (1982). https://doi.org/10.1007/BF02579310

- Open in new tab
