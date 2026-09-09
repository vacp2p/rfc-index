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
| 1.1.0 | Set the reference load of the Blend difficulty to the transaction rate the Blend network carries, `F_T / F_D = 130` transactions per block | 2026-09-09 |

# Introduction

This document specifies the proof of work machinery of Bedrock: the target type, the reward pool that [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) pays from, and the two difficulty controllers, `difficulty_reward` for the reward and `difficulty_blend` for the proof of work branch of [Proof of Quota](proof-of-quota.md). The state these sections maintain is listed in [Proof of Work Operations](bedrock-v1.1-mantle-specification.md#proof-of-work-operations).

# Proof of Work Target

`PowTarget` is a scalar field element, and every operation on one is defined over its **canonical integer representative** in $`[0, p-1]`$. A field has no order and no floor division, so neither the ticket comparison nor the controller arithmetic in [Reward Difficulty](#reward-difficulty) and [Blend Difficulty](#blend-difficulty) is field arithmetic: a ticket is accepted when its representative is strictly below the target's, and targets are multiplied and floor-divided as arbitrary-precision integers. A **smaller** target is a **harder** puzzle.

The controller arithmetic is the exception to the checked fixed-width arithmetic of [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic): the reward retarget's intermediate product reaches about $`2^{261}`$, and the Blend retarget's radicand about $`2^{487}`$, so both are computed in a big-integer type. The field element is converted to its canonical integer representative, all arithmetic is performed in that type, and only the result is converted back. Each controller caps its result below $`p`$, so the conversion back never reduces modulo $`p`$.

# Reward Pool

The reward per claim is a fixed fraction of the pool, divided by the number of claims an epoch is expected to accept:

```python
EPOCH_POW_DISTRIBUTION_RATE_NUM: uint64 = 1     # rho, as a fraction NUM / DEN
EPOCH_POW_DISTRIBUTION_RATE_DEN: uint64 = 200
TARGET_CLAIMS_PER_BLOCK: uint64 = 10      # T
EXPECTED_BLOCKS_PER_EPOCH: uint64 = 21_600      # N_b, derived below

def compute_epoch_pow_reward(pow_reward_pool: TokenValue) -> TokenValue:
    denominator = (EPOCH_POW_DISTRIBUTION_RATE_DEN
                   * TARGET_CLAIMS_PER_BLOCK
                   * EXPECTED_BLOCKS_PER_EPOCH)
    return (pow_reward_pool * EPOCH_POW_DISTRIBUTION_RATE_NUM) // denominator
```

`EXPECTED_BLOCKS_PER_EPOCH` is not a free choice and is not defined here: it is the **expected number of blocks in an epoch** defined in [Cryptarchia](cryptarchia-v1-protocol.md#epoch-schedule) — the epoch length times the slot activation rate, which reduces to $`10k = 21{,}600`$. The value is restated as a constant because this is where it enters consensus arithmetic, and a change to Cryptarchia's epoch length or activation rate changes it here identically. More generally, the constant values throughout this section are **mainnet values**; a test network may substitute values sized to its expected activity, provided the relations this section derives between them are preserved.

The division rounds down, and what the flooring withholds is not lost: it remains in the pool, to be counted again at the next boundary. `TARGET_CLAIMS_PER_BLOCK` is the same value the reward difficulty steers toward, so the two uses are consistent by construction: the reward is sized for the rate the controller is targeting.

At each epoch boundary, before any block of the new epoch is processed, the per-claim reward is recomputed from the pool:

```python
def on_epoch_boundary():
    epoch_pow_reward = compute_epoch_pow_reward(pow_reward_pool)
```

All arithmetic here is checked, in accordance with [Arithmetic](bedrock-v1.1-mantle-specification.md#arithmetic).

Fixing the reward for the whole epoch allows a wallet to compute a reward note's identifier before submitting a claim, and therefore what makes a self-funding claim possible at all. The pool is drawn down by claims within the epoch, but the per-claim value is not recomputed until the next boundary.

## Exhaustion within an epoch

The distribution rate is not a spending cap. $`\rho`$ divides the pool by the number of claims an epoch is *expected* to accept; it does not limit how many are accepted. Nothing stops a block from carrying more claims than the target, and nothing stops an epoch from paying out more than the fraction $`\rho`$ of its pool. Claims are paid, one after another, for as long as the pool can cover the next one, and are rejected from the moment it cannot.

The rejection is not a special case. It is the first condition of [CLAIM_POW_REWARD](bedrock-v1.1-mantle-specification.md#claim_pow_reward) validation, evaluated for every claim against the pool as it stands at that point in the block, so a block may contain claims that were accepted followed by claims that were rejected, and a claim that fails only because the pool is exhausted is an invalid Operation and its transaction is rejected whole.

At the specified constants no sequence of valid blocks can drain the pool within an epoch. The guard nevertheless remains normative, so that if a future change to `MAX_BLOCK_TXS` or to these constants reopened the path, the result would be that claiming stops, rather than that the pool goes negative or the protocol pays out tokens it does not hold.

Claiming recovers by itself. At the next epoch boundary `epoch_pow_reward` is recomputed from the pool, so a pool that was drained to a fraction of one reward yields a correspondingly smaller reward in the epoch that follows, and claiming resumes at that lower value. The mechanism degrades to a smaller reward rather than stopping permanently, and it stops permanently only when the pool falls so far that the recomputed reward rounds down to zero.

An epoch running at the target claim rate distributes exactly the fraction $`\rho`$ of the pool, whatever the target is set to; the target governs how many claims share the distribution, not its total.

`POW_REWARD_POOL_GENESIS` is set to **five thousandths of the maximum supply**. Its constraints and the relationship the three parameters must satisfy are given below and in [Genesis](#genesis).

The relationship the three must satisfy is that a claim's reward exceeds its fee.

# Genesis

The pool is seeded once, at genesis, with `POW_REWARD_POOL_GENESIS`, as specified in [Bedrock Genesis Block](bedrock-genesis-block.md). After that it changes only through claims.

The seed is **five thousandths of the maximum supply** $`S_{cap}`$, the hard cap of [Block Rewards](block-rewards.md).

# Reward Difficulty

`difficulty_reward` is part of consensus state and is updated **every block**, steering the number of accepted claims toward `TARGET_CLAIMS_PER_BLOCK`. It is independent of the Blend threshold used by [Proof of Quota](proof-of-quota.md), which is a per-epoch value and is never evaluated here.

```python
EMA_SMOOTHING_FACTOR: uint64 = 9      # F, the weight given to the previous estimate
EMA_SMOOTHING_PRECISION: uint64 = 10  # P, the scale F is expressed against; F < P

def compute_new_reward_difficulty(claims_in_block: uint64,
                                  current_target: PowTarget) -> PowTarget:
    # `current_target` and the result are canonical integer representatives of
    # their field elements; the arithmetic is over arbitrary-precision integers per
    # [Arithmetic], and the clamped result converts back without reduction.
    # The demand implied by this block, reconstructed from the target that
    # produced it, then smoothed against the target rate. Floored at 1 so the
    # division below is always defined, including when no claims arrived.
    demand = max(1, (EMA_SMOOTHING_PRECISION - EMA_SMOOTHING_FACTOR) * claims_in_block
                    + EMA_SMOOTHING_FACTOR * TARGET_CLAIMS_PER_BLOCK)
    new_target = (TARGET_CLAIMS_PER_BLOCK * current_target
                  * EMA_SMOOTHING_PRECISION) // demand
    # Capped so that converting back into the field cannot reduce modulo p and
    # turn a very easy target into a very hard one.
    return min(new_target, p - 1)
```

The ordering is part of consensus. Every claim in a block is validated against the target produced by the previous block's update; the update from a block's own accepted count is applied after the block is processed and governs the next block. Genesis supplies the value the first block is validated against.

The controller holds no state of its own beyond the current target. Rather than remembering a running estimate of demand, it reconstructs one from the target in force, on the assumption that the target was calibrated to the intended rate. This keeps it a single value in consensus state.

Two properties follow, and both matter for its safety. When a block accepts exactly the target number of claims the target is unchanged, so the intended rate is a fixed point. When a block accepts none, the numerator is floored at 1 and the target moves up by a factor of $`P/F`$ — bounded, and in the direction of making claiming easier, so a period without claims eases rather than locks. The smoothing means a single unusual block moves the target only slightly, so no separate per-block rate clamp is required.

The rate the controller observes is the rate of claims **included in blocks**, not the rate at which solutions are found. Solutions that are never included, because a block builder declined to include them or because block space was exhausted, are invisible to it. Difficulty therefore tracks accepted demand rather than offered demand, and the two diverge when block space is contended.

`difficulty_reward` is set at genesis to the scalar field modulus divided by $`2^{26}`$ — deliberately on the hard side, so that the controller's first move is to loosen: a genesis value too hard costs only the time the per-block easing takes to correct it, where one too permissive over-pays claims.

# Blend Difficulty

`difficulty_blend` is the threshold used by the proof of work branch of [Proof of Quota](proof-of-quota.md) to admit messages to the Blend network. It is consensus state and is maintained here, alongside the reward difficulty, because it must be agreed by every node and is derived from on-chain observations. It is never evaluated by any Operation.

The two difficulties are independent. They gate different things, are computed from different observations, and neither implies the other: a solution may satisfy one, both, or neither. Coupling them would force one objective to distort the other, since they are steering unrelated quantities.

Unlike the reward difficulty, `difficulty_blend` is recomputed **once per epoch** and held fixed for the whole epoch. This is required rather than a simplification: the value is a public input to the proof, so a value that changed within an epoch would partition that epoch's proofs into distinguishable classes and leak which participants produced which messages.

The value for epoch $`N`$ is fixed at the same moment as epoch $`N`$'s nonce — the lottery-constants snapshot taken during epoch $`N-1`$, as specified in [Epoch](cryptarchia-v1-protocol.md#epoch) — and its input is the transaction load of epoch $`N-2`$, the last epoch complete at that snapshot; publishing it with the nonce keeps the [precomputation window](proof-of-quota.md#precomputation-of-proof-of-work-solutions) usable. For the first two epochs no complete input epoch exists, so `difficulty_blend` is `BLEND_DIFFICULTY_BASE` for epochs 0 and 1, and the schedule begins with epoch 2, computed during epoch 1 from epoch 0's load. The same value applies at genesis: the network begins at `BLEND_DIFFICULTY_BASE` rather than at a guess about the first epoch's traffic.

The reference load is the transaction rate the Blend network carries, $`F_T / F_D = 130`$ transactions per block ([Global Parameters](blend-protocol.md#global-parameters)). At the reference load the threshold sits at a baseline; above it admission tightens, below it admission loosens.

```python
BLEND_DIFFICULTY_BASE: PowTarget = p // 2**19   # Threshold at the reference load
TARGET_TXS_PER_BLOCK: uint64 = 130              # Reference transactions per block, F_T / F_D
BLEND_DAMPING_NUM: uint64 = 1                   # a, where the exponent is alpha = a / b
BLEND_DAMPING_DEN: uint64 = 2                   # b, with 0 < a <= b so that alpha <= 1
BLEND_MAX_STEP: uint64 = 2                      # Max factor the threshold may move per epoch

def compute_epoch_blend_difficulty(epoch_blocks: list[Block],   # the blocks of epoch N-2
                                   previous: PowTarget) -> PowTarget:  # d_blend of epoch N-1
    # All quantities here are canonical integer representatives of their field
    # elements; the arithmetic is over arbitrary-precision integers per [Arithmetic], and
    # the capped result converts back to a field element without reduction.
    # Observed load as an exact ratio, never divided: num == den at the reference load.
    num = sum(num_transactions(b) for b in epoch_blocks)
    den = TARGET_TXS_PER_BLOCK * len(epoch_blocks)

    lo = previous // BLEND_MAX_STEP
    # Capped below the field modulus for the same reason as the reward retarget:
    # a target at or above p is no threshold at all, since every ticket is a
    # field element and would satisfy it.
    hi = min(previous * BLEND_MAX_STEP, p - 1)

    if num == 0:
        return hi   # No load observed: as permissive as this epoch's clamp allows.

    # A smaller target is harder, so load divides the baseline:
    #     target = BASE / load ** alpha
    # Every quantity is an integer and only the final root is floored, so the
    # result is at most one unit away from the exact value.
    a, b = BLEND_DAMPING_NUM, BLEND_DAMPING_DEN
    # The radicand reaches roughly 2**487 and is computed over unbounded
    # integers, per [Arithmetic]; no fixed-width type can carry it.
    radicand = (BLEND_DIFFICULTY_BASE ** b * den ** a) // num ** a
    return clamp(integer_nth_root(radicand, b), lo, hi)

def integer_nth_root(x: int, n: int) -> int:
    # The floor of the real n-th root: the largest integer r with r**n <= x.
    # Any exact method serves; this reference is a binary search over
    # arbitrary-precision integers.
    lo, hi = 0, 1 << (x.bit_length() // n + 1)   # hi**n > x by construction
    while lo < hi - 1:
        mid = (lo + hi) // 2
        if mid ** n <= x:
            lo = mid
        else:
            hi = mid
    return lo
```

The clamp interval is never empty: every stored value is capped below $`p`$, so `previous` is at most $`p-1`$ and `lo = previous // BLEND_MAX_STEP` is at most $`(p-1)/2`$, strictly below the $`p-1`$ ceiling of `hi`.

Computed once per epoch at the nonce snapshot of the preceding epoch, and applied from the first block of its epoch. `previous` is the value computed one snapshot earlier, so the chain of values is well defined without reference to any boundary state.

The upper clamp is capped at $`p-1`$ in addition to the per-epoch step bound. Without the cap, an idle network — every epoch observing no load and returning `hi` — would double the threshold each epoch and pass the field modulus after a few months of empty epochs, at which point every ticket would satisfy it and admission would be free. The reward controller bounds its result for the same reason, and the two failure modes are the same one.

Note what this controller cannot see. Its input is transactions included in blocks, so messages that are never included — including messages sent purely to consume Blend capacity — do not raise it. It regulates admission against observed chain load, not against network load, and is therefore not by itself a defence against flooding the Blend network with messages that never reach a block.

`BLEND_DIFFICULTY_BASE` is calibrated against a measurement of the work itself: about fifty seconds per solution on one core of the target machine, a Raspberry Pi 5, measured on that hardware.
