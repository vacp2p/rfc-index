---
title: CODEX-MANIFEST
name: Codes Manifest
status: raw
category: Standards Track
tags: codex
editor: 
contributors:
---

## Abstract

This specification defines the attributes for the Codex manifest.

## Background

The Codex manifest provides the description of the metadata uploaded to the Codex network.
It is in many ways similar to the BitTorrent metainfo file also known as .torrent files,
(for more information see, [BEP3 from BitTorrent Enhancement Proposals (BEPs)]().
While the BitTorrent metainfo files are generally distributed out-of-band,
Codex manifest receives its own [content identifier (CID)]() that is announced on the Codex DHT, also 
see the [CODEX-DHT specification]().

In version 1 of the BitTorrent protocol a user wants to upload (seed) some content to the BitTorrent network,
the client chunks the content into pieces.
For each piece, a hash is computed and
included in the pieces attribute of the info dictionary in the BitTorrent metainfo file.
In Codex,
instead of hashes of individual pieces,
we create a Merkle Tree computed over the blocks in the dataset.
We then include the CID of the root of this Merkle Tree as treeCid attribute in the Codex Manifest file.

In version 2 of the BitTorrent protocol also uses Merkle Trees and
includes the root of the tree in the info dictionary for each .torrent file.

The resulting Manifest is encoded and
the corresponding CID - Manifest CID - is then returned to the user in Multibase base58btc
encoding (official string representation of CID version 1).
Because in Codex, Manifest CID is announced on the DHT,
the nodes storing the corresponding Manifest block can be found.
From the resolved manifest, 
the nodes storing relevant blocks can be identified using the treeCid attribute from the manifest.
The treeCid in Codex is this similar to the infoHash from BitTorrent.
In version 2 of the BitTorrent protocol,
infoHash is also announced on the BitTorrent DHT,
but a torrent file or the so-called magnet link (also introduced later)
has to be distributed out-of-band.

The Codex manifest, CID in particular,
is the ability to uniquely identify the content and
be able to retrieve that content from any single Codex client.

## Semantics

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Manifest

The manifest SHOULD be 

#### Parameters

```protobuf

Message Manifest {
  optional bytes treeCid = 1;        # cid (root) of the tree
  optional uint32 blockSize = 2;     # size of a single block
  optional uint64 datasetSize = 3;   # size of the dataset
  optional uint32 codec = 4;         # Dataset codec
  optional uint32 hcodec  = 5        # Multihash codec
  optional uint32 version = 6;       # Cid version
  optional string filename = 8;      # original filename
  optional string mimetype = 9;      # original mimetype
}

```

| attribute | type | description |
|-----------|------|-------------|
| `treeCid` | string | A hash based on [CIDv1](https://github.com/multiformats/cid#cidv1). The root of the merkle tree |
| `datasetSize` | bytes | Total size of all blocks, after data is chunked. |
| `blockSize` | bytes | Size of each contained block. |
| `codec` | [MultiCodec](https://github.com/multiformats/multicodec) |  A dataset codec. |
| `hcodec` | [MultiCodec](https://github.com/multiformats/multicodec) | A multihash codec. |
| `version` | string | The CID version |
| `filename` | bool | |
| `mimetype` | int |  |

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [MultiCodec](https://github.com/multiformats/multicodec)
- [CIDv1](https://github.com/multiformats/cid#cidv1)
