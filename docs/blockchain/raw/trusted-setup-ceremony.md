# TRUSTED-SETUP-CEREMONY

| Field | Value |
| --- | --- |
| Name | Trusted Setup Ceremony |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | Mehmet Gonen <mehmet@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Mehmet Gonen <mehmet@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-09-04


1.0.1
	
Renamed Nomos to Logos Blockchain.
Removed mentions of DA.
	
2026-04-23
Introduction
The Logos Blockchain utilizes zero-knowledge proof systems not only to ensure strong privacy and security guarantees across its decentralized architecture, but also to reduce the computational burden on validators by compressing execution into succinct proofs. Some of the Logos Blockchain's cryptographic applications specifically use Groth16 (see 🔀
[1.0.2] Common Cryptographic Components - Groth16 (zk-SNARK)), a proof system renowned for its succinctness and efficient verification.
A critical requirement of Groth16 is the secure generation of a Common Reference String (CRS) through a one-time cryptographic ceremony, commonly known as a Trusted Setup Ceremony. This ceremony ensures that cryptographic parameters are generated in a decentralized manner, such that no individual participant can later compromise the security or privacy guarantees of the system.
The Logos Blockchain adopts a secure, publicly verifiable, and auditable Multi-Party Computation (MPC) protocol known as Powers-of-Tau, performed over the BN254 elliptic curve as a first step for Groth16-based zero-knowledge proofs, to generate and extend these trusted setup parameters. 
This document defines the cryptographic foundations and provides detailed instructions for securely performing or extending a trusted setup ceremony, including:
Essential cryptographic definitions and parameters.
Step-by-step guidance for participant contributions.
Procedures for extending an existing Powers-of-Tau ceremony.
Overview
At a high level, the Powers-of-Tau ceremony generates a structured set of elliptic curve points corresponding to powers of a secret scalar 
𝜏
τ. These elements form the Phase 1 CRS that underpins the Groth16 protocol in the Logos Blockchain. For Groth16, the CRS can be extended in a short Phase 2 MPC to derive circuit-specific proving and verification keys, ensuring the underlying secret remains hidden as long as at least one participant discards their randomness. The Logos Blockchain adopts an MPC setup ceremony: the Powers-of-Tau protocol.
Powers-of-Tau Ceremony Overview
Each participant securely contributes randomness sequentially.
Each participant iterates over the existing CRS parameters to update it.
At least one participant must be honest and destroy their secret input to guarantee the security of ZK schemes using the CRS.
All transformations are accompanied by publicly verifiable proofs, ensuring full auditability of the ceremony.
In the ceremony, a coordinator manages the sequential flow of contributions. Each contributor downloads the current CRS, applies their secret randomness, and sends the updated CRS back through the coordinator, who relays it to the next participant. At each step, an independent verifier can check that the update was performed correctly. Once all contributions are complete, the final CRS is published.
Security of Powers-of-Tau
Let N denote the total number of contributors participating in the ceremony. The Powers-of-Tau ceremony achieves computational soundness against adversaries that corrupt up to (N-1) participants, under certain number-theoretic assumptions (e.g., the q-Strong Diffie-Hellman (q-SDH) assumption in the underlying elliptic curve groups), provided that at least one honest participant successfully erases their secret randomness. 
Honest Participation: The core trust assumption is that at least one participant in the multi-party computation securely deletes their secret contribution (i.e., the toxic waste). If this holds, then the final CRS remains sound and cannot be used to forge proofs.
Computational Assumptions: The protocol relies on several number-theoretic assumptions, most notably the q-SDH assumption over the elliptic curve. These assumptions are fundamental to pairing-based cryptography and are not specific to the ceremony.
Erasure Assumption: Powers-of-Tau is typically analyzed in the secure erasure model, where each participant is assumed to be capable of permanently deleting their internal secret randomness after applying it. This ensures that even if an adversary later compromises a participant, they cannot recover the toxic waste. While not a computational assumption, secure erasure is essential for the soundness of the protocol in this model.
The security of Groth16-based zero-knowledge proofs in the Logos Blockchain critically depends on a sound and verifiable trusted setup. Each participant contributes to the CRS without revealing their secret randomness, and public proofs guarantee the correctness of every transformation. The procedure applies to all required secret scalars, 
𝜏
,
𝛼
,
𝛽
,
𝛾
,
𝛿
τ,α,β,γ,δ, ensuring that all toxic waste is handled consistently and securely. Furthermore, the Logos Blockchain builds its Powers-of-Tau ceremony on top of an existing, already-audited CRS instead of starting from scratch, providing greater confidence in its security. This trusted setup process forms a foundational cryptographic pillar for ensuring privacy, integrity, and long-term resilience in the Logos architecture.
We have two phases for the ceremony. Phase 1 is circuit-independent and involves generating elliptic curve encodings of powers of a toxic waste scalar 
𝜏
τ. This enables polynomial commitments up to a certain degree and can be reused across any circuit of bounded size. Phase 2 is circuit-specific and requires knowledge of the exact constraint system. It introduces four additional toxic waste scalars 
𝛼
,
𝛽
,
𝛾
,
𝛿
α,β,γ,δ, which are used to encode the circuit's polynomials and, crucially, compute the 
𝐾
𝑖
K
i
	​

 elements in the verification key. These 
