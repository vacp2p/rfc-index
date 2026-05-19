# LIONESS-PAYLOAD-ENCRYPTION-FOR-MIX

Field | Value
--- | ---
Name | LIONESS encryption scheme for LIBP2P-MIX payload encryption
Slug | TBD
Status | raw
Category | Standards Track
Editor | Mohammed Alghazwi <mohalghazwi@status.im>
Contributors | Balázs Kőműves <balazs@status.im>

## Abstract

This specification defines the LIONESS wide-block encryption scheme for the Sphinx payload encryption. The purpose of this is to perform layered-encryption and preserve payload integrity in the Sphinx construction used by the [Mix Protocol](./mix.md) while keeping the payload fixed-size. The routing header integrity mechanism defined in the [Mix Protocol](./mix.md) remains unchanged. Only the payload field $\delta$ is affected by this specification.

### Scope
This specification defines:
- the LIONESS construction to use for payload encryption and decryption,
- the concrete primitives used to instantiate LIONESS for the [Mix Protocol](./mix.md).
- the required Sphinx payload format and construction.
- the hop payload processing and integrity verification.

## 1. Introduction

The [Mix Protocol](./mix.md) uses a Sphinx packet format with four fields ($\alpha,\ \beta,\ \gamma,\ \delta$). The header fields ($\alpha,\ \beta,\ \gamma$) provide per-hop layered-encrypted routing information which includes header integrity. The payload field $\delta$ carries only the application message in layered-encrypted form.

In the current Mix Protocol, AES-CTR is used to encrypt the routing header $\beta$. This is sufficient for $\beta$ because header integrity is separately protected by the per-hop MAC field $\gamma$. However, the integrity of $\delta$ is not covered by $\gamma$, since the Sphinx design intentionally separates header integrity from payload integrity.

This separation is necessary because SURB replies require the sender of the SURB to construct the return header before the reply payload is known. As a result, payload integrity MUST be provided independently of header integrity.

A malleable encryption scheme such as AES-CTR does not satisfy this requirement. Bit modifications to the ciphertext result in modifications to the decrypted plaintext. This violates the integrity of the Sphinx payload. Therefore, the payload-encryption scheme MUST satisfy the following:
1. It MUST preserve the fixed payload size $|\delta|$.
2. It MUST support layered encryption and per-hop layer removal.
3. It MUST be compatible with SURBs and therefore MUST NOT require payload-dependent header authentication.
4. It MUST allow the final hop to detect payload tampering.
5. It MUST avoid adding external authentication material/tags that change the packet or payload size.

