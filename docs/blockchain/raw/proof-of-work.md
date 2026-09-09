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

This document specifies the proof of work of Bedrock: the puzzle, the two thresholds a solution is measured against, the reward pool that pays for solving it, and the window within which a reward may be claimed. The puzzle admits messages to the Blend network through the proof of work branch of [Proof of Quota](proof-of-quota.md), and earns a reward through the [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) Operation of Mantle.

# Overview

A puzzle solution is a value whose ticket, a `zkhash` of the value and an epoch nonce, is below a threshold. Two thresholds exist. Both are consensus state, derived from on-chain observations, so every node computes the same values.

- `difficulty_reward` gates reward claims. It is updated after every block toward a target number of accepted claims per block, as specified in [Reward Difficulty](#reward-difficulty). The ticket of a claim is derived from the public key the reward is paid to, a recent block hash and the epoch nonce, and is checked by Mantle.
- `difficulty_blend` gates the proof of work branch of the Proof of Quota. It is computed once per epoch from the transaction load, as specified in [Blend Difficulty](#blend-difficulty). The ticket is derived from a private nonce and the epoch nonce, and is checked in the circuit.

The reward pool is a reserve of tokens seeded at genesis and drawn down by claims. At each epoch boundary a reward per claim is computed from the pool and held for the whole epoch, as specified in [Reward Pool](#reward-pool). A claim must reference a recent block; how recent is specified in [Acceptance Window](#acceptance-window).

The state these rules maintain is listed in [Proof of Work Operations](bedrock-v1.1-mantle-specification.md#proof-of-work-operations).

| Value | Updated | Section |
| --- | --- | --- |
| `pow_reward_pool` | at genesis, and by every claim | [Reward Pool](#reward-pool) |
| `epoch_pow_reward` | at every epoch boundary | [Reward Pool](#reward-pool) |
| `difficulty_reward` | after every block | [Reward Difficulty](#reward-difficulty) |
| `difficulty_blend` | once per epoch, at the epoch nonce snapshot | [Blend Difficulty](#blend-difficulty) |

# Puzzle Target

`PowTarget` is an element of the scalar field $`\mathbb{F}_p`$ of [Poseidon2](common-cryptographic-components.md#poseidon2-zk-friendly-hash-function), as every ticket is. A ticket satisfies a target when its canonical integer representative in $`[0, p-1]`$ is strictly below the target's; a smaller target is a harder puzzle. The two updates below multiply and divide targets as arbitrary-precision integers, the exception to the fixed-width arithmetic of [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic), and cap their result at $`p - 1`$, so that it converts back to a field element without reduction.

# Reward Pool

The pool is seeded once, at genesis, with `POW_REWARD_POOL_GENESIS`, five thousandths of the maximum supply $`S_{cap}`$ of [Block Rewards](block-rewards.md), as specified in [Bedrock Genesis Block](bedrock-genesis-block.md). After that it changes only through claims.

The reward per claim is a fixed fraction of the pool, divided by the number of claims an epoch is expected to accept:

```python
EPOCH_POW_DISTRIBUTION_RATE_NUM: uint64 = 1     # rho, as a fraction NUM / DEN
EPOCH_POW_DISTRIBUTION_RATE_DEN: uint64 = 200
TARGET_CLAIMS_PER_BLOCK: uint64 = 10            # T, shared with Reward Difficulty
EXPECTED_BLOCKS_PER_EPOCH: uint64 = 21_600      # N_b

def compute_epoch_pow_reward(pow_reward_pool: TokenValue) -> TokenValue:
    denominator = (EPOCH_POW_DISTRIBUTION_RATE_DEN
                   * TARGET_CLAIMS_PER_BLOCK
                   * EXPECTED_BLOCKS_PER_EPOCH)
    return (pow_reward_pool * EPOCH_POW_DISTRIBUTION_RATE_NUM) // denominator
```

`EXPECTED_BLOCKS_PER_EPOCH` is the epoch length in slots of [Epoch Schedule](cryptarchia-v1-protocol.md#epoch-schedule) times the slot activation coefficient $`f`$, $`10k`$; a change to either changes it here identically. The constants are mainnet values; a test network may substitute values sized to its expected activity. The division rounds down, and the remainder stays in the pool.

At each epoch boundary, before any block of the new epoch is processed, the reward per claim is recomputed from the pool and held for the epoch:

```python
def on_epoch_boundary():
    epoch_pow_reward = compute_epoch_pow_reward(pow_reward_pool)
```

All arithmetic here is checked, in accordance with [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic).

The parameters must give an `epoch_pow_reward` above the fee of a claim transaction; otherwise a claim cannot pay its own fee.

## Exhaustion within an epoch

The reward is fixed for the epoch while the pool shrinks with every claim. The first condition of [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) validation, that the reward is positive and the pool covers it, is evaluated for every claim against the pool as it stands at that point in the block, and a claim it rejects invalidates its transaction. Claiming resumes at the next epoch boundary at which the recomputed reward is positive and the pool covers it.

# Acceptance Window

A claim references a recent block by hash. The reference is accepted when the block is canonical and at most `WINDOW` slots older than the block including the claim; the check is step 2 of [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) validation.

```python
EXPECTED_BLOCKS_PER_WINDOW: uint64 = 10   # W_b: window depth, in expected blocks
```

$$
\mathrm{WINDOW} = \left\lfloor \frac{W_b}{f} \right\rfloor
$$

where $`f`$ is the slot activation coefficient of [Constants](cryptarchia-v1-protocol.md#constants). With $`W_b = 10`$ and $`f = 1/30`$, `WINDOW` is $`300`$ slots.

A nullifier may be discarded once the block its claim referenced has left the window, since the claim can no longer be accepted.

# Reward Difficulty

`difficulty_reward` is updated after every block, steering the number of accepted claims per block toward `TARGET_CLAIMS_PER_BLOCK`:

```python
EMA_SMOOTHING_FACTOR: uint64 = 9      # F, the weight given to the previous estimate
EMA_SMOOTHING_PRECISION: uint64 = 10  # P, the scale F is expressed against; F < P

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

# Blend Difficulty

`difficulty_blend` is the threshold of the proof of work branch of [Proof of Quota](proof-of-quota.md), where it is the public input `pow_blend_difficulty`. It is computed once per epoch and held fixed for the whole epoch. The value for epoch $`N`$ is fixed at the same moment as epoch $`N`$'s nonce, the lottery-constants snapshot taken during epoch $`N-1`$ as specified in [Epoch](cryptarchia-v1-protocol.md#epoch), from the transaction load of epoch $`N-2`$. For epochs 0 and 1 it is `BLEND_DIFFICULTY_BASE`; the schedule begins with epoch 2, computed during epoch 1 from epoch 0's load.

At the reference load the threshold is `BLEND_DIFFICULTY_BASE`; above it admission tightens and below it admission loosens, by at most a factor of `BLEND_MAX_STEP` per epoch:

```python
BLEND_DIFFICULTY_BASE: PowTarget = p // 2**19   # Threshold at the reference load
TARGET_TXS_PER_BLOCK: uint64 = 512              # Reference transactions per block
BLEND_DAMPING_NUM: uint64 = 1                   # a, where the exponent is alpha = a / b
BLEND_DAMPING_DEN: uint64 = 2                   # b, with 0 < a <= b so that alpha <= 1
BLEND_MAX_STEP: uint64 = 2                      # Max factor the threshold may move per epoch

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
