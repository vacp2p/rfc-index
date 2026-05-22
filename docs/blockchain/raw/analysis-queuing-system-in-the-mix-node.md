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

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors:  Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-09-08
Introduction
We consider queuing system of a mix node where coin-flipping algorithm is used to remove messages. We show that the amount of time message spends in a queue is governed by the Geometric distribution. The consequence of the latter is memorylessness property, i.e. the amount of time a message will spend in the queue is independent on how long it is already been in the queue, which is important for anonymity of communication.
Overview
This document analyses how a mix node—a privacy tool that hides message origins—manages delays using randomised queues. Key points:
Queue Design:
Each connection has an in-queue (FIFO order) and out-queue with randomised removal.
A "Relayer" forwards real messages to all out-queues except the sender’s, dropping dummies.
Randomised Delays:
Messages in the out-queue are shuffled, then each has probability 
𝑞
q (e.g., 50%) of being sent per round.
This follows a Geometric distribution: ~50% sent in Round 1, ~25% in Round 2, etc.
Anonymity Guarantee:
The system’s memorylessness ensures delays are independent of past wait times, preventing timing attacks.
Methods used:
Geometric distribution models rounds until a message is sent.
Simulations (e.g., sending 10,000 messages) validate the theory.
Binomial distribution tracks messages removed per round.
Why It Matters:
Balances privacy (unpredictable delays) with efficiency (tunable via 
𝑞
q).
Foundations for Tor-like systems and anonymous networks.
Analysis
Assumptions 
We assume that node 
𝑖
i has 
𝑐
𝑖
c
i
	​

 connections to other nodes, labelled by the set 
[
𝑐
𝑖
]
[c
i
	​

], and two queues (”in-queue” and “out-queue”), associated with each connection. Messages which arrive via the connection 
ℓ
∈
[
𝑐
𝑖
]
ℓ∈[c
i
	​

] are stored in the in-queue 
𝑄
ℓ
𝑖
𝑛
Q
ℓ
in
	​

. Messages which are sent via the connection 
ℓ
∈
[
𝑐
𝑖
]
ℓ∈[c
i
	​

] are stored in the out-queue 
𝑄
ℓ
𝑜
𝑢
𝑡
Q
ℓ
out
	​

. Messages are added to the back and removed from the front of 
𝑄
ℓ
𝑖
𝑛
Q
ℓ
in
	​

, i.e. the latter is the FIFO queue
Representation of a FIFO (first in, first out) queue.
We note that FIFO queue preserves temporal order of arriving messages. 
The Relayer removes a message from the front of 
𝑄
ℓ
𝑖
𝑛
Q
ℓ
in
	​

 and i) drops it if the message is a dummy or ii) adds the message to the back of all 
𝑄
𝑘
𝑜
𝑢
𝑡
Q
k
out
	​

, where 
𝑘
∈
[
𝑐
𝑖
]
∖
𝑗
k∈[c
i
	​

]∖j, queues (i.e. all out-queues but 
𝑗
j) if message is “real”. 
Above operation is repeated by Relayer for all 
𝑗
∈
[
𝑐
𝑖
]
j∈[c
i
	​

] 
Analysis of a single out-queue
Let us consider, without loss of generality, the out-queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 and assume that the front of 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 holds 
𝑛
n messages which arrived at times 
𝑡
1
≤
𝑡
2
≤
⋯
≤
𝑡
𝑛
t
1
	​

≤t
2
	​

≤⋯≤t
n
	​

.  Furthermore, we assume that messages which arrive at times after time 
𝑡
𝑛
t
n
	​

, 
𝑡
𝑖
>
𝑡
𝑛
t
i
	​

>t
n
	​

, are labelled by 
𝑖
∈
𝑁
∖
[
𝑛
]
i∈N∖[n], i.e. we assume that messages are labelled by the set 
𝑁
N. 
The above 
𝑛
n messages are shuffled, which is equivalent to random permutation, then each message is removed from the queue with probability 
𝑞
q and sent.  In above removal of a message which arrived at time 
𝑡
𝑖
t
i
	​

 can be modeled by the binary variable 
