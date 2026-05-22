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

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2026-03-20
Introduction 
We consider latency of a broadcast on the network constructed from mix nodes which use queues to store in-coming and out-going messages. A message is removed from the queue with probability 
𝑞
q which delays messages by a random amount of time governed by the Geometric distribution with parameter 
𝑞
q. The other source of message delays are due to the latency in communication links which we assume to be “frozen”, i.e. not changing with time. We show that for a single path constructed from 
𝑘
k mix nodes the average message latency is proportional to 
𝑘
/
𝑞
k/q and we estimate the probability of latency being greater than the average. Furthermore, we consider latency of a broadcast on the network with the topology of a random regular graph with connectivity 
𝑐
c. Here we find that the latency of broadcast, divided by 
log
⁡
(
𝑁
)
log(N), is approaching  
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
1
log
⁡
(
1
+
𝑞
)
c(c−2)
2(c−1)
	​

log(1+q)
1
	​

 for a small probability of message removal 
𝑞
q as the number of nodes in the network 
𝑁
N is growing. However, for finite 
𝑁
N the distribution of latency can have long tails. We note that the latter result is established semi-analytically and only for trees we managed to develop a complete analytical framework which can be used to compute the latency of a broadcast. Finally, in this document we propose a simple model of communication latency in consensus. 
Analysis
Single Node
Assuming that a message is removed from the queue of a node with probability 
𝑞
q (see the document), a message in node 
𝑖
i is delayed by (at most) 
𝑟
𝑖
Δ
𝑖
r
i
	​

Δ
i
	​

, where 
𝑟
𝑖
r
i
	​

 is a random variable from the Geometric distribution with parameter 
𝑞
q and 
Δ
𝑖
Δ
i
	​

 is a “cost” of one attempt of removing a message.
Assuming that node 
𝑖
i has 
𝑐
c connections and it puts a message into all out-queues associated with these connections, i.e. the node 
𝑖
i is sending a message. The message will be delayed by (at most) 
𝑟
𝑖
(
1
)
Δ
𝑖
r
i
	​

(1)Δ
i
	​

 in the queue 
1
1, by 
𝑟
𝑖
(
2
)
Δ
𝑖
r
i
	​

(2)Δ
i
	​

 in the queue 
2
2, etc., where 
𝑟
𝑖
(
1
)
,
…
,
𝑟
𝑖
(
𝑐
)
r
i
	​

(1),…,r
i
	​

(c) is sample from the Geometric distr. with parameter 
𝑞
q.
Assuming that node 
𝑖
i has 
𝑐
c connections and it puts a message into all out-queues but not the queue associated with the connection labelled by 
𝑐
c, i.e. the node is relaying a message, the message will be delayed by (at most) 
𝑟
𝑖
(
1
)
Δ
𝑖
r
i
	​

(1)Δ
i
	​

 in the queue 
1
1, by 
𝑟
𝑖
(
2
)
Δ
𝑖
r
i
	​

(2)Δ
i
	​

in the queue 
2
2, etc., where 
𝑟
𝑖
(
1
)
,
…
,
𝑟
𝑖
(
𝑐
−
1
)
r
i
	​

(1),…,r
i
	​

(c−1) is sample from the Geometric distr. with parameter 
𝑞
q.
Single Path
Without loss of generality, we consider a message traveling from node 
1
1 to node 
𝑘
k. A message is delayed at the node 
1
1 by 
𝑟
1
Δ
1
r
1
	​

Δ
1
	​

, at the node 
2
2 by 
𝑟
2
Δ
2
r
2
	​

Δ
2
	​

, etc. For node 
𝑖
i we assume that 
𝑟
𝑖
r
i
	​

 is a random variable from the Geometric distribution with parameter 
𝑞
q and that 
Δ
𝑖
>
0
Δ
i
	​

>0. The latter is prop. to a max. time elapsed between attempts to “flip a coin”. Furthermore, a message traveling between the nodes 
𝑖
i and 
𝑗
j is delayed by 
𝑑
𝑖
𝑗
d
ij
	​

. 
Using above the total delay is given by 
∑
𝑖
=
1
𝑘
𝑟
𝑖
Δ
𝑖
+
∑
𝑖
=
1
𝑘
−
1
𝑑
𝑖
𝑖
+
1
∑
i=1
k
	​

r
i
	​

Δ
i
	​

+∑
i=1
k−1
	​

d
ii+1
	​

. We note that for 
Δ
=
max
⁡
𝑖
∈
[
𝑘
]
Δ
𝑖
Δ=max
i∈[k]
	​

Δ
i
	​

 and 
𝑑
=
max
⁡
𝑖
∈
[
𝑘
−
1
]
𝑑
𝑖
𝑖
+
1
d=max
i∈[k−1]
	​

d
ii+1
	​

 we have 
∑
𝑖
=
1
𝑘
𝑟
𝑖
Δ
𝑖
+
∑
𝑖
=
1
𝑘
−
1
𝑑
𝑖
𝑖
+
1
≤
Δ
∑
𝑖
=
1
𝑘
𝑟
𝑖
+
(
𝑘
−
1
)
𝑑
i=1
∑
k
	​

r
i
	​

Δ
i
	​

+
i=1
∑
k−1
	​

d
ii+1
	​

≤Δ
i=1
∑
k
	​

r
i
	​

+(k−1)d
The sum 
𝑟
=
∑
𝑖
=
1
𝑘
𝑟
𝑖
r=∑
i=1
k
	​

r
i
	​

 is random variable from the negative binomial distribution 
𝑃
𝑘
,
𝑞
(
𝑟
)
=
(
𝑟
−
1
𝑘
−
1
)
𝑞
𝑘
(
1
−
𝑞
)
𝑟
−
𝑘
,
w
h
e
r
e
 
 
𝑟
∈
{
𝑘
,
𝑘
+
1
,
…
}
.
P
k,q
	​

(r)=(
k−1
r−1
	​

)q
k
(1−q)
r−k
,wherer∈{k,k+1,…}.
Using that 
𝑟
𝑖
r
i
	​

 is a random variable from the Geometric distribution with parameter 
𝑞
q the average and variance of the total delay 
∑
𝑖
=
1
𝑘
𝑟
𝑖
Δ
𝑖
+
∑
𝑖
=
1
𝑘
−
1
𝑑
𝑖
𝑖
+
1
∑
i=1
k
	​

r
i
	​

Δ
i
	​

+∑
i=1
k−1
	​

d
ii+1
	​

 is given, respectively, by 
∑
𝑖
=
1
𝑘
Δ
𝑖
/
𝑞
+
∑
𝑖
=
1
𝑘
−
1
𝑑
𝑖
𝑖
+
1
∑
i=1
k
	​

Δ
i
	​

/q+∑
i=1
k−1
	​

d
ii+1
	​

 and 
1
−
𝑞
𝑞
2
∑
𝑖
=
1
𝑘
Δ
𝑖
2
q
2
1−q
	​

∑
i=1
k
	​

Δ
i
2
	​

. The latter, for 
Δ
=
Δ
𝑖
Δ=Δ
i
	​

 and 
𝑑
=
𝑑
𝑖
𝑖
+
1
d=d
ii+1
	​

 , is simplifies to 
𝑘
Δ
/
𝑞
+
(
𝑘
−
1
)
𝑑
kΔ/q+(k−1)d and 
1
−
𝑞
𝑞
2
𝑘
Δ
2
q
2
1−q
	​

kΔ
2
. 
The histogram of delays 
∑
𝑖
=
1
𝑘
𝑟
𝑖
Δ
𝑖
+
∑
𝑖
=
1
𝑘
−
1
𝑑
𝑖
𝑖
+
1
∑
i=1
k
	​

r
i
	​

Δ
i
	​

+∑
i=1
k−1
	​

d
ii+1
	​

 of 
𝑁
𝑚
=
10
6
N
m
	​

=10
6
 messages traveling through 
𝑘
=
5
k=5 nodes (red histogram bars) is compared with negative binomial (o symbols) with parameters 
𝑘
=
5
k=5 and 
𝑞
=
1
/
2
q=1/2. Here we assumed that 
Δ
𝑖
=
1
Δ
i
	​

=1 and 
𝑑
𝑖
𝑖
+
1
=
0
d
ii+1
	​

=0. 
The mean of sum 
∑
𝑖
=
1
𝑘
𝑟
𝑖
∑
i=1
k
	​

r
i
	​

 is equals to 
𝑘
/
𝑞
k/q. For 
𝜖
>
0
ϵ>0 the probability 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q) can bounded from above as follows 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
≤
(
𝑞
(
𝜖
−
1
)
+
1
1
−
𝑞
)
𝑘
(
𝑞
(
𝜖
−
1
)
+
1
(
1
−
𝑞
)
(
𝜖
𝑞
+
1
)
)
−
𝑘
(
1
+
𝜖
)
𝑞
P(
i=1
∑
k
	​

r
i
	​

≥(1+ϵ)k/q)≤(
1−q
q(ϵ−1)+1
	​

)
k
(
(1−q)(ϵq+1)
q(ϵ−1)+1
	​

)
−
q
k(1+ϵ)
	​

To show the above we used 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
=
P
(
e
𝜆
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
e
𝜆
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q)=P(e
λ∑
i=1
k
	​

r
i
	​

≥e
λ(1+ϵ)k/q
) for any 
𝜆
>
0
λ>0 and Markov’s inequality. 
The prob. 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q) as a function of 
𝑘
k plotted for 
𝑞
=
1
/
2
q=1/2 and 
𝜖
=
1
ϵ=1. Here the simulation (red + symbols) is compared with the upper bound (blue square symbols). In simulation the prob. distr. of 
∑
𝑖
=
1
𝑘
𝑟
𝑖
∑
i=1
k
	​

r
i
	​

 was represented by 
𝑁
=
10
6
N=10
6
 samples of random variables 