𝐾
𝑖
K
i
	​

 terms represent compressed combinations of public input polynomials and must be computed for each unique circuit. As a result, while Phase 1 can be performed once and reused broadly, Phase 2 must be securely executed for every new circuit.
Curve Selection and Parameter Structure
The Logos Blockchain uses the BN254 elliptic curve for Groth16-based zero-knowledge proofs because proving time and proof size are critical in these applications. BN254 offers smaller proofs and faster proving times compared to alternatives like BLS12-381, and is backed by mature, highly optimized libraries such as Circom, SnarkJS, and libsnark.
Groth16 Parameters
Groth16 proving systems derive two key components from a structured CRS:
Proving Key (
𝑝
𝑘
pk): This is a set of cryptographic parameters enabling the prover to generate proofs. Includes group elements from the prime-order cyclic subgroups 
𝐺
1
G
1
	​

 and 
𝐺
2
G
2
	​

 on elliptic curve, where 
𝐺
2
G
2
	​

 is defined over a degree-2 extension field.
Verification Key (
𝑣
𝑘
vk): This is a smaller set of parameters allowing efficient verification of proofs. The verification key contains a much smaller set of elliptic curve elements from groups 
𝐺
1
G
1
	​

 and 
𝐺
2
G
2
	​

.
Protocol
Technical and Cryptographic Steps
This section describes the trusted setup procedure in detail, outlining both the cryptographic computations and the interactive flow of the multi-party Powers-of-Tau protocol. The process begins with a coordinator initializing elliptic curve parameters and generating the initial set of structured CRS elements. Each participant builds on the previous one’s output by applying a secret random transformation and publishing a proof of correctness — so the process is sequential. As long as at least one participant discards their secret input, the entire setup remains secure. These contributions are chained together, and the ceremony concludes with a publicly verifiable aggregation of the final CRS. 
The Groth16 protocol requires a CRS with a suite of powers of one random scalar 
𝜏
∈
𝐹
𝑝
∗
τ∈F
p
∗
	​

. To ensure soundness and zero-knowledge for a given arithmetic circuit, four additional toxic-waste elements must also be sampled independently and uniformly at random. While their values are circuit-independent, the way they are applied in constructing the proving and verification keys depends on the specific circuit.
In addition to 
𝜏
τ, the Groth16 proving system requires, for each circuit, four additional secret scalars, 
𝛼
,
α, 
𝛽
,
𝛾
β,γ and 
𝛿
δ all sampled independently and uniformly at random from the field 
𝐹
𝑝
∗
F
p
∗
	​

. These values are essential for securely encoding different components of the constraint system and for ensuring zero-knowledge in the final proof. Specifically, 
𝛼
α and 
𝛽
β are used to randomize the circuit polynomials 
𝐴
(
𝑥
)
A(x) and 
𝐵
(
𝑥
)
B(x), 
𝛾
γ is used to compress linear combinations of public inputs, and 
𝛿
δ provides blinding for the quotient polynomial that ensures witness-hiding. Like 
𝜏
τ, each of these values must be treated as toxic waste and securely discarded after use. All five values: 
𝜏
,
𝛼
,
𝛽
,
𝛾
,
𝛿
τ,α,β,γ,δ must be generated using the same secure procedure and structure. In Groth16 Phase 2, these scalars are used immediately to derive circuit-specific CRS elements, in particular the 
𝐾
𝑖
K
i
	​

 terms in the verification key, before all toxic waste is securely destroyed.
Step 1: Initialization (Coordinator)
The coordinator publicly specifies the foundational cryptographic parameters:
Elliptic Curve: 
BN254: 
(
𝑥
,
𝑦
)
∈
𝐹
𝑝
BN254
(x,y)∈F
p
BN254
	​

 such that 
