# ANALYSISCORRELATION-FUNCTIONS

| Field | Value |
| --- | --- |
| Name | [Analysis] Correlation Functions |
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

One of possible approaches to design a reliable anonymous communication (AC) system is to reduce statistical correlations between communicating nodes. Here we model a network of communicating nodes as a probabilistic discrete-state cellular automata (CA). We consider a node-centred approach where a node has associated with it variable representing its discrete state, such as sending, receiving, etc. Also we suggest a more granular connection-centred approach where discrete states of communication links of a node are considered. We note that message-centred approach is also possible but not pursued here. Finally, we discuss functions which can be used to quantify correlations in empirical analysis of AC systems.

## The “cellular automata” (CA) model

The system we consider is a network of communicating nodes where nodes are labelled by the set $[N]=\{1,\ldots,N\}$ .

We assume that nodes receive and send messages and these messages are indistinguishable, i.e. it is either impossible to observe bitstreams of messages, or incoming and outgoing messages are bitwise uncorrelated.

The node $i\in[N]$ at time $t$ can be in the state of either sending (message) or receiving (message) or inactive, i.e. neither sending or receiving. The latter is modelled by the variable $S\_i(t)\in\{-1,0,1\}$ as follows

| $S\_i(t)$ ​ | Node $i$ at time $t$ is |
| --- | --- |
| -1 | sending a message |
| 0 | inactive |
| 1 | receiving a message |

We note that a node can be in more states, for example in addition to sending, receiving, and inactive it could have an additional state of simultaneous sending and receiving, i.e. “send-receive” state. Additional states c can be modelled by extending the alphabet from which $S\_i(t)$ takes its values, i.e. $S\_i(t)\in\{1,2,\ldots,q\}$ for the most general case.

The vector $\mathbf{S}(t)=(S\_1(t),\ldots, S\_N(t))$ is the state of the network at time $t$ and for $t\in\{t\_0,t\_1,\ldots,t\_F\}$ , where $t\_0

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F12939053-ffb4-4900-a536-9604a2b8343f%2FScreenshot_2024-05-17_at_18.11.48.png?table=block&id=1fd261aa-09df-812c-8b14-e7447a9dd3fd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The state of the network as a function of time. The node $i\in [N]$ at time $t$ , represented by dot, is either sending (red dot) or receiving (blue dots) or inactive (white dot). All $N$ nodes are sending messages through $k$ nodes with $k=3$ .

ALT

Here we expect that dynamics of the network state $\mathbf{S}(t+\Delta t)$ is Markovian, i.e. depends only on $\mathbf{S}(t)$ , and can be described by the probability $\mathrm{P}(\mathbf{S}(t))$ . We note if the latter is factorises, i.e. $\mathrm{P}(\mathbf{S}(t))=\prod\_{i=1}^N \mathrm{P}\_i(\mathbf{S}(t))$ , for all $t$ then nodes are uncorrelated and “observing” any given node doesn’t reveal any information about the other node/nodes.

To take this research route further would require to derive master equation for $\mathrm{P}(\mathbf{S}(t))$ , to derive and analyse equations for correlation functions, etc.

## Empirical analysis of correlations in CA model

