# BLOCK-CONSTRUCTION-VALIDATION-AND-EXECUTION

| Field | Value |
| --- | --- |
| Name | Block Construction, Validation and Execution |
| Slug | 93 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski <marcin@logos.co> |
| Contributors | Thomas Lavaur <thomaslavaur@logos.co>, Daniel Sanchez Quiros <danielsq@logos.co>, David Rusu <davidrusu@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Mehmet Gonen <mehmet@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-27** — [`b7602ed`](https://github.com/logos-co/logos-lips/blob/b7602ed8a225d41ca0bfaaa432524dc84d2ded7e/docs/blockchain/raw/bedrock-v1.1-block-construction.md) — chore: move blockchain specs from notion to github
- **2026-05-18** — [`58b5698`](https://github.com/logos-co/logos-lips/blob/58b56988429f4d69a9e10a9fc118725e229e37c5/docs/blockchain/raw/bedrock-v1.1-block-construction.md) — chore(blockchain): migrate contributor emails to @logos.co (#338)
- **2026-02-09** — [`afd94c8`](https://github.com/logos-co/logos-lips/blob/afd94c8bc1420376ae9af7e14a4feb246f2ed621/docs/blockchain/raw/bedrock-v1.1-block-construction.md) — chore: add math support (#287)
- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-v1.1-block-construction.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-v1.1-block-construction.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revisions History

| **Version** | **Changes** | **Date** |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-12-03 |
| 1.1.0 | Removed `service_rewards` due to updated [SERVICE-REWARD-DISTRIBUTION-PROTOCOL](bedrock-service-reward-distribution.md). Extended the [Block Execution](#block-execution) logic with rewards distribution due to updated [SERVICE-REWARD-DISTRIBUTION-PROTOCOL](bedrock-service-reward-distribution.md). Removed **Block Samples** subsection of the [Batch verification of ZK proofs](#batch-verification-of-zk-proofs) from the [Annex](#annex). Reordered the [Block Execution](#block-execution) steps to enable immediate use of reward notes as inputs for transactions included in the proposal. | 2026-03-27 |
| 1.1.1 | [[RFC] Simplify Mantle Transaction and Refactor Ledger Operations](mantle-transaction-encoding/appendices/rfc-simplify-mantle-transaction-and-refactor-ledger-operations.md) | 2026-05-06 |
| 1.1.2 | Precise that the maximum block size applies to the block body only. | 2026-07-27 |
| 1.2.0 | Compressed Block Proposal: 8-byte transaction reference prefixes and a variable-length `references` list, reducing the proposal to at most 8,555 bytes. Added [Canonical Encoding](#canonical-encoding) and [Prefix Collision Resolution](#prefix-collision-resolution). | 2026-08-10 |

# Introduction

In this document, we present the specification defining the construction of the block proposal, its validation, and execution. We define the block proposal construction that contains references to transactions (from the mempool) instead of a complete transaction to limit its length. The raw block body increases with the size of transactions it contains up to `MAX_BLOCK_SIZE`, which is 1 MB and covers the transactions only, and the proposal compresses its size down to at most ≈8.5 kB (8,555 bytes), which saves the bandwidth necessary to broadcast new blocks.

# Overview

For the consensus protocol to make progress, a new **leader** is elected through the leader lottery. The new leader is in possession of a proof of leadership (PoL) that confirms that it is indeed the leader. The main objective of the leader is to construct a new block, hence becoming a **block builder,** and share it with other members of the network as a **block proposer**. The block must be correctly constructed; otherwise, it will be rejected by the consensus nodes who are validating every block. Only validated blocks are executed, which means that the transactions included in the block are interpreted by all nodes, and the state of the chain is modified according to the instructions embedded in the transactions.

## High-level Flow

Below, we present a high-level description of the block lifecycle. The main focus of this section is to build an intuition on the block construction, validation, and execution.

1. A leader is selected. The leader becomes a block builder.
2. The block builder **constructs** a block proposal.
1. The block builder selects the latest block (parent) as the reference point for the chain state update.
2. The block builder selects valid Mantle Transactions (as defined in [Mantle](bedrock-v1.1-mantle-specification.md)) from its mempool and includes references to them in the proposal.
3. The block builder populates the block header of the block proposal.

3. The block proposer sends the block proposal to the Blend network.
4. The validators receive the block proposal.
5. The validators **validate** the block proposal.
1. They validate the block header.
2. They retrieve complete transactions from their mempool that are referred in the block.
3. They validate each transaction included in the block.

6. The validators **execute** the block proposal.
1. They derive the new blockchain state from the previous one by executing transactions as defined in [Mantle](bedrock-v1.1-mantle-specification.md).
2. They update the different variables that need to be maintained over time.
3. They execute the [**Service Reward Distribution Protocol**](bedrock-service-reward-distribution.md) to generate reward notes locally.

# Constructions

## Hash

We are using two hashing algorithms that have the same output length of 256 bits (32 bytes) that are [Poseidon2 and Blake2b](common-cryptographic-components.md).

## Block Proposal

A block proposal, instead of containing complete Mantle Transactions of an unlimited size, contains short fixed-size references to the transactions. The number of references varies from block to block, so the proposal is variable-size: 363 bytes when it references no transaction, and at most 8,555 bytes when it references the maximum of `MAX_BLOCK_TXS` transactions.

We define the following message structure:

```python
class Proposal:                              # 363..8555 bytes
    header: Header                           # 297 bytes
    references: References                   # 2..8194 bytes (2-byte count + entries)
    signature: Ed25519Signature              # 64 bytes
```

Where:

- `header` is the header of the proposal; defined below: [Header](#header).
- `references` is a variable-length list of up to `MAX_BLOCK_TXS` [references](#references) to transactions, each being an 8-byte (`REFERENCE_PREFIX_LENGTH`) prefix of the transaction hash defined in [Mantle Transaction](bedrock-v1.1-mantle-specification.md#mantle-transaction).
- `signature` is the signature of the complete `header` using the `leader_key` from the `ProofOfLeadership`; the size of the `Ed25519Signature` type is 64 bytes.

The proposal carries no padding of its own. Proposal indistinguishability is provided at the message layer: [Payload Formatting](payload-formatting.md#body) already mandates a fixed body length (`Max_Body_Length`) for every dispersed payload, with shorter messages padded with **random** data and the true length carried in `body_length`. An in-proposal zero-padded layout would duplicate that guarantee while charging every proposal the full `MAX_BLOCK_TXS` cost even when it references few transactions. The padding lies outside the signed proposal and is discarded via `body_length` on decapsulation, so no consensus meaning ever attaches to it.

Note that this makes the random-padding requirement of [Payload Formatting](payload-formatting.md#body) load-bearing for the first time. While the proposal was a constant 8,555 bytes it always filled the body exactly and the padding path never fired for a real proposal. Implementations must pad with random data, not zeros, or the padding region will itself distinguish proposals by their reference count.

### Header

```python
class Header:                                # 297 bytes
    bedrock_version: byte                    # 1 byte
    parent_block: hash                       # 32 bytes
    slot: SlotNumber                         # 8 bytes
    block_root: hash                         # 32 bytes
    proof_of_leadership: ProofOfLeadership   # 224 bytes
```

Where:

- `bedrock_version` is the version of the proposal message structure that supports other protocols defined in linked reference; its size is 1 byte and is fixed to `0x01`.
- `parent_block` is the block ID ([Cryptarchia Protocol](cryptarchia-v1-protocol.md)) of the parent block, validated and accepted by the block builder. It is used for the derivation of the `AgedLedger` and `LatestLedger` values necessary for validating the PoL; the size of the `hash` is 32 bytes.
- `slot` is the consensus slot number; the size of the `SlotNumber` type is 8 bytes.
- `block_root` is the root of the Merkle tree constructed from the **full** transaction hashes (defined in [Mantle Transaction](bedrock-v1.1-mantle-specification.md#mantle-transaction)) used for constructing the `mempool_transactions` references list; the size of the `hash` is 32 bytes. Because `block_root` commits to the full hashes, it uniquely binds the proposal to a specific ordered transaction selection even when two transactions share the same `references` prefix. It also binds the *number* of references; see [Binding of the reference list](#binding-of-the-reference-list).
- `proof_of_leadership` is the proof confirming that the sender is the leader; defined below: [Proof of Leadership](#proof-of-leadership).

### References

Each reference is a fixed-length prefix of the transaction hash rather than the full hash. The prefix length is the protocol parameter `REFERENCE_PREFIX_LENGTH = 8` bytes, and the prefix is taken by:

```python
REFERENCE_PREFIX_LENGTH = 8   # bytes

def prefix(hash_input: bytes, length: int) -> bytes:
    return hash_input[:length]
```

```python
class References:                            # 2..8194 bytes
    mempool_transactions: list[bytes]        # UINT16 count + len * REFERENCE_PREFIX_LENGTH
```

Where `mempool_transactions` is a variable-length list of up to `MAX_BLOCK_TXS` references to transactions, each being `prefix(mantle_txhash(tx), REFERENCE_PREFIX_LENGTH)` of the transaction hash defined in [Mantle Transaction](bedrock-v1.1-mantle-specification.md#mantle-transaction).

The list is not padded. As specified in [Canonical Encoding](#canonical-encoding), it is serialized as a 2-byte little-endian element count followed by that many `REFERENCE_PREFIX_LENGTH`-byte entries, so its encoded size is `2 + len(mempool_transactions) * REFERENCE_PREFIX_LENGTH` bytes — 2 bytes when the proposal references no transaction, and `2 + 1024 * 8 = 8194` bytes at `MAX_BLOCK_TXS`.

A decoder must reject a count greater than `MAX_BLOCK_TXS` **before** allocating for it or performing any mempool lookup, on every ingress path.

### Proof of Leadership

```python
class ProofOfLeadership:                     # 224 bytes
    proof: Groth16Proof                      # 128 bytes
    entropy_contribution: zkhash             # 32 bytes
    leader_key: Ed25519PublicKey             # 32 bytes
    leader_voucher: RewardVoucher            # 32 bytes
```

Where:

- `proof` is the proof confirming that the proposal is constructed by the leader; the size of the `Groth16Proof` type is 128 bytes (2 compressed $`\mathbb{G}_1`$and 1 compressed $`\mathbb{G}_2`$ BN256 elements).
- `entropy_contribution` is the output of the PoL contribution for Cryptarchia entropy; the size of the `zkhash` type is 32 bytes.
- `leader_key` is the one-time `Ed25519PublicKey` used for signing the `Proposal`. This binds the content of the proposal with the `ProofOfLeadership`; the size of the `Ed25519PublicKey` type is 32 bytes.
- `leader_voucher` is the voucher value used for retrieving the reward by the leader for proposal; the size of the `RewardVoucher` is 32 bytes.

> **Field order.** The order above is the **wire** order, i.e. the order in which these fields are concatenated by [Canonical Encoding](#canonical-encoding). The `block_id` preimage in [Cryptarchia Protocol](cryptarchia-v1-protocol.md#block-id) absorbs the same four fields in a *different* order (`leader_voucher`, `entropy_contribution`, `proof`, `leader_key`). This is deliberate, not an inconsistency: `block_id` is a domain-separated enumeration of header fields rather than a re-serialization of the header, so the two orders are independent and both are normative. Changing either one changes a different thing — the wire format in the first case, block identity in the second.

## Canonical Encoding

This section defines the byte-level wire format of the block proposal. It follows the same conventions as the [Mantle Transaction Encoding](mantle-transaction-encoding.md), in particular *"All multi-byte integers use little-endian encoding"* and *"Any lists are length-prefixed with fixed width uints"*, and reuses its primitive terminals rather than redefining them.

The encoding is canonical: every valid proposal has exactly one byte representation, and every byte string decodes to at most one proposal. The following rules are normative.

1. All multi-byte integers are little-endian.
2. The fields of a structure are concatenated in the order in which they are declared, with no separators, no alignment padding, and no per-field framing.
3. A list is encoded as a `UINT16` element count followed by that many elements, each encoded individually. The count must not exceed the list's declared bound.
4. Decoding must consume the input exactly. A decoder must reject input that ends before the structure is complete, and must equally reject input with bytes remaining after it. Accepting trailing bytes would allow two distinct wire messages to decode to the same proposal, which is a parser differential and therefore a consensus-split risk.

```schema
Proposal          = Header References Ed25519Signature

Header            = Version ParentBlock Slot BlockRoot ProofOfLeadership
Version           = Byte            ; fixed to 0x01
ParentBlock       = Hash32
Slot              = UINT64
BlockRoot         = Hash32

ProofOfLeadership = Groth16 EntropyContribution LeaderKey LeaderVoucher
EntropyContribution = FieldElement
LeaderKey         = Ed25519PublicKey
LeaderVoucher     = FieldElement

References        = ReferenceCount *Reference
ReferenceCount    = UINT16          ; MUST NOT exceed MAX_BLOCK_TXS
Reference         = 8BYTE           ; REFERENCE_PREFIX_LENGTH bytes
```

The terminals `Byte`, `UINT16`, `UINT64`, `Hash32`, `FieldElement`, `Groth16`, `Ed25519PublicKey` and `Ed25519Signature` are those defined in [Mantle Transaction Encoding](mantle-transaction-encoding.md#common-structures). Note in particular that `FieldElement` is a little-endian BN254 field element, which fixes the byte order of `entropy_contribution` and `leader_voucher`.

This yields the following sizes, where `n` is the number of references:

| Structure | Encoded size | Minimum | Maximum |
| --- | --- | --- | --- |
| `Header` | `1 + 32 + 8 + 32 + 224` | 297 | 297 |
| `ProofOfLeadership` | `128 + 32 + 32 + 32` | 224 | 224 |
| `References` | `2 + 8n` | 2 | 8,194 |
| `Proposal` | `297 + (2 + 8n) + 64` | 363 | 8,555 |

The maximum of 8,555 bytes is what [Payload Formatting](payload-formatting.md#body) uses as `Max_Body_Length`.

## Proposal Construction

In this section, we explain how the block proposal structure presented above is populated by the consensus leader.

The block proposal is constructed by the leader of the current slot. The node becomes a leader only after successfully generating a valid PoL for a given `(Epoch, Slot)`.

### Prerequisites

Before constructing the proposal, the block builder must:

1. Select a valid parent block referenced by `ParentBlock` on which they will extend the chain.
2. Derive the required Ledger state snapshots `AgedLedger` and `LatestLedger` from the state of the chain including the last block.
3. Select a valid unspent note winning the PoL.
4. Generate a valid PoL proving leadership eligibility for `(Epoch, Slot)` based on the selected note. Attach the PoL to a one-time Ed25519 public key used to sign the block proposal.

Only after the PoL is generated can the block proposal be constructed (see [Proof of Leadership](cryptarchia-proof-of-leadership.md)).

### Construction Procedure

1. Initialize proposal metadata with the last known state of the blockchain. Set the:
  - `header`:
    - `bedrock_version`
    - `parent_block`
    - `slot`
    - `block_root`
    - `proof_of_leadership`:
      - `leader_voucher`
      - `entropy_contribution`
      - `proof`
      - `leader_key`

2. Construct the `mempool_transactions` object:
1. Select Mantle transactions:
    - Choose up to `MAX_BLOCK_TXS` valid `SignedMantleTx` from the local mempool.
    - Ensure each transaction:
      - Is valid according to [Mantle](bedrock-v1.1-mantle-specification.md).
      - Has no conflicts with others (e.g., two transactions trying to spend the same note).
    - Bound the ambiguity the selection creates. For each selected transaction, let `a_i` be the number of transactions in the local mempool that share its `REFERENCE_PREFIX_LENGTH`-byte hash prefix, so `a_i = 1` when the prefix is unique there. The selection must satisfy:

      ```python
      # A colliding transaction the proposer did not hold raises one a_i by one, which
      # multiplies the product by (a_i + 1) / a_i, at most 2. Tolerating
      # DIVERGENCE_TOLERANCE such surprises therefore costs 2 ** DIVERGENCE_TOLERANCE
      # against the validator's bound.
      DIVERGENCE_TOLERANCE = 2

      MAX_PROPOSAL_AMBIGUITY = MAX_RECONSTRUCTION_COMBINATIONS // (2 ** DIVERGENCE_TOLERANCE)   # 1024 // 4 = 256

      product(a_i for all selected i) <= MAX_PROPOSAL_AMBIGUITY
      ```

  This is the construction-side counterpart of the validator's `MAX_RECONSTRUCTION_COMBINATIONS` (see [Prefix Collision Resolution](#prefix-collision-resolution)), and it is what keeps reconstruction an unambiguous lookup in the ordinary case rather than a search. The bound is derived from the validator's rather than set independently, so that `MAX_PROPOSAL_AMBIGUITY < MAX_RECONSTRUCTION_COMBINATIONS` holds by construction: a proposer working to its own mempool must leave room for a validator that holds a colliding transaction it did not.

  `DIVERGENCE_TOLERANCE` is not sized for accidental divergence, which does not need it — with `MAX_BLOCK_TXS` references and a mempool differing by even ten thousand transactions, the chance that any of that difference collides with a referenced prefix is around $`10^{-12}`$. It is sized for *timed* divergence: an adversary who delivers one half of a ground pair late, and to some validators only, places a collision the proposer could not have seen. A tolerance of two covers two such deliveries; beyond that the proposal is rejected at the affected validators alone rather than network-wide, since validators that never received the late transactions reconstruct normally. A validator that rejected for this reason converges on the block later through ordinary chain synchronisation, once the chain extends it.

  In practice a builder satisfies this by preferring transactions whose prefix is unique in its mempool, which costs a lookup on an index it already maintains, and spending the remaining budget on at most a few ambiguous ones. A transaction passed over for this reason is deferred rather than dropped: it stays eligible, and the budget is recomputed against a fresh mempool for every proposal.

3. Derive references values:
```python
references: list[bytes] = [prefix(mantle_txhash(tx), REFERENCE_PREFIX_LENGTH)
                           for tx in mempool_transactions]
```

4. Compute the `header.block_root` as the root of the Merkle tree constructed over the full transaction hashes of the selected transactions used to build `references`. The `references` list is left exactly as long as the selection; it is not padded.
5. Sign the block proposal header, where `header` is its canonical encoding as defined in [Canonical Encoding](#canonical-encoding) — the 297 bytes of the header alone, without `references` and without the signature itself.
```text
signature = Ed25519.sign(leader_secret_key, header)
```

6. Assemble the block proposal.
```python
proposal = Proposal(
    header,
    references,
    signature
)
```

  The PoL must have been generated beforehand and bound to the same Ledger view as mentioned in the [Prerequisites](#prerequisites).

The constructed proposal can now be broadcast to the network for validation.

## Block Proposal Reconstruction

Given a block proposal, we assume *transaction maturity*. This means that the block proposal must include transactions from the mempool that have had enough time to spread across the network to reach all nodes. This ensures that transactions are widely known and recognized before block reconstruction.

This transaction maturity assumption holds true because the block proposal must be sent through the Blend Network before it reaches validators and can be reconstructed. The Blend Network introduces significant delay, ensuring that transactions referenced in the proposal have reached all network participants. This approach is crucial for maintaining smooth network operation and reducing the risk that proposals get rejected due to transactions being unavailable to some validators. Moreover, by increasing the number of nodes that have seen the transaction, anonymity is also enhanced as the set of nodes with the same view is larger. This may result in increased difficulty—or even practical prevention—of executing deanonymization attacks such as tagging attacks.

Upon receipt of a block proposal, validators must confirm the presence of all referenced transactions within their local mempool. This verification is an absolute requirement—if even a single referenced transaction is missing from the validator's mempool, the entire proposal must be rejected. This stringent validation protocol ensures only widely-distributed transactions are included in the blockchain, safeguarding against potential network state fragmentation.

The process works as follows:

1. Transaction is added to the node mempool.
2. Node sends the transaction to all its neighbors.
3. Neighbors add the transaction to their own mempools and propagate it to their neighbors—transaction is gossiped throughout the network.
4. Block builder selects a transaction from its local mempool, which is guaranteed to be propagated through the network due to steps 1-3.
5. Block builder constructs a block proposal with references to selected transactions.
6. Block proposal is sent through the Blend Network, which requires multiple rounds of gossiping. This introduces a delay that ensures the transaction has reached most of the network participants' mempools.
7. Block proposal is received by validators.
8. Validators match each reference prefix in `references` against the transactions in their local mempool.
9. If every reference matches, the block proposal is reconstructed (resolving any prefix collisions as described below) and proceeds to further validation steps; otherwise the entire proposal is rejected.

### Prefix Collision Resolution

Because a reference is only an 8-byte (`REFERENCE_PREFIX_LENGTH`) prefix of the transaction hash, a single reference may match more than one transaction in a validator's mempool. The full-hash Merkle commitment in `header.block_root` still uniquely binds the proposal to one ordered transaction selection, so collisions affect only reconstruction cost, not correctness. Reconstruction is bounded by a single parameter:

```python
MAX_RECONSTRUCTION_COMBINATIONS = 1024  # maximum candidate combinations to try
```

The value is derived from a time budget rather than chosen arbitrarily. Trying one combination costs a Merkle root over at most `MAX_BLOCK_TXS` leaves, so the worst case is `MAX_RECONSTRUCTION_COMBINATIONS * MAX_BLOCK_TXS` evaluations of the general-purpose hash — the tree is built with `Hash`, not `zkhash`, since `block_root` is never verified inside a circuit. That is about $`10^{6}`$ hashes, which is a small fraction of a second and so a small fraction of the expected block interval of 30 slots at a slot length of 1 second ([Cryptarchia Protocol](cryptarchia-v1-protocol.md#protocol)).

The bound is deliberately conservative in two further respects: consecutive combinations differ in only a few leaves, so an implementation may cache the unchanged subtrees rather than recomputing a whole root each time, and a proposal that reaches this path at all is already exceptional (see [Construction Procedure](#construction-procedure)).

No separate per-reference cap is needed. A single reference with many candidates raises `N_comb` by the same factor, so the combination bound already covers it, and having only one bound removes any need to truncate a candidate set — which keeps the outcome identical across validators holding the same mempool.

Reconstruction considers every entry of `references`; the list has no padding. A proposal whose reference count exceeds `MAX_BLOCK_TXS` is rejected at decode time, as specified in [References](#references). For each reference `i`, the validator collects the candidate set of local mempool transactions whose hash prefix equals `references[i]`:

```python
C_i = [tx for tx in mempool if prefix(mantle_txhash(tx), REFERENCE_PREFIX_LENGTH) == references[i]]
```

The validator then proceeds as follows:

- If any `C_i` is empty, a referenced transaction is missing from the local mempool and the proposal is rejected.
- If the number of candidate combinations `N_comb = product(len(C_i) for all i)` exceeds `MAX_RECONSTRUCTION_COMBINATIONS`, the proposal is rejected.
- Otherwise the validator tries each combination, taking one candidate per reference. Reconstruction succeeds for the combination whose full transaction hashes reproduce `header.block_root`. If no combination reproduces `header.block_root`, the proposal is rejected.

Every outcome above is a function of the proposal and the validator's mempool alone, so two validators holding the same mempool always reach the same decision.

An honest proposal should never reach the second case, because a proposer bounds the ambiguity of its selection to `MAX_PROPOSAL_AMBIGUITY` against its own mempool (see [Construction Procedure](#construction-procedure)) and validators hold comparable mempools by the transaction maturity assumption above. Rejection there is a backstop against mempool divergence, not a routine path; the cost of deliberately provoking it is analysed in [Cost of provoking a reconstruction failure](#cost-of-provoking-a-reconstruction-failure).

### Binding of the reference list

Neither the reference entries nor their count are covered by `signature` or by `block_id`, both of which range over `header` only. `header.block_root` is therefore the **sole** mechanism binding a proposal to its reference list and to the number of references: any altered reference set, and any altered count, fails to reproduce `header.block_root` and the proposal is rejected. The argument is given in [Why `block_root` alone binds the reference list](#why-block_root-alone-binds-the-reference-list).

Two operational consequences follow:

- Tampered copies of a genuine proposal are cheap to produce, since `references` is unauthenticated. They are also cheap to discard: `block_id` is computable from the 297-byte header alone, so duplicate suppression on `block_id` collapses every tampered variant of one genuine proposal into a single unit of reconstruction work.
- Reconstruction must not be the first expensive step. It is bounded by `MAX_RECONSTRUCTION_COMBINATIONS`, but it should follow signature and PoL verification so that an unauthenticated proposal is discarded before any mempool scanning takes place.

## Block Proposal Validation

This section defines the procedure followed by a Logos Blockchain node to validate a received block proposal.

Given a `proposal`, a proposed block consisting of a `header`, `references` and a `signature`. This block proposal is considered valid if the following conditions are met, checked **in the order given** so that the cheapest checks discard a malformed or unauthenticated proposal first:

1. **Decoding**
  The received bytes must decode to a `proposal` under [Canonical Encoding](#canonical-encoding): the frame must be consumed exactly, with no trailing bytes, and the `references` element count must not exceed `MAX_BLOCK_TXS`. This check precedes any allocation proportional to the count and any mempool lookup.

2. **Block Validation**
  The `proposal` must satisfy the rules defined in [Block Header Validation](cryptarchia-v1-protocol.md#block-header-validation).

3. **Block Proposal Reconstruction**
  The `references` prefixes must resolve to a candidate combination of local mempool transactions that reproduces `header.block_root`, within the bound defined in [Prefix Collision Resolution](#prefix-collision-resolution).

4. **Mempool Transactions Validation**
  `mempool_transactions` must refer to a valid sequence of Mantle Transactions from the mempool. Each transaction must be valid according to the rules defined in the [Mantle](bedrock-v1.1-mantle-specification.md). In order to verify ZK proofs, they are batched for verification as explained in [Batch verification of ZK proofs](#batch-verification-of-zk-proofs) to get better performance.

If any of the above checks fail, the block proposal must be rejected.

## Block Execution

This section specifies how a Logos Blockchain node executes a valid block proposal to update its local state.

Given a `ValidBlock` that has successfully passed proposal validation, the node must:

1. Append the `leader_voucher` contained in the block to the set of reward vouchers **when the following epoch starts**.
2. Execute the reward distribution protocol defined in [**Service Reward Distribution Protocol**](bedrock-service-reward-distribution.md) to generate reward notes locally and include them in the ledger.
3. Execute the Mantle Transactions included in the block sequentially, using the execution rules defined in the [Mantle](bedrock-v1.1-mantle-specification.md).

# Annex

## Cost of provoking a reconstruction failure

`REFERENCE_PREFIX_LENGTH = 8` is sized against **targeted** grinding: producing a transaction whose prefix collides with one specific other transaction costs ≈ $`2^{64}`$ work. Provoking a reconstruction failure is a cheaper problem, because an attacker may collide their **own** transactions with each other, which is a birthday search over ≈ $`2^{32.5}`$ candidates for one colliding pair and ≈ $`2^{32.5}\sqrt{k}`$ for `k` pairs. Grinding a candidate is cheap: `mantle_txhash` covers the `MantleTx` alone and not the `op_proofs` of the enclosing `SignedMantleTx`, so a candidate costs one encoding and one hash, and only the pairs actually used are ever signed.

If such pairs could be selected into a proposal, `k` of them would give `N_comb = 2^k` and a modest `k` would exceed any bound a validator can afford to evaluate — raising `MAX_RECONSTRUCTION_COMBINATIONS` is no defence, since the attacker's work grows only as $`\sqrt{k}`$ while the validator's grows as `N_comb`.

This is why the validator's bound is not the defence. The `MAX_PROPOSAL_AMBIGUITY` rule in [Construction Procedure](#construction-procedure) caps the ambiguity at selection time, so ground pairs are simply never referenced in the quantity the attack needs, and the transactions passed over are the attacker's own.

Denying an *honest* transaction is a different and far dearer proposition. It requires a transaction colliding with that specific one, which is the targeted $`2^{64}`$ case the prefix length is chosen for, and it must be repeated whenever the sender rebroadcasts with any field altered, since that yields a fresh prefix. Exhausting the whole ambiguity budget with other people's transactions requires roughly $`\log_2`$(`MAX_PROPOSAL_AMBIGUITY`) such collisions at once. Note that a collision consumes budget rather than removing a transaction from consideration outright, so a victim colliding with one ground transaction remains selectable.

Two costs bound the attack further, though neither is what the design relies on. Both halves of a pair must coexist in a mempool without conflicting, which requires a distinct channel or funded note per transaction and therefore a one-time, fee-paying setup. Against that, an attacker whose transactions are never included never pays their fees, so the recurring cost is nil; only the setup is charged.

## Salted references

An alternative to bounding ambiguity at selection time is to make the reference derivation depend on the block, so that collisions cannot be ground in advance at all. Each reference would be derived as

```python
reference = prefix(Hash(salt, mantle_txhash(tx)), REFERENCE_PREFIX_LENGTH)
```

where `salt` is fixed by the header, `parent_block` concatenated with `slot` being the natural choice.

What this changes is the search space. Under the unsalted derivation an attacker grinds offline against a fixed function and may generate unboundedly many candidates. Under a salted one, the prefixes an attacker needs to collide only exist once the salt does, and by then the transactions must already be resident and mature in mempools — so the search is confined to transactions that are actually there. For a mempool of ≈ $`2^{20}`$ transactions the probability that any pair collides under a given salt is ≈ $`2^{-25}`$, and it is resampled every block rather than accumulating.

The salt need not be unpredictable, only unpredictable *in time to act on it*. `parent_block` and `slot` are known roughly one block interval ahead, which is ample GPU time for a birthday search, but a transaction ground during that window cannot propagate and reach maturity before the salt it was ground for is spent. `entropy_contribution` would be a worse choice, being leader-chosen and therefore grindable by the leader.

The cost is that reference prefixes can no longer be indexed once and reused. Both the proposer and every validator must derive one salted hash per candidate mempool transaction per proposal — on the order of $`2^{20}`$ hashes, tens of milliseconds, against a mempool of that size.

This is recorded as an alternative, not as an addition: it addresses the same failure as the `MAX_PROPOSAL_AMBIGUITY` rule in [Construction Procedure](#construction-procedure), and adopting it would make that rule unnecessary rather than reinforcing it. The rule in the Construction Procedure is the normative one. Salting would also dispense with the ambiguity budget altogether, and with it the question of how an adversary might consume that budget.

## Why `block_root` alone binds the reference list

This annex substantiates [Binding of the reference list](#binding-of-the-reference-list).

It is not the case that tampering with `references` is caught by the signature. An attacker who truncates or extends the list and adjusts the 2-byte count to match produces a frame that is still well-formed and whose header bytes are untouched, so `signature` still verifies. Framing gives unambiguity, not tamper-detection.

What rules the tampering out is `block_root`, in two steps:

1. `block_root` is a Merkle root over the **full** 32-byte transaction hashes, with the leaf set padded to the next power of two using all-zero leaves ([Block Header Validation](cryptarchia-v1-protocol.md#block-header-validation)). Changing the number of leaves across a power-of-two boundary changes the depth of the tree and therefore the root.
2. Within a boundary, an added leaf would have to hash to the all-zero value to leave the root unchanged. Reconstruction rejects any reference that resolves to no mempool transaction, so every leaf must be the hash of a real Mantle Transaction, and producing one whose hash is all-zero is infeasible.

Relative to a design that carries the count in the signed header, this removes one of two independent mechanisms rather than adding one: the count would be bound both by the signature and by `block_root`, and is now bound by `block_root` alone. That is an acceptable trade because the count is not a security binding. Its only role is to remove the parsing ambiguity between a genuine all-zero reference and zero padding, and an explicit length prefix removes that ambiguity directly, at the same cost in bytes and without a fixed-size layout.

## Batch verification of ZK proofs

### Proofs of Claim

1. For each proof of Claim, the verifier collects the classic Groth16 elements required for verification. It includes the proof $`\pi^{(i)}`$, and the public values $`x_j^{(i)}`$ for each proof of claim.
2. The verifier draws one random value for each proof $`r_i \overset{\$}{\leftarrow} \mathbb{F}_p`$.
3. The verifier computes:
1. $`\pi'_{j} := \sum_{i=1}^k r_i \cdot \pi_j^{(i)}`$ for $`j \in \{A,B,C\}`$.
2. $`r' := \sum_{i=1}^k r_i`$
3. $`IC := r' \cdot \Psi_0 + \sum_{j=1}^l\left( \sum_{i=1}^k r_i \cdot x_j^{(i)} \right) \cdot \Psi_j`$

4. They test if $`\sum_{i=1}^k e(r_1\pi'_A,\pi'_B) = e(r'[\alpha]_1,[\beta]_2)+ e(IC,[\gamma]_2) + e(\pi'_C,[\delta]_2)`$.

  Note that this batch verification of Groth16 proofs is the same as what is described in the Zcash paper, Appendix B.2.

### ZkSignatures

The verifier follows the same procedure as in [Proofs of Claim](#proofs-of-claim) but with the Groth16 proofs of ZkSignatures.
