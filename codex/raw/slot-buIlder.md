---
title: CODEX-SLOT-BUILDER
name: Codex Slot Builder
status: raw
tags: codex
editor:
contributors:
- Jimmy Debe <jimmy@status.im>
---

## Abstract

This document describes the Codex slot builder mechanism.
Slots used in the Codex protocol are an important component of node collaboration in the network.

## Background

The Codex protocol places a dataset into blocks before sending a storage request to the network.
Slots control and facilitate the distribution of the data blocks to participating storage providers.
The mechanism builds individual Merkle trees for each slot, enabling cell-level proof generation, and
constructs a root verification tree over all slot roots.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

A Codex client wanting to present a dataset to the network will present a set of erasure encoded data blocks,
as described in the [CODEX-ERASURE-CODING](./erasure-coding.md) specification.
These data blocks will be placed into slots for storage providers to access.
The slot building process MUST construct a block digest Merkle tree from the data blocks.
The root hashes from this tree are used as the leaves in a slot merkle tree.

The prepared dataset is presented to storage providers in the form of slots.
A slot represents the location of a data block cell with an open storage contract.
Storage providers SHOULD be able to locate a specific data block and
all the details of the storage contract.
See, the [CODEX-MARKETPLACE](./marketplace.md) specification.

### Construct a Slot Tree

#### Block Digest Tree

A slot stores a list of root hashes that help with the retrieval of a dataset.
The block digest tree SHOULD be constructed before building any slots.
A data block is divided into cells that are hashed.
The block size MUST be divisible by the cell size for the block digest tree construction.

$$
\text{Cell size} \mid \text{Block size (in bytes)}
$$

A block digest tree SHOULD contain the unique root hashes of blocks of the entire dataset,
which MAY be based on the [Poseidon2](https://eprint.iacr.org/2023/323) algorithm.
The result of one digest tree will be represented by the root hash of the tree.

#### Slot Tree

A slot tree represents one slot,
which includes the list of digest root hashes.
If a block is empty,
the slot branch SHOULD be a hash of an empty block.
Some slots MAY be empty,
depending on the size of the dataset.

$$
\text{Blocks per slot} = \frac{\text{Total blocks}}{\text{Number of slots}}
$$

The cells per slot tree branch MUST be padded to a power of two.
This will ensure a balanced slot Merkle tree.

$$
\text{Cells per slot} = \text{Blocks per slot} \times \text{Cells per block}
$$

Below are the REQUIRED values to build a slot.

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
A verification tree is a Merkle proof derived from the `slotRoot`.
The entire dataset is not REQUIRED to construct the tree.

The following are the inputs to verify a proof:

```nim

type
 H = array[32, byte]
 Natural = uint64

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

To verify, a node MUST recompute the root hash,
based on `slotProof` and the hash of the `slotIndex`,
to confirm that the `slotIndex` is a member of the dataset represented by `datasetRoot`.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [CODEX-ERASURE-CODING](./erasure-coding.md)
- [CODEX-MARKETPLACE](./marketplace.md)
- [Poseidon2](https://eprint.iacr.org/2023/323)
