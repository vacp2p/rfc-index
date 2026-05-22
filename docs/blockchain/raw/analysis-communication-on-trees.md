# ANALYSISCOMMUNICATION-ON-TREES

| Field | Value |
| --- | --- |
| Name | [Analysis] Communication on Trees |
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
	
2025-08-25
Introduction
We would like to understand how to reduce probability of a communication failure, i.e. when a message sent by a node is “lost” somewhere in the network and not broadcasted. The latter is a main concern as a naive approach of retransmission increases the delay and bandwidth, and reduces anonymity. We have identified two approaches with a potential to reduce communication failure. In the first approach, the sender node uses multiple independent linear paths, i.e. linear trees, to send a message. However, initial analysis suggests that to reduce communication failure in the latter, one must increase the number of communication paths significantly which would have detrimental effect on the bandwidth of a sending node. In the second approach, where the sender node is root of a branching tree, bandwidth of a sending node is only weakly affected by the number communication paths. 
First, we assume that a fraction of nodes in the network is adversarial and compute the probability of broadcast and anonymity failures for broadcasting on linear trees. We note that if each communication path has at least one adversarial node then this is considered to be a broadcasting failure and if there is at least one path where all nodes are adversarial then this considered to be anonymity failure. Probabilities are parametrised by the fraction of adversarial nodes, number of paths and number of nodes per path. Second, we compute failure probabilities for broadcasting on branching trees. Assuming the same number of paths, we compare results for linear and branching trees and we find that the linear tree design has better broadcast failure properties than the branching tree design, but worse anonymity failure properties. Finally, we assume that, in addition to adversarial nodes, we also have “faulty” nodes in the network. The latter are unable to relay a messages and their faultiness is a result of some “natural” process. Here we find only quantitative differences with the scenario when only adversarial nodes are considered, but we expect that the model which accounts for “natural” failures to be more realistic.
💡
Details of mathematical derivations, with references to literature, and additional numerical results are provided in the Appendix. 
Overview
This document investigates methods to reduce communication failures in network messaging by comparing two primary designs: linear trees and branching trees. The study focuses on minimizing broadcast failures (lost messages) and anonymity failures (privacy breaches) while considering bandwidth constraints.
The analysis uses probabilistic models and recursive equations to compute failure probabilities under adversarial and faulty node conditions. For linear trees, broadcast and anonymity failures are derived based on path length and the number of independent paths. For branching trees, recursive methods determine critical thresholds where failures become inevitable.
A two-variable model is introduced to separate natural faults from adversarial behavior, improving realism. Simulations validate theoretical results, showing trade-offs:
Linear trees offer better broadcast reliability but worse anonymity and higher bandwidth costs.
Branching trees reduce anonymity risks and bandwidth usage but are more vulnerable to shared-node failures.
The findings guide design choices based on network priorities (e.g., reliability vs. privacy) and constraints (e.g., node bandwidth). The appendix includes detailed derivations and simulation results.
Analysis 
Communication on Linear Trees
Communication on Linear Trees. The node sends a message through 
𝐾
K communication paths where each path is a linear tree constructed from exactly 
𝐿
L nodes. 
We assume that a node sends a message through 
𝐾
K communication paths where each path is a linear tree constructed from exactly 
𝐿
L nodes (see figure above). We assumed that 
𝐿
×
𝐾
L×K nodes were sampled (with replacement) from the population of 
𝑁
N nodes where 
𝑁
𝐹
N
F
	​

 nodes are “faulty”. If a path contains at least one faulty node then communication failure occurred. If all 
𝐾
K paths have communication failure then broadcast failure occurred.
If nodes in communication paths are sampled with replacement from the 
𝑁
N network nodes with 
𝑁
𝐹
<
𝑁
N
F
	​

<N faulty nodes then the probability that a node is faulty is 
𝑞
=
𝑁
𝐹
/
𝑁
q=N
F
	​

/N. The probability of broadcast failure is given by
P
𝑏
=
[
1
−
(
1
−
𝑞
)
𝐿
]
𝐾
.
P
b
	​

=[1−(1−q)
L
]
K
.
We note that in the limit 
𝐿
→
∞
L→∞, such that 
𝐾
/
𝐿
→
0
K/L→0, the probability of broadcast failure 
P
𝑏
→
1
P
b
	​

→1 and in the limit 
𝐾
→
∞
K→∞, such that 
𝐿
/
𝐾
→
0
L/K→0, the probability 
P
𝑏
→
0
P
b
	​

→0.
Let us now assume that 
𝑞
q is the probability that a node is “curious”. Then the event "there is at least one path where all nodes are curious" is the anonymity failure. The probability of anonymity failure is given by 
P
𝑎
=
1
−
(
1
−
𝑞
𝐿
)
𝐾
.
P
a
	​

=1−(1−q
L
)
K
.
We note that in the limit 
𝐿
→
∞
L→∞, such that 
𝐾
/
𝐿
→
0
K/L→0, the probability of anonymity failure 
P
𝑎
→
0
P
a
	​

→0 and in the limit 
𝐾
→
∞
K→∞, such that 
𝐿
/
𝐾
→
0
L/K→0, the probability 
P
𝑎
→
1
P
a
	​

→1.
Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below 
Analysis  of failures in  
2
𝐿
2
L
 linear trees with 
𝐿
L layers. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the fraction  
𝑞
=
0.3
q=0.3 of faulty nodes.  Right: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the fraction  
𝑞
=
0.3
q=0.3 of “curious” nodes. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
Analysis of failures in 
2
𝐿
2
L
 linear trees with 
𝐿
L layers. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the fraction 
𝑞
=
0.6
q=0.6 of faulty nodes. Right: The probability of anonymity
failure plotted as a function of the number of layers 
𝐿
L for the fraction 
𝑞
=
0.6
q=0.6 of “curious” nodes. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
We note that the number of samples 
𝑀
M in above figures is equivalent to the number of messages sent by a sender node. 
Communication on Branching Trees 
Assumptions
We consider broadcasting on a tree 
𝑇
𝐿
T
L
	​

 with layers labeled, from leaf nodes to the root node, by the set 
{
0
,
1
,
…
,
𝐿
}
{0,1,…,L} (see figure below). All nodes in a tree at the same distance from its root constitute a layer. We assume that the root node of 
𝑇
𝐿
T
L
	​

 is sending a message to leaf nodes. A node inside 
𝑇
𝐿
T
L
	​

 is relaying a message to 
𝑏
b nodes, i.e. 
𝑇
𝐿
T
L
	​

 is 
𝑏
b-ary tree.  The set of all leaf node is the “boundary” 
∂
𝑇
𝐿
∂T
L
	​

 of the tree 
𝑇
𝐿
T
L
	​

. 
𝑏
b-ary tree 
𝑇
𝐿
T
L
	​

 is balanced and complete if all distances from the root node to a leaf node are the same. 
In this document we consider only balanced and complete 
𝑏
b-ary trees. The number of leaf nodes 
∣
∂
𝑇
𝐿
∣
=
𝑏
𝐿
∣∂T
L
	​

∣=b
L
 is also the number of paths from the root node to leaf nodes. If all leaf nodes didn't receive a message sent from the root node then broadcast failure occurred. Let us now assume that 
𝑞
q is the probability that a node is “curious”. Then the event "there is at least one path where all nodes are curious" is the anonymity failure.
Communication on a (balanced and complete) tree 
𝑇
𝐿
T
L
	​

. The layers in the tree are labeled by the set 
{
0
,
1
,
…
,
𝐿
}
{0,1,…,L} (bottom to top).  A message is sent from the root node (layer 
𝐿
L)  to the leaf nodes (layer 
0
0). All leaf nodes of the tree 
𝑇
𝐿
T
L
	​

 constitute its boundary 
∂
𝑇
𝐿
∂T
L
	​

. Each node in the tree, but the root, has associated with it binary random variable.
Analysis of communication failures 
The prob. of broadcast failure 
𝐵
𝐿
B
L
	​

 in the tree with 
