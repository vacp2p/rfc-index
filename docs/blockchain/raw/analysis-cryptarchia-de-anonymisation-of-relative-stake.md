# ANALYSIS-CRYPTARCHIA-DE-ANONYMISATION-OF-RELATIVE-STAKE

| Field | Value |
| --- | --- |
| Name | [Analysis] Cryptarchia De-anonymisation of Relative Stake |
| Slug | 189 |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Alexander Mozeika <alexander.mozeika@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-27** — [`b7602ed`](https://github.com/logos-co/logos-lips/blob/b7602ed8a225d41ca0bfaaa432524dc84d2ded7e/docs/blockchain/raw/analysis-cryptarchia-de-anonymisation-of-relative-stake.md) — chore: move blockchain specs from notion to github

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-08-26 |

Details of derivations are in the documents [Statistical inference of relative stake](#statistical-inference-of-relative-stake-1) and [Analysis of leader election process in PoS](#analysis-of-leader-election-process-in-proof-of-stake-consensus-model).

# Stake Distribution Strategies Based on Adversarial Inference Which Uses a Naive Estimator

- The adversary observes the leader election process of a node with the relative stake $\alpha$.
- In $T$ time slots, he/she is able to observe $n$ wins in $m$ observations.
- For $m\geq1$  he/she uses the naive estimator $`\hat{\alpha}=\frac{\log\left(1-n/m\right)}{\log(1-f)}`$ of the true relative stake $\alpha$.
- Here $f$, known to adversary, is the fraction of time-slots with at least one winner.
- For “accuracy” $\gamma\in(0,1)$, the probability that $`\alpha(1-\gamma)\leq\hat{\alpha}\leq\alpha(1+\gamma)`$ for large $T$ is [given by](https://www.overleaf.com/read/xvgmfchdhgzh#acd15d) $`\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\right)=\frac{2 \,\mathrm{erf}\! \left(\frac{ \epsilon}{\sqrt{2\sigma^2(q)}}\right)}{\mathrm{erf}\! \left(\frac{s }{ \sqrt{2\sigma^2(q)}}\right)+\mathrm{erf}\! \left(\frac{ 1-s}{ \sqrt{2\sigma^2(q)}}\right)},`$ where $s\equiv\phi(\alpha)$ is the lottery function, $`\epsilon=\gamma\alpha\frac{\mathrm{d}}{\mathrm{d}\alpha}\phi(\alpha)`$ and $`\sigma^2(q)=s(1-s)/T q`$. Here $q$ is the fraction of observed time-slots such that $Tq$ slots are observed on average.
- An example of above probability is given below.

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8183-a4bc-d76c2e3a9dee.png)

> <sub>The probability  that inferred relative stake $`\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]`$, i.e. adversarial “confidence”,  as a function of the true relative stake $`\alpha`$ obtained in $`T=432000`$ time-slots (the number used in Cardano) when fraction $`q=0.657`$ of slots is observed. Here the probability that the stake of a node with the true stake $`\alpha=0.0126`$ (the max. stake in the Bitcoin network), represented by a red vertical line, is inferred  with an “accuracy” within the fraction $`\gamma=0.1`$ of relative stake $`\alpha`$, represented by $`\alpha(1\pm\gamma)`$ red vertical dotted lines, is approx. $`0.824`$.  The red dashed horizontal line corresponds to the threshold $`\theta=0.5`$. The blue vertical line at $`\alpha=0.00252`$ is the result of dividing the stake $`\alpha=0.0126`$ into $`5`$ nodes.</sub>

- Having estimated the fraction of observed time-slots $q$ and accuracy $\gamma$ a node can use its stake $\alpha$, to compute the probability $`\delta(\alpha)=\mathrm{P}\left(\hat{\alpha}\in[\alpha(1-\gamma), \alpha(1+\gamma)]\right)`$, i.e. the “confidence”  obtained by an adversary in $T$ time-slots.  For a node, it is beneficial to reduce the latter, which can be done by distributing its stake among a number of nodes. To this end, the probability $\delta(\alpha)$ is compared with some threshold $\theta$ and if $\delta(\alpha)\geq\theta$ then the stake is divided, i.e. $\alpha\leftarrow\alpha/2$, $\alpha\leftarrow\alpha/3$, etc., until $`\delta(\alpha) \lt \theta`$.
- The main functions of the algorithm which uses $\delta(\alpha)$ to distribute the stake are as follows:

```python
from math import erf, sqrt, log

def phi(alpha):
global f
    return 1 - (1 - f)**alpha

def dphi(alpha):
global f
    return -((1 - f)**alpha) * log(1 - f)
def Prob2(alpha, epsilon, T, q):    
    sqrt2 = sqrt(2.0)
    numerator = -2.0 * erf(sqrt2 * epsilon / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q))))
    denominator = (-erf(phi(alpha) * sqrt2 / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))) + erf(sqrt2 * (phi(alpha) - 1) / (2 * sqrt(phi(alpha) * (1 - phi(alpha)) / (T * q)))))
return numerator / denominator
```

- The above functions are then used to find minimum number of nodes such that distributing the stake into these nodes reduces the probability $\delta(\alpha)$ to $\theta$ as follows

```python
import math

# Define parameters
T = 432000 # number of time-slots in one epoch
theta = 0.5 # adversarial confidence threshold
gamma0 = 0.1 # adversarial accuracy
a = 0.3 # fraction of compromised paths in the mixnet
r = 3 # redundancy in messages sent through the mixnet
q0 = 1 - (1 - a)**r  # fraction of compromised messages
f = 0.05
n_max = 10 # maximum number of iterations
alpha0 = 0.0126 #initial stake 
# Initialize relative stake alpha and delta
alpha = alpha0
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)
# Loop until delta <= theta or n reaches n_max
n = 2
while delta > theta and n <= n_max:
    alpha = alpha0 / n
    epsilon = dphi(alpha) * alpha * gamma0
    delta = Prob2(alpha, epsilon, T, q0)
    n += 1
# Update alpha and Prob
alpha = alpha0 / (n - 1)
epsilon = dphi(alpha) * alpha * gamma0
delta = Prob2(alpha, epsilon, T, q0)
print("Final num. of nodes:", n-1)
print("Final alpha:", alpha)
print("Final Prob:", delta)
```

- The above program suggests that the stake $\alpha=0.0126$ has to be divided among 5 nodes for the adversarial confidence $`\delta(\alpha) \lt 0.5`$ when $0.3$ of paths in the mixnet are compromised (this is $80\times 3$, where $3$ is the number of layers, with a mixnet sampled from $800$ nodes with $400$ adversarial nodes) and each message is sent $3$ times giving $0.657$ for the fraction of messages being compromised.

# Analysis of Naive Estimator

- The naive estimator of relative stake $`\hat{\alpha}_i=\frac{\log\left(1-\hat{P}_i(1)\right)}{\log(1-f)}`$ is obtained from the maximum likelihood (ML) estimator by setting $\lambda=0$.
- The probability that $`\alpha_i-\epsilon\leq\hat{\alpha}_i\leq\alpha_i+\epsilon`$, where $`\alpha_i`$ is true relative stake and $\epsilon$ is “accuracy”, is given by   $`P\left(\phi_f(\alpha_i-\epsilon)\,m\leq n \leq \phi_f(\alpha_i+\epsilon)\,m\vert m \gt 0\right)=\sum_{m=1}^T\sum_{n=0}^m\frac{P\left(m\vert T \right)P\left(n\vert m \right)}{1-(1-q)^T} 1\left[\phi_f(\alpha_i-\epsilon)\,m\leq n \leq \phi_f(\alpha_i+\epsilon)\,m\right]`$, where $P\left(m\vert T \right)$ is the binomial distribution of number of observations $m$, with the parameter $q$ such that $q\,T$ is the average number of observations, and $P\left(n\vert m \right)$ is the binomial distribution of the number of observed wins n, with the parameter $`\phi_f(\alpha_i)`$ such that $`\phi_f(\alpha_i)\, m`$ is the average number of observed wins.
- The probability of $`\alpha_i-\epsilon\leq\hat{\alpha}_i\leq\alpha_i+\epsilon`$ can be interpreted as “confidence”. The probability that $`\alpha_i-\epsilon\leq\hat{\alpha}_i`$, given by $`P\left(\phi_f(\alpha_i-\epsilon)\,m\leq n\vert m \gt 0\right)`$, is also of interest. However, for $`\hat{P}_i(1) \gt f`$, which can happen for short observation times  $T$,  the estimator $`\hat{\alpha}_i \gt 1`$ (and hence the probability of $`\alpha_i-\epsilon\leq\hat{\alpha}_i`$) can be considered only for long observation times $T$ where the probability of the event $`\hat{\alpha}_i \gt 1`$ is small.
- The bounds and (large time T) asymptotic estimates on the probability   $`P\left(\phi_f(\alpha_i-\epsilon)\,m\leq n \leq \phi_f(\alpha_i+\epsilon)\,m\vert m \gt 0\right)`$, as well as on the probability $`P\left(\phi_f(\alpha_i-\epsilon)\,m\leq n\vert m \gt 0\right)`$, can be obtained by adopting the results in [Analysis of leader election process in proof of stake consensus model](#analysis-of-leader-election-process-in-proof-of-stake-consensus-model).

## Numerical Results

The maximum likelihood (ML) estimator performance is dependent on the fraction of observed nodes $q$ (or the mixnet failure probability) and the number of slots  $T$. The [erformance of the estimator improves as  $T$ increases, as can be seen in this plot:

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8189-ad5e-e7965070d1c6.png)

> <sub>The (naive) ML estimator, given by the frequency of elections won, as a function of the number of slots $`T`$ plotted for a number of nodes with relative stakes $`\alpha`$.  Here on average the fraction $`q=0.8`$ of slots was observed.</sub>

The performance of ML estimators was also evaluated using the [Jaccard Index](https://en.wikipedia.org/wiki/Jaccard_index). The index evaluates the estimators’ ability to correctly classify nodes as “high” or “low” stake. The simulation was done across multiple mixnet failure probabilities $q$.

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-81a5-8cd6-cf7500aba079.png)

> <sub>The  performance of the (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here the N=2000 stake values were drawn from the $`\text{Pareto}(m=2, s=1)`$ distribution and T=432000. For q close 1, i.e. all nodes are observed, most high stake nodes are inferred correctly (Jaccard index is close to 1). As q (i.e. fraction of observed nodes) decreases, the accuracy decreases and for  $`q \gt 10^{-2}`$ is significantly reduced (Jaccard index is close to 0).</sub>

Analysis was also done using Cardano’s real world stake values. Clearly, Cardano’s stake distribution incentives somehow seem to protect against inferring top 1pct of stakers. More analysis is needed:

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-811e-9438-cf3f54ecafdd.png)

> <sub>The performance of (non-naive) ML estimator in classifying validators, measured by the Jaccard index, in the top 1pct of stakers as a function of the fraction of observed nodes, q. Here T=432000 and  N=2500 stake values were obtained from [Cardano](#cardano-stake-distribution).</sub>

# Analysis of ML Estimator: Inference of Lagrange Multiplier

The naive estimator above assumed the Lagrange multiplier, which ensures that inferred relative stake is normalized , $\lambda=0$. A more sophisticated estimator can be derived from the ML framework by inferring $\lambda$ for a given sample.

The Lagrange multiplier $\lambda$ is inferred by minimizing the distance between the LHS and RHS of [equation](#statistical-inference-of-relative-stake-1) (18) :

$$
D(1-f ||  \prod_{i=1}^N\left[1-\hat{\phi}_i(\lambda)\right])
$$

In the above, the “distance” used is the relative entropy. Computing the partial derivative w.r.t. $\lambda$ gives us a gradient which we can then follow using gradient descent, or any other algorithm which uses a gradient, to discover the choice of $\lambda$ which minimizes the above distance.

Inferred Distributions of Relative Stake

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8126-a553-fb355c86555e.png)

> <sub>Relative stake obtained in 1000 inferences for stake distribution drawn from $`\text{Pareto}(2,1)`$<br>$`q=1`$</sub>

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8187-b929-f3a06054bc52.png)

> <sub>$`q=0.1`$</sub>

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-81f1-a6bc-c1b6a738f4fa.png)

> <sub>$`q=0.01`$</sub>

Here $q$ is the fraction of observed time-slots (or the “mixnet failure probability”)  out of the total $T=432,000$ time-slots.  The  small, grad and naive above refer to the $\lambda \rarr 0$ approximation, the inferred $\lambda$, and the $\lambda=0$ estimators respectively. The inferred $\lambda$ estimator produces a smoother distribution for small $q$. The  small and naive estimators produce near identical inferred distributions.

The Total of Inferred Relative Stake

The sum of all relative stake (by definition) must sum to 1. Here we plot the error in inferred total stake for the different estimators:

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-815c-b327-d891eb11dedd.png)

> <sub>Plotting the squared distance to 1 of the sum of inferred relative stakes. The inferred $`\lambda`$ estimator produces a much lower and constant error across $`q`$ values on this metric.</sub>

Classification Performance

Despite the reduced error in total relative stake inference, and the smoother histogram, the naive estimator performed identically to the inferred $\lambda$ estimator when tasked to identify the top stakers of the distribution.

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8193-8101-cf37ca124398.png)

