> **Stacked PR.** The base of this PR is `Bedrock-RFC-Compressed-Block-Proposal`
> ([#389](https://github.com/logos-co/logos-lips/pull/389)), not `master`, so the diff shows
> only the revision. #389 must merge first. If #389 is merged or closed before this is
> reviewed, retarget to `master` and the diff will grow to include it.

## Reviewer Orientation

| # | Priority | Document / Change | What to look for |
| --- | --- | --- | --- |
| 1 | Critical | **Start here** — [Block Construction](#affected-specifications): [short IDs and key derivation](#1-keyed-short-transaction-ids-block-construction) | A reference becomes a keyed 64-bit SipHash-2-4 output instead of a 16-byte hash prefix. Confirm the key is derived only from **signed** header fields, that excluding `body_root` from the preimage is what breaks the selection↔key circularity, and that no key material reaches the wire. |
| 2 | Critical | **Start here** — [Block Construction](#affected-specifications): [reconstruction under ambiguity](#3-bounded-ambiguity-reconstruction-block-construction) | Resolution may now branch. Verify the per-reference candidate sets are genuinely disjoint, that `MAX_RECONSTRUCTION_COMBINATIONS` is checked **before** the search, and that at most one assignment can reproduce `body_root`. |
| 3 | High | [Block Construction](#affected-specifications): [security argument](#5-security-argument-block-construction-annex) | The whole case for 8 bytes rests on the key being unknowable before broadcast. Check the before/after-broadcast split, the claim that the birthday shortcut does not apply post-broadcast, and the leader-self-grinding argument. |
| 4 | Medium | [Block Construction](#affected-specifications): [builder collision pre-check](#2-builder-side-collision-pre-check-block-construction) | A MUST (duplicate short IDs in the selection) and a SHOULD (collisions against the builder's own mempool). Confirm the MUST is what licenses the decoder to treat a duplicate reference as tampering. |
| 5 | Medium | [Block Construction](#affected-specifications): [decode-time duplicate rejection](#4-decode-time-rejection-of-duplicate-references-block-construction) | New rejection rule. Confirm it is classified as condemning the *copy*, not the block. |
| 6 | Low | [Payload Formatting](#affected-specifications), [Message Formatting](#affected-specifications), [Blend Protocol](#affected-specifications) | Derived sizes only: 10000 / 10003 / ≈11.2%. Arithmetic check. |

## Status tracker

- [ ]  🚧 **Raw (make sure that all below is completed)**
    -  Template applied
    -  Authors filled in
    -  Authors agree on the RFC content
- [ ]  📘 **Draft (make sure that all below is completed)**
    -  All dependent specifications added (Notion backlinks checked)
    -  Specifications to deprecate added, if applicable
    -  Specifications to retire added, if applicable
    -  Research Lead assigned, or Project Lead assigned if the Research Lead is an author
    -  Relevant Research Domain Experts assigned (cannot be authors)
- [ ]  ⚙️ **Verified (make sure that all below is completed)**
    -  Researchers’ comments addressed
    -  All logical changes documented
    -  All Research reviewers approve the latest version
    -  Engineering Lead assigned
    -  Relevant Engineering Domain Experts assigned
- [ ]  🔀 **Merged (make sure that all below is completed)**
    -  Engineers’ comments addressed
    -  Every change added to the change log
    -  All Engineering reviewers approve the latest version
    -  Specification version numbers assigned
    -  Implementation reviewed and merged
    -  Branch updated to master and all conflicts resolved
    -  PR merged

## Change log

| **Revision** | **Description** | **Date** |
| --- | --- | --- |
| v1 | Initial PR description | 2026-08-20 |

# Motivation

[#389](https://github.com/logos-co/logos-lips/pull/389) shrank the block proposal by replacing full 32-byte transaction hashes with 16-byte prefixes. That prefix length is not a bandwidth choice — it is forced by an unkeyed construction. Because the prefix is a plain function of the transaction, an attacker can grind collisions **at leisure, before any block exists**, and a birthday search finds a colliding pair in ≈2^(b/2). At 8 unkeyed bytes that is ≈2³², under a second of GPU hashing, which is why #389 had to spend 16 bytes to reach a ≈2⁶⁴ birthday cost. Half of every reference is paying for an attack that only works because the function has no secret in it.

Keying the reference removes the precondition rather than out-running it. If the short ID is a keyed function under a key that does not exist until the proposal does, there is nothing to grind against in advance, and the birthday shortcut — which needs the attacker to collide two transactions of their own choosing — stops being useful, because after broadcast only collisions against the *referenced* IDs matter and those are a fixed target set. The reference can then be sized against a **targeted** search rather than a birthday one, and 8 bytes buys more margin keyed than 16 bytes buys unkeyed.

This is the same trade Bitcoin makes in [BIP-152](https://github.com/bitcoin/bips/blob/master/bip-0152.mediawiki) compact blocks, which has run keyed SipHash short IDs in an adversarial network for years.

# Proposal

A reference becomes an 8-byte **keyed short transaction ID**: the full 64-bit output of SipHash-2-4 over the transaction hash, under a 128-bit key specific to the proposal and derived from its own signed header:

```python
key    = prefix(Blake2b("REFKEY_V1", parent_block, slot, proof_of_leadership), 16)
ref_tx = SipHash24(k0, k1, mantle_txhash(tx))
```

The key is **derived, not carried** — it costs no wire bytes, is authenticated by `signature` and `block_id` exactly as the header is, and cannot be tampered with independently of the header. Because the preimage contains the `ProofOfLeadership` and leadership is anonymous until a proposal is published, nobody but the (still secret) leader can compute a future key at all.

Keying makes collisions possible in principle where #389 had ruled them out, so the handling returns in bounded form: the builder clears its selection of duplicate short IDs before publishing, and validators resolve residual ambiguity locally by trying candidate assignments against `header.body_root`, capped at `MAX_RECONSTRUCTION_COMBINATIONS = 64`. Failure to reconstruct stays local and provisional, exactly as #389 defined it.

The maximum proposal falls from **18,192 to 10,000 bytes** — 3.5× below the 34,574 of a full-hash layout carrying the same uncles — and the encapsulated Blend message from 19,318 to 11,126 bytes.

# Discussion

## Why 8 bytes and not BIP-152's 6

BIP-152 uses 48-bit short IDs. Adopting that here would save a further 2,048 bytes per proposal (~18% of the wire message, on **every** proposal, since Blend pads all of them to `Max_Body_Length`). It was analyzed and rejected. The sizes:

| short ID | proposal max | `Max_Payload_Length` | wire message | Blend overhead | vs. full-hash |
| --- | ---: | ---: | ---: | ---: | ---: |
| **8 B (chosen)** | 10,000 | 10,003 | 11,126 | 11.2% | 3.46× |
| 7 B | 8,976 | 8,979 | 10,102 | 12.5% | 3.85× |
| 6 B | 7,952 | 7,955 | 9,078 | 14.1% | 4.35× |

**Before broadcast, both sizes are safe** — that is what keying buys, and it does not depend on the ID length. Nothing can be ground against an unknown key, and pre-planting transactions to meet a future key needs 2^b/N residents for one expected hit: 2³⁸ at 6 bytes, 2⁵⁴ at 8. Dead either way.

**After broadcast, the two diverge sharply.** Once the key is public an attacker grinds a transaction colliding with one of the N referenced IDs — a *targeted* search at 2^b/N attempts, each costing one Blake2b over a candidate `MantleTx` (the birthday shortcut does not apply, because a collision between two attacker transactions that are not referenced is never consulted by resolution):

| | single collision, 100 GPUs | cap breach (~7 collisions) |
| --- | ---: | ---: |
| **6 B** | ~0.8–2.5 s | ~6–17 s |
| 7 B | ~1–2 min | ~8–14 min |
| **8 B** | ~5–14 h | ~1.5–4 days |

(Ranges span `MantleTx` sizes of 256 B–1 KB at 10¹⁰ single-block Blake2b/s per GPU; a multi-block transaction costs proportionally more per attempt.)

At 6 bytes the grind completes **inside the propagation window**. At 8 bytes it does not complete regardless of how long the window is — which is the decisive difference. 6 bytes would be secure *only* if the Blend delivery spread stays short, and that spread is a mix-network timing property, not a hardened security parameter. Keying was adopted precisely to stop depending on timing; 6 bytes would put the dependency back.

Three qualifications, recorded so the margin is not overstated:

- **The attacker has a second race to win**, which the table above does not price. A ground transaction is useless unless it reaches a validator's mempool *before that validator reconstructs* — so the attacker is racing the tail of the proposal's own propagation, from wherever they sit in the Blend spread. This makes 6 bytes harder to attack than the raw grind cost suggests, without making it safe.
- **The damage is bounded at any size.** A won collision forces only a *local, provisional* reconstruction failure — recoverable through chain synchronisation, with no verdict recorded against `block_id` — and must hit many validators at once to affect liveness. This is a liveness nuisance, not a safety break.
- **BIP-152's field record does not fully transfer.** Bitcoin recovers from an unresolvable short ID with an interactive `getblocktxn` re-request. Logos has no equivalent: a request for individual transactions can, in the case that matters, only be answered by the block builder, which makes it a leader-deanonymization oracle (the vector removed during #389 review). Note the asymmetry is about *recovery after the cap is breached*, not about disambiguation — collisions are resolved locally against `body_root` at any ID size.

**Honest-case cost, for completeness.** Chance ambiguity per validator per proposal is ≈ N·M/2^b: 2⁻³⁴ at 8 bytes (≈6 occurrences per year across a 10,000-validator network) against 2⁻¹⁸ at 6 bytes (≈360,000/year). Both are harmless — each is one reference with two candidates, settled by two `body_root` checks — and a chance cap breach is 2⁻²⁵¹ at 8 bytes: never.

There is one real argument *for* the shorter ID, recorded because it has an implementation consequence rather than a specification one: at 8 bytes the ambiguity path executes ≈6 times per year **network-wide**, i.e. it is effectively dead code in a consensus-critical position, first exercised in production under precisely the adversarial conditions it exists to handle. This is why the Implementation section requires test vectors for the two-candidate and cap-breach cases explicitly — production will not generate them.

**7 bytes** is the honest middle if bandwidth later becomes the binding constraint: 2⁴⁶ grind (minutes at 100 GPUs — marginal against the window rather than trivially inside it) for 1,024 bytes saved. It still trades unconditional safety for window-conditional safety, and it loses the native-integer encoding, so it is not proposed here.

## Why SipHash-2-4 rather than reusing Blake2b

The short ID needs pseudorandomness under an unpredictable key (PRF security), not cryptographic collision resistance — the collision resistance of the *commitment* is carried entirely by `body_root` over full hashes. SipHash-2-4 was designed as a keyed PRF for short inputs, specifically against hash-flooding denial of service, which is this threat shape exactly.

The cost that decides it is the validator's per-proposal mempool rehash, which cannot be cached across blocks because the key changes every block. Benchmarked on 32-byte inputs (Apple M4 Pro, pure-Rust implementations, median of 5×2,000,000 hashes):

| Function | ns/hash | rehash at M = 10⁶ |
| --- | ---: | ---: |
| **SipHash-2-4** | **13.0** | **13 ms** |
| SipHash-1-3 | 6.5 | 6.5 ms |
| Blake2b-512 truncated to 8 B | 81–86 | 81–86 ms |
| Blake2bMac, 8-byte output | 159 | 159 ms |

The ~6.4× gap is architectural rather than a property of this CPU: a 32-byte input costs SipHash four ARX absorption rounds, while Blake2b pays a full 12-round 128-byte-block compression however short the input is. Blake2b's *native keyed mode* is the worst option of the four, not the best — with a 16-byte key and a 32-byte message it processes two blocks where prefix-absorption processes one. SipHash-1-3's extra 2× buys nothing at 13 ms and has a thinner security margin, so 2-4 is chosen. Blake2b remains the only cryptographic hash in the construction; SipHash is a performance component keyed from it, as in BIP-152 (which derives its SipHash keys from SHA256 of the header).

> **TODO (author):** the benchmark and its report exist in the research repository working tree at `simulations/block-proposal/bench-shortid` and `reports/block-proposal/SipHash-vs-Blake2b-Short-IDs.md` but are **not yet committed**. Commit and link them before this PR leaves Draft.

## Why the key excludes `body_root`

Deriving the key from the whole header would be circular: `body_root` commits to the transaction selection, the selection depends on the short IDs, and the short IDs depend on the key. Restricting the preimage to `parent_block`, `slot` and `proof_of_leadership` — all fixed before selection begins — breaks the loop while keeping every input inside the signed header.

A leader can know its own winning slots in advance and therefore its own future keys, and could grind collisions under them at birthday cost. This is harmless: a key is used only by its own proposal, so the only block such a leader can make unreconstructible is its own, which achieves exactly what not proposing achieves. `MAX_RECONSTRUCTION_COMBINATIONS` is what keeps this a self-inflicted denial of service rather than a validator-CPU attack, by capping the search a malicious leader can impose at 64 body-root evaluations per proposal.

# Details

## 1. Keyed short transaction IDs (Block Construction)

`References` is respecified from a truncation of the transaction hash to a keyed function of it. The prefix helper and its parameter are removed; `SHORT_ID_LENGTH` and the key derivation replace them.

```diff
-REFERENCE_PREFIX_LENGTH = 16   # bytes
-
-def prefix(hash_input: bytes, length: int) -> bytes:
-    return hash_input[:length]
+SHORT_ID_LENGTH = 8                   # bytes: the full SipHash-2-4 output
+MAX_RECONSTRUCTION_COMBINATIONS = 64  # see Reference Resolution
+
+def reference_key(header) -> (uint64, uint64):
+    material = hash(b"REFKEY_V1",
+                    header.parent_block,
+                    encode(header.slot),                  # UINT64, little-endian
+                    encode(header.proof_of_leadership))   # 224 bytes, wire order
+    return uint64_le(material[0:8]), uint64_le(material[8:16])
+
+def short_id(k0: uint64, k1: uint64, tx) -> bytes:
+    return encode(SipHash24(k0, k1, mantle_txhash(tx)))   # UINT64, little-endian
```

The full SipHash output is used with no truncation, so a reference is a native little-endian `UINT64` on the wire and the canonical encoding gains a primitive rather than a new byte-string terminal:

```diff
-Reference         = 16BYTE          ; REFERENCE_PREFIX_LENGTH bytes
+Reference         = UINT64          ; short transaction ID: full SipHash-2-4 output
```

A new paragraph states the three properties of deriving rather than carrying the key: no wire bytes, authentication inherited from the header, and unpredictability before broadcast. SipHash is introduced in the **Hash** section as a keyed PRF explicitly distinguished from the two cryptographic hashes, with its key derived by Blake2b so that Blake2b remains the sole cryptographic primitive.

## 2. Builder-side collision pre-check (Block Construction)

Construction step 3 replaces the note that no collision avoidance is needed:

```diff
-  No prefix-collision avoidance is needed at selection time. At `REFERENCE_PREFIX_LENGTH = 16`
-  a collision between two distinct transaction hashes is infeasible to encounter or to
-  manufacture [...]
+3. Derive the reference key and the short IDs, and clear the selection of collisions:
+   k0, k1 = reference_key(header)   # parent_block, slot and the PoL are already set
+   references = [short_id(k0, k1, tx) for tx in mempool_transactions]
```

Two rules attach:

- **MUST** — the selection may not contain two transactions with the same short ID; on a duplicate, drop or replace one and recompute. Under an honest key this fires with probability ≈ N²/2⁶⁵ (below 2⁻⁴⁵ at `MAX_BLOCK_TXS`). Its purpose is not collision avoidance but licensing the decoder rule in §4.
- **SHOULD** — the builder should also avoid selecting a transaction that collides with any *other* transaction in its own mempool, which would resolve ambiguously at every validator holding both. Best effort: the builder cannot see other mempools, and §3 handles what it cannot prevent.

## 3. Bounded-ambiguity reconstruction (Block Construction)

**Reference Resolution** is rewritten. Resolution begins with a per-proposal mempool rehash under the derived key, producing candidate sets:

```python
def resolve_candidates(proposal, mempool):
    k0, k1 = reference_key(proposal.header)
    index = {}                                   # short ID -> local transactions
    for tx in mempool:
        index.setdefault(short_id(k0, k1, tx), []).append(tx)
    return [index.get(r, []) for r in proposal.references]
```

Each reference then has exactly one candidate (the overwhelming majority), none (absent locally), or several (a collision). Ambiguity is resolved rather than rejected, by a bounded search:

```python
def reconstruct(proposal, candidates):
    if any(len(c) == 0 for c in candidates):
        return None            # missing transaction: not reconstructible here
    if product(len(c) for c in candidates) > MAX_RECONSTRUCTION_COMBINATIONS:
        return None            # ambiguity beyond the bound: not reconstructible here
    for assignment in cartesian_product(candidates):
        if body_root(proposal.uncle_headers, assignment) == proposal.header.body_root:
            return assignment  # the committed selection; unique
    return None                # no assignment matches: corrupted or malformed
```

Three properties make this safe and deterministic, and are argued in the spec:

- **Candidate sets are disjoint** across references — distinct references are distinct short IDs (§4), and a transaction has exactly one short ID under a given key — so the combinations are an independent per-reference choice and the product is the exact search size.
- **At most one assignment can match**, because two assignments differ in at least one full 32-byte hash and `body_root` binds them all; the order of enumeration is therefore irrelevant.
- **The bound is checked before the search**, so the work is capped at 64 body-root evaluations regardless of the candidate structure. Successive combinations can be evaluated by recomputing one Merkle leaf path rather than the whole tree.

Cap-exceeded joins missing-transaction as a **local, provisional** outcome: both are properties of the local mempool, so neither may be recorded as a verdict against `block_id`. This extends, rather than modifies, the classification introduced in #389.

## 4. Decode-time rejection of duplicate references (Block Construction)

A decoder must reject a `references` list containing the same value twice, alongside the existing `MAX_BLOCK_TXS` bound. §2's MUST guarantees an honest proposal never carries duplicates, so a duplicate marks the copy as tampered or dishonestly built; rejecting at decode closes the cheapest way to inflate reconstruction work. Like every check on bytes outside the header, this condemns the received copy, not the block.

Validation step 1 gains the rule; the reconstruction-cost bullet under **Binding of the reference list** additionally notes that each distinct `block_id` admitted past signature and PoL verification triggers at most one mempool rehash, and that implementations should bound reconstruction attempts per slot against an equivocating leader.

## 5. Security argument (Block Construction, Annex)

The annex **Prefix length and collision resistance** is replaced by **Short ID keying and collision resistance**, restructured around the key rather than the length: the BIP-152 correspondence and its two deliberate departures (64 bits rather than 48; a bounded local search rather than `getblocktxn`), the before/after-broadcast split, the leader-self-grinding argument, the chance-collision rates, and the SipHash-2-4 rationale. The substance is summarized in [Discussion](#discussion).

## 6. Derived sizes (Payload Formatting, Message Formatting, Blend Protocol)

- **Payload Formatting** — `Max_Body_Length` 18192 → 10000.
- **Message Formatting** — no formula change; the derived value tracks to 10003. (Expressing it as `Max_Body_Length + 3` in #389 is what spares this file an edit to its normative text.)
- **Blend Protocol** — encapsulation overhead recomputed against `Max_Payload_Length`: `1123 / 10003 ≈ 11.2%` (was ≈6.2% over 18,195 bytes). Informational.

# Implementation

- [ ]  Add a keyed short-ID module: SipHash-2-4 over `mantle_txhash`, `SHORT_ID_LENGTH = 8`, full 64-bit output as a little-endian `u64`. Replaces `REFERENCE_PREFIX_BYTES` and the prefix helper.
- [ ]  Implement `reference_key`: `Blake2b("REFKEY_V1", parent_block, slot, encode(proof_of_leadership))`, first 16 bytes as `(k0, k1)`. Assert the preimage excludes `body_root`.
- [ ]  Change the proposal reference type to `u64` and update the canonical encoding to emit/parse it as `UINT64`.
- [ ]  Proposal construction: derive the key before transaction selection, compute short IDs during selection, enforce the duplicate-free MUST, and apply the own-mempool-collision SHOULD.
- [ ]  Reference resolution: build the per-proposal short-ID index over the mempool, form candidate sets, enforce `MAX_RECONSTRUCTION_COMBINATIONS = 64` **before** enumerating, and verify assignments against `body_root` with incremental Merkle recomputation.
- [ ]  Classify cap-exceeded and missing-transaction failures as local and provisional — no verdict recorded against `block_id` — consistent with the existing reconstruction-failure handling.
- [ ]  Reject duplicate references at decode time, on every ingress path, before allocation or mempool lookup.
- [ ]  Bound reconstruction attempts per slot, so an equivocating leader cannot force one mempool rehash per distinct `block_id` without limit.
- [ ]  Update `Max_Body_Length` to 10000; confirm `Max_Payload_Length` derives to 10003 with no separate constant.
- [ ]  Add or extend tests / test vectors: key-derivation vectors; short-ID vectors; codec round-trip for `UINT64` references; rejection of duplicate references and of over-large counts; **a proposal with a forced two-candidate reference**; **a proposal that breaches `MAX_RECONSTRUCTION_COMBINATIONS`**. The last two will not occur in production at 8 bytes (≈6 network-wide per year), so they must be constructed deliberately.
- [ ]  Verify the implementation matches this specification (proposal size = 364..10,000 bytes; key derived, never carried; reconstruction accepts iff some assignment reproduces `body_root` within the bound).

# Affected Specifications

| Specification | Status | Note |
| --- | --- | --- |
| [Block Construction, Validation and Execution](docs/blockchain/raw/bedrock-v1.1-block-construction.md) | Modified | Primary change (v1.4.0): keyed short IDs, key derivation, builder pre-check, bounded-ambiguity reconstruction, duplicate rejection, rewritten security annex. |
| [Payload Formatting](docs/blockchain/raw/payload-formatting.md) | Modified | `Max_Body_Length` 18192 → 10000. |
| [Message Formatting](docs/blockchain/raw/message-formatting.md) | Modified | Derived value tracks to 10003; no formula change. |
| [Blend Protocol](docs/blockchain/raw/blend-protocol.md) | Modified | Encapsulation overhead recomputed: ≈11.2%. |
| [Cryptarchia Protocol](docs/blockchain/raw/cryptarchia-v1-protocol.md) | Unchanged | Deliberately untouched: `body_root`, the `block_id` preimage and `Header` are unaffected — the change is confined to how `references` name transactions. Flagged so the omission can be checked rather than assumed. |

🤖 Generated with [Claude Code](https://claude.com/claude-code)