𝐿
L layers and branching parameter 
𝑏
b can be computed recursively (see the Details of derivations section) via the following set of equations
𝐵
𝐿
=
P
𝐿
−
1
𝑏
                        
P
ℓ
+
1
=
1
−
(
1
−
𝑞
)
[
1
−
P
ℓ
𝑏
]
P
0
=
𝑞
B
L
	​

=P
L−1
b
	​

                        P
ℓ+1
	​

=1−(1−q)[1−P
ℓ
b
	​

]
P
0
	​

=q
Solving above equations gives the following results
The (critical) probability that a node is faulty,  
𝑞
𝑐
=
(
𝑏
−
1
)
/
𝑏
q
c
	​

=(b−1)/b, as a function of tree branching factor 
𝑏
b. For 
𝑞
>
𝑞
𝑐
q>q
c
	​

 broadcast  on a tree is only possible for a small number of layers.  For 
𝑞
<
𝑞
𝑐
q<q
c
	​

 broadcast is possible for infinite number of layers.
The probability of broadcast failure (lower and upper bound) plotted as a function of probability that a node is faulty,  
𝑞
q, for the  values of tree branching factor 
𝑏
=
{
2
,
3
,
4
}
b={2,3,4} (yellow, orange, red). Here 
𝑞
<
𝑞
𝑐
q<q
c
	​

 and the lower bound corresponds to a branching tree with 
3
3 layers. The upper bound corresponds to a branching tree with an infinite number of  layers.
The probability of broadcast failure (lower and upper bound) plotted as a function of probability that a node is faulty,  
𝑞
q, for the  values of tree branching factor 
𝑏
=
{
2
,
3
,
4
}
b={2,3,4} (yellow, orange, red). Here 
𝑞
>
𝑞
𝑐
q>q
c
	​

 and the lower bound corresponds to a branching tree with 
3
3 layers. The upper bound corresponds to a branching tree with an infinite number of  layers.
Analysis of anonymity failure
The prob. of anonymity failure 
𝐴
𝐿
A
L
	​

 in the tree with 
𝐿
L layers and branching parameter 
𝑏
b can be computed recursively (see the Details of derivations section) via the following set of equations 
𝐴
𝐿
=
1
−
[
1
−
P
𝐿
−
1
]
𝑏
P
ℓ
+
1
=
𝑞
[
1
−
[
1
−
P
ℓ
]
𝑏
]
P
0
=
𝑞
A
L
	​

=1−[1−P
L−1
	​

]
b
P
ℓ+1
	​

=q[1−[1−P
ℓ
	​

]
b
]
P
0
	​

=q
Solving above equations gives the following results
The (critical) probability that a node is “curious”,  
𝑞
𝑐
=
1
/
𝑏
q
c
	​

=1/b, as a function of tree branching factor 
𝑏
b.   For 
𝑞
𝑐
<
𝑞
<
1
q
c
	​

<q<1 the probability  of anonymity failure is bounded away from 
0
0 and 
1
1 for infinite number of layers, i.e. the probability  of anonymity failure is approaching a non-zero value with increasing number of layers in a tree.  For 
𝑞
<
𝑞
𝑐
q<q
c
	​

 the probability  of anonymity failure is exactly 
0
0 for infinite number of layers.
The probability of anonymity failure (lower and upper bound) plotted as a function of probability that a node is “curious”,  
𝑞
q, for the  values of tree branching factor 
𝑏
=
{
2
,
3
,
4
}
b={2,3,4} (red, orange, yellow). Here 
𝑞
<
𝑞
𝑐
=
1
/
𝑏
q<q
c
	​

=1/b and the lower bound, given by 
0
0,  corresponds to a branching tree with an infinite number of layers. The upper bound corresponds to a branching tree with 
3
3 layers.
The probability of anonymity failure (lower and upper bound) plotted as a function of probability that a node is “curious”,  
𝑞
q, for the  values of tree branching factor 
𝑏
=
{
2
,
3
,
4
}
b={2,3,4} (red, orange, yellow). Here 
𝑞
>
𝑞
𝑐
=
1
/
𝑏
q>q
c
	​

=1/b and the lower bound  corresponds to a branching tree with an infinite number of layers. The upper bound corresponds to a branching tree with 
3
3 layers.
Results of simulations 
Above analytic results, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below 
Analysis of failures in branching trees with branching factor 
𝑏
=
2
b=2 . Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the fraction 
𝑞
=
0.3
q=0.3 of faulty nodes.  Right: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the fraction  
𝑞
=
0.3
q=0.3 of “curious” nodes. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
Analysis of failures in branching trees with branching factor 
𝑏
=
2
b=2. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the fraction 
𝑞
=
0.6
q=0.6 of faulty nodes. Right: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the fraction 
𝑞
=
0.6
q=0.6 of “curious” nodes. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
We note that the number of samples 
𝑀
M in above figures is equivalent to the number of messages sent by a sender node. 
Discussion of results for linear and branching tree designs
Discussion of difference between designs
The number of leaf nodes in the branching tree is 
𝑏
𝐿
b
L
 , where 
𝑏
b is the branching parameter and 
𝐿
L is the number of layers, which is also the number of communication paths. To compare the two designs we assume that both of them have the same number of communication paths. The latter implies that the total number of nodes used in linear tree design is 
1
+
𝐿
𝑏
𝐿
1+Lb
L
 (the number of nodes in linear tree design is 
1
+
𝐾
𝐿
1+KL, where 
𝐾
K is the number of paths and 
𝐿
L is the number of nodes in a path without the sender node) and in branching tree design is 
1
+
𝑏
+
𝑏
2
+
⋯
+
𝑏
𝐿
1+b+b
2
+⋯+b
L
. We note that the number of paths grows exponentially with the number of layers 
𝐿
L (and branching parameter 
𝑏
b) as can be seen in the figure below
The consequences of having 
𝑏
𝐿
b
L
 comm. paths in both designs is that the out-degree of a sender node in linear design is 
𝑏
𝐿
b
L
 and in branching design is 
𝑏
b. However, the out-degree is the number of messages sent by a node and hence the number of messages which have to be sent by a sender node grows exponentially in the linear design, but in the branching design it is a constant, i.e. 
𝑏
b. This suggests that the out-degree of a sender node (in linear and branching designs) is constrained by bandwidth of a node.
The ratio 
num. of nodes
/
num. of comm. paths
=
𝐿
num. of nodes/num. of comm. paths=L in the linear design and in the branching design the 
num. of nodes
/
num. of comm. paths
=
(
𝑏
𝐿
+
1
−
1
𝑏
−
1
−
1
)
/
𝑏
𝐿
≤
𝑏
/
(
𝑏
−
1
)
num. of nodes/num. of comm. paths=(
b−1
b
L+1
−1
	​

−1)/b
L
≤b/(b−1), i.e. the ratio is growing linearly with 
𝐿
L in the linear design and it is at most 
𝑏
/
(
𝑏
−
1
)
b/(b−1), i.e. a constant, in the branching design.
Given that the number of communication paths is the same in both designs, the bandwidth consumption "pattern" is very different between these two designs. In linear tree design the root node has to send 
𝑏
𝐿
b
L
 messages to other nodes and other nodes, but leaf nodes, receive a single message and send a single message. In branching tree design the root node sends 
𝑏
b number of messages to other nodes and other nodes, but leaf nodes, receive a single message and send 
𝑏
b messages. For the branching tree design a node might need to send the same number of messages as in the linear tree design as we might not be able to encode messages in a way that it will be able to use topology efficiently. 
For now bandwidth optimisation is not a priority as it depends on possibility of efficient implementation of a communication design which is not investigated at the moment.  Assuming that branching tree design can be implemented efficiently, the root node in the linear case is more "chatty", where the number of messages sent is equal to the number of comm. paths, than in the branching case, where the number of messages sent is equal to the branching parameter and is independent from the number of comm. paths, which would make "anonymity" properties of the sender (root node) in these designs very different which has to be taken in to consideration when making decision on which design to choose. 
Discussion of results for failures 
We assume that the number of comm. paths in both designs is 
𝐾
=
𝑏
𝐿
K=b
L
 and consider communication and anonymity failures. For anonymity failure we will use the same statistical model as for communication failure, with "faulty" replaced by "curious", and the same probability 
