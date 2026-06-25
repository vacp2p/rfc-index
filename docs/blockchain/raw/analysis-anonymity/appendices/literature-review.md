# Literature review

## Summary of “[Are continuous stop-and-go mixnets provably secure](https://eprint.iacr.org/2023/1311)?” article.
- **Adversary:** We consider a probabilistic polynomial time (PPT) adversary that can observe (but not alter) all network traffic. The adversary can also perform passive and static corruptions of senders, the recipient R, and a subset of mixnodes. Passive and static corruption means that the adversary chooses the subset of corrupted parties before the protocol starts; the adversary then has access to the internal states of these c mixnodes, including all of their keys and random choices; however, the compromised parties still follow the protocol specifications.
- **User Unlinkability:** In our first definition, the adversary does not control the time when the challenge messages are released, and the content of any other messages from the honest users. This more closely captures the surveil- lance scenario where the adversary observes an interesting/disturbing message received by the recipient and then tries to figure out who among Alice and Bob could have sent that message. Informally, the protocol achieves anonymity according to this definition as long as a target message from Alice is ‘mixed’ with at least one message from Bob.
- **Pairwise Unlinkability:** Our second definition is stronger; here, we consider that the adversary controls the time when the challenge messages are released to the challenge users, the content of all other messages from the honest users, and then tries to distinguish who among them have sent which of the challenge messages after they are received by the recipient. Such a definition is useful to capture a strong adversarial scenario in the context of whistleblowing where the adversary might release fake/tagged documents and observe the time of its release to identify the whistleblower.
  - In one of our main results, we prove that in continuous mixnets, by controlling the time of release, the adversary can exploit the fact that whichever message goes into the AC network first, comes out first with good probability - which we formally denote as the FIFO attack.
- The **cascade continuous mixing (CCM)** protocol: i) Each message travels through a fixed cascade of k hops before getting delivered to the recipient; ii) The sender then onion encrypts the message (using Sphinx packet structure) for the cascade (including the recipient), and sends it to the first of the mixnode in the cascade after some delay sampled from exponential distribution; iii) Each mixnode delays the messages also following an exponential distribution.
  ![Diagram](../assets/1fd261aa-09df-8179-9bb2-c163a9d4935e.jpg)
- The **multi-path continuous mixing (MCM)** protocol: i) We consider a stratified topology where mixnodes are arranged in a number of layers, such that mixnodes in layer i receives messages from mixnodes in layer i - 1 and sends messages to mixnodes in layer i+1. The path length of message routes is determined by the number of layers, and is denoted by k. Further, we consider that each layer has exactly K mixnodes; ii) The sender of the message picks a path of length k by picking one mixnode uniformly at random from each layer, independent of the choices of other users or other messages; iii) The sender samples k independent delay values from exp. distribution. They then onion-encrypt the message for the path (including the recipient), and embed the values in the onions header such that only i-th mixnode can see its delay value. Then they send it to the first of the mixnodes in the path after a delay sampled from the exp. distr.
- A **trusted third party (TTP)** anonymizer receives messages and shuffles them. If there are a sufficient number of messages received by the TTP regularly, then each message will mix with enough number of other messages. However, if a set messages are received by the TTP exactly at the same moment, their output order will not reveal anything to the adversary; and we could say that those messages are “shuffled” with each other.
  - TTP interacts with the senders in U and the recipient R, and is parameterized by latency k and delay λ. The senders provide TTP with their messages over a secure channel, so that no information about the message content is leaked to the adversary.
    ![Diagram](../assets/1fd261aa-09df-8162-9195-c382db4ff215.jpg)
  - TTP acts as a central mixing node that delivers the messages to R after adding a delay (sampled from some prob. distribution related to the protocol).
  - Assuming that the central mixing node is honest, the power of the adversary is limited to an observer that monitors incoming and outgoing traffic.
  - As this sets the minimum power for a global passive adversary, the security of TTP serves as an optimistic bound of the security expected by a typical mixing construction.
- **FIFO attack**
  - We consider a simplified setting with (i) two senders u0, u1; (ii) a single recipient R; and (iii) TTP. The system state is as follows: each sender has a single message in her buffer and the queue is empty, i.e. there are no prior pending messages. The senders u0 and u1 send their messages to the recipient R that receives the messages m0 and m1.
    ![Diagram](../assets/1fd261aa-09df-8177-aa59-df9ea1999949.jpg)
  - The goal of the mix is to provide sender anonymity against an adversary that controls R and is a global observer, i.e. to hide whether communication occurs in 1) a “direct” manner: i.e. the users u0 and u1 sent, respectively, the messages m0 and m1 to R or 2) a “cross” manner: i.e. the users u0 and u1 sent, respectively, the messages m1 and m0 to R.
  - The adversary begins observation at some given time when the messages m0 , m1 are in the sender’s queues and are about to be delivered. By the memoryless property (?) and the description of the system state, we may assume that observation begins at time 0. Then adversary executes the following steps:
    ![Diagram](../assets/1fd261aa-09df-81aa-854a-f7bbb9f0bfea.png)
  - In a nutshell, adversary guesses based on the prediction that messages input earlier to the mixing node are more likely to be delivered earlier to the intended recipient.