𝑟
1
,
…
,
𝑟
𝑘
r
1
	​

,…,r
k
	​

 generated from the Geometric distribution with parameter 
𝑞
q. 
The probability 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q) is increasing with decreasing 
𝑞
q for 
𝑞
<
1
/
2
q<1/2​
The prob. 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q) as a function of 
𝑘
k plotted for 
𝑞
=
1
/
4
q=1/4 and 
𝜖
=
1
ϵ=1. Here the simulation (red + symbols) is compared with the upper bound (blue square symbols). In simulation the prob. distr. of 
∑
𝑖
=
1
𝑘
𝑟
𝑖
∑
i=1
k
	​

r
i
	​

 was represented by 
𝑁
=
10
6
N=10
6
 samples of random variables 
𝑟
1
,
…
,
𝑟
𝑘
r
1
	​

,…,r
k
	​

 generated from the Geometric distribution with parameter 
𝑞
q. 
and decreasing with increasing 
𝑞
q for 
𝑞
>
1
/
2
q>1/2 
The prob. 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
P(∑
i=1
k
	​

r
i
	​

≥(1+ϵ)k/q) as a function of 
𝑘
k plotted for 
𝑞
=
3
/
4
q=3/4 and 
𝜖
=
1
ϵ=1. Here the simulation (red + symbols) is compared with the upper bound (blue square symbols). In simulation the prob. distr. of 
∑
𝑖
=
1
𝑘
𝑟
𝑖
∑
i=1
k
	​

r
i
	​

 was represented by 
𝑁
=
10
6
N=10
6
 samples of random variables 
𝑟
1
,
…
,
𝑟
𝑘
r
1
	​

,…,r
k
	​

 generated from the Geometric distribution with parameter 
𝑞
q. 
We note that the upper bound can be represented as 
P
(
∑
𝑖
=
1
𝑘
𝑟
𝑖
≥
(
1
+
𝜖
)
𝑘
/
𝑞
)
≤
𝑓
𝑘
(
𝑞
,
𝜖
)
,
w
h
e
r
e
                                         
𝑓
(
𝑞
,
𝜖
)
=
(
𝑞
(
𝜖
−
1
)
+
1
1
−
𝑞
)
(
𝑞
(
𝜖
−
1
)
+
1
(
1
−
𝑞
)
(
𝜖
𝑞
+
1
)
)
−
(
1
+
𝜖
)
𝑞
.
P(
i=1
∑
k
	​

r
i
	​

≥(1+ϵ)k/q)≤f
k
(q,ϵ),where
                                         f(q,ϵ)=(
1−q
q(ϵ−1)+1
	​

)(
(1−q)(ϵq+1)
q(ϵ−1)+1
	​

)
−
q
(1+ϵ)
	​

.
𝑓
(
𝑞
,
𝜖
)
f(q,ϵ) as a function of 
𝑞
q and 
𝜖
ϵ. 
Plotting 
𝑓
(
𝑞
,
𝜖
)
f(q,ϵ) suggests that the upper bound is monotonic decreasing function of 
𝑘
k, 
𝜖
ϵ and 
𝑞
q. 
Random Networks
Configuration Model
Let us consider the probability distribution 
P
(
𝑐
)
P(c) over the non-negative integers 
𝑐
≥
0
c≥0 such that 
∑
𝑐
≥
0
P
(
𝑐
)
 
𝑐
<
∞
∑
c≥0
	​

P(c)c<∞ and define the probability distribution 
Q
(
𝑐
)
=
𝑐
 
P
(
𝑐
)
∑
𝑐
~
≥
0
𝑐
~
 
P
(
𝑐
~
)
Q(c)=
∑
c
~
≥0
	​

c
~
P(
c
~
)
cP(c)
	​

We consider the random rooted tree generated as follows. First, we sample 
𝑐
c from the distr. 
P
(
𝑐
)
P(c) and connect the root node to 
𝑐
c offspring nodes. Second, for each offspring node we sample 
𝑐
c from the distr. 
Q
(
𝑐
)
Q(c) and connect to 
𝑐
−
1
c−1 nodes. The latter is repeated until the tree 
𝑇
(
ℎ
)
T(h) of height 
ℎ
h is generated. 
We consider the random graph 
𝐺
𝑁
=
(
𝑉
𝑁
,
𝐸
𝑁
)
G
N
	​

=(V
N
	​

,E
N
	​

), where 
𝑉
𝑁
=
[
𝑁
]
V
N
	​

=[N] is the set of nodes and 
𝐸
𝑁
E
N
	​

 is the set of edges, generated by connecting nodes with connectivities sampled from the probability distribution 
P
(
𝑐
)
P(c), i.e. the “configuration model”. 
For 
𝑁
→
∞
N→∞ we have that 
𝐵
𝑖
(
ℎ
)
≃
𝑇
(
ℎ
)
B
i
	​

(h)≃T(h), where 
𝐵
𝑖
(
ℎ
)
B
i
	​

(h) is the subgraph of 
𝐺
𝑁
G
N
	​

 induced by nodes at a distance (length of shortest path between two nodes) at most 
ℎ
h from the node 
𝑖
∈
[
𝑁
]
i∈[N], with high probability. 
A special case 
𝐺
𝑁
G
N
	​

 is a random regular graph (RRG) of connectivity 
𝑐
c, i.e. each node in 
𝐺
𝑁
G
N
	​

 is connected to exactly 
𝑐
c nodes. 
Distance on a graph and latency of a broadcast 
Let us assume, without loss of generality, that node 
1
1 in this network wants to send a message to the all 
𝑁
−
1
N−1 nodes of network. 
A node puts a message in to all of its out-queues. Assuming that coin-flipping algorithm is used to remove a message from the queue, we have that a message is delayed by (at most) 
𝑟
Δ
1
rΔ
1
	​

 (see previous section), where 
𝑟
r random variable from the Geometric distribution with parameter 
𝑞
q. A message is delayed further in a communication link and hence, for example, a message sent from the node 
1
1 to the node 
2
2 is delayed (at most) by 
𝑟
12
Δ
1
+
𝑑
12
r
12
	​

Δ
1
	​

+d
12
	​

. We note that copies of the same message, sent to other neighbours of node 
1
1, are delayed in a similar manner. 
For node 
𝑖
i sending a message to its neighbour 
𝑗
j the delay is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

. 
The total delay of a message sent from the node 
1
1 to the node 
𝑖
∈
[
𝑁
]
∖
1
i∈[N]∖1 is the sum of delays
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
{
𝑟
𝑖
𝑗
(
1
)
Δ
𝑖
+
𝑑
𝑖
𝑗
}
(i,j)∈1→i
∑
	​

{r
ij
	​

(1)Δ
i
	​

+d
ij
	​

}
 along the (directed) path from node 
1
1 to node 
𝑖
i, 
1
→
𝑖
1→i .
Let us define the distance between node 1 and node 
𝑖
∈
[
𝑁
]
∖
1
i∈[N]∖1 as the 
𝐷
1
→
𝑖
[
𝐺
𝑁
]
=
min
⁡
1
→
𝑖
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
{
𝑟
𝑖
𝑗
(
1
)
Δ
𝑖
+
𝑑
𝑖
𝑗
}
D
1→i
	​

[G
N
	​

]=
1→i
min
	​

(i,j)∈1→i
∑
	​

{r
ij
	​

(1)Δ
i
	​

+d
ij
	​

}
 i.e. the minimum total delay over all (directed) paths from node 1 to node i. 
Now the maximum distance 
max
⁡
𝑖
∈
[
𝑁
]
∖
1
𝐷
1
→
𝑖
[
𝐺
𝑁
]
=
max
⁡
𝑖
∈
[
𝑁
]
∖
1
min
⁡
1
→
𝑖
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
{
𝑟
𝑖
𝑗
(
1
)
Δ
𝑖
+
𝑑
𝑖
𝑗
}
i∈[N]∖1
max
	​

D
1→i
	​

[G
N
	​

]=
i∈[N]∖1
max
	​

1→i
min
	​

(i,j)∈1→i
∑
	​

{r
ij
	​

(1)Δ
i
	​

+d
ij
	​

}
i.e. the maximum over distances between node 
1
1 and all other nodes, is the time that elapsed from the event “node 
1
1 sent a message” to the event “the message was delivered to all nodes”. 
Thus 
max
⁡
𝑖
∈
[
𝑁
]
∖
1
𝐷
1
→
𝑖
[
𝐺
𝑛
]
max
i∈[N]∖1
	​

D
1→i
	​

[G
n
	​

] is the latency of broadcast from node 
1
1. Let us define the latter as 
𝐿
1
[
𝐺
𝑁
]
=
max
⁡
𝑖
∈
[
𝑁
]
∖
1
𝐷
1
→
𝑖
[
𝐺
𝑁
]
L
1
	​

[G
N
	​

]=
i∈[N]∖1
max
	​

D
1→i
	​

[G
N
	​

]
We note that maximum distance can be computed using Dijkstra's algorithm. 
Finally, for all pairs of distinct nodes we define the diameter of 
𝐺
𝑁
G
N
	​

 as follows 
𝐷
[
𝐺
𝑁
]
=
max
⁡
𝑖
≠
𝑗
𝐷
𝑖
→
𝑗
[
𝐺
𝑁
]
D[G
N
	​

]=
i

=j
max
	​

D
i→j
	​

[G
N
	​

]
A single message is sent from node 
1
1 to all 
𝑁
−
1
N−1 nodes of the network. The latter has topology of a random regular graph of connectivity 
𝑐
=
3
c=3 which is locally tree-like for large 
𝑁
N. The total delay of a message sent from node 
1
1 to node 
4
4, via the nodes 
2
2 and 
3
3, is given by the sum 
∑
𝑗
=
2
4
[
𝑟
𝑗
−
1
𝑗
Δ
𝑗
−
1
+
𝑑
𝑗
−
1
𝑗
]
∑
j=2
4
	​