𝑥
𝑖
∈
{
0
,
1
}
x
i
	​

∈{0,1}, where 
0
/
1
0/1 corresponds to not-removed/removed.  We note that number of removed messages in this process is the random variable from binomial distribution with parameters 
𝑛
n and 
𝑞
q. Hence above process on average (and (approx.) typically) removes 
𝑞
 
𝑛
qn messages from the queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

. The above algorithm can be seen as a variant of the pool mix (see the article) 
A pool mix.
However, in the pool mix model a fixed number (of randomly selected messages) is removed and sent, but in the algorithm this number is random. 
Let us assume that messages are removed from the front of the out-queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 in rounds (or epochs) and if a message which arrived at time 
𝑡
𝑖
t
i
	​

, where 
𝑖
∈
𝑁
i∈N, was removed at round 
𝑟
r then 
𝑥
𝑖
(
𝑟
)
=
1
x
i
	​

(r)=1 and 
𝑥
𝑖
(
𝑘
)
=
0
x
i
	​

(k)=0 for 
1
≤
𝑘
<
𝑟
1≤k<r. We assume that after each round of removal the removed messages are replaced with new messages and the front 
𝑛
n messages in the queue are shuffled before the next round of removal.  We assume that round 
𝑟
∈
𝑁
r∈N follows the Geometric distribution 
P
𝑞
(
𝑟
)
=
(
1
−
𝑞
)
𝑟
−
1
𝑞
P
q
	​

(r)=(1−q)
r−1
q
To test above hypothesis we consider the following random process.
The message removal process in the out-queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

. At round 
0
0 the front of the queue contained 
𝑛
=
10
n=10 messages.  Here messages are  labelled by the set 
𝑁
N (top row). In round 
1
1, and in subsequent rounds, each message is removed, with the prob. 
𝑞
=
1
/
2
q=1/2, and replaced with a next message from the queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

. 
Computing the histogram of “the number of rounds a messages stays in the queue” random variable confirms that the latter follows the Geometric distribution. 
Histogram of the number of messages removed from the front of the queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 at round 
1
1, 
2
2, etc. of the random message removal process with 
𝑞
=
1
/
2
q=1/2. At round 
0
0 the front of the queue contained 
𝑛
=
10
4
n=10
4
 messages. Here the simulation (red histogram bars) is compared with the prediction 
𝑛
 
P
𝑞
(
𝑟
)
nP
q
	​

(r) of Geometric distribution (square boxes). We note that for 
𝑞
=
1
/
2
q=1/2 on average 
𝑛
/
2
n/2 messages were removed at round 
1
1, 
𝑛
/
4
n/4 messages were removed at round 
2
2, etc. 
Decreasing 
𝑞
q reduces number of messages removed per round as can be seen below. 
 
Histogram of the number of messages removed from the front of the queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 at round 
1
1, 
2
2, etc. of the random message removal process with 
𝑞
=
1
/
4
q=1/4. At round 
0
0 the front of queue contained 
𝑛
=
10
4
n=10
4
 messages. Here the simulation (red histogram bars) is compared with the prediction 
𝑛
 
P
𝑞
(
𝑟
)
nP
q
	​

(r) of Geometric distribution (square boxes). We note that for 
𝑞
=
1
/
4
q=1/4 on average 
𝑛
/
4
n/4 messages were removed at round 
1
1, 
(
𝑛
−
𝑛
/
4
)
/
4
(n−n/4)/4 messages were removed at round 
2
2, etc. 
Increasing 
𝑞
q increases number of messages removed per round as can be seen below.
Histogram of the number of messages removed from the front of the queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 at round 
1
1, 
2
2, etc. of the random message removal process with 
𝑞
=
3
/
4
q=3/4. At round 
0
0 the front of queue contained 
𝑛
=
10
4
n=10
4
 messages. Here the simulation (red histogram bars) is compared with the prediction 
