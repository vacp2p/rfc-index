---
title: CODEX-SLOT-BUILDER
name: Codex Slot Builder
status: raw
tags: codex
editor:
contributors:
---

## Abstract

This document describes the Codex slot builder mechanism.
Slots in Codex is an important component to the node collaboration in the network. 

## Background

The Codex protocol places a dataset into blocks before sending a storage request to the network.
Slots control and facilitates the distrubtion of the data blocks to participating storage providers.

The mechanism builds individual Merkle trees for each slot enabling cell-level proof generation, and
constructs a root verification tree over all slot roots.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

A client would present the dataset after the erasure coding process,
for more information refer to the [CODEX-ERASURE-CODING](./erasure-coding.md) specification.
A block digest tree is contructed to produce a unqiue root hash that represents the dataset.
The root hash SHOULD be used to fill slots.

Slots are request made by a client to store a part of a dataset. 

### Block Tree

### Slot Tree Contruction

``` js

type SlotsBuilder*[T, H] = ref object of RootObj
  store: BlockStore              # Storage backend for blocks
  manifest: Manifest             # Current dataset manifest
  strategy: IndexingStrategy     # Block indexing strategy
  cellSize: NBytes               # Size of each cell in bytes
  numSlotBlocks: Natural         # Blocks per slot (including padding)
  slotRoots: seq[H]              # Computed slot root hashes
  emptyBlock: seq[byte]          # Pre-allocated empty block data
  verifiableTree: ?T             # Optional verification tree
  emptyDigestTree: T             # Pre-computed empty block tree

```

### Verification Tree


Construct slot trees from block digests
Create verification trees from slot roots
Manage empty blocks and padding
Store cryptographic proofs in the block store

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References