[r
j−1j
	​

Δ
j−1
	​

+d
j−1j
	​

]. 
Results for a High Connectivity Regime
We consider networks with topology of a random regular graph in the high connectivity regime of 
𝑐
=
𝛼
𝑁
c=αN, where 
𝛼
∈
(
0
,
1
)
α∈(0,1), with 
Δ
𝑖
=
1
Δ
i
	​

=1 and 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0. 
First we consider the case of 
𝑐
=
𝑁
−
1
c=N−1, i.e. the network is a complete graph, where the least latency is expected. Measuring the latency of broadcast for 
𝑁
=
{
10
,
10
2
,
10
3
}
N={10,10
2
,10
3
}, we see that it is increasing as 
𝑞
→
0
q→0 and decreasing as 
𝑞
→
1
q→1 as can be seen in the figure below. 
Statistics of message latencies computed for the number of messages 
𝑀
∈
{
10
5
,
10
6
}
M∈{10
5
,10
6
} (bottom, top and middle) broadcasted on the network of 
𝑁
∈
{
10
,
10
2
,
10
3
}
N∈{10,10
2
,10
3
} nodes. The latter has the topology of a complete graph. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
∈
{
1
/
100
,
1
/
10
,
…
,
9
/
10
}
q∈{1/100,1/10,…,9/10}. The black dashed horizontal line corresponds to 
2
2. The blue dashed horizontal line corresponds to 
0
0.
Furthermore, as 
𝑁
N is increased from 
𝑁
=
10
N=10 to 
𝑁
=
10
3
N=10
3
 the latency of broadcast becomes more concentrated on the value of 2 as can be seen in figures below. 
The histogram of message latencies computed for the 
𝑀
∈
{
10
5
,
10
6
}
M∈{10
5
,10
6
} (top and middle, bottom) messages broadcasted for the network of 
𝑁
=
{
10
,
10
2
,
10
3
}
N={10,10
2
,10
3
} nodes. The latter has topology of a complete graph. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with the parameter 
𝑞
=
{
1
/
10
,
1
/
2
,
9
/
10
}
q={1/10,1/2,9/10} (left, middle, right). 
Finally, we consider random regular graph in the high connectivity regime of 
𝑐
=
𝛼
𝑁
c=αN, where 
𝛼
∈
(
0
,
1
)
α∈(0,1). 
Statistics of message latencies computed for 
𝑀
∈
{
10
5
,
10
6
}
M∈{10
5
,10
6
} (bottom, top and middle) messages broadcasted on the network of 
𝑁
∈
{
10
,
10
2
,
10
3
}
N∈{10,10
2
,10
3
} nodes. The latter has topology of a random regular graph with connectivity 
𝑁
/
2
N/2. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
∈
{
1
/
100
,
1
/
10
,
…
,
9
/
10
}
q∈{1/100,1/10,…,9/10}. The black dashed horizontal line corresponds to 
2
2. The blue dashed horizontal line corresponds to 
0
0. 
The histogram of message latencies computed for the 
𝑀
∈
{
10
5
,
10
6
}
M∈{10
5
,10
6
} (top and middle, bottom) messages broadcasted for the network of 
𝑁
=
{
10
,
10
2
,
10
3
}
N={10,10
2
,10
3
} nodes. The latter has topology of a random regular graph of connectivity 
𝑁
/
2
N/2. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with the parameter 
𝑞
=
{
1
/
10
,
1
/
2
,
9
/
10
}
q={1/10,1/2,9/10} (left, middle, right). 
Results for a Finite Connectivity Regime
We consider broadcast on networks with topology of a random regular graph in the finite connectivity regime of 
𝑐
≪
𝑁
c≪N with 
Δ
𝑖
=
1
Δ
i
	​

=1 and 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0. 
Top: Statistics of message latencies computed for the number of messages 
𝑀
=
10
5
M=10
5
 broadcasted on the network of 
𝑁
=
10
3
N=10
3
 nodes. The latter has topology of a random regular graph with connectivity 
𝑐
=
4
c=4. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
∈
{
1
/
100
,
1
/
10
,
…
,
9
/
10
}
q∈{1/100,1/10,…,9/10}. Bottom: The histogram of message latencies computed for 
𝑞
=
{
1
/
10
,
1
/
2
,
9
/
10
}
q={1/10,1/2,9/10} (left, middle, right). 
Dividing the latency of broadcast by 
log
⁡
(
𝑁
)
log(N) suggests that the latter is converging to some value, dependent on 
𝑞
q and connectivity 
𝑐
c, as 
𝑁
→
∞
N→∞ as can be seen in the figure below. 
The average latency of broadcast 
±
± standard deviation (divided by 
log
⁡
(
𝑁
)
log(N)) plotted as a function of network size 
𝑁
N for 
𝑞
∈
{
1
/
10
,
1
/
2
,
9
/
10
}
q∈{1/10,1/2,9/10} (left, middle, right). The number of messages broadcasted is 
𝑀
=
10
4
M=10
4
. The network has topology of a random regular graph with connectivity 
𝑐
=
4
c=4. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
q. 
For 
𝑞
→
0
q→0 distribution of the random variable 
𝑞
 
𝑟
𝑖
𝑗
qr
ij
	​

, where 
𝑟
𝑖
𝑗
r
ij
	​

 is sampled from the geometric distribution with parameter 
𝑞
q, is exponential distribution with parameter 
1
1. The latter follows from the properties of the Geometric distribution. 
Furthermore, the latency of broadcast, 
𝐿
1
[
𝐺
𝑁
]
L
1
	​

[G
N
	​

], for delays sampled from the exponential distribution with parameter 
1
1 and 
𝑁
→
∞
N→∞ is 
𝐿
1
[
𝐺
𝑁
]
log
⁡
(
𝑁
)
→
Prob.
1
𝑐
−
2
+
1
𝑐
,
log(N)
L
1
	​

[G
N
	​

]
	​

Prob.
	​

c−2
1
	​

+
c
1
	​

,
i.e. the latency of broadcast is 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
c(c−2)
2(c−1)
	​

log(N) with high probability when 
𝑁
N is large. 
The above two points suggest that for small 
𝑞
q, the latency of broadcast is approximately 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑞
c(c−2)
2(c−1)
	​

q
log(N)
	​

 when 
𝑟
𝑖
𝑗
r
ij
	​

 are sampled from the geometric distribution with parameter 
𝑞
q, i.e. the latency of broadcast is diverging as 
𝑞
→
0
q→0. The latter is consistent with latency measured in simulations. 
Statistics of message latencies computed for the number of messages 
𝑀
=
10
5
M=10
5
 broadcasted on the network of 
𝑁
=
10
3
N=10
3
 nodes. The latter has the topology of a random regular graph with connectivity 
𝑐
=
4
c=4. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
∈
{
1
/
100
,
1
/
10
,
…
,
9
/
10
}
q∈{1/100,1/10,…,9/10}. The dashed black line is the function 
2
𝑐
−
2
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑞
c(c−2)
2c−2
	​

q
log(N)
	​

.
For larger values of q, the average latency of broadcast computed numerically deviates from the asymptotic 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑞
c(c−2)
2(c−1)
	​

q
log(N)
	​

 as can be seen in the figure above. 
We note that the (asymptotic) latency of broadcast 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑞
c(c−2)
2(c−1)
	​

q
log(N)
	​

 is a special case of 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑓
(
𝑞
)
c(c−2)
2(c−1)
	​

f(q)
log(N)
	​

 for some (unknown) function 
𝑓
(
𝑞
)
f(q). 
Assuming that the latency of broadcast 
𝐿
1
[
𝐺
𝑁
]
=
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝑓
(
𝑞
)
L
1
	​

[G
N
	​

]=
c(c−2)
2(c−1)
	​

f(q)
log(N)
	​

, with high prob. as 
𝑁
→
∞
N→∞, and inverting this expression gives us 
𝑓
(
𝑞
)
=
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝐿
1
[
𝐺
𝑁
]
f(q)=
c(c−2)
2(c−1)
	​

L
1
	​

[G
N
	​

]
log(N)
	​

. Using the data to plot the latter suggests the form 
𝑓
(
𝑞
)
=
𝛼
log
⁡
(
1
+
𝑞
)
f(q)=αlog(1+q) for some parameter 
𝛼
>
0
α>0 as can be seen in the figure below. 
The function 
𝑓
(
𝑞
)
=
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝐿
1
[
𝐺
𝑁
]
f(q)=
c(c−2)
2(c−1)
	​

L
1
	​

[G
N
	​

]
log(N)
	​

 as function of 
𝑞
q. Solid line is 
𝑓
(
𝑞
)
=
𝑞
f(q)=q and dashed line is 
𝑓
(
𝑞
)
=
𝛼
log
⁡
(
1
+
𝑞
)
f(q)=αlog(1+q) with 
𝛼
=
0.95
α=0.95. Here for the broadcast latency 
𝐿
1
[
𝐺
𝑁
]
L
1
	​

[G
N
	​

] the (empirical) mean from the figure was used. 
We note that for 
𝑓
(
𝑞
)
=
𝛼
log
⁡
(
1
+
𝑞
)
f(q)=αlog(1+q) we have 
𝑓
(
𝑞
)
=
𝛼
 
(
𝑞
−
𝑞
2
/
2
+
𝑂
(
𝑞
3
)
)
f(q)=α(q−q
2
/2+O(q
3
)) as 
𝑞
→
0
q→0. 
Furthermore, fitting 
𝐿
1
[
𝐺
𝑁
]
=
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝛼
log
⁡
(
1
+
𝑞
)
L
1
	​

[G
N
	​

]=
c(c−2)
2(c−1)
	​

αlog(1+q)
log(N)
	​

 to the mean of data gives us 
