# ANALYSIS-LATENCY

| Field | Value |
| --- | --- |
| Name | [Analysis] Latency |
| Slug | 193 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-27** — [`b7602ed`](https://github.com/logos-co/logos-lips/blob/b7602ed8a225d41ca0bfaaa432524dc84d2ded7e/docs/blockchain/raw/analysis-latency.md) — chore: move blockchain specs from notion to github

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-03-20 |

# Introduction

We consider latency of a broadcast on the network constructed from mix nodes which use [queues](analysis-queuing-system-in-the-mix-node.md) to store in-coming and out-going messages. A message is removed from the queue with probability $q$ which delays messages by a random amount of time governed by the Geometric distribution with parameter $q$. The other source of message delays are due to the latency in communication links which we assume to be “frozen”, i.e. not changing with time. We show that for a single path constructed from $k$ mix nodes the average message latency is proportional to $k/q$ and we estimate the probability of latency being greater than the average. Furthermore, we consider latency of a broadcast on the network with the topology of a random regular graph with connectivity $c$. Here we find that the latency of broadcast, divided by $\log(N)$, is approaching  $\frac{2(c-1)}{c(c-2)}\frac{1}{\log(1+q)}$ for a small probability of message removal $q$ as the number of nodes in the network $N$ is growing. However, for finite $N$ the distribution of latency can have long tails. We note that the latter result is established semi-analytically and only for trees we managed to develop a complete analytical framework which can be used to compute the latency of a broadcast. Finally, in this document we propose a simple model of communication latency in consensus.

# Analysis

## Single Node

- Assuming that a message is removed from the queue of a node with probability $q$ (see the [document](analysis-queuing-system-in-the-mix-node.md)), a message in node $i$ is delayed by (at most) $r_i\Delta_i$, where $r_i$ is a random variable from the Geometric distribution with parameter $q$ and $\Delta_i$ is a “cost” of one attempt of removing a message.
- Assuming that node $i$ has $c$ connections and it puts a message into all out-queues associated with these connections, i.e. the node $i$ is sending a message. The message will be delayed by (at most) $r_i(1)\Delta_i$ in the queue $1$, by $r_i(2)\Delta_i$ in the queue $2$, etc., where $r_i(1),\ldots,r_i(c)$ is sample from the Geometric distr. with parameter $q$.
- Assuming that node $i$ has $c$ connections and it puts a message into all out-queues but not the queue associated with the connection labelled by $c$, i.e. the node is relaying a message, the message will be delayed by (at most) $r_i(1)\Delta_i$ in the queue $1$, by $r_i(2)\Delta_i$in the queue $2$, etc., where $r_i(1),\ldots,r_i(c-1)$ is sample from the Geometric distr. with parameter $q$.

## Single Path

- Without loss of generality, we consider a message traveling from node $1$ to node $k$. A message is delayed at the node $1$ by $r_1\Delta_1$, at the node $2$ by $r_2\Delta_2$, etc. For node $i$ we assume that $r_i$ is a random variable from the Geometric distribution with parameter $q$ and that $\Delta_i \gt 0$. The latter is prop. to a max. time elapsed between attempts to “flip a coin”. Furthermore, a message traveling between the nodes $i$ and $j$ is delayed by $d_{ij}$.

![Diagram](analysis-latency/assets/1fd261aa-09df-8109-bdc3-ce8b91179527.png)

- Using above the total delay is given by $\sum_{i=1}^kr_i\Delta_i+ \sum_{i=1}^{k-1}d_{ii+1}$. We note that for $\Delta=\max_{i\in[k]}\Delta_i$ and $d=\max_{i\in[k-1]}d_{ii+1}$ we have

$$
\sum_{i=1}^kr_i\Delta_i+ \sum_{i=1}^{k-1}d_{ii+1}\leq \Delta\sum_{i=1}^kr_i+ (k-1)d
$$

- The sum $r=\sum_{i=1}^kr_i$ is random variable from the negative binomial distribution

$$
P_{k,q}(r)={r-1\choose k-1}q^k(1-q)^{r-k},\mathrm{where}\,\, r\in\{k,k+1,\ldots\}.
$$

- Using that $r_i$ is a random variable from the Geometric distribution with parameter $q$ the average and variance of the total delay $\sum_{i=1}^kr_i\Delta_i+ \sum_{i=1}^{k-1}d_{ii+1}$ is given, respectively, by $\sum_{i=1}^k\Delta_i/q+ \sum_{i=1}^{k-1}d_{ii+1}$ and $\frac{1-q}{q^2}\sum_{i=1}^k\Delta^2_i$. The latter, for $\Delta=\Delta_i$ and $d=d_{ii+1}$ , is simplifies to $k\Delta/q+ (k-1)d$ and $\frac{1-q}{q^2}k\Delta^2$.

![Diagram](analysis-latency/assets/1fd261aa-09df-81f2-9a1c-e10d0112a61c.png)

> <sub>The histogram of delays $\sum_{i=1}^kr_i\Delta_i+ \sum_{i=1}^{k-1}d_{ii+1}$ of $N_m=10^6$ messages traveling through $k=5$ nodes (red histogram bars) is compared with negative binomial (o symbols) with parameters $k=5$ and $q=1/2$. Here we assumed that $\Delta_i=1$ and $d_{ii+1}=0$.</sub>

- The mean of sum $\sum_{i=1}^kr_i$ is equals to $k/q$. For $\epsilon \gt 0$ the probability $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)$ can bounded from above as follows

