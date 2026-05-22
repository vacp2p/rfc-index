# ANALYSISCRYPTARCHIA-DEANONYMISATION-OF-RELATIVE-STAKE

| Field | Value |
| --- | --- |
| Name | [Analysis] Cryptarchia De-anonymisation of Relative Stake |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Alexander Mozeika <alexander.mozeika@logos.co>, Filip Dimitrijevic <filip@logos.co> |

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
| 1.0.0 | Initial revision. | 2025-08-26 |

Details of derivations are in the documents [Statistical inference of relative stake](/1fd261aa09df8181a428f52251e173c4?pvs=25#255261aa09df802d808dc47be2fdbe05) and [Analysis of leader election process in PoS](/1fd261aa09df8181a428f52251e173c4?pvs=25#256261aa09df80cfadacdb638f634815).

## Stake Distribution Strategies Based on Adversarial Inference Which Uses a Naive Estimator

The adversary observes the leader election process of a node with the relative stake $\alpha$ .

In $T$ time slots, he/she is able to observe $n$ wins in $m$ observations.

For $m\geq1$ he/she uses the naive estimator $\hat{\alpha}=\frac{\log\left(1-n/m\right)}{\log(1-f)}$ of the true relative stake $\alpha$ .

Here  $f$ , known to adversary, is the fraction of time-slots with at least one winner.

For “accuracy”  $\gamma\in(0,1)$ , the probability that  $\alpha(1-\gamma)\leq\hat{\alpha}\leq\alpha(1+\gamma)$  for large  $T$  is [given by](https://www.overleaf.com/read/xvgmfchdhgzh#acd15d)  $\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\right)=\frac{2 \,\mathrm{erf}\! \left(\frac{ \epsilon}{\sqrt{2\sigma^2(q)}}\right)}{\mathrm{erf}\! \left(\frac{s }{ \sqrt{2\sigma^2(q)}}\right)+\mathrm{erf}\! \left(\frac{ 1-s}{ \sqrt{2\sigma^2(q)}}\right)},$  where  $s\equiv\phi(\alpha)$  is the lottery function,  $\epsilon=\gamma\alpha\frac{\mathrm{d}}{\mathrm{d}\alpha}\phi(\alpha)$  and  $\sigma^2(q)=s(1-s)/T q$ . Here  $q$  is the fraction of observed time-slots such that  $Tq$  slots are observed on average.

An example of above probability is given below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F694d7ce0-ede2-44dc-ac13-5ad0bb78b47d%2Fadver_conf.png?table=block&id=1fd261aa-09df-8183-a4bc-d76c2e3a9dee&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=830&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The probability that inferred relative stake $\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]$ , i.e. adversarial “confidence”, as a function of the true relative stake $\alpha$ obtained in $T=432000$ time-slots (the number used in Cardano) when fraction $q=0.657$ of slots is observed. Here the probability that the stake of a node with the true stake $\alpha=0.0126$ (the max. stake in the Bitcoin network), represented by a red vertical line, is inferred with an “accuracy” within the fraction $\gamma=0.1$ of relative stake $\alpha$ , represented by $\alpha(1\pm\gamma)$ red vertical dotted lines, is approx. $0.824$ . The red dashed horizontal line corresponds to the threshold $\theta=0.5$ . The blue vertical line at $\alpha=0.00252$ is the result of dividing the stake $\alpha=0.0126$ into $5$ nodes.

ALT

Having estimated the fraction of observed time-slots $q$ and accuracy $\gamma$ a node can use its stake $\alpha$ , to compute the probability $\delta(\alpha)=\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\right)$ , i.e. the “confidence” obtained by an adversary in $T$ time-slots. For a node, it is beneficial to reduce the latter, which can be done by distributing its stake among a number of nodes. To this end, the probability $\delta(\alpha)$ is compared with some threshold $\theta$ and if $\delta(\alpha)\geq\theta$ then the stake is divided, i.e. $\alpha\leftarrow\alpha/2$ , $\alpha\leftarrow\alpha/3$ , etc., until $\delta(\alpha)<\theta$ .

The main functions of the algorithm which uses $\delta(\alpha)$ to distribute the stake are as follows:

from math import erf, sqrt, log
def phi(alpha):
global f
return 1 - (1 - f)\*\*alpha
def dphi(alpha):
global f
return -((1 - f)\*\*alpha) \* log(1 - f)
def Prob2(alpha, epsilon, T, q):
sqrt2 = sqrt(2.0)
numerator = -2.0 \* erf(sqrt2 \* epsilon / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q))))
denominator = (-erf(phi(alpha) \* sqrt2 / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q)))) + erf(sqrt2 \* (phi(alpha) - 1) / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q)))))
return numerator / denominator

​

The above functions are then used to find minimum number of nodes such that distributing the stake into these nodes reduces the probability $\delta(\alpha)$ to $\theta$ as follows

import math
# Define parameters
T = 432000 # number of time-slots in one epoch
theta = 0.5 # adversarial confidence threshold
gamma0 = 0.1 # adversarial accuracy
a = 0.3 # fraction of compromised paths in the mixnet
r = 3 # redundancy in messages sent through the mixnet
q0 = 1 - (1 - a)\*\*r # fraction of compromised messages
f = 0.05
n\_max = 10 # maximum number of iterations
alpha0 = 0.0126 #initial stake 
# Initialize relative stake alpha and delta
alpha = alpha0
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
# Loop until delta <= theta or n reaches n\_max
n = 2
while delta > theta and n <= n\_max:
alpha = alpha0 / n
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
n += 1
# Update alpha and Prob
alpha = alpha0 / (n - 1)
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
print("Final num. of nodes:", n-1)
print("Final alpha:", alpha)
print("Final Prob:", delta)

​

The above program suggests that the stake $\alpha=0.0126$ has to be divided among 5 nodes for the adversarial confidence $\delta(\alpha)<0.5$ when $0.3$ of paths in the mixnet are compromised (this is $80\times 3$ , where $3$ is the number of layers, with a mixnet sampled from $800$ nodes with $400$ adversarial nodes) and each message is sent $3$ times giving $0.657$ for the fraction of messages being compromised.

## Analysis of Naive Estimator

The naive estimator of relative stake $\hat{\alpha}\_i=\frac{\log\left(1-\hat{P}\_i(1)\right)}{\log(1-f)}$ is obtained from the maximum likelihood (ML) estimator by setting $\lambda=0$ .

The probability that $\alpha\_i-\epsilon\leq\hat{\alpha}\_i\leq\alpha\_i+\epsilon$ , where $\alpha\_i$ is true relative stake and $\epsilon$ is “accuracy”, is given by $P\left(\phi\_f(\alpha\_i-\epsilon)\,m\leq n \leq \phi\_f(\alpha\_i+\epsilon)\,m\vert m>0\right)=\sum\_{m=1}^T\sum\_{n=0}^m\frac{P\left(m\vert T \right)P\left(n\vert m \right)}{1-(1-q)^T} 1\left[\phi\_f(\alpha\_i-\epsilon)\,m\leq n \leq \phi\_f(\alpha\_i+\epsilon)\,m\right]$ , where $P\left(m\vert T \right)$ is the binomial distribution of number of observations $m$ , with the parameter $q$ such that $q\,T$ is the average number of observations, and $P\left(n\vert m \right)$ is the binomial distribution of the number of observed wins n, with the parameter $\phi\_f(\alpha\_i)$ such that $\phi\_f(\alpha\_i)\, m$ is the average number of observed wins.

The probability of $\alpha\_i-\epsilon\leq\hat{\alpha}\_i\leq\alpha\_i+\epsilon$ can be interpreted as “confidence”. The probability that $\alpha\_i-\epsilon\leq\hat{\alpha}\_i$ , given by $P\left(\phi\_f(\alpha\_i-\epsilon)\,m\leq n\vert m>0\right)$ , is also of interest. However, for $\hat{P}\_i(1)>f$ , which can happen for short observation times $T$ , the estimator $\hat{\alpha}\_i>1$ (and hence the probability of $\alpha\_i-\epsilon\leq\hat{\alpha}\_i$ ) can be considered only for long observation times $T$ where the probability of the event $\hat{\alpha}\_i>1$ is small.