𝑦
2
=
𝑥
3
+
3
y
2
=x
3
+3​
Here 
𝐹
𝑝
BN254
F
p
BN254
	​

 denotes distinct prime fields of size 
𝑝
BN254
p
BN254
.
Cryptographic Groups:
𝐺
1
,
𝐺
2
,
𝐺
𝑇
G
1
	​

,G
2
	​

,G
T
	​

: prime-order subgroups of elliptic curve points over 
𝐹
𝑝
F
p
	​

 and its extensions.
𝑒
:
𝐺
1
×
𝐺
2
→
𝐺
𝑇
e:G
1
	​

×G
2
	​

→G
T
	​

: a bilinear, non-degenerate pairing function.
Generators:
𝐺
𝑖
∈
𝐺
𝑖
:
𝑖
∈
{
1
,
2
,
𝑇
}
G
i
	​

∈G
i
	​

:i∈{1,2,T} are fixed public generators.
Element Notation:
Elements of the group 
𝐺
𝑖
:
𝑖
∈
{
1
,
2
,
𝑇
}
G
i
	​

:i∈{1,2,T} are written additively by using the following notation: 
[
𝛼
]
𝑖
:
=
𝛼
⋅
𝐺
𝑖
[α]
i
	​

:=α⋅G
i
	​

.
These values are fixed and published to all ceremony participants.
An initialized CRS:
The initialized CRS contains 
𝑛
+
1
n+1 elements in 
𝐺
1
G
1
	​

 and 
𝑚
+
1
m+1 elements in 
𝐺
2
G
2
	​

. For the 
𝜏
τ secret in Groth16, the value of 
𝑛
n defines the maximum degree of polynomials that will be committed and the maximum size of circuits (the number of R1CS constraints must be ≤ 
𝑛
n) and 
𝑚
=
1
m=1. In contrast, the parameters 
𝛼
,
𝛽
,
𝛾
,
𝛿
α,β,γ,δ of the Groth16 protocol each require only 
𝑛
=
𝑚
=
0
n=m=0. But, Phase 2 also includes the computation of the 
𝐾
𝑖
K
i
	​

 elements in 
𝐺
1
G
1
	​

, whose number depends on the circuit’s public inputs. These must be generated at the same time, while the toxic waste scalars are still in memory.
The CRS is of the form: 
(
[
1
]
1
)
𝑗
=
0
𝑛
  
(
[
1
]
2
)
𝑘
=
0
𝑚
([1]
1
	​

)
j=0
n
	​

([1]
2
	​

)
k=0
m
	​

 when initializing from scratch.
💡
For performance reasons, especially to leverage Number Theoretic Transforms (NTT) for fast polynomial arithmetic, it is common to choose 
𝑛
n as a power of two. For example, setting 
𝑛
=
2
𝑘
n=2
k
 allows working with polynomials of degree up to 
2
𝑘
−
1
2
k
−1, and proving circuits with up to 
2
𝑘
2
k
 constraints. 
Step 2: Participant Contribution 
Each participant 
𝑖
i in the sequence performs the following:
Downloads the current CRS:
(
[
𝜏
𝑗
]
1
)
𝑗
=
0
𝑛
,
  
(
[
𝜏
𝑘
]
2
)
𝑘
=
0
𝑚
([τ
j
]
1
	​

)
j=0
n
	​

,([τ
k
]
2
	​

)
k=0
m
	​

 (
𝜏
=
1
τ=1 at the initialization phase).
Generates a random secret scalar 
𝑟
𝑖
←$
𝐹
𝑝
∗
r
i
	​

←
$
F
p
∗
	​

.
Updates the CRS by contributing its secret 
𝑟
𝑖
r
i
	​

 into the CRS.
∀
𝑗
∈
[
0
,
𝑛
]
:
  
[
(
𝜏
′
)
𝑗
]
1
:
=
[
(
𝑟
𝑖
𝜏
)
𝑗
]
1
=
𝑟
𝑖
𝑗
⋅
[
𝜏
𝑗
]
1
∀j∈[0,n]:[(τ
′
)
j
]
1
	​

:=[(r
i
	​

τ)
j
]
1
	​

=r
i
j
	​

⋅[τ
j
]
1
	​

