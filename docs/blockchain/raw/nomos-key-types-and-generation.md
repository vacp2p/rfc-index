# NOMOS-KEY-TYPES-AND-GENERATION

| Field | Value |
| --- | --- |
| Name | Nomos Key Types and Generation |
| Slug | 84 |
| Status | raw |
| Category | Standards Track |
| Editor | Mehmet Gonen <mehmet@logos.co> |
| Contributors | Marcin Pawlowski <marcin@logos.co>, Youngjoon Lee <youngjoon@logos.co>, Alexander Mozeika <alexander@logos.co>, Thomas Lavaur <thomaslavaur@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/nomos-key-types-and-generation.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/nomos-key-types-and-generation.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

# Introduction

This document defines the key types used in the Blend protocol and describes the process of generating them.

# Overview

This document ensures that the keys are used and generated in a common manner, which is necessary for making the Blend protocol work. The keys include:

- Non-ephemeral Quota Key (NQK)  used for proving that a node is a core node.
- Non-ephemeral Signing Key (NSK)  used to authenticate the node on the network level and derive the Non-ephemeral Encryption Key.
- Ephemeral Signing Key (ESK)  used for signing Blend messages, one per encapsulation.
- Non-ephemeral Encryption Key (NEK)  used for deriving shared secrets for message encryption.
- Ephemeral Encryption Key (EEK)  used for encrypting Blend messages, one per encapsulation.

# Construction

## Non-ephemeral Quota Key

A node generates a Non-ephemeral Quota Key (NQK) that is a ZkSignature ([[1.3.0] Mantle - Zero Knowledge Signature Scheme (ZkSignature)](https://nomos-tech.notion.site/Zero-Knowledge-Signature-Scheme-ZkSignature-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df818ba163f9e05495d321)). The NQK is stored on the ledger as the zk_id field in the DeclarationInfo of the nodes outcome of the participation in the Service Declaration Protocol (SDP  [[1.0.0] Service Declaration Protocol](https://nomos-tech.notion.site/1-0-0-Service-Declaration-Protocol-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24)).

The NQK is used to prove that the node is part of the set of core nodes as indicated through the SDP.

## Non-ephemeral Signing Key

A node generates a Non-ephemeral Signing Key (NSK) that is a Ed25519 key. The NSK is stored on the ledger as the provider_id field in the DeclarationInfo of the nodes outcome of the participation in the Service Declaration Protocol (SDP  [[1.0.0] Service Declaration Protocol](https://nomos-tech.notion.site/1-0-0-Service-Declaration-Protocol-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24)).

The NSK is used to authenticate the node on the network level and to derive Non-ephemeral Encryption Key.

## Ephemeral Signing Key

A node generates Ephemeral Signing Keys (ESK) that are proved to be limited in number by the Proof of Quota (PoQ  [[1.0.1] Proof of Quota](https://nomos-tech.notion.site/1-0-1-Proof-of-Quota-2e9261aa09df8038b95fc94b808ee32f?pvs=24)). The PoQ for core nodes requires a valid NQK for the session for which the PoQ is generated.

A unique signing key must be generated for every encapsulation as required by the [[1.0.0] Message Encapsulation Mechanism](https://nomos-tech.notion.site/1-0-0-Message-Encapsulation-Mechanism-215261aa09df81309d7fd7f1c2da086b?pvs=24).

The key must not be reused. Otherwise, the messages that reuse the same key can be linked together. The node is responsible for not reusing the key.

## Non-ephemeral Encryption Key

A node generates a Non-ephemeral Encryption Key (NEK). It is an X25519 curve key derived from the NSK (Ed25519) public key retrieved from the provider_id, which is stored on the ledger when the node executes the SDP protocol.

The NEK key is used for deriving a shared secret (alongside EEK defined below) for the Blend message encapsulation purposes.

## Ephemeral Encryption Key

A node derives an Ephemeral Encryption Key (EEK) pair using the X25519 curve from the ESK.

A unique encryption key must be generated for every encapsulation as required by the [[1.0.0] Message Encapsulation Mechanism](https://nomos-tech.notion.site/1-0-0-Message-Encapsulation-Mechanism-215261aa09df81309d7fd7f1c2da086b?pvs=24).

The derivation of a shared secret for the encryption of an encapsulated message requires using the EEK of the sender and the derived X25519 key from the NEK of the recipient.

The key must not be reused. Otherwise, the messages that reuse the same key can be linked together. The node is responsible for not reusing the key.

