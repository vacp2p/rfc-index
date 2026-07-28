# Mix Cover Traffic

| Field | Value |
| --- | --- |
| Name | Mix Cover Traffic |
| Slug | 161 |
| Status | raw |
| Category | Standards Track |
| Editor | Prem Prathi <prem@status.im> |
| Contributors |  |

<!-- timeline:start -->

## Timeline

- **2026-05-11** — [`ae4c4a1`](https://github.com/logos-co/logos-lips/blob/ae4c4a11e4f7b0d09cbfd2333e22295d3df56582/docs/anoncomms/raw/mix-cover-traffic.md) — chore: split ift ts specs
- **2026-05-11** — [`2aa2bcd`](https://github.com/logos-co/logos-lips/blob/2aa2bcd89c58ccc4453207edeb8269e66a631b48/docs/ift-ts/raw/mix-cover-traffic.md) — feat: Mix Cover Traffic specification (#311)

<!-- timeline:end -->

## Abstract

This document specifies the cover traffic architecture for the [libp2p Mix Protocol](mix.md).
The architecture ensures that an observer cannot distinguish cover traffic from locally originated messages
by observing a node's emission pattern.
It defines how cover packets are generated and emitted,
how the rate-limit budget is shared across cover and non-cover traffic,
and specifies the Constant-Rate cover traffic strategy, with Poisson-Rate as a future consideration in §11.5.

## 1. Introduction

The Mix Protocol provides sender anonymity through layered encryption and per-hop delays.
However, without cover traffic,
an adversary observing a mix node's emission rate can mount several attacks:

- **Traffic analysis**: by correlating emission bursts with known events,
  an adversary can link a node's activity periods to specific senders or recipients.
- **Intersection attack**: by observing which nodes are active each time a message reaches its destination,
  an adversary can progressively narrow down the set of possible senders across multiple messages.
- **Timing correlation**: by matching idle and active periods across mix nodes,
  an adversary can correlate ingress and egress packets.

All three attacks rely on the same weakness:
a node's emission pattern leaks information about whether it is carrying non-cover traffic.

Cover traffic addresses this by ensuring a node's emission pattern does not depend on non-cover traffic volume,
making it indistinguishable to an observer whether the node is sending locally originated messages or none at all.

The Mix Protocol defines cover traffic as a pluggable component (see [Mix Protocol §6.4](mix.md#64-cover-traffic)).
This specification provides a concrete instantiation of that component,
defining the cover traffic architecture, the rate-limit budget model, and the Constant-Rate scheduling strategy.
An alternative Poisson-Rate strategy is documented as a future consideration in [§11.5](#115-poisson-rate-cover-traffic).
The architecture is designed to integrate with any DoS protection mechanism conforming to the [Mix DoS Protection](mix-dos-protection.md) interface,
and specifically with [Mix RLN DoS Protection](mix-dos-protection-rln.md)
and its stake-weighted extension [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md).

**Deployments without a DoS protection mechanism**:
This cover traffic mechanism MAY be used in deployments that do not enforce DoS protection.
In such deployments,
the DoS protection interface calls referenced throughout this specification (_e.g.,_ `GenerateProof`, `VerifyProof`, `OnEpochChange`) are treated as no-ops,
and `R_node`, `R_base`, and epoch boundaries are sourced directly from deployment configuration.
All nodes in such a deployment MUST use the same configured values for `R_node` and `R_base`
(typically `R_node = R_base`);
per-node local choice of these parameters is NOT permitted,
as it would break the cover-emission uniformity on which this specification's anonymity-set guarantees depend.

## 2. Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
in this document are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

Other terms used in this document are as defined in the [libp2p Mix Protocol](mix.md) and [Mix DoS Protection](mix-dos-protection.md).

The following additional terms are used throughout this specification:

- **Cover Packet**
  A dummy Sphinx packet that carries no application payload
  and is indistinguishable from non-cover Sphinx packets in structure, size, and routing behavior.

- **`R_node`**
  The node's own per-epoch rate-limit budget, exposed by the DoS protection mechanism for this specific node.
  Under [Mix RLN DoS Protection](mix-dos-protection-rln.md), `R_node` equals the messaging rate `R` configured for the deployment and is uniform across all nodes.
  Under [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md), `R_node` equals the node's `user_message_limit ∈ [R_min, R_max]` derived from its registered stake, and may differ across nodes.

- **`R_base`**
  The deployment-wide anchor rate per epoch, published in the DoS protection mechanism's deployment configuration.
  Identical across all nodes in the deployment.
  Under [Mix RLN DoS Protection](mix-dos-protection-rln.md), `R_base` equals the single configured messaging rate `R`.
  Under [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md), `R_base` is the parameter defined in its [System Parameters](mix-dos-protection-rln-stake-weighted.md#44-system-parameters).
  Every node satisfies `R_node ≥ R_base` by construction.

- **`R_cover`**
  The deployment-wide cover-emission budget per epoch, identical across all nodes.
  Derived as `R_cover = f × R_base` where `f` is the configured `cover_rate_fraction` (see [§5.5](#55-data-structures)).
  Since `f ≤ 1` and `R_node ≥ R_base` for every node, the invariant `R_cover ≤ R_node` holds by construction.

- **Slot**
  A single rate-limit token within an epoch's per-node budget of `R_node` tokens, as defined by the DoS protection mechanism.
  Each outgoing packet — whether cover or non-cover — consumes exactly one slot.

- **Slot Pool**
  The collection of rate-limit slots available for a given epoch.

- **Epoch**
  A fixed time window of duration `P` seconds during which each mix node is permitted to emit at most `R_node` packets,
  as enforced by the DoS protection mechanism.

## 3. Design Principles

The cover traffic architecture is guided by the following principles:

- **Sender unobservability**: A node's emission pattern must not depend on non-cover traffic volume,
  making it indistinguishable to an observer whether the node is carrying non-cover traffic or not.
- **Indistinguishability**: Cover packets are structurally identical to non-cover Sphinx packets in size and routing behavior,
  preventing packet-level classification. ([Mix Protocol §6.4](mix.md#64-cover-traffic))
- **Self-exit**: Cover packets SHOULD use loop paths where the originating node is also the exit node.
  This ensures the dummy payload is never decrypted by an external party,
  eliminating the risk of cover classification at the exit.
- **DoS protection compliance**: Cover emission operates within `R_cover ≤ R_node`,
  ensuring cover never exceeds any node's per-epoch rate-limit budget.
  Proofs are epoch-bound and unused slots are discarded at epoch boundaries. ([Mix DoS Protection](mix-dos-protection.md))
- **Slot integrity**: Each rate-limit slot is consumed at most once on the wire per epoch.
  When a non-cover claim reclaims a slot held by a queued cover packet,
  that packet's pre-computed proof is discarded before the slot is reused.
- **Mix node only**: Cover traffic is generated only for mix nodes that act as intermediate nodes forwarding mix traffic
  and participate continuously in the network.
  Initiating-only nodes are mostly short-lived with dynamic identifiers and do not forward traffic,
  making cover traffic neither practical nor beneficial for them.
- **Pre-computation**: As an optimization, cover packets and their proofs MAY be generated during epoch `N-1`,
  so they are ready to emit at the start of epoch `N` without any cryptographic work at emission time.

## Overview

A mix node plays multiple roles at once: it sends its own messages, relays messages for other nodes, and ideally hides which of these it is doing.
Without protection, an observer watching the node's outgoing packets can tell when it is active, how busy it is, and when it is idle —
enough to link users to their messages through traffic patterns.

Cover traffic addresses this by emitting additional dummy packets that look identical to real mix traffic from the outside.
An observer still sees packets leaving the node,
but can no longer tell from the pattern alone whether those packets are real or dummy.

The node operates under a per-node rate-limit budget `R_node` per epoch,
exposed by the deployment's DoS protection mechanism ([§4](#4-rate-limit-budget-model)).
`R_node` may be uniform across all nodes (e.g. flat [Mix RLN DoS Protection](mix-dos-protection-rln.md))
or differentiated across nodes (e.g. [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md), where `R_node` is derived from registered stake).
Every packet — cover, locally originated, or forwarded — consumes one slot from `R_node`.
Forwarding typically takes a large share because each originated packet traverses multiple hops,
so the maximum cover rate is naturally bounded below `R_node`.

Each node draws cover from a uniform deployment-wide slot budget `R_cover = f × R_base` per epoch, identical across all nodes,
where `R_base` is the deployment anchor rate published by the DoS protection mechanism
and `f ∈ (0.0, 1.0]` is the configured `cover_rate_fraction` ([§7.1](#71-constant-rate-cover-traffic)).
`R_cover ≤ R_node` for every node by construction,
so cover never displaces the capacity that origination and forwarding need.
Lower `f` reduces `R_cover`, leaving correspondingly more of the `R_node` pool available to non-cover.
Locally originated and forwarded traffic claim slots from the same `R_node` pool as they arrive;
cover yields whatever slots remain when those slots are needed.

Cover packets follow round-trip paths — the sender is also the final destination,
so the dummy payload is never decrypted by another party ([§5.1](#51-cover-packet-transmission)).
For efficiency, cover packets and their rate-limit proofs MAY be pre-built during the previous epoch ([§6.1](#61-at-epoch-boundary))
and revalidated at send time in case the underlying state has changed ([§6.5](#65-pre-computed-proof-validation-at-send-time)).

Each epoch begins by discarding previous state and initializing a fresh slot budget,
loading any pre-built cover packets prepared during the prior epoch.
Throughout the epoch, cover, locally originated, and forwarded packets independently claim slots.
Near the midpoint, the node starts pre-computing cover packets for the next epoch.
At epoch end, unused slots are discarded and the cycle repeats.

The specification focuses on the Constant-Rate strategy.
An alternative Poisson-Rate strategy, where cover emission times are randomized, is kept for future consideration in [§11.5](#115-poisson-rate-cover-traffic).

## 4. Rate Limit Budget Model

Each mix node receives a per-node budget of `R_node` slots per epoch from the DoS protection mechanism (see [§2](#2-terminology)).
Cover emission, locally originated message sending, and packet forwarding all draw from the same `R_node` pool.
Since each originated packet traverses `L` forwarding hops — where `L` is the mix path length
as defined in [Mix Protocol §6](mix.md#6-pluggable-components) —
forwarding traffic naturally consumes a significant portion of `R_node`.

If every node originates at rate `C` packets per epoch (cover plus locally originated combined),
each node forwards approximately `C * L` packets per epoch.
Since origination and forwarding share the same per-node budget `R_node`:

```text
C + C * L ≤ R_node
C ≤ R_node / (1 + L)
```

`R_node / (1 + L)` is the equilibrium per-node origination rate used to size the cover budget `R_cover`,
not a hard per-node cap on origination.
Local origination MAY opportunistically use slots beyond what cover consumes,
constrained only by the hard per-node total `R_node` (enforced via `ClaimSlot` in [§5.2](#52-non-cover-slot-claim)).
Cover rate does not need to be explicitly reduced by a node's locally originated rate,
because the slot pool is self-balancing (see below).

Cover emission is sized against `R_cover = f × R_base`, not against the per-node `R_node`.
The cover-only bound is:

```text
R_cover ≤ R_node       (invariant, holds when f ≤ 1 and R_node ≥ R_base)
cover_per_epoch ≤ R_cover / (1 + L) = f × R_base / (1 + L)
```

This means the actual cover traffic emitted by a node is always less than `R_cover ≤ R_node` and depends on:

- **Path length `L`**: longer paths consume more forwarding slots, leaving fewer for cover.
  For `L=3`, approximately 25% of `R_base` is available for cover and locally originated message sending.
- **Network size `N` and forwarding variance**: with random path selection, forwarding load is not uniform.
  Some nodes receive more forwarding traffic than the equilibrium average, leaving even fewer slots for cover.
  The actual cover output per node therefore varies with network conditions.

The slot pool is self-balancing — no explicit origination rate constraint is needed.
Heavier forwarding load automatically leaves fewer slots for cover; lighter load leaves more.
Under differentiated `R_node`, any per-node capacity in `(R_base, R_node]` is exclusively available to non-cover origination and forwarding;
cover never draws from this headroom.

**Why `R_cover` is uniform.**
Under uniform random path selection, each node's forwarding load tracks the network-average origination rate, not its own `R_node`.
Per-node `R_cover` would let high-`R_node` nodes drive the average up,
leaving low-`R_node` forwarders unable to absorb the resulting forwarding load.
Pinning `R_cover = f × R_base` keeps network-wide cover load at `f × R_base / (1 + L)` per node, which fits every node's budget since `R_node ≥ R_base` and `f ≤ 1`.
A secondary registry-layer privacy benefit is noted in [§10.3](#103-network-wide-cover-rate-correlation).

**Note on DoS protection architecture:**
The self-balancing pool model assumes per-hop generated proofs
([Mix DoS Protection §4.2](mix-dos-protection.md#42-per-hop-generated-proofs)),
where forwarding consumes slots from the node's own `R_node` budget.
With sender-generated proofs ([Mix DoS Protection §4.1](mix-dos-protection.md#41-sender-generated-proofs)),
forwarding nodes only verify proofs and do not consume their own `R_node`,
but cover emission must still account for forwarding load to maintain constant total output.
The budget model and slot pool semantics for sender-generated proofs require separate analysis
and are deferred to [§11.4](#114-budget-model-for-sender-generated-proofs).

## 5. Integration with the Mix Protocol

The cover traffic mechanism integrates with the Mix Protocol at four points in packet processing.

Cover packets are identified by the reserved protocol codec `"/mix/cover/1.0.0"`.
This codec is used as the origin protocol codec during Sphinx packet construction
and is checked during exit processing to distinguish cover packets from application traffic.

All mix nodes in a deployment SHOULD use the same strategy type and parameters
to ensure uniform emission patterns across the anonymity set.
The configured path length `L` for cover packets
MUST match the path length used for locally originated messages
as defined in [Mix Protocol §6](mix.md#6-pluggable-components).

### 5.1 Cover Packet Transmission

**Trigger:** The configured strategy schedules a cover emission.

**[During Sphinx packet construction](mix.md#85-packet-construction):**
The mechanism constructs a cover Sphinx packet
following the same construction procedure as a locally originated message,
with the following differences:

- The mix path is a loop path — the final hop routes the packet back to the originating node.
- The origin protocol codec MUST be set to the cover traffic codec defined in [§5](#5-integration-with-the-mix-protocol).
  This codec is recognized by the Mix Protocol during exit processing
  to identify returning cover packets (see [§5.4](#54-cover-packet-reception)).
- The application message content SHOULD be filled with cryptographically random bytes.
  This keeps cover payloads indistinguishable from non-cover payloads under partial path compromise,
  and remains relevant if the design evolves to support non-loop cover paths in the future.
- If pre-computation is enabled, the pre-built cover packet is used directly without re-construction.

**Wire format:**
Cover packets use the exact Sphinx packet format defined in [Mix Protocol §8](mix.md#8-sphinx-packet-format).
No additional fields or framing are introduced.

The cover packet is then transmitted to the first hop following the standard Mix Protocol transmission procedure.

### 5.2 Non-Cover Slot Claim

**Procedure:** `ClaimSlot() -> success`

**Trigger:** The Mix Protocol needs to send a message or forward a packet and requires a slot from the budget.

The mechanism atomically claims a slot from the pool using the following procedure:

1. If `slots_remaining == 0`, the claim fails.
2. If `slots_remaining == len(cover_queue)`, the only way to free a slot is to reclaim one held by a queued cover packet:
   dequeue the head of `cover_queue` and discard it. Its pre-computed proof MUST NOT be sent on the wire.
3. Decrement `slots_remaining` and return success.

Free (unreserved) slots are taken first;
a queued cover packet is reclaimed only when no free slots remain
(_i.e._, when every remaining slot is committed to either non-cover claims already on the wire or pre-built cover in the queue).

Because `cover_queue` is bounded by `R_cover / (1 + L) = f × R_base / (1 + L) ≤ R_node / (1 + L)`,
non-cover claims have access to at least `R_node − f × R_base / (1 + L)` slots before any queued cover packet is reclaimed.
Under differentiated `R_node` (e.g. [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md)),
the entire `(R_base, R_node]` headroom is exclusively available to non-cover claims and never competes with cover.

On success, the caller then generates a DoS protection proof
via `GenerateProof(binding_data)` ([Mix DoS Protection §8.2.1](mix-dos-protection.md#821-proof-generation)),
where `binding_data` is the packet-specific data as defined by the DoS protection mechanism.

If the claim fails, the packet SHOULD be handled as follows to avoid hitting DoS protection limits:

- **Locally originated messages**: queued for the next epoch.
- **Forwarded packets**: queued for the next epoch.
  Since per-hop generated proofs are produced at send time ([§4](#4-rate-limit-budget-model)),
  the queued packet is re-emitted in the next epoch with a fresh proof generated then.
  Queue bounding, ordering, and fairness rules are specified in [§9.5](#95-forwarded-packet-queueing).

### 5.3 Epoch Boundary

**Procedure:** `ResetEpoch(epoch) -> void`

**Trigger:** The DoS protection mechanism signals the start of a new epoch
via `OnEpochChange` ([Mix DoS Protection §8.2.3](mix-dos-protection.md#823-epoch-change-notification)).
The Mix Protocol MUST call `ResetEpoch` before processing any packets in the new epoch.

The mechanism refreshes the slot pool for the new epoch:
all remaining slots from the previous epoch are discarded,
and a new pool of `R_node` slots is initialized.
If pre-computation is enabled, the pre-built cover packets prepared during the previous epoch
are loaded into the new pool.

Forwarded packets queued on `ClaimSlot` failure ([§5.2](#52-non-cover-slot-claim)) are not part of
the slot pool and are not discarded by `ResetEpoch`.
They are carried into the new epoch and re-attempted against the refreshed pool,
subject to the one-epoch lifetime cap in [§9.5](#95-forwarded-packet-queueing).

Packets emitted near epoch end may arrive at later hops in a subsequent epoch
due to accumulated mixing delays.
The DoS protection mechanism is responsible for accepting proofs within a configurable epoch window
(_e.g.,_ the `max_epoch_gap` parameter in [Mix RLN DoS Protection](mix-dos-protection-rln.md)).

### 5.4 Cover Packet Reception

**Trigger:** The Mix Protocol completes [exit processing](mix.md#864-exit-processing) on a received Sphinx packet
and extracts the origin protocol codec from the decrypted payload.

If the codec matches the cover traffic codec (see [§5](#5-integration-with-the-mix-protocol)),
the Mix Protocol MUST handle the packet internally without handing off to the Mix Exit Layer.
The packet SHOULD be silently discarded.
The codec check is performed in [Mix Protocol §8.6.4](mix.md#864-exit-processing) step 4.
Implementations MAY use this reception event for diagnostics such as path health monitoring
(see [§11.2](#112-path-health-monitoring)).

Self-exit ([§3](#3-design-principles)) keeps the cover codec invisible to any party other than the originator.
An external exit could otherwise accumulate cover-to-non-cover traffic ratios over time and leak
aggregate cover strategy and volume.

### 5.5 Data Structures

```text
PrebuiltCoverPacket {
  slot_id:        bytes                 // Slot identifier within the epoch
  packet:         bytes                 // Pre-built wire-format packet (Sphinx packet + DoS protection proof), ready to transmit
  path:           []bytes               // Ordered list of mix node identifiers on the cover path
  created_at:     uint64                // Unix timestamp (seconds) when this packet was constructed
}
```

```text
SlotPool {
  epoch:              uint64                 // The epoch this pool belongs to
  cover_queue:        []PrebuiltCoverPacket  // Pre-built cover packets, dequeued on emission or reclaimed by non-cover claims
                                             // bounded above by R_cover / (1 + L) = f × R_base / (1 + L), not by R_node
  slots_remaining:    uint32                 // Slots still spendable in this epoch (R_node minus what's already on the wire);
                                             // invariant: slots_remaining >= len(cover_queue)
}
```

```text
CoverTrafficConfig {
  strategy_type:  enum { CONSTANT_RATE, POISSON, NONE }
  cover_rate_fraction:  float64    // f ∈ (0.0, 1.0], such that R_cover = f × R_base (see §7); RECOMMENDED default 0.7
  // Strategy-specific parameters (see §7):
  // For CONSTANT_RATE: emission_rate (float64, packets per second, derived from R_cover)
  // For POISSON:       lambda_cover (float64, packets per second, derived from R_cover)
}
```

## 6. Node Responsibilities

This section defines what each mix node MUST do at each integration point.

Each outgoing packet — cover or non-cover — claims a slot from the [`SlotPool`](#55-data-structures) via `ClaimSlot` ([§5.2](#52-non-cover-slot-claim)).
Slot claim operations MUST be atomic (see [§9.4](#94-synchronization)).

### 6.1 At Epoch Boundary

When the DoS protection mechanism signals the start of a new epoch,
the Mix Protocol instance MUST invoke `ResetEpoch` ([§5.3](#53-epoch-boundary)) on the cover traffic mechanism
to discard previous epoch state and initialize a new slot pool.

**If pre-computation is enabled (RECOMMENDED):**
The cover traffic mechanism pre-builds cover packets during epoch `N-1` for use in epoch `N`.
For each slot to be pre-computed (at most `R_cover / (1 + L) = f × R_base / (1 + L)`;
see [§9.1](#91-pre-computation-scheduling) for sizing guidance),
construct a cover Sphinx packet following the procedure in [§5.1](#51-cover-packet-transmission)
and generate a DoS protection proof for the **next** epoch
via `GenerateProof(binding_data)` ([Mix DoS Protection §8.2.1](mix-dos-protection.md#821-proof-generation)).
Store the result as a [`PrebuiltCoverPacket`](#55-data-structures).
Slots without a pre-built packet will require on-demand generation if selected for cover emission.
Pre-computed proofs are bound to a specific epoch and MUST NOT be reused in subsequent epochs.

**Proof validity over time:**
Pre-computed proofs may be invalidated within their target epoch, not just across epochs.
For example, in [Mix RLN DoS Protection](mix-dos-protection-rln.md),
accumulating membership updates can push the root used at generation time
out of the current `acceptable_root_window_size` before the epoch ends.
Implementations MUST therefore validate pre-computed proofs at send time
(see [§6.5](#65-pre-computed-proof-validation-at-send-time)).

**Fallback caveat:**
On-demand generation when pre-computation falls behind introduces timing jitter,
which shifts emissions off-grid for deterministic strategies (_e.g.,_ [§7.1](#71-constant-rate-cover-traffic))
and weakens timing unobservability.
Implementations SHOULD size the pre-computation pipeline ([§9.1](#91-pre-computation-scheduling))
to avoid the fallback path in steady state.

### 6.2 Cover Emission

The cover emission loop runs continuously as a background process.
Emission timing is governed by the configured strategy ([`CoverTrafficConfig`](#55-data-structures)).

Cover emission consumes from `cover_queue`.
Slots are deducted from `slots_remaining` at claim time, not at wire transmission:
forwarded packets within their mixing delay (see [§6.4](#64-packet-forwarding))
have already been deducted, so their slots are unavailable to any later claim.

**Algorithm: Cover Emission**

> The following steps repeat continuously throughout each epoch:
>
> 1. Wait for the next emission event as determined by the configured strategy.
> 2. If the strategy schedules an emission **and** `cover_queue` is non-empty:
>    - a. Dequeue the head of `cover_queue` and decrement `slots_remaining`.
>    - b. Validate the proof per [§6.5](#65-pre-computed-proof-validation-at-send-time).
>    - c. Transmit the `packet` field of [`PrebuiltCoverPacket`](#55-data-structures) to the first hop
>      (other fields are internal and MUST NOT be sent).
> 3. If `cover_queue` is empty for the remainder of the epoch
>    (because pre-built packets were exhausted by emission or reclaimed under heavy non-cover load),
>    cover emission is suppressed until the next epoch boundary.

### 6.3 Locally Originated Message Sending

**[During Sphinx packet construction](mix.md#85-packet-construction):**
When the Mix Entry Layer submits a locally originated message for mixification,
the Mix Protocol instance MUST first call `ClaimSlot()` ([§5.2](#52-non-cover-slot-claim))
and apply that section's failure handling.
On success, the Mix Protocol instance proceeds with
[Sphinx packet construction](mix.md#85-packet-construction).

### 6.4 Packet Forwarding

**[During Sphinx packet handling](mix.md#86-sphinx-packet-handling):**
When the Mix Protocol instance acts as an intermediary and receives a Sphinx packet to forward,
it MUST first call `ClaimSlot()` ([§5.2](#52-non-cover-slot-claim)) before applying the mixing delay.
This ensures no two forwarded packets consume the same slot regardless of how their mixing delays overlap.
If no slot can be claimed, apply the failure handling in [§5.2](#52-non-cover-slot-claim) and [§9.5](#95-forwarded-packet-queueing).
On success, the Mix Protocol instance proceeds with
[intermediary processing](mix.md#863-intermediary-processing).

**Slot consumption:**
The slot is consumed on successful `ClaimSlot()`, not on transmission (see [§6.2](#62-cover-emission)).

**Send timing:**
The packet is dispatched when its mixing delay elapses,
independently of the cover emission schedule.

### 6.5 Pre-Computed Proof Validation at Send Time

Before transmitting a pre-built cover packet,
the mechanism MUST validate the carried DoS protection proof against the current state
(see [§6.1](#61-at-epoch-boundary) for rationale).
For [Mix RLN DoS Protection](mix-dos-protection-rln.md),
this means verifying the `merkle_root` bound into the proof
is still within the node's `acceptable_root_window_size`.

If validation fails, implementations MUST either:

- **Regenerate** the proof against the current anchor, keeping the Sphinx packet body unchanged; or
- **Skip** the emission if regeneration is infeasible.

A pre-built packet with a stale proof MUST NOT be sent.
When regenerating, implementations MAY reuse the message identifier bound to the cover packet
where the DoS protection mechanism permits (see [Mix RLN DoS Protection](mix-dos-protection-rln.md)).

## 7. Recommended Strategy

This section defines the Constant-Rate cover emission strategy, which is the normative strategy for this specification.
An alternative Poisson-Rate strategy is documented as a future consideration in [§11.5](#115-poisson-rate-cover-traffic).
Cover emission operates over the per-node `R_node`-slot pool and produces irregular total output
because forwarding traffic claims slots at unpredictable times.
Cover is emitted at up to `R_cover / (1 + L) = f × R_base / (1 + L)` packets per epoch —
a maximum, not a target;
the self-balancing pool ([§4](#4-rate-limit-budget-model))
accommodates locally originated messages without explicit adjustment.

**Cover rate fraction `f`:**
The strategy takes a configurable `cover_rate_fraction` `f ∈ (0.0, 1.0]` ([§5.5](#55-data-structures))
such that `R_cover = f × R_base`.
The cover emission rate is then `R_cover / ((1 + L) × P) = f × R_base / ((1 + L) × P)` packets per second.
A value of `f = 1.0` makes `R_cover = R_base`; lower values reduce `R_cover`
and leave more of `R_base` as headroom for locally originated messages and forwarded traffic.
The RECOMMENDED default is `f = 0.7`,
which makes `R_cover = 0.7 × R_base`, leaving 30% of `R_base` for non-cover origination and forwarding-variance headroom.
All mix nodes in a deployment SHOULD use the same `f`;
since `R_cover` is identical across all nodes, the cover-emission anonymity set is preserved network-wide
even when `R_node` varies (see [§4](#4-rate-limit-budget-model)).

### 7.1 Constant-Rate Cover Traffic

The cover traffic mechanism emits cover packets at a fixed interval of `1 / emission_rate` seconds,
where `emission_rate = R_cover / ((1 + L) × P) = f × R_base / ((1 + L) × P)` packets per second.
`f` is the configured `cover_rate_fraction` ([§5.5](#55-data-structures)),
and `R_base / ((1 + L) × P)` is the maximum safe cover rate (achieved at `f = 1.0`).
Non-cover traffic claims slots via `ClaimSlot()` ([§5.2](#52-non-cover-slot-claim)) as it arrives,
making total output inherently irregular even though the cover emission rate is constant.

At the configured rate, up to `R_cover / (1 + L) = f × R_base / (1 + L)` cover packets are emitted per epoch;
the actual count is lower when locally originated messages or forwarding variance claim slots first.
The originated cover emission rate is perfectly constant,
so an adversary cannot distinguish epochs with heavy locally originated traffic from idle epochs
by observing cover timing alone.

**Tradeoff — timing separability:**
Cover packets fire on a fixed grid,
while forwarded packets fire at arrival time plus mixing delay —
always off-grid relative to the cover schedule.
Over enough observations, an adversary can separate cover from non-cover by timing alone,
regardless of forwarding load.
Constant-Rate therefore provides **volume unobservability**
(the node's emission count does not leak non-cover activity)
but not **timing unobservability**
(individual packets remain classifiable by timing).

Full timing unobservability requires the pre-scheduled emission timing enhancement
([§11.3](#113-pre-scheduled-emission-timing)),
where all traffic types share the same timing grid.
Constant-Rate is the only strategy compatible with this upgrade path,
as it requires deterministic emission times known at epoch start.

**Characteristics:**
Constant-Rate emits up to `N = R_cover / (1 + L) = f × R_base / (1 + L)` cover packets per epoch.
The count is exact when forwarding does not exhaust the pool —
the design intent behind the RECOMMENDED `cover_rate_fraction = 0.7` ([§7](#7-recommended-strategy)),
which makes `R_cover = 0.7 × R_base`, leaving 30% of `R_base` as headroom against forwarding spikes.
Pre-computation sizing matches `N`; no further safety margin beyond `f` is needed.
Under exhaustion, cover emission is suppressed for the remainder of the epoch
([§6.2](#62-cover-emission), [§10.5](#105-cover-priority-and-forwarded-packet-deferral)),
and per-epoch cover output drops below `N`.
An observer who knows `f` can upper-bound the per-epoch forwarding count as `total_emissions - N`;
this analysis holds across heterogeneous-`R_node` deployments precisely because `R_cover` is uniform,
so cover-emission observation reveals nothing about a node's `R_node`.
Volume unobservability holds only against observers unaware of `f` or watching aggregate rates.

## 8. Initiating-Only Node Considerations

Initiating-only nodes are short-lived with dynamic identifiers and do not forward traffic.
They SHOULD NOT generate cover traffic,
as cover traffic is only meaningful for nodes that participate continuously in the network with a stable identity —
a briefly connected node has no sustained emission pattern to protect or contribute.

**Residual privacy for initiating-only nodes:**
Without cover traffic, initiating-only nodes still retain:

- **Path anonymity**: Sphinx layered encryption prevents any single intermediary or exit
  from learning both sender and recipient.
- **Identity unlinkability**: dynamic identifiers prevent cross-session linking.

However, an adversary on the link to the first hop — or a malicious first hop itself —
can directly observe session volume and timing,
since no cover or forwarded packets are blended with originated traffic.

Deployments where this matters SHOULD route initiating-only traffic through trusted first hops.

If an initiating-only node is promoted to a mix node and becomes long-lived,
it SHOULD activate cover traffic using the Constant-Rate strategy.
During the first epoch after promotion, pre-computed cover packets are unavailable;
the node SHOULD fall back to on-demand cover packet generation for that epoch
and begin pre-computation immediately upon promotion.

## 9. Implementation Recommendations

This section provides non-normative guidance for implementers.

### 9.1 Pre-computation Scheduling

The pre-computation pipeline SHOULD be initiated at the midpoint of the current epoch
to allow sufficient time for slots to be processed before the next epoch begins.
Implementations SHOULD interleave pre-computation with normal packet processing
(_e.g.,_ yielding to non-cover traffic between slot generations) to avoid contention with ongoing packet handling.

Pre-computation pool size matches the per-epoch cover ceiling `R_cover / (1 + L) = f × R_base / (1 + L)`,
not the per-node `R_node`.
Rather than pre-computing all cover packets in the previous epoch,
implementations MAY batch pre-computation across epochs:
an initial batch during epoch `N-1` to ensure cover packets are available at the start of epoch `N`,
with subsequent batches computed incrementally during epoch `N` itself, staying ahead of the emission schedule.
This reduces peak computational load and memory usage.

### 9.2 Pool Status Tracking

Implementations SHOULD maintain runtime counters for available slots, cover emissions, and non-cover consumptions.
These aid in diagnostics, monitoring, and tuning the emission strategy.

**Exposure restrictions:**
The non-cover consumption counter reveals the exact per-epoch count of real traffic,
which is what traffic analysis aims to recover.

Implementations MUST keep this counter (and any derived per-epoch breakdowns) in-memory only
and MUST NOT export it via metrics endpoints, structured logs, or any monitoring interface.

### 9.3 Slot Exhaustion Logging

When a forwarded packet is queued due to slot exhaustion ([§5.2](#52-non-cover-slot-claim)),
or dropped because the queue itself is at its implementation-defined bound, implementations SHOULD log a warning.
Persistent queueing or drops may indicate that `R_node` is too low for the network's forwarding load,
or that the node is under a traffic flooding attack.

### 9.4 Synchronization

Slot claim operations MUST be atomic.
Implementations may enforce this using mutexes, lock-free atomic operations, or single-threaded event loops,
depending on the concurrency model.

### 9.5 Forwarded Packet Queueing

Per [§5.2](#52-non-cover-slot-claim) and [§6.4](#64-packet-forwarding),
forwarded packets that fail to claim a slot are queued for the next epoch.
Implementations SHOULD observe the following:

- **One-epoch lifetime cap**:
  A queued packet MUST be either re-emitted within the next epoch or dropped at that epoch's end.
  Re-queueing across multiple epochs MUST NOT be permitted.
  This bounds the latency penalty to at most one epoch
  and avoids cumulative synchronization effects in flush bursts.
- **Bounded queue size**:
  Implementations MUST configure a maximum queue size.
  Forwards arriving when the queue is at bound MUST be dropped (tail-drop).
  The queue size MUST NOT exceed `R_node − f × R_base / (1 + L)`,
  the non-cover slot headroom one epoch is guaranteed to offer
  (see [§5.2](#52-non-cover-slot-claim)).
  A queue larger than this cannot drain within the one-epoch lifetime cap above,
  so the excess is capacity that can never be used.
  Implementations SHOULD size the queue to a fraction of that headroom rather than all of it,
  since queued packets compete for slots with forwards and locally originated messages
  arriving during the next epoch.
- **Per-predecessor fairness**:
  The queue is shared across every upstream node a forwarder receives packets from.
  A single upstream sending at high rate near epoch end can otherwise fill the queue
  and cause tail-drops of packets forwarded on behalf of others.
  Implementations SHOULD partition the queue per immediate predecessor,
  or apply a per-predecessor quota,
  so that tail-drop applies within a partition rather than across the whole buffer.
  This uses only the predecessor identity a node already observes on the incoming connection
  and reveals nothing further about the packet's path.
- **FIFO ordering**:
  Queued packets SHOULD be re-attempted in FIFO order in the next epoch.
- **Stagger flush**:
  Implementations SHOULD NOT release the entire queue at the exact epoch boundary instant.
  Re-emission is integrated with the normal `ClaimSlot` flow so re-emitted packets are scattered
  by their fresh mixing delays after each re-claim succeeds.
- **Fresh proof on re-emission**:
  Re-emission MUST generate a new DoS protection proof bound to the new epoch via `GenerateProof`,
  consistent with the per-hop generated proof model ([§4](#4-rate-limit-budget-model)).
- **Diagnostics**:
  Implementations MAY track queue depth and drop counts.
  These counters MUST be kept in-memory only
  and MUST NOT be exported via metrics endpoints, structured logs, or any monitoring interface,
  consistent with the exposure restrictions in [§9.2](#92-pool-status-tracking).

## 10. Security Considerations

The design principles motivating slot integrity and DoS protection compliance
are described in [§3](#3-design-principles).
This section discusses the threat context behind those principles.

### 10.1 Proof Reuse via Proof Leakage

If a pre-computed cover proof and a freshly generated non-cover proof for the same slot are both sent on the wire,
the DoS protection mechanism detects a reuse.
Depending on the mechanism, this may result in slashing or reputation loss for the node.
The slot integrity principle ([§3](#3-design-principles)) prevents this
by ensuring the cover proof is discarded before the slot is reused.

### 10.2 Slot Exhaustion Under Heavy Non-Cover Traffic

If non-cover traffic consumes all `R_node` slots before the epoch ends,
the node cannot emit further cover traffic.
This is a natural consequence of DoS protection compliance ([§3](#3-design-principles)).
Locally originated messages that arrive after slot exhaustion MUST be queued for the next epoch.
Cover emission ceases when no slots remain.

### 10.3 Network-Wide Cover-Rate Correlation

When a message traverses multiple mix nodes,
each node on the path claims one slot for forwarding,
slightly reducing its available cover capacity for the remainder of the epoch.
A global passive adversary observing all nodes simultaneously could in principle
detect correlated cover-rate perturbations across nodes and use them to trace message paths.

In practice, each forwarded message consumes only one slot out of `R_node`,
making the perturbation negligible for sufficiently large `R_node`.
The pre-scheduled emission timing enhancement ([§11.3](#113-pre-scheduled-emission-timing))
would eliminate this concern entirely by fixing all emission times at epoch start,
making individual slot consumption events unobservable.

Note that uniform `R_cover` across all nodes (see [§4](#4-rate-limit-budget-model)) ensures
cover-emission observation does not narrow the rate-tier anonymity sets that the registry layer
of differentiated-`R_node` mechanisms (e.g.
[Stake-Weighted Mix RLN DoS Protection §5.3](mix-dos-protection-rln-stake-weighted.md#53-registered-stake-privacy))
may already partially expose.

Cover-rate perturbation is not the only per-node signal slot consumption produces:
forwarded-packet deferral ([§10.5](#105-cover-priority-and-forwarded-packet-deferral))
exposes queue depth as a latency signal on the same nodes.

### 10.4 Timing Separability of Cover and Non-Cover Packets

The default Constant-Rate strategy ([§7.1](#71-constant-rate-cover-traffic))
emits cover packets on a fixed grid while forwarded packets are dispatched at arrival time plus mixing delay.
With enough observations, a passive adversary can classify individual packets by timing alone,
regardless of forwarding load.

Constant-Rate therefore provides volume unobservability but not timing unobservability.
Under Constant-Rate, the pre-scheduled emission timing enhancement ([§11.3](#113-pre-scheduled-emission-timing))
is the only design that closes this gap,
by assigning all outgoing packets — cover, locally originated, and forwarded —
to a shared fixed-time grid determined at epoch start.

### 10.5 Cover Priority and Forwarded Packet Deferral

Cover emissions occur on a schedule independent of forwarding load,
so slots consumed by cover early in an epoch are unavailable to forwarded packets arriving later.
Under uneven forwarding load, this can cause honest forwards to be queued for the next epoch ([§6.4](#64-packet-forwarding))
even when total traffic stays within the `R_node` budget,
adding at least one epoch of latency.
Forwards are dropped only if the implementation's bounded queue itself overflows.

The `cover_rate_fraction` `f` ([§7](#7-recommended-strategy)) reduces this risk
by holding back a fraction of `R_base` from cover emission,
leaving headroom for forwarding spikes.
Under differentiated `R_node` (e.g. [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md)),
additional headroom in `(R_base, R_node]` further reduces forwarded-packet deferral.
Deployments SHOULD adjust `f` based on observed network behavior;
see [§11.1](#111-adaptive-cover-rate-fraction) for adaptive tuning as a future enhancement.
See [§4](#4-rate-limit-budget-model) for why `R_cover` is uniform rather than scaled per-node.

**Queue depth as a node-level observable.**
Deferring a forwarded packet rather than dropping it changes the shape of the signal
that slot exhaustion produces, but does not remove it.
Dropping made exhaustion visible as packet loss;
deferral makes it visible as latency, since a node's queue depth manifests
as additional forwarding delay across the epoch boundary.
A global passive adversary can therefore distinguish persistently congested forwarders
from lightly loaded ones, which is a node-fingerprinting axis beyond the cover-rate perturbation
discussed in [§10.3](#103-network-wide-cover-rate-correlation).
The latency signal is the more legible of the two,
because it persists for as long as the node stays congested.
As with [§10.3](#103-network-wide-cover-rate-correlation) and
[§10.4](#104-timing-separability-of-cover-and-non-cover-packets),
the pre-scheduled emission timing enhancement ([§11.3](#113-pre-scheduled-emission-timing))
addresses this by assigning outgoing packets to a fixed grid determined at epoch start,
which decouples observable send times from queue state.
Note that this is a property of the traffic a node emits;
the queue-depth counter itself is separately restricted to in-memory use by
[§9.5](#95-forwarded-packet-queueing).

## 11. Future Work

### 11.1 Adaptive Cover Rate Fraction

The `cover_rate_fraction` `f` ([§7](#7-recommended-strategy)) is currently a static deployment-wide configuration.
A future enhancement MAY define a method for nodes to adapt `f` based on observed forwarding load,
network size `N`, and path length `L`,
allowing cover rate to be tuned closer to the deployment's actual available cover budget
and reducing unnecessary cryptographic work.
Any adaptive scheme MUST preserve uniformity of `R_cover` across the anonymity set
(_i.e.,_ adapt `f` deployment-wide, not per-node)
to avoid leaking per-node load or `R_node` through emission rate differences.

### 11.2 Path Health Monitoring

When cover packets are implemented as loop packets —
dummy Sphinx packets that follow a valid mix path and return to the originating node —
their return confirms path liveness.
Failures to return indicate potential node failures or active attacks along the path.
A future revision of this specification MAY define an interface for exposing loop return status
to enable path health monitoring.

### 11.3 Pre-Scheduled Emission Timing

Inspired by the [Blend Protocol](../../blockchain/raw/nomos-blend-protocol.md), a future enhancement MAY define pre-scheduled emission slots
where all outgoing packets — cover, locally originated, and forwarded — are assigned to
fixed time slots determined at epoch start.
The grid would be sized to `R_cover`, not `R_node`,
to preserve cover-emission uniformity across the anonymity set under differentiated-`R_node` deployments.
All traffic types would share the same timing grid,
producing a perfectly periodic total output regardless of traffic mix.
This would eliminate the periodic emission pattern tradeoff noted in [§7.1](#71-constant-rate-cover-traffic),
as an observer would see uniform intervals with no way to classify individual packets.
When using Constant-Rate, this is the only design path to full timing unobservability
(see [§10.4](#104-timing-separability-of-cover-and-non-cover-packets)).

This approach is only compatible with the Constant-Rate strategy,
which provides deterministic emission times known at epoch start.
Poisson-Rate, where emission times are sampled at runtime, cannot support pre-scheduled slots.
Note that pre-scheduled slots would require changes to the mixing delay strategy
in the Mix Protocol, as forwarded packets would need to be held until their assigned slot time
rather than forwarded after the sampled delay elapses.

### 11.4 Budget Model for Sender-Generated Proofs

The rate-limit budget model in [§4](#4-rate-limit-budget-model) assumes per-hop generated proofs,
where forwarding consumes from the node's own `R_node` budget and the slot pool self-balances.
With sender-generated proofs, the initiating node generates `L` proofs per originated packet from its own `R_node`,
while forwarding nodes only verify and do not consume their own budget.
A future revision MAY define an adapted budget model for this architecture,
including revised slot pool semantics with `R_node` and `R_cover` accounting,
an explicit emission rate target that accounts for observed forwarding load,
and updated pre-computation sizing.

### 11.5 Poisson-Rate Cover Traffic

Poisson-Rate is a candidate alternative strategy retained here for future consideration.

The node emits cover packets according to a Poisson process with rate `λ_cover` packets per second,
producing random memoryless inter-emission gaps.
`λ_cover` would be set to `R_cover / ((1 + L) × P) = f × R_base / ((1 + L) × P)` packets per second,
where `f` is the configured `cover_rate_fraction` ([§5.5](#55-data-structures)).
Emissions are suppressed when no slots are available.

**Potential strengths:**

- **Timing unobservability:** both cover and forwarded emissions are exp-distributed,
  making it statistically hard for an observer to classify individual packets by timing
  (addressing the separability concern in [§10.4](#104-timing-separability-of-cover-and-non-cover-packets)).
- **Short-window volume unobservability:** per-epoch cover count is `Poisson(N)` rather than deterministic,
  so forwarding-count estimates from total emissions carry at least `±√N` uncertainty per epoch.

**Costs:**

- **Per-epoch variance:** cover emissions per epoch are `Poisson(N)` — some epochs are thin and weaken in-epoch mixing.
- **Front-loading:** random clustering can consume cover budget early, starving late-arriving non-cover traffic.
- **Pre-computation margin:** pipelines need a safety margin (e.g., `N + 3√N`) to avoid running dry.
- **Budget coupling:** cover rate drops with non-cover load as the pool nears exhaustion.

**Interaction with `R_cover`:**

Poisson-Rate's per-epoch variance shrinks relative to its mean as `R_cover` grows (`√N / N` → 0).
At small `R_cover`, front-loading and thin-cover epochs are pronounced.
At large `R_cover`, these effects become negligible.

Simulation of real traffic distributions is required before adopting Poisson-Rate as a normative option.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [libp2p Mix Protocol](mix.md)
- [Mix DoS Protection](mix-dos-protection.md)
- [Mix RLN DoS Protection](mix-dos-protection-rln.md)
- [Stake-Weighted Mix RLN DoS Protection](mix-dos-protection-rln-stake-weighted.md)
- [Loopix: Providing Anonymity in a Message Passing System](https://www.usenix.org/conference/usenixsecurity17/technical-sessions/presentation/piotrowska)
- [Nym: Mixnet for Network-Level Privacy](https://nymtech.net/nym-whitepaper.pdf)
- [Blend Protocol](../../blockchain/raw/nomos-blend-protocol.md)
