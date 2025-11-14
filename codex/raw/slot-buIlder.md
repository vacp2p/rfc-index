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
There SHOULD be three merkle tree contructed for the slot building process.
A block digest tree, a slot tree and a verification tree.

A prepared dataset will be presented to the network in the form of slots.
Slot represent a data chunk with a block that include all mechanisms for conducting a storage contract.
Based on the storage contract, storage providers SHOULD be able to locate a specifc data chunk that is tasked to be stored.

### Contruct the Slot Tree

A slot stores a list of root hashes that help in the retrieval of a dataset.
The block digest tree SHOULD be contructed before building any slots.
A block is divided into cells that are then hashed and
those hashes are used to create a [Posieden2]() based merkle tree.
A block digest tree SHOULD contain the unqiue root hashes of blocks of the entire dataset,
which MAY also be based on the Posiden2 algorithm.
The total byte size of each block MUST be able to evenly divide by the cell size and/or 
the number of slots.

### Slot Tree Contruction

Some slots MAY be empty,
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

Nodes within the network are REQUIRED to verify a dataset before retrieving it.
A verification tree is a merkle proof derived from the `slotRoot`.
The entire dataset is not REQUIRED to contruct the tree.

The following parameters SHOULD be presented:


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

- [CODEX-ERASURE-CODING](./erasure-coding.md)
- 
