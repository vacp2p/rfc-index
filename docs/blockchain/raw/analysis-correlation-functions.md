# ANALYSIS-CORRELATION-FUNCTIONS

| Field | Value |
| --- | --- |
| Name | [Analysis] Correlation Functions |
| Slug | 188 |
| Status | raw |
| Category | Informational |
| Editor | Alexander Mozeika <alexander.mozeika@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/analysis-correlation-functions.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/analysis-correlation-functions.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-09-08 |

# Introduction

One of possible approaches to design a reliable anonymous communication (AC) system is to reduce statistical correlations between communicating nodes. Here we model a network of communicating nodes as a probabilistic discrete-state cellular automata (CA). We consider a node-centred approach where a node has associated with it variable representing its discrete state, such as sending, receiving, etc. Also we suggest a more granular connection-centred approach where discrete states of communication links of a node are considered. We note that message-centred approach is also possible but not pursued here. Finally, we discuss functions which can be used to quantify correlations in empirical analysis of AC systems.

# The “cellular automata” (CA) model

- The system we consider is a network of communicating nodes where nodes are labelled by the set $[N]=\{1,\ldots,N\}$.
- We assume that nodes receive and send messages and these messages are indistinguishable, i.e. it is either impossible to observe bitstreams of messages, or incoming and outgoing messages are bitwise uncorrelated.
- The node $i\in[N]$ at time $t$ can be in the state of either sending (message) or receiving (message) or inactive, i.e. neither sending or receiving. The latter is modelled by the variable $S_i(t)\in\{-1,0,1\}$ as follows

| $S_i(t)$​ | Node $i$ at time $t$ is |
| --- | --- |
| -1 | sending a message |
| 0 | inactive |
| 1 | receiving a message |

- We note that  a node can be in more states, for example in addition to sending, receiving, and inactive it could have an additional state of simultaneous sending and receiving, i.e. “send-receive” state. Additional states c can be modelled by extending the alphabet from which $S_i(t)$ takes its values, i.e. $S_i(t)\in\{1,2,\ldots,q\}$ for the most general case.
- The vector $\mathbf{S}(t)=(S_1(t),\ldots, S_N(t))$ is the state of the network at time $t$ and for $t\in\{t_0,t_1,\ldots,t_F\}$, where $t_0<t_1<\ldots<t_F$, the (ordered by time) set of vectors $\mathbf{S}(t_0),  \mathbf{S}(t_1),\ldots,   \mathbf{S}(t_F)$ is the path, through the state-space $\{-1,0,1\}^N$, taken by the system from the time $t_0$ to the time $t_F$. The latter can be represented by a table (or matrix) as in the example below obtained from simulations.

