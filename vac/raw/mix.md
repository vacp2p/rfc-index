---
title: LIBP2P-MIX
name:  Libp2p Mix Protocol
status: raw
category: Standards Track
tags:
editor: Akshaya Mani <akshaya@status.im>
contributors:
---

## Abstract

This document specifies the Mix protocol, a custom protocol within the
[libp2p](https://libp2p.io) framework designed to enable anonymous communication
in peer-to-peer networks. The Mix protocol allows libp2p nodes to send messages
without revealing the sender's identity to intermediary nodes or the recipient.
It achieves this by using the [Sphinx packet format](https://www.researchgate.net/publication/220713667_Sphinx_A_Compact_and_Provably_Secure_Mix_Format),
which encrypts and routes messages through a series of nodes (mix nodes)
before reaching the recipient.

Key features of the protocol include:

i. Path selection for choosing a random route through the network via multiple
mix nodes.\
ii. Sphinx packet construction and processing, providing cryptographic
guarantees of anonymity and security.\
iii. Pluggable spam protection mechanism to prevent abuse of the mix network.\
iv. Delayed message forwarding to thwart timing analysis attacks.

**Protocol identifier:** `"/mix/1.0.0"`

Note: The Mix Protocol is designed to work alongside existing libp2p protocols,
allowing for seamless integration with current libp2p applications while
providing enhanced privacy features. For example, it can encapsulate messages
from protocols like [GossipSub](https://github.com/libp2p/specs/blob/master/pubsub/gossipsub/gossipsub-v1.2.md)
to ensure sender anonymity.

## Background

libp2p protocols do not inherently protect sender identities.

The Mix protocol enhances anonymity in libp2p by implementing a mix network,
where messages are anonymized through multiple relay nodes before reaching the
intended recipient. The Sphinx packet format is a well-researched component which
this specification leverages to offer strong anonymity properties by concealing
sender and recipient information at each relay.

Using this approach, even the nodes relaying messages cannot determine the
sender or final recipient, within a robust adversarial model. This decentralized
solution distributes trust among participants, eliminating single points of
failure and enhancing overall network resilience. Additionally, pluggable
spam protection mechanism and delayed forwarding address common attacks on
anonymity networks, such as spam and timing analysis.

The Mix protocol is designed with flexibility in mind, allowing for
pluggable components such as spam protection, peer discovery, and
incentivization mechanisms. This design choice enables the protocol to evolve
and adapt to different network requirements and constraints. This also leaves
room for future enhancements such as cover traffic generation.

By incorporating these features, the Mix protocol aims to provide a robust
anonymity layer within the libp2p ecosystem, enabling developers to easily
incorporate privacy features into their applications.

## Specification

### 1. Protocol Identifier

The Mix protocol is identified by the string `"/mix/1.0.0"`.

### 2. Custom Mix Protocol

The Mix protocol is designed as a standalone protocol,
identified by the protocol identifier `"/mix/1.0.0"`.
This approach allows the Mix protocol to operate independently,
decoupled from specific applications,
providing greater flexibility and reusability across various libp2p protocols.
By doing so, the Mix protocol can evolve independently,
focusing on its core functionality without being tied to the development
and maintenance cycles of other protocols.

#### 2.1 Mix Nodes Roles

All nodes participating in the Mix protocol are considered as mix nodes. They
have the capability to create/process and forward Sphinx packets. Mix nodes can
play different roles depending on their position in a particular message path:

- **Sender Node**
  - A mix node that initiates the anonymous message publishing process.
  - Responsible for:
    - Path selection.
    - Sphinx packet creation.
    - Initiating the message routing through the mix network.
  - Must run both the Mix protocol instance and the instance of the libp2p
    protocol for the message being published (_e.g.,_ GossipSub, Ping, etc.).
- **Intermediary Mix Node**
  - A mix node that is neither the sender nor the exit node in a message path.
  - Responsible for:
    - Receiving Sphinx packets.
    - Processing (decrypting and re-encrypting) Sphinx packets.
    - Forwarding processed packets to the next node in the path.
  - Only needs to run the Mix protocol instance.
- **Exit Node**
  - The final mix node in a message path.
  - Responsible for:
    - Receiving and processing the final Sphinx packet.
    - Extracting the original message.
    - Disseminating the decrypted message using the appropriate libp2p protocol.
  - Must run both the Mix protocol instance and the instance of the libp2p
    protocol for the message being published.

#### 2.2 Roles Flexibility

A single mix node can play different roles in different paths:

- It can be a sender node for messages it initiates.
- It can be an intermediary node for messages it is forwarding.
- It can be an exit node for messages it is disseminating.

#### 2.3 Incentives

To publish an anonymous libp2p message (_e.g.,_ GossipSub, Ping, etc.), nodes
MUST run a mix node instance. This requirement serves as an incentive for nodes
to participate in the mix network, as it allows them to benefit from the
anonymity features while also contributing to the network's overall anonymity
and robustness.

#### 2.4 Node Discovery

All mix nodes participate in the discovery process and maintain a list of
discovered nodes.

- **Bootstrap Nodes**

  i. The network has a set of well-known bootstrap nodes that new mix nodes
  can connect to when joining the network.\
  ii. The bootstrap nodes help new mix nodes discover other active mix nodes in
  the network.

- **Discovery**
  
  i. All mix nodes publish their Ethereum Node Records (ENRs) containing:

  ```json
  {
    "id": "v4",
    "multiaddr": "/ip4/192.0.2.1/udp/9000/quic",
    "ed25519": "0x5a6fcd3e9d6a5e4d5f71e7e5b4cfa9b7b73d9f5f7e9a8b9c5d7f9e8d5a6f7c9e",
    "mix": "/mix/1.0.0",
    "supported_protocols": ["ping", "gossipsub"]
  }
  ```

  **Field Explanations**

  - `id`: Indicates the ENR format version (_e.g.,_ `"v4"`).
  - `multiaddr`: The node's multiaddress, including the transport protocol
    (_e.g.,_ QUIC) and IP address/port.
  - `ed25519`: The node's Ed25519 public key, used for Sphinx encryption.
  - `mix`: Indicates the supported Mix protocol version (_e.g.,_ `"/mix/1.0.0"`).
  - `supported_protocols`: A list of other libp2p protocols supported by the
    node (_e.g.,_ Ping, GossipSub, etc.).
  - Additional fields may be included based on the node's requirements.
  
  ii. The mix nodes use a peer discovery protocol like [WAKU](https://waku.org)/[Discv5](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md):
  
  - Connect to a set of bootstrap nodes when joining the network.
  - Regularly update their list of known peers.
  - Obtain a random sample of nodes that is representative of the network.

- **Path Selection (Message Senders Only)**

  To send an anonymous message, a mix node performs the following actions:
  
  i. Choose a random exit node that supports the required libp2p protocol for
  the message.\
  ii. Select remaining L-1 unique mix nodes randomly without replacement from
  the list of discovered nodes.

- **Forwarding To Next Hop (Intermediary Nodes Only)**

  When a mix node receives an incoming Sphinx packet, it performs the following
  actions:

  i. Decrypts the packet to obtain the next hop multiaddress\
  ii. Checks if the next hop is in the list of discovered nodes.\
  iii. If not, performs discovery for that specific node.\
  iv. Forwards the Sphinx packet to the next hop.

#### 2.5 Protocol Registration

The protocol is registered with the libp2p host using the `"/mix/1.0.0"`
identifier. This identifier is used to establish connections and negotiate the
protocol between libp2p peers.

#### 2.6 Transport Layer

The Mix protocol uses secure transport protocols to ensure confidentiality and
integrity of communications. The recommended transport protocols are
[QUIC](https://datatracker.ietf.org/doc/rfc9000/) or TLS (preferably QUIC
due to its performance benefits and built-in features
such as low latency and efficient multiplexing).

#### 2.7 Connection Establishment

- The sender initiates a secure connection (TLS or QUIC) to the first mix node
  using the libp2p transport.
- The sender uses the `"/mix/1.0.0"` protocol identifier to convey that the
  connection is for the Mix protocol.
- Once the connection is established, the sender can forward Sphinx packets
  using the Mix protocol.
- Subsequent mix nodes in the path follow the same process when forwarding
  messages to other mix nodes.

### 3. Cryptographic Primitives and Security Parameter

- **Security Parameter:** $\kappa = 128$ bits provides a balance between
  security and efficiency.
- **Cryptographic Primitives**
  - **Group G**: Curve25519 elliptic curve offers 128-bit security with small
    (32-byte) group elements, efficient for both encryption and key exchange.
  - **Hash function H**: SHA-256.
  - **KDF:** SHA-256 (truncated to 128 bits).
  - **AES-CTR:** AES-128 in counter mode.
    - **Inputs:** Key `k` (16 bytes), Initialization Vector `iv` (16 bytes),
      Plaintext `p`
    - **Initialization Vector (IV)**: 16 bytes, chosen randomly for each
      encryption.
    - **Plaintext**: Data to be encrypted (_e.g.,_ routing information, message
      payload).
    - **Output**: Ciphertext `c` (same size as plaintext `p`).
    - **Operation**: AES-CTR mode uses key and the counter (`iv`) to produce a
      keystream, which is XORed with the plaintext to produce the ciphertext.
  - **HMAC-SHA-256:** 256-bit MAC (truncated to 128 bits).
    - **Inputs:** Key `k` (16 bytes), Message `m`
    - **Message**: Data to be authenticated (_e.g.,_ $β$ component).
    - **Output**: MAC `mac` (truncated to 128 bits).
    - **Operation**: HMAC-SHA-256 uses the key and the message to produce a
      hash-based message authentication code.

### 4. Sphinx Packet Format

#### 4.1 Packet Components and Sizes

1. **Alpha ($α$)**: 32 bytes

   - Represents a Curve25519 group element (x-coordinate in GF(2^255 - 19)).
   - Used by mix nodes to extract shared session key using their private key.

2. **Beta ($β$)**: $((t+1)r + 1)\kappa$ bytes typically, where $r$ is the maximum
   path length.

   - Contains the encrypted routing information.
   - We recommend a reasonable maximum path length of $r=5$, considering
    latency/anonymity trade-offs.
   - This gives a reasonable size of $336$ bytes, when $t = 3$ (refer
     Section 5.2.10 for the choice of $t$).
   - We extend $β$ to accommodate next hop address and delay below.

3. **Gamma ($γ$)**: $\kappa$ bytes (16 bytes)

   - Output of HMAC-SHA-256, truncated to 128 bits.
   - Ensures the integrity of the header information.

4. **Delta ($δ$)**: The encrypted payload, which can be of variable size.
   - According to the [MixMatch](https://petsymposium.org/popets/2024/popets-2024-0050.pdf)
    paper, the Nym network uses Sphinx packets of a fixed
    size (2413 bytes).
   - Considering this, the maximum $δ$ size can be chosen as 2413 bytes minus
    the header length (which will be derived below).

#### 4.2 Address Format and Delay Specification

In the original
[Sphinx](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf) paper, the
authors use node IDs of size $\kappa$ ($16$ bytes) to represent the next hop
addresses. To accommodate larger addresses, we'll use a combined size of
$t\kappa$ bytes for the address and delay, where $t$ is small (_e.g.,_ $t = 2$
or $3$).

- **Delay**: 2 bytes
  Allows delays up to 65,535 milliseconds ≈ 65 seconds.
- **Address**: $t\kappa-2$ bytes
  This flexible format can accommodate various address types, including:
  - libp2p multiaddress (variable length, typically 32-64 bytes).
  - Custom format with:
    - IP address (IPv4 or IPv6, 4 or 16 bytes)
    - TCP/UDP port number (2 bytes)
    - QUIC/TLS protocol identifier flag (1 byte)
    - Peer ID (32 bytes for Ed25519 or Secp256k1).

The entire Sphinx packet header ($α$, $β$, and $γ$) can fit within a fixed size
of $32 + (r(t+1)+1)\kappa + 16 = 384$ bytes, leaving ample room for a large $δ$ of
up to $2413 - 384 = 2029$ bytes.

#### 4.3 Message Format

The Mix protocol uses the Sphinx packet format to encapsulate messages and
routing information.

```proto
message SphinxPacket {
  bytes alpha = 1; // 32 bytes
  bytes beta = 2; // 304 - 384 bytes
  bytes gamma = 3; // 16 bytes
  bytes delta = 4; // variable size, max 2029 bytes
}
```

### 5. Handler Function

The [handler function](https://docs.libp2p.io/concepts/fundamentals/protocols/#handler-functions)
is responsible for processing connections and messages for
the Mix protocol. It operates according to the mix node roles (_i.e.,_ sender,
intermediary mix node, or exit node) defined in
[Section 2.1](#21-mix-nodes-roles). This function is crucial for implementing
the core functionality of the mixnet protocol within the libp2p framework.

When a node receives a new stream for the `"/mix/1.0.0"` protocol, the handler
function is invoked. It performs different operations based on the node's role
in the current message path:

- **Role Determination**

  The handler first determines the node's role for the incoming message. This
  is typically done by examining the packet structure and the node's position
  in the network.

- **Packet Processing**

  Depending on the role, the handler processes the Sphinx packet differently:

  - For senders, it creates and sends new Sphinx packets.
  - For intermediary nodes, it processes and forwards existing packets.
  - For exit nodes, it decrypts the final layer and disseminates the original message.

- **Error Handling**

  It manages any errors that occur during packet processing, such as invalid
  MACs or decryption failures.

- **Logging and Metrics**

  The handler is also be responsible for logging important events and
  collecting metrics for network analysis and debugging.

The specific implementation of the handler function for each role (_i.e.,_
sender, intermediary, and exit node) is detailed in the following subsections.

#### 5.1 Sender

1. **Convert the libp2p Message to Bytes**

   Serialize the libp2p message to bytes and store the result in
   `libp2p_message`. This can be done using Protocol Buffers or another
   serialization method.

2. **Apply Spam Protection**

   Apply the chosen spam protection mechanism to the `libp2p_message`.
   This could be Proof of Work (PoW), Verifiable Delay Function (VDF),
   Rate Limiting Nullifier (RLN), or other suitable approaches.

   Refer to [Appendix A](#appendix-a-example-spam-protection-using-proof-of-work)
   for details on the current implementation using PoW.

3. **Prepare the Message**

   Prepare the `message` by combining the `libp2p_message` with any necessary data
   from the spam protection mechanism. The exact format of `message` will depend
   on the chosen spam protection method.

   Note: The spam protection mechanism is designed as a pluggable interface,
   allowing for different methods to be implemented based on network requirements.
   This flexibility extends to other components such as peer discovery and incentivization,
   which are not specified in detail to allow for future optimizations and adaptations.

4. **Perform Path Selection** (refer [Section 2.4](#24-node-discovery))

   - Let the Ed25519 public keys of the mix nodes in the path be
    $y_0,\ y_1,\ \ldots,\ y_{L-1}$.

5. **Wrap Final Message in Sphinx Packet**
   Perform the following steps to wrap `message` in a Sphinx packet:

   a. **Compute** **Alphas ($α_i$**, **$i=0$** to **$L-1$)**

   - Select a random exponent $x$ from $\mathbb{Z}_q^*$.
   - Compute initial alpha $α_0$, shared secret $s_0$, and blinding factor $b_0$:
     - $α_0 = g^x$ using Curve25519 scalar multiplication.
     - $s_0 = y_0^x$, where $y_0$ is the public key of the first hop.
     - $b_0 = H(α_0\ |\ s_0)$, where $H$ is the SHA-256 hash function (refer
      _[Section 3](#3-cryptographic-primitives-and-security-parameter)_ for details).
   - For each node $i$ (from $1$ to $L-1$):
     - $α_i = α_{i-1}^{b_{i-1}}$ using Curve25519 scalar multiplication.
     - $s_i = y_{i}^{x\prod_{\text{j=0}}^{\text{i-1}} b_{j}}$, where $y_{i}$ is
      the public key of the i-th hop.
     - $b_i = H(α_i\ |\ s_i)$, where $H$ is the SHA-256 hash function.

   Note that $\alpha_i$ and $s_i$ are group elements, each 32 bytes long.

   b. **Compute** **Filler Strings ($\phi_i$**, **$i=0$** to **$L-1$)**

   - Initialize $\phi_0$ as an empty string.
   - For each $i$ (from $1$ to $L-1$):

     - Derive the AES key and IV:

       $`\text{φ\_aes\_key}_{i-1} = KDF(\text{"aes\_key"}\ |\ s_{i-1})`$

       $`\text{φ\_iv}_{i-1} = H(\text{"iv"}\ |\ s_{i-1})`$ (truncated to 128 bits)

     - Compute the filler string $\phi_i$ using $\text{AES-CTR}^\prime_i$,
       which is AES-CTR encryption with the keystream starting from
       index $((t+1)(r-i)+t+2)\kappa$ :

       $`\phi_i = \text{AES-CTR}^\prime_i(\text{φ\_aes\_key}_{i-1},\ \text{φ\_iv}_{i-1},
       \ \phi_{i-1}\ |\ 0_{(t+1)\kappa})`$,
       where $0_{(t+1)\kappa}$ is the string of $0$ bits of length $(t+1)\kappa$.

   Note that the length of $\phi_i$ is $(t+1)i\kappa$.

   c. **Compute** **Betas and Gammas ($\beta_i$**, $\gamma_i$, **$i=0$** to **$L-1$)**

   For each $i$ (from $L-1$ to $0$):

   - Derive the AES key, MAC key, and IV:

     $`\text{β\_aes\_key}_{i} = KDF(\text{"aes\_key"}\ |\ s_{i})`$

     $`\text{mac\_key}_{i} = KDF(\text{"mac\_key"}\ |\ s_{i})`$

     $`\text{β\_iv}_{i} = H(\text{"iv"}\ |\ s_{i})`$ (truncated to 128 bits)

   - Generate random $`\text{delay\_i}`$, a 16-bit unsigned integer (0-65535 milliseconds).

     Note that top-level applications can use other probability distributions,
     such as an exponential distribution, where shorter delays are more likely
     than longer delays. This can mimic real-world traffic patterns and provide
     robust anonymity against traffic analysis. The trade-off lies in balancing
     the need for flexible delay handling with the risk of exposing
     application-specific traffic patterns.

   - If $i = L-1$ (_i.e.,_ exit node):

     $`\beta_i = \text{AES-CTR}(\text{β\_aes\_key}_{i},\ \text{β\_iv}_{i},\ 0_{((t+1)
     (r-L)+t+2)\kappa})\ |\ \phi_{L-1}`$

   - Otherwise (_i.e.,_ intermediary node):

     $`\beta_i = \text{AES-CTR}(\text{β\_aes\_key}_{i},\ \text{β\_iv}_{i},\ \text
     {addr}_{i+1} \ |\ \text{delay}_{i+1}\ | \ \gamma_{i+1}\ |\ {\beta_{i+1}}_
     {[0\ldots(r(t+1)-t)\kappa−1]})`$

     Note that the length of $\beta_i$ is $(r(t+1)+1)\kappa$, $0 \leq i \leq L-1$,
     where $t$ is the combined length of next hop address and delay.

   - $`\gamma_i = \text{HMAC-SHA-256}(\text{mac\_key}_i,\ β_i)`$\
      Note that the length of $\gamma_i$ is $\kappa$.

   d. **Compute** **Deltas (**$\delta_i$, **$i=0$** to **$L-1$)**

   For each $i$ (from $L-1$ to $0$):

   - Derive the AES key and IV:

     $`\text{δ\_aes\_key}_{i} = KDF(\text{"δ\_aes\_key"}\ |\ s_{i})`$

     $`\text{δ\_iv}_{i} = H(\text{"δ\_iv"}\ |\ s_{i})`$ (truncated to 128 bits)

   - If $i = L-1$ (_i.e.,_ exit node):

     $`\delta_i = \text{AES-CTR}(\text{δ\_aes\_key}_{i},\ \text{δ\_iv}_{i},
     \ 0_{\kappa}\ |\ m)`$, where $m$ is the `message`.

   - Otherwise (_i.e.,_ intermediary node):

     $`\delta_i = \text{AES-CTR}(\text{δ\_aes\_key}_{i},\ \text{δ\_iv}_{i},\ \delta_{i+1})`$

     Note that the length of $\delta$ is $|m| + \kappa$.

     Given that the derived size of $\delta$ is $2029$ bytes, this allows
     `message` to be of length $2029-16 = 2013$ bytes. This means smaller
     messages may need to be padded up to $2013$ bytes (e.g., using PKCS#7
     padding).

   e. **Construct Final Sphinx Packet**

   - Initialize header

     ```pseudocode
     alpha = alpha_0 // 32 bytes
     beta = beta_0 // $(r(t+1)+1)\kappa$ bytes
     gamma = gamma_0 // 16 bytes
     ```

     As discussed earlier, for a maximum path length of $r = 5$, and combined
     length of address and delay $t = 3\kappa = 48$ bytes, the header size is
     just $384$ bytes.
   - Initialize payload

     `delta = delta_0 // variable size, max 2029 bytes`

     For a fixed Sphinx packet size of $2413$ bytes and given the header length
     of $384$ bytes, `delta` size is $2029$ bytes.

6. **Serialize the Sphinx Packet** using Protocol Buffers.

7. **Send the Serialized Packet** to the first mix node using the
   `"/mix/1.0.0"` protocol.

#### 5.2 Intermediary Mix Node

Let $`x_i \in \mathbb{Z}_q^*`$ be the intermediary node’s private key
corresponding to the public key $y_i \in G^*$. It performs the following steps
to relay a message:

1. **Receive and Deserialize** the Sphinx packet using Protocol Buffers.
2. **Compute Shared Secret $s = \alpha^{x_{i}}$**.

3. **Check If Previously Seen**

   a. Compute tag $H(s)$, where $H$ is the SHA-256 hash function.

   b. If tag is in the previously seen list of tags, discard the message.

   c. This list can be reset whenever the node rotates its private key

4. **Compute MAC**

   a. Derive MAC key

   $`\text{mac\_key} = KDF(\text{"mac\_key"}\ |\ s)`$

   b. Check if $`\gamma = \text{HMAC-SHA-256}(\text{mac\_key},\ β)`$ . If not,
   discard the message.

   c. Otherwise, store tag $H(s)$ in the list of seen message tags.

5. **Decrypt One Layer**

   a. Derive the AES key, MAC key, and IV:

   $`\text{β\_aes\_key} = KDF(\text{"aes\_key"}\ |\ s)`$

   $`\text{β\_iv} = H(\text{"iv"}\ |\ s)`$ (truncated to 128 bits)

   b. Compute
   $`B = \text{AES-CTR}(\text{β\_aes\_key},\ \text{β\_iv},\ \beta\ |\ 0_{(t+1)k})`$.

   c. Uniquely parse prefix of $B$

   If $B$ has a prefix of **$0_{((t+1)(r-L)+t+2)\kappa}$,** the current node is the
   exit node (refer exit node operations below).

   Otherwise, it is an intermediary node and it performs the followings steps
   to relay the message.

   d. **Extract Routing Information**

   $`\text{next\_hop} = B_{[0\ldots(t\kappa-17)]}`$ (first $t\kappa-2$ bytes).

   e. **Extract Delay**

   $`\text{delay} = B_{[(t\kappa-16)\ldots(t\kappa-1)]}`$ (following $2$ bytes).

   f. **Extract Gamma**

   $`{\gamma}' = B_{[t\kappa\ldots(t\kappa+\kappa-1)]}`$ (following $\kappa$ bytes).

   g. **Extract Beta**

   $`\beta' = B_{[(t\kappa+\kappa)\ldots(r(t+1)+t+2)\kappa-1]}`$ (following
   $((t+1)r + 1)\kappa$ bytes).

   h. **Compute Alpha**

   - Compute blinding factor $b = H(α\ |\ s)$, where $H$ is the SHA-256 hash
    function.
   - Compute $α^′ = α^b$.

   i. **Compute Delta**

   - Derive the AES key and IV:
     $`\text{δ\_aes\_key} = KDF(\text{"δ\_aes\_key"}\ |\ s)`$
     $`\text{δ\_iv} = H(\text{"δ\_iv"}\ |\ s)$` (truncated to 128 bits)
   - Compute $`\delta' = \text{AES-CTR}(\text{δ\_aes\_key},\ \text{δ\_iv},\ \delta)`$

6. **Construct Final Sphinx Packet**

   a. Initialize header

   ```pseudocode
    alpha = alpha' // 32 bytes
    beta = beta' // $((t+1)r + 1)\kappa$ bytes
    gamma = gamma' // 16 bytes
   ```

   b. Initialize payload

   `delta = delta' // variable size, max 2029 bytes`

7. **Serialize the Sphinx Packet** using Protocol Buffers.
8. **Introduce A Delay** of $`\text{delay}`$ milliseconds.
9. **Send the Serialized Packet** to $`\text{next\_hop}`$ using the
    `"/mix/1.0.0"` protocol.

#### 5.3 Exit Node

1. **Perform _Steps i. to v. b._ Above**, similar to an intermediary node. If
   $B$ has a prefix of $0_{((t+1)(r-L)+t+2)\kappa}$ (in _step 5. c._ above), the
   current node is the exit node. It performs the following steps to
   disseminate the message via the respective libp2p protocol.

2. **Compute Delta**

   - Derive the AES key and IV:

     $`\text{δ\_aes\_key} = KDF(\text{"δ\_aes\_key"}\ |\ s)`$

     $`\text{δ\_iv} = H(\text{"δ\_iv"}\ |\ s)`$ (truncated to 128 bits)

   - Compute $`\delta' = \text{AES-CTR}(\text{δ\_aes\_key},\ \text{δ\_iv},\ \delta)`$.

3. **Extract Message**

   $m = \delta'_{[\kappa\ldots]}$ (remove first $\kappa$ bytes).

4. **Remove Any Padding** from $m$ to obtain the `message` including any
   necessary spam protection data.

5. **Verify Spam Protection**

   Verify the spam protection mechanism applied to the `message`.
   If the verification fails, discard the `message`.
   Refer to [Appendix A](#appendix-a-example-spam-protection-using-proof-of-work)
   for details on the current implementation using PoW.

6. **Deserialize the extracted message** using the respective libp2p protocol's
   definition.

7. **Disseminate the message** via the respective libp2p protocol (_e.g.,_
   GossipSub).

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### Normative

[Handler function](https://docs.libp2p.io/concepts/fundamentals/protocols/#handler-functions)
[libp2p](https://libp2p.io)\
[Sphinx](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf)

### Informative

[PoW](https://bitcoin.org/bitcoin.pdf)\
[Sphinx packet size](https://petsymposium.org/popets/2024/popets-2024-0050.pdf)

## Appendix A. Example Spam Protection using Proof of Work

The current implementation uses a Proof of Work mechanism for spam protection.
This section details the specific steps for attaching and verifying the PoW.

### Structure

The sender appends the PoW to the serialized libp2p message, `libp2p_message`,
in a structured format, making it easy to parse and verify by the exit node.
The sender includes the PoW as follows:

 `message = <libp2p_message_bytes | timestamp | nonce>`

where:

 `<libp2p_message_bytes>`: Serialized libp2p message (variable length).

`<timestamp>`: The current Unix timestamp in seconds (4 bytes).

`<nonce>`: The nonce that satisfies the PoW difficulty criterion (4 bytes).

**Nonce Size:** The nonce size should be large enough to ensure a sufficiently large
search space. It should be chosen so that the range of possible nonce values
allows for the difficulty target to be met. However, larger nonce sizes can increase
the time and computational effort required to find a valid nonce. We use
a 4-byte nonce to ensure sufficiently large search space with reasonable
computational effort.

**Difficulty Level:** The difficulty level is usually expressed as the number of
leading zeros required in the hash output. It is chosen such that the
computational effort required is significant but not prohibitive.
We recommend a reasonable difficulty level that requires around
16-18 leading zeros in the SHA-256 hash. This would roughly take
0.65 to 2.62 seconds to compute in a low-grade CPU,
capable of computing 100,000 hashes per second.

### Calculate Proof of Work (PoW)

The sender performs the following steps to compute the PoW challenge and response:

i. **Create Challenge**

Retrieves the current Unix timestamp, `timestamp`, in seconds (4 bytes).

ii. **Find A Valid Nonce**

- Initializes the `nonce` to a 4-byte value (initially zero).
  
- Increments the `nonce` until the SHA-256 hash of
  `<libp2p_message_bytes | timestamp | nonce>` has at least
  18 leading zeros.

- The final value of the `nonce` is considered valid.

### Attach the PoW to the libp2p Message

  Append the 4-byte `timestamp` and the valid `nonce` to
  the `libp2p_message_bytes` to form the `message`.

  `message = <libp2p_message_bytes | timestamp | nonce>`

### Verify PoW
  
i. **Extract Timestamp and Nonce**

  Split `message` into 4-byte `nonce` (last 4 bytes), 4-byte `timestamp`
  (the 4 bytes before the nonce), and the serialized libp2p message
  to be published, `libp2p_message_bytes` (the remaining bytes).

ii. **Verify Timestamp**
  
- Check the `timestamp` is within the last 5 minutes.
  
- If the timestamp is outside the acceptable window, the exit node
  discards the message.

iii. **Verifiy Response**

- Compute the SHA-256 hash of the `message` and check if the hash
  meets the difficulty requirement, _i.e._, has at least 18 leading zeros.
  
- If the hash is not valid, the exit node discards the message. Otherwise,
  it follows the steps to publish the message.