𝑞
q that node is faulty or curious. The linear tree design has better communication failure properties than the branching tree design but worse anonymity failure properties as can be seen in two figures below 
We want to find a solution that minimises both failure probabilities. Plotting one prob. against another gives us 
We note that 
𝐿
L in above is increasing from top to bottom. For linear tree design both probabilities are minimal for 
𝐿
=
5
L=5, i.e. maximum number of layers. For branching tree design we can not minimise both probabilities , but the probability of anonymity failure is always less than in the linear tree design for any 
𝐿
L.  Also, we note that linear trees design has better communication failure properties since it consists of 
𝑏
𝐿
b
L
 independent paths. Paths in branching trees design share nodes which increases the ramifications of communication failure at an interior node. On the other hand, linear trees has worse anonymity properties since it consists of more nodes to form the 
𝑏
𝐿
b
L
 paths.
Discussion of failure model
The current approach, where we label a node by a single binary (random) variable, can be used to model only communication failures or anonymity failures but not both.  When both communication and anonymity failures are modelled with a single binary variable then this can be interpreted as a scenario where an adversary controls some number of nodes in a tree. Then it uses these nodes to cause broadcast failure or anonymity failure. Hence here a probability of failure can interpreted as frequency of adversarial opportunities to cause failures. 
We note that in above single-variable approach adversary is cause of both communication and anonymity failures, when both of these failures are considered together. However, in real world scenario communication failures can occur “naturally” and independently from adversarial behaviour. The latter can also cause communication failures, but natural failures can for e.g. interfere with adversary’s ability to cause anonymity failure which is not accounted for in the current single-variable model. 
We note that an adversary can use communication failures to provoke node operators to increase number of communication paths, but the latter could increase chances of anonymity failure. Such adversarial strategy can be used in the linear design for example. 
 In order to separate “natural” communication failures from adversarial, we need to introduce two (random) binary variables which will be associated with a node. One variable to model natural communication failures of nodes and the other variable is an adversarial “label”, i.e. second variable labels a node as "adversarial" or "honest". The adversary will choose on how to use nodes it controls. It can use these nodes to cause communication failure, anonymity failure, etc. From analysis perspective a two-variable model is not much more complex than single-variable model, but will allow us to separate better adversarial failures from non-adversarial.
Communication on Linear Trees: two-variable failure model
Communication on Linear Trees. A message is sent from a node through 
𝐾
K communication paths where each path has 
𝐿
L nodes. A node could be faulty (circle with dashed boundary), or adversarial (red circle). Presence of faulty node leads to communication failures. Presence of adversarial nodes could lead to communication and anonymity failures. 
We assume that a node sends a message through 
𝐾
K communication paths where each path contains exactly 
𝐿
L nodes. We assumed that 
𝐿
×
𝐾
L×K nodes were sampled with replacement from the population of 
𝑁
N nodes.
Analysis of broadcast failure
We assume that 
𝑀
𝐹
M
F
	​

 nodes in the population are “faulty” (faulty node is unable to relay a message).  The probability that a node is faulty is 
𝑞
𝐹
=
𝑀
𝐹
/
𝑁
q
F
	​

=M
F
	​

/N. If a path contains at least one faulty node then communication failure occurred. If all nodes in a communication path are non-faulty then this is a functioning communication path. If all 
𝐾
K paths have communication failure then broadcast failure occurred. The probability of broadcast failure is given by 
P
𝑏
=
[
1
−
(
1
−
𝑞
𝐹
)
𝐿
]
𝐾
.
P
b
	​

=[1−(1−q
F
	​

)
L
]
K
.
We note that 
P
𝑏
P
b
	​

 is (monotonic) decreasing function of 
𝐾
K and (monotonic) increasing function of 
𝐿
L.  Above result is intuitive as increasing number of communications paths (of fixed length) increases chances that at least one of these paths is functional.  Also increasing length of paths (for a fixed number of paths) increases chances that in each path at least one node is faulty.  For 
𝐾
→
∞
K→∞, with 
𝐿
L fixed, the prob. 
P
𝑏
→
0
P
b
	​

→0 and for 
𝐿
→
∞
L→∞, with 
𝐾
K fixed, the prob. 
P
𝑏
→
1
P
b
	​

→1.
We note that anonymity properties are improved for larger 
𝐿
L (see 
Analysis of anonymity failure) and we would like to find a relation between 
𝐾
K and 
𝐿
L such that we have both good communication and anonymity properties. Let us assume that 
𝐾
=
𝑓
(
𝐿
)
K=f(L), where 
𝑓
(
𝐿
)
∈
𝑁
f(L)∈N, and consider the prob. 
P
𝑏
P
b
	​

. For the latter we have the following inequality 
P
𝑏
=
[
1
−
(
1
−
𝑞
𝐹
)
𝐿
]
𝐾
=
e
𝑓
(
𝐿
)
log
⁡
(
1
−
(
1
−
𝑞
𝐹
)
𝐿
)
                                              
≤
e
−
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
,
P
b
	​

=[1−(1−q
F
	​

)
L
]
K
=e
f(L)log(1−(1−q
F
	​

)
L
)
                                              ≤e
−f(L)(1−q
F
	​

)
L
,
 where in above we used 
log
⁡
(
𝑥
)
≤
𝑥
−
1
log(x)≤x−1 to obtain inequality.  Hence for 
𝐾
=
𝑓
(
𝐿
)
K=f(L) we can have 
P
𝑏
→
0
P
b
	​

→0 when 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
→
∞
f(L)(1−q
F
	​

)
L
→∞ as 
𝐿
→
∞
L→∞.
We note that 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
=
e
𝐿
[
log
⁡
(
1
−
𝑞
𝐹
)
+
1
𝐿
log
⁡
𝑓
(
𝐿
)
]
f(L)(1−q
F
	​

)
L
=e
L[log(1−q
F
	​

)+
L
1
	​

logf(L)]
 and hence for any 
𝜖
>
0
ϵ>0 the following condition 
1
𝐿
log
⁡
𝑓
(
𝐿
)
=
−
log
⁡
(
1
−
𝑞
𝐹
)
+
𝜖
L
1
	​

logf(L)=−log(1−q
F
	​

)+ϵ
 ensures that 
P
𝑏
→
0
P
b
	​

→0 when 
𝐿
→
∞
L→∞. Above suggests 
𝑓
(
𝐿
)
=
e
𝐿
[
−
log
⁡
(
1
−
𝑞
𝐹
)
+
𝜖
]
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
,
f(L)=e
L[−log(1−q
F
	​

)+ϵ]
=(
1−q
F
	​

α
	​

)
L
,
where 
𝛼
=
e
𝜖
α=e
ϵ
, i.e. the number of paths has to grow exponentially with 
𝐿
L to ensure that 
P
𝑏
→
0
P
b
	​

→0 when 
𝐿
→
∞
L→∞.
Analysis of anonymity failure
We assume that 
𝑀
𝐴
M
A
	​

 nodes in the population are “adversarial”;  adversarial nodes are controlled by an adversary which can make nodes faulty, use them for traffic analysis, etc. The probability that a node is adversarial is 
𝑞
𝐴
=
𝑀
𝐴
/
𝑁
q
A
	​

=M
A
	​

/N. If there is at least one functioning communication paths where all nodes are adversarial, then adversary has opportunity to cause anonymity failure. The probability of anonymity failure is given by 
P
𝑎
=
1
−
[
1
−
[
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
]
𝐿
]
𝐾
.
P
a
	​

=1−[1−[(1−q
F
	​

)q
A
	​

]
L
]
K
.
We note that 
P
𝑎
P
a
	​

 is (monotonic) increasing function of 