.
∀
𝑘
∈
[
0
,
𝑚
]
:
[
(
𝜏
′
)
𝑘
]
2
=
[
(
𝑟
𝑖
𝜏
)
𝑘
]
2
=
𝑟
𝑖
𝑘
⋅
[
𝜏
𝑘
]
2
∀k∈[0,m]:[(τ
′
)
k
]
2
	​

=[(r
i
	​

τ)
k
]
2
	​

=r
i
k
	​

⋅[τ
k
]
2
	​

.
Creates a proof showing they know 
𝑟
𝑖
r
i
	​

, and that the CRS is a correct transformation of the old one.
This proof consists of three checks (detailed in Step 4):
Knowledge of exponent 
𝑟
𝑖
r
i
	​

 for the first element.
Non-zero: 
𝑟
𝑖
≠
0
r
i
	​


=0 ensuring previous contributions are not erased.
Well-formedness of the updated CRS via random linear combination pairing check.
Submits:
Updated parameters 
(
[
(
𝜏
′
)
𝑗
]
1
)
𝑗
=
0
𝑛
,
  
(
[
(
𝜏
′
)
𝑘
]
2
)
𝑘
=
0
𝑚
([(τ
′
)
j
]
1
	​

)
j=0
n
	​

,([(τ
′
)
k
]
2
	​

)
k=0
m
	​

.
Proof of correct transformation.
In Phase 2 for Groth16, participants also update all circuit-specific elements derived from the toxic waste scalars (including the 
𝐾
𝑖
K
i
	​

 terms), ensuring they are transformed consistently with the rest of the CRS.
Step 3: Public Verification
Knowledge of Exponent 
𝑟
𝑖
r
i
	​

​
This is proven using a Fiat–Shamir transform of a Schnorr-like protocol:
Let: 
[
𝜏
′
]
1
=
𝑟
𝑖
⋅
[
𝜏
]
1
[τ
′
]
1
	​

=r
i
	​

⋅[τ]
1
	​

.
Prover samples random values uniformly 
𝑧
←$
𝐹
𝑝
z
←
$
F
p
	​

.
Computes: 
[
𝑧
′
]
1
=
𝑧
⋅
[
𝜏
]
1
[z
′
]
1
	​

=z⋅[τ]
1
	​

.
Computes challenge: 
ℎ
=
Hash
(
[
𝜏
]
1
,
[
𝜏
′
]
1
,
[
𝑧
′
]
1
)
h=Hash([τ]
1
	​

,[τ
′
]
1
	​

,[z
′
]
1
	​

).
Computes response: 
𝑠
=
𝑧
+
ℎ
⋅
𝑟
𝑖
m
o
d
 
 
𝑝
s=z+h⋅r
i
	​

modp.
Publishes proof 
𝜋
=
(
[
𝑧
′
]
1
,
𝑠
)
π=([z
′
]
1
	​

,s).
Verifier checks: 
𝑠
⋅
[
𝜏
]
1
=?
[
𝑧
′
]
1
+
ℎ
⋅
[
𝜏
′
]
1
s⋅[τ]
1
	​

=
?
[z
′
]
1
	​

+h⋅[τ
′
]
1
	​

.
This protocol confirms that the first element of the CRS was exponentiated with a known secret 
𝑟
𝑖
r
i
	​

.
Well-Formedness of CRS
Verifier samples 
𝜌
1
,
𝜌
2
←$
𝐹
𝑝
∗
ρ
1
	​

,ρ
2
	​

←
$
F
p
∗
	​

. 
The verifier computes the following pairing equation on the new CRS:
𝑒
(
∑
𝑗
=
1
𝑛
𝜌
1
𝑗
−
1
⋅
[
𝜏
𝑗
]
1
,
[
1
]
2
+
∑
𝑘
=
1
𝑚
−
1
𝜌
2
𝑘
⋅
[
𝜏
𝑘
]
2
)
=?
𝑒
(
[
1
]
1
+
∑
𝑗
=
1
𝑛
−
1
𝜌
1
𝑗
⋅
[
𝜏
𝑗
]
1
,
∑
𝑘
=
1
𝑚
𝜌
2
𝑘
−
1
[
𝜏
𝑘
]
2
)
e(
j=1
∑
n
	​

ρ
1
j−1
	​

⋅[τ
j
]
1
	​

,[1]
2
	​

+
k=1
∑
m−1
	​

ρ
2
k
	​

⋅[τ
k
]
2
	​

)
=
?
e([1]
1
	​

+
j=1
∑
n−1
	​

ρ
1
j
	​

⋅[τ
j
]
1
	​

,
k=1
∑
m
	​

ρ
2
k−1
	​

[τ
k
]
2
	​

)
This pairing check confirms that the CRS has been updated via exponentiation by the same secret scalar 
𝑟
𝑖
r
i
	​

