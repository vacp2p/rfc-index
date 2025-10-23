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

The data chucks will are encoded based on the following parameters:

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

With Reed-Solomon algorithm, extra data chunks need to be created for the dataset.
Parity blocks is added to the chucks of data before encoding.
Once data is encoded, it is prepared to be transmitted or placed into slots by the client node.
Slots containing encoded data chunks are located by the CID and downloaded by storage providers.

Below is the content of the dag-pb protobuf message:

```protobuf

   Message VerificationInfo {
     bytes verifyRoot = 1;             # Decimal encoded field-element
     repeated bytes slotRoots = 2;     # Decimal encoded field-elements
   }
   Message ErasureInfo {
     optional uint32 ecK = 1;                            # number of encoded blocks
     optional uint32 ecM = 2;                            # number of parity blocks
     optional bytes originalTreeCid = 3;                 # cid of the original dataset
     optional uint32 originalDatasetSize = 4;            # size of the original dataset
     optional VerificationInformation verification = 5;  # verification information
   }

   Message Header {
     optional bytes treeCid = 1;        # cid (root) of the tree
     optional uint32 blockSize = 2;     # size of a single block
     optional uint64 datasetSize = 3;   # size of the dataset
     optional codec: MultiCodec = 4;    # Dataset codec
     optional hcodec: MultiCodec = 5    # Multihash codec
     optional version: CidVersion = 6;  # Cid version
     optional ErasureInfo erasure = 7;  # erasure coding info
   }

```


After erasure encoding process, 
the dataset is ready to be stored on the network via the [CODEX-MARKETPLACE](./marketplace.md).

- Store the data blocks
- Store tree roots
- Create protected manifest

### Decode Data

Decoding occurs after a dataset is downloaded by storage providers and
and proofs of storage are required.
There are two node roles that will need to decode data.

- Client nodes to read data
- Validator nodes to verfiy storage providers are storing data as per the marketplace
- During repair of slots

Using the CID of a dataset, a client node can read the data during a storage request.
The client node will download all slots accioscated to the dataset to perform erasure decoding.

To ensure data is being stored by storage providers, the smart contracts REQUIRES proof of storage to be submitted.
Once submitted by an SP node, validator check proofs are valid by decoding data. 

## Security Considerations

### Adversarial Attack

An adversarial storage provider can remove only the first element from more than half of the block, and the slot data can no longer be recovered from the data that the host stores.
For example, with 1TB of slot data erasure coded into 256 data and parity shards, an adversary could strategically remove 129 bytes, and the data can no longer be fully recovered with the erasure coded data that is present on the host.

The RECOMMENDED solution should perform checks on entire shards to protect against adversarial erasure.
In the Merkle storage proofs, we need to hash the entire shard, and then check that hash with a Merkle proof.
Effectively the block size for Merkle proofs should equal the shard size of the erasure coding interleaving. Hashing large amounts of data will be expensive to perform in a SNARK, which is used to compress proofs in size in Codex.

### Data Encryption

If data is not encryted before entering the encoding process, nodes, including storage providers, will be able to access the data. This may lead to privacy concerns and the misuse of data.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [CODEX-MARKETPLACE](./marketplace.md)