> <sub>We ask the question: given the top 10% of *inferred* stakers, is the *true* top staker among those inferred top 10%.<br>Naive and grad estimators performed identically at this task.</sub>

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8104-8020-e551eef13573.png)

> <sub>Plot of the Jaccard Index: J(inferred 90th pct, true 90th pct). High Jaccard index tells us there is a high degree of overlap between the two sets, low index tells us that the sets are nearly disjoint.</sub>

Estimator Accuracy

Here we measure the accuracy of estimators. The left plot shows inferred vs true relative stake for one simulation, right plot shows mean squared error between inferred and true relative stakes. We find that both naive and inferred $\lambda$ estimators produce similar results.

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-819c-91c5-f922fc5c7be3.png)

> <sub>X-axis is the true relative stake, Y-axis is the inferred relative stake. Perfect inference would produce the solid black line. All estimators perform nearly identically.<br>Simulation parameters:<br>$`q=0.5`$, $`f=0.05`$, $`T=432,000`$<br>stake distribution=np.linspace(1, 100, 1000)</sub>

Simulation parameters:
$`q=0.5`$, $`f=0.05`$, $`T=432,000`$

Simulation parameters:
$`q=0.5`$, $`f=0.05`$, $`T=432,000`$
![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-81f7-8fd6-e3015ff84aff.png)