𝐾
K and (monotonic) decreasing function of 
𝐿
L.  Also 
P
𝑎
P
a
	​

 is monotonic increasing function of 
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
(1−q
F
	​

)q
A
	​

 and hence monotonic decreasing function of 
𝑞
𝐹
q
F
	​

. For 
𝐾
→
∞
K→∞, with 
𝐿
L fixed, the prob. 
P
𝑎
→
1
P
a
	​

→1 and for 
𝐿
→
∞
L→∞, with 
𝐾
K fixed, the prob. 
P
𝑎
→
0
P
a
	​

→0. 
Let us assume that 
𝐾
=
𝑓
(
𝐿
)
K=f(L), where 
𝑓
(
𝐿
)
∈
𝑁
f(L)∈N, and consider the prob. 
P
𝑎
P
a
	​

. For the latter we have the following inequality 
P
𝑎
=
1
−
[
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
]
𝐾
=
1
−
e
𝑓
(
𝐿
)
log
⁡
(
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
)
                                                            
≤
1
−
e
−
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
P
a
	​

=1−[1−(1−q
F
	​

)
L
q
A
L
	​

]
K
=1−e
f(L)log(1−(1−q
F
	​

)
L
q
A
L
	​

)
                                                            ≤1−e
−f(L)
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

Hence for 
𝐾
=
𝑓
(
𝐿
)
K=f(L) we can have 
P
𝑎
→
0
P
a
	​

→0 when 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
→
0
f(L)
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

→0 as 
𝐿
→
∞
L→∞. We note that 
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
=
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
+
𝑂
(
(
1
−
𝑞
𝐹
)
2
𝐿
 
𝑞
𝐴
2
𝐿
)
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

=(1−q
F
	​

)
L
q
A
L
	​

+O((1−q
F
	​

)
2L
q
A
2L
	​

) when 
𝐿
→
∞
L→∞ and hence 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
f(L)(1−q
F
	​

)
L
q
A
L
	​

 is the dominant term in 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
→
0
f(L)
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

→0.  Thus 
P
𝑎
→
0
P
a
	​

→0 when 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
→
0
f(L)(1−q
F
	​

)
L
q
A
L
	​

→0 as 
𝐿
→
∞
L→∞. 
Let us assume 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 and consider 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
                  
=
(
𝛼
𝑞
𝐴
)
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
f(L)
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

=(
1−q
F
	​

α
	​

)
L
1−(1−q
F
	​

)
L
q
A
L
	​

(1−q
F
	​

)
L
q
A
L
	​

	​

                  =
1−(1−q
F
	​

)
L
q
A
L
	​

(αq
A
	​

)
L
	​

From above follows that 
P
𝑎
→
0
P
a
	​

→0 as 
𝐿
→
∞
L→∞ when 
𝛼
 
𝑞
𝐴
<
1
αq
A
	​

<1.  Hence, if 
𝛼
α is such that 
1
<
𝛼
<
1
/
𝑞
𝐴
1<α<1/q
A
	​

 then the number of comm. paths 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 ensures that 
P
𝑏
→
0
P
b
	​

→0 and 
P
𝑎
→
0
P
a
	​

→0 as 
𝐿
→
∞
L→∞. 
Analysis of adversarial broadcast-failure
If there is at least one adversarial node in each functioning communication paths then adversary has opportunity to cause broadcast failure. The probability of adversarial broadcast failure is given by 
P
𝑎
𝑏
=
[
1
−
[
(
1
−
𝑞
𝐹
)
(
1
−
𝑞
𝐴
)
]
𝐿
]
𝐾
−
[
1
−
(
1
−
𝑞
𝐹
)
𝐿
]
𝐾
.
P
ab
	​

=[1−[(1−q
F
	​

)(1−q
A
	​

)]
L
]
K
−[1−(1−q
F
	​

)
L
]
K
.
We note that 
P
𝑎
𝑏
≤
[
1
−
[
(
1
−
𝑞
𝐹
)
(
1
−
𝑞
𝐴
)
]
𝐿
]
𝐾
P
ab
	​

≤[1−[(1−q
F
	​

)(1−q
A
	​

)]
L
]
K
 and hence 
P
𝑎
𝑏
P
ab
	​

 is bounded from above by (monotonic) decreasing function of 
𝐾
K and (monotonic) increasing function of 
𝐿
L. For 
𝐾
→
∞
K→∞, with 
𝐿
L fixed, the prob. 
P
𝑎
𝑏
→
0
P
ab
	​

→0 and for 
𝐿
→
∞
L→∞, with 
𝐾
K fixed, the prob. 
P
𝑎
𝑏
→
1
P
ab
	​

→1. 
Let us assume 
𝐾
=
𝑓
(
𝐿
)
K=f(L) and consider 
P
𝑎
𝑏
≤
[
1
−
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
]
𝑓
(
𝐿
)
        
=
e
𝑓
(
𝐿
)
log
⁡
(
1
−
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
)
                              
≤
e
−
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
P
ab
	​

≤[1−[(1−q
A
	​

)(1−q
F
	​

)]
L
]
f(L)
        =e
f(L)log(1−[(1−q
A
	​

)(1−q
F
	​

)]
L
)
                              ≤e
−f(L)[(1−q
A
	​

)(1−q
F
	​

)]
L
Hence 
P
𝑎
𝑏
→
0
P
ab
	​

→0 when 
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
→
∞
f(L)[(1−q
A
	​

)(1−q
F
	​

)]
L
→∞ as 
𝐿
→
∞
L→∞. Furthermore, we can obtain the lower bound on 
P
𝑎
𝑏
P
ab
	​

 as follows 
   
P
𝑎
𝑏
=
[
1
−
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
]
𝑓
(
𝐿
)
−
[
1
−
(
1
−
𝑞
𝐹
)
𝐿
]
𝐾
=
e
𝑓
(
𝐿
)
log
⁡
(
1
−
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
)
−
e
𝑓
(
𝐿
)
log
⁡
(
1
−
(
1
−
𝑞
𝐹
)
𝐿
)
≥
e
−
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
1
−
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
−
e
−
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
                                           
=
e
−
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
𝐿
(
1
−
𝑞
𝐹
)
𝐿
+
𝑂
(
(
1
−
𝑞
𝐴
)
2
𝐿
(
1
−
𝑞
𝐹
)
2
𝐿
)
]
−
e
−
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
   P
ab
	​

=[1−[(1−q
A
	​

)(1−q
F
	​

)]
L
]
f(L)
−[1−(1−q
F
	​

)
L
]
K
=e
f(L)log(1−[(1−q
A
	​

)(1−q
F
	​

)]
L
)
−e
f(L)log(1−(1−q
F
	​

)
L
)
≥e
−f(L)
1−[(1−q
A
	​

)(1−q
F
	​

)]
L
[(1−q
A
	​

)(1−q
F
	​

)]
L
	​

−e
−f(L)(1−q
F
	​

)
L
                                           =e
−f(L)[(1−q
A
	​

)
L
(1−q
F
	​

)
L
+O((1−q
A
	​

)
2L
(1−q
F
	​

)
2L
)]
−e
−f(L)(1−q
F
	​

)
L
We note that 
(
1
−
𝑞
𝐴
)
𝐿
(
1
−
𝑞
𝐹
)
𝐿
≤
(
1
−
𝑞
𝐹
)
𝐿
(1−q
A
	​

)
L
(1−q
F
	​

)
L
≤(1−q
F
	​

)
L
 and hence for 
𝑓
(
𝐿
)
f(L) such that 
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
→
0
f(L)[(1−q
A
	​

)(1−q
F
	​

)]
L
→0, as 
𝐿
→
∞
L→∞, but 
𝑓
(
𝐿
)
(
1
−
𝑞
𝐹
)
𝐿
→
∞
f(L)(1−q
F
	​

)
L
→∞ we have 
P
𝑎
𝑏
→
1
P
ab
	​