![Diagram](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F12939053-ffb4-4900-a536-9604a2b8343f%2FScreenshot_2024-05-17_at_18.11.48.png?table=block&id=1fd261aa-09df-812c-8b14-e7447a9dd3fd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Here we expect that dynamics of the network state $\mathbf{S}(t+\Delta t)$ is Markovian, i.e. depends only on $\mathbf{S}(t)$, and can be described by the probability $\mathrm{P}(\mathbf{S}(t))$. We note if the latter is factorises, i.e. $\mathrm{P}(\mathbf{S}(t))=\prod_{i=1}^N \mathrm{P}_i(\mathbf{S}(t))$, for all $t$ then nodes are uncorrelated and “observing” any given node doesn’t reveal any information about the other node/nodes.
- To take this research route further would require to derive master equation for $\mathrm{P}(\mathbf{S}(t))$, to derive and analyse equations for correlation functions, etc.

# Empirical analysis of correlations in CA model

- If node $i$ at time $t$ is in the state $S_i(t)\in \{-1,0,1\}$ then  the [Kronecker delta function](https://mathworld.wolfram.com/KroneckerDelta.html) is defined as follows

$$
\delta_{S;S_i(t)}=\Big\{ \begin{array}{c} 
1, S=S_i(t) \\ 
0,  S\neq S_i(t)
\end{array}
$$

- The sum $\sum_{t\in \mathcal{T}}\delta_{S;S_i(t)}$ counts how many times node i was in state $s$ on the (ordered) set of times $\mathcal{T}=\{t_0,t_1,\ldots\}$, where $\vert\mathcal{T}\vert=T$. Additionally, the latter can be used to define the (empirical) frequency $\hat{P}_i(S)=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)}$.
- The sum $\sum_{i=1}^N\delta_{S;S_i(t)}$ counts number of nodes in the network which are in state $s$ at time $t$ and can be used to define the (empirical) frequency $\hat{P}_t(S)=\frac{1}{N}\sum_{i=1}^N\delta_{S;S_i(t)}$.
- The sum $\sum_{i=1}^N\delta_{S;S_i(t)}\delta_{\tilde{S};S_i(t+t_w)}$ counts how many nodes in the network were in state $S$ at time $t$ and in state $\tilde{s}$ at time $t+t_w$, where $t_w>0$, can be used to define the joint (empirical) frequency (or correlation function) $\hat{P}_{t,t+t_w}(S,\tilde{S})=\frac{1}{N}\sum_{i=1}^N\delta_{S;S_i(t)}\delta_{\tilde{S};S_i(t+t_w)}$.
- In a similar manner we can define the (spatial) correlation function

$$
C_{t,t+t_w}(S,\tilde{S})=\frac{2}{N(N-1)}\sum_{i<j}\delta_{S;S_i(t)}\delta_{\tilde{S};S_j(t+t_w)}
$$

- In above the sum $\sum_{i<j}\delta_{S;S_i(t)}\delta_{\tilde{S};S_j(t+t_w)}$ counts how many pairs of distinct nodes in the network (there are $N(N-1)/2$ such pairs in total ) were in state $s$ and $\tilde{s}$ at, respectively, the time $t$ and $t+t_w$​

# Node-centred approach

- We adopt the [CA model](https://nomos-tech.notion.site/1fd261aa09df81ff9278e23c51addfa4?pvs=25#1fd261aa09df81a39438fd17c225b730) where state of AC system at time $t$ is described by the vector $\mathbf{S}(t)=(S_1(t),\ldots, S_N(t))$, where the variable $S_i(t)$ is the state of node $i$, such as receiving a message, sending a message, etc., at time $t$. For example $S_i(t)\in\{-1,0,1\}$, where $-1$ corresponds to sending, $0$ corresponds to inactive and $1$ corresponds to receiving.
- We note that a node connected to more than two nodes can be receiving and/or sending multiple messages at the same time. However, to simplify analysis we will assume that at any time a node can receive (or send) at most one message.
- We assume that we have observed $T$ such vectors at times collected in the (ordered) set $\mathcal{T}=\{t_0,t_1,\ldots\}$, where $\vert\mathcal{T}\vert=T$.

|  | $t_0$​ | $t_1$​ | $t_2$​ | $\cdots$​ | $t_{T-1}$​ |
| --- | --- | --- | --- | --- | --- |
| $S_1$​ | -1 | 0 | 1 | $\vdots$​ | -1 |
| $S_2$​ | 0 | 1 | 0 | $\vdots$​ | 1 |
| $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ |
| $S_i$​ | -1 | 0 | -1 | $\vdots$​ | 1 |
| $S_j$​ | 1 | 0 | -1 | $\vdots$​ | 1 |
| $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ | $\vdots$​ |
| $S_N$​ | 0 | 0 | 0 | $\cdots$​ | 1 |

- We define the indicator function: $\delta_{S;S_i(t)}=1$ when $S=S_i(t)$ and $0$ otherwise, i.e. this is the Kronecker delta function. The latter allows us to define various “correlation functions” such as the (empirical) frequency $\hat{P}_i(S)=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)}$ , the joint frequency $\hat{P}_{ij}(S,\tilde{S})=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)}\delta_{\tilde{S};S_j(t)}$, etc.
- In general the product $\delta_{S_{i_1};S_{i_1}(t_1)}\times\cdots\times\delta_{S_{i_k};S_{i_k}(t_k)}$ could be used to construct any correlation function.

