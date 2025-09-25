---
title: CODEX-ERASUE-CODING
name: Codex Erasue Coding
status: raw
tags: codex
editor: 
contributors:
---

## Abstract

This specification describes the erasue coding technique used in the Codex network.
A Codex node uses erasue coding to encode a dataset that will be stored on the network.

## Background

The Codex protocol has storage proofs to verify whether a storage provider is storing a certain dataset.
Before a dataset can be retrievable on the network,
storage providers must agree to store dataset for a certain period of time.
This task is done by multiple providers participating in the network.
Before making a request on the network,
requesting clients create erasure-protected data blocks using [Reed-Solomon]() erasure coding.
These blocks are assigned between a number of different storage providers via slots through the [CODEX=MARKETPLACE]()
The requester can be assured of data retrievablity even in cases where some data blocks are abandoned by storage providers.

## Wire Format

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

A client SHOULD perform erasure coding locally before providing a dataset to the network.
The dataset is split into data chunks represented by `k`.
The total number of blocks for an erasure protected dataset is represented by `n`.
This would include a set of parity blocks that MAY be generated using the [Reed Solomon algorithm](),
which is represented by `n - k`.

The erasure coding process is utilized by all node roles on the network.

Below are the steps where erasure coding is used:

1. Prepare prefered dataset and encode with Reed-Solomon technique
2.  Derive an CID from encoded chunks and make a re share on the marketplace
3.  Error correction by validator nodes once storage contract begins

# Prepare Data

A user wanting to be stored by the network will prepare the dataset before the request.
The client MUST divide this dataset into chunks, e.g. $(c_1, c_2, c_3, \ldots, c_{n})$.
Interleaving MAY be used to the data chunks to 
Including the [CODEX-MANIFEST](manifest), the data chucks will be encoded based on the following parameters:

```js
struct encodingParms {
  ecK: int,
  ecM: int,
  rounded: int,
  steps: int,
  blocksCount: int,
  strategy: enum
}
```
### Encoding Data

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
