---
title: CODEX-ERASUE-CODING
name: Codex Erasue Coding
status: raw
tags: codex
editor: 
contributors:
---

## Abstract

This specification describes the erasue coding technique used by Codex clients.
A Codex client will encode a dataset before it is stored on the network.

## Background

The Codex protocol uses storage proofs to verify whether a storage provider (SP) is storing a certain dataset.
Before a dataset can be retrievable on the network,
SPs must agree to store dataset for a certain period of time.
When to storage request is active erasure coding help ensure the dataset is retrievable from the network.
This is achieved by the dataset that is chunked is restored in retrieveal by erasure coding.****
When data blocks are abandoned by storage providers,
the requester can be assured of data retrievability.


## Specification

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

A client SHOULD perform the erasure encoding locally before providing a dataset to the network.
During validation, nodes will conduct error coorection and decoding based on the erasure coding technique known to the network.
Datasets using encodings not recognized by the network, MAY be ignored during decoding and
validation by other nodes in the network. 

The dataset SHOULD split into data chunks represented by `k`, e.g. $(k_1, k_2, k_3, \ldots, k_{n})$.
Each chunk `k` MUST be encoded into `n` blocks, using an erasure encoding technique like the [Reed Solomon algorithm]().
Including a set of parity blocks that MUST be generated,
represented by `m`.
All node roles on the Codex network use the [Leapard Codec](https://github.com/catid/leopard).

Below is the encoding process:

1.  Prepare the dataset for the marketplace using erasure encoding.
2.  Derive an manifest CID from the root encoded blocks
3.  Error correction by validator nodes once storage contract begins
4.  Decode data back to original data.

### Encoding

A client MAY prepare a dataset locally before making the request to the network.
The data chunks, `k`, MUST be the same size, if not,
the lesser chunk MAY be padded with empty data.

The data blocks are encoded based on the following parameters:

```js

struct encodingParms {
  ecK: int, # Number of data blocks (K)
  ecM: int, # Number of parity blocks (M)
  rounded: int, # Dataset rounded to multiple of (K)
  steps: int, # Number of encoding iterations (steps)
  blocksCount: int, # Total blocks after encoding
  strategy: enum, # Indexing strategy used
}

```

After the erasure coding process,
a protected manifest SHOULD be generated for the dataset which would store the a CID of the root merkle tree.
The content of the protected manifest below, see [CODEX-MANIFEST]() for more information:

```js

   type verifiable {
      verifyRoot: Cid                  # Root of verification tree
      slotRoots: seq[Cid]              # Individual slot roots
      cellSize: NBytes                 # Size of verification cells
      verifiableStrategy: StrategyType # Strategy for verification
   }

   struct ErasureInfo {
     optional uint32 ecK = 1;                            # number of encoded blocks
     optional uint32 ecM = 2;                            # number of parity blocks
     optional bytes originalTreeCid = 3;                 # cid of the original dataset
     optional uint32 originalDatasetSize = 4;            # size of the original dataset
     optional VerificationInformation verification = 5;  # verification information
   }

   struct Manifest {
     optional bytes treeCid = 1;        # cid (root) of the tree
     optional uint32 blockSize = 2;     # size of a single block
     optional uint64 datasetSize = 3;   # size of the dataset
     optional codec: MultiCodec = 4;    # Dataset codec
     optional hcodec: MultiCodec = 5    # Multihash codec
     optional version: CidVersion = 6;  # Cid version
     optional ErasureInfo erasure = 7;  # erasure coding info
   }

```

After the encoding process, 
is ready to be stored on the network via the [CODEX-MARKETPLACE](./marketplace.md).
The merkle tree root SHOULD be included in the manifest so other nodes are able to locate and
recontruct a dataset from the erasure encoded blocks.

### Data Repair

Storage providers may have periods during a storage contract where they are not storing the data.
A validator node MAY store the `treeCid` from the `Manifest` to locate all the data blocks and 
recontruct the merkle tree.
When a missing branch of the tree is not retrievable from a SP, data repair will be REQUIRED.
The validator will open a request for a new SP to reconstruct the merkle tree and
store the missing data blocks.
The validator role is described in the [CODEX-MARKETPLACE]() specification.

### Decode Data

During dataset retrieval, a node will use the `treeCid` to locate the data blocks.
The number of retrieved blocks by the node MUST be greater than `k`.
If less than `k`, the node MAY not be able to recontruct the dataset.
The node SHOULD request missing data chunks from the network and
wait until the threshold is reached.

## Security Considerations

### Adversarial Attack

An adversarial storage provider can remove only the first element from more than half of the block,
and the slot data can no longer be recovered from the data that the host stores.
For example, with data blocks of size 1TB erasure coded into 256 data and parity shard,
an adversary could strategically remove 129 bytes, and
the data can no longer be fully recovered with the erasure coded data that is present on the host.

The RECOMMENDED solution should perform checks on entire shards to protect against adversarial erasure.
In the Merkle storage proofs, the entire shard SHOULD be hased, 
then that hash is checked against the Merkle proof.
Effectively, the block size for Merkle proofs should equal the shard size of the erasure coding interleaving.
Hashing large amounts of data will be expensive to perform in a SNARK, which is used to compress proofs in size in Codex.

### Data Encryption

If data is not encryted before entering the encoding process, nodes, including storage providers,
MAY be able to access the data.
This may lead to privacy concerns and the misuse of data.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [CODEX-MARKETPLACE](./marketplace.md)
