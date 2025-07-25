--- 
title: UTXO-SPECIFICATIONS
name: UTXO Specifications 
status: raw
category:
tags:
editor:
contributors:
- Filip Dimitrijevic <filip@status.im>
---

The UTXO model in the NSSA architecture underpins privacy-preserving executions for private, SE, and DE transactions.
By utilizing cryptographic methods and structured components,
UTXOs facilitate programmable privacy,selective transparency,
and secure state transitions.

## Components of a UTXO

A UTXO encapsulates several cryptographic and functional elements that ensure privacy,
ownership, and state programmability.

### Token amount

The token amount component in a UTXO represents the value or balance associated with that UTXO.
It ensures that during private, SE, and DE executions,
the system can verify the total balance of input and output UTXOs,
maintaining transactional integrity and preventing value discrepancies.
This component plays an important role in ensuring consistency between private and public states,
especially during state transitions.

The token amount is stored as an unsigned integer.
It represents the amount in the smallest unit of value in the system,
an element of the finite field $\mathbb {F}_{p}$ leveraging the field’s modular arithmetic
to enable efficient computations within zkVM environments.

### Range

- Minimum value: 0 (representing zero tokens).

- Maximum value: $2^{128-1}$ Any value less than the modulus $p$, which approximately is $2^{256}$.

- This provides an upper bound of 128 bits,
  allowing for large balances256while remaining compatible with cryptographic constraints.

### Decimals

- Decimal values are supported through rational number representation,
  stored in the form $A/B$ where $B^{-1}$ is the multiplicative inverse of ﻿ in $B$ $\mathbb {F}_{p}$.

- Example: For $3.14$, the value is stored as $314⋅100−1$ mod $p$ where $100^{-1}$ ﻿ is computed using modular arithmetic.

- This approach ensures precision and avoids the need for floating-point arithmetic,
  which is not compatible with cryptographic systems.

### Usage in execution types

1. Private execution: During balance validation,
the zkVM verifies that the sum of input UTXO amounts equals the sum of output UTXO amounts.
This validation ensures that no tokens are created or destroyed during the transaction.

2. SE execution: The token amount component represents the value of freshly minted UTXOs.
These amounts must match the public portion of the SE execution,
ensuring consistency across private and public states.

3. DE execution: Input UTXOs are consumed,
and their amounts are checked against the corresponding public transaction to prevent discrepancies.
The consumed value must align with the value specified in the public state, enabling secure decommitment.

### Validation in zkVM

The zkVM enforces balance validation by performing modular arithmetic on Token Amount values.

- **Balance check:**
  - For a transaction with input UTXOs $\text{in}_i$ and output UTXOs $\text{out}_j$, *the zkVM checks:*
  
    $$
    \sum_i \text{Token Amount}_{\text{in}_i} \equiv \sum_j \text{Token Amount}_{\text{out}_j} \pmod{p}
    $$

    That is, the sum of the token amounts in all input UTXOs must be congruent (modulo $p$) to the sum of the token amounts in all output UTXOs.

- **Decimal compatibility:**
  - Since decimals are represented as rational numbers in $\mathbb {F}_{p}$ the zkVM multiplies by the least common denominator before performing modular balance checks,
  this guarantees precision without introducing inconsistencies.

### Security considerations

The token amount component is safeguarded against manipulation through cryptographic commitments and zkVM proofs.

- **Commitments:**
  - Token amounts are included in the UTXO commitment, ensuring they cannot be altered without invalidating the proof.
  - For example, in Pedersen commitments, the Token Amount is hidden as part of the commitment:
  
    $$
    C = g^{\text{Token Amount}} \cdot h^r \mod p
    $$
    where $r$ is a randomly chosen blinding factor.

- **Anonymity:**
  - Since the token amount is embedded in commitments, its value is hidden from external observers unless explicitly revealed by the user.

- **Resistance to overflow:**
  - The maximum supply of token value in the system should be less than the maximum value allowed in the amount field. This way we prevent overflows in the balance check, as both sides of the equality will always be less than the total supply of the system. The modular nature of $\mathbb{F}_p$ ensures that operations involving large Token Amounts do not lead to overflows, a common issue in fixed-width integer systems.