The mean latency of broadcast (+ symbols), computed from the data, is explained by 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝛼
log
⁡
(
1
+
𝑞
)
c(c−2)
2(c−1)
	​

αlog(1+q)
log(N)
	​

 (dashed line). Here the value of 
𝛼
α, obtained by fitting, is 
0.9534770
0.9534770. 
Testing the expression 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝛼
log
⁡
(
1
+
𝑞
)
c(c−2)
2(c−1)
	​

αlog(1+q)
log(N)
	​

 for the mean value of broadcast obtained numerically suggests that the latter is accurate when the connectivity 
𝑐
c and q are small but significantly diverges from the data when 
𝑐
c and 
𝑞
q are large as can be seen in the figure below. 
The mean latency of broadcast, represented by symbols, as a function of 
𝑞
q computed for the number of messages 
𝑀
=
10
4
M=10
4
 broadcasted on the network of 
𝑁
=
10
4
N=10
4
 nodes. The latter has topology of a random regular graph with connectivity 
𝑐
∈
{
3
,
5
,
8
,
13
,
21
,
34
}
c∈{3,5,8,13,21,34} (top to bottom). The lines were obtained by fitting the 
𝛼
α parameter in the expression 
2
(
𝑐
−
1
)
𝑐
(
𝑐
−
2
)
log
⁡
(
𝑁
)
𝛼
log
⁡
(
1
+
𝑞
)
c(c−2)
2(c−1)
	​

αlog(1+q)
log(N)
	​

. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
q. 
The probability that the latency of broadcast is greater than some threshold 
𝑡
t decreases with the connectivity 
𝑐
c as can be seen in the figure below. 
The probability that the latency of broadcast is greater than 
𝑡
t as a function of 
𝑡
t computed for the number of messages 
𝑀
=
10
6
M=10
6
 broadcasted on the network of 
𝑁
=
10
3
N=10
3
 nodes. The latter has the topology of a random regular graph with connectivity 
𝑐
∈
{
3
,
4
,
7
,
11
}
c∈{3,4,7,11} (top to bottom). The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
We note that random regular graph is locally tree-like, i.e. when 
𝑁
N is large any node is a root of a tree of some height 
ℎ
h with high probability. 
For the node connectivity 
𝑐
>
2
c>2 the number of nodes in the tree of height 
ℎ
h, rooted at node 
1
1, is given by 
1
+
𝑐
+
𝑐
(
𝑐
−
1
)
+
𝑐
(
𝑐
−
1
)
2
+
⋯
+
𝑐
(
𝑐
−
1
)
ℎ
−
1
=
1
+
𝑐
(
𝑐
−
1
)
ℎ
−
1
𝑐
−
2
.
1+c+c(c−1)+c(c−1)
2
+⋯+c(c−1)
h−1
=1+c
c−2
(c−1)
h
−1
	​

.
In above we assumed that root node has 
𝑐
c children and every internal node has 
𝑐
−
1
c−1 children (see figure). 
For 
𝑁
N nodes, the minimum 
ℎ
h such that 
𝑁
≤
1
+
𝑐
(
𝑐
−
1
)
ℎ
−
1
𝑐
−
2
N≤1+c
c−2
(c−1)
h
−1
	​

 is given by 
⌈
log
⁡
(
𝑁
(
𝑐
−
2
)
+
2
𝑐
)
log
⁡
(
𝑐
−
1
)
⌉
	​

log(c−1)
log(
c
N(c−2)+2
	​

)
	​

	​

The latency of broadcast on a tree of 
𝑁
N nodes is expected to be higher than on random regular with the same 
𝑁
N and the same connectivity 
𝑐
c. This is due to the presence of loops in the latter. 
The numerical results for (average) latency of broadcast on a tree of 
𝑁
N nodes suggest that this average is an upper bound on the average latency of broadcast on on random regular with the same 
𝑁
N and the same connectivity 
𝑐
c as can be seen in the figure below.
The average latency of broadcast as a function of connectivity 
𝑐
c computed for the number of messages 
𝑀
=
10
6
M=10
6
 broadcasted on the network of 
𝑁
=
10
3
N=10
3
 nodes. The latter has the topology of a random regular graph with connectivity 
𝑐
c or of a balanced complete tree, rooted at node 1, with the same 
𝑁
N and 
𝑐
c. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
Furthermore, numerical results for latency of broadcast on trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.
The probability that the latency of broadcast is greater than 
𝑡
t as a function of 
𝑡
t computed for the number of messages 
𝑀
=
10
6
M=10
6
 broadcasted on the network of 
𝑁
=
10
3
N=10
3
 nodes. The latter has the topology of a random regular graph with connectivity 
𝑐
=
4
c=4 or of a balanced complete tree rooted at node 1. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
We note that the latency of broadcast on a tree of finite size is equivalent to the latency of broadcast in finite neighbourhood of a sender node in large random regular graph. In the latter, as 
𝑁
→
∞
N→∞ the finite neighbourhood of a node is (with high prob.) a Cayley tree (see figure below) up to some distance, measured in by number edges between the node and any other node. 
The neighbourhood of node 
1
1 in a very large random regular graph of connectivity 
𝑐
=
3
c=3. The weights in the latter are independent random variables from geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
The numerical results for latency of broadcast on Cayley trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.
The probability that the latency of broadcast is greater than 
𝑡
t as a function of 
𝑡
t computed for the number of messages 
𝑀
=
10
6
M=10
6
 broadcasted on the network of 
𝑁
∈
{
94
,
190
,
382
,
766
,
10
3
,
1534
}
N∈{94,190,382,766,10
3
,1534} nodes. The latter for 
𝑁
=
10
3
N=10
3
 has the topology of a random regular graph with connectivity 
𝑐
=
4
c=4 and for 
𝑁
≠
10
3
N

=10
3
 is a Cayley tree rooted at node 1. The delay model, for a message sent from node 
𝑖
i to its neighbours 
𝑗
j, used is 
𝑟
𝑖
𝑗
Δ
𝑖
+
𝑑
𝑖
𝑗
r
ij
	​

Δ
i
	​

+d
ij
	​

, where 
Δ
𝑖
=
1
Δ
i
	​

=1, 
𝑑
𝑖
𝑗
=
0
d
ij
	​

=0 and 
𝑟
𝑖
𝑗
r
ij
	​

 is random variable from the Geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
The latency of broadcast on a tree can be computed iteratively. The latter uses the property 
max
⁡
{
𝐽
1
+
𝐽
2
,
𝐽
1
+
𝐽
3
}
=
𝐽
1
+
max
⁡
{
𝐽
2
,
𝐽
3
}
,
                                                                                   where 
𝐽
𝑖
>
0.
max{J
1
	​

+J
2
	​

,J
1
	​

+J
3
	​

}=J
1
	​

+max{J
2
	​

,J
3
	​

},
                                                                                   where J
i
	​

>0.
To show this we consider the latency of broadcast on a tree of 
𝑁
N nodes 
𝑇
𝑁
T
N
	​

 rooted at node 
1
1 (see figure) as follows. 
First, we define the latency of communication a message, sent from node 
1
1 to all nodes in
𝑇
𝑁
T
N
	​

, when it is relayed from the node 
𝑖
i to 
𝑗
j as 
𝐽
𝑖
𝑗
(
1
)
=
𝑟
𝑖
𝑗
(
1
)
Δ
𝑖
+
𝑑
𝑖
𝑗
J
ij
	​

(1)=r
ij
	​

(1)Δ
i
	​

+d
ij
	​

 then the latency of broadcast 
𝐿
1
[
𝑇
𝑁
]
=
max
⁡
𝑖
∈
[
𝑁
]
∖
1
𝐷
1
→
𝑖
[
𝑇
𝑁
]
                           
=
max
⁡
𝑖
∈
[
𝑁
]
∖
1
min
⁡
1
→
𝑖
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
𝐽
𝑖
𝑗
(
1
)
                    
=
max
⁡
𝑖
∈
[
𝑁
]
∖
1
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
𝐽
𝑖
𝑗
(
1
)
                                                         
=
max
⁡
𝑖
∈
∂
𝑇
𝑁
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
𝐽
𝑖
𝑗
(
1
)
, where 
∂
𝑇
𝑁
 is the set 
                                                                                       of leaf nodes
L
1
	​

[T
N
	​

]=
i∈[N]∖1
max
	​

D
1→i
	​

[T
N
	​

]
                           =
i∈[N]∖1
max
	​

1→i
min
	​

(i,j)∈1→i
∑
	​

J
ij
	​

(1)
                    =
i∈[N]∖1
max
	​

(i,j)∈1→i
∑
	​

J
ij
	​

(1)
                                                         =
i∈∂T
N
	​

max
	​

(i,j)∈1→i
∑
	​

J
ij
	​

(1), where ∂T
N
	​

 is the set 
                                                                                       of leaf nodes
Second, we consider the latency of broadcast
𝐿
1
[
𝑇
𝑁
]
=
max
⁡
𝑖
∈
∂
𝑇
𝑁
∑
(
𝑖
,
𝑗
)
∈
1
→
𝑖
𝐽
𝑖
𝑗
(
1
)
                                    
=
max
⁡
𝑖
∈
∂
1
{
𝐽
1
𝑖
(
1
)
+
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑖
→
𝑘
[
𝑇
𝑁
]
}
,
                            where 
𝐷
𝑖
→
𝑘
[
𝑇
𝑁
]
                                                                           is the distance from 
𝑖
 to 
𝑘
L
1
	​

[T
N
	​

]=
i∈∂T
N
	​

max
	​

(i,j)∈1→i
∑
	​

J
ij
	​

(1)
                                    =
i∈∂1
max
	​

{J
1i
	​

(1)+
k∈∂T
N
	​

max
	​

D
i→k
	​

[T
N
	​

]},
                            where D
i→k
	​

[T
N
	​

]
                                                                           is the distance from i to k