If node $i$ at time $t$ is in the state $S\_i(t)\in \{-1,0,1\}$ then the [Kronecker delta function](https://mathworld.wolfram.com/KroneckerDelta.html) is defined as follows

$$
\delta\_{S;S\_i(t)}=\Big\{ \begin{array}{c}
1, S=S\_i(t) \\
0, S\neq S\_i(t)
\end{array}
$$
δS;Si​(t)​={1,S=Si​(t)0,S=Si​(t)​

The sum $\sum\_{t\in \mathcal{T}}\delta\_{S;S\_i(t)}$ counts how many times node i was in state $s$ on the (ordered) set of times $\mathcal{T}=\{t\_0,t\_1,\ldots\}$ , where $\vert\mathcal{T}\vert=T$ . Additionally, the latter can be used to define the (empirical) frequency $\hat{P}\_i(S)=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)}$ .

The sum $\sum\_{i=1}^N\delta\_{S;S\_i(t)}$ counts number of nodes in the network which are in state $s$ at time $t$ and can be used to define the (empirical) frequency $\hat{P}\_t(S)=\frac{1}{N}\sum\_{i=1}^N\delta\_{S;S\_i(t)}$ .

The sum $\sum\_{i=1}^N\delta\_{S;S\_i(t)}\delta\_{\tilde{S};S\_i(t+t\_w)}$ counts how many nodes in the network were in state $S$ at time $t$ and in state $\tilde{s}$ at time $t+t\_w$ , where $t\_w>0$ , can be used to define the joint (empirical) frequency (or correlation function) $\hat{P}\_{t,t+t\_w}(S,\tilde{S})=\frac{1}{N}\sum\_{i=1}^N\delta\_{S;S\_i(t)}\delta\_{\tilde{S};S\_i(t+t\_w)}$ .

In a similar manner we can define the (spatial) correlation function

$$
C\_{t,t+t\_w}(S,\tilde{S})=\frac{2}{N(N-1)}\sum\_{iCt,t+tw​​(S,S~)=N(N−1)2​i<j∑​δS;Si​(t)​δS~;Sj​(t+tw​)​

In above the sum $\sum\_{i

## Node-centred approach

We adopt the [CA model](/1fd261aa09df81ff9278e23c51addfa4?pvs=25#1fd261aa09df81a39438fd17c225b730) where state of AC system at time $t$ is described by the vector $\mathbf{S}(t)=(S\_1(t),\ldots, S\_N(t))$ , where the variable $S\_i(t)$ is the state of node $i$ , such as receiving a message, sending a message, etc., at time $t$ . For example $S\_i(t)\in\{-1,0,1\}$ , where $-1$ corresponds to sending, $0$ corresponds to inactive and $1$ corresponds to receiving.

We note that a node connected to more than two nodes can be receiving and/or sending multiple messages at the same time. However, to simplify analysis we will assume that at any time a node can receive (or send) at most one message.

We assume that we have observed $T$ such vectors at times collected in the (ordered) set $\mathcal{T}=\{t\_0,t\_1,\ldots\}$ , where $\vert\mathcal{T}\vert=T$ .

|  |  |  |  |  |  |
| --- | --- | --- | --- | --- | --- |
|  | $t\_0$ ​ | $t\_1$ ​ | $t\_2$ ​ | $\cdots$ ​ | $t\_{T-1}$ ​ |
| $S\_1$ ​ | -1 | 0 | 1 | $\vdots$ ​ | -1 |
| $S\_2$ ​ | 0 | 1 | 0 | $\vdots$ ​ | 1 |
| $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ |
| $S\_i$ ​ | -1 | 0 | -1 | $\vdots$ ​ | 1 |
| $S\_j$ ​ | 1 | 0 | -1 | $\vdots$ ​ | 1 |
| $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ | $\vdots$ ​ |
| $S\_N$ ​ | 0 | 0 | 0 | $\cdots$ ​ | 1 |

We define the indicator function: $\delta\_{S;S\_i(t)}=1$ when $S=S\_i(t)$ and $0$ otherwise, i.e. this is the Kronecker delta function. The latter allows us to define various “correlation functions” such as the (empirical) frequency $\hat{P}\_i(S)=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)}$ , the joint frequency $\hat{P}\_{ij}(S,\tilde{S})=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)}\delta\_{\tilde{S};S\_j(t)}$ , etc.

In general the product $\delta\_{S\_{i\_1};S\_{i\_1}(t\_1)}\times\cdots\times\delta\_{S\_{i\_k};S\_{i\_k}(t\_k)}$ could be used to construct any correlation function.

## Connection-centred approach

The state of node $i$ , with respect to its connection to the node $j$ , at time $t$ is described by the variable $S\_{ij}(t)\in\{-1,0,1\}$ , where $-1$ corresponds to node $i$ sending message to node $j$ , $0$ corresponds to “no-communication” state between nodes and $1$ corresponds to node $i$ receiving a message from node $j$ .

