# NOMOS-PROOF-OF-QUOTA

| Field | Value |
| --- | --- |
| Name | Nomos Proof of Quota Specification |
| Slug | 88 |
| Status | raw |
| Category | Standards Track |
| Editor | Mehmet Gonen <mehmet@logos.co> |
| Contributors | Marcin Pawlowski <marcin@logos.co>, Thomas Lavaur <thomaslavaur@logos.co>, Youngjoon Lee <youngjoon@logos.co>, David Rusu <davidrusu@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/nomos-proof-of-quota.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/nomos-proof-of-quota.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

Authors: Mehmet Gonen <mehmet@status.im>, Marcin Pawlowski <marcin@status.im>, Thomas Lavaur <thomaslavaur@status.im>

# Revisions History

# Introduction

This document defines an implementation-friendly specification of the Proof of Quota (PoQ), which is introduced in [����[1.0.0] Blend Protocol - Proof of Quota](https://nomos-tech.notion.site/Proof-of-Quota-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df81edb561ef75a31f65a4).

# Overview

The PoQ ensures that there is a limited number of message encapsulations that a node can perform. This constrains the number of messages a node can introduce to the Blend network. The mechanism regulating these messages is similar to [rate-limiting nullifiers](https://rate-limiting-nullifier.github.io/rln-docs/rln.html).

# Construction

The Proof of Quota (PoQ) verifies that a node's public key is within a limit for either a core node or a leader node. It consists of two parts:

1. Proof of Core Quota (PoQ_C): Ensures that the core node is declared and hasn���t already produced more keys than the core quota Q_C.
1. Proof of Leadership Quota (PoQ_L): Ensures that the leader node would win the proof of stake for current Cryptarchia epoch and hasn���t already produced more keys than the leadership quota Q_L. That doesn���t guarantee that the node is indeed winning because the PoQ doesn���t check if the note is unspent enabling generation of the proof ahead of time preventing extreme delays.

The final proof PoQ is valid if either PoQ_C or PoQ_L holds.

## Zero-Knowledge Proof Statement

### Public values

A proof attesting that for the following public values derived from blockchain parameters:

```
class ProofOfQuotaPublic:
		session: int # Session number (uint64)
		core_quota: int # Allowed messages per session for core nodes (20 bits)
		leader_quota: int # Allowed messages per session for potential leaders (20 bits)
		core_root: zkhash     # Merkle root of zk_id of the core nodes
		K_part_one: int # First part of the signature public key (16 bytes)
		K_part_two: int # Second part of the signature public key (16 bytes)
		pol_epoch_nonce: int # PoL Epoch nonce
		pol_t0: int # PoL constant t0
		pol_t1: int # PoL constant t1
		pol_ledger_aged: zkhash # Merkle root of the PoL eligible notes
# Outputs:
		key_nullifier: zkhash   # derived from session, private index and private sk
```

### Witness

The prover knows a witness:

```
class ProofOfQuotaWitness:
		index: int # This is the index of the generated key. Limiting this index limits the maximum number of key generated. (20 bits)
		selector: bool # Indicates if it's a leader (=1) or a core node (=0)
# This part is filled randomly by potential leaders
		core_sk: zkhash                       # sk corresponding to the zk_id of the core node
		core_path: list[zkhash] # Merkle path proving zk_id membership (len = 20)
		core_path_selectors: list[bool] # Indicates how to read the core_path (if Merkle nodes are left or right in the path)
# This part is filled randomly by core nodes
		pol_sl: int # PoL slot
		pol_secret_key: int # PoL note secret key
		pol_note_value: int # PoL note value
		pol_note_tx_hash: zkhash              # PoL note transaction 
		pol_note_output_number: int # PoL note transaction output number
		pol_noteid_path: list[zkhash] # PoL Merkle path proving noteID membership in ledger aged (len = 32)
		pol_noteid_path_selectors: list[bool] # Indicates how to read the note_path (if Merkle nodes are left or right in the path)
```

> Note that every inputs and outputs of zero-knowledge proofs are all scalar field elements.

### Constraints

Such that the following constraints hold:

Step 1: The prover selects an index for the chosen key. This index must be lower than the allowed quota and not already used. This index is used to derive the key nullifier in step 4. Limiting the possible values of this index also limit the possible nullifier created which produce the desired effect: limiting the generation of keys to a certain quota. index will be on 20 bits enabling up to $2^{20}$ messages per node per session.

Step 2:  If the prover indicated that the node is a core node for the proof, the proof checks that:

Step 3: If the prover indicated that the node is a potential leader node for the proof, the proof checks that:

Step 4: The prover derives a key_nullifier maintained by blend nodes during the session for message deduplication purpose.

Step 5: The prover attaches a one-time signature key used in the blend protocol. This public key is split into two 16-byte parts: K_part_one and K_part_two. When written in little-endian byte order, the complete public key equals the concatenation K_part_one||K_part_two.

### Pseudocode

```
# Verify selector is a boolean
# selector = 1 if it's a potential leader and 0 if it's a core node
selector * (1 - selector) == 0 # to check that selector is indeed a bit.
# Verify index is lower than quota. It's exactly like saying index < leader_quota
# if selector == 1 or index < core_quota if selector == 0
index < selector * (leader_quota - core_quota) + core_quota

# Check if it's a registered core node
zk_id = zkhash(b"KDF", core_sk)
is_registered = merkle_verify(core_root, core_path, core_path_selectors, zk_id)
# Check if it's a potential leader
is_leader = would_win_leadership(pol_epoch_nonce,
		pol_t0,
		pol_t1,
		pol_ledger_aged,
		pol_sl,
		pol_secret_key,
		pol_sk_secrets_root,
		pol_note_value,
		pol_note_tx_hash,
		pol_note_output_number,
		pol_noteid_path,
		pol_noteid_path_selectors)
# Verify that it's a core node or a leader
assert( selector * (is_leader - is_registered) + is_registered == 1)
# Derive nullifier
selection_randomness = zkhash(
b"SELECTION_RANDOMNESS_V1",
		selector * (pol_secret_key - core_sk) + core_sk,
		index,
		selector * (pol_sl - session) + session)
key_nullifier = zkhash(b"KEY_NULLIFIER_V1", selection_randomness)
```

## Proof Compression

The proof confirming that the PoQ is correct must be compressed to a size of 128 bytes, where the UncompressedProof is comprising of 2  $\mathbb{G}_1$ and 1  $\mathbb{G}_2$ BN256 elements as presented below.

```
class UncompressedProof:
   pi_a: G1 # BN256 element 
   pi_b: G2 # BN256 element
   pi_c: G1 # BN256 element
```

## Proof Serialization

The ProofOfQuota structure contains key_nullifier and the compressed proof transformed in bytes according [����[1.0.2] Common Cryptographic Components - Use in the Logos Blockchain:](https://nomos-tech.notion.site/Use-in-the-Logos-Blockchain-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24#209261aa09df80b8aec6cc763573ff69). The key_nullifier must be transformed into bytes. The bytes of the compressed proof are then concatenated together with the bytes representing the key_nullifier, with the encoded key_nullifier preceding the encoded compressed proof. Reconstruction of a serialized ProofOfQuota interpreting the bytes as the concatenation of the key_nullifier and of the compressed proof following the same rule of conversion.

```
class ProofOfQuota:
  key_nullifier: zkhash # 32 bytes
  proof: bytes # 128 bytes
```

# Appendix

## Benchmarks

The material used for the benchmarks is the following:

- CPU: 13th Gen Intel(R) Core(TM) i9-13980HX (24 cores / 32 threads)
- RAM: 32GB - Speed: 5600 MT/s
- Motherboard: Micro-Star International Co., Ltd. MS-17S1
- OS: Ubuntu 22.04.5 LTS
- Kernel: 6.8.0-59-generic

![](https://nomos-tech.notion.site/image/attachment%3Aa2fcd60c-7778-4aa3-9bcf-0e5299e31e16%3Aoutput_(2).png?table=block&id=2e9261aa-09df-8023-91a7-e7f6c11c4056&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

