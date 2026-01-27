
| Name       | Logos Storage Datasets               |
| ---------- | ------------------------------------ |
| **Status** | **draft**                            |
| **Editor** | **Giuliano Mega** giuliano@status.im |

## Abstract

This spec defines the basic structure, constraints, and representation for Logos Storage **Datasets** and their metadata. Datasets are the unit of data which Logos Storage manipulates: those can be published, downloaded, or deleted. They could be compared to objects in S3 or, somewhat more loosely, to blocks in IPFS.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Dataset

A _dataset_ is an ordered set of fixed-sized blocks, $F = \{b_1, \cdots b_n\}$. Different datasets MAY have different block sizes, but all blocks within a single dataset MUST have the same size. A valid dataset MUST have at least one block.

A dataset is comparable to a regular filesystem (e.g. ext4) file, in that blocks are totally ordered within the file. This allows us to identify a block within a file $F$ by an integer-valued index $1 \leq i \leq n$. This is in direct contrast with systems like, say, IPFS, in which blocks might not be ordered and block-dataset membership is much more fluid, requiring the use of unique block content identifiers (CID) per block instead.

### Manifest

Every dataset $F$ MUST have an associated _manifest_, which contains metadata describing $F$ and is required to correctly store, decode, and validate its blocks individually. It MAY also contain optional metadata such as a content type, and a file name. In CDDL:

```cddl
manifest = {
  version: uint,
  codec: bstr,
  block_size: uint,
  block_count: uint,
  merkle_root: bytes .size 32,
  ? content_type: tstr,
  ? file_name: tstr,
}
```

The content type, when present, MUST be a valid [RFC6838](https://datatracker.ietf.org/doc/html/rfc6838) media type string.

### Identifying Datasets and Blocks

A dataset MUST be identified by the hash of its serialized manifest, $m$. The encoding of this serialization is specified in its `codec` attribute, which MUST contain [a libp2p multicodec type](https://github.com/multiformats/multicodec/blob/master/table.csv). This means a block within a file MUST be uniquely addressable within the network by the tuple $(m, i)$, where $i$ is an integer $1 \leq i \leq n$.

It is important to note that different values for `file_name` and `content_type` will produce different datasets, even if the set of blocks contained in $F$ remains the same. If this turns out to be undesirable, future versions of this spec might adopt an approach in which a subset of the attributes of the manifest gets hashed instead; akin to how Bittorrent does with its [info dictionaries](https://www.bittorrent.org/beps/bep_0003.html), is used instead.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).