We could use an extended alphabet as additional states may exist. For example, it is possible that node $i$ is both simultaneously sending a message to node $j$ and receiving a message from $j$ , i.e. node $i$ is in “send-receive” state. This situation can be modelled by the variable $S\_{ij}(t)\in\{\varnothing, -1,0,1\}$ , where $\varnothing$ corresponds to “no-communication” state between nodes, $-1$ corresponds to node $i$ sending message to node $j$ , $0$ corresponds to node i in “send-receive” state and $1$ corresponds to node $i$ receiving a message from node $j$ .

Let us define the set of nodes connected to the node $i$ as the (ordered) set $\partial i=\{i\_1,i\_2, \ldots,i\_c\}$ ( $\partial i$ notation here means “neighbourhood” of node $i$ ) then the state of node $i$ , with respect to all of its connections, at time $t$ is the (ordered by $\partial i$ ) set (or vector) $S\_i(t)=\{S\_{ij}(t)\vert j\in\partial i\}$ , i.e. the state of its connections at time $t$ . We note that “no-communication” and not being a member of $\partial i$ are different concepts.

Using above definition the state of all nodes at time $t$ can be described by the “vector”

$$
\mathbf{S}(t) = \begin{bmatrix}
S\_{1}(t) \\\vdots \\
S\_{i}(t) \\
\vdots \\
S\_{N}(t)
\end{bmatrix}
$$
S(t)=​S1​(t)⋮Si​(t)⋮SN​(t)​​

We note that $S\_{i}(t)\in\{-1,0,1\}^{\vert \partial i\vert}$ , i.e. $S\_{i}(t)$ can be any ternary string of length $\vert \partial i \vert$ . Hence $S\_{i}(t)$ can be represented by a single number from the set $[3^{\vert\partial i\vert}]$ once the mapping between the sets $\{-1,0,1\}^{\vert \partial i\vert}$ and $[3^{\vert\partial i\vert}]$ is fixed.

For $S\in\{-1,0,1\}^{\vert \partial i\vert}$ we can define the frequency for node $i$ as follows

$$
\hat{P}\_i(S)=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)},
$$
P^i​(S)=T1​t∈T∑​δS;Si​(t)​,

where $\delta\_{S; S\_i(t)}=\prod\_{j\in\partial i}\delta\_{S\_{j};S\_{ij}(t)}$ , which “counts” how many times connections of node $i$ , with respect to $\partial i$ , were in some specific communication “pattern” $S$ .

In a similar manner for $S\in\{-1,0,1\}^{\vert \partial i\vert}$ and $\tilde{S}\in\{-1,0,1\}^{\vert \partial j\vert}$ we can define the joint frequency

$$
\hat{P}\_{ij}(S,\tilde{S})=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)}\delta\_{\tilde{S};S\_j(t)}
$$
P^ij​(S,S~)=T1​t∈T∑​δS;Si​(t)​δS~;Sj​(t)​

for nodes $i$ and $j$ .

## Mutual information