→1. 
For 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 we have 
𝑓
(
𝐿
)
[
(
1
−
𝑞
𝐴
)
(
1
−
𝑞
𝐹
)
]
𝐿
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
(
1
−
𝑞
𝐴
)
𝐿
(
1
−
𝑞
𝐹
)
𝐿
          
=
𝛼
𝐿
(
1
−
𝑞
𝐴
)
𝐿
f(L)[(1−q
A
	​

)(1−q
F
	​

)]
L
=(
1−q
F
	​

α
	​

)
L
(1−q
A
	​

)
L
(1−q
F
	​

)
L
          =α
L
(1−q
A
	​

)
L
From above, it follows that if 
𝛼
 
(
1
−
𝑞
𝐴
)
>
1
α(1−q
A
	​

)>1, which is equivalent to 
𝛼
>
1
/
(
1
−
𝑞
𝐴
)
α>1/(1−q
A
	​

), then 
P
𝑎
𝑏
→
0
P
ab
	​

→0 when 
𝐿
→
∞
L→∞.  Thus to have 
P
𝑏
→
0
P
b
	​

→0, 
P
𝑎
→
0
P
a
	​

→0, and 
P
𝑎
𝑏
→
0
P
ab
	​

→0 as 
𝐿
→
∞
L→∞ we have to choose 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 for the number of paths 
𝐾
K with 
1
1
−
𝑞
𝐴
<
𝛼
<
1
𝑞
𝐴
1−q
A
	​

1
	​

<α<
q
A
	​

1
	​

The lower bound 
1
1
−
𝑞
𝐴
1−q
A
	​

1
	​

 and upper bound 
1
𝑞
𝐴
q
A
	​

1
	​

 on parameter 
𝛼
α plotted as a function of 
𝑞
𝐴
q
A
	​

.
Analysis of failures
Using the expression 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
, where 
𝐿
L is the number of nodes in a path and 
𝛼
α parameter such that 
𝑓
(
𝐿
)
∈
𝑁
f(L)∈N, for the number of paths in the upper bounds on failure probabilities 
P
𝑏
P
b
	​

, 
P
𝑎
P
a
	​

, and 
P
𝑎
𝑏
P
ab
	​

 we obtain the following inequalities 
P
𝑏
≤
e
−
𝛼
𝐿
            
P
𝑎
𝑏
≤
e
−
𝛼
𝐿
(
1
−
𝑞
𝐴
)
𝐿
                      
P
𝑎
≤
1
−
e
−
𝛼
𝐿
𝑞
𝐴
𝐿
1
−
(
1
−
𝑞
𝐹
)
𝐿
 
𝑞
𝐴
𝐿
.
P
b
	​

≤e
−α
L
            P
ab
	​

≤e
−α
L
(1−q
A
	​

)
L
                      P
a
	​

≤1−e
−α
L
1−(1−q
F
	​

)
L
q
A
L
	​

q
A
L
	​

	​

.
 and for any 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

) all of the above are vanishing as 
𝐿
→
∞
L→∞.  From above follows that broadcast failure probabilities 
P
𝑏
P
b
	​

 and 
P
𝑎
𝑏
P
ab
	​

 are tending to 
0
0 with increasing 
𝐿
L at a much higher rate for a larger values of 
𝛼
α, but the anonymity failure prob. 
P
𝑎
P
a
	​

 is tending to 
0
0 at a much higher rate for a smaller values of 
𝛼
α. 
We note that the number of comm. paths 
𝑓
(
𝐿
)
f(L) and the number of nodes involved in communication 
𝐿
×
𝑓
(
𝐿
)
L×f(L), which is bounded by the number of nodes in the network 
𝑁
N, is growing slowly (with 
𝐿
L) when 
𝛼
α is small and very fast when 
𝛼
α is large when we increase the number of nodes per path 
𝐿
L. For values of 
𝛼
α close to 
1
1
−
𝑞
𝐴
1−q
A
	​

1
	​

 probabilities of broadcast failures are tending to 
0
0 with increasing 
𝐿
L at a much lower rate than the prob. of anonymity failure as can be seen in the figures below
Probability of comm. failure as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. The number of communication paths is given by 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
, where 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). Here 
𝛼
=
1.2
>
1
/
(
1
−
𝑞
𝐴
)
=
1.111111
α=1.2>1/(1−q
A
	​

)=1.111111. 
Probability of anonymity failure as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. The number of communication paths is given by 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
, where 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). Here 
𝛼
=
1.2
>
1
/
(
1
−
𝑞
𝐴
)
=
1.111111
α=1.2>1/(1−q
A
	​

)=1.111111. 
The number of communication paths 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝛼
=
1.2
α=1.2. 
The number of nodes in communication paths 
𝐿
×
𝑓
(
𝐿
)
L×f(L) as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝛼
=
1.2
α=1.2. 
For 
𝛼
α values closer to 
1
/
𝑞
𝐴
1/q
A
	​

 probabilities of broadcast failures are tending to 
0
0 with increasing 
𝐿
L at a much higher rate than the prob. of anonymity failure as can be seen in the figures below 
Probability of comm. failure as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. The number of communication paths is given by 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
, where 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). Here 
𝛼
=
2
<
1
/
𝑞
𝐴
=
10
α=2<1/q
A
	​

=10. 
Probability of anonymity failure as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. The number of communication paths is given by 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
, where 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). Here 
𝛼
=
2
<
1
/
𝑞
𝐴
=
10
α=2<1/q
A
	​

=10. 
The number of communication paths 
𝑓
(
𝐿
)
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
f(L)=(
1−q
F
	​

α
	​

)
L
 as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝛼
=
2
α=2.
The number of nodes in communication paths 
𝐿
×
𝑓
(
𝐿
)
L×f(L) as a function of 
𝐿
L plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and 
𝛼
=
2
α=2.
For 
𝛼
α outside of the interval 
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

) we have that either the broadcast failure probabilities are increasing and anonymity failure prob. is decreasing with increasing 
𝐿
L when 
𝛼
<
1
1
−
𝑞
𝐴
α<
1−q
A
	​

1
	​

 or the broadcast failure probabilities are decreasing and anonymity failure prob. is increasing with increasing 
𝐿
L when 
𝛼
>
1
𝑞
𝐴
α>
q
A
	​

1
	​

. 
We note that 
P
𝑏
≤
e
−
𝛼
𝐿
P
b
	​

≤e
−α
L
, 
P
𝑎
𝑏
≤
e
−
𝛼
𝐿
(
1
−
𝑞
𝐴
)
𝐿
P
ab
	​

≤e
−α
L
(1−q
A
	​

)
L
§11, and 
e
−
𝛼
𝐿
≤
e
−
𝛼
𝐿
(
1
−
𝑞
𝐴
)
𝐿
e
−α
L
≤e
−α
L
(1−q
A
	​

)
L
. The latter implies that for finite 
𝐿
L the broadcast failure probabilities are reduced when we increase 
𝛼
α, i.e. when the number of communication paths is increased. However, for finite 
𝐿
L the probability of anonymity failure 
P
𝑎
P
a
	​

 is reduced when we decrease 
𝛼
α, i.e. when the number of communication paths is decreased. This behaviour of failure probabilities for finite 
𝐿
L can be seen in the plots below. 
Probability of comm. failure as a function of the number of communication paths 
𝐾
K plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2, 
𝑞
𝐴
=
0.1
q
A
	​

=0.1 and 
𝐿
=
2
L=2. Here 
𝐾
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
K=(
1−q
F
	​

α
	​

)
L
 is for 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). 
Probability of anonymity failure as a function of the number of communication paths 
𝐾
K plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2, 
𝑞
𝐴
=
0.1
q
A
	​

=0.1 and 
𝐿
=
2
L=2. Here 
𝐾
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
K=(
1−q
F
	​

α
	​

)
L
 is for 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). 