Now the maximum distance from node 
𝑖
i to a leaf node 
𝑘
k, 
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑖
→
𝑘
[
𝑇
𝑁
]
max
k∈∂T
N
	​

	​

D
i→k
	​

[T
N
	​

], can be computed as follows 
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑖
→
𝑘
[
𝑇
𝑁
]
=
max
⁡
𝑗
∈
∂
𝑖
∖
1
{
𝐽
𝑖
𝑗
(
1
)
+
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑗
→
𝑘
[
𝑇
𝑁
]
}
k∈∂T
N
	​

max
	​

D
i→k
	​

[T
N
	​

]=
j∈∂i∖1
max
	​

{J
ij
	​

(1)+
k∈∂T
N
	​

max
	​

D
j→k
	​

[T
N
	​

]}
Furthermore, if node 
𝑗
j is adjacent only to leaf nodes but one then 
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑗
→
𝑘
[
𝑇
𝑁
]
=
max
⁡
𝑘
∈
∂
𝑗
∖
𝑖
{
𝐽
𝑗
𝑘
(
1
)
}
k∈∂T
N
	​

max
	​

D
j→k
	​

[T
N
	​

]=
k∈∂j∖i
max
	​

{J
jk
	​

(1)}
For node 
𝑗
j not adjacent to leaf nodes the 
max
⁡
𝑘
∈
∂
𝑇
𝑁
𝐷
𝑗
→
𝑘
[
𝑇
𝑁
]
max
k∈∂T
N
	​

	​

D
j→k
	​

[T
N
	​

] can be computed via equation similar to the equation. The latter suggests that the latency of broadcast 
𝐿
1
[
𝑇
𝑁
]
L
1
	​

[T
N
	​

] can be computed recursively using above equations and numerical complexity of this computation is 
𝑂
(
𝑁
)
O(N). This is better than 
𝑂
(
𝑁
log
⁡
𝑁
)
O(NlogN) when Dijkstra's algorithm is used to compute 
𝐿
1
[
𝑇
𝑁
]
L
1
	​

[T
N
	​

]. 
The distribution of the latency of broadcast 
𝐿
1
[
𝑇
𝑁
]
L
1
	​

[T
N
	​

] on a Cayley tree of height 
𝑇
+
2
T+2 can computed by the population dynamics algorithm as follows. 
First, for each 
ℓ
∈
[
𝑀
]
ℓ∈[M] compute boundary conditions as follows 
𝑟
𝑘
∼
G
e
o
m
(
𝑞
)
                      
ℎ
ℓ
(
0
)
=
max
⁡
{
𝑟
1
,
…
,
𝑟
𝑐
−
1
}
r
k
	​

∼Geom(q)
                      h
ℓ
	​

(0)=max{r
1
	​

,…,r
c−1
	​

}
 Second, for each 
𝑡
∈
{
0
,
1
,
…
,
𝑇
}
t∈{0,1,…,T} do the following for each 
ℓ
∈
[
𝑀
]
ℓ∈[M] 
𝑟
𝑘
∼
G
e
o
m
(
𝑞
)
ℓ
𝑘
∼
𝑈
{
[
𝑀
]
}
                                                    
ℎ
ℓ
(
𝑡
+
1
)
=
max
⁡
{
𝑟
1
+
ℎ
ℓ
1
(
𝑡
)
,
…
,
𝑟
𝑐
−
1
+
ℎ
ℓ
𝑐
−
1
(
𝑡
)
}
r
k
	​

∼Geom(q)
ℓ
k
	​

∼U{[M]}
                                                    h
ℓ
	​

(t+1)=max{r
1
	​

+h
ℓ
1
	​

	​

(t),…,r
c−1
	​

+h
ℓ
c−1
	​

	​

(t)}
Finally, for each 
ℓ
∈
[
𝑀
]
ℓ∈[M] compute 
𝑟
𝑘
∼
G
e
o
m
(
𝑞
)
ℓ
𝑘
∼
𝑈
{
[
𝑀
]
}
                                                     
𝐻
ℓ
(
𝑇
)
=
max
⁡
{
𝑟
1
+
ℎ
ℓ
1
(
𝑇
)
,
…
,
𝑟
𝑐
+
ℎ
ℓ
𝑐
(
𝑇
)
}
r
k
	​

∼Geom(q)
ℓ
k
	​

∼U{[M]}
                                                     H
ℓ
	​

(T)=max{r
1
	​

+h
ℓ
1
	​

	​

(T),…,r
c
	​

+h
ℓ
c
	​

	​

(T)}
The prob. distribution of 
𝐿
1
[
𝑇
𝑁
]
L
1
	​

[T
N
	​

] for a Cayley tree of height 
𝑇
+
2
T+2 can be estimated by the density 
P
𝑀
(
𝐻
)
=
1
𝑀
∑
ℓ
=
1
𝑀
𝛿
𝐻
;
 
𝐻
ℓ
(
𝑇
)
P
M
	​

(H)=
M
1
	​

ℓ=1
∑
M
	​

δ
H;H
ℓ
	​

(T)
	​

The above dynamics can be described by the equation 
P
𝑡
+
1
(
ℎ
)
=
∑
ℎ
1
⋯
∑
ℎ
𝑐
−
1
∏
ℓ
=
1
𝑐
−
1
P
𝑡
(
ℎ
ℓ
)
                   
×
∑
𝑟
1
⋯
∑
𝑟
𝑐
−
1
∏
ℓ
=
1
𝑐
−
1
P
𝑞
(
𝑟
ℓ
)
                         
×
𝛿
ℎ
;
 
max
⁡
{
𝑟
1
+
ℎ
1
,
…
,
𝑟
𝑐
−
1
+
ℎ
𝑐
−
1
}
P
t+1
	​

(h)=
h
1
	​

∑
	​

⋯
h
c−1
	​

∑
	​

ℓ=1
∏
c−1
	​

P
t
	​

(h
ℓ
	​

)
                   ×
r
1
	​

∑
	​

⋯
r
c−1
	​

∑
	​

ℓ=1
∏
c−1
	​

P
q
	​

(r
ℓ
	​

)
                         ×δ
h;max{r
1
	​

+h
1
	​

,…,r
c−1
	​

+h
c−1
	​

}
	​

The boundary condition corresponding to the Cayley tree is given by 
P
0
(
ℎ
)
=
∑
𝑟
1
⋯
∑
𝑟
𝑐
−
1
{
∏
ℓ
−
1
𝑐
−
1
P
𝑞
(
𝑟
ℓ
)
}
 
𝛿
ℎ
;
 
max
⁡
{
𝑟
1
,
…
,
𝑟
𝑐
−
1
}
P
0
	​

(h)=
r
1
	​

∑
	​

⋯
r
c−1
	​

∑
	​

{
ℓ−1
∏
c−1
	​

P
q
	​

(r
ℓ
	​

)}δ
h;max{r
1
	​

,…,r
c−1
	​

}
	​

The prob. distribution of 
𝐿
1
[
𝑇
𝑁
]
L
1
	​

[T
N
	​

] for a Cayley tree of height 
𝑇
+
2
T+2 is given by 
P
𝑇
+
2
(
𝐻
)
=
∑
ℎ
1
⋯
∑
ℎ
𝑐
∏
ℓ
=
1
𝑐
P
𝑇
(
ℎ
ℓ
)
                   
×
∑
𝑟
1
⋯
∑
𝑟
𝑐
∏
ℓ
=
1
𝑐
P
𝑞
(
𝑟
ℓ
)
                         
×
𝛿
𝐻
;
 
max
⁡
{
𝑟
1
+
ℎ
1
,
…
,
𝑟
𝑐
+
ℎ
𝑐
}
P
T+2
	​

(H)=
h
1
	​

∑
	​

⋯
h
c
	​

∑
	​

ℓ=1
∏
c
	​

P
T
	​

(h
ℓ
	​

)
                   ×
r
1
	​

∑
	​

⋯
r
c
	​

∑
	​

ℓ=1
∏
c
	​

P
q
	​

(r
ℓ
	​

)
                         ×δ
H;max{r
1
	​

+h
1
	​

,…,r
c
	​

+h
c
	​

}
	​

Using that the prob. distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r) is geometric with parameter 
𝑞
q, one could try to solve above equations analytically. Also one could consider a single loop and see how this will change the equation. 
For 
𝑞
=
1
q=1 we have 
𝑟
𝑗
𝑖
=
1
r
ji
	​

=1 with prob. 
1
1 and hence the latency of broadcast is dominated by the diameter 
𝑑
d of a random regular graph, i.e. the largest distance between any two nodes. The bounds (using the Theorems 1 and 3) for the latter for (very small) 
𝜖
>
0
ϵ>0 are given by
⌊
log
⁡
𝑐
−
1
(
𝑁
)
⌋
+
⌊
log
⁡
𝑐
−
1
(
log
⁡
(
𝑁
)
𝑐
−
2
6
𝑐
)
⌋
+
1
≤
𝑑
                                                           
≤
⌈
log
⁡
𝑐
−
1
(
𝑁
)
+
log
⁡
𝑐
−
1
(
(
2
+
𝜖
)
 
𝑐
log
⁡
(
𝑁
)
)
⌉
+
1.
⌊log
c−1
	​

(N)⌋+⌊log
c−1
	​

(log(N)
6c
c−2
	​

)⌋+1≤d
                                                           ≤⌈log
c−1
	​

(N)+log
c−1
	​

((2+ϵ)clog(N))⌉+1.
A Simple Model of Communication Latency in Consensus
To model the communication latency of a node participating in consensus, we assume that latency has two dominant components which are due to delays in “mixing“ and “broadcast” (cf. the formula “Mixnet delay (gamma distribution) sampled once per block + PoL (constant) + final broadcast from exit mixnode (exponential distribution) sampled per node” used in consensus simulations).
We assume that given a network of 
𝑁
N nodes, a gossiping-like mode of communication is used.
Let us assume that the network topology used is a random regular graph 
𝐺
𝑁
=
(
𝑉
𝑁
,
𝐸
𝑁
)
G
N
	​

