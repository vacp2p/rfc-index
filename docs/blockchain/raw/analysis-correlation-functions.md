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
	
2025-09-08
Introduction 
One of possible approaches to design a reliable anonymous communication (AC) system is to reduce statistical correlations between communicating nodes. Here we model a network of communicating nodes as a probabilistic discrete-state cellular automata (CA). We consider a node-centred approach where a node has associated with it variable representing its discrete state, such as sending, receiving, etc. Also we suggest a more granular connection-centred approach where discrete states of communication links of a node are considered. We note that message-centred approach is also possible but not pursued here. Finally, we discuss functions which can be used to quantify correlations in empirical analysis of AC systems.
The “cellular automata” (CA) model
The system we consider is a network of communicating nodes where nodes are labelled by the set 
[
𝑁
]
=
{
1
,
…
,
𝑁
}
[N]={1,…,N}.
We assume that nodes receive and send messages and these messages are indistinguishable, i.e. it is either impossible to observe bitstreams of messages, or incoming and outgoing messages are bitwise uncorrelated.
The node 
𝑖
∈
[
𝑁
]
i∈[N] at time 
𝑡
t can be in the state of either sending (message) or receiving (message) or inactive, i.e. neither sending or receiving. The latter is modelled by the variable 
𝑆
𝑖
(
𝑡
)
∈
{
−
1
,
0
,
1
}
S
i
	​

(t)∈{−1,0,1} as follows
𝑆
𝑖
(
𝑡
)
S
i
	​

(t)​
	
Node 
𝑖
i at time 
𝑡
t is 


-1
	
sending a message


0
	
inactive


1
	
receiving a message 
We note that  a node can be in more states, for example in addition to sending, receiving, and inactive it could have an additional state of simultaneous sending and receiving, i.e. “send-receive” state. Additional states c can be modelled by extending the alphabet from which 
𝑆
𝑖
(
𝑡
)
S
i
	​

(t) takes its values, i.e. 
𝑆
𝑖
(
𝑡
)
∈
{
1
,
2
,
…
,
𝑞
}
S
i
	​

(t)∈{1,2,…,q} for the most general case.
The vector 
𝑆
(
𝑡
)
=
(
𝑆
1
(
𝑡
)
,
…
,
𝑆
𝑁
(
𝑡
)
)
S(t)=(S
1
	​

(t),…,S
N
	​

(t)) is the state of the network at time 
𝑡
t and for 
𝑡
∈
{
𝑡
0
,
𝑡
1
,
…
,
𝑡
𝐹
}
t∈{t
0
	​

,t
1
	​

,…,t
F
	​

}, where 
𝑡
0
<
𝑡
1
<
…
<
𝑡
𝐹
t
0
	​

<t
1
	​

<…<t
F
	​

, the (ordered by time) set of vectors 
𝑆
(
𝑡
0
)
,
𝑆
(
𝑡
1
)
,
…
,
𝑆
(
𝑡
𝐹
)
S(t
0
	​

),S(t
1
	​

),…,S(t
F
	​

) is the path, through the state-space 
{
−
1
,
0
,
1
}
𝑁
{−1,0,1}
N
, taken by the system from the time 
𝑡
0
t
0
	​

 to the time 
𝑡
𝐹
t
F
	​

. The latter can be represented by a table (or matrix) as in the example below obtained from simulations. 
The state of the network as a function of time. The node 
𝑖
∈
[
𝑁
]
i∈[N] at time 
𝑡
t, represented by dot, is either sending (red dot) or receiving (blue dots) or inactive (white dot). All 
𝑁
N nodes are sending messages through 
𝑘
k nodes with 
𝑘
=
3
k=3. 
Here we expect that dynamics of the network state 
𝑆
(
𝑡
+
Δ
𝑡
)
S(t+Δt) is Markovian, i.e. depends only on 
𝑆
(
𝑡
)
S(t), and can be described by the probability 
P
(
𝑆
(
𝑡
)
)
P(S(t)). We note if the latter is factorises, i.e. 
P
(
𝑆
(
𝑡
)
)
=
∏
𝑖
=
1
𝑁
P
𝑖
(
𝑆
(
𝑡
)
)
P(S(t))=∏
i=1
N
	​

P
i
	​

