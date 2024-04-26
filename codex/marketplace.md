---
slug: 
title: CODEX-MARKETPLACE
name: Codex Storage Marketplace
status: raw
tags: codex
editor: 
contributors:
  
---

## Abstract

This specification describes a method for Codex hosts and client nodes to participate in a storage marketplace. The goal is to create a storage marketplace that promotes durability.

## Motivation
Codex aims to create a peer-to-peer storage engine with strong data availability, data persistence guarantees and node storage incentivies.
To reach this goal, a data availibilty and retrievaial mechanism is needed.
Support for light clients, like mobile devices should also be embraced.
The protocol should remove complexity to allow for simple implementation and 
simplify incentive mechanism.

## Semantics 

### Definitions

| Terminology  | Description |
| --------------- | --------- |
| Storage Nodes | A Codex node that provide storage services to the marketplace.|
| Validator Nodes | A Codex node that collects, validates, and submits proofs to reward or penilize other storage nodes or validator nodes. |
| Regular Nodes | The Main Codex client that interacts with other nodes to locate and retrieve data. Can also be considered a ephemeral node(light client) |
| Slots | An agreement with storage nodes and regular nodes to store data |

The Codex network provides a marketplace where regular nodes can create a storage request on the blockchain to store data.
A Codex node can request storage of arbitrary data by creating open slots on the blockchain. 
The requester SHOULD include the following:

### Storage Request

```protobuf

requestStorage {
  // content identifier
  byte cid = 1

  // Tokens from the requester to reward storage nodes
  byte reward = 2

  // Amount of tokens required for collateral by storage nodes
  byte collateral = 3

  // Frequency that proofs are checked by validator nodes
  byte proofProbability = 4

  //
  proofParameters = 5

  //
  erasureCoding = 6

  //
  dispersal = 7

  //
  repair = 8

  // Number of storage hosts 
  nodes = 9

  //
  duratioin = 10

  //
  tolerance = 11

  // Timeout set for slots to be filled
  expire = 12
}

```
- cid MUST be a sha2-256 hash (length 32 bytes, base58) of the data being stored

The contract will be open to any storage node willing to accepting to store the data.
### Filling Slots