### Storage slots

Storage slots in a UTXO serve as a link between private states and programmable privacy.
They represent hashed references to variable data tied to private smart contracts,
enabling state modifications without exposing raw information.
This mechanism supports both confidentiality and data integrity in private executions, SE, and DE transitions.

A storage slot is represented as an element of the finite field $\mathbb{F}_p$, derived as the output of a cryptographic hash function. The hash ensures that:

1. Arbitrary-length input data (e.g., a list of variables) is compactly represented.
2. The hashed value integrates seamlessly into zkVM operations and proofs.
3. Integrity is preserved during storage updates, as any mismatch invalidates the commitment.

### Functional role in NSSA executions

1. **Private execution:** Storage slots enable modifications to private smart contract states by embedding references to hashed data. During private execution, the actual data is transmitted off-chain, and the hash is validated against the UTXO.
2. **SE execution:** SE executions often involve state updates reflected in both private and public states. Storage slots help maintain consistency by synchronizing private state changes with public updates without exposing sensitive details.
3. **DE execution:** In DE executions, storage slots are critical for linking consumed private UTXOs to their public counterparts. This ensures that decommitment transitions preserve data integrity.

### Hashing mechanism

Storage slots rely on a secure cryptographic hash function, denoted as `hash`.
The function transforms input data into an element of $\mathbb{F}_p$, ensuring:

- **Compactness:** Arbitrary-length input is reduced to a fixed-length output.
- **Collision resistance:** Different inputs produce distinct hashes, safeguarding against tampering.
- **Pre-image resistance:** Given a hash, it is computationally infeasible to reverse-engineer the input.

**Example:**  
For storage data containing variables $x$, $y$, and $z$, the storage slot is computed as:

$$
\text{Storage Slot} = \text{hash}(x \| y \| z).
$$

### Integration with zkVM proofs

Unlike the token amount component, storage slots are not inherently validated during zkVM proofs.
This design decision balances performance with flexibility:

1. **Default behavior:** Storage slot integrity is assumed to be verified off-chain. This reduces the complexity of zkVM proofs, focusing only on balance checks and ownership validations.
2. **Optional validation:** For applications requiring on-chain verification, storage slot checks can be enforced within the zkVM. This involves recomputing the hash during the proof to ensure consistency.

#### Ownership

Ownership ensures that a UTXO can only be consumed by its designated recipient. This is achieved by linking the UTXO to the nullifier public key ($N_{pk}$) of the intended owner. The ownership mechanism is critical for maintaining privacy and access control within NSSA’s privacy-preserving framework.

The ownership component is represented as an element of $\mathbb{F}_p$, corresponding to the recipient’s $N_{pk}$, derived from their private key (check NSSA key protocol).

### Functional role in NSSA

1. **Recipient eligibility:** The zkVM validates that the consumer of a UTXO possesses the corresponding private key linked to its $N_{pk}$. This prevents unauthorized access while preserving the anonymity of ownership.
2. **Sender anonymity:** UTXOs do not include any sender information. This design ensures that transactions remain unlinkable, even if multiple UTXOs are sent to the same recipient.
3. **Transfer of ownership:** During UTXO creation, the sender embeds the recipient’s $N_{pk}$ in the UTXO. The recipient can later consume the UTXO by proving possession of the corresponding private key.

### Validation in zkVM (UTXO)

The zkVM ensures that only the rightful owner can consume a UTXO:

1. **Proof of ownership:** The zkVM verifies $g^x \equiv N_{pk} \pmod{p}$ where $x$ is the recipient’s private key.
2. **Unlinkability:** To maintain unlinkability, $N_{pk}$ is typically combined with randomization (e.g., blinding factors) during zk proofs. This ensures that ownership validation cannot be correlated across transactions.

#### Randomness

Randomness introduces entropy into UTXOs, ensuring that they are cryptographically secure and resistant to pre-image attacks. This randomness obscures deterministic patterns, preventing adversaries from deducing transaction details or correlating inputs and outputs.

The randomness component is a field element $r \in \mathbb{F}_p$, chosen uniformly at random. It is combined with other UTXO attributes (e.g., token amount, ownership) to produce cryptographic commitments:

$$
C = g^{\text{Token Amount}} \cdot h^r \mod p
$$

where $g$ and $h$ are generator points on the elliptic curve.

### Functional role in NSSA (UTXO)

1. **Commitment schemes:** Randomness ensures that identical inputs produce distinct commitments, preserving privacy and unlinkability.
2. **Proof isolation:** Each UTXO is uniquely randomized, ensuring that zk proofs are isolated and cannot be reused in different contexts.
3. **Entropy enhancement:** Randomness mitigates the risk of brute-force or enumeration attacks, even if some UTXO attributes are partially revealed.

### Validation in zkVM (randomness)

The zkVM validates the randomness indirectly by verifying the commitment:
$$
C = g^{\text{Token Amount}} \cdot h^r \mod p
$$
The proof ensures that $r$ was chosen appropriately without revealing its actual value.

### Privacy flags

The privacy flag determines whether a UTXO is confined to the private state or can transition to the public state. This enables **selective privacy**, allowing users to balance confidentiality and transparency depending on the transaction context.

#### Types of privacy flags

1. **True (private state only):**
    - UTXOs remain exclusively in the private state.
    - They are manually consumed or nullified during private executions.
    - These UTXOs are never revealed to the public state, ensuring maximal confidentiality.

2. **False (synchronizable with public state):**
    - These UTXOs can be revealed during public state synchronization (e.g., SE executions).
    - The associated storage data is exposed selectively, allowing integration with public smart contract states.

### Functional role in NSSA (randomness)

1. **Private transactions:** Privacy flags enable UTXOs to remain isolated in private state transitions, ensuring that sensitive data is not inadvertently exposed.
2. **Hybrid transactions:** In SE executions, privacy flags allow users to selectively reveal UTXOs necessary for public state updates while keeping others private.
3. **Public updates:** DE executions leverage UTXOs with false privacy flags to synchronize private state changes with public contracts.

### Validation in zkVM (UTXO) consumption

The zkVM validates privacy flags during execution by enforcing constraints on UTXO consumption:

- **True flag:** Ensures that UTXOs with a true flag are only consumed in private state transitions. It also prevents such UTXOs from being revealed in public synchronization steps.
- **False flag:** Allows UTXOs to participate in public state updates but requires the associated storage data to be verified during synchronization.

### Construction

NSSA offers a selective privacy feature, allowing users to choose the privacy level for smart contract invocations, including private, public, shielded, or deshielded modes. However, this flexibility necessitates a synchronisation mechanism to ensure fairness across all users. Without such a mechanism, the system risks fragmenting into two separate decentralised applications, operating independently in public and private states.

To address this, NSSA employs privacy flags. All private states of contracts (receivers) are composed of UTXOs labelled with privacy flags as either `true` or `false`. UTXOs with a `true` flag remain private and are never revealed to the public state. In contrast, UTXOs with a `false` flag must be revealed to the public state and subsequently nullified to prevent further use. This approach ensures proper synchronisation between private and public states.

The revealing phase of the FFUs follows this process:

- Users transfer both types of UTXOs to the receiver, adhering to the lifecycle.
- During the block time, receivers accumulate each FFU using the homomorphic properties of Pedersen commitments.
- At the end of the block, the receiver interacts with the zkVM to generate a ZK proof, which demonstrates the following:
  - Input UTXOs are verified as FFUs, ensuring that UTXOs with a `true` privacy flag remain concealed.
  - Only the amount and storage are revealed, while the owner remains private.
  - The receiver proves that the revealed amount and storage match the original FFU, ensuring no discrepancies.
  - Nullifiers for the input FFUs are created to ensure they cannot be reused, as they remain in the commitment tree but are not yet in the nullifier tree.
- The receiver submits the proof to the sequencer. Upon successful verification of the proof, the sequencer synchronises the revealed amounts and storage with the public state of the receivers and contracts.

### Privacy and unlinkability

UTXO exchanges are limited to private and shielded executions. In these cases, only the amount and storage components of the UTXO are revealed. The storage component remains arbitrary, within the constraints allowed by the application, which ensures sender unlinkability.