𝑛
 
P
𝑞
(
𝑟
)
nP
q
	​

(r) of Geometric distribution (square boxes). We note that for 
𝑞
=
3
/
4
q=3/4 on average 
3
𝑛
/
4
3n/4 messages were removed at round 
1
1, 
3
(
𝑛
−
3
𝑛
/
4
)
/
4
3(n−3n/4)/4 messages were removed at round 
2
2, etc.
The Geometric distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r) is increasing function of 
𝑞
q for 
1
/
𝑞
>
𝑟
1/q>r and decreasing function of 
𝑞
q for 
1
/
𝑞
<
𝑟
1/q<r. 
 The Geometric distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r) plotted as the function of 
𝑟
∈
𝑁
r∈N for 
𝑞
∈
{
1
/
4
,
1
/
2
,
3
/
4
}
q∈{1/4,1/2,3/4} (magenta, red, blue). 
Assuming that the duration of round 
𝑘
k is 
Δ
𝑘
Δ
k
	​

 the message which arrived at time 
𝑡
𝑖
t
i
	​

 will be removed from the queue at time 
𝑡
𝑖
+
∑
𝑘
=
1
𝑟
Δ
𝑘
t
i
	​

+∑
k=1
r
	​

Δ
k
	​

, where 
𝑟
r is random variable from the Geometric distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r). We expect that 
Δ
𝑘
Δ
k
	​

 is a function of the number 
𝑛
1
(
𝑘
)
n
1
	​

(k) of messages removed at round 
𝑘
k, i.e. 
Δ
𝑘
≡
Δ
(
𝑛
1
(
𝑘
)
)
Δ
k
	​

≡Δ(n
1
	​

(k)). Here 
𝑛
1
(
𝑘
)
n
1
	​

(k) is random number from the binomial distribution with parameters 
𝑛
n ( size of queue) and 
𝑞
q (prob. of dequeuing a message). We note that at most 
𝑛
n messages can be removed and 
Δ
(
𝑛
1
(
𝑘
)
)
≤
Δ
(
𝑛
)
Δ(n
1
	​

(k))≤Δ(n). The latter implies that 
𝑡
𝑖
+
∑
𝑘
=
1
𝑟
Δ
(
𝑛
1
(
𝑘
)
)
≤
𝑡
𝑖
+
𝑟
Δ
t
i
	​

+∑
k=1
r
	​

Δ(n
1
	​

(k))≤t
i
	​

+rΔ , where we defined 
Δ
=
Δ
(
𝑛
)
Δ=Δ(n). Thus a message is delayed in the out-queue 
𝑄
1
𝑜
𝑢
𝑡
Q
1
out
	​

 by at most 
𝑟
Δ
rΔ, where 
𝑟
r is the random variable from the distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r). 
Furthermore, the probability 
P
(
𝑟
≤
𝑅
−
1
)
=
1
−
(
1
−
𝑞
)
𝑅
−
1
P(r≤R−1)=1−(1−q)
R−1
 for the random variable 
𝑟
r from the Geometric distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r). Hence 
P
(
𝑟
≥
𝑅
)
=
1
−
P
(
𝑟
≤
𝑅
−
1
)
=
(
1
−
𝑞
)
𝑅
−
1
.
P(r≥R)=1−P(r≤R−1)=(1−q)
R−1
.
 Thus a message is delayed by 
𝑟
Δ
≥
𝑅
Δ
rΔ≥RΔ with the probability 
(
1
−
𝑞
)
𝑅
−
1
(1−q)
R−1
. We note that for the random variable 
𝑟
r from the Geometric distribution 
P
𝑞
(
𝑟
)
P
q
	​