> <sub>Plotting the Mean Squared Error (i.e. average squared distance between true and inferred relative stake pairs) against $`q`$.<br>Simulation Parameters:<br>$`f=0.05, T=432,000`$<br>stake distribution = Cardano</sub>

Simulation Parameters:
$`f=0.05, T=432,000`$

Simulation Parameters:
$`f=0.05, T=432,000`$
## Statistical Inference of Relative Stake

- Leader election process: at time-slot $t$ the probability of a node $`i\in\{1,\ldots,N\}`$ winning the election is given by the “lottery” function $`\phi(\alpha_i)`$, where $`\alpha_i`$ is the relative stake of node $i$.
- Observation process: the outcome of the election for node $i$ is observed with the probability $q$.
- Statistical inference: we define the log-likelihood $\mathcal{L}
=\sum_{t=1}^T\sum_{i=1}^N \eta_i(t)\log P_i(s_i(t))$ , where $s_i(t)=1/0$  is the outcome of the election for node $i$ at time-slot t, $P_i(1)=\phi(\alpha_i)$ and $\eta_i(t)=1/0$ for observed/unobserved $s_i(t)$.
- Maximisation of $`\mathcal{L}`$, subject to constraint $`\sum_{i=1}^N \alpha_i=1`$, gives the ML estimator of relative stake $`\hat{\alpha}_i`$ which is a solution of the equation $`\phi(\alpha_i)=\hat{P}_i(1)/ \left(1 +\frac{\lambda}{\log \! \left({1-f} \right)\sum_{t=1}^T\eta_i(t)}\right)`$ for $`\alpha_i`$.
- Here $`\hat{P}_i(1)=\sum_{t=1}^T\eta_i(t)\,\delta_{1;s_i(t)}/\sum_{\tilde{t}=1}^T\eta_i(\tilde{t})`$, i.e. the number of 1’s observed divided by the total number of observations, and $\lambda$ is a parameter which ensures that  $`\sum_{i=1}^N \hat{\alpha}_i=1`$.

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/1fd261aa-09df-8172-bfe5-ef28fe794a44.png)