To achieve this, this specification uses LIONESS as described in [anderson et al](https://www.cl.cam.ac.uk/archive/rja14/Papers/bear-lion.pdf). LIONESS is a wide-block cipher built from a stream cipher and a keyed hash function. LIONESS acts as a pseudo-random permutation (PRP) over the entire payload block, allowing us to add an integrity prefix (e.g. leading zeros) into the plaintext and verify it after decryption.

## 2. Terminology
The following terms are used throughout this specification. Other terms are as defined in the [Mix Protocol](./mix.md).

- **Sphinx packet**: 
  The packet format as defined in the [Mix Protocol](./mix.md), consisting of ($\alpha,\ \beta,\ \gamma,\ \delta$).
- **Sphinx payload ($\mathbf{\delta}$)**
  The fixed-size encrypted field $\delta$ of a Sphinx packet.
  It carries the padded application message and any payload extensions such as SURBs.
- **Payload integrity prefix**
  A fixed all-zero byte string prepended to the plaintext payload before applying the payload encryption. The final hop verifies this prefix after payload decryption to detect payload tampering.
- **Payload encryption key ($\mathbf{\delta_{key}}$)**
  A per-hop key used to encrypt or decrypt one layer of the Sphinx payload field $δ$. 
  For LIONESS payload encryption, this key is used as the seed for deriving the internal LIONESS round keys.
- **Round keys**: 
  The four keys $(K_1, K_2, K_3, K_4)$ used by the LIONESS Feistel network.
- **Wide-block cipher**: 
  A block cipher with a large block size compared to conventional fixed-size block ciphers such as AES. LIONESS is a wide-block cipher that supports variable-length input blocks above a lower bound.
- **Pseudo-random permutation (PRP)**: 
  A keyed permutation over a fixed-size message block that is computationally indistinguishable from a uniformly random permutation. Changing even one bit of the input is expected to produce unpredictable changes to a large number of output bits.

## 3. Cryptographic Primitives

This section defines the primitives used by this specification. In this specification, we will assume the following constants:
- The security parameter $\kappa = 16$ bytes ($128$-bits) as defined in the [Mix Protocol](./mix.md).
- The LIONESS internal parameter $\mu = 32$ bytes, which defines the size of multiple LIONESS components.

### 3.1 Stream Cipher

The stream cipher $\mathsf{S}$ used in LIONESS can be abstracted as the following keyed function that produces an arbitrary-length keystream:

$`
\begin{array}{l}
\mathsf{S}(k) \to \mathsf{ks}
\end{array}
`$

where:
- $k$ is a $\mu$-byte key
- $\mathsf{ks}$ is the output arbitrary-length keystream.

Encryption and decryption can then be done by first generating a key stream $\mathsf{ks}$ and then XORing the key stream with the message/ciphertext. Encryption and decryption work in the same way: 

$`
\begin{aligned}
c &= m \oplus \mathsf{ks} \\
m &= c \oplus \mathsf{ks}
\end{aligned}
`$

where $m$ is the plaintext and $c$ is the ciphertext.
- $m$ is the arbitrary-length message
- $c$ is the arbitrary-length ciphertext of the same size as $m$, i.e., $|m| = |c|$
### 3.2 Keyed Hash Function

In this specification, the keyed hash function used in LIONESS is denoted as:

$`
\begin{array}{l}
\mathsf{H}_k(m) \to h
\end{array}
`$

where:
- $k$ is a $\mu$-byte key
- $m$ is an arbitrary-length input message.
- $h$ is the $\mu$-byte digest output

### 3.3 Key Derivation Function (KDF)
The key derivation function $\mathsf{KDF}$ is used to derive fixed-size keys from a domain-separation string and a seed:

$`
\begin{array}{l}
\mathsf{KDF}(\mathsf{dom}, \mathsf{seed}) \to u
\end{array}
`$

where

- $\mathsf{dom}$: is an arbitrary-length domain-separation string.
- $\mathsf{seed}$: is an arbitrary-length seed at least $\kappa$ bytes in size.
- $u$ is a $\mu$-byte output key.

## 4. Concrete Primitive Instantiation

This section defines the concrete primitive choices used by this specification.

### 4.1 Stream Cipher Instantiation

The LIONESS stream cipher $\mathsf{S}$ is instantiated using AES-CTR.

Each LIONESS stream-cipher round key $k$ is $\mu = 32$ bytes. For AES-CTR, this $32$-byte value is split as follows:

$`
\begin{array}{l}
k = k_{\mathsf{aes}} \parallel IV
\end{array}
`$

where:

- $k_{\mathsf{aes}}$ is the first $16$ bytes of $k$.
- $IV$ is the last $16$ bytes of $k$.

### 4.2 Keyed Hash Instantiation

The LIONESS keyed hash function $\mathsf{H}_k$ is instantiated as SHA-256 with the key prepended to the input message:

$`
\begin{array}{l}
\mathsf{H}_k(m) = \mathsf{SHA256}(k \parallel m)
\end{array}
`$

where:

- $k$ is a $\mu$-byte key.
- $m$ is the input message.
- the output is a $\mu$-byte digest.

This construction is used only as the keyed hash function inside the LIONESS Feistel construction. It is not (and must not be used as) a general-purpose MAC.

### 4.3 KDF Instantiation

The KDF is instantiated using SHA-256 with domain-separation:

$`
\begin{array}{l}
\mathsf{KDF}(\mathsf{dom}, \mathsf{seed}) =
\mathsf{SHA256}(\mathsf{dom} \parallel \mathsf{seed})
\end{array}
`$

where:

- $\mathsf{dom}$ is a domain-separation string.
- $\mathsf{seed}$ is an arbitrary-length seed at least $\kappa$ bytes in size.
- the output is a $\mu$-byte key.

The following domain-separation strings are used by this specification:

| Purpose | Domain-separator |
|---|---|
| Payload encryption key $\delta_{\mathrm{key}}$ | `payload_enc_key` |
| LIONESS round key $K_1$ | `lioness_key1` |
| LIONESS round key $K_2$ | `lioness_key2` |
| LIONESS round key $K_3$ | `lioness_key3` |
| LIONESS round key $K_4$ | `lioness_key4` |

## 5. LIONESS Construction

### 5.1 High-level API
In general, the LIONESS wide-block cipher provides the following:

$`
\begin{array}{l}
\mathsf{LIONESS.Enc}(k,x) \to y \\
\mathsf{LIONESS.Dec}(k,y) \to x 
\end{array}
`$

where:
- $k$ is the arbitrary-length seed (master key) from which the internal round keys are derived, with size at least $\kappa$ bytes
- $x$ is the plaintext message with size $|x| \ge 2\mu$ bytes.
- $y$ is the corresponding ciphertext with size $|y| = |x|$

### 5.2 Block Structure
LIONESS is a wide-block cipher, meaning that its block size is large compared to conventional fixed-size block ciphers such as AES. In this specification, LIONESS is applied once to the entire Sphinx payload $\delta$. The whole payload is treated as a single message block, and LIONESS acts as a PRP over that full payload block.
For both LIONESS encryption and decryption, the input block $B$ is split into two chunks:

$`
\begin{array}{l}
B = L \parallel R 
\end{array}
`$

where:
- $B$ is the plaintext message block of any size $|B| \ge 2\mu$
- $L$ is the left chunk with size $|L| = \mu$ bytes
- $R$ is the right chunk with size $|R| = |B| - \mu$ bytes.

In this specification, we require the size of the message to be at least $2\mu$, i.e., $|B| \ge 2\mu$. This requirement ensures that $|L| = \mu$ and $|R| \ge \mu$. The Mix protocol payload size satisfies this requirement since the expected payload is much larger than $2\mu$.

In summary, we set $\mu = 32$ bytes. Therefore:
- $|B| \ge 64$ bytes
- $|L| = \mu = 32$ bytes,
- $|R| = |B| - |L|$ bytes.

The choice $\mu = 32$ bytes must match:
- the stream cipher ($\mathsf{S}$) key size, and
- the keyed hash ($H_k$) key size and digest ($h$) size.

As a result, we can observe that for large messages, the right chunk is expected to be much larger than the left chunk.

```
+----------------+----------------------------------+
|       L        |          R                       |
|   mu bytes     |    (|B| - mu) bytes              |
+----------------+----------------------------------+
```

### 5.3 Key Derivation
LIONESS requires four internal round keys, one for each round: $(K_1, K_2, K_3, K_4)$:

- $K_1$ and $K_3$ are the keys used for the stream cipher.
- $K_2$ and $K_4$ are the keys used for the keyed hash function.

All internal round keys are $\mu = 32$ bytes in size. Given a LIONESS seed $k$, we require four calls to the $\mathsf{KDF}$, each with a different domain-separation string:

$`
\begin{aligned}
K_1 &= \mathsf{KDF}(\texttt{"lioness\_key1"}, k) \\
K_2 &= \mathsf{KDF}(\texttt{"lioness\_key2"}, k) \\
K_3 &= \mathsf{KDF}(\texttt{"lioness\_key3"}, k) \\
K_4 &= \mathsf{KDF}(\texttt{"lioness\_key4"}, k)
\end{aligned}
`$

The LIONESS seed is arbitrary-length and MUST be at least $\kappa$ bytes. The derivation of the seed depends on whether the packet is a forward packet or a reply packet. Further details are specified in [Section 6](#6-payload-construction) and [section 7](#7-sphinx-payload-processing).

### 5.4 Encryption

Let:
- plaintext message $B = L_0 \parallel R_0$
- round keys $(K_1, K_2, K_3, K_4)$ 
- $\mathsf{S}$ is the stream cipher as defined in [section 3.1](#31-stream-cipher)
- $\mathsf{H}_k$ is the keyed hash function as defined in [section 3.2](#32-keyed-hash-function)

LIONESS encryption proceeds with applying a small Feistel network of four rounds:

$`
\begin{aligned}
B &= L_0 \parallel R_0 \\
R_1 &= R_0 \oplus S(K_1 \oplus L_0) \\
L_1 &= L_0 \oplus H_{K_2}(R_1) \\
R_2 &= R_1 \oplus S(K_3 \oplus L_1) \\
L_2 &= L_1 \oplus H_{K_4}(R_2) \\
C   &= L_2 \parallel R_2
\end{aligned}
`$

```                                                   
round 1:  R1 = R0 ^ S(L0 ^ K1)                        
                                                      
+-----------+                           +-----------+ 
|    L0     |                           |    R0     | 
+-----------+                           +-----------+ 
      |                 K1                    |       
      |                 │                     | xor   
      |                 │                     v       
      |                 v              +-------------+
      +----------------xor------------>|      S      |
                                       +-------------+
                                              |       
                                              v       
+-----------+                           +-----------+ 
|    L0     |                           |    R1     | 
+-----------+                           +-----------+ 
                                                      
                                                      
round 2:  L1 = L0 ^ H_K2(R1)                          
                                                      
+-----------+                           +-----------+ 
|    L0     |                           |    R1     | 
+-----------+                           +-----------+ 
      |                                       |       
      | xor                                   |       
      v                                       |       
+-------------+<------------------------------+       
|      H      |<----- K2                              
+-------------+                                       
      |                                               
      v                                               
+-----------+                           +-----------+ 
|    L1     |                           |    R1     | 
+-----------+                           +-----------+ 
                                                      
                                                      
round 3:  R2 = R1 ^ S(L1 ^ K3)                        
                                                      
+-----------+                           +-----------+ 
|    L1     |                           |    R1     | 
+-----------+                           +-----------+ 
      |                K3                     |       
      |                │                      | xor   
      |                │                      v       
      |                v               +-------------+
      +---------------xor------------->|      S      |
                                       +-------------+
                                              |       
                                              v       
+-----------+                           +-----------+ 
|    L1     |                           |    R2     | 
+-----------+                           +-----------+ 
                                                      
                                                      
round 4:  L2 = L1 ^ H_K4(R2)                          
                                                      
+-----------+                           +-----------+ 
|    L1     |                           |    R2     | 
+-----------+                           +-----------+ 
      |                                       |       
      | xor                                   |       
      v                                       |       
+-------------+<------------------------------+       
|      H      |<----- K4                              
+-------------+                                       
      |                                               
      v                                               
+-----------+                           +-----------+ 
|    L2     |                           |    R2     | 
+-----------+                           +-----------+ 
```                                                   

### 5.5 Decryption

LIONESS decryption is the inverse of the four internal rounds defined in the previous section:

$`
\begin{aligned}
C &= L_2 \parallel R_2 \\
L_1 &= L_2 \oplus H_{K_4}(R_2) \\
R_1 &= R_2 \oplus S(K_3 \oplus L_1) \\
L_0 &= L_1 \oplus H_{K_2}(R_1) \\
R_0 &= R_1 \oplus S(K_1 \oplus L_0) \\
B &= L_0 \parallel R_0
\end{aligned}
`$

## 6. Payload Construction
This section specifies how the Sphinx payload is constructed using the LIONESS wide-block encryption. Some parts of this section restates the Mix specification for clarity. For full specification of how the Sphinx packet is constructed, refer to the [mix protocol specification](./mix.md).

### 6.1 Payload Plaintext Format

Before layered encryption, the sender MUST construct the payload plaintext as the following concatenation:

$`
\begin{array}{l}
B = z \parallel m
\end{array}
`$

where:
- $z = 0_\kappa$ is the payload integrity prefix, consisting of $\kappa$ zero bytes.
- $m$ is the application message padded to fill the remaining payload space.

Thus:
- $|z| = \kappa$ bytes
- $|B| = |\delta|$
- $|m| = |B| - |z|$

The size of the payload $|\delta|$ is specified in the Mix protocol, and if the application message $|m|$ is small payload padding is added as specified in the [mix protocol](./mix.md).

### 6.2 Sphinx Payload Construction

#### 6.2.1 Forward Payload
Once the plaintext is formatted as specified in [section 6.1](#61-payload-plaintext-format), it needs to be encrypted in layers such that each hop in the mix path removes exactly one layer using the per-hop session key. This ensures that only the final hop (i.e., the exit node) can fully recover the plaintext message $m$, validate its integrity, and forward it to the destination. To compute the encrypted payload, perform the following steps for each hop $i = L-1$ down to $0$, recursively:

1. Derive the payload encryption key:

    $`
    \begin{array}{l}
    \delta_{\mathrm{key}_i} = \mathsf{KDF}(\texttt{"payload\_enc\_key"}, s_i)
    \end{array}
    `$ 

   where $s_i$ is the per-hop shared secret for hop `i` as defined in the Mix protocol specification.

2. Using $\delta_{\mathrm{key}_i}$, compute the encrypted payload $\delta_i$:
  - If $i = L-1$ (_i.e.,_ exit node):
       
    $`
    \begin{array}{l}
    \delta_i = \mathsf{LIONESS.Enc}\bigl(\delta_{\mathrm{key}_i}, B
    \bigr)
    \end{array}
    `$

  - Otherwise (_i.e.,_ intermediary node):

    $`
    \begin{array}{l}
    \delta_i = \mathsf{LIONESS.Enc}\bigl(\delta_{\mathrm{key}_i},
    \delta_{i+1} \bigr)
    \end{array}
    `$

   The resulting $\delta$ is placed into the final Sphinx packet.

#### 6.2.2 Reply payload (SURB payload)
For a SURB reply, the reply sender (i.e., the SURB user not the SURB creator) does not know the return-path shared secrets $s_0, \ldots, s_{L-1}$. Instead, it only has the first node in the return path ($\mathrm{hop}_0$), a pre-computed Sphinx header ($\alpha, \beta, \gamma$), and a reply key ($\tilde{k}$).

Therefore, the reply sender encrypts the reply payload $B$ only once using $\tilde{k}$ as the LIONESS seed:

$`
\begin{array}{l}
\delta = \mathsf{LIONESS.Enc}(\tilde{k}, B)
\end{array}
`$

Note that the reply key $\tilde{k}$ is $\kappa$ bytes in size as defined in the [Mix Protocol](./mix.md), so it satisfies the LIONESS seed requirement. The resulting $\delta$ is placed into the SURB reply packet. Then each hop on the return path subsequently applies the normal payload-processing rule, namely one LIONESS decryption under its per-hop payload encryption key, resulting in one layer of LIONESS encryption and $L$ layers of LIONESS decryptions. These $L + 1$ return path layers are later removed during reply recovery as described in [section 7.3](#73-exit-processing---reply-packet).

## 7. Sphinx Payload Processing

Once the Sphinx packet is deserialized into ($\alpha,\ \beta,\ \gamma,\ \delta$) and the header is preprocessed as specified in the Mix protocol, the mix node performs the following steps depending on its role (as defined in the [Mix Protocol, Section 8.6.2](./mix/#862-node-role-determination)):

### 7.1 Intermediary Processing

If the node is an intermediary, it MUST:
1. Derive the payload encryption key using the shared secret $s$:

    $`
    \begin{array}{l}
    \delta_{\mathrm{key}} = \mathsf{KDF}(\texttt{"payload\_enc\_key"}, s)
    \end{array}
    `$

2. Decrypt one layer of the payload using the payload encryption key $\delta_{\mathrm{key}}$: 

    $`
    \begin{array}{l}
    \delta' = \mathsf{LIONESS.Dec}\bigl(\delta_{\mathrm{key}}, \delta \bigr)
    \end{array}
    `$

3. use $\delta'$ as the outgoing payload,
4. forward the updated packet as defined by the [Mix Protocol](./mix.md).

### 7.2 Exit Processing - Forward packet

If the node is the exit, and the packet is not a reply (using SURBs), it MUST:
1. Derive the payload encryption key using the shared secret $s$ in the same way as defined in [section 7.1 step 1](#71-intermediary-processing). 
2. Decrypt one layer of the payload using the payload encryption key $\delta_{\mathrm{key}}$ in the same way as defined in [section 7.1 step 2](#71-intermediary-processing). 
3. perform the payload integrity prefix check as follows:
  - parse the decrypted payload $\delta'$ as $B = z \parallel m$, where $|z| = \kappa$ bytes.
  - verify that $z = 0_\kappa$
  - discard the packet if this payload integrity prefix check fails.
  - otherwise remove $z$ (i.e., the $\kappa$ bytes of payload integrity prefix) and return $m$.
4. pass $m$ to the Mix Exit Layer.

### 7.3 Exit Processing - Reply packet
If the node is the exit, and the packet is a reply, it MUST:
1. reverse the return-path transformations, i.e., since the hops apply LIONESS decryption, the exit must apply LIONESS encryption. Therefore, the node must perform the same LIONESS layered encryption pattern as defined in [Section 6.2.1](#621-forward-payload), with the reply payload $\delta$ used as the initial input instead of the plaintext payload block $B$.

2. Decrypt the final layer i.e., reversing the effect of the initial encryption in [section 6.2.2](#622-reply-payload-surb-payload):

    $`
    \begin{array}{l}
    B = \mathsf{LIONESS.Dec}(\tilde{k}, \delta)
    \end{array}
    `$

3. perform the payload integrity prefix check as defined in [section 7.2 step 3](#72-exit-processing---forward-packet) and then pass $m$ to the Mix Exit Layer.

*Note: We assume here that the exit is the SURB creator, if not then the exit will simply forward $\delta$ to the destination which will process the reply payload as specified above.*

## 8. Security Considerations

### 8.1 LIONESS Blocks/Messages
This specification requires the LIONESS input block to be at least $2\mu$ bytes, i.e., 64 bytes since we assume $\mu = 32$.

LIONESS splits the input block into two parts 

$`
\begin{array}{l}
B = L \parallel R
\end{array}
`$

where:
- $|L| = \mu = 32$ bytes,
- $|R| = |B| - \mu$ bytes.

Therefore, the 64-byte minimum ensures that both $L$ and $R$ contain at least $\mu$ bytes. The [Mix Protocol](./mix.md) payload size is expected to be much larger than this minimum, so this requirement is satisfied by normal Mix payloads.

### 8.2 LIONESS Integrity

This specification does not use an explicit payload authentication tag. Instead, integrity is obtained by:
- embedding a fixed payload integrity prefix, specified as $\kappa$ bytes of zeros, into the plaintext,
- encrypting the whole payload as a single block with LIONESS.

Because the payload is encrypted as a single block, LIONESS acts as a pseudo-random permutation (PRP) over the entire payload, a modification to the ciphertext will, except with negligible probability, produce a decrypted plaintext whose first $\kappa = 16$ bytes are not all zero. Replacing LIONESS with a malleable stream construction invalidates this property.

### 8.3 Primitive Choices
The security of LIONESS depends on the security of the primitives used to instantiate it:
- the stream cipher $\mathsf{S}$,
- the keyed hash function $\mathsf{H}_k$,
- the key derivation function $\mathsf{KDF}$.

Implementations may use any compatible choices. For detailed analysis on the security of LIONESS, refer to the [paper](https://www.cl.cam.ac.uk/~rja14/Papers/bear-lion.pdf). 

## 9. Reference Implementations

- [Rust reference implementation of LIONESS](https://github.com/logos-storage/lioness_blockcipher)
- [Haskell reference implementation](https://github.com/logos-storage/transport-over-mix).

These reference implementations are generic and can support any compatible $\mathsf{S}$, $\mathsf{H}_k$, and $\mathsf{KDF}$. 

## 10. Future Work

The following are under research/consideration:
- support for faster alternative wide-block ciphers: 
  - [AEZ authenticated encryption scheme](https://www.cs.ucdavis.edu/~rogaway/aez/index.html) 
  - [Accordion mode based on Hash-Encrypt-Hash](https://csrc.nist.gov/csrc/media/Events/2024/accordion-cipher-mode-workshop-2024/documents/papers/accordion-mode-based-hash-encrypt-hash.pdf)

## References

- [Sphinx: A Compact and Provably Secure Mix Format](https://eprint.iacr.org/2008/475.pdf)
- [The Bear and Lion Block Cipher Design](https://www.cl.cam.ac.uk/~rja14/Papers/bear-lion.pdf)
- [Mix Protocol](./mix.md)