, preserving the structure of the powers of 
𝜏
τ.
Non-Erasing Contribution
Checks that 
𝑟
𝑖
≠
0
r
i
	​


=0:  
𝑟
𝑖
⋅
[
𝜏
]
1
≠
𝑂
(
identity element
)
r
i
	​

⋅[τ]
1
	​


=O(identity element).
𝐾
𝑖
K
i
	​

’s verification (Phase2 only)
For each public 
𝑖
i, check the pairing equation:

𝑒
(
𝐾
𝑖
,
  
[
𝛾
]
2
)
  
=?
  
𝑒
 ⁣
(
[
𝐴
𝑖
(
𝜏
)
]
1
,
  
[
𝛽
]
2
)
  
⋅
  
𝑒
 ⁣
(
[
𝐵
𝑖
(
𝜏
)
]
1
,
  
[
𝛼
]
2
)
  
⋅
  
𝑒
 ⁣
(
[
𝐶
𝑖
(
𝜏
)
]
1
,
  
𝐺
2
)
e(K
i
	​

,[γ]
2
	​

)
=
?
e([A
i
	​

(τ)]
1
	​

,[β]
2
	​

)⋅e([B
i
	​

(τ)]
1
	​

,[α]
2
	​

)⋅e([C
i
	​

(τ)]
1
	​

,G
2
	​

)​
Left side encodes the division by 
𝛾
γ (respectively 
𝛿
δ for private inputs).
Right side encodes the linear combination 
𝛽
𝐴
𝑖
(
𝜏
)
+
𝛼
𝐵
𝑖
(
𝜏
)
+
𝐶
𝑖
(
𝜏
)
βA
i
	​

(τ)+αB
i
	​

(τ)+C
i
	​

(τ). 
If it holds for all 
𝑖
i, the 
𝐾
𝑖
K
i
	​

 are correct and consistent with the same 
𝛼
,
𝛽
,
𝛾
,
𝜏
α,β,γ,τ for public inputs (respectively 
𝛿
δ for private inputs).
Step 4: Toxic Waste Destruction
While each participant is expected to delete their secret scalar 
𝑟
𝑖
r
i
	​

 immediately after contribution, security is guaranteed as long as at least one participant successfully deletes their randomness.
Finalized CRS
Once all participants have contributed:
The final CRS 
(
[
𝜏
𝑗
]
1
)
𝑗
=
0
𝑛
=
(
[
∏
𝑖
𝑟
𝑖
𝑗
]
1
)
𝑗
=
0
𝑛
,
  
(
[
𝜏
𝑘
]
2
)
𝑘
=
0
𝑚
=
(
[
∏
𝑖
𝑟
𝑖
𝑘
]
2
)
𝑘
=
0
𝑚
([τ
j
]
1
	​

)
j=0
n
	​

=([∏
i
	​

r
i
j
	​

]
1
	​

)
j=0
n
	​

,([τ
k
]
2
	​

)
k=0
m
	​

=([∏
i
	​

r
i
k
	​

]
2
	​

)
k=0
m
	​

 is published (
𝑖
i being the number of participants).
This CRS is used to derive:
Circuit-specific proving keys 
𝑝
𝑘
pk.
Circuit-specific verification keys 
𝑣
𝑘
vk.
Extending an Existing Trusted Setup Ceremony
Logos may choose to leverage an existing, publicly verified Powers-of-Tau ceremony to inherit trust and security. To do this, Logos simply adds additional participants following the above participant contribution steps (Step 2):
Logos participants securely download existing Powers-of-Tau parameters.
Each Logos participant sequentially adds their randomness and generates proofs-of-knowledge, updating the parameters.
After all Logos contributions, a new final set of parameters is derived.
A Logos coordinator aggregates the auditable contributions to compute the new CRS parameters and publish them for Logos.
By following this protocol, Logos ensures robust security guarantees without repeating the entire ceremony from scratch. Most importantly, this process allows Logos to onboard previous contributions from external parties, inheriting their randomness and strengthening the trust assumption. It also preserves the transparency, integrity, and auditability of the original ceremony while enhancing its security by contributing additional entropy from Logos’ own participants, effectively extending a trusted foundation with new safeguards.
References
[Groth16] IACR Cryptology ePrint ArchiveOn the Size of Pairing-based Non-interactive Arguments, Jens Groth, Eurocrypt 2016
[WCB25] IACR Cryptology ePrint ArchiveSoK: Trusted setups for powers-of-tau strings, Faxing Wang, Shaanan Cohney, Joseph Bonneau, FC 2025
Annex
# Pseudocode for Multi-Party Powers-of-Tau Ceremony