- **Analysis of the FIFO attack**
  - Without loss of generality, assume that the users $`u_0`$ and $`u_1`$ provide the messages $`m_0`$ and $`m_1`$, respectively, in a “direct” manner to $`R`$ (due to symmetry and independence, the “cross” case can be analysed similarly?).
  - We denote the following random variables:
    1. The delay $`x_0`$ until $`m_0`$ is sent to TTP by $`u_0`$.
    1. The delay $`x_1`$ until $`m_1`$ is sent to TTP by $`u_1`$.
    1. The delay $`y_0`$ of TTP until $`m_0`$ is forwarded to $`R`$, i.e. the time $`m_0`$ stays in the TTP.
    1. The delay $`y_1`$ of the TTP until $`m_1`$ is forwarded to $`R`$, i.e. the time $`m_1`$ stays in the TTP
  - We have that $`t_{s,0}`$,$`t_{s,1}`$, $`t_{r,0}`$ and $`t_{r,1}`$ are the time values of $`x_0`$, $`x_1`$, $`x_0`$+$`y_0`$, $`x_1 + y_1`$, that adversary observes, in the direct case.
  - Thus adversary wins when either one of the following events happen:
    1. $`E_{0 \lt 1}: x_0 \lt x_1`$ and $`x_0 + y_0 \lt x_1 + y_1`$;
    1. or $`E_{0\geq1}: x_0 \geq x_1`$ and $`x_0 +y_0 \geq x_1 +y_1`$;
      ![Diagram](../assets/1fd261aa-09df-81da-a602-c25b89420a49.png)
- **User unlinkability definition**
  ![Diagram](../assets/1fd261aa-09df-81f5-8820-e6bb07548644.png)
![Diagram](../assets/1fd261aa-09df-81f9-a37e-e564487aa4de.png)
- **Analysis for User Unlinkability**
  ![Diagram](../assets/1fd261aa-09df-814c-9526-c1933bb2a129.png)
![Diagram](../assets/1fd261aa-09df-8199-8410-f2382400d299.png)
![Diagram](../assets/1fd261aa-09df-81bf-91e7-ed936ccd5868.png)
![Diagram](../assets/1fd261aa-09df-8116-927d-df30139dc4c5.png)
![Diagram](../assets/1fd261aa-09df-8173-9a84-f61a0ab8f501.png)
![Diagram](../assets/1fd261aa-09df-814e-b315-cf746c930b37.png)
- **Pairwise Unlinkability definition**
  ![Diagram](../assets/1fd261aa-09df-810c-a939-f8e15e6080fe.png)
  ![Diagram](../assets/1fd261aa-09df-8100-a541-f5d5bb9a9988.png)
- **Analysis for Pairwise Unlinkability**
  ![Diagram](../assets/1fd261aa-09df-8194-aa8f-cb2f9db0df69.png)
  ![Diagram](../assets/1fd261aa-09df-8129-b77d-cb4e123826e9.png)
  ![Diagram](../assets/1fd261aa-09df-8187-9ada-df646798f734.png)
  ![Diagram](../assets/1fd261aa-09df-8192-aa06-c54f8d78c44d.png)
  ![Diagram](../assets/1fd261aa-09df-81c2-81fc-f9c42df50c77.png)
  ![Diagram](../assets/1fd261aa-09df-819a-9595-e0dbad225be5.png)
  ![Diagram](../assets/1fd261aa-09df-8152-b6b2-cfb87b5a69c3.png)
  ![Diagram](../assets/1fd261aa-09df-81fe-a348-c48c0fe6e171.png)
- In above we plot the prob. bound from the inequality |prob. -1/2| \leq \delta . For example using Theorem 2 (plot (d) in the above) we obtain the following
  ![Diagram](../assets/1fd261aa-09df-81af-bc6b-f417d6fa55b4.png)
## Summary of “[The Generals' Scuttlebutt: Byzantine-Resilient Gossip Protocols](https://dl.acm.org/doi/abs/10.1145/3548606.3560638)”
- **Abstract**
![Diagram](../assets/1fd261aa-09df-81c1-acf2-e93f44a10e3b.png)
![Diagram](../assets/1fd261aa-09df-819e-80c7-e8480028047e.png)
![Diagram](../assets/1fd261aa-09df-8111-9104-c772f683aeb9.png)