> <sub>The leader election and observation processes. Node $`i`$ participates in the leader election (or ``lottery'') at times $`t_1,\ldots,t_T`$. The (binary) outcome of this lottery,  where 0/1 corresponds to lost/won, is either *observed* (numbers in square brackets) or *unobserved*.</sub>

# Appendix

## Analysis of leader election process in proof of stake consensus model

> **File attachment:** [Analysis_of_leader_election_process_in_PoS.pdf](analysis-cryptarchia-de-anonymisation-of-relative-stake/appendices/Analysis_of_leader_election_process_in_PoS.pdf)

## Statistical inference of relative stake

> **File attachment:** [Statistical_inference_of_relative_stake.pdf](analysis-cryptarchia-de-anonymisation-of-relative-stake/appendices/Statistical_inference_of_relative_stake.pdf)

## Cardano Stake Distribution

Data was pulled from [Cexplorer](https://cexplorer.io/pool) to determine the stake value of every pool in Cardano

> **File attachment:** [pools.csv](analysis-cryptarchia-de-anonymisation-of-relative-stake/appendices/pools.csv)

The histogram seems to shows it seems to follow a classic power law

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/256261aa-09df-8031-9b84-ddd45b836c7f.png)

### Anomalies in the Distribution

Removing the low stakers from the distribution reveals a few peaks and a sharp decline after 70MM ADA:

![Diagram](analysis-cryptarchia-de-anonymisation-of-relative-stake/assets/256261aa-09df-8075-9212-cdf9ef738adf.png)

These two peaks occur at 32.7MM ADA and 69.9MM ADA respectively.

Doing some research shows that Cardano has a concept of “Pool Saturation”, that is controlled by a global [“Saturation Parameter (](https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/)$k$[)”](https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/). This parameter sets the target number of pools in the network. The target is enforced through a soft “stake cap”, i.e. a pool with 200 ADA when the stake cap is 100 ADA will earn the same rewards as a pool with 100 ADA.

Currently $k=500$, this sets the stake cap at 64MM ADA. The IOHK blog posts suggest that there is a plan to move to $k=1000$ in the future, which would correspond to a stake cap of 32.7MM ADA.

We suspect the peak at ~70MM ADA we see in the data is the result of pool operators who are slightly over their target of 64MM but don’t yet feel the incentive to split into smaller pools.

The other peak at 32MM ADA likely corresponds to pools who are anticipating the switch to $k=1000$ and hoping to avoid any lost revenue due to the stake cap.

The sharp decline after 70MM ADA is likely explained by this Saturation Parameter incentivizing smaller pools.

- The IOHK blog post announcing the change to $k=500$ and a plan to increase $k$ to 1000 in 2021 (didn’t seem to happen) [https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/](https://iohk.io/en/blog/posts/2020/11/05/parameters-and-decentralization-the-way-ahead/)
- Reddit discussion anticipating the change to $k=1000$ [https://www.reddit.com/r/cardano/comments/nfor5t/when_is_a_pools_saturation_too_high/](https://www.reddit.com/r/cardano/comments/nfor5t/when_is_a_pools_saturation_too_high/)
