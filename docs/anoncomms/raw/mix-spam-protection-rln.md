# RLN DoS Protection for Mixnet

| Field | Value |
| --- | --- |
| Name         | RLN DoS Protection for Mixnet |
| Slug         | 144                           |
| Status       | raw                           |
| Category     | Standards Track               |
| Editor       | Prem Prathi <prem@status.im>  |
| Contributors |                               |

<!-- timeline:start -->

## Timeline

- **2026-05-11** — [`ae4c4a1`](https://github.com/logos-co/logos-lips/blob/ae4c4a11e4f7b0d09cbfd2333e22295d3df56582/docs/anoncomms/raw/mix-spam-protection-rln.md) — chore: split ift ts specs
- **2026-04-15** — [`5a3e844`](https://github.com/logos-co/logos-lips/blob/5a3e844679a0ac60e6b4e945a64c2f7d8650cba5/docs/ift-ts/raw/mix-spam-protection-rln.md) — Chore/move repo into logos co (#312)
- **2026-02-09** — [`afd94c8`](https://github.com/logos-co/logos-lips/blob/afd94c8bc1420376ae9af7e14a4feb246f2ed621/docs/ift-ts/raw/mix-spam-protection-rln.md) — chore: add math support (#287)
- **2026-01-29** — [`3cd2d09`](https://github.com/logos-co/logos-lips/blob/3cd2d090a4c8aa7a762dd9357d21cd73bb57cd15/docs/ift-ts/raw/mix-spam-protection-rln.md) — fix title of doc (#282)
- **2026-01-29** — [`0e53ebb`](https://github.com/logos-co/logos-lips/blob/0e53ebb1b0d090d1d2957a0164c85c38d81560f8/docs/ift-ts/raw/mix-spam-protection-rln.md) — change header to new format (#279)
- **2026-01-24** — [`ffca40a`](https://github.com/logos-co/logos-lips/blob/ffca40abfa6b42f239439550cd2fc47fc802f22a/docs/ift-ts/raw/mix-spam-protection-rln.md) — Mix spam and sybil protection protocol using RLN (#252)

<!-- timeline:end -->

## Abstract

This document defines a DoS and sybil protection protocol for [libp2p mix](mix.md) based mixnets.
The protocol specifies how [Rate Limiting Nullifiers (RLN)](https://vac.dev/rln) can be integrated into libp2p mix.
RLN allows mix nodes to detect and drop spam without identifying legitimate users,
addressing spam attacks.
RLN requires membership for mix nodes to send or forward messages,
addressing the sybil attack vector.
RLN satisfies the DoS protection [requirements](mix-dos-protection.md#3-requirements) defined for the Mix Protocol.

## Background / Rationale / Motivation

Mixnets provide strong privacy guarantees by routing messages through multiple mix nodes using layered encryption and per-hop delays to obscure both routing paths and timing correlations.
In order to have a production-ready mixnet using the [libp2p mix](mix.md),
two critical vulnerabilities must be addressed:

1. **DoS attacks**: An attacker can generate well-formed sphinx packets targeting mix nodes
   and exhaust their resources.
   In case of mixnets,
   it is easy to attack a later hop in the mix path by choosing different first hop nodes.
   An attacker with minimal resources can launch DoS attacks against individual mix nodes.
   By targeting all mix nodes in this manner,
   the attacker can render the entire mixnet unusable.
2. **Sybil attacks**: Adversaries operating multiple node identities can increase the probability of path compromise,
   enabling deanonymization through traffic correlation or timing analysis.

The [libp2p mix](mix.md) protocol provides an extension for integrating DoS protection mechanisms (see [Mix DoS Protection](mix-dos-protection.md)).
This specification proposes to use [Rate Limiting Nullifiers (RLN)](rln-v2.md) as the DoS and sybil protection mechanism.
This approach introduces some trade-offs such as additional per-hop latency for proof generation
which are discussed in the [Tradeoffs](#tradeoffs) section.

## Terminology

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and “OPTIONAL”
in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

Other terms used in this document are as defined in the [libp2p Mix Protocol](mix.md) and [Mix DoS Protection](mix-dos-protection.md).

### Message

Message is the actual sphinx packet including headers and encrypted payload that is either originated or forwarded by a mix node.

### Messaging Rate

The messaging rate is defined as the number of messages that can be sent/forwarded per fixed unit of time,
termed an `epoch`.
Since we're using this as shorthand for the maximum allowable rate,
this is also known as the _rate limit_.
The length of each epoch is constant and defined as the `period`.

We define an `epoch` as $\lceil$ `unix_time` / `period` $\rceil$.
For example,
if `unix_time` is `1644810116` and we set `period` to `30`,
then `epoch` is $\lceil$ `(unix_time/period)` $\rceil$ `= 54827004`.

> **NOTE:** The `epoch` refers to the epoch in RLN and not Unix epoch.
> This means that no more messages than the registered rate limit can be sent per epoch,
> where the epoch length (`period`) is up to the application.

See section [System Parameters](#system-parameters) for details on the `period` parameter.

## Approach

### Overview

The protocol implements RLN using a [per-hop generated proof approach](mix-dos-protection.md#42-per-hop-generated-proofs),
where each node in the mix path generates and verifies proofs.
This enables network-wide spam protection while preserving user privacy.

Each mix node MUST have an RLN group membership in order to send or forward messages in the mixnet.
Each mix node in the path (except the initiating node) verifies the incoming RLN proof before processing the message.
After verification,
each node generates and attaches a new RLN proof before forwarding the message to the next hop.

To effectively detect spam,
mix nodes SHOULD identify when a node exceeds its [messaging rate](#messaging-rate) by reusing the same nullifier across multiple messages within an epoch (known as "double signalling").
Since a message does not traverse all the mix nodes in the network,
a spammer could exploit different paths to avoid detection by any single mix node.
To address this,
intermediary and exit nodes SHOULD participate in a [coordination layer](#coordination-layer)
that indicates already seen [messaging metadata](#messaging-metadata) across the mix nodes.
This enables all participating mix nodes to detect double signalling across different paths, derive the spammer's private key, and initiate slashing.

### Rationale

RLN is well-suited for spam and sybil protection in libp2p mix based mixnets due to the following properties:

- Sybil Resistance:
  - Requiring membership for each mix node creates friction to participate in the mixnet to send or forward messages
  - Operating multiple identities becomes costly,
    mitigating sybil attacks that could compromise mix path selection

- Privacy-Preserving Spam Protection:
  - Uses zero-knowledge proofs to enforce rate limits without revealing sender identities
  - Ties spam protection proof to the message content,
    making proofs non-reusable across messages
  - Enables economic deterrence through slashing without compromising anonymity

- Network-Level Benefits:
  - RLN enables setting a deterministic [messaging rate](#messaging-rate) for the mixnet,
    which translates to predictable bandwidth requirements (messages per epoch × sphinx packet size).
  - This makes it easier to provision and estimate resource usage for nodes participating in the mixnet.
  - The rate limit creates a baseline traffic level
    that, when combined with cover traffic, helps maintain k-anonymity even during periods of low organic traffic.

### Setup

Each mix node has an RLN key pair consisting of a secret key `sk` and public key `pk` as defined in [RLN](../draft/32/rln-v1.md).
The secret key `sk` MUST be persisted securely by the mix node.

A mixnet that is DoS-protected requires all mix nodes in it to form an [RLN group](../draft/32/rln-v1.md#flow).

- Mix nodes MUST be registered to the RLN group to be able to send or forward messages.
- Registration MAY be moderated through a smart contract deployed on a blockchain.

Note: The criteria for membership is out of scope of the spec and should be implementation-specific (e.g requiring stake)

The group membership data MUST be synchronized initially so that the mix node has the latest Merkle root in order to generate or verify RLN proofs.
See [Group Synchronization](#group-synchronization) for details on maintaining synchronization.

Intermediary and exit mix nodes SHOULD subscribe to the coordination layer (defined [below](#coordination-layer)) in order to detect rate limit violations collaboratively.
This ensures that mix nodes can detect spam and trigger slashing.

### Sending and forwarding messages

In order to send/forward messages via mixnet,
a mix node MUST include the encrypted [RateLimitProof](#ratelimitproof) in the sphinx packet as $\sigma$ (see [Mix DoS Protection spec](mix-dos-protection.md#42-per-hop-generated-proofs)).

#### Proof Generation

When generating an RLN proof,
the node MUST:

1. Use its secret key `sk` and the current `epoch`
2. Obtain the current Merkle root and [`path_elements`](../draft/32/rln-v1.md#obtaining-merkle-proof) from the synchronized membership tree
3. Generate a keccak256 hash of all components of the **outgoing** sphinx packet [(α', β', γ', δ')](mix.md#81-packet-structure-overview)
   and set it as the proof signal.
   This prevents proof reuse across different messages.

#### Proof Encryption

After generating the proof,
the node MUST encrypt it to the next hop in the mix path.

The X25519 group, KDF, and AES-CTR construction are as defined in the [Mix Protocol cryptographic primitives](mix.md#82-cryptographic-primitives).

Let $y$ denote the next hop's X25519 public key.
The node MUST:

1. Choose a random private exponent $e \in_R \mathbb{Z}_q^*$.
2. Compute:

   $`
   \begin{aligned}
   A &= g^e \\
   z &= y^e
   \end{aligned}
   `$

3. Derive the AES key and IV:

   $`
   \begin{array}{l}
   \mathrm{proof\_aes\_key} = \mathrm{KDF}(\text{"proof\_aes\_key"} \mid z)\\
   \mathrm{proof\_iv} = \mathrm{KDF}(\text{"proof\_iv"} \mid z)
   \end{array}
   `$

4. Encrypt the serialized `RateLimitProof`:

   $`
   c = \mathrm{AES\text{-}CTR}(\mathrm{proof\_aes\_key},\ \mathrm{proof\_iv},\ \mathrm{RateLimitProof})
   `$

5. Encode $A$ and $c$ as $\sigma$ as specified in [Encrypted Proof Wire Format](#encrypted-proof-wire-format).

A fresh $e$ MUST be chosen for every message.

**Initiating node**:

- generate an RLN proof for the initial sphinx packet
- encrypt the proof to the first hop and attach the resulting $\sigma$ to the packet before sending

**Intermediary and Exit nodes**:

MUST do the following for every incoming mix packet:

- decrypt and verify the incoming packet's RLN proof (see [Message validation](#message-validation))
- process the sphinx packet according to the mix protocol
- generate a NEW RLN proof for the outgoing packet
- encrypt the new proof to the next hop and attach the resulting $\sigma$ to the packet before forwarding

### Group Synchronization

Proof generation relies on the knowledge of Merkle tree root `merkle_root` and `path_elements` (the authentication path in the Merkle proof as defined in [RLN](../draft/32/rln-v1.md#obtaining-merkle-proof))
which both require access to the membership Merkle tree.
Proof verification also requires knowledge of the `merkle_root` to validate that the proof was generated against a valid membership tree state.
The RLN membership group MUST be synchronized across all mix nodes to ensure the latest Merkle root is used for RLN proof generation and verification.
Stale roots may cause legitimate proofs to be rejected.
Using an old root can allow inference about the index of the user's `pk` in the membership tree
hence compromising user privacy and breaking message unlinkability.

In order to accommodate network delays,
nodes MUST maintain a window of recent valid roots (see `acceptable_root_window_size` in [System Parameters](#system-parameters)).
We recommend `5` for `acceptable_root_window_size`.

### Coordination Layer

The coordination layer enables network-wide spam detection by preventing rate limit violations through nullifier reuse detection.
The coordination layer SHOULD be used to broadcast [messaging metadata](#messaging-metadata).
When a node detects spam,
it can reconstruct the spammer's secret key using the shared key shares and initiate [slashing](#spam-detection-and-slashing).

Mix nodes that participate in the coordination layer MUST both subscribe to receive metadata and broadcast metadata from messages they process.
Nodes acting only as initiating nodes need not participate in this coordination layer
as they only originate messages and do not forward or validate messages from others.

The coordination layer MUST have its own spam and sybil protection mechanism in order to prevent from these attacks.
We recommend using [WAKU-RLN-RELAY](../../messaging/draft/17/rln-relay.md)
In this case,
the Messaging Metadata MUST be encoded as the Waku Message payload.
We recommend using the [public Waku Network](../../messaging/draft/64/network.md) with a content topic agreed by all mix nodes.

### Processing received messages

In order to process messages received via mixnet,
a mix node MUST decrypt the [RateLimitProof](#ratelimitproof), $\sigma$, attached to the sphinx packet
and validate it (see [Mix DoS Protection spec](mix-dos-protection.md#42-per-hop-generated-proofs)).

#### Proof Decryption

Upon receiving a sphinx packet with attached $\sigma$ containing $(A, c)$,
a mix node MUST decrypt $\sigma$ before validating the proof.

Let $x$ denote the receiving node's X25519 private key.
The node MUST:

1. Compute the shared secret $z = A^x$.
2. Derive the AES key and IV:

   $`
   \begin{array}{l}
   \mathrm{proof\_aes\_key} = \mathrm{KDF}(\text{"proof\_aes\_key"} \mid z)\\
   \mathrm{proof\_iv} = \mathrm{KDF}(\text{"proof\_iv"} \mid z)
   \end{array}
   `$

3. Decrypt $c$ using AES-CTR with $\mathrm{proof\_aes\_key}$ and $\mathrm{proof\_iv}$ to recover the serialized `RateLimitProof`.

#### Message validation

A mix node MUST validate the recovered `RateLimitProof` using the below checks,
discarding the proof and stopping further checks or processing on failure.

1. If the `epoch` in the decrypted proof differs from the mix node's current `epoch` by more than `max_epoch_gap`.
2. If the `merkle_root` is NOT in the `acceptable_root_window_size` past roots of the mix node.
3. If the zero-knowledge proof `proof` is valid.
   It does so by running the zk verification algorithm as explained in [RLN](../draft/32/rln-v1.md#verification-and-slashing).

If all checks pass,
the node proceeds to [spam detection and slashing](#spam-detection-and-slashing) before processing the message.

#### Spam detection and Slashing

To enable local spam detection and slashing,
mix nodes MUST store the [messaging metadata](#messaging-metadata) in a local cache.
This includes metadata from:

- messages processed locally by the mix layer
- messages received via the coordination layer

The cache SHOULD be cleared for epoch data older than `max_epoch_gap`.
To identify spam messages,
the node checks whether a message with an identical `nullifier` is present in the epoch's cache.

1. If no entry exists for this `nullifier`,
   the node stores the [messaging metadata](#messaging-metadata) in the cache and proceeds to process the message normally.
2. If an entry exists and its `share_x` and `share_y` components are different from the incoming message,
   then proceed with slashing.
   The mix node uses the `share_x` and `share_y` of the new message and the shares from the local cache to reconstruct the `sk` of the message owner.
   The `sk` then MUST be used to delete the spammer from the group and withdraw its staked funds.
   The node MUST discard the message and MUST NOT forward it.
3. If the `share_x` and `share_y` fields in the local cache are identical to the incoming message,
   then the message is a duplicate and MUST be discarded.

After successfully validating a message,
intermediary and exit nodes SHOULD broadcast the [message's metadata](#messaging-metadata) using the coordination layer to enable network-wide spam detection.
The broadcast on the coordination layer MAY be batched atleast once per epoch to reduce constant traffic on coordination layer.

## Wire Format Specification / Syntax

### Encrypted Proof Wire Format

$\sigma$ MUST be attached to the sphinx packet as explained in [sending and forwarding messages](#sending-and-forwarding-messages).
$\sigma$ is the byte concatenation $A \| c$, where:

- $A$ is the 32-byte ephemeral group element
- $c$ is the AES-CTR ciphertext of the serialized `RateLimitProof`

Both $A$ and $c$ are generated as described in [Proof Encryption](#proof-encryption).
The size of $\sigma$ MUST be fixed (see [Mix DoS Protection §4.2.4](mix-dos-protection.md#424-impact-on-packet-size)).

#### RateLimitProof

Once $c$ is decrypted (see [Proof Decryption](#proof-decryption)),
the result is the serialized `RateLimitProof` protobuf:

```protobuf
syntax = "proto3";

message RateLimitProof {
   bytes proof = 1;
   bytes merkle_root = 2;
   bytes epoch = 3;
   bytes share_x = 4;
   bytes share_y = 5;
   bytes nullifier = 6;
}
```

The following table describes the fields of `RateLimitProof`.

|               Parameter | Type                                     | Description                                                                                                                                                                                                                                                          |
| ----------------------: | ---------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
|                 `proof` | array of 128 bytes compressed            | the zkSNARK proof as explained in the [Sending process](#sending-and-forwarding-messages)                                                                                                                                                                            |
|           `merkle_root` | array of 32 bytes in little-endian order | the root of membership group Merkle tree at the time of sending the message                                                                                                                                                                                          |
|                 `epoch` | array of 32 bytes                        | the current epoch at time of sending the message                                                                                                                                                                                                                     |
| `share_x` and `share_y` | array of 32 bytes each                   | Shamir secret shares of the user's secret identity key `sk` . `share_x` is the hash of the message. `share_y` is calculated using [Shamir secret sharing scheme](../draft/32/rln-v1.md)                                                                              |
|             `nullifier` | array of 32 bytes                        | internal nullifier derived from `epoch` and node's `sk` as explained in [RLN construct](../draft/32/rln-v1.md)                                                                                                                                                       |

### Messaging Metadata

[Messaging metadata](../draft/32/rln-v1.md#notes-from-implementation) is metadata
which is broadcasted via coordination layer and cached by mix nodes locally.
This helps identify duplicate signalling in order to detect spam.

```protobuf
syntax = "proto3";

message ExternalNullifier {
   bytes internal_nullifier = 1;
   repeated bytes x_shares = 2;
   repeated bytes y_shares = 3;
}

message MessagingMetadata {
   repeated ExternalNullifier nullifiers = 1;
}
```

### System Parameters

The system parameters are summarized in the following table.

|                     Parameter | Description                                                                        |
| ----------------------------: | ---------------------------------------------------------------------------------- |
|                      `period` | the length of `epoch` in seconds                                                   |
|                 `staked_fund` | the amount of funds to be staked by mix nodes at the registration                  |
|               `max_epoch_gap` | the maximum allowed gap between the `epoch` of a mix node and the incoming message |
| `acceptable_root_window_size` | the maximum number of past Merkle roots to store                                   |

## Security/Privacy Considerations

### Known Attack Vectors and Mitigations

#### Sybil Attacks

- **Attack**: Adversary operates multiple node identities to increase path compromise probability
- **Limitation**: Well-funded adversary can still acquire multiple memberships
- **Mitigation**: Membership registration can consider other criteria along with stake to reduce chance of sybil identities.

#### Coordination Layer Attacks

- **Attack**: Flood coordination layer with spam metadata to create DoS
- **Mitigation**: Coordination layer MUST implement its own spam protection (see [Coordination Layer](#coordination-layer))

#### Timing Attacks

- **Attack**: Correlate message timing across hops to deanonymize users
- **Mitigation**: Mix protocol's per-hop delays provide timing obfuscation
- **Note**: RLN metadata broadcast may create additional timing side-channels requiring analysis

### Privacy Considerations

#### Nullifier Linkability

- **Concern**: Nullifiers are broadcast via coordination layer, potentially enabling traffic analysis
- **Analysis**: Nullifiers are derived from epoch and secret key, changing per epoch
- **Limitation**: Within an epoch, multiple messages from same node share nullifier metadata structure

#### Wire-Level Privacy

Encrypting the `RateLimitProof` to the next hop prevents on-wire exposure of the proof fields.
In particular, the `epoch` field is invariant across hops and would otherwise enable cross-hop correlation by passive observers.

### Out of Scope

The following are explicitly out of scope for this specification and left to implementations:

- Specific membership criteria and stake amounts
- Coordination layer protocol selection and configuration
- Blockchain selection for RLN group management

## Tradeoffs

### Additional Latency due to proof generation in every hop

Per-hop RLN proof generation introduces additional latency at each mix node in the path:

- **Proof generation time**: Typically `100-500ms` per hop depending on hardware capabilities
- **End-to-end impact**: For a `3-hop` path, this adds `300-1500ms` to total message delivery time
- **Comparison**: This is significant compared to the mix protocol's per-hop delay
- **Mitigation**: See [Future Work](#future-work) for potential optimizations using pre-computed proofs

This latency needs to be considered while deciding the approach to be used.

### Membership registration friction

Requiring RLN group membership for all mix nodes creates barriers to network participation:

- **Stake requirement**: Nodes MUST stake funds to join, limiting casual participation
- **Registration overhead**: On-chain registration adds complexity and potential costs (gas fees)
- **Benefit**: This friction is intentional and necessary for sybil resistance

The appropriate stake amount MUST balance accessibility against attack economics (see [System Parameters](#system-parameters)).

### Cost of ZK Proof Generation

Zero-knowledge proof generation imposes computational costs on mix nodes.
Proof generation is CPU-intensive,
requiring modern processors.
May be prohibitive for mobile or embedded devices.

**Mitigation**: See [Future Work](#future-work) for potential research into using alternative proving systems.

These costs must be factored into operational expenses and node requirements.

## Future Work

In order to reduce latency introduced at each hop:

- RLN can be used with pre-computed proofs as explained [here](https://forum.vac.dev/t/rln-with-pre-computed-proofs/606).
  This approach can be explored further and could potentially replace the current proposed RLN implementation.
- Research other proving systems that would generate faster ZK proofs.

Additional sybil resistance mechanisms could augment RLN by incorporating reputation-based lists similar to Tor's "directory authorities".

These help clients build circuits that are less likely to be entirely controlled by sybils through a range of techniques
that limit nodes' possible influence based on trustworthiness metrics.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [libp2p mix protocol](mix.md)
- [Mix DoS Protection](mix-dos-protection.md)
- [Rate Limiting Nullifiers (RLN)](https://vac.dev/rln)
- [Rate Limiting Nullifiers v2](rln-v2.md)
- [RLN v1](../draft/32/rln-v1.md)
- [Waku-Relay](https://rfc.vac.dev/spec/11/)
- [RLN with precomputed proofs](https://forum.vac.dev/t/rln-with-pre-computed-proofs/606)
- [Poseidon hash implementation](https://eprint.iacr.org/2019/458.pdf)