The number of nodes involved in communication 
𝐿
×
𝐾
L×K as a function of the number of comm. paths 
𝐾
K plotted for 
𝐿
=
2
L=2. 
Probability of comm. failure as a function of the number of communication paths 
𝐾
K plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2, 
𝑞
𝐴
=
0.1
q
A
	​

=0.1 and 
𝐿
=
3
L=3. Here 
𝐾
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
K=(
1−q
F
	​

α
	​

)
L
 is for 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). 
Probability of anonymity failure as a function of the number of communication paths 
𝐾
K plotted for 
𝑞
𝐹
=
0.2
q
F
	​

=0.2, 
𝑞
𝐴
=
0.1
q
A
	​

=0.1 and 
𝐿
=
3
L=3. Here 
𝐾
=
(
𝛼
1
−
𝑞
𝐹
)
𝐿
K=(
1−q
F
	​

α
	​

)
L
 is for 
𝛼
∈
(
1
1
−
𝑞
𝐴
,
1
𝑞
𝐴
)
α∈(
1−q
A
	​

1
	​

,
q
A
	​

1
	​

). 
The number of nodes involved in communication 
𝐿
×
𝐾
L×K as a function of the number of comm. paths 
𝐾
K plotted for 
𝐿
=
3
L=3. 
Simulation results 
Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below 
Analysis of failures in 
2
𝐿
2
L
 linear trees with 
𝐿
L layers. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐹
=
0.3
q
F
	​

=0.3 of faulty nodes.  Center: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐴
=
0.1
q
A
	​

=0.1 of adversarial  nodes and 
𝑞
𝐹
=
0.3
q
F
	​

=0.3. Right: The probability of adversarial broadcast failure plotted as a function of the number of layers 
𝐿
L for 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
Analysis of failures in 
2
𝐿
2
L
 linear trees with 
𝐿
L layers. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐹
=
0.3
q
F
	​

=0.3 of faulty nodes.  Center: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐴
=
0.4
q
A
	​

=0.4 of adversarial  nodes and 
𝑞
𝐹
=
0.3
q
F
	​

=0.3. Right: The probability of adversarial broadcast failure plotted as a function of the number of layers 
𝐿
L for 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.4
q
A
	​

=0.4. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
We note that the number of samples 
𝑀
M in above figures is equivalent to the number of messages sent by a sender node. 
Communication on Branching Trees: two-variable failure model
Assumptions
Communication on a (balanced and complete) tree 
𝑇
𝐿
T
L
	​

. The layers in  the tree are labeled by the set 
{
0
,
1
,
…
,
𝐿
}
{0,1,…,L} (bottom to top).  A message is sent from the root node (layer 
𝐿
L)  to the leaf nodes (layer 
0
0). All leaf nodes of the tree 
𝑇
𝐿
T
L
	​

 constitute its boundary 
∂
𝑇
𝐿
∂T
L
	​

. Each node in the tree, but the root, has associated with it binary random variable. A node could be faulty (circle with dashed boundary), or adversarial (red circle). Presence of faulty node leads to communication failures.  Presence of adversarial nodes could lead to communication and anonymity failures.
We consider broadcast on a tree 
𝑇
𝐿
T
L
	​

 (see figure above) constructed from nodes sampled (with replacement) from the 
𝑁
N nodes of the network. We assume that 
𝑀
𝐹
M
F
	​

 nodes in the network are “faulty” (faulty node is unable to relay a message) and the probability that a sampled node is faulty is 
𝑞
𝐹
=
𝑀
𝐹
/
𝑁
q
F
	​

=M
F
	​

/N. We assume that 
𝑀
𝐴
M
A
	​

 nodes in the network are “adversarial” (Adversarial nodes are controlled by an adversary which can make nodes faulty, use them for traffic analysis, etc.) and the probability that a sampled node is adversarial is 
𝑞
𝐴
=
𝑀
𝐴
/
𝑁
q
A
	​

=M
A
	​

/N.
We assume that the root node of 
𝑇
𝐿
T
L
	​

 sends a message to all leaf nodes. The root node is labeled by 
0
0 and all leaf nodes constitute the set 
∂
𝑇
𝐿
∂T
L
	​

. We assume that each node can fail to relay the message with probability 
𝑞
𝐹
q
F
	​

 independently from other nodes. We assume that a node can be adversarial with probability 
𝑞
𝐴
q
A
	​

 independently from other nodes.
Let us define the binary variable 
𝜎
𝑖
∈
{
0
,
1
}
σ
i
	​

∈{0,1} for a node 
𝑖
i in some communication path. A node is faulty/not-faulty when 
𝜎
𝑖
=
0
/
1
σ
i
	​

=0/1 with probability 
𝑞
𝐹
/
(
1
−
𝑞
𝐹
)
q
F
	​

/(1−q
F
	​

). If the sum of all 
𝜎
𝑖
σ
i
	​

 variables of nodes on the path from the root 
0
0 to some leaf node 
𝑗
j, 
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
∑
k∈0→j∖0
	​

σ
k
	​

, is less than 
𝐿
L, i.e. then there is at least one faulty node in this path. Hence, node 
𝑗
j did not receive the message, i.e. communication failure occurred. If all nodes in a communication path are non-faulty then this is a functioning communication path. If 
max
⁡
𝑗
∈
∂
𝑇
𝐿
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
<
𝐿
max
j∈∂T
L
	​

	​

∑
k∈0→j∖0
	​

σ
k
	​

<L, i.e. each comm. path contains at least one faulty node, then all leaf nodes didn't receive the message, i.e. broadcast failure occurred.
Also we define the binary variable 
𝑠
𝑖
∈
{
0
,
1
}
s
i
	​

∈{0,1}. A node is “honest/adversarial” when 
𝑠
𝑖
=
0
/
1
s
i
	​

=0/1 with probability 
(
1
−
𝑞
𝐴
)
/
𝑞
𝐴
(1−q
A
	​

)/q
A
	​

. If 
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
 
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝑠
𝑘
≥
1
]
=
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
∑
j∈∂T
L
	​

	​

1[∑
k∈0→j∖0
	​

σ
k
	​

=L]1[∑
k∈0→j∖0
	​

s
k
	​

≥1]=∑
j∈∂T
L
	​

	​

1[∑
k∈0→j∖0
	​

σ
k
	​

=L] and 
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
≥
1
∑
j∈∂T
L
	​

	​

1[∑
k∈0→j∖0
	​

σ
k
	​

=L]≥1, i.e. all functioning communication paths have at least one adversarial node, then adversary has opportunity to cause broadcast failure. If 
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
 
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝑠
𝑘
=
𝐿
]
≥
1
∑
j∈∂T
L
	​

	​

1[∑
k∈0→j∖0
	​

σ
k
	​

=L]1[∑
k∈0→j∖0
	​

s
k
	​

=L]≥1, i.e. there is at least one functioning communication paths where all nodes are adversarial, then adversary has opportunity to cause anonymity failure. We note that above definition of anonymity failure is equivalent to the event 
max
⁡
𝑗
∈
∂
𝑇
𝐿
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
𝑠
𝑘
=
𝐿
max
j∈∂T
L
	​

	​

∑
k∈0→j∖0
	​

σ
k
	​

s
k
	​

=L. Here the 
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
𝑠
𝑘
∑
k∈0→j∖0
	​

σ
k
	​

s
k
	​

 counts number of adversarial nodes on the path 
0
→
𝑗
0→j.
Analysis of broadcast failure
The probability of broadcast failure is give by 
P
𝑏
=
[
1
−
P
𝐿
−
1
]
𝑏
P
b
	​

=[1−P
L−1
	​

]
b
, where the prob. 
P
𝐿
−
1
P
L−1
	​

 can be computed recursively (see the Details of derivations section) as follows 
                          
P
ℓ
+
1
=
(
1
−
𝑞
𝐹
)
[
1
−
[
1
−
P
ℓ
]
𝑏
]
P
0
=
1
−
𝑞
𝐹
                          P
ℓ+1
	​

=(1−q
F
	​

)[1−[1−P
ℓ
	​

]
b
]
P
0
	​