$$
\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)\leq\left(\frac{q \left(\epsilon -1\right)+1}{1-q}\right)^{k} \left(\frac{q \left(\epsilon -1\right)+1}{\left(1-q \right) \left(\epsilon  q +1\right)}\right)^{-\frac{k \left(1+\epsilon \right)}{q}}
$$

- To show the above we used $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)=\mathrm{P}\left(\mathrm{e}^{\lambda\sum_{i=1}^kr_i}\geq \mathrm{e}^{\lambda(1+\epsilon)k/q}\right)$ for any $\lambda \gt 0$ and Markov’s inequality.

![Diagram](analysis-latency/assets/1fd261aa-09df-81c5-9635-d2b020ed4146.png)

> <sub>The prob. $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=1/2$ and $\epsilon=1$. Here the simulation (red + symbols) is compared with the [upper bound](#single-path) (blue square symbols). In simulation the prob. distr. of $\sum_{i=1}^kr_i$ was represented by $N=10^6$ samples of random variables $r_1,\ldots,r_k$ generated from the Geometric distribution with parameter $q$.</sub>

- The probability $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)$ is increasing with decreasing $q$ for $q \lt 1/2$​

![Diagram](analysis-latency/assets/1fd261aa-09df-8111-9f95-de9b603ff42b.png)

