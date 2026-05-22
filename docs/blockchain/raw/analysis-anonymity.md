# ANALYSISANONYMITY

| Field | Value |
| --- | --- |
| Name | [Analysis] Anonymity |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor |  |
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

Literature review
Literature review 
Summary of “Are continuous stop-and-go mixnets provably secure?” article.
Adversary: We consider a probabilistic polynomial time (PPT) adversary that can observe (but not alter) all network traffic. The adversary can also perform passive and static corruptions of senders, the recipient R, and a subset of mixnodes. Passive and static corruption means that the adversary chooses the subset of corrupted parties before the protocol starts; the adversary then has access to the internal states of these c mixnodes, including all of their keys and random choices; however, the compromised parties still follow the protocol specifications.
User Unlinkability: In our first definition, the adversary does not control the time when the challenge messages are released, and the content of any other messages from the honest users. This more closely captures the surveil- lance scenario where the adversary observes an interesting/disturbing message received by the recipient and then tries to figure out who among Alice and Bob could have sent that message. Informally, the protocol achieves anonymity according to this definition as long as a target message from Alice is ‘mixed’ with at least one message from Bob.
Pairwise Unlinkability: Our second definition is stronger; here, we consider that the adversary controls the time when the challenge messages are released to the challenge users, the content of all other messages from the honest users, and then tries to distinguish who among them have sent which of the challenge messages after they are received by the recipient. Such a definition is useful to capture a strong adversarial scenario in the context of whistleblowing where the adversary might release fake/tagged documents and observe the time of its release to identify the whistleblower.
In one of our main results, we prove that in continuous mixnets, by controlling the time of release, the adversary can exploit the fact that whichever message goes into the AC network first, comes out first with good probability - which we formally denote as the FIFO attack.
The cascade continuous mixing (CCM) protocol: i) Each message travels through a fixed cascade of k hops before getting delivered to the recipient; ii) The sender then onion encrypts the message (using Sphinx packet structure) for the cascade (including the recipient), and sends it to the first of the mixnode in the cascade after some delay sampled from exponential distribution; iii) Each mixnode delays the messages also following an exponential distribution.
The multi-path continuous mixing (MCM) protocol: i) We consider a stratified topology where mixnodes are arranged in a number of layers, such that mixnodes in layer i receives messages from mixnodes in layer i - 1 and sends messages to mixnodes in layer i+1. The path length of message routes is determined by the number of layers, and is denoted by k. Further, we consider that each layer has exactly K mixnodes; ii) The sender of the message picks a path of length k by picking one mixnode uniformly at random from each layer, independent of the choices of other users or other messages; iii) The sender samples k independent delay values from exp. distribution. They then onion-encrypt the message for the path (including the recipient), and embed the values in the onions header such that only i-th mixnode can see its delay value. Then they send it to the first of the mixnodes in the path after a delay sampled from the exp. distr.
A trusted third party (TTP) anonymizer receives messages and shuffles them. If there are a sufficient number of messages received by the TTP regularly, then each message will mix with enough number of other messages. However, if a set messages are received by the TTP exactly at the same moment, their output order will not reveal anything to the adversary; and we could say that those messages are “shuffled” with each other.
TTP interacts with the senders in U and the recipient R, and is parameterized by latency k and delay λ. The senders provide TTP with their messages over a secure channel, so that no information about the message content is leaked to the adversary.	
TTP acts as a central mixing node that delivers the messages to R after adding a delay (sampled from some prob. distribution related to the protocol).
Assuming that the central mixing node is honest, the power of the adversary is limited to an observer that monitors incoming and outgoing traffic.
As this sets the minimum power for a global passive adversary, the security of TTP serves as an optimistic bound of the security expected by a typical mixing construction.
FIFO attack
We consider a simplified setting with (i) two senders u0, u1; (ii) a single recipient R; and (iii) TTP. The system state is as follows: each sender has a single message in her buffer and the queue is empty, i.e. there are no prior pending messages. The senders u0 and u1 send their messages to the recipient R that receives the messages m0 and m1.
The goal of the mix is to provide sender anonymity against an adversary that controls R and is a global observer, i.e. to hide whether communication occurs in 1) a “direct” manner: i.e. the users u0 and u1 sent, respectively, the messages m0 and m1 to R or 2) a “cross” manner: i.e. the users u0 and u1 sent, respectively, the messages m1 and m0 to R.
The adversary begins observation at some given time when the messages m0 , m1 are in the sender’s queues and are about to be delivered. By the memoryless property (?) and the description of the system state, we may assume that observation begins at time 0. Then adversary executes the following steps:
In a nutshell, adversary guesses based on the prediction that messages input earlier to the mixing node are more likely to be delivered earlier to the intended recipient.
Analysis of the FIFO attack
Without loss of generality, assume that the users 
𝑢
0
u
0
	​

 and 
𝑢
1
u
1
	​

 provide the messages 
𝑚
0
m
0
	​

 and 
𝑚
1
m
1
	​

, respectively, in a “direct” manner to 
𝑅
R (due to symmetry and independence, the “cross” case can be analysed similarly?).
We denote the following random variables:
The delay 
𝑥
0
x
0
	​

 until 
𝑚
0
m
0
	​

 is sent to TTP by 
𝑢
0
u
0
	​

.
The delay 
𝑥
1
x
1
	​

 until 
𝑚
1
m
1
	​

 is sent to TTP by 
𝑢
1
u
1
	​

.
The delay 
𝑦
0
y
0
	​

 of TTP until 
𝑚
0
m
0
	​

 is forwarded to 
𝑅
R, i.e. the time 
𝑚
0
m
0
	​

 stays in the TTP.
The delay 
𝑦
1
y
1
	​

 of the TTP until 
𝑚
1
m
1
	​

 is forwarded to 
𝑅
R, i.e. the time 
𝑚
1
m
1
	​

 stays in the TTP
We have that 
𝑡
𝑠
,
0
t
s,0
	​

,
𝑡
𝑠
,
1
t
s,1
	​

, 
𝑡
𝑟
,
0
t
r,0
	​

 and 
𝑡
𝑟
,
1
t
r,1
	​

 are the time values of 
𝑥
0
x
0
	​

, 
𝑥
1
x
1
	​

, 
𝑥
0
x
0
	​

+
𝑦
0
y
0
	​

, 
𝑥
1
+
𝑦
1
x
1
	​

+y
1
	​

, that adversary observes, in the direct case.
Thus adversary wins when either one of the following events happen:
𝐸
0
<
1
:
𝑥
0
<
𝑥
1
E
0<1
	​

:x
0
	​

<x
1
	​

 and 
𝑥
0
+
𝑦
0
<
𝑥
1
+
𝑦
1
x
0
	​

+y
0
	​

<x
1
	​

+y
1
	​

;
or 
𝐸
0
≥
1
:
𝑥
0
≥
𝑥
1
E
0≥1
	​

:x
0
	​

≥x
1
	​

 and 
𝑥
0
+
𝑦
0
≥
𝑥
1
+
𝑦
1
x
0
	​

+y
0
	​

≥x
1
	​

+y
1
	​

;	
User unlinkability definition 
Analysis for User Unlinkability
Pairwise Unlinkability definition
Analysis for Pairwise Unlinkability
In above we plot the prob. bound from the inequality |prob. -1/2| \leq \delta . For example using Theorem 2 (plot (d) in the above) we obtain the following 
Summary of “The Generals' Scuttlebutt: Byzantine-Resilient Gossip Protocols” 
Abstract