=1−q
F
	​

The above equation has only one solution 
P
ℓ
=
0
P
ℓ
	​

=0, which corresponds to prob. of broadcast failure being 
1
1, when 
1
−
𝑞
𝐹
<
1
/
𝑏
1−q
F
	​

<1/b. However, the fixed point 
P
ℓ
=
0
P
ℓ
	​

=0 becomes unstable when 
1
−
𝑞
𝐹
>
1
/
𝑏
1−q
F
	​

>1/b and a second (stable) solution 
P
ℓ
>
0
P
ℓ
	​

>0, which corresponds to prob. of broadcast failure being less than 
1
1, emerges.
Analysis of anonymity failure
The probability of anonymity failure is give by 
P
𝑎
=
1
−
[
1
−
P
𝐿
−
1
]
𝑏
P
a
	​

=1−[1−P
L−1
	​

]
b
, where 
P
𝐿
−
1
P
L−1
	​

 can be computed recursively (see the Details of derivations section) as follows 
                       
P
ℓ
+
1
=
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
[
1
−
[
1
−
P
ℓ
]
𝑏
]
P
0
=
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
                       P
ℓ+1
	​

=(1−q
F
	​

)q
A
	​

[1−[1−P
ℓ
	​

]
b
]
P
0
	​

=(1−q
F
	​

)q
A
	​

The above equation has only one solution 
P
ℓ
=
0
P
ℓ
	​

=0, which corresponds to prob. of anonymity failure being 
0
0, when 
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
<
1
/
𝑏
(1−q
F
	​

)q
A
	​

<1/b. However, the fixed point 
P
ℓ
=
0
P
ℓ
	​

=0 becomes unstable when 
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
>
1
/
𝑏
(1−q
F
	​

)q
A
	​

>1/b and a second (stable) solution 
P
ℓ
>
0
P
ℓ
	​

>0, which corresponds to prob. of anonymity failure being greater than 
0
0, emerges.
From above follows that we would like to have 
1
−
𝑞
𝐹
>
1
/
𝑏
1−q
F
	​

>1/b and 
(
1
−
𝑞
𝐹
)
 
𝑞
𝐴
<
1
/
𝑏
(1−q
F
	​

)q
A
	​

<1/b as it allows us to make failure prob. arbitrarily small by increasing the number of layers 
𝐿
L . The latter gives us conditions for this in the inequalities 
𝑞
𝐹
<
1
−
1
𝑏
=
𝑞
𝐹
(
𝑏
)
q
F
	​

<1−
b
1
	​

=q
F
	​

(b) and 
𝑞
𝐴
<
1
𝑏
(
1
−
𝑞
𝐹
)
=
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

<
b(1−q
F
	​

)
1
	​

=q
A
	​

(b,q
F
	​

). The threshold 
𝑞
𝐹
(
𝑏
)
q
F
	​

(b) is increasing with the branching ratio 
𝑏
b, i.e. 
P
𝑏
→
0
P
b
	​

→0 when 
𝐿
→
∞
L→∞ for higher values of 
𝑞
𝐹
q
F
	​

, but the threshold 
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

(b,q
F
	​

) is decreasing with 
𝑏
b, i.e. 
P
𝑎
→
0
P
a
	​

→0 when 
𝐿
→
∞
L→∞ for lower values of 
𝑞
𝐹
q
F
	​

. Also 
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

(b,q
F
	​

) is increasing function of 
𝑞
𝐹
q
F
	​

. 
Analysis of adversarial broadcast-failure
We have exploited a recursive property of 
max
⁡
max on trees (see equation (48) in the Details of derivations) to derive expressions for the prob. of broadcast and anonymity failures, however if such recursive approach is possible in analysis of adversarial broadcast-failure is not clear. In particular we don’t know how to estimate probability of the event 
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
 
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝑠
𝑘
≥
1
]
=
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
 and
∑
𝑗
∈
∂
𝑇
𝐿
1
[
∑
𝑘
∈
0
→
𝑗
∖
0
𝜎
𝑘
=
𝐿
]
≥
1
j∈∂T
L
	​

∑
	​

1
	​

k∈0→j∖0
∑
	​

σ
k
	​

=L
	​

1
	​

k∈0→j∖0
∑
	​

s
k
	​

≥1
	​

=
j∈∂T
L
	​

∑
	​

1
	​

k∈0→j∖0
∑
	​

σ
k
	​

=L
	​

 and
j∈∂T
L
	​

∑
	​

1
	​

k∈0→j∖0
∑
	​

σ
k
	​

=L
	​

≥1
 analytically. However for 
𝑞
𝐹
=
0
q
F
	​

=0, i.e. there are no faulty nodes, we know from our earlier analysis that the probability of adversarial broadcast failure 
P
𝑎
𝑏
P
ab
	​

 is strictly less than 
1
1 as 
𝐿
→
∞
L→∞ when 
𝑞
𝐴
<
1
−
1
𝑏
q
A
	​

<1−
b
1
	​

. 
Simulation results 
Above analytic expressions, derived for infinite number of random samples, for failure probabilities are in good agreement with probabilities computed from a finite number of samples obtained in simulations as can be seen in figures below 
Analysis  of failures in branching trees with branching factor 
𝑏
=
2
b=2. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐹
=
0.3
q
F
	​

=0.3 of faulty nodes.  Center: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the (average) fraction 
𝑞
𝐴
=
0.1
q
A
	​

=0.1 of adversarial  nodes and 
𝑞
𝐹
=
0.3
q
F
	​

=0.3. Right: The probability of adversarial broadcast failure plotted as a function of the number of layers 
𝐿
L for 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
Analysis of failures in branching trees with branching factor 
𝑏
=
2
b=2. Left: The probability of broadcast failure plotted as a function of number of layers 
𝐿
L for the (average) fraction  
𝑞
𝐹
=
0.3
q
F
	​

=0.3 of faulty nodes. Center: The probability of anonymity failure plotted as a function of the number of layers 
𝐿
L for the (average) fraction 
𝑞
𝐴
=
0.4
q
A
	​

=0.4 of adversarial  nodes and 
𝑞
𝐹
=
0.3
q
F
	​

=0.3. Right: The probability of adversarial broadcast failure plotted as a function of the number of layers 
𝐿
L for 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.4
q
A
	​

=0.4. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples.
Discussion of results for linear and branching tree designs: two-variable failure model
To compare linear and branching tree designs we assume that both have the same number of paths 
𝑏
𝐿
b
L
, where 
𝑏
b is branching parameter and 
𝐿
L is the number of layers (see diagram of linear trees and diagram of branching tree). The differences between designs when above assumption is used were discussed above. 
First, we consider the prob. of broadcast failure for values of 
𝑞
𝐹
q
F
	​

 below and above the threshold 
𝑞
𝐹
(
𝑏
)
q
F
	​

(b) plotted in the figure below. 
The threshold 
𝑞
𝐹
(
𝑏
)
=
1
−
1
/
𝑏
q
F
	​

(b)=1−1/b plotted as a function of branching ratio 
𝑏
b. For 
𝑞
𝐹
<
𝑞
𝐹
(
𝑏
)
q
F
	​

<q
F
	​

(b) the prob. of broadcast failure 
P
𝑏
P
b
	​

 in branching trees is strictly less than 
1
1 even for infinite number of layers 
𝐿
L. For 
𝑞
𝐹
>
𝑞
𝐹
(
𝑏
)
q
F
	​

>q
F
	​

(b) the prob. of broadcast failure 
P
𝑏
P
b
	​

 in branching trees is tending to 
1
1 with increasing number of layers 
𝐿
L.
For the branching parameter 
𝑏
=
2
b=2 the prob. of broadcast failure, 
P
𝑏
P
b
	​

, in linear trees is smaller than in the branching trees as can be seen in the figure below. We note that in linear trees the prob. 
P
𝑏
→
0
P
b
	​