# Connection-centred approach

- The state of node $i$, with respect to its connection to the node $j$, at time $t$ is described by the variable $S_{ij}(t)\in\{-1,0,1\}$, where $-1$ corresponds to node $i$ sending message to node $j$, $0$ corresponds to “no-communication” state between nodes and $1$ corresponds to node $i$ receiving a message from node $j$.
- We could use an extended alphabet as additional states may exist. For example, it is possible that node $i$ is both simultaneously sending a message to node $j$ and receiving a message from $j$, i.e. node $i$ is in “send-receive” state. This situation can be modelled by the variable $S_{ij}(t)\in\{\varnothing, -1,0,1\}$, where $\varnothing$ corresponds to “no-communication” state between nodes, $-1$ corresponds to node $i$ sending message to node $j$, $0$ corresponds to node i in “send-receive” state and $1$ corresponds to node $i$ receiving a message from node $j$.
- Let us define the set of nodes connected to the node $i$ as the (ordered) set $\partial i=\{i_1,i_2, \ldots,i_c\}$ ($\partial i$ notation here means “neighbourhood” of node $i$) then the state of node $i$, with respect to all of its connections, at time $t$ is the (ordered by $\partial i$ ) set (or vector) $S_i(t)=\{S_{ij}(t)\vert j\in\partial i\}$, i.e. the state of its connections at time $t$. We note that “no-communication” and not being a member of $\partial i$ are different concepts.
- Using above definition the state of all nodes at time $t$ can be described by the “vector”

$$
\mathbf{S}(t) = \begin{bmatrix}
S_{1}(t)  \\\vdots  \\
S_{i}(t)  \\
\vdots  \\
S_{N}(t) 
\end{bmatrix}
$$

- We note that $S_{i}(t)\in\{-1,0,1\}^{\vert \partial i\vert}$, i.e. $S_{i}(t)$ can be any ternary string of length $\vert \partial i \vert$. Hence $S_{i}(t)$ can be represented by a single number from the set $[3^{\vert\partial i\vert}]$ once the mapping between the sets $\{-1,0,1\}^{\vert \partial i\vert}$ and $[3^{\vert\partial i\vert}]$ is fixed.
- For $S\in\{-1,0,1\}^{\vert \partial i\vert}$ we can define the frequency for node $i$ as follows

$$
\hat{P}_i(S)=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)},
$$

where $\delta_{S; S_i(t)}=\prod_{j\in\partial  i}\delta_{S_{j};S_{ij}(t)}$, which “counts” how many times connections of node $i$, with respect to $\partial i$, were in some specific communication “pattern” $S$.

- In a similar manner for $S\in\{-1,0,1\}^{\vert \partial i\vert}$ and $\tilde{S}\in\{-1,0,1\}^{\vert \partial j\vert}$ we can define the joint frequency

$$
\hat{P}_{ij}(S,\tilde{S})=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)}\delta_{\tilde{S};S_j(t)}
$$

for nodes $i$ and $j$.

# Mutual information