The bounds and (large time T) asymptotic estimates on the probability $P\left(\phi\_f(\alpha\_i-\epsilon)\,m\leq n \leq \phi\_f(\alpha\_i+\epsilon)\,m\vert m>0\right)$ , as well as on the probability $P\left(\phi\_f(\alpha\_i-\epsilon)\,m\leq n\vert m>0\right)$ , can be obtained by adopting the results in [Analysis of leader election process in proof of stake consensus model](/1fd261aa09df8181a428f52251e173c4?pvs=25#256261aa09df80cfadacdb638f634815).

### Numerical Results

The maximum likelihood (ML) estimator performance is dependent on the fraction of observed nodes $q$ (or the mixnet failure probability) and the number of slots $T$ . The [erformance of the estimator improves as $T$ increases, as can be seen in this plot:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fdc35a820-24ee-46d5-908e-4c81a59bf899%2Ftest-3.png?table=block&id=1fd261aa-09df-8189-ad5e-e7965070d1c6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The (naive) ML estimator, given by the frequency of elections won, as a function of the number of slots $T$ plotted for a number of nodes with relative stakes $\alpha$ . Here on average the fraction $q=0.8$ of slots was observed.

ALT

The performance of ML estimators was also evaluated using the [Jaccard Index](https://en.wikipedia.org/wiki/Jaccard_index). The index evaluates the estimators’ ability to correctly classify nodes as “high” or “low” stake. The simulation was done across multiple mixnet failure probabilities $q$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F16f34084-639b-4742-b076-7eee8d749975%2FUntitled.png?table=block&id=1fd261aa-09df-81a5-8cd6-cf7500aba079&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1020&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The performance of the (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here the N=2000 stake values were drawn from the  $\text{Pareto}(m=2, s=1)$  distribution and T=432000. For q close 1, i.e. all nodes are observed, most high stake nodes are inferred correctly (Jaccard index is close to 1). As q (i.e. fraction of observed nodes) decreases, the accuracy decreases and for $q>10^{-2}$ is significantly reduced (Jaccard index is close to 0).

ALT

Analysis was also done using Cardano’s real world stake values. Clearly, Cardano’s stake distribution incentives somehow seem to protect against inferring top 1pct of stakers. More analysis is needed:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fba83f13e-bfeb-4c0e-9729-aa68993b3739%2FUntitled.png?table=block&id=1fd261aa-09df-811e-9438-cf3f54ecafdd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=930&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The performance of (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here T=432000 and N=2500 stake values were obtained from [Cardano](/1fd261aa09df8181a428f52251e173c4?pvs=25#256261aa09df80a69f56f2338556b0f1).

ALT

## Analysis of ML Estimator: Inference of Lagrange Multiplier

The naive estimator above assumed the Lagrange multiplier, which ensures that inferred relative stake is normalized , $\lambda=0$ . A more sophisticated estimator can be derived from the ML framework by inferring $\lambda$ for a given sample.

The Lagrange multiplier $\lambda$ is inferred by minimizing the distance between the LHS and RHS of [equation](/1fd261aa09df8181a428f52251e173c4?pvs=25#255261aa09df8004b2a3d68af0ee215b) (18) :

$$
D(1-f || \prod\_{i=1}^N\left[1-\hat{\phi}\_i(\lambda)\right])
$$
D(1−f∣∣i=1∏N​[1−ϕ^​i​(λ)])

In the above, the “distance” used is the relative entropy. Computing the partial derivative w.r.t. $\lambda$ gives us a gradient which we can then follow using gradient descent, or any other algorithm which uses a gradient, to discover the choice of $\lambda$ which minimizes the above distance.

Inferred Distributions of Relative Stake

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F36dfbc9c-79fd-4296-ad0e-699582def54f%2FUntitled.png?table=block&id=1fd261aa-09df-8126-a553-fb355c86555e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=390&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Relative stake obtained in 1000 inferences for stake distribution drawn from $\text{Pareto}(2,1)$
$q=1$ ​

ALT

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F4c7fb880-f8ef-49ce-86d1-9591494aa57a%2FUntitled.png?table=block&id=1fd261aa-09df-8187-b929-f3a06054bc52&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=390&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

$q=0.1$ ​

ALT

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F17aa62f5-a89d-486e-ae1a-8b0fdcdea827%2FUntitled.png?table=block&id=1fd261aa-09df-81f1-a6bc-c1b6a738f4fa&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=390&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

$q=0.01$ ​

ALT

Here $q$ is the fraction of observed time-slots (or the “mixnet failure probability”) out of the total $T=432,000$ time-slots. The small, grad and naive above refer to the $\lambda \rarr 0$ approximation, the inferred $\lambda$ , and the $\lambda=0$ estimators respectively. The inferred $\lambda$ estimator produces a smoother distribution for small $q$ . The small and naive estimators produce near identical inferred distributions.

The Total of Inferred Relative Stake

The sum of all relative stake (by definition) must sum to 1. Here we plot the error in inferred total stake for the different estimators:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa01ea93f-8888-47e6-bafc-f277e4195532%2FUntitled.png?table=block&id=1fd261aa-09df-815c-b327-d891eb11dedd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=590&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Plotting the squared distance to 1 of the sum of inferred relative stakes. The inferred $\lambda$ estimator produces a much lower and constant error across $q$ values on this metric.

ALT

Classification Performance

Despite the reduced error in total relative stake inference, and the smoother histogram, the naive estimator performed identically to the inferred $\lambda$ estimator when tasked to identify the top stakers of the distribution.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2bac2ff4-0567-4be6-9f9a-b26115264ad6%2FUntitled.png?table=block&id=1fd261aa-09df-8193-8101-cf37ca124398&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

We ask the question: given the top 10% of inferred stakers, is the true top staker among those inferred top 10%.
Naive and grad estimators performed identically at this task.

ALT

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F09fdb70d-e76c-498e-98c1-dd16dac1a0d7%2FUntitled.png?table=block&id=1fd261aa-09df-8104-8020-e551eef13573&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Plot of the Jaccard Index: J(inferred 90th pct, true 90th pct). High Jaccard index tells us there is a high degree of overlap between the two sets, low index tells us that the sets are nearly disjoint.

ALT

Estimator Accuracy

Here we measure the accuracy of estimators. The left plot shows inferred vs true relative stake for one simulation, right plot shows mean squared error between inferred and true relative stakes. We find that both naive and inferred $\lambda$ estimators produce similar results.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9e70c117-a48a-4418-84c9-3fa32018ffa8%2FUntitled.png?table=block&id=1fd261aa-09df-819c-91c5-f922fc5c7be3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

X-axis is the true relative stake, Y-axis is the inferred relative stake. Perfect inference would produce the solid black line. All estimators perform nearly identically.
Simulation parameters:
$q=0.5$ , $f=0.05$ , $T=432,000$
stake distribution=np.linspace(1, 100, 1000)

ALT

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fcabbaf04-2327-45c0-9dbd-04ff4047d032%2FUntitled.png?table=block&id=1fd261aa-09df-81f7-8fd6-e3015ff84aff&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=630&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Plotting the Mean Squared Error (i.e. average squared distance between true and inferred relative stake pairs) against $q$ .
Simulation Parameters:
$f=0.05, T=432,000$
stake distribution = Cardano

ALT

### Statistical Inference of Relative Stake

Leader election process: at time-slot $t$ the probability of a node $i\in\{1,\ldots,N\}$ winning the election is given by the “lottery” function $\phi(\alpha\_i)$ , where $\alpha\_i$ is the relative stake of node $i$ .

Observation process: the outcome of the election for node $i$ is observed with the probability $q$ .

Statistical inference: we define the log-likelihood $\mathcal{L} =\sum\_{t=1}^T\sum\_{i=1}^N \eta\_i(t)\log P\_i(s\_i(t))$ , where $s\_i(t)=1/0$ is the outcome of the election for node $i$ at time-slot t, $P\_i(1)=\phi(\alpha\_i)$ and $\eta\_i(t)=1/0$ for observed/unobserved $s\_i(t)$ .

Maximisation of $\mathcal{L}$ , subject to constraint $\sum\_{i=1}^N \alpha\_i=1$ , gives the ML estimator of relative stake $\hat{\alpha}\_i$ which is a solution of the equation $\phi(\alpha\_i)=\hat{P}\_i(1)/ \left(1 +\frac{\lambda}{\log \! \left({1-f} \right)\sum\_{t=1}^T\eta\_i(t)}\right)$ for $\alpha\_i$ .

Here  $\hat{P}\_i(1)=\sum\_{t=1}^T\eta\_i(t)\,\delta\_{1;s\_i(t)}/\sum\_{\tilde{t}=1}^T\eta\_i(\tilde{t})$ , i.e. the number of 1’s observed divided by the total number of observations, and $\lambda$ is a parameter which ensures that $\sum\_{i=1}^N \hat{\alpha}\_i=1$ .

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F98250dc2-c074-4bf3-87a0-abb2fb00e0cc%2FScreenshot_2024-02-19_at_19.41.53.png?table=block&id=1fd261aa-09df-8172-bfe5-ef28fe794a44&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=740&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The leader election and observation processes. Node $i$ participates in the leader election (or ``lottery'') at times $t\_1,\ldots,t\_T$ . The (binary) outcome of this lottery, where 0/1 corresponds to lost/won, is either observed (numbers in square brackets) or unobserved.

ALT

## Appendix

### Analysis of leader election process in proof of stake consensus model

Analysis\_of\_leader\_election\_process\_in\_PoS.pdf

326.3 KB

### Statistical inference of relative stake

Statistical\_inference\_of\_relative\_stake.pdf

314.7 KB

### Cardano Stake Distribution

Data was pulled from [Cexplorer](https://cexplorer.io/pool) to determine the stake value of every pool in Cardano

pools.csv

232.8KB

The histogram seems to shows it seems to follow a classic power law

![](/image/attachment%3A4271bbb8-014e-41bc-a557-4fa7db5d0da6%3AUntitled.png?table=block&id=256261aa-09df-8031-9b84-ddd45b836c7f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1180&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

#### Anomalies in the Distribution

Removing the low stakers from the distribution reveals a few peaks and a sharp decline after 70MM ADA:

![](/image/attachment%3A3a487737-b50c-483f-b524-38270dcde432%3AUntitled.png?table=block&id=256261aa-09df-8075-9212-cdf9ef738adf&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1090&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

These two peaks occur at 32.7MM ADA and 69.9MM ADA respectively.

Doing some research shows that Cardano has a concept of “Pool Saturation”, that is controlled by a global [“Saturation Parameter (](https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/) $k$ [)”](https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/). This parameter sets the target number of pools in the network. The target is enforced through a soft “stake cap”, i.e. a pool with 200 ADA when the stake cap is 100 ADA will earn the same rewards as a pool with 100 ADA.

Currently $k=500$ , this sets the stake cap at 64MM ADA. The IOHK blog posts suggest that there is a plan to move to $k=1000$ in the future, which would correspond to a stake cap of 32.7MM ADA.

We suspect the peak at ~70MM ADA we see in the data is the result of pool operators who are slightly over their target of 64MM but don’t yet feel the incentive to split into smaller pools.

The other peak at 32MM ADA likely corresponds to pools who are anticipating the switch to $k=1000$ and hoping to avoid any lost revenue due to the stake cap.

The sharp decline after 70MM ADA is likely explained by this Saturation Parameter incentivizing smaller pools.

The IOHK blog post announcing the change to $k=500$ and a plan to increase $k$ to 1000 in 2021 (didn’t seem to happen) <https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/>

Reddit discussion anticipating the change to $k=1000$ <https://www.reddit.com/r/cardano/comments/nfor5t/when_is_a_pools_saturation_too_high/>

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.0][Analysis] Cryptarchia De-anonymisation of Relative Stake

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-0-Analysis-Cryptarchia-De-anonymisation-of-Relative-Stake-1fd261aa09df8181a428f52251e173c4?pvs=26&qid=1:029e6087-d9b5-48f9-af17-70d81c873261:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.0][Analysis] Cryptarchia De-anonymisation of Relative Stake

Revision History

Table

Details of derivations are in the documents Statistical inference of relative stake and Analysis of leader election process in PoS.

Stake Distribution Strategies Based on Adversarial Inference Which Uses a Naive Estimator

- The adversary observes the leader election process of a node with the relative stake ΣEquation.
- In ΣEquation time slots, he/she is able to observe ΣEquation wins in ΣEquation observations.
- For ΣEquation he/she uses the naive estimator ΣEquation of the true relative stake ΣEquation.
- Here ΣEquation, known to adversary, is the fraction of time-slots with at least one winner.
- For “accuracy” ΣEquation, the probability that ΣEquation for large ΣEquation is given by ΣEquation where ΣEquation is the lottery function, ΣEquation and ΣEquation. Here ΣEquation is the fraction of observed time-slots such that ΣEquation slots are observed on average.
- An example of above probability is given below.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F694d7ce0-ede2-44dc-ac13-5ad0bb78b47d%2Fadver_conf.png?table=block&id=1fd261aa-09df-8183-a4bc-d76c2e3a9dee&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

- Having estimated the fraction of observed time-slots ΣEquation and accuracy ΣEquation a node can use its stake ΣEquation, to compute the probability ΣEquation, i.e. the “confidence” obtained by an adversary in ΣEquation time-slots. For a node, it is beneficial to reduce the latter, which can be done by distributing its stake among a number of nodes. To this end, the probability ΣEquation is compared with some threshold ΣEquation and if ΣEquation then the stake is divided, i.e. ΣEquation, ΣEquation, etc., until ΣEquation.
- The main functions of the algorithm which uses ΣEquation to distribute the stake are as follows:

from math import erf, sqrt, log
def phi(alpha):
global f
return 1 - (1 - f)\*\*alpha
def dphi(alpha):
global f
return -((1 - f)\*\*alpha) \* log(1 - f)
def Prob2(alpha, epsilon, T, q):
sqrt2 = sqrt(2.0)
numerator = -2.0 \* erf(sqrt2 \* epsilon / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q))))
denominator = (-erf(phi(alpha) \* sqrt2 / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q)))) + erf(sqrt2 \* (phi(alpha) - 1) / (2 \* sqrt(phi(alpha) \* (1 - phi(alpha)) / (T \* q)))))
return numerator / denominator

- The above functions are then used to find minimum number of nodes such that distributing the stake into these nodes reduces the probability ΣEquation to ΣEquation as follows

import math
# Define parameters
T = 432000 # number of time-slots in one epoch
theta = 0.5 # adversarial confidence threshold
gamma0 = 0.1 # adversarial accuracy
a = 0.3 # fraction of compromised paths in the mixnet
r = 3 # redundancy in messages sent through the mixnet
q0 = 1 - (1 - a)\*\*r # fraction of compromised messages
f = 0.05
n\_max = 10 # maximum number of iterations
alpha0 = 0.0126 #initial stake
# Initialize relative stake alpha and delta
alpha = alpha0
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
# Loop until delta <= theta or n reaches n\_max
n = 2
while delta > theta and n <= n\_max:
alpha = alpha0 / n
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
n += 1
# Update alpha and Prob
alpha = alpha0 / (n - 1)
epsilon = dphi(alpha) \* alpha \* gamma0
delta = Prob2(alpha, epsilon, T, q0)
print("Final num. of nodes:", n-1)
print("Final alpha:", alpha)
print("Final Prob:", delta)

- The above program suggests that the stake ΣEquation has to be divided among 5 nodes for the adversarial confidence ΣEquation when ΣEquation of paths in the mixnet are compromised (this is ΣEquation, where ΣEquation is the number of layers, with a mixnet sampled from ΣEquation nodes with ΣEquation adversarial nodes) and each message is sent ΣEquation times giving ΣEquation for the fraction of messages being compromised.

Analysis of Naive Estimator

- The naive estimator of relative stake ΣEquation is obtained from the maximum likelihood (ML) estimator by setting ΣEquation.
- The probability that ΣEquation, where ΣEquation is true relative stake and ΣEquation is “accuracy”, is given by ΣEquation, where ΣEquation is the binomial distribution of number of observations ΣEquation, with the parameter ΣEquation such that ΣEquation is the average number of observations, and ΣEquation is the binomial distribution of the number of observed wins n, with the parameter ΣEquation such that ΣEquation is the average number of observed wins.
- The probability of ΣEquation can be interpreted as “confidence”. The probability that ΣEquation, given by ΣEquation, is also of interest. However, for ΣEquation, which can happen for short observation times ΣEquation, the estimator ΣEquation (and hence the probability of ΣEquation) can be considered only for long observation times ΣEquation where the probability of the event ΣEquation is small.
- The bounds and (large time T) asymptotic estimates on the probability ΣEquation, as well as on the probability ΣEquation, can be obtained by adopting the results in Analysis of leader election process in proof of stake consensus model.

Numerical Results

The maximum likelihood (ML) estimator performance is dependent on the fraction of observed nodes ΣEquation (or the mixnet failure probability) and the number of slots ΣEquation. The [erformance of the estimator improves as ΣEquation increases, as can be seen in this plot:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fdc35a820-24ee-46d5-908e-4c81a59bf899%2Ftest-3.png?table=block&id=1fd261aa-09df-8189-ad5e-e7965070d1c6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The performance of ML estimators was also evaluated using the Jaccard Index. The index evaluates the estimators’ ability to correctly classify nodes as “high” or “low” stake. The simulation was done across multiple mixnet failure probabilities ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F16f34084-639b-4742-b076-7eee8d749975%2FUntitled.png?table=block&id=1fd261aa-09df-81a5-8cd6-cf7500aba079&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Analysis was also done using Cardano’s real world stake values. Clearly, Cardano’s stake distribution incentives somehow seem to protect against inferring top 1pct of stakers. More analysis is needed:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fba83f13e-bfeb-4c0e-9729-aa68993b3739%2FUntitled.png?table=block&id=1fd261aa-09df-811e-9438-cf3f54ecafdd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Analysis of ML Estimator: Inference of Lagrange Multiplier

The naive estimator above assumed the Lagrange multiplier, which ensures that inferred relative stake is normalized , ΣEquation. A more sophisticated estimator can be derived from the ML framework by inferring ΣEquation for a given sample.

The Lagrange multiplier ΣEquation is inferred by minimizing the distance between the LHS and RHS of equation (18) :

📈Equation

In the above, the “distance” used is the relative entropy. Computing the partial derivative w.r.t. ΣEquation gives us a gradient which we can then follow using gradient descent, or any other algorithm which uses a gradient, to discover the choice of ΣEquation which minimizes the above distance.

Inferred Distributions of Relative Stake

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F36dfbc9c-79fd-4296-ad0e-699582def54f%2FUntitled.png?table=block&id=1fd261aa-09df-8126-a553-fb355c86555e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F4c7fb880-f8ef-49ce-86d1-9591494aa57a%2FUntitled.png?table=block&id=1fd261aa-09df-8187-b929-f3a06054bc52&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F17aa62f5-a89d-486e-ae1a-8b0fdcdea827%2FUntitled.png?table=block&id=1fd261aa-09df-81f1-a6bc-c1b6a738f4fa&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Here ΣEquation is the fraction of observed time-slots (or the “mixnet failure probability”) out of the total ΣEquation time-slots. The small, grad and naive above refer to the ΣEquation approximation, the inferred ΣEquation, and the ΣEquation estimators respectively. The inferred ΣEquation estimator produces a smoother distribution for small ΣEquation. The small and naive estimators produce near identical inferred distributions.

The Total of Inferred Relative Stake

The sum of all relative stake (by definition) must sum to 1. Here we plot the error in inferred total stake for the different estimators:

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fa01ea93f-8888-47e6-bafc-f277e4195532%2FUntitled.png?table=block&id=1fd261aa-09df-815c-b327-d891eb11dedd&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Classification Performance

Despite the reduced error in total relative stake inference, and the smoother histogram, the naive estimator performed identically to the inferred ΣEquation estimator when tasked to identify the top stakers of the distribution.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F2bac2ff4-0567-4be6-9f9a-b26115264ad6%2FUntitled.png?table=block&id=1fd261aa-09df-8193-8101-cf37ca124398&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F09fdb70d-e76c-498e-98c1-dd16dac1a0d7%2FUntitled.png?table=block&id=1fd261aa-09df-8104-8020-e551eef13573&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Estimator Accuracy

Here we measure the accuracy of estimators. The left plot shows inferred vs true relative stake for one simulation, right plot shows mean squared error between inferred and true relative stakes. We find that both naive and inferred ΣEquation estimators produce similar results.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F9e70c117-a48a-4418-84c9-3fa32018ffa8%2FUntitled.png?table=block&id=1fd261aa-09df-819c-91c5-f922fc5c7be3&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2Fcabbaf04-2327-45c0-9dbd-04ff4047d032%2FUntitled.png?table=block&id=1fd261aa-09df-81f7-8fd6-e3015ff84aff&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Statistical Inference of Relative Stake

- Leader election process: at time-slot ΣEquation the probability of a node ΣEquation winning the election is given by the “lottery” function ΣEquation, where ΣEquation is the relative stake of node ΣEquation.
- Observation process: the outcome of the election for node ΣEquation is observed with the probability ΣEquation.
- Statistical inference: we define the log-likelihood ΣEquation , where ΣEquation is the outcome of the election for node ΣEquation at time-slot t, ΣEquation and ΣEquation for observed/unobserved ΣEquation.
- Maximisation of ΣEquation, subject to constraint ΣEquation, gives the ML estimator of relative stake ΣEquation which is a solution of the equation ΣEquation for ΣEquation.
- Here ΣEquation, i.e. the number of 1’s observed divided by the total number of observations, and ΣEquation is a parameter which ensures that ΣEquation.

![](/image/https%3A%2F%2Fprod-files-secure.s3.us-west-2.amazonaws.com%2F1518abd9-c08f-4989-93c1-96525e62bce5%2F98250dc2-c074-4bf3-87a0-abb2fb00e0cc%2FScreenshot_2024-02-19_at_19.41.53.png?table=block&id=1fd261aa-09df-8172-bfe5-ef28fe794a44&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Appendix

Analysis of leader election process in proof of stake consensus model

📎File

Statistical inference of relative stake

📎File

Cardano Stake Distribution

Data was pulled from Cexplorer to determine the stake value of every pool in Cardano

📎File

The histogram seems to shows it seems to follow a classic power law

![](/image/attachment%3A4271bbb8-014e-41bc-a557-4fa7db5d0da6%3AUntitled.png?table=block&id=256261aa-09df-8031-9b84-ddd45b836c7f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Anomalies in the Distribution

Removing the low stakers from the distribution reveals a few peaks and a sharp decline after 70MM ADA:

![](/image/attachment%3A3a487737-b50c-483f-b524-38270dcde432%3AUntitled.png?table=block&id=256261aa-09df-8075-9212-cdf9ef738adf&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

These two peaks occur at 32.7MM ADA and 69.9MM ADA respectively.

Doing some research shows that Cardano has a concept of “Pool Saturation”, that is controlled by a global “Saturation Parameter (ΣEquation)”. This parameter sets the target number of pools in the network. The target is enforced through a soft “stake cap”, i.e. a pool with 200 ADA when the stake cap is 100 ADA will earn the same rewards as a pool with 100 ADA.

Currently ΣEquation, this sets the stake cap at 64MM ADA. The IOHK blog posts suggest that there is a plan to move to ΣEquation in the future, which would correspond to a stake cap of 32.7MM ADA.

We suspect the peak at ~70MM ADA we see in the data is the result of pool operators who are slightly over their target of 64MM but don’t yet feel the incentive to split into smaller pools.

The other peak at 32MM ADA likely corresponds to pools who are anticipating the switch to ΣEquation and hoping to avoid any lost revenue due to the stake cap.

The sharp decline after 70MM ADA is likely explained by this Saturation Parameter incentivizing smaller pools.

- The IOHK blog post announcing the change to ΣEquation and a plan to increase ΣEquation to 1000 in 2021 (didn’t seem to happen) https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/
- Reddit discussion anticipating the change to ΣEquation https://www.reddit.com/r/cardano/comments/nfor5t/when\_is\_a\_pools\_saturation\_too\_high/

- Open in new tab