=(V
N
	​

,E
N
	​

), where 
𝑉
𝑁
=
[
𝑁
]
V
N
	​

=[N] is the set of nodes and 
𝐸
𝑁
E
N
	​

 is the set of edges, with connectivity 
𝑐
c. The latter is sampled only once and remains fixed for the duration of a consensus protocol. 
Furthermore, to each edge 
{
𝑖
,
𝑗
}
∈
𝐸
𝑁
{i,j}∈E
N
	​

 we assign a random variable 
𝑑
𝑖
𝑗
d
ij
	​

, sampled from some probability distribution, to model delays in communication links. This gives rise to the weighted graph 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
}
]
G
N
	​

[{d
ij
	​

}]. The probability distribution could be exponential, with parameter 
𝜆
λ such that 
1
/
𝜆
1/λ is the average and 
1
/
𝜆
2
1/λ
2
 is the variance, or 
𝑑
𝑖
𝑗
=
𝑑
d
ij
	​

=d for all 
{
𝑖
,
𝑗
}
∈
𝐸
𝑁
{i,j}∈E
N
	​

 (cf. the “300ms” constant delay used in current estimates of latency). 
To model the mixing delay we assume, without loss of generality, that node 
1
1 sends (via 
𝑘
k mix nodes) a message to node 
𝑘
+
2
k+2, and adopt the single-path model as follows 
Δ
∑
ℓ
=
1
𝑘
+
1
𝑟
ℓ
+
∑
ℓ
=
1
𝑘
+
1
𝐷
ℓ
→
ℓ
+
1
Δ
ℓ=1
∑
k+1
	​

r
ℓ
	​

+
ℓ=1
∑
k+1
	​

D
ℓ→ℓ+1
	​

In above we assume that 
𝑘
k mix nodes, and the sender node 
1
1, introduce delays modeled by random variables 
𝑟
𝑖
r
i
	​

 sampled from the Geometric distribution with the parameter 
𝑞
=
1
/
2
q=1/2. The latter models a queue which uses coin-flipping to remove a message. Here 
Δ
Δ is a cost of attempt to remove a message, measured in units of time, from the queue. 
The second part of above equation models the contribution of gossiping to the delay. Here 
𝐷
𝑖
1
→
𝑖
2
≡
𝐷
𝑖
1
→
𝑖
2
[
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
}
]
]
D
i
1
	​

→i
2
	​

	​

≡D
i
1
	​

→i
2
	​

	​

[G
N
	​

[{d
ij
	​

}]] is the “distance”, measured in units of time, between the nodes 
𝑖
1
i
1
	​

 and 
𝑖
2
i
2
	​

 on the graph 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
}
]
G
N
	​

[{d
ij
	​

}] which is defined as follows 


𝐷
𝑖
1
→
𝑖
2
=
min
⁡
𝑖
1
→
𝑖
2
∑
(
𝑖
,
𝑗
)
∈
𝑖
1
→
𝑖
2
𝑑
𝑖
𝑗
D
i
1
	​

→i
2
	​

	​

=
i
1
	​

→i
2
	​

min
	​

(i,j)∈i
1
	​

→i
2
	​

∑
	​

d
ij
	​

Furthermore, the distance 
𝐷
ℓ
→
ℓ
+
1
≡
𝐷
ℓ
→
ℓ
+
1
[
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
ℓ
}
]
]
D
ℓ→ℓ+1
	​

≡D
ℓ→ℓ+1
	​

[G
N
	​

[{d
ij
ℓ
	​

}]], i.e. samples of random variables 
{
𝑑
𝑖
𝑗
ℓ
}
{d
ij
ℓ
	​

} are different for different 
ℓ
ℓ to model the gossiping aspect of communication. 
The distance 
𝐷
𝑖
1
→
𝑖
2
D
i
1
	​

→i
2
	​

	​

 can be interpreted as the latency of (communication) path between the sender node 
𝑖
1
i
1
	​

 and the receiver node 
𝑖
2
i
2
	​

 when the gossiping mode of communication is used. 
We note that in a weighted graph 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
}
]
G
N
	​

[{d
ij
	​

}] the distance 
𝐷
𝑖
1
→
𝑖
2
D
i
1
	​

→i
2
	​

	​

 can computed by using the Dijkstra's algorithm. 
To model the broadcast delay we assume, without loss of generality, that the node 
𝑘
+
2
k+2 broadcasts the message, received from node 
1
1, to all nodes in the network. Assuming that gossiping is used the delay is 
𝐷
𝑘
+
2
→
ℓ
[
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
ℓ
}
]
]
D
k+2→ℓ
	​

[G
N
	​

[{d
ij
ℓ
	​

}]] for each node 
ℓ
∈
[
𝑁
]
∖
𝑘
+
2
ℓ∈[N]∖k+2. 
To simulate the mixing and broadcast delays in a consensus simulation the following algorithm can be used
Generate a random regular graph 
𝐺
𝑁
G
N
	​

 with connectivity 
𝑐
c.
For the sender node 
𝑖
𝑆
i
S
	​

, sending a message to the receiver node 
𝑖
𝑅
i
R
	​

, sample (without replacement) the mix nodes 
𝑖
1
,
…
,
𝑖
𝑘
i
1
	​

,…,i
k
	​

 and 
𝑖
𝑅
i
R
	​

 from the set of all available nodes 
[
𝑁
]
∖
𝑖
𝑆
[N]∖i
S
	​

. 
Sample the random delays 
𝑟
1
,
…
,
𝑟
𝑘
+
1
r
1
	​

,…,r
k+1
	​

, from the geometric distribution with parameter 
𝑞
=
1
/
2
q=1/2. 
Given the random regular graph 
𝐺
𝑁
G
N
	​

, generate the sequence of weighted graphs 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
1
}
]
,
…
,
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
𝑘
+
1
}
]
G
N
	​

[{d
ij
1
	​

}],…,G
N
	​

[{d
ij
k+1
	​

}] associated with each directed edge in the path 
𝑖
𝑆
→
𝑖
1
→
…
→
𝑖
𝑘
→
𝑖
𝑅
i
S
	​

→i
1
	​

→…→i
k
	​

→i
R
	​

 and compute the distances 
𝐷
𝑖
𝑆
→
𝑖
1
,
𝐷
𝑖
1
→
𝑖
2
,
…
,
𝐷
𝑖
𝑘
→
𝑖
𝑅
D
i
S
	​

→i
1
	​

	​

,D
i
1
	​

→i
2
	​

	​

,…,D
i
k
	​

→i
R
	​

	​

 on these graphs. 
Compute the mixing delay 
Δ
∑
ℓ
=
1
𝑘
+
1
𝑟
ℓ
+
𝐷
𝑖
𝑆
→
𝑖
1
+
𝐷
𝑖
1
→
𝑖
2
+
⋯
+
𝐷
𝑖
𝑘
→
𝑖
𝑅
Δ∑
ℓ=1
k+1
	​

r
ℓ
	​

+D
i
S
	​

→i
1
	​

	​

+D
i
1
	​

→i
2
	​

	​

+⋯+D
i
k
	​

→i
R
	​

	​

​
Given the same random regular graph 
𝐺
𝑁
G
N
	​

, generate the graph with random weights 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
}
]
G
N
	​

[{d
ij
	​

}] and for the node 
𝑖
𝑅
i
R
	​

 compute the distance 
𝐷
𝑖
𝑅
→
𝑖
D
i
R
	​

→i
	​

 for all 
𝑖
∈
[
𝑁
]
∖
𝑖
𝑅
i∈[N]∖i
R
	​

 . The latter are broadcast delays. 
Repeat the steps 2 to 6 for each sender node. 
We note that when 
𝑑
𝑖
𝑗
=
𝑑
d
ij
	​

=d, i.e. all communication links have the same latency, then all distances 
𝐷
𝑖
→
𝑗
D
i→j
	​

 on the weighted graph 
𝐺
𝑁
[
{
𝑑
𝑖
𝑗
=
𝑑
}
]
G
N
	​

[{d
ij
	​

=d}] can be precomputed which simplifies the steps 4 and 6 in the above algorithm. 
Also the algorithm can be easily adopted to use other models of random graphs, and other models of mixing and communication delays. 
Bibliography
Amir Dembo. Andrea Montanari. "Ising models on locally tree-like graphs." Ann. Appl. Probab. 20 (2) 565 - 592, April 2010. https://doi.org/10.1214/09-AAP627
Hamed Amini. Marc Lelarge. "The diameter of weighted random graphs." Ann. Appl. Probab. 25 (3) 1686 - 1727, June 2015. https://doi.org/10.1214/14-AAP1034
Mézard, M., Parisi, G. “The Bethe lattice spin glass revisited.” Eur. Phys. J. B 20, 217–233 (2001). https://doi.org/10.1007/PL00011099 
Bollobás, B., Fernandez de la Vega, W. “The diameter of random regular graphs.” Combinatorica 2, 125–134 (1982). https://doi.org/10.1007/BF02579310
\frac{\mathcal{L}_1[G_N]}{\log(N)}\xrightarrow{\text{Prob.}}
\frac{1}{c-2}+\frac{1}{c},

\left\lceil\frac{\log\left(\frac{N(c - 2) + 2}{c}\right)}{\log(c - 1)}\right\rceil

Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Latency
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Latency
Authors: Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Table
Introduction
We consider latency of a broadcast on the network constructed from mix nodes which use queues to store in-coming and out-going messages. A message is removed from the queue with probability 
Σ
Equation
 which delays messages by a random amount of time governed by the Geometric distribution with parameter 