(r) we can show that 
P
(
𝑅
>
𝑚
+
𝑛
∣
𝑅
>
𝑚
)
=
P
(
𝑅
>
𝑛
)
P(R>m+n∣R>m)=P(R>n). The latter is memorylessness property of Geometric distribution and the consequence of the latter is that the amount of time a message will spend in the queue is independent on how long it is already been in the queue. 
Bibliography
Das D., Diaz C., Kiayias A., Zacharias T. (2024). Are continuous stop-and-go mixnets provably secure? Proceedings on Privacy Enhancing Technologies. https://eprint.iacr.org/2023/1311
Serjantov, A., Danezis, G. (2003). Towards an Information Theoretic Metric for Anonymity. In: Dingledine, R., Syverson, P. (eds) Privacy Enhancing Technologies. PET 2002. Lecture Notes in Computer Science, vol 2482. Springer, Berlin, Heidelberg. https://doi.org/10.1007/3-540-36467-6_4
Sign up or log in
Report page
Cookie settings
Pages
[1.0.0][Analysis] Queuing System in the Mix Node
Current Page
—
The Logos Blockchain Project
/
Specifications
The Logos Blockchain Project
/
Specifications
[1.0.0][Analysis] Queuing System in the Mix Node
Authors:  Alexander Mozeika <alexander.mozeika@logos.co>
Revision History
Table
Introduction
We consider queuing system of a mix node where coin-flipping algorithm is used to remove messages. We show that the amount of time message spends in a queue is governed by the Geometric distribution. The consequence of the latter is memorylessness property, i.e. the amount of time a message will spend in the queue is independent on how long it is already been in the queue, which is important for anonymity of communication.
Overview
This document analyses how a mix node—a privacy tool that hides message origins—manages delays using randomised queues. Key points:
Queue Design:
Each connection has an in-queue (FIFO order) and out-queue with randomised removal.
A "Relayer" forwards real messages to all out-queues except the sender’s, dropping dummies.
Randomised Delays:
Messages in the out-queue are shuffled, then each has probability 
Σ
Equation
 (e.g., 50%) of being sent per round.
This follows a Geometric distribution: ~50% sent in Round 1, ~25% in Round 2, etc.
Anonymity Guarantee:
The system’s memorylessness ensures delays are independent of past wait times, preventing timing attacks.
Methods used:
Geometric distribution models rounds until a message is sent.
Simulations (e.g., sending 10,000 messages) validate the theory.
Binomial distribution tracks messages removed per round.
Why It Matters:
Balances privacy (unpredictable delays) with efficiency (tunable via 
Σ
Equation
).
Foundations for Tor-like systems and anonymous networks.
Analysis
Assumptions
We assume that node 
Σ
Equation
 has 
Σ
Equation
 connections to other nodes, labelled by the set 
Σ
Equation
, and two queues (”in-queue” and “out-queue”), associated with each connection. Messages which arrive via the connection 
Σ
Equation
 are stored in the in-queue 
Σ
Equation
. Messages which are sent via the connection 
Σ
Equation
 are stored in the out-queue 
Σ
Equation
. Messages are added to the back and removed from the front of 
Σ
Equation
, i.e. the latter is the FIFO queue
We note that FIFO queue preserves temporal order of arriving messages.
The Relayer removes a message from the front of 
Σ
Equation
 and i) drops it if the message is a dummy or ii) adds the message to the back of all 
Σ
Equation
, where 
Σ
Equation
, queues (i.e. all out-queues but 
Σ
Equation
) if message is “real”.
Above operation is repeated by Relayer for all 
Σ
Equation
Analysis of a single out-queue
Let us consider, without loss of generality, the out-queue 
Σ
Equation
 and assume that the front of 
Σ
Equation
 holds 
Σ
Equation
 messages which arrived at times 
Σ
Equation
. Furthermore, we assume that messages which arrive at times after time 
Σ
Equation
, 
Σ
Equation
, are labelled by 
Σ
Equation
, i.e. we assume that messages are labelled by the set 
Σ
Equation
.
The above 
Σ
Equation
 messages are shuffled, which is equivalent to random permutation, then each message is removed from the queue with probability 
