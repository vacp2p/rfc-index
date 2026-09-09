# PROOF-OF-WORK

| Field | Value |
| --- | --- |
| Name | Proof of Work |
| Slug | 245 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski <marcin@logos.co> |
| Contributors |  |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

# Revision History

| **Version** | **Changes** | **Date** |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-09-09 |

# Introduction

Two things in Bedrock are out of reach for a newcomer. Sending a message through the Blend network requires a quota, and a quota comes from being a declared core node with locked stake or from winning the leadership lottery. Holding stake requires tokens, and the protocol gives a newcomer none: tokens are bought from someone who has them, outside the protocol and outside its privacy. A participant who arrives with nothing therefore cannot use the privacy layer and cannot earn a first balance.

Proof of work removes both obstacles. A participant who has computed a puzzle solution may use it to send a Blend message, and may claim a small reward for it from a pool of tokens set aside at genesis. Neither use needs stake, a declaration, or a counterparty. The cost is the computation, which any machine can perform, and a solution is worth exactly what it cost to find: it cannot be faked, since a valid ticket proves the work, and a validator checks it with one hash.

The two uses share the puzzle and nothing else. They are measured against separate thresholds that follow separate objectives: the reward threshold keeps the number of paid claims per block near a target whatever the amount of mining, and the Blend threshold keeps admission to the network affordable when the network is quiet and dearer when it is busy. This document specifies the puzzle, the two thresholds, the reward pool and the reward it pays per claim, and the window within which a reward may be claimed. The Blend side of the mechanism is specified in [Proof of Quota](proof-of-quota.md) and the claim Operation in [Mantle](bedrock-v1.1-mantle-specification.md#claim_pow_reward); this document holds what both depend on.

# Overview

**The puzzle.** A solution is a number whose ticket is small enough. The ticket is a `zkhash` of the number and the epoch nonce, the random value that Cryptarchia fixes for every epoch. A hash cannot be predicted, so the only way to find a solution is to try numbers until one works, and the smaller the threshold, the more tries it takes on average. The two uses search different numbers:

- For Blend admission the number is a private nonce, and the threshold is `difficulty_blend`. The prover shows inside the Proof of Quota circuit that it knows such a nonce, without revealing it, and the solution pays for exactly one message.
- For the reward the number is a public key, the hash of a recent block is added to the ticket, and the threshold is `difficulty_reward`. The miner submits a claim naming the key, the block and the epoch nonce, signed with the key; every validator recomputes the ticket, and the reward is paid to the key.

**The reward pool.** The tokens paid to claims come from a pool seeded at genesis with a fixed fraction of the maximum supply. Nothing is minted for it, and nothing refills it. Each epoch distributes a fixed fraction of what the pool holds, split into a reward per claim that stays the same for the whole epoch, so a claimant knows what a claim is worth before submitting it. If claims outrun the pool, claiming stops until the next epoch begins with a smaller reward computed from what is left.

**Two thresholds, two clocks.** `difficulty_reward` is updated after every block, so that about ten claims are accepted per block whatever the amount of mining: more claims than that make the puzzle harder, fewer make it easier. `difficulty_blend` is updated once per epoch from the number of transactions the blocks carried: a busier network makes admission harder and a quieter one easier, by at most a factor of two per epoch. Both are consensus state that every node computes from the chain, so no node trusts another for them.

**Freshness.** A reward claim must name a block from the recent past, about ten blocks, so a solution cannot be stockpiled and claimed later. A Blend solution is bound only to its epoch, and the epoch nonce is known before the epoch starts, so Blend solutions may be prepared ahead of time.

# Protocol

## The puzzle

A ticket is `zkhash` over the searched value and the epoch nonce; for a reward claim the hash of the referenced block is added between them. Tickets and thresholds are elements of the field of the hash, and a ticket satisfies a threshold when, both read as integers, the ticket is strictly below the threshold. A threshold is therefore at most the field modulus minus one.

## Reward claims

A claim is a Mantle Operation carrying the epoch nonce it was mined against, the hash of the referenced block and the public key, signed with that key's secret key. A validator accepts it when the pool can pay the reward of the epoch, the referenced block is canonical and within the acceptance window, the epoch nonce is the current or the previous one, the ticket is below `difficulty_reward`, the ticket has not been claimed before, and the signature verifies; the checks are specified in [Mantle](bedrock-v1.1-mantle-specification.md#claim_pow_reward). On acceptance the ticket is recorded as spent, a note of the reward's value is created for the key, and the pool falls by the same amount.

## Reward pool and reward per claim

At genesis the pool holds five thousandths of the maximum supply. At each epoch boundary the reward per claim for the coming epoch is computed as one two-hundredth of the pool, divided by the number of claims an epoch accepts at the target rate: ten per block over the expected number of blocks in an epoch. The reward is held for the whole epoch, and the pool falls by one reward per accepted claim.

## Steering the reward threshold

After every block, `difficulty_reward` is updated from the number of claims the block included, so that the accepted rate is steered toward the target. The update smooths the observed count against the target with weights nine to one, so a single unusual block moves the threshold little, and the result is capped at the field modulus minus one. The claims of a block are validated against the threshold the previous block produced. Genesis sets the first threshold to the field modulus divided by $`2^{26}`$.

## Steering the Blend threshold

`difficulty_blend` for an epoch is fixed when that epoch's nonce is, during the preceding epoch, from the transaction load of the last complete epoch, and it is held for the whole epoch. At the reference load of 512 transactions per block the threshold is its base value; a heavier load lowers it and a lighter load raises it, in proportion to the square root of the load ratio, by at most a factor of two per epoch. The first two epochs use the base value. The base is calibrated so that a solution takes about 38 seconds in expectation on one core of a Raspberry Pi 5.

## Claim freshness

A claim must reference a canonical block at most 300 slots older than the block including the claim, which is ten blocks in expectation. A spent ticket needs to be remembered only while its referenced block is within the window.

# Details

## Notation

| Symbol | Name | Description | Value |
| --- | --- | --- | --- |
| $`p`$ | field modulus | Modulus of the scalar field $`\mathbb{F}_p`$ of [Poseidon2](common-cryptographic-components.md#poseidon2-zk-friendly-hash-function); tickets and thresholds are its elements. | [Common Cryptographic Components](common-cryptographic-components.md) |
| $`\eta`$ | epoch nonce | The per-epoch random value of [Epoch Nonce](cryptarchia-v1-protocol.md#epoch-nonce). | |
| $`d_{reward}`$ | reward threshold | `difficulty_reward`, updated after every block. | $`p / 2^{26}`$ at genesis |
| $`d_{blend}`$ | Blend threshold | `difficulty_blend`, fixed once per epoch. | $`p / 2^{19}`$ at the reference load |
| $`T`$ | target claims per block | `TARGET_CLAIMS_PER_BLOCK`, the accepted rate the reward threshold steers toward. | $`10`$ |
| $`\rho`$ | distribution rate | `EPOCH_POW_DISTRIBUTION_RATE_NUM / EPOCH_POW_DISTRIBUTION_RATE_DEN`, the fraction of the pool an epoch distributes at the target rate. | $`1/200`$ |
| $`N_b`$ | expected blocks per epoch | `EXPECTED_BLOCKS_PER_EPOCH`, the epoch length in slots times $`f`$. | $`10k = 21{,}600`$ |
| $`\sigma_e`$ | reward per claim | `epoch_pow_reward` of epoch $`e`$. | $`\lfloor \rho \cdot \mathrm{pool} / (T \cdot N_b) \rfloor`$ |
| $`S_{cap}`$ | maximum supply | The hard cap of [Block Rewards](block-rewards.md). | |
| $`W_b`$ | window depth | `EXPECTED_BLOCKS_PER_WINDOW`, the acceptance window in expected blocks. | $`10`$ |
| $`f`$ | slot activation coefficient | The probability that a slot has a leader, from [Constants](cryptarchia-v1-protocol.md#constants). | $`1/30`$ |
| $`k`$ | security parameter | From [Constants](cryptarchia-v1-protocol.md#constants). | $`2160`$ |
| $`F`$, $`P`$ | smoothing factor and precision | The reward update weighs the previous estimate $`F`$ out of $`P`$. | $`9`$, $`10`$ |
| $`\alpha = a / b`$ | damping exponent | The Blend update's response to the load ratio. | $`1/2`$ |

## Parameters

```python
POW_REWARD_POOL_GENESIS: TokenValue             # 5/1000 of S_cap, set in the Genesis Block
EPOCH_POW_DISTRIBUTION_RATE_NUM: uint64 = 1     # rho, as a fraction NUM / DEN
EPOCH_POW_DISTRIBUTION_RATE_DEN: uint64 = 200
TARGET_CLAIMS_PER_BLOCK: uint64 = 10            # T
EXPECTED_BLOCKS_PER_EPOCH: uint64 = 21_600      # N_b = 10 k
EXPECTED_BLOCKS_PER_WINDOW: uint64 = 10         # W_b
EMA_SMOOTHING_FACTOR: uint64 = 9                # F, the weight given to the previous estimate
EMA_SMOOTHING_PRECISION: uint64 = 10            # P, the scale F is expressed against; F < P
BLEND_DIFFICULTY_BASE: PowTarget = p // 2**19   # d_blend at the reference load
TARGET_TXS_PER_BLOCK: uint64 = 512              # Reference transactions per block
BLEND_DAMPING_NUM: uint64 = 1                   # a, where the exponent is alpha = a / b
BLEND_DAMPING_DEN: uint64 = 2                   # b, with 0 < a <= b so that alpha <= 1
BLEND_MAX_STEP: uint64 = 2                      # Max factor d_blend may move per epoch
```

`EXPECTED_BLOCKS_PER_EPOCH` is the epoch length in slots of [Epoch Schedule](cryptarchia-v1-protocol.md#epoch-schedule) times $`f`$; a change to either changes it here identically. The constants are mainnet values; a test network may substitute values sized to its expected activity. The parameters must give an `epoch_pow_reward` above the fee of a claim transaction; otherwise a claim cannot pay its own fee.

## Puzzle Target

`PowTarget` is an element of $`\mathbb{F}_p`$, as every ticket is. A ticket satisfies a target when its canonical integer representative in $`[0, p-1]`$ is strictly below the target's; a smaller target is a harder puzzle. The two updates below multiply and divide targets as arbitrary-precision integers, the exception to the fixed-width arithmetic of [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic), and cap their result at $`p - 1`$, so that it converts back to a field element without reduction.

## Reward Pool

The pool is seeded once, at genesis, with `POW_REWARD_POOL_GENESIS`, five thousandths of $`S_{cap}`$, as specified in [Bedrock Genesis Block](bedrock-genesis-block.md). After that it changes only through claims.

```python
def compute_epoch_pow_reward(pow_reward_pool: TokenValue) -> TokenValue:
    denominator = (EPOCH_POW_DISTRIBUTION_RATE_DEN
                   * TARGET_CLAIMS_PER_BLOCK
                   * EXPECTED_BLOCKS_PER_EPOCH)
    return (pow_reward_pool * EPOCH_POW_DISTRIBUTION_RATE_NUM) // denominator
```

At each epoch boundary, before any block of the new epoch is processed, `epoch_pow_reward` is set to `compute_epoch_pow_reward(pow_reward_pool)` and held for the epoch. The division rounds down, and the remainder stays in the pool. All arithmetic here is checked, in accordance with [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic).

### Exhaustion within an epoch

The reward is fixed for the epoch while the pool shrinks with every claim. The first condition of [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) validation, that the reward is positive and the pool covers it, is evaluated for every claim against the pool as it stands at that point in the block, and a claim it rejects invalidates its transaction. Claiming resumes at the next epoch boundary at which the recomputed reward is positive and the pool covers it.

## Acceptance Window

$$
\mathrm{WINDOW} = \left\lfloor \frac{W_b}{f} \right\rfloor
$$

With $`W_b = 10`$ and $`f = 1/30`$, `WINDOW` is $`300`$ slots. A claim's referenced block must be canonical and at most `WINDOW` slots older than the block including the claim; the check is step 2 of [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) validation. A nullifier may be discarded once the block its claim referenced has left the window.

## Reward Difficulty

```python
def compute_new_reward_difficulty(claims_in_block: uint64,
                                  current_target: PowTarget) -> PowTarget:
    # Arbitrary-precision integers over canonical representatives; see Puzzle Target.
    # The demand implied by this block, reconstructed from the target that produced
    # it and smoothed against the target rate; floored at 1 so the division is defined.
    demand = max(1, (EMA_SMOOTHING_PRECISION - EMA_SMOOTHING_FACTOR) * claims_in_block
                    + EMA_SMOOTHING_FACTOR * TARGET_CLAIMS_PER_BLOCK)
    new_target = (TARGET_CLAIMS_PER_BLOCK * current_target
                  * EMA_SMOOTHING_PRECISION) // demand
    return min(new_target, p - 1)
```

`claims_in_block` counts the `CLAIM_POW_REWARD` Operations the block includes. Every claim in a block is validated against the target produced by the previous block's update; the update from a block's own count is applied after the block is processed and governs the next block. At genesis `difficulty_reward` is the scalar field modulus divided by $`2^{26}`$.

## Blend Difficulty

The value for epoch $`N`$ is computed at the lottery-constants snapshot of epoch $`N-1`$ specified in [Epoch](cryptarchia-v1-protocol.md#epoch), the moment epoch $`N`$'s nonce is fixed, from the blocks of epoch $`N-2`$, and is the public input `pow_blend_difficulty` of [Proof of Quota](proof-of-quota.md) for the whole of epoch $`N`$. For epochs 0 and 1 it is `BLEND_DIFFICULTY_BASE`; the schedule begins with epoch 2, computed during epoch 1 from epoch 0's blocks.

```python
def compute_epoch_blend_difficulty(epoch_blocks: list[Block],   # the blocks of epoch N-2
                                   previous: PowTarget) -> PowTarget:  # d_blend of epoch N-1
    # Arbitrary-precision integers over canonical representatives; see Puzzle Target.
    # Observed load as an exact ratio: num == den at the reference load.
    num = sum(num_transactions(b) for b in epoch_blocks)
    den = TARGET_TXS_PER_BLOCK * len(epoch_blocks)

    lo = previous // BLEND_MAX_STEP
    hi = min(previous * BLEND_MAX_STEP, p - 1)

    if num == 0:
        return hi   # No load observed: as permissive as this epoch's clamp allows.

    # A smaller target is harder, so load divides the baseline:
    #     target = BASE / load ** alpha
    # Only the final root is floored, so the result is at most one unit from exact.
    a, b = BLEND_DAMPING_NUM, BLEND_DAMPING_DEN
    radicand = (BLEND_DIFFICULTY_BASE ** b * den ** a) // num ** a
    return clamp(integer_nth_root(radicand, b), lo, hi)

def integer_nth_root(x: int, n: int) -> int:
    # The floor of the real n-th root: the largest integer r with r**n <= x.
    # Any exact method serves; this reference is a binary search.
    lo, hi = 0, 1 << (x.bit_length() // n + 1)   # hi**n > x by construction
    while lo < hi - 1:
        mid = (lo + hi) // 2
        if mid ** n <= x:
            lo = mid
        else:
            hi = mid
    return lo
```

`previous` is the value computed one snapshot earlier. `BLEND_DIFFICULTY_BASE` is calibrated against a measurement of the work itself: about 38 seconds per solution in expectation on one core of the target machine, a Raspberry Pi 5, measured on that hardware.