Σ
Equation
. The other source of message delays are due to the latency in communication links which we assume to be “frozen”, i.e. not changing with time. We show that for a single path constructed from 
Σ
Equation
 mix nodes the average message latency is proportional to 
Σ
Equation
 and we estimate the probability of latency being greater than the average. Furthermore, we consider latency of a broadcast on the network with the topology of a random regular graph with connectivity 
Σ
Equation
. Here we find that the latency of broadcast, divided by 
Σ
Equation
, is approaching 
Σ
Equation
 for a small probability of message removal 
Σ
Equation
 as the number of nodes in the network 
Σ
Equation
 is growing. However, for finite 
Σ
Equation
 the distribution of latency can have long tails. We note that the latter result is established semi-analytically and only for trees we managed to develop a complete analytical framework which can be used to compute the latency of a broadcast. Finally, in this document we propose a simple model of communication latency in consensus.
Analysis
Single Node
Assuming that a message is removed from the queue of a node with probability 
Σ
Equation
 (see the document), a message in node 
Σ
Equation
 is delayed by (at most) 
Σ
Equation
, where 
Σ
Equation
 is a random variable from the Geometric distribution with parameter 
Σ
Equation
 and 
Σ
Equation
 is a “cost” of one attempt of removing a message.
Assuming that node 
Σ
Equation
 has 
Σ
Equation
 connections and it puts a message into all out-queues associated with these connections, i.e. the node 
Σ
Equation
 is sending a message. The message will be delayed by (at most) 
Σ
Equation
 in the queue 
Σ
Equation
, by 
Σ
Equation
 in the queue 
Σ
Equation
, etc., where 
Σ
Equation
 is sample from the Geometric distr. with parameter 
Σ
Equation
.
Assuming that node 
Σ
Equation
 has 
Σ
Equation
 connections and it puts a message into all out-queues but not the queue associated with the connection labelled by 
Σ
Equation
, i.e. the node is relaying a message, the message will be delayed by (at most) 
Σ
Equation
 in the queue 
Σ
Equation
, by 
Σ
Equation
in the queue 
Σ
Equation
, etc., where 
Σ
Equation
 is sample from the Geometric distr. with parameter 
Σ
Equation
.
Single Path
Without loss of generality, we consider a message traveling from node 
Σ
Equation
 to node 
Σ
Equation
. A message is delayed at the node 
Σ
Equation
 by 
Σ
Equation
, at the node 
Σ
Equation
 by 
Σ
Equation
, etc. For node 
Σ
Equation
 we assume that 
Σ
Equation
 is a random variable from the Geometric distribution with parameter 
Σ
Equation
 and that 
Σ
Equation
. The latter is prop. to a max. time elapsed between attempts to “flip a coin”. Furthermore, a message traveling between the nodes 
Σ
Equation
 and 
Σ
Equation
 is delayed by 
Σ
Equation
.
Using above the total delay is given by 
Σ
Equation
. We note that for 
Σ
Equation
 and 
Σ
Equation
 we have
📈
Equation
The sum 
Σ
Equation
 is random variable from the negative binomial distribution
📈
Equation
Using that 
Σ
Equation
 is a random variable from the Geometric distribution with parameter 
Σ
Equation
 the average and variance of the total delay 
Σ
Equation
 is given, respectively, by 
Σ
Equation
 and 
Σ
Equation
. The latter, for 
Σ
Equation
 and 
Σ
Equation
 , is simplifies to 
Σ
Equation
 and 
Σ
Equation
.
The mean of sum 
Σ
Equation
 is equals to 
Σ
Equation
. For 
Σ
Equation
 the probability 
Σ
Equation
 can bounded from above as follows
📈
Equation
To show the above we used 
Σ
Equation
 for any 
Σ
Equation
 and Markov’s inequality.
The probability 
Σ
Equation
 is increasing with decreasing 
Σ
Equation
 for 
Σ
Equation
and decreasing with increasing 
Σ
Equation
 for 
Σ
Equation
We note that the upper bound can be represented as
📈
Equation
Plotting 
Σ
Equation
 suggests that the upper bound is monotonic decreasing function of 
Σ
Equation
, 
Σ
Equation
 and 
Σ
Equation
.
Random Networks
Configuration Model
Let us consider the probability distribution 
Σ
Equation
 over the non-negative integers 
Σ
Equation
 such that 
Σ
Equation
 and define the probability distribution
📈
Equation
We consider the random rooted tree generated as follows. First, we sample 
Σ
Equation
 from the distr. 
Σ
Equation
 and connect the root node to 
Σ
Equation
 offspring nodes. Second, for each offspring node we sample 
Σ
Equation
 from the distr. 
Σ
Equation
 and connect to 
Σ
Equation
 nodes. The latter is repeated until the tree 
Σ
Equation
 of height 
Σ
Equation
 is generated.
We consider the random graph 
Σ
Equation
, where 
Σ
Equation
 is the set of nodes and 
Σ
Equation
 is the set of edges, generated by connecting nodes with connectivities sampled from the probability distribution 
Σ
Equation
, i.e. the “configuration model”.
For 
Σ
Equation
 we have that 
Σ
Equation
, where 
Σ
Equation
 is the subgraph of 
Σ
Equation
 induced by nodes at a distance (length of shortest path between two nodes) at most 
Σ
Equation
 from the node 
Σ
Equation
, with high probability.
A special case 
Σ
Equation
 is a random regular graph (RRG) of connectivity 
Σ
Equation
, i.e. each node in 
Σ
Equation
 is connected to exactly 
Σ
Equation
 nodes.
Distance on a graph and latency of a broadcast
Let us assume, without loss of generality, that node 
Σ
Equation
 in this network wants to send a message to the all 
Σ
Equation
 nodes of network.
A node puts a message in to all of its out-queues. Assuming that coin-flipping algorithm is used to remove a message from the queue, we have that a message is delayed by (at most) 
Σ
Equation
 (see previous section), where 
Σ
Equation
 random variable from the Geometric distribution with parameter 
Σ
Equation
. A message is delayed further in a communication link and hence, for example, a message sent from the node 
Σ
Equation
 to the node 
Σ
Equation
 is delayed (at most) by 
Σ
Equation
. We note that copies of the same message, sent to other neighbours of node 
Σ
Equation
, are delayed in a similar manner.
For node 
Σ
Equation
 sending a message to its neighbour 
Σ
Equation
 the delay is 
Σ
Equation
.
The total delay of a message sent from the node 
Σ
Equation
 to the node 
Σ
Equation
 is the sum of delays
📈
Equation
along the (directed) path from node 
Σ
Equation
 to node 
Σ
Equation
, 
Σ
Equation
 .
Let us define the distance between node 1 and node 
Σ
Equation
 as the
📈
Equation
i.e. the minimum total delay over all (directed) paths from node 1 to node i.
Now the maximum distance
📈
Equation
i.e. the maximum over distances between node 
Σ
Equation
 and all other nodes, is the time that elapsed from the event “node 
Σ
Equation
 sent a message” to the event “the message was delivered to all nodes”.
Thus 
Σ
Equation
 is the latency of broadcast from node 
Σ
Equation
. Let us define the latter as
📈
Equation
We note that maximum distance can be computed using Dijkstra's algorithm.
Finally, for all pairs of distinct nodes we define the diameter of 
Σ
Equation
 as follows
📈
Equation
Results for a High Connectivity Regime
We consider networks with topology of a random regular graph in the high connectivity regime of 
Σ
Equation
, where 
Σ
Equation
, with 
Σ
Equation
 and 
Σ
Equation
.
First we consider the case of 
Σ
Equation
, i.e. the network is a complete graph, where the least latency is expected. Measuring the latency of broadcast for 
Σ
Equation
, we see that it is increasing as 
Σ
Equation
 and decreasing as 
Σ
Equation
 as can be seen in the figure below.
Furthermore, as 
Σ
Equation
 is increased from 
Σ
Equation
 to 
Σ
Equation
 the latency of broadcast becomes more concentrated on the value of 2 as can be seen in figures below.
Finally, we consider random regular graph in the high connectivity regime of 
Σ
Equation
, where 
Σ
Equation
.
Results for a Finite Connectivity Regime
We consider broadcast on networks with topology of a random regular graph in the finite connectivity regime of 
Σ
Equation
 with 
Σ
Equation
 and 
Σ
Equation
.
Dividing the latency of broadcast by 
Σ
Equation
 suggests that the latter is converging to some value, dependent on 
Σ
Equation
 and connectivity 
Σ
Equation
, as 
Σ
Equation
 as can be seen in the figure below.
For 
Σ
Equation
 distribution of the random variable 
Σ
Equation
, where 
Σ
Equation
 is sampled from the geometric distribution with parameter 
Σ
Equation
, is exponential distribution with parameter 
Σ
Equation
. The latter follows from the properties of the Geometric distribution.
Furthermore, the latency of broadcast, 
Σ
Equation
, for delays sampled from the exponential distribution with parameter 
Σ
Equation
 and 
Σ
Equation
 is
📈
Equation
i.e. the latency of broadcast is 
Σ
Equation
 with high probability when 
Σ
Equation
 is large.
The above two points suggest that for small 
Σ
Equation
, the latency of broadcast is approximately 
Σ
Equation
 when 
Σ
Equation
 are sampled from the geometric distribution with parameter 
Σ
Equation
, i.e. the latency of broadcast is diverging as 
Σ
Equation
. The latter is consistent with latency measured in simulations.
For larger values of q, the average latency of broadcast computed numerically deviates from the asymptotic 
Σ
Equation
 as can be seen in the figure above.
We note that the (asymptotic) latency of broadcast 
Σ
Equation
 is a special case of 
Σ
Equation
 for some (unknown) function 
Σ
Equation
.
Assuming that the latency of broadcast 
Σ
Equation
, with high prob. as 
Σ
Equation
, and inverting this expression gives us 
Σ
Equation
. Using the data to plot the latter suggests the form 
Σ
Equation
 for some parameter 
