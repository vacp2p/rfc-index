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
Slots used in the Codex protocol is an important component to node collaboration in the network. 

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
 

### Block Tree

A block digest tree is contructed to produce a unqiue root hash that represents the dataset.
The root hash SHOULD be used to fill slots.

Slots are request made by a client to store a part of a dataset.


### Slot Tree Contruction

If slots MAY be empty, meaning containing no data,
depending on the size of the dataset.


``` nim

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

A verification tree is contructed from all slots of a dataset.

```nim

type ProofInputs*[H] = object
  entropy*: H                    # Randomness value
  datasetRoot*: H                # Dataset root hash
  slotIndex*: Natural            # Slot identifier
  slotRoot*: H                   # Root hash of slot
  nCellsPerSlot*: Natural        # Cell count per slot
  nSlotsPerDataSet*: Natural     # Total slot count
  slotProof*: seq[H]             # Inclusion proof for slot in dataset
  samples*: seq[Sample[H]]       # Cell inclusion proofs

```



## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [CODEX-ERASURE-CODING](./erasure-coding.md)
- 
