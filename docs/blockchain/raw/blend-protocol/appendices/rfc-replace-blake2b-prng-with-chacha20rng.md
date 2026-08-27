# [RFC] Replace the BLAKE2b-Based PRNG with ChaCha20 (ChaCha20Rng)

**Authors:** David Rusu
**Approvals (research):**
**Approvals (engineering):**

---

## Reviewer Orientation

Read [Motivation](#motivation) first; no other background is required beyond the three linked specifications.

| # | Priority | Document / Change | What to look for |
| --- | --- | --- | --- |
| 1 | Critical | **Start here** — [Common Cryptographic Components](../../common-cryptographic-components.md#blake2b-based-prng-construction) — the PRNG construction is replaced ([Details §1](#1-common-cryptographic-components--replace-the-prng-construction)) | the new ChaCha20 keystream definition; the seed narrowing from 64 to 32 bytes |
| 2 | Critical | [Message Encapsulation](../../message-encapsulation.md) — `CSPRBG` reseated on ChaCha20 ([Details §2](#2-message-encapsulation--csprbg-notation-and-pseudocode)) | every keystream (`E_k`/`D_k`, fillers, header randomization) changes value; zero-nonce safety argument |
| 3 | High | [Blend Protocol](../../blend-protocol.md#notation) — `CSPRNG` notation and Proof of Selection ([Details §3](#3-blend-protocol--csprng-notation-and-proof-of-selection)) | node index `m_i` derivation changes value; little-endian and modulo-bias analysis are unaffected |

## Status tracker

- [ ]  🚧 **Raw (make sure that all below is completed)**
    -  Template applied
    -  Authors filled in
    -  Authors agree on the RFC content
- [ ]  📘 **Draft (make sure that all below is completed)**
    -  All dependent specifications added
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
| v1 | Initial PR description | 2026-08-28 |

# Motivation

The Blend protocol and its message encapsulation scheme draw all deterministic randomness from a home-grown construction: BLAKE2b run in counter mode over a 64-byte seed ([BLAKE2b-Based PRNG Construction](../../common-cryptographic-components.md#blake2b-based-prng-construction)). Beyond ordinary pseudo-random sampling (e.g., node index selection in Proof of Selection), this construction is used directly as an encryption keystream: [Message Encapsulation](../../message-encapsulation.md) defines `E_k(x) = CSPRBG(k) ⊕ x`, i.e., the PRNG output is a stream cipher protecting blend payloads and headers.

While no weakness is known in hashing with BLAKE2b in counter mode, the construction is bespoke: it has received no dedicated cryptanalysis as a stream cipher, has no published test vectors, and every implementation of the protocol must hand-roll it. ChaCha20 is a standardized, extensively analyzed stream cipher designed for exactly this use, with mature, audited implementations in every mainstream language (in Rust, `ChaCha20Rng` from the `rand_chacha` crate) and well-known test vectors. Switching removes a bespoke cryptographic construction from the protocol's trusted surface and replaces an ad-hoc hash-based cipher with a real one, at equal or better performance.

# Proposal

Replace the BLAKE2b-Based PRNG Construction with the ChaCha20 keystream. Concretely, redefine

```text
CSPRBG(seed) = ChaCha20Keystream(key = seed[0..32], nonce = 0, initial_counter = 0)
```

using ChaCha20 in Bernstein's original variant (20 rounds, 256-bit key, 64-bit nonce, 64-bit block counter). This is byte-for-byte the output of Rust's `rand_chacha::ChaCha20Rng::from_seed(key)` with the default stream identifier. Consumers take the first `n` bytes (or `k` bits, truncating the last byte) of the keystream, exactly as they do today.

All call sites keep their current formulas — `E_k`/`D_k`, filler generation, header randomization, and the Proof of Selection index `m_i = CSPRNG(H_N(ρ))_8 mod N` are unchanged as written — but every produced value changes because the underlying keystream changes. The only structural change is at the seeding boundary: ChaCha20 takes a 256-bit key, so the 64-byte BLAKE2b digests currently used as seeds are truncated to their first 32 bytes.

The affected specifications are [Common Cryptographic Components](../../common-cryptographic-components.md), [Message Encapsulation](../../message-encapsulation.md), and the [Blend Protocol](../../blend-protocol.md).

# Discussion

## Security

- **Fitness for purpose.** The dominant use of the PRNG is as an encryption keystream (`E_k(x) = CSPRBG(k) ⊕ x`). XOR-with-keystream is precisely the ChaCha20 cipher's intended mode of use and the object of its cryptanalysis; for BLAKE2b-in-counter-mode it is an improvised cipher whose security rests on general PRF assumptions about the hash rather than targeted analysis.
- **Zero nonce is safe here.** Keystream security with a fixed nonce requires that no key be reused across two different plaintext streams. The protocol already guarantees this: every keystream is keyed by a domain-separated hash of a per-encapsulation shared secret (see the keystream-uniqueness note in [Message Encapsulation](../../message-encapsulation.md), "the uniqueness of the key stream is preserved as the encryption is done on a domain separated checksum of the shared key"). The same argument that makes the current construction safe (unique seed per use) makes the fixed-nonce ChaCha20 keystream safe.
- **Seed narrowing (64 → 32 bytes).** Truncating a BLAKE2b-512 digest to 32 bytes yields a uniform 256-bit key; 256-bit security matches the security level targeted everywhere else in the protocol, so no effective security is lost. The alternative — re-parameterizing the `H_N`/`H_I`/`H_b`/`H_P` hash functions to 32-byte output — was rejected to keep the change confined to a single site (the `CSPRBG` definition) and to leave the house-wide `Blake2B.hash512` domain-separation convention untouched.

## Alternatives considered

- **Status quo (BLAKE2b counter mode).** Not broken, but carries the assurance and implementation costs stated in Motivation for no offsetting benefit.
- **IETF ChaCha20 (RFC 8439: 96-bit nonce, 32-bit counter).** Functionally equivalent for our fixed-nonce use, but its 32-bit counter caps a single keystream at 256 GiB and, more importantly, it does not match the default construction of `ChaCha20Rng` and its ecosystem of compatible RNG implementations. The DJB variant is chosen so that "use `ChaCha20Rng` off the shelf" is a correct implementation.
- **XChaCha20.** The extended nonce buys nothing when the nonce is fixed at zero.

## Compatibility and rollout

This is a wire-value-breaking change with an unchanged wire format: message sizes, layouts, and serialization are identical, but every keystream, filler, randomized header, and Proof of Selection index takes a different value. A node running the old construction cannot decapsulate messages from, or verify selections of, a node running the new one. The change must therefore ship as a coordinated protocol version bump (or before any deployed network exists); no gradual migration path is possible or needed.

## Ancillary properties

- The keystream is a byte stream; the existing `CSPRBG()_8` / little-endian conventions apply unchanged.
- The modulo-bias analysis in [Blend Protocol](../../blend-protocol.md#statistical-analysis-of-selection-bias-of-modulo-operation) depends only on the generator being uniform over its output width and is unaffected.
- Performance is equal or better: both primitives are ARX designs, and ChaCha20 produces 64 bytes per block permutation without the finalization overhead of a full hash evaluation per block; `ChaCha20Rng` additionally ships SIMD backends. The keystream is also cheaply seekable, which the counter-mode construction only achieves by recomputation.

# Details

## 1. Common Cryptographic Components — replace the PRNG construction

Replace the [BLAKE2b-Based PRNG Construction](../../common-cryptographic-components.md#blake2b-based-prng-construction) section with a **ChaCha20-Based PRNG Construction**:

```diff
-PRNG(seed, i) = BLAKE2b(seed || encode_u64(i), out_len=64)
+PRNG(seed) = ChaCha20Keystream(key = seed[0..32], nonce = 0, initial_counter = 0)
```

The new section text specifies:

- ChaCha20 is used in its original variant: 20 rounds, 256-bit key, 64-bit nonce (fixed to zero), 64-bit block counter (starting at zero).
- seed: when the available seed material is longer than 32 bytes (e.g., a 64-byte BLAKE2b digest), the key is its first 32 bytes.
- This construction is byte-for-byte the output of `ChaCha20Rng` (Rust crate `rand_chacha`) seeded with the key, using the default stream identifier.

Output rules are unchanged in substance:

- For generating `n` bytes, take the first `n` bytes of the keystream.
- For generating `k` bits, take `ceil(k/8)` bytes and truncate the last byte to the required bit-length.

Normative safety requirement (carried over and made explicit): a seed MUST NOT be reused across two different generation contexts; seed uniqueness and domain separation are handled at the protocol level, as today.

Also update the component recommendation table:

```diff
 | Context | Recommended Component |
 | --- | --- |
 | ZK Hashing | [Poseidon2](#poseidon2-zk-friendly-hash-function) |
-| General Hashing & PRNG | [BLAKE2b](#blake2bgeneral-purpose-hashing) |
+| General Hashing | [BLAKE2b](#blake2bgeneral-purpose-hashing) |
+| PRNG & Keystreams | [ChaCha20](#chacha20-based-prng-construction) |
```

## 2. Message Encapsulation — `CSPRBG` notation and pseudocode

In the [Notation](../../message-encapsulation.md#notation) section, repoint the `CSPRBG()` / `CSPRBG()_x` definitions at the new construction and update the reference pseudocode:

```diff
 def pseudo_random(domain: bytes, key: bytes, size: int) -> bytes:
-    rand = BlakeRng.from_seed(hashds(domain, key)).generate(size)
+    rand = ChaCha20Rng.from_seed(hashds(domain, key)[:32]).generate(size)
     assert len(rand) == size
     return rand
```

The `E_k`/`D_k` definitions, filler generation (`r_{t,1..4}`), private-header randomization, and node selection (`l_i`) formulas are textually unchanged; their values change because the keystream changes. The `H_N`/`H_I`/`H_b`/`H_P` hash functions are unchanged (still `Blake2B.hash512` with their existing domain tags); only the first 32 bytes of their output are consumed as the ChaCha20 key.

## 3. Blend Protocol — `CSPRNG` notation and Proof of Selection

- In [Notation](../../blend-protocol.md#notation): `CSPRNG()` is now "implemented as a ChaCha20-Based PRNG Construction", linking to the new section.
- In [Proof of Selection](../../blend-protocol.md#proof-of-selection): the formula `m_i = CSPRNG(H_N(ρ))_8 mod N` is unchanged as written; the 8-byte output is now the first 8 bytes of the ChaCha20 keystream seeded with `H_N(ρ)[0..32]`, still interpreted little-endian. The modulo-bias analysis section requires no change.

## Chores

- Rename all remaining textual references to "BLAKE2b-Based PRNG" across the three specifications.
- Update the anchor `#blake2b-based-prng-construction` and all inbound links to the new section anchor.
- In the Blend Protocol's [modulo-bias analysis](../../blend-protocol.md#statistical-analysis-of-selection-bias-of-modulo-operation), update the parenthetical "(here the Blake2b hash function)" to name the ChaCha20 keystream; the analysis itself is unchanged.

# Implementation

- [ ]  Implement `CSPRBG` on `ChaCha20Rng` (`rand_chacha`), seeded with the first 32 bytes of the domain-separated BLAKE2b digest, replacing the `BlakeRng` counter-mode implementation
- [ ]  Update Proof of Selection node-index derivation (`m_i`) and its verification to the new generator
- [ ]  Update message encapsulation/decapsulation (payload and header keystreams, fillers, header randomization) to the new generator
- [ ]  Add cross-implementation test vectors: `CSPRBG` outputs for known seeds (checked against the ChaCha20 keystream / `ChaCha20Rng` reference), full encapsulate→decapsulate round trips, and `m_i` selection vectors
- [ ]  Remove the `BlakeRng` implementation once no call sites remain
- [ ]  Verify the implementation matches this specification

# Affected Specifications

| Specification | Status | Note |
| --- | --- | --- |
| [Common Cryptographic Components](../../common-cryptographic-components.md) | Modified | PRNG construction replaced; recommendation table updated |
| [Message Encapsulation](../../message-encapsulation.md) | Modified | `CSPRBG` notation/pseudocode reseated on ChaCha20; all keystream values change |
| [Blend Protocol](../../blend-protocol.md) | Modified | `CSPRNG` notation and Proof of Selection generator updated |
| [Proof of Quota](../../proof-of-quota.md) | — | Unchanged (source of `ρ`); listed for reviewer attention to confirm no PRNG dependency |
