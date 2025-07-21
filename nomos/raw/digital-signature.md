---
title: NOMOS-DIGITAL-SIGNATURE
name: Nomos Digital Signature
status: raw
editor: 
contributors:
- Jimmy Debe <jimmy@status.im>
- 
---

## Abstract

This specification describes the digital signature element used in different components of the Nomos system design.
Thoughout the system, Nomos components share the same signature scheme.

## Background

The Nomos protocol has Bedrock which is the a few key components that Nomos Network is built on,
see the 
[Nomos whitepaper](https://nomos-tech.notion.site/The-Nomos-Whitepaper-1fd261aa09df81318690c6f398064efb?pvs=97#1fd261aa09df817bac4ad46fdb8d94ab)
for more information. 
The Bedrock Mantle component serves as the operating system of Nomos.
This includes facilitating operations like writing data to the blockchain or
a restricted ledger of notes to support payments and staking.
Also defines Nomos zone updates and coordination between Nomos zone executors.
It is like a system call interface designed to provide a minimal and 
a execution layer that connects Nomos services to provide the necessary functionality for sovereign rollups and zones,
see [Common Ledger specification](https://nomos-tech.notion.site/Common-Ledger-Specification-1fd261aa09df81088b76f39cbbe7c648) for more on Nomos zones.

In order for this layer to remain lightweight, it focuses on data availability and
verification rather than execution.
Native zones on the other hand will be able to define their state transition function (STF) and
prove to the Bedrock layer their correct execution.
The Bedrock components share the same digital signature mechanism to ensure security and privacy.***
This document will describe the validation tools that can be used with Bedrock services in the Nomos network.

## Wire Format

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

The signature schemes used by the provers and verifiers participating in the of the Nomos systems include:

- ZKSignature
- EdDSA Digital Signature Algorithm

### EdDSA

EdDSA is a signature scheme based on elliptic-curve cryptography,
defined over twisted [Edwards curves](https://eprint.iacr.org/2008/013.pdf).
Nomos uses the Ed25519 instances uses Curve25519, 
providing 128-bit security for general purpose signing.
EdDSA SHOUD NOT be used for ZK circuits use.

The prover computes the EdDSA signature, twisted Edwards curve Curve25519:

> $-x^2 + y^2 = 1 - (121665/121666)x^2y^2 \mod{(2^{255} - 19)}$

- The public key size MUST be 32 bytes
- The signature size MUST be 64 bytes.

The verifier runs the verification algorithm:


### ZKSignature

The ZkSignature scheme enables a prover to demonstrate cryptographic knowledge of a secret key corresponding to a publicly available key,
without revealing the secret key itself.


