---
title: NOMOS-FORK-CHOICE
name: Nomos Fork Choice
status: raw
tags: nomos
editor:
contributors:
- Jimmy Debe <jimmy@status.im>
---

## Abstract

This document describes the consensus mechanism of the fork choice rule,
followed by nodes in the Cryptarchia protocol.
Cryptarchia implements two fork choice rules,
one during node bootstrapping
and the second fork choice once a node is connected to the network.

## Background/Motivation

In blockchain networks,
the consensus process may encounter multiple competing branches(forks) of the blockchain state.
A Nomos node maintains a local copy of the blockchain state and
connects to a set of peers to download new blocks.

During bootstrapping, Cryptarchia v1 implements [Ouroboros Genesis](https://eprint.iacr.org/2018/378.pdf) and
[Ouroboros Praos](https://eprint.iacr.org/2017/573.pdf) for the fork choice mechanism.
These translate to two fork choice rules,
the bootstrap rule and the online rule.
This approach is meant to help nodes defend against malicious peers feeding false chains to download.
This calls for a more expensive fork choice rule that can differentiate between malicious long-range attacks and
the honest chain.

### The Long Range Attack

The protocol has a time window for a node, which is the **lottery** leader winner,
to complete a new block.
Nodes with more stake have a higher probability of being selected through the **lottery**.
The **lottery difficulty** is determined by protocol parameters and the node's stake.
The leadership lottery difficulty will adjust dynamically
based on the total stake that is participating in the consensus at the time.
The scenario, which NOMOS-FORK-CHOICE solves,
is when an adversary forks the chain and
generates a very sparse branch where he is the only winner for an epoch.
This fork would be very sparse
since the attacker does not control a large amount of stake initially.

Each epoch,
the lottery difficulty is adjusted
based on participation in the previous epoch to maintain a target block rate.
When this happens on the adversary’s chain,
the lottery difficulty will plummet and
he will be able to produce a chain that has a similar growth rate to the main chain.
The advantage is that his chain is more efficient.
Unlike the honest chain,
which needs to deal with unintentional forks caused by network delays,
the adversary’s branch has no wasted blocks.

With this advantage,
the adversary can eventually make up for that sparse initial period and
extend his fork until it’s longer than the honest chain.
He can then convince bootstrapping nodes to join his fork,
where he has had a monopoly on block rewards.

#### Genesis Fork Choice Rule Mitigation

When the honest branch and the adversary branch are in the period immediately following the fork,
the honest chain is dense and
the adversary’s fork will be quite sparse.
If an honest node had seen the adversary’s fork in that period,
it would not have followed this fork since the honest chain would be longer,
so selecting the fork using the longest chain rule is fine for a short-range fork.

If an honest node sees the adversary’s fork after he’s completed the attack,
the longest chain rule is no longer enough to protect them.
Instead, the node can look at the density of both chains in that short period after they diverge and
select the chain with the higher density of blocks.

#### Praos Fork Choice Rule Mitigation

Under two assumptions:

1. A node has successfully bootstrapped and found the honest chain.
2. Nodes see honest blocks reasonably quickly.

Nodes will remain on the honest chain if they reject forks that diverge further back than $k$ blocks,
without further inspection.
In order for an adversary to succeed,
they would need to build a $k$-deep chain faster than the time it takes the honest nodes to grow the honest chain by $k$ blocks.
The adversary must build this chain live,
alongside the honest chain.
They cannot build this chain after-the-fact,
since online nodes will be rejecting any fork that diverges before their $k$-deep block.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document is to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Definitions

- $k$ : safety parameter, i.e., the depth at which a block is considered immutable
- $s_{gen}$ : sufficient time measured in slots to measure the density of block production with enough statistical significance.

In practice, $s_{gen} = \frac{k}{4f}$, where $f$ is the active slot coefficient from the leader lottery,
see [Theorem 2 of Badertscher et al., 2018 “Ouroborus Genesis”](https://eprint.iacr.org/2018/378.pdf)
for more information.

- $$\textbf{CommonPrefixDepth}(b_1, b_2) \rightarrow (\mathbb{N}, \mathbb{N})$$

Returns the minimum block depth at which the two branches converge to a common chain.

Examples:

1. $$\textbf{CommonPrefixDepth}(b_1, b_2) = (0, 4)$$
implies that $b_2$ is ahead of $b_1$ by 4 blocks

![image](./images/image1.jpeg)

2. $$\textbf{CommonPrefixDepth}(b_2, b_5) = (2, 3)$$
would represent a forking tree like the one illustrated below:

![image2](./images/commonprefix2.jpeg)

3. $$\textbf{density}(b_i, d, s_{gen})$$

![image3](./images/density.jpeg)

Returns the number of blocks produced in the $s$ slots following block $b_{i-d}$.
For example, in the following diagram,
count the number of blocks produced in the $s_{gen}$ slots of the highlighted area.

### Bootstrap Fork Choice Rule

During bootstrapping, the Ouroboros Genesis fork choice rule (`maxvalid-bg`)

```python

def bootstrap_fork_choice(c_local, forks, k, s_gen):
    c_max = c_local
    for c_fork in forks:
        depth_max, depth_fork = common_prefix_depth(c_max, c_fork):
        if depth_max <= k:
            # the fork depth is less than our safety parameter `k`. It's safe
            # to use longest chain to decide the fork choice.
            if depth_max < depth_fork
                # strict inequality to ensure to choose first-seen chain as the tie break
                c_max = c_fork
        else:
            # here the fork depth is larger than our safety parameter `k`.
            # It's unsafe to use the longest chain here, instead check the density
            # of blocks immediately after the divergence.
            if density(c_max, depth_max, s_gen) < density(c_fork, depth_fork, s_gen):
                # The denser chain immediately after the divergence wins.
                c_max = c_fork

```

### Online Fork Choice Rule

When `bootstrap-rule` is complete,
a node SHOULD switch to the `online-rule`,
see [CRYPTARCHIA-V1-BOOTSTRAPPING-SYNCHRONIZATION](./bootstrap.md)
for more information on bootstrapping.
With the `online-rule` flag,
the node SHOULD now reject any forks that diverge further back than $k$ blocks.

```python
def online_fork_choice(c_local, forks, k):
    c_max = c_local
    for c_fork in forks:
        depth_max, depth_fork = common_prefix_depth(c_max, c_fork):
        if depth_max <= k:
            # the fork depth is less than our safety parameter `k`. It's safe
            # to use the longest chain to decide the fork choice.
            if depth_max < depth_fork
                # strict inequality to ensure to choose the first-seen chain as our tie break
                c_max = c_fork
        else:
            # The fork depth is larger than our safety parameter `k`.
            # Ignore this fork.
            continue

```

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## Reference

- [Ouroboros Genesis](https://eprint.iacr.org/2018/378.pdf)
- [Ouroboros Praos](https://eprint.iacr.org/2017/573.pdf)
- [CRYPTARCHIA-V1-BOOTSTRAPPING-SYNCHRONIZATION](./bootstrap.md)