(S(t)), for all 
𝑡
t then nodes are uncorrelated and “observing” any given node doesn’t reveal any information about the other node/nodes. 
To take this research route further would require to derive master equation for 
P
(
𝑆
(
𝑡
)
)
P(S(t)), to derive and analyse equations for correlation functions, etc. 
Empirical analysis of correlations in CA model
If node 
𝑖
i at time 
𝑡
t is in the state 
𝑆
𝑖
(
𝑡
)
∈
{
−
1
,
0
,
1
}
S
i
	​

(t)∈{−1,0,1} then  the Kronecker delta function is defined as follows 
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
=
{
1
,
𝑆
=
𝑆
𝑖
(
𝑡
)


0
,
𝑆
≠
𝑆
𝑖
(
𝑡
)
δ
S;S
i
	​

(t)
	​

={
1,S=S
i
	​

(t)
0,S

=S
i
	​

(t)
	​

The sum 
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
∑
t∈T
	​

δ
S;S
i
	​

(t)
	​

 counts how many times node i was in state 
𝑠
s on the (ordered) set of times 
𝑇
=
{
𝑡
0
,
𝑡
1
,
…
}
T={t
0
	​

,t
1
	​

,…}, where 
∣
𝑇
∣
=
𝑇
∣T∣=T. Additionally, the latter can be used to define the (empirical) frequency 
𝑃
^
𝑖
(
𝑆
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
P
^
i
	​

(S)=
T
1
	​

∑
t∈T
	​

δ
S;S
i
	​

(t)
	​

. 
The sum 
∑
𝑖
=
1
𝑁
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
∑
i=1
N
	​

δ
S;S
i
	​

(t)
	​

 counts number of nodes in the network which are in state 
𝑠
s at time 
𝑡
t and can be used to define the (empirical) frequency 
𝑃
^
𝑡
(
𝑆
)
=
1
𝑁
∑
𝑖
=
1
𝑁
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
P
^
t
	​

(S)=
N
1
	​

∑
i=1
N
	​

δ
S;S
i
	​

(t)
	​

. 
The sum 
∑
𝑖
=
1
𝑁
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑖
(
𝑡
+
𝑡
𝑤
)
∑
i=1
N
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
i
	​

(t+t
w
	​

)
	​

 counts how many nodes in the network were in state 
𝑆
S at time 
𝑡
t and in state 
𝑠
~
s
~
 at time 
𝑡
+
𝑡
𝑤
t+t
w
	​

, where 
𝑡
𝑤
>
0
t
w
	​

>0, can be used to define the joint (empirical) frequency (or correlation function) 
𝑃
^
𝑡
,
𝑡
+
𝑡
𝑤
(
𝑆
,
𝑆
~
)
=
1
𝑁
∑
𝑖
=
1
𝑁
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑖
(
𝑡
+
𝑡
𝑤
)
P
^
t,t+t
w
	​

	​

(S,
S
~
)=
N
1
	​

∑
i=1
N
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
i
	​

(t+t
w
	​

)
	​

. 
In a similar manner we can define the (spatial) correlation function 
𝐶
𝑡
,
𝑡
+
𝑡
𝑤
(
𝑆
,
𝑆
~
)
=
2
𝑁
(
𝑁
−
1
)
∑
𝑖
<
𝑗
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑗
(
𝑡
+
𝑡
𝑤
)
C
t,t+t
w
	​

	​

(S,
S
~
)=
N(N−1)
2
	​

i<j
∑
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
j
	​

(t+t
w
	​

)
	​

In above the sum 
∑
𝑖
<
𝑗
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑗
(
𝑡
+
𝑡
𝑤
)
∑
i<j
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
j
	​

(t+t
w
	​

)
	​

 counts how many pairs of distinct nodes in the network (there are 
𝑁
(
𝑁
−
1
)
/
2
N(N−1)/2 such pairs in total ) were in state 
𝑠
s and 
𝑠
~
s
~
 at, respectively, the time 
𝑡
t and 
𝑡
+
𝑡
𝑤
t+t
w
	​

​
Node-centred approach
We adopt the CA model where state of AC system at time 
𝑡
t is described by the vector 
𝑆
(
𝑡
)
=
(
𝑆
1
(
𝑡
)
,
…
,
𝑆
𝑁
(
𝑡
)
)
S(t)=(S
1
	​

(t),…,S
N
	​

(t)), where the variable 
𝑆
𝑖
(
𝑡
)
S
i
	​

(t) is the state of node 
𝑖
i, such as receiving a message, sending a message, etc., at time 
𝑡
t. For example 
𝑆
𝑖
(
𝑡
)
∈
{
−
1
,
0
,
1
}
S
i
	​

(t)∈{−1,0,1}, where 
−
1
−1 corresponds to sending, 
0
0 corresponds to inactive and 
1
1 corresponds to receiving. 
We note that a node connected to more than two nodes can be receiving and/or sending multiple messages at the same time. However, to simplify analysis we will assume that at any time a node can receive (or send) at most one message. 
We assume that we have observed 
𝑇
T such vectors at times collected in the (ordered) set 
𝑇
=
{
𝑡
0
,
𝑡
1
,
…
}
T={t
0
	​

,t
1
	​

,…}, where 
∣
𝑇
∣
=
𝑇
∣T∣=T. 
	
𝑡
0
t
0
	​

​
	
𝑡
1
t
1
	​

​
	
𝑡
2
t
2
	​

​
	
⋯
⋯​
	
𝑡
𝑇
−
1
t
T−1
	​

​


𝑆
1
S
1
	​

​
	
-1
	
0
	
1
	
⋮
⋮​
	
-1


𝑆
2
S
2
	​

​
	
0
	
1
	
0
	
⋮
⋮​
	
1


⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​


𝑆
𝑖
S
i
	​

​
	
-1
	
0
	
-1
	
⋮
⋮​
	
1


𝑆
𝑗
S
j
	​

​
	
1
	
0
	
-1
	
⋮
⋮​
	
1


⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​
	
⋮
⋮​


𝑆
𝑁
S
N
	​

​
	
0
	
0
	
0
	
⋯
⋯​
	
1
We define the indicator function: 
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
=
1
δ
S;S
i
	​

(t)
	​

=1 when 
𝑆
=
𝑆
𝑖
(
𝑡
)
S=S
i
	​

(t) and 
0
0 otherwise, i.e. this is the Kronecker delta function. The latter allows us to define various “correlation functions” such as the (empirical) frequency 
𝑃
^
𝑖
(
𝑆
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
P
^
i
	​

(S)=
T
1
	​

∑
t∈T
	​

δ
S;S
i
	​

(t)
	​

 , the joint frequency 
𝑃
^
𝑖
𝑗
(
𝑆
,
𝑆
~
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑗
(
𝑡
)
P
^
ij
	​

(S,
S
~
)=
T
1
	​

∑
t∈T
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
j
	​

(t)
	​

, etc. 
In general the product 
𝛿
𝑆
𝑖
1
;
𝑆
𝑖
1
(
𝑡
1
)
×
⋯
×
𝛿
𝑆
𝑖
𝑘
;
𝑆
𝑖
𝑘
(
𝑡
𝑘
)
δ
S
i
1
	​

	​

;S
i
1
	​

	​

(t
1
	​

)
	​

×⋯×δ
S
i
k
	​

	​

;S
i
k
	​

	​

(t
k
	​

)
	​

 could be used to construct any correlation function. 
Connection-centred approach 
The state of node 
𝑖
i, with respect to its connection to the node 
𝑗
j, at time 
𝑡
t is described by the variable 
𝑆
𝑖
𝑗
(
𝑡
)
∈
{
−
1
,
0
,
1
}
S
ij
	​

(t)∈{−1,0,1}, where 
−
1
−1 corresponds to node 
𝑖
i sending message to node 
𝑗
j, 
0
0 corresponds to “no-communication” state between nodes and 
1
1 corresponds to node 
𝑖
i receiving a message from node 
𝑗
j.
We could use an extended alphabet as additional states may exist. For example, it is possible that node 
𝑖
i is both simultaneously sending a message to node 
𝑗
j and receiving a message from 
𝑗
j, i.e. node 
𝑖
i is in “send-receive” state. This situation can be modelled by the variable 
𝑆
𝑖
𝑗
(
𝑡
)
∈
{
∅
,
−
1
,
0
,
1
}
S
ij
	​

(t)∈{∅,−1,0,1}, where 
∅
∅ corresponds to “no-communication” state between nodes, 
−
1
−1 corresponds to node 
𝑖
i sending message to node 
𝑗
j, 
0
0 corresponds to node i in “send-receive” state and 
1
1 corresponds to node 
𝑖
i receiving a message from node 
𝑗
j.
Let us define the set of nodes connected to the node 
𝑖
i as the (ordered) set 
∂
𝑖
=
{
𝑖
1
,
𝑖
2
,
…
,
𝑖
𝑐
}
∂i={i
1
	​

,i
2
	​

,…,i
c
	​

} (
∂
𝑖
∂i notation here means “neighbourhood” of node 
𝑖
i) then the state of node 
𝑖
i, with respect to all of its connections, at time 
𝑡
t is the (ordered by 
∂
𝑖
∂i ) set (or vector) 
𝑆
𝑖
(
𝑡
)
=
{
𝑆
𝑖
𝑗
(
𝑡
)
∣
𝑗
∈
∂
𝑖
}
S
i
	​

(t)={S
ij
	​

(t)∣j∈∂i}, i.e. the state of its connections at time 
𝑡
t. We note that “no-communication” and not being a member of 
∂
𝑖
∂i are different concepts.
Using above definition the state of all nodes at time 
𝑡
t can be described by the “vector” 
𝑆
(
𝑡
)
=
[
𝑆
1
(
𝑡
)


⋮


𝑆
𝑖
(
𝑡
)


⋮


𝑆
𝑁
(
𝑡
)
]
S(t)=
	​

S
1
	​

(t)
⋮
S
i
	​

(t)
⋮
S
N
	​

(t)
	​

	​

We note that 
𝑆
𝑖
(
𝑡
)
∈
{
−
1
,
0
,
1
}
∣
∂
𝑖
∣
S
i
	​

(t)∈{−1,0,1}
∣∂i∣
, i.e. 
𝑆
𝑖
(
𝑡
)
S
i
	​

(t) can be any ternary string of length 
∣
∂
𝑖
∣
∣∂i∣. Hence 
𝑆
𝑖
(
𝑡
)
S
i
	​

(t) can be represented by a single number from the set 
[
3
∣
∂
𝑖
∣
]
[3
∣∂i∣
] once the mapping between the sets 
{
−
1
,
0
,
1
}
∣
∂
𝑖
∣
{−1,0,1}
∣∂i∣
 and 
[
3
∣
∂
𝑖
∣
]
[3
∣∂i∣
] is fixed. 
For 
𝑆
∈
{
−
1
,
0
,
1
}
∣
∂
𝑖
∣
S∈{−1,0,1}
∣∂i∣
 we can define the frequency for node 
𝑖
i as follows 
𝑃
^
𝑖
(
𝑆
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
,
P
^
i
	​

(S)=
T
1
	​

t∈T
∑
	​

δ
S;S
i
	​

(t)
	​

,
where 
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
=
∏
𝑗
∈
∂
𝑖
𝛿
𝑆
𝑗
;
𝑆
𝑖
𝑗
(
𝑡
)
δ
S;S
i
	​

(t)
	​

=∏
j∈∂i
	​

δ
S
j
	​

;S
ij
	​

(t)
	​

, which “counts” how many times connections of node 
𝑖
i, with respect to 
∂
𝑖
∂i, were in some specific communication “pattern” 
𝑆
S. 
In a similar manner for 
𝑆
∈
{
−
1
,
0
,
1
}
∣
∂
𝑖
∣
S∈{−1,0,1}
∣∂i∣
 and 
𝑆
~
∈
{
−
1
,
0
,
1
}
∣
∂
𝑗
∣
S
~
∈{−1,0,1}
∣∂j∣
 we can define the joint frequency 
𝑃
^
𝑖
𝑗
(
𝑆
,
𝑆
~
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑗
(
𝑡
)
P
^
ij
	​

(S,
S
~
)=
T
1
	​

t∈T
∑
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
j
	​

(t)
	​

for nodes 
𝑖
i and 
𝑗
j.
Mutual information
For the joint frequency 
𝑃
^
𝑖
𝑗
(
𝑆
,
𝑆
~
)
=
1
𝑇
∑
𝑡
∈
𝑇
𝛿
𝑆
;
𝑆
𝑖
(
𝑡
)
𝛿
𝑆
~
;
𝑆
𝑗
(
𝑡
)
P
^
ij
	​

(S,
S
~
)=
T
1
	​

∑
t∈T
	​

δ
S;S
i
	​

(t)
	​

δ
S
~
;S
j
	​

(t)
	​

 the (empirical) mutual information 
𝐼
^
𝑖
𝑗
=
∑
𝑆
∑
𝑆
~
𝑃
^
𝑖
𝑗
(
𝑆
,
𝑆
~
)
log
⁡
𝑃
^
𝑖
𝑗
(
𝑆
,
𝑆
~
)
𝑃
^
𝑖
(
𝑆
)
𝑃
^
𝑗
(
𝑆
~
)
I
^
ij
	​

=∑
S
	​

∑
S
~
	​

P
^
ij
	​

(S,
S
~
)log
P
^
i
	​

(S)
P
^
j
	​

(
S
~
)
P
^
ij
	​

(S,
S
~
)
	​

 can be used as a measure of dependence between states of node 
𝑖
i and 
𝑗
j. The latter can be used in both node-centric and connection-centric approaches.
Hamming distance
The (normalised) Hamming distance between the vectors 
𝑆
(
𝑡
)
=
(
𝑆
1
(
𝑡
)
,
…
,
𝑆
𝑁
(
𝑡
)
)
S(t)=(S
1
	​

(t),…,S
N
	​

(t)) and 
𝑆
~
(
𝑡
~
)
=
(
𝑆
~
1
(
𝑡
~
)
,
…
,
𝑆
~
𝑁
(
𝑡
~
)
)
S
~
(
t
~
)=(
S
~
1
	​

(
t
~
),…,
S
~
N
	​

(
t
~
)) is the sum 
D
𝐻
(
𝑆
(
𝑡
)
∣
∣
𝑆
~
(
𝑡
~
)
)
=
1
𝑁
∑
𝑖
=
1
𝑁
(
1
−
𝛿
𝑆
𝑖
(
𝑡
)
;
𝑆
~
𝑖
(
𝑡
~
)
)
D
H
	​

(S(t)∣∣
S
~
(
t
~
))=
N
1
	​

∑
i=1
N
	​

(1−δ
S
i
	​

(t);
S
~
i
	​

(
t
~
)
	​

), i.e. the  number of disagreements between the 
𝑆
(
𝑡
)
S(t) and 
𝑆
~
(
𝑡
~
)
S
~
(
t
~
) is counted and divided by 
𝑁
N. 
We note when 
𝑆
𝑖
(
𝑡
)
S
i
	​

(t) is set (or vector) as in the section on connection-centric approach then 
𝛿
𝑆
𝑖
(
𝑡
)
;
𝑆
~
𝑖
(
𝑡
~
)
=
∏
𝑗
∈
∂
𝑖
𝛿
𝑆
𝑖
𝑗
(
𝑡
)
;
𝑆
~
𝑖
𝑗
(
𝑡
~
)
δ
S
i
	​

(t);
S
~
i
	​

(
t
~
)
	​

=∏
j∈∂i
	​

δ
S
ij
	​

(t);
S
~
ij
	​

(
t
~
)
	​

, i.e. the latter is 
1
1 if and only if states of all connections of node 
𝑖
i in 
𝑆
(
𝑡
)
S(t) and 
𝑆
~
(
𝑡
)
S
~
(t) are the same. 
We note that 
0
≤
D
𝐻
(
𝑆
(
𝑡
)
∣
∣
𝑆
~
(
𝑡
~
)
)
≤
1
0≤D
H
	​

(S(t)∣∣
S
~
(
t
~
))≤1 with 
0
0 when 
𝑆
(
𝑡
)
=
𝑆
~
(
𝑡
~
)
S(t)=
S
~
(
t
~
) and 1 when 
𝑆
𝑖
(
𝑡
)
≠
𝑆
~
𝑖
(
𝑡
~
)
S
i
	​

(t)

=
S
~
i
	​

(
t
~
) for all 
𝑖
∈
[
𝑁
]
i∈[N].
Assuming that we observe the states 
𝑆
(
𝑡
)
S(t) and 
𝑆
~
(
𝑡
)
S
~
(t) of two systems on the same time-set 
𝑇
T, where 
∣
𝑇
∣
=
𝑇
∣T∣=T, the (average) Hamming distance 
𝐷
‾
𝐻
(
𝑇
)
=
1
𝑇
∑
𝑡
∈
𝑇
D
𝐻
(
𝑆
(
𝑡
)
∣
∣
𝑆
~
(
𝑡
)
)
D
H
	​

(T)=
T
1
	​

∑
t∈T
	​

D
H
	​

(S(t)∣∣
S
~
(t)) measures how these two systems are different. We note that 
0
≤
𝐷
‾
𝐻
(
𝑇
)
≤
1
0≤
D
H
	​

(T)≤1 with 
0
0 when 
𝑆
(
𝑡
)
=
𝑆
~
(
𝑡
)
S(t)=
S
~
(t) for all 
𝑡
∈
𝑇
t∈T and 
1
1 when 
𝑆
𝑖
(
𝑡
)
≠
𝑆
~
𝑖
(
𝑡
)
S
i
	​

(t)

=
S
~
i
	​

(t) for all 
𝑖
∈
[
𝑁
]
i∈[N] and all 
𝑡
∈
𝑇
t∈T. 
Let us assume we observed at times 
𝑡
∈
𝑇
t∈T the states 
𝑆
1
(
𝑡
)
S
1
(t) and 
𝑆
2
(
𝑡
)
S
2
(t) of two copies of exactly the same AC system. That is the graph 
𝐺
G is the same in both copies, with exactly the same LEVEL 0 noise, i.e. if node 
𝑖
i in copy 
1
1, described by 
𝑆
1
(
𝑡
)
S
1
(t), is sending a (LEVEL 0) message then node 
𝑖
i in copy 
2
2, described by 
𝑆
2
(
𝑡
)
S
2
(t), is also sending the same message, etc. We note that the latter can be achieved in simulation which usually uses pseudo-randomness and hence evolution of AC system in time is deterministic. The latter implies that 
D
𝐻
(
𝑆
1
(
𝑡
)
∣
∣
𝑆
2
(
𝑡
)
)
=
0
D
H
	​

(S
1
(t)∣∣S
2
(t))=0 for all 
𝑡
∈
𝑇
t∈T and hence in this case 
𝐷
‾
𝐻
(
𝑇
)
=
0
D
H
	​

(T)=0.
Let us now, without loss of generality, assume that node 
1
1 in the copy 
2
2, described by 
𝑆
2
(
𝑡
)
S
2
(t), sent a LEVEL 2 message, through the nodes 
2
,
3
,
…
,
𝑘
−
1
2,3,…,k−1, to the node 
𝑘
k at time 
𝑡
0
t
0
	​

 and node 
𝑘
k received this message at time 
𝑡
1
t
1
	​

. 
We note that for 
𝑇
<
𝑡
0
T<t
0
	​

 we have 
𝐷
‾
𝐻
(
𝑇
)
=
0
D
H
	​

(T)=0 because states of copies 1 and 2, described by 
𝑆
1
(
𝑡
)
S
1
(t) and 
𝑆
2
(
𝑡
)
S
2
(t), are exactly the same before this event. For times 
𝑇
≥
𝑡
0
T≥t
0
	​

 we can have 
𝐷
‾
𝐻
(
𝑇
)
>
0
D
H
	​

(T)>0, i.e. the states of copies 
1
1 and 
2
2, described by 
𝑆
1
(
𝑡
)
S
1
(t) and 
𝑆
2
(
𝑡
)
S
2
(t), are different after the event at 
𝑡
0
t
0
	​

. 
\mathbf{S}(t) = \begin{bmatrix}
S_{1}(t)  \\\vdots  \\
S_{i}(t)  \\
\vdots  \\
S_{N}(t) 
\end{bmatrix}

Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Correlation Functions
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Correlation Functions
Authors: Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Table
Introduction
One of possible approaches to design a reliable anonymous communication (AC) system is to reduce statistical correlations between communicating nodes. Here we model a network of communicating nodes as a probabilistic discrete-state cellular automata (CA). We consider a node-centred approach where a node has associated with it variable representing its discrete state, such as sending, receiving, etc. Also we suggest a more granular connection-centred approach where discrete states of communication links of a node are considered. We note that message-centred approach is also possible but not pursued here. Finally, we discuss functions which can be used to quantify correlations in empirical analysis of AC systems.
The “cellular automata” (CA) model
The system we consider is a network of communicating nodes where nodes are labelled by the set 
Σ
Equation
.
We assume that nodes receive and send messages and these messages are indistinguishable, i.e. it is either impossible to observe bitstreams of messages, or incoming and outgoing messages are bitwise uncorrelated.
The node 
Σ
Equation
 at time 
Σ
Equation
 can be in the state of either sending (message) or receiving (message) or inactive, i.e. neither sending or receiving. The latter is modelled by the variable 
Σ
Equation
 as follows
Table
We note that a node can be in more states, for example in addition to sending, receiving, and inactive it could have an additional state of simultaneous sending and receiving, i.e. “send-receive” state. Additional states c can be modelled by extending the alphabet from which 
Σ
Equation
 takes its values, i.e. 
Σ
Equation
 for the most general case.
The vector 
Σ
Equation
 is the state of the network at time 
Σ
Equation
 and for 
Σ
Equation
, where 
Σ
Equation
, the (ordered by time) set of vectors 
Σ
Equation
 is the path, through the state-space 
Σ
Equation
, taken by the system from the time 
Σ
Equation
 to the time 
Σ
Equation
. The latter can be represented by a table (or matrix) as in the example below obtained from simulations.
Here we expect that dynamics of the network state 
Σ
Equation
 is Markovian, i.e. depends only on 
Σ
Equation
, and can be described by the probability 
Σ
Equation
. We note if the latter is factorises, i.e. 
Σ
Equation
, for all 
Σ
Equation
 then nodes are uncorrelated and “observing” any given node doesn’t reveal any information about the other node/nodes.
To take this research route further would require to derive master equation for 
Σ
Equation
, to derive and analyse equations for correlation functions, etc.
Empirical analysis of correlations in CA model
If node 
Σ
Equation
 at time 
Σ
Equation
 is in the state 
Σ
Equation
 then the Kronecker delta function is defined as follows
📈
Equation
The sum 
Σ
Equation
 counts how many times node i was in state 
Σ
Equation
 on the (ordered) set of times 
Σ
Equation
, where 
Σ
Equation
. Additionally, the latter can be used to define the (empirical) frequency 
Σ
Equation
.
The sum 
Σ
Equation
 counts number of nodes in the network which are in state 
Σ
Equation
 at time 
Σ
Equation
 and can be used to define the (empirical) frequency 
Σ
Equation
.
The sum 
Σ
Equation
 counts how many nodes in the network were in state 
Σ
Equation
 at time 
Σ
Equation
 and in state 
Σ
Equation
 at time 
Σ
Equation
, where 
Σ
Equation
, can be used to define the joint (empirical) frequency (or correlation function) 
Σ
Equation
.
In a similar manner we can define the (spatial) correlation function
📈
Equation
In above the sum 
Σ
Equation
 counts how many pairs of distinct nodes in the network (there are 
Σ
Equation
 such pairs in total ) were in state 
Σ
Equation
 and 
Σ
Equation
 at, respectively, the time 
Σ
Equation
 and 
Σ
Equation
Node-centred approach
We adopt the CA model where state of AC system at time 
Σ
Equation
 is described by the vector 
Σ
Equation
, where the variable 
Σ
Equation
 is the state of node 
Σ
Equation
, such as receiving a message, sending a message, etc., at time 
Σ
Equation
. For example 
Σ
Equation
, where 
Σ
Equation
 corresponds to sending, 
Σ
Equation
 corresponds to inactive and 
Σ
Equation
 corresponds to receiving.
We note that a node connected to more than two nodes can be receiving and/or sending multiple messages at the same time. However, to simplify analysis we will assume that at any time a node can receive (or send) at most one message.
We assume that we have observed 
Σ
Equation
 such vectors at times collected in the (ordered) set 
Σ
Equation
, where 
Σ
Equation
.
Table
We define the indicator function: 
Σ
Equation
 when 
Σ
Equation
 and 
Σ
Equation
 otherwise, i.e. this is the Kronecker delta function. The latter allows us to define various “correlation functions” such as the (empirical) frequency 
Σ
Equation
 , the joint frequency 
Σ
Equation
, etc.
In general the product 
Σ
Equation
 could be used to construct any correlation function.
Connection-centred approach
The state of node 
Σ
Equation
, with respect to its connection to the node 
Σ
Equation
, at time 
Σ
Equation
 is described by the variable 
Σ
Equation
, where 
Σ
Equation
 corresponds to node 
Σ
Equation
 sending message to node 
Σ
Equation
, 
Σ
Equation
 corresponds to “no-communication” state between nodes and 
Σ
Equation
 corresponds to node 
Σ
Equation
 receiving a message from node 
Σ
Equation
.
We could use an extended alphabet as additional states may exist. For example, it is possible that node 
Σ
Equation
 is both simultaneously sending a message to node 
Σ
Equation
 and receiving a message from 
Σ
Equation
, i.e. node 
Σ
Equation
 is in “send-receive” state. This situation can be modelled by the variable 
Σ
Equation
, where 
Σ
Equation
 corresponds to “no-communication” state between nodes, 
Σ
Equation
 corresponds to node 
Σ
Equation
 sending message to node 
Σ
Equation
, 
Σ
Equation
 corresponds to node i in “send-receive” state and 
Σ
Equation
 corresponds to node 
Σ
Equation
 receiving a message from node 
Σ
Equation
.
Let us define the set of nodes connected to the node 
Σ
Equation
 as the (ordered) set 
Σ
Equation
 (
Σ
Equation
 notation here means “neighbourhood” of node 
Σ
Equation
) then the state of node 
Σ
Equation
, with respect to all of its connections, at time 
Σ
Equation
 is the (ordered by 
Σ
Equation
 ) set (or vector) 
Σ
Equation
, i.e. the state of its connections at time 
Σ
Equation
. We note that “no-communication” and not being a member of 
Σ
Equation
 are different concepts.
Using above definition the state of all nodes at time 
Σ
Equation
 can be described by the “vector”
📈
Equation
We note that 
Σ
Equation
, i.e. 
Σ
Equation
 can be any ternary string of length 
Σ
Equation
. Hence 
Σ
Equation
 can be represented by a single number from the set 
Σ
Equation
 once the mapping between the sets 
Σ
Equation
 and 
Σ
Equation
 is fixed.
For 
Σ
Equation
 we can define the frequency for node 
Σ
Equation
 as follows
📈
Equation
where 
Σ
Equation
, which “counts” how many times connections of node 
Σ
Equation
, with respect to 
Σ
Equation
, were in some specific communication “pattern” 
Σ
Equation
.
In a similar manner for 
Σ
Equation
 and 
Σ
Equation
 we can define the joint frequency
📈
Equation
for nodes 
Σ
Equation
 and 
Σ
Equation
.
Mutual information
For the joint frequency 
Σ
Equation
 the (empirical) mutual information 
Σ
Equation
 can be used as a measure of dependence between states of node 
Σ
Equation
 and 
Σ
Equation
. The latter can be used in both node-centric and connection-centric approaches.
Hamming distance
The (normalised) Hamming distance between the vectors 
Σ
Equation
 and 
Σ
Equation
 is the sum 
Σ
Equation
, i.e. the number of disagreements between the 
Σ
Equation
 and 
Σ
Equation
 is counted and divided by 
Σ
Equation
.
We note when 
Σ
Equation
 is set (or vector) as in the section on connection-centric approach then 
Σ
Equation
, i.e. the latter is 
Σ
Equation
 if and only if states of all connections of node 
Σ
Equation
 in 
Σ
Equation
 and 
Σ
Equation
 are the same.
We note that 
Σ
Equation
 with 
Σ
Equation
 when 
Σ
Equation
 and 1 when 
Σ
Equation
 for all 
Σ
Equation
.
Assuming that we observe the states 
Σ
Equation
 and 
Σ
Equation
 of two systems on the same time-set 
Σ
Equation
, where 
Σ
Equation
, the (average) Hamming distance 
Σ
Equation
 measures how these two systems are different. We note that 
Σ
Equation
 with 
Σ
Equation
 when 
Σ
Equation
 for all 
Σ
Equation
 and 
Σ
Equation
 when 
Σ
Equation
 for all 
Σ
Equation
 and all 
Σ
Equation
.
Let us assume we observed at times 
Σ
Equation
 the states 
Σ
Equation
 and 
Σ
Equation
 of two copies of exactly the same AC system. That is the graph 
Σ
Equation
 is the same in both copies, with exactly the same LEVEL 0 noise, i.e. if node 
Σ
Equation
 in copy 
Σ
Equation
, described by 
Σ
Equation
, is sending a (LEVEL 0) message then node 
Σ
Equation
 in copy 
Σ
Equation
, described by 
Σ
Equation
, is also sending the same message, etc. We note that the latter can be achieved in simulation which usually uses pseudo-randomness and hence evolution of AC system in time is deterministic. The latter implies that 
Σ
Equation
 for all 
Σ
Equation
 and hence in this case 
Σ
Equation
.
Let us now, without loss of generality, assume that node 
Σ
Equation
 in the copy 
Σ
Equation
, described by 
Σ
Equation
, sent a LEVEL 2 message, through the nodes 
Σ
Equation
, to the node 
Σ
Equation
 at time 
Σ
Equation
 and node 
Σ
Equation
 received this message at time 
Σ
Equation
.
We note that for 
Σ
Equation
 we have 
Σ
Equation
 because states of copies 1 and 2, described by 
Σ
Equation
 and 
Σ
Equation
, are exactly the same before this event. For times 
Σ
Equation
 we can have 
Σ
Equation
, i.e. the states of copies 
Σ
Equation
 and 
Σ
Equation
, described by 
Σ
Equation
 and 
Σ
Equation
, are different after the event at 
Σ
Equation
.
Open in new tab
