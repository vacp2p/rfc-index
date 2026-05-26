# FORK-CHOICE

| Field | Value |
| --- | --- |
| Name | Cryptarchia Fork Choice Rule |
| Slug | 147 |
| Status | raw |
| Category | Standards Track |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Jimmy Debe <jimmy@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-30** — [`0ef87b1`](https://github.com/logos-co/logos-lips/blob/0ef87b1ba9491c854e48c8dfd7574d34ec69c704/docs/blockchain/raw/fork-choice.md) — New RFC: CODEX-MANIFEST (#191)
- **2026-01-29** — [`a428c03`](https://github.com/logos-co/logos-lips/blob/a428c0370733bdeadc019952a49264443d27edd0/docs/blockchain/raw/fork-choice.md) — New RFC: NOMOS-FORK-CHOICE (#247)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-02-17 |

# Introduction

Cryptarchia makes use of two fork choice rules, one during bootstrapping and a second once a node completes bootstrapping and comes online.

During bootstrapping, we must be resilient to malicious peers feeding us false chains. This calls for a more expensive fork choice rule that can differentiate between malicious long-range attacks and the honest chain.

Once bootstrapping completes, the node commits to the best chain it has seen so far and switches to a different fork choice rule that rejects forks that diverge too much.

# Overview

During bootstrapping, we use the [Ouroboros Genesis](https://nomos-tech.notion.site/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df81e4a352dd365c9ebe8c) fork choice rule, after bootstrapping, we switch to the [Ouroboros Praos](https://nomos-tech.notion.site/21b261aa09df811584dfd362abb26627?pvs=25#21b261aa09df812caa08ce2f637a6278) fork choice rule.

To understand why we use the Genesis rule during bootstrapping, it’s useful to consider the long range attack.

## The Long Range Attack

The leadership lottery difficulty adjusts dynamically based on how much stake is participating in consensus.

The scenario we are worried about is where an attacker forks the chain and generates a very sparse branch where he is the only winner for an epoch. This fork would be very sparse since the attacker does not control a large amount of stake initially.

Each epoch, the lottery difficulty is adjusted based on participation in the previous epoch to maintain a target block rate. When this happens on the adversary’s chain, the lottery difficulty will plummet and he will be able to produce a chain that has similar growth rate to the main chain with the advantage that his chain is very efficient. Unlike the honest chain, which needs to deal with unintentional forks caused by network delays, the attacker’s branch has no wasted blocks.

With this advantage, the adversary can eventually make up for that sparse initial period and extend his fork until it’s longer than the honest chain. He can then convince bootstrapping nodes to join his fork where he has had a monopoly on block rewards.

### How This Attack is Mitigated by the Genesis Fork Choice Rule

If we look at the honest branch and the adversary branch in the period immediately following the fork, we can see that the honest chain is dense and the adversary’s fork will be quite sparse.

If an honest node had seen the adversary’s fork in that period, it would not have followed this fork since the honest chain would be longer, so selecting the fork using the longest chain rule is fine for a short range fork.

If an honest node sees the adversary’s fork after he’s completed the attack, the longest chain rule is no longer enough to protect them. Instead, the node can look at the density of both chains in that short period after they diverge and select the chain with the higher density of blocks.

### How This Attack is Mitigated by the Praos Fork Choice Rule

Under two assumptions:

1. A node has successfully bootstrapped and found the honest chain.
1. Nodes see honest blocks reasonably quickly.

Nodes will remain on the honest chain if they reject forks that diverge further back than $k$ blocks without further inspection. In order for an adversary to succeed, they would need to build a $k$-deep chain faster than the time it takes the honest nodes to grow the honest chain by $k$ blocks. The adversary must build this chain live, alongside the honest chain. They cannot build this chain after-the-fact since online nodes will be rejecting any fork that diverges before their $k$-deep block.

# Protocol

## Definitions

- $k$ : safety parameter, i.e. the depth at which a block is considered immutable
- $s_{gen}$ : sufficient time measured in slots to measure the density of block production with enough statistical significance.
    In practice, we say $s_{gen} = \lfloor\frac{k}{4f}\rfloor$, where $f$ is the active slot coefficient from the leader lottery. (see [Theorem 2 of Badertscher et al., 2018 “Ouroboros Genesis”](https://eprint.iacr.org/2018/378.pdf))
- $\textbf{common\_prefix\_depth}(b_1, b_2) \rarr (\mathbb{N},\mathbb{N})$​
    Returns the minimum block depth at which the two branches converge to a common chain.
    Examples:
    1. $\textbf{common\_prefix\_depth}(b_1, b_2) = (0, 4)$ implies that $b_2$ is ahead of $b_1$ by 4 blocks
        i.e. $4^{th}\text{-grandparent}(b_2)=b_1$​
        ![Diagram](https://nomos-tech.notion.site/image/attachment%3Af0819d8a-3b5d-46bf-93e0-01b461f8ffe3%3AScreenshot_2025-08-21_at_3.39.41_AM.png?table=block&id=21b261aa-09df-8127-b31d-e4d33743d675&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=830&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
    1. $\textbf{common\_prefix\_depth}(b_2, b_5) = (2, 3)$ would represent a forking tree like the one illustrated below
        $$
        2^{nd}\text{-grandparent}(b_2)=3^{rd}\text{-grandparent}(b_5)
        $$
        ![Diagram](https://nomos-tech.notion.site/image/attachment%3A445a5b52-3905-4371-8900-bfda3155cb8e%3AScreenshot_2025-08-21_at_3.42.56_AM.png?table=block&id=21b261aa-09df-8128-a35a-d2f0affc2031&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=830&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
- $\textbf{density}(b_i, d, s_{gen})$​
    Returns the number of blocks produced in the $s$ slots following block $b_{i-d}$.
    For example, in the following diagram, count the number of blocks produced in the $s_{gen}$ slots of the highlighted area.
    ![Diagram](https://nomos-tech.notion.site/image/attachment%3A47e985b3-9ed2-4cef-ae25-97327993c455%3AScreenshot_2025-05-23_at_12.02.42_PM.png?table=block&id=21b261aa-09df-81b3-a43c-d884eae8fce7&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1330&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Bootstrap Fork Choice Rule

During bootstrapping, we use the Ouroboros Genesis fork choice rule (maxvalid-bg)

```text
def bootstrap_fork_choice(c_local, forks, k, s_gen):
    c_max = c_local
    for c_fork in forks:
        depth_max, depth_fork = common_prefix_depth(c_max, c_fork):
if depth_max <= k:
# the fork depth is less than our safety parameter `k`. It's safe
# to use longest chain to decide the fork choice.
if depth_max < depth_fork
                # strict inequality to ensure we choose first-seen chain as our tie break
                c_max = c_fork
        else:
# here the fork depth is larger than our safety parameter `k`.
# It's unsafe to use longest chain here, instead we check the density
# of blocks immediately after the divergence.
if density(c_max, depth_max, s_gen) < density(c_fork, depth_fork, s_gen):
# The denser chain immediately after the divergence wins.
                c_max = c_fork
```

## Online Fork Choice Rule

During normal operations, we use the Ouroboros Praos fork choice rule (maxvalid-mc). Here we reject any forks that diverge further back than $k$ blocks.

```text
def online_fork_choice(c_local, forks, k):
    c_max = c_local
    for c_fork in forks:
        depth_max, depth_fork = common_prefix_depth(c_max, c_fork):
if depth_max <= k:
# the fork depth is less than our safety parameter `k`. It's safe
# to use longest chain to decide the fork choice.
if depth_max < depth_fork
                # strict inequality to ensure we choose first-seen chain as our tie break
                c_max = c_fork
        else:
# The fork depth is larger than our safety parameter `k`.
# Ignore this fork.
continue
```

# References

1. Ouroboros Genesis: Composable Proof-of-Stake Blockchains with
Dynamic Availability [eprint.iacr.org](https://eprint.iacr.org/2018/378.pdf)​
1. Ouroboros Praos: An adaptively-secure, semi-synchronous
proof-of-stake blockchain [eprint.iacr.org](https://eprint.iacr.org/2017/573.pdf)​