Σ
Equation
 as can be seen in the figure below.
We note that for 
Σ
Equation
 we have 
Σ
Equation
 as 
Σ
Equation
.
Furthermore, fitting 
Σ
Equation
 to the mean of data gives us
Testing the expression 
Σ
Equation
 for the mean value of broadcast obtained numerically suggests that the latter is accurate when the connectivity 
Σ
Equation
 and q are small but significantly diverges from the data when 
Σ
Equation
 and 
Σ
Equation
 are large as can be seen in the figure below.
The probability that the latency of broadcast is greater than some threshold 
Σ
Equation
 decreases with the connectivity 
Σ
Equation
 as can be seen in the figure below.
We note that random regular graph is locally tree-like, i.e. when 
Σ
Equation
 is large any node is a root of a tree of some height 
Σ
Equation
 with high probability.
For the node connectivity 
Σ
Equation
 the number of nodes in the tree of height 
Σ
Equation
, rooted at node 
Σ
Equation
, is given by
📈
Equation
In above we assumed that root node has 
Σ
Equation
 children and every internal node has 
Σ
Equation
 children (see figure).
For 
Σ
Equation
 nodes, the minimum 
Σ
Equation
 such that 
Σ
Equation
 is given by
📈
Equation
The latency of broadcast on a tree of 
Σ
Equation
 nodes is expected to be higher than on random regular with the same 
Σ
Equation
 and the same connectivity 
Σ
Equation
. This is due to the presence of loops in the latter.
The numerical results for (average) latency of broadcast on a tree of 
Σ
Equation
 nodes suggest that this average is an upper bound on the average latency of broadcast on on random regular with the same 
Σ
Equation
 and the same connectivity 
Σ
Equation
 as can be seen in the figure below.
Furthermore, numerical results for latency of broadcast on trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.
We note that the latency of broadcast on a tree of finite size is equivalent to the latency of broadcast in finite neighbourhood of a sender node in large random regular graph. In the latter, as 
Σ
Equation
 the finite neighbourhood of a node is (with high prob.) a Cayley tree (see figure below) up to some distance, measured in by number edges between the node and any other node.
The numerical results for latency of broadcast on Cayley trees suggest that the latter also can be used to obtain an upper bound on probability as can be seen in the figure below.
The latency of broadcast on a tree can be computed iteratively. The latter uses the property
📈
Equation
To show this we consider the latency of broadcast on a tree of 
Σ
Equation
 nodes 
Σ
Equation
 rooted at node 
Σ
Equation
 (see figure) as follows.
First, we define the latency of communication a message, sent from node 
Σ
Equation
 to all nodes in
Σ
Equation
, when it is relayed from the node 
Σ
Equation
 to 
Σ
Equation
 as 
Σ
Equation
 then the latency of broadcast
📈
Equation
Second, we consider the latency of broadcast
📈
Equation
Now the maximum distance from node 
Σ
Equation
 to a leaf node 
Σ
Equation
, 
Σ
Equation
, can be computed as follows
📈
Equation
Furthermore, if node 
Σ
Equation
 is adjacent only to leaf nodes but one then
📈
Equation
For node 
Σ
Equation
 not adjacent to leaf nodes the 
Σ
Equation
 can be computed via equation similar to the equation. The latter suggests that the latency of broadcast 
Σ
Equation
 can be computed recursively using above equations and numerical complexity of this computation is 
Σ
Equation
. This is better than 
Σ
Equation
 when Dijkstra's algorithm is used to compute 
Σ
Equation
.
The distribution of the latency of broadcast 
Σ
Equation
 on a Cayley tree of height 
Σ
Equation
 can computed by the population dynamics algorithm as follows.
First, for each 
Σ
Equation
 compute boundary conditions as follows
📈
Equation
Second, for each 
Σ
Equation
 do the following for each 
Σ
Equation
📈
Equation
Finally, for each 
Σ
Equation
 compute
📈
Equation
The prob. distribution of 
Σ
Equation
 for a Cayley tree of height 
Σ
Equation
 can be estimated by the density
📈
Equation
The above dynamics can be described by the equation
📈
Equation
The boundary condition corresponding to the Cayley tree is given by
📈
Equation
The prob. distribution of 
Σ
Equation
 for a Cayley tree of height 
Σ
Equation
 is given by
📈
Equation
Using that the prob. distribution 
Σ
Equation
 is geometric with parameter 
Σ
Equation
, one could try to solve above equations analytically. Also one could consider a single loop and see how this will change the equation.
For 
Σ
Equation
 we have 
Σ
Equation
 with prob. 
Σ
Equation
 and hence the latency of broadcast is dominated by the diameter 
Σ
Equation
 of a random regular graph, i.e. the largest distance between any two nodes. The bounds (using the Theorems 1 and 3) for the latter for (very small) 
Σ
Equation
 are given by
📈
Equation
A Simple Model of Communication Latency in Consensus
To model the communication latency of a node participating in consensus, we assume that latency has two dominant components which are due to delays in “mixing“ and “broadcast” (cf. the formula “Mixnet delay (gamma distribution) sampled once per block + PoL (constant) + final broadcast from exit mixnode (exponential distribution) sampled per node” used in consensus simulations).
We assume that given a network of 
Σ
Equation
 nodes, a gossiping-like mode of communication is used.
Let us assume that the network topology used is a random regular graph 
Σ
Equation
, where 
Σ
Equation
 is the set of nodes and 
Σ
Equation
 is the set of edges, with connectivity 
Σ
Equation
. The latter is sampled only once and remains fixed for the duration of a consensus protocol.
Furthermore, to each edge 
Σ
Equation
 we assign a random variable 
Σ
Equation
, sampled from some probability distribution, to model delays in communication links. This gives rise to the weighted graph 
Σ
Equation
. The probability distribution could be exponential, with parameter 
Σ
Equation
 such that 
Σ
Equation
 is the average and 
Σ
Equation
 is the variance, or 
Σ
Equation
 for all 
Σ
Equation
 (cf. the “300ms” constant delay used in current estimates of latency).
To model the mixing delay we assume, without loss of generality, that node 
Σ
Equation
 sends (via 
Σ
Equation
 mix nodes) a message to node 
Σ
Equation
, and adopt the single-path model as follows
📈
Equation
In above we assume that 
Σ
Equation
 mix nodes, and the sender node 
Σ
Equation
, introduce delays modeled by random variables 
Σ
Equation
 sampled from the Geometric distribution with the parameter 
Σ
Equation
. The latter models a queue which uses coin-flipping to remove a message. Here 
Σ
Equation
 is a cost of attempt to remove a message, measured in units of time, from the queue.
The second part of above equation models the contribution of gossiping to the delay. Here 
Σ
Equation
 is the “distance”, measured in units of time, between the nodes 
Σ
Equation
 and 
Σ
Equation
 on the graph 
Σ
Equation
 which is defined as follows
📈
Equation
Furthermore, the distance 
Σ
Equation
, i.e. samples of random variables 
Σ
Equation
 are different for different 
Σ
Equation
 to model the gossiping aspect of communication.
The distance 
Σ
Equation
 can be interpreted as the latency of (communication) path between the sender node 
Σ
Equation
 and the receiver node 
Σ
Equation
 when the gossiping mode of communication is used.
We note that in a weighted graph 
Σ
Equation
 the distance 
Σ
Equation
 can computed by using the Dijkstra's algorithm.
To model the broadcast delay we assume, without loss of generality, that the node 
Σ
Equation
 broadcasts the message, received from node 
Σ
Equation
, to all nodes in the network. Assuming that gossiping is used the delay is 
Σ
Equation
 for each node 
Σ
Equation
.
To simulate the mixing and broadcast delays in a consensus simulation the following algorithm can be used
Generate a random regular graph 
Σ
Equation
 with connectivity 
Σ
Equation
.
For the sender node 
Σ
Equation
, sending a message to the receiver node 
Σ
Equation
, sample (without replacement) the mix nodes 
Σ
Equation
 and 
Σ
Equation
 from the set of all available nodes 
Σ
Equation
.
Sample the random delays 
Σ
Equation
, from the geometric distribution with parameter 
Σ
Equation
.
Given the random regular graph 
Σ
Equation
, generate the sequence of weighted graphs 
Σ
Equation
 associated with each directed edge in the path 
Σ
Equation
 and compute the distances 
Σ
Equation
 on these graphs.
Compute the mixing delay 
Σ
Equation
Given the same random regular graph 
Σ
Equation
, generate the graph with random weights 
Σ
Equation
 and for the node 
Σ
Equation
 compute the distance 
Σ
Equation
 for all 
Σ
Equation
 . The latter are broadcast delays.
Repeat the steps 2 to 6 for each sender node.
We note that when 
Σ
Equation
, i.e. all communication links have the same latency, then all distances 
Σ
Equation
 on the weighted graph 
Σ
Equation
 can be precomputed which simplifies the steps 4 and 6 in the above algorithm.
Also the algorithm can be easily adopted to use other models of random graphs, and other models of mixing and communication delays.
Bibliography
Amir Dembo. Andrea Montanari. "Ising models on locally tree-like graphs." Ann. Appl. Probab. 20 (2) 565 - 592, April 2010. https://doi.org/10.1214/09-AAP627
Hamed Amini. Marc Lelarge. "The diameter of weighted random graphs." Ann. Appl. Probab. 25 (3) 1686 - 1727, June 2015. https://doi.org/10.1214/14-AAP1034
Mézard, M., Parisi, G. “The Bethe lattice spin glass revisited.” Eur. Phys. J. B 20, 217–233 (2001). https://doi.org/10.1007/PL00011099
Bollobás, B., Fernandez de la Vega, W. “The diameter of random regular graphs.” Combinatorica 2, 125–134 (1982). https://doi.org/10.1007/BF02579310
Open in new tab
