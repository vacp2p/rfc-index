---
title: CODEX-VALIDATOR
name: Codex Validator
status: raw
editor: 
contributors: 

---

## Abstract

This specification describes the Codex validation process for a Codex marketplace storage request. 
The process is a remote auditing scheme to check that a piece of data is being stored on a storage node
## Background

Codex network has a few node roles that user can decide to run.
The validator role allows user to have some guarantee that there data is retrievable.
Codex storage contracts are create when a storage request is made by a user.
The node roles that participant in the storage contract will be the Codex client node and the Codex storage provider, 
see [other rfc for more info](#).
Once an agreement is created between both node roles,
the client node will be aware that there data is being persisted and
storage nodes are aware that they are receiving periodic rewards from the new contract.

A storage provider may be an malicious actor by joining a contract in the beginning,
then stop storing the data shortly after for any malicious reason.
To avoid such a scenario, the Codex Marketplace allows for validator nodes to check data being stored.
Once a contract is opened,
storage nodes need to prove that they are still storing the data in the request.
This will give storage requesters assurances that the data is being persisted throughout the lifecycle of the storage contract. need to give assurances to requesters.
Malicious storage providers also need an disincentive to not store data and break the storage contract.

## Wire Format

Before a validator node can validate a proof of storage for a slot,
a storage request MUST be complete.

### Flow

- Validators choose a random slot to download from a storage provider
- If the validator must create a proof of the data to match the proof already in the slot
    - If the proof does not match, the slot is empty and validator marks it as `proofMissing`
    - If the data cannot be downloaded,
    the storage provider may be disconnected, the validator MAY mark slot as `proofMissing`
    - If the data downloaded matchs the proof, the validator MAY makr slot as `correctProof`
The validator must make a blockchain transaction to state the current status of a slot.
- When a slot is missing and the validator marks it as `proofMissing`,
the slot MUST enter into repair, see [slot repair](CODEX-MARKETPLACE).
    - The validator will recieve a reward for marking a `proofMissing`
A validator can continue this process for any duration.

### Validator Creating Proofs


### Validator Repair

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [CODEX-MARKETPLACE](#)