# Input:
#   - n: Max degree of polynomials to support (e.g., #constraints in Groth16)
#   - m: Usually 1
#   - G1, G2: Elliptic curve generators for groups G1 and G2
#   - p: Prime order of the field F_p

# Output:
#   - crs: Common Reference String with structured powers of tau
#   - transcript: List of contributions and public proofs

# Assume Point is a placeholder for an elliptic curve point class
Point = object
Scalar = int

@dataclass
class ContributionProof:
    z_point: Point
    s: Scalar

def initialize_crs(n: int, m: int, G1: Point, G2: Point):
    crs_G1 = [(1 ** j) * G1 for j in range(n)] # [1]_1, [1]_1, ..., [1]_1
    crs_G2 = [(1 ** k) * G2 for k in range(m)] # [1]_2, [1]_2
    return crs_G1, crs_G2

def contribute(
    crs_G1: list[Point],
    crs_G2: list[Point],
    G1: Point,
    G2: Point,
    p: int):
    r: Scalar = random_non_zero_scalar(p) # secret toxic waste scalar. 254-bit for BN254 and 255-bit for BLS12-381

		# Apply exponentiation to CRS
    crs_G1_prime = [(r ** j) * crs_G1[j] for j in range(len(crs_G1))]
    crs_G2_prime = [(r ** k) * crs_G2[k] for k in range(len(crs_G2))]

		# Generate proof of correct exponentiation
    proof = generate_proof_of_knowledge(crs_G1[1], crs_G1_prime[1], r, G1, p)
	
		# Destroy r securely
    del r

    return crs_G1_prime, crs_G2_prime, proof

def generate_proof_of_knowledge(
    old_point: Point,
    new_point: Point,
    r: Scalar,
    G: Point,
    p: int):
    
    z: Scalar = random_non_zero_scalar(p)
    z_point = z * G
    # Schnorr-style proof with Fiat–Shamir challenge
    h: Scalar = hash_to_scalar(old_point, new_point, z_point)
    s: Scalar = (z + h * r) % p
    return ContributionProof(z_point, s)

def verify_contribution(
    old_crs_G1: list[Point],
    old_crs_G2: list[Point],
    new_crs_G1: list[Point],
    new_crs_G2: list[Point],
    proof: ContributionProof,
    G1: Point,
    G2: Point,
    p: int):
    
    z_point, s = proof.z_point, proof.s
    h = hash_to_scalar(old_crs_G1[1], new_crs_G1[1], z_point)
    lhs = s * G1
    rhs = z_point + h * new_crs_G1[1]
    if lhs != rhs:
        return False

    rho_one = random_non_zero_scalar(p)
    rho_two = random_non_zero_scalar(p)

    lhs = pairing(
        sum([(rho_one ** j) * new_crs_G1[j] for j in range(len(new_crs_G1))]),
        (1 * old_crs_G2[0]) + sum([(rho_two ** k) * old_crs_G2[k] for k in range(len(old_crs_G2))])
    )
    rhs = pairing(
        (1 * old_crs_G1[0]) + sum([(rho_one ** j) * old_crs_G1[j] for j in range(len(old_crs_G1))]),
        sum([(rho_two ** k) * new_crs_G2[k] for k in range(len(new_crs_G2))])
    )

    return lhs == rhs

def powers_of_tau_ceremony(
    participants: list[object],  # Should ideally be a class/interface with contribute()
    n: int,
    m: int,
    G1: Point,
    G2: Point,
    p: int):
    
    crs_G1, crs_G2 = initialize_crs(n, m, G1, G2)
    transcript: list[ContributionProof] = []

    for participant in participants:
        crs_G1_new, crs_G2_new, proof = participant.contribute(crs_G1, crs_G2, G1, G2, p)
        if not verify_contribution(crs_G1, crs_G2, crs_G1_new, crs_G2_new, proof, G1, G2, p):
            raise ValueError("Invalid contribution by participant")
        transcript.append(proof)
        crs_G1, crs_G2 = crs_G1_new, crs_G2_new

    return crs_G1, crs_G2, transcript

​