For the joint frequency $\hat{P}\_{ij}(S,\tilde{S})=\frac{1}{T}\sum\_{t\in\mathcal{T}}\delta\_{S;S\_i(t)}\delta\_{\tilde{S};S\_j(t)}$ the (empirical) [mutual information](https://en.wikipedia.org/wiki/Mutual_information) $\hat{I}\_{ij}=\sum\_{S}\sum\_{\tilde{S}}\hat{P}\_{ij}(S,\tilde{S})\log\frac{\hat{P}\_{ij}(S,\tilde{S})}{\hat{P}\_i(S) \hat{P}\_j(\tilde{S})}$ can be used as a measure of dependence between states of node $i$ and $j$ . The latter can be used in both node-centric and connection-centric approaches.

## Hamming distance

The (normalised) [Hamming distance](https://en.wikipedia.org/wiki/Hamming_distance) between the vectors $\mathbf{S}(t)=(S\_1(t),\ldots, S\_N(t))$ and $\tilde{\mathbf{S}}(\tilde{t})=(\tilde{S}\_1(\tilde{t}),\ldots, \tilde{S}\_N(\tilde{t}))$ is the sum $\mathrm{D}\_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(\tilde{t}))=\frac{1}{N}\sum\_{i=1}^N\left(1-\delta\_{S\_i(t);\tilde{S}\_i(\tilde{t})}\right)$ , i.e. the number of disagreements between the $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(\tilde{t})$ is counted and divided by $N$ .

We note when $S\_i(t)$ is set (or vector) as in the section on connection-centric approach then $\delta\_{S\_i(t);\tilde{S}\_i(\tilde{t})}=\prod\_{j\in\partial i}\delta\_{S\_{ij}(t);\tilde{S}\_{ij}(\tilde{t})}$ , i.e. the latter is $1$ if and only if states of all connections of node $i$ in $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(t)$ are the same.

We note that $0\leq \mathrm{D}\_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(\tilde{t})) \leq1$ with $0$ when $\mathbf{S}(t)=\tilde{\mathbf{S}}(\tilde{t})$ and 1 when $S\_i(t)\neq \tilde{S}\_i(\tilde{t})$ for all $i\in[N]$ .

Assuming that we observe the states $\mathbf{S}(t)$ and $\tilde{\mathbf{S}}(t)$ of two systems on the same time-set $\mathcal{T}$ , where $\vert\mathcal{T}\vert=T$ , the (average) Hamming distance $\overline{D}\_H(T)=\frac{1}{T}\sum\_{t\in\mathcal{T}}\mathrm{D}\_H(\mathbf{S}(t)\vert\vert\tilde{\mathbf{S}}(t))$ measures how these two systems are different. We note that $0\leq\overline{D}\_H(T)\leq1$ with $0$ when $\mathbf{S}(t)=\tilde{\mathbf{S}}(t)$ for all $t\in\mathcal{T}$ and $1$ when $S\_i(t)\neq \tilde{S}\_i(t)$ for all $i\in[N]$ and all $t\in\mathcal{T}$ .

Let us assume we observed at times $t\in\mathcal{T}$ the states $\mathbf{S}^1(t)$ and $\mathbf{S}^2(t)$ of two copies of exactly the same AC system. That is the graph $G$ is the same in both copies, with exactly the same LEVEL 0 noise, i.e. if node $i$ in copy $1$ , described by $\mathbf{S}^1(t)$ , is sending a (LEVEL 0) message then node $i$ in copy $2$ , described by $\mathbf{S}^2(t)$ , is also sending the same message, etc. We note that the latter can be achieved in simulation which usually uses pseudo-randomness and hence evolution of AC system in time is deterministic. The latter implies that $\mathrm{D}\_H(\mathbf{S}^1(t)\vert\vert\mathbf{S}^2(t))=0$ for all $t\in\mathcal{T}$ and hence in this case $\overline{D}\_H(T)=0$ .

Let us now, without loss of generality, assume that node $1$ in the copy $2$ , described by $\mathbf{S}^2(t)$ , sent a LEVEL 2 message, through the nodes $2,3,\ldots, k-1$ , to the node $k$ at time $t\_0$ and node $k$ received this message at time $t\_1$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9a7bd2f3-f7ba-4d9b-a9f5-547db8c9ccaa%2Freplica2.png?table=block&id=1fd261aa-09df-8184-9afc-e82127a01d83&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We note that for $T0$ , i.e. the states of copies $1$ and $2$ , described by $\mathbf{S}^1(t)$ and $\mathbf{S}^2(t)$ , are different after the event at $t\_0$ .

\mathbf{S}(t) = \begin{bmatrix}
S\_{1}(t) \\\vdots \\
S\_{i}(t) \\
\vdots \\
S\_{N}(t)
\end{bmatrix}

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Correlation Functions

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Correlation-Functions-1fd261aa09df81ff9278e23c51addfa4?pvs=26&qid=1:12585907-925a-4e74-962b-42eedc2adb31:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Correlation Functions

Revision History

Table

Introduction

One of possible approaches to design a reliable anonymous communication (AC) system is to reduce statistical correlations between communicating nodes. Here we model a network of communicating nodes as a probabilistic discrete-state cellular automata (CA). We consider a node-centred approach where a node has associated with it variable representing its discrete state, such as sending, receiving, etc. Also we suggest a more granular connection-centred approach where discrete states of communication links of a node are considered. We note that message-centred approach is also possible but not pursued here. Finally, we discuss functions which can be used to quantify correlations in empirical analysis of AC systems.

The “cellular automata” (CA) model

- The system we consider is a network of communicating nodes where nodes are labelled by the set ΣEquation.
- We assume that nodes receive and send messages and these messages are indistinguishable, i.e. it is either impossible to observe bitstreams of messages, or incoming and outgoing messages are bitwise uncorrelated.
- The node ΣEquation at time ΣEquation can be in the state of either sending (message) or receiving (message) or inactive, i.e. neither sending or receiving. The latter is modelled by the variable ΣEquation as follows

Table

- We note that a node can be in more states, for example in addition to sending, receiving, and inactive it could have an additional state of simultaneous sending and receiving, i.e. “send-receive” state. Additional states c can be modelled by extending the alphabet from which ΣEquation takes its values, i.e. ΣEquation for the most general case.
- The vector ΣEquation is the state of the network at time ΣEquation and for ΣEquation, where ΣEquation, the (ordered by time) set of vectors ΣEquation is the path, through the state-space ΣEquation, taken by the system from the time ΣEquation to the time ΣEquation. The latter can be represented by a table (or matrix) as in the example below obtained from simulations.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F12939053-ffb4-4900-a536-9604a2b8343f%2FScreenshot_2024-05-17_at_18.11.48.png?table=block&id=1fd261aa-09df-812c-8b14-e7447a9dd3fd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Here we expect that dynamics of the network state ΣEquation is Markovian, i.e. depends only on ΣEquation, and can be described by the probability ΣEquation. We note if the latter is factorises, i.e. ΣEquation, for all ΣEquation then nodes are uncorrelated and “observing” any given node doesn’t reveal any information about the other node/nodes.
- To take this research route further would require to derive master equation for ΣEquation, to derive and analyse equations for correlation functions, etc.

Empirical analysis of correlations in CA model

- If node ΣEquation at time ΣEquation is in the state ΣEquation then the Kronecker delta function is defined as follows

📈Equation

- The sum ΣEquation counts how many times node i was in state ΣEquation on the (ordered) set of times ΣEquation, where ΣEquation. Additionally, the latter can be used to define the (empirical) frequency ΣEquation.
- The sum ΣEquation counts number of nodes in the network which are in state ΣEquation at time ΣEquation and can be used to define the (empirical) frequency ΣEquation.
- The sum ΣEquation counts how many nodes in the network were in state ΣEquation at time ΣEquation and in state ΣEquation at time ΣEquation, where ΣEquation, can be used to define the joint (empirical) frequency (or correlation function) ΣEquation.
- In a similar manner we can define the (spatial) correlation function

📈Equation

- In above the sum ΣEquation counts how many pairs of distinct nodes in the network (there are ΣEquation such pairs in total ) were in state ΣEquation and ΣEquation at, respectively, the time ΣEquation and ΣEquation

Node-centred approach

- We adopt the CA model where state of AC system at time ΣEquation is described by the vector ΣEquation, where the variable ΣEquation is the state of node ΣEquation, such as receiving a message, sending a message, etc., at time ΣEquation. For example ΣEquation, where ΣEquation corresponds to sending, ΣEquation corresponds to inactive and ΣEquation corresponds to receiving.
- We note that a node connected to more than two nodes can be receiving and/or sending multiple messages at the same time. However, to simplify analysis we will assume that at any time a node can receive (or send) at most one message.
- We assume that we have observed ΣEquation such vectors at times collected in the (ordered) set ΣEquation, where ΣEquation.

Table

- We define the indicator function: ΣEquation when ΣEquation and ΣEquation otherwise, i.e. this is the Kronecker delta function. The latter allows us to define various “correlation functions” such as the (empirical) frequency ΣEquation , the joint frequency ΣEquation, etc.
- In general the product ΣEquation could be used to construct any correlation function.

Connection-centred approach

- The state of node ΣEquation, with respect to its connection to the node ΣEquation, at time ΣEquation is described by the variable ΣEquation, where ΣEquation corresponds to node ΣEquation sending message to node ΣEquation, ΣEquation corresponds to “no-communication” state between nodes and ΣEquation corresponds to node ΣEquation receiving a message from node ΣEquation.
- We could use an extended alphabet as additional states may exist. For example, it is possible that node ΣEquation is both simultaneously sending a message to node ΣEquation and receiving a message from ΣEquation, i.e. node ΣEquation is in “send-receive” state. This situation can be modelled by the variable ΣEquation, where ΣEquation corresponds to “no-communication” state between nodes, ΣEquation corresponds to node ΣEquation sending message to node ΣEquation, ΣEquation corresponds to node i in “send-receive” state and ΣEquation corresponds to node ΣEquation receiving a message from node ΣEquation.
- Let us define the set of nodes connected to the node ΣEquation as the (ordered) set ΣEquation (ΣEquation notation here means “neighbourhood” of node ΣEquation) then the state of node ΣEquation, with respect to all of its connections, at time ΣEquation is the (ordered by ΣEquation ) set (or vector) ΣEquation, i.e. the state of its connections at time ΣEquation. We note that “no-communication” and not being a member of ΣEquation are different concepts.
- Using above definition the state of all nodes at time ΣEquation can be described by the “vector”

📈Equation

- We note that ΣEquation, i.e. ΣEquation can be any ternary string of length ΣEquation. Hence ΣEquation can be represented by a single number from the set ΣEquation once the mapping between the sets ΣEquation and ΣEquation is fixed.
- For ΣEquation we can define the frequency for node ΣEquation as follows

📈Equation

where ΣEquation, which “counts” how many times connections of node ΣEquation, with respect to ΣEquation, were in some specific communication “pattern” ΣEquation.

- In a similar manner for ΣEquation and ΣEquation we can define the joint frequency

📈Equation

for nodes ΣEquation and ΣEquation.

Mutual information

- For the joint frequency ΣEquation the (empirical) mutual information ΣEquation can be used as a measure of dependence between states of node ΣEquation and ΣEquation. The latter can be used in both node-centric and connection-centric approaches.

Hamming distance

- The (normalised) Hamming distance between the vectors ΣEquation and ΣEquation is the sum ΣEquation, i.e. the number of disagreements between the ΣEquation and ΣEquation is counted and divided by ΣEquation.
- We note when ΣEquation is set (or vector) as in the section on connection-centric approach then ΣEquation, i.e. the latter is ΣEquation if and only if states of all connections of node ΣEquation in ΣEquation and ΣEquation are the same.
- We note that ΣEquation with ΣEquation when ΣEquation and 1 when ΣEquation for all ΣEquation.
- Assuming that we observe the states ΣEquation and ΣEquation of two systems on the same time-set ΣEquation, where ΣEquation, the (average) Hamming distance ΣEquation measures how these two systems are different. We note that ΣEquation with ΣEquation when ΣEquation for all ΣEquation and ΣEquation when ΣEquation for all ΣEquation and all ΣEquation.
- Let us assume we observed at times ΣEquation the states ΣEquation and ΣEquation of two copies of exactly the same AC system. That is the graph ΣEquation is the same in both copies, with exactly the same LEVEL 0 noise, i.e. if node ΣEquation in copy ΣEquation, described by ΣEquation, is sending a (LEVEL 0) message then node ΣEquation in copy ΣEquation, described by ΣEquation, is also sending the same message, etc. We note that the latter can be achieved in simulation which usually uses pseudo-randomness and hence evolution of AC system in time is deterministic. The latter implies that ΣEquation for all ΣEquation and hence in this case ΣEquation.
- Let us now, without loss of generality, assume that node ΣEquation in the copy ΣEquation, described by ΣEquation, sent a LEVEL 2 message, through the nodes ΣEquation, to the node ΣEquation at time ΣEquation and node ΣEquation received this message at time ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9a7bd2f3-f7ba-4d9b-a9f5-547db8c9ccaa%2Freplica2.png?table=block&id=1fd261aa-09df-8184-9afc-e82127a01d83&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- We note that for ΣEquation we have ΣEquation because states of copies 1 and 2, described by ΣEquation and ΣEquation, are exactly the same before this event. For times ΣEquation we can have ΣEquation, i.e. the states of copies ΣEquation and ΣEquation, described by ΣEquation and ΣEquation, are different after the event at ΣEquation.

- Open in new tab
