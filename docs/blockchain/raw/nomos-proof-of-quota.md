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

---

> **Note on this content sync:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) via katex; tables and headings
> are converted from Notion HTML. Formatting polish (semantic line breaks, code block fences,
> internal cross-references) may still be needed.

---

## Revisions History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2026-04-09 |
| 1.0.1 | Remove the protection against adaptive adversary from PoL. It impacts the PoL section of PoQ. Update the performance according to the new circuit. Remove the notion of NOMOS in DSTs | 2026-04-09 |

## Introduction

This document defines an implementation-friendly specification of the Proof of Quota (PoQ), which is introduced in [[1.0.0] Blend Protocol - Proof of Quota](https://nomos-tech.notion.site/Proof-of-Quota-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df81edb561ef75a31f65a4).

## Overview

The PoQ ensures that there is a limited number of message encapsulations that a node can perform. This constrains the number of messages a node can introduce to the Blend network. The mechanism regulating these messages is similar to [rate-limiting nullifiers](https://rate-limiting-nullifier.github.io/rln-docs/rln.html).

## Construction

The Proof of Quota (PoQ) verifies that a node's public key is within a limit for either a core node or a leader node. It consists of two parts:

Proof of Core Quota (

PoQ\_C

): Ensures that the core node is declared and hasnt already produced more keys than the core quota

Q\_C

.

Proof of Leadership Quota (

PoQ\_L

): Ensures that the leader node would win the proof of stake for current Cryptarchia epoch and hasnt already produced more keys than the leadership quota

Q\_L

. That doesnt guarantee that the node is indeed winning because the PoQ doesnt check if the note is unspent enabling generation of the proof ahead of time preventing extreme delays.

The final proof

PoQ

is valid if either

PoQ\_C

or

PoQ\_L

holds.

### Zero-Knowledge Proof Statement

#### Public values

A proof attesting that for the following public values derived from blockchain parameters:

class ProofOfQuotaPublic:
session: int # Session number (uint64)
core\_quota: int # Allowed messages per session for core nodes (20 bits)
leader\_quota: int # Allowed messages per session for potential leaders (20 bits)
core\_root: zkhash # Merkle root of zk\_id of the core nodes
K\_part\_one: int # First part of the signature public key (16 bytes)
K\_part\_two: int # Second part of the signature public key (16 bytes)
pol\_epoch\_nonce: int # PoL Epoch nonce
pol\_t0: int # PoL constant t0
pol\_t1: int # PoL constant t1
pol\_ledger\_aged: zkhash # Merkle root of the PoL eligible notes
# Outputs:
key\_nullifier: zkhash # derived from session, private index and private sk

#### Witness

The prover knows a witness:

class ProofOfQuotaWitness:
index: int # This is the index of the generated key. Limiting this index limits the maximum number of key generated. (20 bits)
selector: bool # Indicates if it's a leader (=1) or a core node (=0)
# This part is filled randomly by potential leaders
core\_sk: zkhash # sk corresponding to the zk\_id of the core node
core\_path: list[zkhash] # Merkle path proving zk\_id membership (len = 20)
core\_path\_selectors: list[bool] # Indicates how to read the core\_path (if Merkle nodes are left or right in the path)
# This part is filled randomly by core nodes
pol\_sl: int # PoL slot
pol\_secret\_key: int # PoL note secret key
pol\_note\_value: int # PoL note value
pol\_note\_tx\_hash: zkhash # PoL note transaction 
pol\_note\_output\_number: int # PoL note transaction output number
pol\_noteid\_path: list[zkhash] # PoL Merkle path proving noteID membership in ledger aged (len = 32)
pol\_noteid\_path\_selectors: list[bool] # Indicates how to read the note\_path (if Merkle nodes are left or right in the path)

Note that every inputs and outputs of zero-knowledge proofs are all scalar field elements.

#### Constraints

Such that the following constraints hold:

Step 1: The prover selects an

index

for the chosen key. This index must be lower than the allowed quota and not already used. This index is used to derive the key nullifier in step 4. Limiting the possible values of this index also limit the possible nullifier created which produce the desired effect: limiting the generation of keys to a certain quota.

index

will be on 20 bits enabling up to $2^{20}$ messages per node per

session

.

Step 2: If the prover indicated that the node is a core node for the proof, the proof checks that:

The core node is registered in the set

N = SDP(session)

. This is proven by demonstrating knowledge of a

core\_sk

that corresponds to a declared

zk\_id

, which is a valid SDP registry for the current

session

. The

zk\_id

values are stored in a Merkle tree with a fixed depth of 20, with the root provided as a public input. To build the Merkle tree,

zk\_id

are ordered from the smallest to the biggest (when seen as natural numbers between 0 and $p$ ) and remaining empty leaves are represented by the

0

after the sorting (appended at the end of the vector). This structure supports up to 1M validators.

The index is valid:

index < core\_quota

.

Step 3: If the prover indicated that the node is a potential leader node for the proof, the proof checks that:

The leader node possesses a note that would win a slot in the consensus lottery. Unlike leadership conditions, the proof of quota doesn't verify that the note is unspent. This enables potential provers to generate the PoQ well in advance. All other lottery constraints are the same as in [[1.1.0] Proof of Leadership - Circuit Constraints](https://nomos-tech.notion.site/Circuit-Constraints-2e9261aa09df80058244c902defc6da2?pvs=24#2e9261aa09df8019ad45f5ce872093ea).

The index is valid:

index < leader\_quota

.

Step 4: The prover derives a

key\_nullifier

maintained by blend nodes during the session for message deduplication purpose.

selection\_randomness = zkhash(b"SELECTION\_RANDOMNESS\_V1", sk, index, validity\_period)
key\_nullifier = zkhash(b"KEY\_NULLIFIER\_V1", selection\_randomness)

Where

sk

is:

The

core\_sk

as defined in the [Mantle specification](https://nomos-tech.notion.site/2ce261aa09df805ea358d80c2046cf95?pvs=25#2ce261aa09df814f8764f3e6d8f543a3) if the node is a core node.

The secret key of the PoL note if its a leader node.

and

validity\_period

is:

The

session

if the node is a core node.

The winning slot of the PoL if its a leader node.

Here we use two hashes because the selection randomness is used in the Proof of Selection in order to prove the ownership of a valid PoQ (see [[1.0.0] Blend Protocol - Proof of Selection](https://nomos-tech.notion.site/Proof-of-Selection-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df81d6bb3febd62b598138)).

Step 5: The prover attaches a one-time signature key used in the blend protocol. This public key is split into two 16-byte parts:

K\_part\_one

and

K\_part\_two

. When written in little-endian byte order, the complete public key equals the concatenation

K\_part\_one||K\_part\_two

.

#### Pseudocode

# Verify selector is a boolean
# selector = 1 if it's a potential leader and 0 if it's a core node
selector \* (1 - selector) == 0 # to check that selector is indeed a bit.
# Verify index is lower than quota. It's exactly like saying index < leader\_quota
# if selector == 1 or index < core\_quota if selector == 0
index < selector \* (leader\_quota - core\_quota) + core\_quota
# Check if it's a registered core node
zk\_id = zkhash(b"KDF", core\_sk)
is\_registered = merkle\_verify(core\_root, core\_path, core\_path\_selectors, zk\_id)
# Check if it's a potential leader
is\_leader = would\_win\_leadership(pol\_epoch\_nonce,
pol\_t0,
pol\_t1,
pol\_ledger\_aged,
pol\_sl,
pol\_secret\_key,
pol\_sk\_secrets\_root,
pol\_note\_value,
pol\_note\_tx\_hash,
pol\_note\_output\_number,
pol\_noteid\_path,
pol\_noteid\_path\_selectors)
# Verify that it's a core node or a leader
assert( selector \* (is\_leader - is\_registered) + is\_registered == 1)
# Derive nullifier
selection\_randomness = zkhash(
b"SELECTION\_RANDOMNESS\_V1",
selector \* (pol\_secret\_key - core\_sk) + core\_sk,
index,
selector \* (pol\_sl - session) + session)
key\_nullifier = zkhash(b"KEY\_NULLIFIER\_V1", selection\_randomness)

### Proof Compression

The proof confirming that the PoQ is correct must be compressed to a size of 128 bytes, where the

UncompressedProof

is comprising of 2 $\mathbb{G}\_1$ and 1 $\mathbb{G}\_2$ BN256 elements as presented below.

class UncompressedProof:
pi\_a: G1 # BN256 element 
pi\_b: G2 # BN256 element
pi\_c: G1 # BN256 element

### Proof Serialization

The

ProofOfQuota

structure contains

key\_nullifier

and the compressed

proof

transformed in bytes according [[1.0.2] Common Cryptographic Components - Use in the Logos Blockchain:](https://nomos-tech.notion.site/Use-in-the-Logos-Blockchain-1fd261aa09df81ac8ebbe0111e2c2d84?pvs=24#209261aa09df80b8aec6cc763573ff69). The

key\_nullifier

must be transformed into bytes. The bytes of the compressed proof are then concatenated together with the bytes representing the

key\_nullifier

, with the encoded

key\_nullifier

preceding the encoded compressed

proof

. Reconstruction of a serialized

ProofOfQuota

interpreting the bytes as the concatenation of the

key\_nullifier

and of the compressed

proof

following the same rule of conversion.

class ProofOfQuota:
key\_nullifier: zkhash # 32 bytes
proof: bytes # 128 bytes

## Appendix

### Benchmarks

The material used for the benchmarks is the following:

CPU: 13th Gen Intel(R) Core(TM) i9-13980HX (24 cores / 32 threads)

RAM: 32GB - Speed: 5600 MT/s

Motherboard: Micro-Star International Co., Ltd. MS-17S1

OS: Ubuntu 22.04.5 LTS

Kernel: 6.8.0-59-generic

![](https://nomos-tech.notion.site/image/attachment%3Aa2fcd60c-7778-4aa3-9bcf-0e5299e31e16%3Aoutput_(2).png?table=block&id=2e9261aa-09df-8023-91a7-e7f6c11c4056&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