- For the joint frequency $\hat{P}_{ij}(S,\tilde{S})=\frac{1}{T}\sum_{t\in\mathcal{T}}\delta_{S;S_i(t)}\delta_{\tilde{S};S_j(t)}$ the (empirical) [mutual information](https://en.wikipedia.org/wiki/Mutual_information) $\hat{I}_{ij}=\sum_{S}\sum_{\tilde{S}}\hat{P}_{ij}(S,\tilde{S})\log\frac{\hat{P}_{ij}(S,\tilde{S})}{\hat{P}_i(S) \hat{P}_j(\tilde{S})}$ can be used as a measure of dependence between states of node $i$ and $j$. The latter can be used in both node-centric and connection-centric approaches.

# Hamming distance

- The (normalised) [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) between the vectors $\mathbf{S}(t)=(S_1(t),\ldots, S_N(t))$ and $\tilde{\mathbf{S}}(\tilde{t})=(\tilde{S}_1(\tilde{t}),\ldots, \tilde{S}_N(\tilde{t}))$ is the sum $\mathrm{D}_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(\tilde{t}))=\frac{1}{N}\sum_{i=1}^N\left(1-\delta_{S_i(t);\tilde{S}_i(\tilde{t})}\right)$, i.e. the  number of disagreements between the $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(\tilde{t})$ is counted and divided by $N$.
- We note when $S_i(t)$ is set (or vector) as in the section on connection-centric approach then $\delta_{S_i(t);\tilde{S}_i(\tilde{t})}=\prod_{j\in\partial  i}\delta_{S_{ij}(t);\tilde{S}_{ij}(\tilde{t})}$, i.e. the latter is $1$ if and only if states of all connections of node $i$ in $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(t)$ are the same.
- We note that $0\leq \mathrm{D}_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(\tilde{t})) \leq1$ with $0$ when $\mathbf{S}(t)=\tilde{\mathbf{S}}(\tilde{t})$ and 1 when $S_i(t)\neq \tilde{S}_i(\tilde{t})$ for all $i\in[N]$.
- Assuming that we observe the states $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(t)$ of two systems on the same time-set $\mathcal{T}$, where $\vert\mathcal{T}\vert=T$, the (average) Hamming distance $\overline{D}_H(T)=\frac{1}{T}\sum_{t\in\mathcal{T}}\mathrm{D}_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(t))$ measures how these two systems are different. We note that $0\leq\overline{D}_H(T)\leq1$ with $0$ when $\mathbf{S}(t)=\tilde{\mathbf{S}}(t)$ for all $t\in\mathcal{T}$ and $1$ when $S_i(t)\neq \tilde{S}_i(t)$ for all $i\in[N]$ and all $t\in\mathcal{T}$.
- Let us assume we observed at times $t\in\mathcal{T}$ the states $\mathbf{S}^1(t)$ and $\mathbf{S}^2(t)$ of two copies of exactly the same AC system. That is the graph $G$ is the same in both copies, with exactly the same LEVEL 0 noise, i.e. if node $i$ in copy $1$, described by $\mathbf{S}^1(t)$, is sending a (LEVEL 0) message then node $i$ in copy $2$, described by $\mathbf{S}^2(t)$, is also sending the same message, etc. We note that the latter can be achieved in simulation which usually uses pseudo-randomness and hence evolution of AC system in time is deterministic. The latter implies that $\mathrm{D}_H(\mathbf{S}^1(t)\vert\vert\mathbf{S}^2(t))=0$ for all $t\in\mathcal{T}$ and hence in this case $\overline{D}_H(T)=0$.
- Let us now, without loss of generality, assume that node $1$ in the copy $2$, described by $\mathbf{S}^2(t)$, sent a LEVEL 2 message, through the nodes $2,3,\ldots, k-1$, to the node $k$ at time $t_0$ and node $k$ received this message at time $t_1$.

![Diagram](https://nomos-tech.notion.site/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9a7bd2f3-f7ba-4d9b-a9f5-547db8c9ccaa%2Freplica2.png?table=block&id=1fd261aa-09df-8184-9afc-e82127a01d83&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that for $T<t_0$ we have $\overline{D}_H(T)=0$ because states of copies 1 and 2, described by $\mathbf{S}^1(t)$ and $\mathbf{S}^2(t)$, are exactly the same before this event. For times $T\geq t_0$ we can have $\overline{D}_H(T)>0$, i.e. the states of copies $1$ and $2$, described by $\mathbf{S}^1(t)$ and $\mathbf{S}^2(t)$, are different after the event at $t_0$.