> <sub>The prob. $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=1/4$ and $\epsilon=1$. Here the simulation (red + symbols) is compared with the [upper bound](#single-path) (blue square symbols). In simulation the prob. distr. of $\sum_{i=1}^kr_i$ was represented by $N=10^6$ samples of random variables $r_1,\ldots,r_k$ generated from the Geometric distribution with parameter $q$.</sub>

- and decreasing with increasing $q$ for $q \gt 1/2$

![Diagram](analysis-latency/assets/1fd261aa-09df-813d-8d29-db9b3b622edc.png)

> <sub>The prob. $\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)$ as a function of $k$ plotted for $q=3/4$ and $\epsilon=1$. Here the simulation (red + symbols) is compared with the [upper bound](#single-path) (blue square symbols). In simulation the prob. distr. of $\sum_{i=1}^kr_i$ was represented by $N=10^6$ samples of random variables $r_1,\ldots,r_k$ generated from the Geometric distribution with parameter $q$.</sub>

- We note that the [upper bound](#single-path) can be represented as

$$
\mathrm{P}\left(\sum_{i=1}^kr_i\geq (1+\epsilon)k/q\right)\leq f^k(q,\epsilon)\mathrm{, where}\\ \quad f(q,\epsilon)=\left(\frac{q \left(\epsilon -1\right)+1}{1-q}\right) \left(\frac{q \left(\epsilon -1\right)+1}{\left(1-q \right) \left(\epsilon  q +1\right)}\right)^{-\frac{ \left(1+\epsilon \right)}{q}} .
$$

![Diagram](analysis-latency/assets/1fd261aa-09df-810f-b0df-fcf9e6fbacb0.png)

> <sub>$f(q,\epsilon)$ as a function of $q$ and $\epsilon$.</sub>

- Plotting $f(q,\epsilon)$ suggests that the upper bound is monotonic decreasing function of $k$, $\epsilon$ and $q$.

## Random Networks

### Configuration Model

- Let us consider the probability distribution $\mathrm{P}(c)$ over the non-negative integers $c\geq0$ such that $\sum_{c\geq0}\mathrm{P}(c)\,c \lt \infty$ and define the probability distribution

$$
\mathrm{Q}(c)=\frac{c\,\mathrm{P}(c)}{\sum_{\tilde{c}\geq0}\tilde{c}\,\mathrm{P}(\tilde{c})}
$$

- We consider the random rooted tree generated as follows. First, we sample $c$ from the distr. $\mathrm{P}(c)$ and connect the root node to $c$ offspring nodes. Second, for each offspring node we sample $c$ from the distr. $\mathrm{Q}(c)$ and connect to $c-1$ nodes. The latter is repeated until the tree $\mathcal{T}(h)$ of height $h$ is generated.
- We consider the random graph $G_N=(V_N,E_N)$, where $V_N=[N]$ is the set of nodes and $E_N$ is the set of edges, generated by connecting nodes with connectivities sampled from the probability distribution $\mathrm{P}(c)$, i.e. the [“configuration model”.](https://en.wikipedia.org/wiki/Configuration_model)
- For $N\rightarrow\infty$ we have that $B_i(h)\simeq\mathcal{T}(h)$, where $B_i(h)$ is the subgraph of $G_N$ induced by nodes at a distance (length of shortest path between two nodes) at most $h$ from the node $i\in[N]$, with [high probability](#bibliography).
- A special case $G_N$ is a random regular graph (RRG) of connectivity $c$, i.e. each node in $G_N$ is connected to exactly $c$ nodes.

### Distance on a graph and latency of a broadcast

- Let us assume, without loss of generality, that node $1$ in this network wants to send a message to the all $N-1$ nodes of network.
- A node puts a message in to all of its out-queues. Assuming that coin-flipping algorithm is used to remove a message from the queue, we have that a message is delayed by (at most) $r\Delta_1$ (see previous [section](#single-node)), where $r$ random variable from the [Geometric distribution](analysis-queuing-system-in-the-mix-node.md) with parameter $q$. A message is delayed further in a communication link and hence, for example, a message sent from the node $1$ to the node $2$ is delayed (at most) by $r_{12}\Delta_1+d_{12}$. We note that copies of the same message, sent to other neighbours of node $1$, are delayed in a similar manner.
- For node $i$ sending a message to its neighbour $j$ the delay is $r_{ij}\Delta_i+d_{ij}$.
- The total delay of a message sent from the node $1$ to the node $i\in[N]\setminus1$ is the sum of delays

$$
\sum_{(i,j)\in 1\rightarrow i}\{r_{ij}(1) \Delta_i+d_{ij}\}
$$

along the (directed) path from node $1$ to node $i$, $1\rightarrow i$ .

- Let us define the distance between node 1 and node $i\in[N]\setminus1$ as the

$$
D_{1\rightarrow i}[G_N]=\min_{1\rightarrow i}\sum_{(i,j)\in 1\rightarrow i}\{r_{ij}(1) \Delta_i+d_{ij}\}
$$

i.e. the minimum total delay over all (directed) paths from node 1 to node i.

- Now the maximum distance

$$
\max_{i\in[N]\setminus1} D_{1\rightarrow i}[G_N]=\max_{i\in[N]\setminus1}\min_{1\rightarrow i}\sum_{(i,j)\in 1\rightarrow i}\{r_{ij}(1) \Delta_i+d_{ij}\}
$$

i.e. the maximum over distances between node $1$ and all other nodes, is the time that elapsed from the event “node $1$ sent a message” to the event “the message was delivered to all nodes”.

- Thus $\max_{i\in[N]\setminus1} D_{1\rightarrow i}[G_n]$ is the latency of broadcast from node $1$. Let us define the latter as

$$
\mathcal{L}_1[G_N]=\max_{i\in[N]\setminus1} D_{1\rightarrow i}[G_N]
$$

- We note that maximum distance can be computed using [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm).
- Finally, for all pairs of distinct nodes we define the diameter of $G_N$ as follows

$$
\mathcal{D}[G_N]=\max_{i\neq j} D_{i\rightarrow j}[G_N]
$$

![Diagram](analysis-latency/assets/1fd261aa-09df-81e1-932a-c0c873f2b808.png)

> <sub>A single message is sent from node $1$ to all $N-1$ nodes of the network. The latter has topology of a random regular graph of connectivity $c=3$ which is locally tree-like for large $N$. The *total delay* of a message sent from node $1$ to node $4$, via the nodes $2$ and $3$, is given by the sum $\sum_{j=2}^4[ r_{j-1j}\Delta_{j-1}+d_{j-1j}]$.</sub>

### Results for a High Connectivity Regime

- We consider networks with topology of a random regular graph in the high connectivity regime of $c=\alpha N$, where $\alpha\in (0,1)$, with $\Delta_i=1$ and $d_{ij}=0$.
- First we consider the case of $c=N-1$, i.e. the network is a complete graph, where the least latency is expected. Measuring the latency of broadcast for $N=\{10,10^2,10^3\}$, we see that it is increasing as $q\rightarrow0$ and decreasing as $q\rightarrow1$ as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-81f5-9cb3-eb2cb6e173eb.png)

> <sub>Statistics of message latencies computed for the number of messages $M\in\{10^5,10^6\}$ (bottom, top and middle) broadcasted on the network of $N\in\{10, 10^2, 10^3\}$ nodes. The latter has the topology of a complete graph. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$. The black dashed horizontal line corresponds to $2$. The blue dashed horizontal line corresponds to $0$.</sub>

- Furthermore, as $N$ is increased from $N=10$ to $N=10^3$ the latency of broadcast becomes more concentrated on the value of 2 as can be seen in figures below.

![Diagram](analysis-latency/assets/1fd261aa-09df-81a8-bb3b-d4048c885aa0.png)

> <sub>The histogram of message latencies computed for the $M\in\{10^5,10^6\}$ (top and middle, bottom) messages broadcasted for the network of $N=\{10,10^2,10^3\}$ nodes. The latter has topology of a complete graph. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with the parameter $q=\{1/10, 1/2,9/10\}$ (left, middle, right).</sub>

- Finally, we consider random regular graph in the high connectivity regime of $c=\alpha N$, where $\alpha\in (0,1)$.

![Diagram](analysis-latency/assets/1fd261aa-09df-8186-ad5c-f01297023e24.png)

> <sub>Statistics of message latencies computed for $M\in\{10^5,10^6\}$ (bottom, top and middle) messages broadcasted on the network of $N\in\{10, 10^2, 10^3\}$ nodes. The latter has topology of a random regular graph with connectivity $N/2$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$. The black dashed horizontal line corresponds to $2$. The blue dashed horizontal line corresponds to $0$.</sub>

![Diagram](analysis-latency/assets/1fd261aa-09df-815b-8d52-d720953cfe09.png)

> <sub>The histogram of message latencies computed for the $M\in\{10^5,10^6\}$ (top and middle, bottom) messages broadcasted for the network of $N=\{10,10^2,10^3\}$ nodes. The latter has topology of a random regular graph of connectivity $N/2$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with the parameter $q=\{1/10, 1/2,9/10\}$ (left, middle, right).</sub>

### Results for a Finite Connectivity Regime

- We consider broadcast on networks with topology of a random regular graph in the finite connectivity regime of $c\ll N$ with $\Delta_i=1$ and $d_{ij}=0$.

![Diagram](analysis-latency/assets/1fd261aa-09df-811b-ade7-e462828efc7c.png)

![Diagram](analysis-latency/assets/1fd261aa-09df-8134-8947-e8edefe98d63.png)

> <sub>Top: Statistics of message latencies computed for the number of messages $M=10^5$ broadcasted on the network of $N=10^3$ nodes. The latter has topology of a random regular graph with connectivity $c=4$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$. Bottom: The histogram of message latencies computed for $q=\{1/10, 1/2,9/10\}$ (left, middle, right).</sub>

- Dividing the latency of broadcast by $\log(N)$ suggests that the latter is converging to some value, dependent on $q$ and connectivity $c$, as $N\rightarrow\infty$ as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-8153-8ba1-c2c82131d99c.png)

> <sub>The average latency of broadcast $\pm$ standard deviation (divided by $\log(N)$) plotted as a function of network size $N$ for $q\in\{1/10, 1/2, 9/10\}$ (left, middle, right). The number of messages broadcasted is $M=10^4$. The network has topology of a random regular graph with connectivity $c=4$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q$.</sub>

- For $q\rightarrow0$ distribution of the random variable $q\,r_{ij}$, where $r_{ij}$ is sampled from the geometric distribution with parameter $q$, is exponential distribution with parameter $1$. The latter follows from the properties of the [Geometric distribution](https://en.wikipedia.org/wiki/Geometric_distribution).
- Furthermore, the [latency of broadcast](#distance-on-a-graph-and-latency-of-a-broadcast), $\mathcal{L}_1[G_N]$, for delays sampled from the exponential distribution with parameter $1$ and $N\rightarrow\infty$ is

$$
\frac{\mathcal{L}_1[G_N]}{\log(N)}\xrightarrow{\text{Prob.}}
\frac{1}{c-2}+\frac{1}{c},
$$

i.e. the latency of broadcast is $\frac{2(c-1)}{c(c-2)}\log(N)$ [with](https://projecteuclid.org/journals/annals-of-applied-probability/volume-25/issue-3/The-diameter-of-weighted-random-graphs/10.1214/14-AAP1034.full)[high probability](#bibliography) when $N$ is large.

- The above two points suggest that for small $q$, the latency of broadcast is approximately $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ when $r_{ij}$ are sampled from the geometric distribution with parameter $q$, i.e. the latency of broadcast is diverging as $q\rightarrow0$. The latter is consistent with latency measured in [simulations](#results-for-a-finite-connectivity-regime).

![Diagram](analysis-latency/assets/1fd261aa-09df-817e-912f-c5380a0691c2.png)

> <sub>Statistics of message latencies computed for the number of messages $M=10^5$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c=4$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q\in\{1/100, 1/10,\ldots,9/10\}$. The dashed black line is the function $\frac{2c-2}{c(c-2)}\frac{\log(N)}{q}$.</sub>

- For larger values of q, the average latency of broadcast computed numerically deviates from the asymptotic $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ as can be seen in the figure above.
- We note that the (asymptotic) latency of broadcast $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{q}$ is a special case of $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{f(q)}$ for some (unknown) function $f(q)$.
- Assuming that the latency of broadcast $\mathcal{L}_1[G_N]=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{f(q)}$, with high prob. as $N\rightarrow\infty$, and inverting this expression gives us $f(q)= \frac{2(c-1)}{c(c-2)}\frac{\log(N)}{ \mathcal{L}_1[G_N]}$. Using the [data](#results-for-a-finite-connectivity-regime) to plot the latter suggests the form $f(q)=\alpha\log(1+q)$ for some parameter $\alpha \gt 0$ as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-8103-9995-f3f4e442c2f5.png)

> <sub>The function $f(q)=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{ \mathcal{L}_1[G_N]}$ as function of $q$. Solid line is $f(q)=q$ and dashed line is $f(q)=\alpha\log(1+q)$ with $\alpha=0.95$. Here for the broadcast latency $\mathcal{L}_1[G_N]$ the (empirical) mean from the [figure](#results-for-a-finite-connectivity-regime) was used.</sub>

- We note that for $f(q)=\alpha\log(1+q)$ we have $f(q)= \alpha\,(q-q^2/2+O(q^3))$ as $q\rightarrow0$.
- Furthermore, fitting $\mathcal{L}_1[G_N]=\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ to the mean of [data](#results-for-a-finite-connectivity-regime) gives us

![Diagram](analysis-latency/assets/1fd261aa-09df-81af-92dc-e769c066daf2.png)

> <sub>The mean latency of broadcast (+ symbols), computed from the [data](#results-for-a-finite-connectivity-regime), is explained by $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ (dashed line). Here the value of $\alpha$, obtained by fitting, is $0.9534770$.</sub>

- Testing the expression $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$ for the mean value of broadcast obtained numerically suggests that the latter is accurate when the connectivity $c$ and q are small but significantly diverges from the data when $c$ and $q$ are large as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-8117-80cd-f85d63fddce3.png)

> <sub>The mean latency of broadcast, represented by symbols, as a function of $q$ computed for the number of messages $M=10^4$ broadcasted on the network of $N=10^4$ nodes. The latter has topology of a random regular graph with connectivity $c\in\{3,5,8,13,21,34\}$ (top to bottom). The lines were obtained by fitting the $\alpha$ parameter in the expression $\frac{2(c-1)}{c(c-2)}\frac{\log(N)}{\alpha\log(1+q)}$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q$.</sub>

- The probability that the latency of broadcast is greater than some threshold $t$ decreases with the connectivity $c$ as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-81ea-b0f9-fac097fa63c8.png)

> <sub>The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c\in\{3,4,7,11\}$ (top to bottom). The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$.</sub>

- We note that random regular graph is [locally tree-like](#bibliography), i.e. when $N$ is large any node is a root of a tree of some height $h$ with high probability.
- For the node connectivity $c \gt 2$ the number of nodes in the tree of height $h$, rooted at node $1$, is given by

$$
1+c+c(c-1)+c(c-1)^2+\cdots+c(c-1)^{h-1}=1+c\frac{(c-1)^{h}-1}{c-2}.
$$

- In above we assumed that root node has $c$ children and every internal node has $c-1$ children (see [figure](#distance-on-a-graph-and-latency-of-a-broadcast)).
- For $N$ nodes, the minimum $h$ such that $N\leq1+c\frac{(c-1)^{h}-1}{c-2}$ is given by

$$
\left\lceil\frac{\log\left(\frac{N(c - 2) + 2}{c}\right)}{\log(c - 1)}\right\rceil
$$

- The latency of broadcast on a tree of $N$ nodes is expected to be higher than on random regular with the same $N$ and the same connectivity $c$. This is due to the presence of loops in the latter.
- The numerical results for (average) latency of broadcast on a tree of $N$ nodes suggest that this average is an upper bound on the average latency of broadcast on on random regular with the same $N$ and the same connectivity $c$ as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-81f6-be83-dc48ad28ff08.png)

> <sub>The average latency of broadcast as a function of connectivity $c$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c$ or of a balanced complete tree, rooted at node 1, with the same $N$ and $c$. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$.</sub>

- Furthermore, numerical results for latency of broadcast on trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-819b-abe1-c72b63e27281.png)

> <sub>The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N=10^3$ nodes. The latter has the topology of a random regular graph with connectivity $c=4$ or of a balanced complete tree rooted at node 1. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$.</sub>

- We note that the latency of broadcast on a tree of finite size is equivalent to the latency of broadcast in finite neighbourhood of a sender node in large random regular graph. In the latter, as $N\rightarrow\infty$ the finite neighbourhood of a node is (with high prob.) a Cayley tree (see figure below) up to some distance, measured in by number edges between the node and any other node.

![Diagram](analysis-latency/assets/1fd261aa-09df-81e1-b50e-f57550e2e255.png)

> <sub>The neighbourhood of node $1$ in a very large random regular graph of connectivity $c=3$. The weights in the latter are independent random variables from geometric distribution with parameter $q=1/2$.</sub>

- The numerical results for latency of broadcast on Cayley trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.

![Diagram](analysis-latency/assets/1fd261aa-09df-81d9-9901-f16358cafad4.png)

> <sub>The probability that the latency of broadcast is greater than $t$ as a function of $t$ computed for the number of messages $M=10^6$ broadcasted on the network of $N\in\{94, 190, 382, 766, 10^3, 1534\}$ nodes. The latter for $N=10^3$ has the topology of a random regular graph with connectivity $c=4$ and for $N\neq10^3$ is a Cayley tree rooted at node 1. The delay model, for a message sent from node $i$ to its neighbours $j$, used is $r_{ij}\Delta_i+d_{ij}$, where $\Delta_i=1$, $d_{ij}=0$ and $r_{ij}$ is random variable from the Geometric distribution with parameter $q=1/2$.</sub>

- The latency of broadcast on a tree can be computed iteratively. The latter uses the property

$$
\max\{J_1+J_2,J_1+J_3\}=J_1+\max\{J_2,J_3\},\\\quad \text{where } J_i>0.
$$

- To show this we consider the latency of broadcast on a tree of $N$ nodes $\mathcal{T}_N$ rooted at node $1$ (see [figure](#distance-on-a-graph-and-latency-of-a-broadcast)) as follows.
- First, we define the latency of communication a message, sent from node $1$ to all nodes in$\mathcal{T}_N$, when it is relayed from the node $i$ to $j$ as $J_{ij}(1)=r_{ij}(1) \Delta_i+d_{ij}$ then the latency of broadcast

$$
\mathcal{L}_1[\mathcal{T}_N]=\max_{i\in[N]\setminus1} D_{1\rightarrow i}[\mathcal{T}_N]\\\quad =\max_{i\in[N]\setminus1}\min_{1\rightarrow i}\sum_{(i,j)\in 1\rightarrow i}J_{ij}(1)\\\quad =\max_{i\in[N]\setminus1}\sum_{(i,j)\in 1\rightarrow i}J_{ij}(1)\\\quad =\max_{i\in \partial\mathcal{T}_N}\sum_{(i,j)\in 1\rightarrow i}J_{ij}(1)\text{, where }\partial\mathcal{T}_N\text{ is the set }\\\quad  \text{of leaf nodes}
$$

- Second, we consider the latency of broadcast

$$
\mathcal{L}_1[\mathcal{T}_N]=\max_{i\in \partial\mathcal{T}_N}\sum_{(i,j)\in 1\rightarrow i}J_{ij}(1)\\\quad =\max_{i\in\partial1}\lbrace J_{1i}(1)+\max_{k\in \partial\mathcal{T}_N}D_{i\rightarrow k}[\mathcal{T}_N]\rbrace,\\\quad \text{ where } D_{i\rightarrow k}[\mathcal{T}_N] \\\quad \text{ is the distance from } i \text{ to } k
$$

- Now the maximum distance from node $i$ to a leaf node $k$, $\max_{k\in \partial\mathcal{T}_N}D_{i\rightarrow k}[\mathcal{T}_N]$, can be computed as follows

$$
\max_{k\in \partial\mathcal{T}_N}D_{i\rightarrow k}[\mathcal{T}_N]=\max_{j\in\partial i\setminus1}\lbrace J_{ij}(1)+\max_{k\in \partial\mathcal{T}_N}D_{j\rightarrow k}[\mathcal{T}_N]\rbrace
$$

- Furthermore, if node $j$ is adjacent only to leaf nodes but one then

$$
\max_{k\in \partial\mathcal{T}_N}D_{j\rightarrow k}[\mathcal{T}_N]=\max_{k\in\partial j\setminus i}\{J_{jk}(1)\}
$$

- For node $j$ not adjacent to leaf nodes the $\max_{k\in \partial\mathcal{T}_N}D_{j\rightarrow k}[\mathcal{T}_N]$ can be computed via equation similar to the [equation](#results-for-a-finite-connectivity-regime). The latter suggests that the latency of broadcast $\mathcal{L}_1[\mathcal{T}_N]$ can be computed recursively using above equations and numerical complexity of this computation is $O(N)$. This is better than $O(N\log N)$ when Dijkstra's algorithm is used to compute $\mathcal{L}_1[\mathcal{T}_N]$.
- The distribution of the latency of broadcast $\mathcal{L}_1[\mathcal{T}_N]$ on a Cayley tree of height $T+2$ can computed by the [population dynamics algorithm](#bibliography)as follows.
- First, for each $\ell\in[M]$ compute boundary conditions as follows

$$
r_k\sim\mathrm{Geom}(q)\\ \quad h_\ell(0)=\max\lbrace r_1,\ldots,r_{c-1}\rbrace
$$

- Second, for each $t\in\{0,1,\ldots,T\}$ do the following for each $\ell\in[M]$

$$
r_k\sim\mathrm{Geom}(q)\\\ell_k\sim \mathcal{U}([M])\\ \quad h_\ell(t+1)=\max\lbrace r_1+h_{\ell_1}(t),\ldots,r_{c-1}+h_{ \ell_{c-1}}(t)\rbrace
$$

- Finally, for each $\ell\in[M]$ compute

$$
r_k\sim\mathrm{Geom}(q)\\\ell_k\sim \mathcal{U}([M])\\ \quad H_\ell(T)=\max\lbrace r_1+h_{\ell_1}(T),\ldots,r_{c}+h_{ \ell_{c}}(T)\rbrace
$$

- The prob. distribution of $\mathcal{L}_1[\mathcal{T}_N]$ for a Cayley tree of height $T+2$ can be estimated by the density

$$
\mathrm{P}_M(H)=\frac{1}{M}\sum_{\ell=1}^M\delta_{H;\,H_\ell(T)}
$$

- The above dynamics can be described by the equation

$$
\mathrm{P}_{t+1}(h)=\sum_{h_1}\cdots\sum_{h_{c-1}}\prod_{\ell=1}^{c-1}\mathrm{P}_{t}(h_\ell)\\\quad \times\sum_{r_1}\cdots\sum_{r_{c-1}}\prod_{\ell=1}^{c-1}\mathrm{P}_{q}(r_\ell)\\\quad \times\delta_{h;\,\max\lbrace r_1+h_1,\ldots,r_{c-1}+h_{c-1}\rbrace}
$$

- The boundary condition corresponding to the Cayley tree is given by

$$
\mathrm{P}_{0}(h)=\sum_{r_1}\cdots\sum_{r_{c-1}}\lbrace\prod_{\ell=1}^{c-1}\mathrm{P}_{q}(r_\ell)\rbrace\,\delta_{h;\,\max\lbrace r_1,\ldots,r_{c-1}\rbrace}
$$

- The prob. distribution of $\mathcal{L}_1[\mathcal{T}_N]$ for a Cayley tree of height $T+2$ is given by

$$
\mathrm{P}_{T+2}(H)=\sum_{h_1}\cdots\sum_{h_{c}}\prod_{\ell=1}^{c}\mathrm{P}_{T}(h_\ell)\\\quad \times\sum_{r_1}\cdots\sum_{r_{c}}\prod_{\ell=1}^{c}\mathrm{P}_{q}(r_\ell)\\\quad \times\delta_{H;\,\max\lbrace r_1+h_1,\ldots,r_{c}+h_{c}\rbrace}
$$

- Using that the prob. distribution $\mathrm{P}_q(r)$ is geometric with parameter $q$, one could try to solve above equations analytically. Also one could consider a single loop and see how this will change the [equation](#results-for-a-finite-connectivity-regime).
- For $q=1$ we have $r_{ji}=1$ with prob. $1$ and hence the latency of broadcast is dominated by the diameter $d$ of a random regular graph, i.e. the largest distance between any two nodes. The bounds (using the [Theorems 1 and 3](#bibliography)) for the latter for (very small) $\epsilon \gt 0$ are given by

$$
\lfloor\log_{c-1}(N)\rfloor+\left\lfloor\log_{c-1}\left(\log(N)\frac{c-2}{6c}\right)\right\rfloor+1\leq d \\\quad \leq \left\lceil\log_{c-1}(N)+\log_{c-1}((2+\epsilon)\,c\log(N))\right\rceil+1.
$$

## A Simple Model of Communication Latency in Consensus

- To model the communication latency of a node participating in consensus, we assume that latency has two dominant components which are due to delays in “mixing“ and “broadcast” (cf. the formula “Mixnet delay (gamma distribution) sampled once per block + PoL (constant) + final broadcast from exit mixnode (exponential distribution) sampled per node” used in consensus simulations).
- We assume that given a network of $N$ nodes, a gossiping-like mode of communication is used.
- Let us assume that the network topology used is a random regular graph $G_N=(V_N,E_N)$, where $V_N=[N]$ is the set of nodes and $E_N$ is the set of edges, with connectivity $c$. The latter is sampled only once and remains fixed for the duration of a consensus protocol.
- Furthermore, to each edge $\{i,j\}\in E_N$ we assign a random variable $d_{ij}$, sampled from some probability distribution, to model delays in communication links. This gives rise to the weighted graph $G_N[\{d_{ij}\}]$. The probability distribution could be [exponential](https://en.wikipedia.org/wiki/Exponential_distribution), with parameter $\lambda$ such that $1/\lambda$ is the average and $1/\lambda^2$ is the variance, or $d_{ij}=d$ for all $\{i,j\}\in E_N$ (cf. the “300ms” constant delay used in current estimates of latency).
- To model the mixing delay we assume, without loss of generality, that node $1$ sends (via $k$ mix nodes) a message to node $k+2$, and adopt the [single-path model](#single-path) as follows

$$
\Delta\sum_{\ell=1}^{k+1}r_\ell+ \sum_{\ell=1}^{k+1}D_{\ell\rightarrow \ell+1}%[G_N[\{d^\ell_{ij}\}]]
$$

- In above we assume that $k$ mix nodes, and the sender node $1$, introduce delays modeled by random variables $r_i$ sampled from the Geometric distribution with the parameter $q=1/2$. The latter models a queue which uses coin-flipping to remove a message. Here $\Delta$ is a cost of attempt to remove a message, measured in units of time, from the queue.
- The second part of above equation models the contribution of gossiping to the delay. Here $D_{i_1\rightarrow i_2}\equiv D_{i_1\rightarrow i_2}[G_N[\{d_{ij}\}]]$ is the “distance”, measured in units of time, between the nodes $i_1$ and $i_2$ on the graph $G_N[\{d_{ij}\}]$ which is defined as follows

$$
D_{i_1\rightarrow i_2}%[G_N[\{d_{ij}\}]]
=\min_{i_1\rightarrow i_2 }\sum_{(i,j)\in i_1\rightarrow i_2}d_{ij}
$$

- Furthermore, the distance $D_{\ell\rightarrow \ell+1}\equiv D_{\ell\rightarrow \ell+1}[G_N[\{d^\ell_{ij}\}]]$, i.e. samples of random variables $\{d^\ell_{ij}\}$ are different for different $\ell$ to model the gossiping aspect of communication.
- The distance $D_{i_1\rightarrow i_2}$ can be interpreted as the latency of (communication) path between the sender node $i_1$ and the receiver node $i_2$ when the gossiping mode of communication is used.
- We note that in a weighted graph $G_N[\{d_{ij}\}]$ the distance $D_{i_1\rightarrow i_2}$ can computed by using the [Dijkstra's algorithm](https://en.wikipedia.org/wiki/Dijkstra%27s_algorithm).
- To model the broadcast delay we assume, without loss of generality, that the node $k+2$ broadcasts the message, received from node $1$, to all nodes in the network. Assuming that gossiping is used the delay is $D_{k+2\rightarrow \ell}[G_N[\{d^\ell_{ij}\}]]$ for each node $\ell\in [N]\setminus k+2$.
- To simulate the mixing and broadcast delays in a consensus simulation the following algorithm can be used
    1. Generate a random regular graph $G_N$ with connectivity $c$.
    1. For the sender node $i_S$, sending a message to the receiver node $i_R$, sample (without replacement) the mix nodes $i_1,\ldots,i_k$ and $i_R$ from the set of all available nodes $[N]\setminus i_S$.
    1. Sample the random delays $r_1,\ldots,r_{k+1}$, from the geometric distribution with parameter $q=1/2$.
    1. Given the random regular graph $G_N$, generate the sequence of weighted graphs $G_N[\{d^1_{ij}\}],\ldots, G_N[\{d^{k+1}_{ij}\}]$ associated with each directed edge in the path $i_S\rightarrow i_1\rightarrow\ldots\rightarrow i_k\rightarrow i_R$ and compute the distances $D_{i_S\rightarrow i_1}, D_{i_1\rightarrow i_2},\ldots, D_{i_k\rightarrow i_R}$ on these graphs.
    1. Compute the mixing delay $\Delta\sum_{\ell=1}^{k+1}r_\ell+ D_{i_S\rightarrow i_1}+ D_{i_1\rightarrow i_2}+\cdots+ D_{i_k\rightarrow i_R}$​
    1. Given the same random regular graph $G_N$, generate the graph with random weights $G_N[\{d_{ij}\}]$ and for the node $i_R$ compute the distance $D_{i_R\rightarrow i}$ for all $i\in [N]\setminus i_R$ . The latter are broadcast delays.
    1. Repeat the steps 2 to 6 for each sender node.
- We note that when $d_{ij}=d$, i.e. all communication links have the same latency, then all distances $D_{i\rightarrow j}$ on the weighted graph $G_N[\{d_{ij}=d\}]$ can be precomputed which simplifies the steps 4 and 6 in the above algorithm.
- Also the algorithm can be easily adopted to use other models of random graphs, and other models of mixing and communication delays.

# Bibliography

Amir Dembo. Andrea Montanari. "Ising models on locally tree-like graphs." Ann. Appl. Probab. 20 (2) 565 - 592, April 2010. [https://doi.org/10.1214/09-AAP627](https://doi.org/10.1214/09-AAP627)

Hamed Amini. Marc Lelarge. "The diameter of weighted random graphs." Ann. Appl. Probab. 25 (3) 1686 - 1727, June 2015. [https://doi.org/10.1214/14-AAP1034](https://doi.org/10.1214/14-AAP1034)

Mézard, M., Parisi, G. “The Bethe lattice spin glass revisited.” Eur. Phys. J. B 20, 217–233 (2001). [https://doi.org/10.1007/PL00011099](https://doi.org/10.1007/PL00011099)

Bollobás, B., Fernandez de la Vega, W. “The diameter of random regular graphs.” Combinatorica 2, 125–134 (1982). [https://doi.org/10.1007/BF02579310](https://doi.org/10.1007/BF02579310)

