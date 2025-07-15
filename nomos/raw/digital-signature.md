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

Nomos uses Mantle a foundational element of the Bedrock, 
designed to provide a minimal and 
efficient execution layer that connects together Nomos Services in order to provide the necessary functionality for Sovereign Rollups and Zones.

we will call Zones, will focus and specialize on different services and functions and attract the relevant user base. The Bedrock Mantle layer's main purpose is to provide the tools to build and manage these zones and coordinate communications. 

In order for this layer to remain lightweight, it focuses on data availability and verification rather than execution.
Native Zones on the other hand will be able to define their state transition function (STF) and prove to the Bedrock layer their correct execution.

It can be viewed as the system call interface of Bedrock, exposing a safe and constrained set of operations to interact with lower-level Bedrock services, similar to syscalls in an operating system.
The Mantle Transactions provide operations for interacting with Nomos Services.

This document will describe the validation tool that can be used with Bedrock services in the Nomos network.

## Wire Format

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

The signature schemes used by the provers and verifiers with the Nomos systems include:

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