Additionally, the revealing operation is performed synchronously, and no information is visible before the process is completed, further preserving unlinkability. The use of ZKPs ensures that no information beyond the revealed parts (amount and storage) is leaked. Critical components such as the owner remain entirely hidden during this process.

However, it is not advisable to use FFUs in shielded executions (SE) with the amount component, as this can compromise unlinkability. In SE, the sending amount is fully visible alongside the executor's identity, making it possible to correlate this information with the public state after the FFUs are synchronised. This potential linkage undermines the unlinkability guarantees and should be avoided.

### Functional role of UTXOs in NSSA

In the NSSA architecture, UTXOs are integral to both private executions and the interplay between private and public states. They carry information necessary for balance validation, programmable privacy, and secure state transitions. The ability to selectively reveal or conceal components like storage slots or ownership keys underpins the hybrid nature of SE and DE executions. During private execution, UTXOs facilitate balance checks and ownership validation in zkVM proofs. In SE executions, freshly minted UTXOs establish a link between private inputs and public updates. In DE executions, consumed UTXOs are nullified, preventing reuse while ensuring unlinkability between public and private states.

### Storage and bandwidth considerations

Each UTXO in the NSSA architecture is structured with four primary components—token amount, storage slot, ownership key, and randomness—each represented as a 256-bit field element. This results in a total size of 128 bytes per UTXO. The compact size ensures compatibility with cryptographic operations, but the aggregated bandwidth demands of large-scale deployments require careful consideration. For private transactions generating multiple UTXOs, bandwidth consumption scales linearly with transaction throughput. For example:

- If each transaction produces 4 UTXOs, the total UTXO data per transaction is:  
  4 × 128 bytes = 512 bytes.

- At 100 transactions per second (TPS), the bandwidth requirement is:

$$
512\ \text{bytes/transaction} \times 100\ \text{TPS} = 51.2\ \text{kilobytes per second}.
$$

### Components affecting bandwidth

1. **Storage slots:**
    - Each storage slot contains hashed data representing private smart contract variables.
    - While the hash itself is compact (256 bits), the original data must also be transmitted during exchanges for verification by the recipient.

2. **Proofs:**
    - zkVM proofs for balance validation, membership, and non-membership checks are transmitted alongside UTXOs.
    - The size of these proofs varies depending on the proof system used, but they typically range from 128 bytes to several kilobytes.

3. **Transaction metadata:**
    - Metadata, such as privacy flags and protocol-specific identifiers, adds a minor overhead to each transaction but can accumulate across high-throughput systems.

### How to commit a UTXO

The commitment for a UTXO is computed using multiexponentiation, where each input to the commitment corresponds to a specific generator from the `generators[]` array. The mapping of components to generators is as follows:

| component      | generator        |
|----------------|-----------------|
| owner          | generators[0]   |
| amount         | generators[1]   |
| storage_slot   | generators[2]   |
| nonce          | generators[3]   |
| privacy_flag   | generators[4]   |

The UTXO commitment can be expressed as:

$$
\text{commit}_{utxo} = owner \cdot generators[0] + amount \cdot generators[1] + storage_{slot} \cdot generators[2] + nonce \cdot generators[3] + privacy_{flag} \cdot generators[4]
$$

### Optimization strategies

- Compress storage slot data during transmission, reducing its size while preserving integrity. Methods like:
  - Run-Length Encoding (RLE) for repetitive data.
  - Delta Encoding for incremental updates.
  - Lossless Compression Algorithms (e.g., Zstandard or Brotli).
- For transactions involving minimal state changes, optimize storage slots by only transmitting updated variables instead of the full state.
- Divide large storage states into smaller, independently verifiable units. Only the relevant partition is transmitted and verified during a transaction.
- Use hierarchical Merkle trees for storage slots, enabling compact proofs for specific subtrees instead of transmitting all data.

### Conclusion

While each UTXO is compactly designed, large-scale deployments face challenges due to the cumulative impact of high TPS and complex storage requirements. Strategic optimizations like compression, batching, and selective updates can mitigate bandwidth demands, ensuring NSSA's scalability in both private and hybrid execution environments. Further enhancements to proof systems and protocol-level efficiency measures will be critical for supporting future adoption.
