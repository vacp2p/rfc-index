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

This specification describes the digital signature element,
which is used for different components in the Nomos system design.
Thoughout the system, each Nomos layer share the same signature scheme.

## Background

The Nomos Bedrock consist of a few key components that Nomos Network is built on,
see the
[Nomos whitepaper](https://nomos-tech.notion.site/The-Nomos-Whitepaper-1fd261aa09df81318690c6f398064efb?pvs=97#1fd261aa09df817bac4ad46fdb8d94ab)
for more information.
The Bedrock Mantle component serves as the operating system of Nomos.
This includes facilitating operations like writing data to the blockchain or
a restricted ledger of notes to support payments and staking.
This component also defines how Nomos zones update their state and
 the coordination between the Nomos zone executor nodes.
It is like a system call interface designed to provide a minimal set of operations
to interact with lower-level Bedrock services.
It is an execution layer that connects Nomos services
to provide the necessary functionality for sovereign rollups and zones,
see [Common Ledger specification](https://nomos-tech.notion.site/Common-Ledger-Specification-1fd261aa09df81088b76f39cbbe7c648) for more on Nomos zones.

In order for the Bedrock layer to remain lightweight, it focuses on data availability
and verification rather than execution.
Native zones on the other hand will be able to define their state transition function
and prove to the Bedrock layer their correct execution.
The Bedrock layer components share the same digital signature mechanism to ensure security and privacy.
This document will describe the validation tools that are used with Bedrock services in the Nomos network.

## Wire Format

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC2119](https://www.ietf.org/rfc/rfc2119.txt).

The signature schemes used by the provers and
verifiers include:

- ZKSignature
- EdDSA Digital Signature Algorithm

### EdDSA

EdDSA is a signature scheme based on elliptic-curve cryptography,
defined over twisted [Edwards curves](https://eprint.iacr.org/2008/013.pdf).
Nomos uses the Ed25519 instances uses Curve25519,
providing 128-bit security for general purpose signing.
EdDSA SHOULD NOT be used for ZK circuit contruction.

The prover computes the following EdDSA signature, twisted Edwards curve Curve25519:

$$ -x^2 + y^2 = 1 - (121665/121666)x^2y^2 \mod{(2^{255} - 19)} $$

- The public key size MUST be 32 bytes
- The signature size MUST be 64 bytes.
- The public key MUST NOT already exist

### ZKSignature

The ZkSignature scheme enables a prover to demonstrate cryptographic knowledge of a secret key,
corresponding to a publicly available key,
without revealing the secret key itself.
The following is the structure for a proof attesting public key:

```python

  class ZkSignaturePublic:
    public_keys: list[ZkPublicKey] # The public keys signing the message
    msg: hash # The hash of the message

```

The prover knows a witness:

```python

  class ZkSignatureWitness:
 # The list of secret keys used to signed the message
    secret_keys: list[ZkSecretKey]

```

Such that the following constraints hold:

The number of secret keys is equal to the number of public keys:

```python

  assert len(secret_keys) == len(public_keys)
    
```

Each public key is derived from the corresponding secret key.

```python

    assert all(
      notes[i].public_key == hash("NOMOS_KDF", secret_keys[i])
      for i in range(len(public_keys)
    )

```

- The proof MUST be embedded in the hashed `msg`.

The ZkSignature circuit MUST take a maximum of 32 public keys as inputs.
To prove ownership when lower than 32 keys,
the remaining inputs MUST be padded with the public key corresponding
to the secret key `0`.
These padding are ignored during execution.
The outputs of the circuit have no size limit,
as they MUST be included in the hashed `msg`.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [Nomos whitepaper](https://nomos-tech.notion.site/The-Nomos-Whitepaper-1fd261aa09df81318690c6f398064efb?pvs=97#1fd261aa09df817bac4ad46fdb8d94ab)
- [Common Ledger specification](https://nomos-tech.notion.site/Common-Ledger-Specification-1fd261aa09df81088b76f39cbbe7c648)
- [Edwards curves](https://eprint.iacr.org/2008/013.pdf)