→0 as 
𝐿
→
∞
L→∞ when 
𝑞
𝐹
<
1
/
2
q
F
	​

<1/2 and 
P
𝑏
→
1
P
b
	​

→1 when 
𝑞
𝐹
>
1
/
2
q
F
	​

>1/2. The threshold 
1
/
2
1/2 follows from the condition 
𝑏
(
1
−
𝑞
𝐹
)
>
1
b(1−q
F
	​

)>1, which ensures 
P
𝑏
→
0
P
b
	​

→0, in the linear trees analysis. 
The prob. of broadcast failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of faulty nodes 
𝑞
𝐹
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
F
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top) and branching parameter 
𝑏
=
2
b=2. Solid lines correspond to 
𝑞
𝐹
=
𝑞
𝐹
(
2
)
=
1
/
2
q
F
	​

=q
F
	​

(2)=1/2. 
However, the number of nodes involved in communication grows much faster in linear trees as can be seen in the figure below. 
The number of nodes involved in communication as function of number of layers 
𝐿
L plotted for the branching parameter 
𝑏
=
2
b=2. 
As we increase the branching parameter 
𝑏
b the probability of broadcast failure is reduced for each number of layers 
𝐿
L as can be seen in the figure below 
The prob. of broadcast failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of faulty nodes 
𝑞
𝐹
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
F
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top) and branching parameter 
𝑏
=
3
b=3. Solid lines correspond to 
𝑞
𝐹
=
𝑞
𝐹
(
3
)
=
2
/
3
q
F
	​

=q
F
	​

(3)=2/3. 
However, the number of nodes involved in communication is growing much faster with the number of layers 
𝐿
L for higher values of the branching parameter 
𝑏
b (cf. figure below and figure above) 
The number of nodes involved in communication as function of number of layers 
𝐿
L plotted for the branching ratio 
𝑏
=
3
b=3. 
Second, we consider the prob. of anonymity failure for values of 
𝑞
𝐴
q
A
	​

 below and above the threshold 
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

(b,q
F
	​

) plotted in the figure below.
The threshold 
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
=
1
𝑏
(
1
−
𝑞
𝐹
)
q
A
	​

(b,q
F
	​

)=
b(1−q
F
	​

)
1
	​

 as a function of branching parameter 
𝑏
b. For 
𝑞
𝐴
<
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

<q
A
	​

(b,q
F
	​

) the prob. of anonymity failure 
P
𝑎
→
0
P
a
	​

→0 in branching trees as the number of layers 
𝐿
→
∞
L→∞. For 
𝑞
𝐴
>
𝑞
𝐴
(
𝑏
,
𝑞
𝐹
)
q
A
	​

>q
A
	​

(b,q
F
	​

) the prob. of anonymity failure in branching trees is tending to some value 
P
𝑎
<
1
P
a
	​

<1 as the number of layers 
𝐿
→
∞
L→∞.
For the branching parameter 
𝑏
=
2
b=2 the prob. of anonymity failure, 
P
𝑎
P
a
	​

, in linear trees is higher than in the branching trees as can be seen in the figure below. We note that in linear trees the prob. 
P
𝑎
→
0
P
a
	​

→0 as 
𝐿
→
∞
L→∞ when 
𝑞
𝐴
<
1
/
1.8
q
A
	​

<1/1.8 and 
P
𝑎
→
1
P
a
	​

→1 when 
𝑞
𝐴
>
1
/
1.8
q
A
	​

>1/1.8. The threshold 
1
/
1.8
1/1.8 follows from the condition 
𝑏
(
1
−
𝑞
𝐹
)
𝑞
𝐴
<
1
b(1−q
F
	​

)q
A
	​

<1, which ensures 
P
𝑎
→
0
P
a
	​

→0, in the linear trees analysis. For branching trees we have 
P
𝑎
→
0
P
a
	​

→0 as 
𝐿
→
∞
L→∞ when 
𝑞
𝐴
<
1
/
1.8
q
A
	​

<1/1.8 but 
P
𝑎
<
1
P
a
	​

<1 when 
𝑞
𝐴
>
1
/
1.8
q
A
	​

>1/1.8. 
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.1
q
F
	​

=0.1 and branching parameter 
𝑏
=
2
b=2. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.1
)
=
1
/
1.8
q
A
	​

=q
A
	​

(2,0.1)=1/1.8.
As we increase 
𝑞
𝐹
q
F
	​

 the probability of anonymity failure is reduced for each number of layers 
𝐿
L as can be seen in figures below
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and branching parameter 
𝑏
=
2
b=2. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.2
)
=
1
/
1.6
q
A
	​

=q
A
	​

(2,0.2)=1/1.6.
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and branching parameter 
𝑏
=
2
b=2. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.3
)
=
1
/
1.4
q
A
	​

=q
A
	​

(2,0.3)=1/1.4.
As we increase the branching parameter 
𝑏
b the probability of anonymity failure is increased for each number of layers 
𝐿
L as can be seen in figures below
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.1
q
F
	​

=0.1 and branching parameter 
𝑏
=
3
b=3. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.1
)
=
1
/
2.7
q
A
	​

=q
A
	​

(2,0.1)=1/2.7. 
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.2
q
F
	​

=0.2 and branching parameter 
𝑏
=
3
b=3. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.2
)
=
1
/
2.4
q
A
	​

=q
A
	​

(2,0.2)=1/2.4.
The prob. of anonymity failure in linear (black lines) and branching (red lines) trees as a function of the number of layers 
𝐿
L plotted for fraction of adversarial nodes 
𝑞
𝐴
∈
{
0.1
,
0.2
,
0.3
,
0.4
,
0.5
,
0.6
,
0.7
,
0.8
,
0.9
}
q
A
	​

∈{0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9} (bottom to top), fraction of faulty nodes 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and branching parameter 
𝑏
=
3
b=3. Dotted lines correspond to 
𝑞
𝐴
=
𝑞
𝐴
(
2
,
0.3
)
=
1
/
2.1
q
A
	​

=q
A
	​

(2,0.3)=1/2.1.
Finally, we consider the prob. of adversarial broadcast failure 
P
𝑎
𝑏
P
ab
	​

. Here for branching trees we have only simulation results and we compare the latter with analytic results for linear trees. We note that in linear trees the prob. 
P
𝑎
𝑏
→
0
P
ab
	​

→0 as 
𝐿
→
∞
L→∞ when 
𝑏
 
(
1
−
𝑞
𝐹
)
(
1
−
𝑞
𝐴
)
>
1
b(1−q
F
	​

)(1−q
A
	​

)>1 and 
P
𝑎
𝑏
→
1
P
ab
	​

→1 when 
𝑏
 
(
1
−
𝑞
𝐹
)
(
1
−
𝑞
𝐴
)
<
1
b(1−q
F
	​

)(1−q
A
	​

)<1 and 
𝑏
 
(
1
−
𝑞
𝐹
)
>
1
b(1−q
F
	​

)>1 (see the linear trees analysis). The latter gives us 
𝑞
𝐹
<
1
−
1
/
𝑏
q
F
	​

<1−1/b, i.e. the condition for the prob. of broadcast failure 
P
𝑏
→
0
P
b
	​

→0 in linear and branching trees. For the branching parameter 
𝑏
=
2
b=2 the prob. of adversarial broadcast failure, 
P
𝑎
𝑏
P
ab
	​

, in linear trees is higher than in the branching trees as can be seen in the figure below. 
The probability of adversarial broadcast failure as a function of 
𝐿
L plotted for 
𝑏
=
2
b=2, 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.1
q
A
	​

=0.1. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples. 
The probability of adversarial broadcast failure as a function of 
𝐿
L plotted for 
𝑏
=
2
b=2, 
𝑞
𝐹
=
0.3
q
F
	​

=0.3 and 
𝑞
𝐴
=
0.4
q
A
	​

=0.4. In simulation probabilities were computed from 
𝑀
=
10
4
M=10
4
 samples. 
Appendix
Details of derivations
Loading...