Σ
Equation
 and sent. In above removal of a message which arrived at time 
Σ
Equation
 can be modeled by the binary variable 
Σ
Equation
, where 
Σ
Equation
 corresponds to not-removed/removed. We note that number of removed messages in this process is the random variable from binomial distribution with parameters 
Σ
Equation
 and 
Σ
Equation
. Hence above process on average (and (approx.) typically) removes 
Σ
Equation
 messages from the queue 
Σ
Equation
. The above algorithm can be seen as a variant of the pool mix (see the article)
However, in the pool mix model a fixed number (of randomly selected messages) is removed and sent, but in the algorithm this number is random.
Let us assume that messages are removed from the front of the out-queue 
Σ
Equation
 in rounds (or epochs) and if a message which arrived at time 
Σ
Equation
, where 
Σ
Equation
, was removed at round 
Σ
Equation
 then 
Σ
Equation
 and 
Σ
Equation
 for 
Σ
Equation
. We assume that after each round of removal the removed messages are replaced with new messages and the front 
Σ
Equation
 messages in the queue are shuffled before the next round of removal. We assume that round 
Σ
Equation
 follows the Geometric distribution
📈
Equation
To test above hypothesis we consider the following random process.
Computing the histogram of “the number of rounds a messages stays in the queue” random variable confirms that the latter follows the Geometric distribution.
Decreasing 
Σ
Equation
 reduces number of messages removed per round as can be seen below.
Increasing 
Σ
Equation
 increases number of messages removed per round as can be seen below.
The Geometric distribution 
Σ
Equation
 is increasing function of 
Σ
Equation
 for 
Σ
Equation
 and decreasing function of 
Σ
Equation
 for 
Σ
Equation
.
Assuming that the duration of round 
Σ
Equation
 is 
Σ
Equation
 the message which arrived at time 
Σ
Equation
 will be removed from the queue at time 
Σ
Equation
, where 
Σ
Equation
 is random variable from the Geometric distribution 
Σ
Equation
. We expect that 
Σ
Equation
 is a function of the number 
Σ
Equation
 of messages removed at round 
Σ
Equation
, i.e. 
Σ
Equation
. Here 
Σ
Equation
 is random number from the binomial distribution with parameters 
Σ
Equation
 ( size of queue) and 
Σ
Equation
 (prob. of dequeuing a message). We note that at most 
Σ
Equation
 messages can be removed and 
Σ
Equation
. The latter implies that 
Σ
Equation
 , where we defined 
Σ
Equation
. Thus a message is delayed in the out-queue 
Σ
Equation
 by at most 
Σ
Equation
, where 
Σ
Equation
 is the random variable from the distribution 
Σ
Equation
.
Furthermore, the probability 
Σ
Equation
 for the random variable 
Σ
Equation
 from the Geometric distribution 
Σ
Equation
. Hence
📈
Equation
Thus a message is delayed by 
Σ
Equation
 with the probability 
Σ
Equation
. We note that for the random variable 
Σ
Equation
 from the Geometric distribution 
Σ
Equation
 we can show that 
Σ
Equation
. The latter is memorylessness property of Geometric distribution and the consequence of the latter is that the amount of time a message will spend in the queue is independent on how long it is already been in the queue.
Bibliography
Das D., Diaz C., Kiayias A., Zacharias T. (2024). Are continuous stop-and-go mixnets provably secure? Proceedings on Privacy Enhancing Technologies. https://eprint.iacr.org/2023/1311
Serjantov, A., Danezis, G. (2003). Towards an Information Theoretic Metric for Anonymity. In: Dingledine, R., Syverson, P. (eds) Privacy Enhancing Technologies. PET 2002. Lecture Notes in Computer Science, vol 2482. Springer, Berlin, Heidelberg. https://doi.org/10.1007/3-540-36467-6_4
Open in new tab
