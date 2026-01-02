---
title: MULTI-MESSAGE_ID-BURN RLN
name: Multi-message_id burn feature RLN
status: raw
category: Standards Track
tags: 
editor: Ugur Sen [ugur@status.im](mailto:ugur@status.im)
contributors: 
---
## Abstract

This document specifies multi-message_id burn RLN which the users
can use their multiple message rights at once unlike previous versions of RLN
that require a separate execution per `message_id`.

## Motivation

RLN is a decentralized rate-limiting mechanism designed for anonymous networks.
In RLVv2, the latest version of the protocol, users can apply arbitrary rate limits
by defining a specific limit over the `message_id`.
However, this version does not support the simultaneous exercise
of multiple messaging rights under a single `message_id`.
In other words, if a user needs to consume multiple `message_id` units,
they must compute separate proofs for each one.

This lack of flexibility creates an imbalance: users sending signals
of significantly different sizes still consume only one `message_id` per proof.
While computing multiple proofs is a trivial workaround,
it is neither computationally efficient nor manageable for high-throughput applications.

Multiple burning refers to the mechanism where a fixed number of `message_id` units are processed
within the circuit to generate multiple corresponding nullifiers inside a single cryptographic proof.
This multiple burning feature may unlock the usage of RLN for big signals
such as large messages or complex transactions, by validating their resource consumption in a single proof.

This document specifies the mechanism that allows users to burn multiple `message_id` units
at once by slightly modifying the existing [RLNv2](./rln-v2.md) circuit.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Recap of RLNv2

Since the multi-message_id RLN is achieved by modifying the existing RLNv2 protocol,
better to recap the RLNv2.
Note that this modification only affects the signalling section.
The rest of sections, registration, verifying and slashing stay the same with RLNv2.

### RLNv2 Registration

RLN-Diff introduces per-user rate limits. Therefore, **id_commitment** must depend on
`user_message_limit`, where
0 ≤ `user_message_limit` ≤ `message_limit`.

The user submits the same `identity_secret_hash` as in
[32/RLN-V1](../32/rln-v1.md), i.e.
`poseidonHash(identity_secret)`, together with `user_message_limit` to a server or
smart contract.

The verifier computes
`rate_commitment = poseidonHash(identity_secret_hash, user_message_limit)`,
which is inserted as a leaf in the membership Merkle tree.

### RLNv2 Signalling

For proof generation, the user need to submit the following fields to the circuit:

```js
{
    identity_secret: identity_secret_hash,
    path_elements: Merkle_proof.path_elements,
    identity_path_index: Merkle_proof.indices,
    x: signal_hash,
    message_id: message_id,
    external_nullifier: external_nullifier,
    user_message_limit: message_limit
}
```

Calculating output

The output `[y, internal_nullifier]` is calculated in the following way:

```js

a_0 = identity_secret_hash;
a_1 = poseidonHash([a0, external_nullifier]);

y = a_0 + x * a_1;

internal_nullifier = poseidonHash([a_1]);

```

### RLNv2 Verification/slashing

Verification and slashing in both subprotocols remain the same as in [32/RLN-V1](../32/rln-v1.md).
The only difference that may arise is the `message_limit` check in RLN-Same,
since it is now a public input of the Circuit.

## Multi-message_id Burn RLN (Multi-burn RLN)

The multi-burn overview is similar witht the previous versions.
Therefore, it consists of registration, signaling and verification/slashing sections.

As we mentioned before the, registration and erification/slashing, so in this section,
it is enough to specify the signalling section.

### Multi-burn RLN Signalling

The multi-burn RLN signalling section consists of the proving of the circuit as follows:

Circuit parameters

Public Inputs

* `x`
* `external_nullifier`
* `i`

Private Inputs

* `identity_secret_hash`
* `path_elements`
* `identity_path_index`
* `message_id []`
* `user_message_limit`

Outputs

* `y`
* `root`
* `internal_nullifier []`

```js
{
    identity_secret_hash: bigint, 
    external_nullifier: bigint,
    x: bigint
}

```

The output `[root, y [], internal_nullifier []]` is calculated in the following way:

```js

a_0 = identity_secret_hash;
a_1i = poseidonHash([a0, external_nullifier, message_id [i]]);

y_i = a_0 + x * a_1i;

internal_nullifier = poseidonHash([a_1]);

```

where 0 ≤ `i` ≤ `max_out`,  `max_out` is a new parameter that is fixed for a application.
`max_out` is arranged the requirements of the application.
To define this fixed number makes the circuit is flexiable with a single circuit that is maintable.
Since the user is free to burn arbitrary number of `message_id` at once up to `max_out`.
