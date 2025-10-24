---
title: CODEX-MANIFEST
name: Codes Manifest
status: raw
category: Standards Track
tags: codex
editor: 
contributors:
- Jimmy Debe <jimmy@status.im>
---

## Abstract

This specification defines the attributes of the Codex manifest.

## Background

The Codex manifest provides the description of the metadata uploaded to the Codex network.
It is in many ways similar to the BitTorrent metainfo file also known as .torrent files,
(for more information see, [BEP3](http://bittorrent.org/beps/bep_0003.html) from BitTorrent Enhancement Proposals (BEPs).
While the BitTorrent metainfo files are generally distributed out-of-band,
Codex manifest receives its own content identifier, [CIDv1](https://github.com/multiformats/cid#cidv1), that is announced on the Codex DHT, also
see the [CODEX-DHT specification](./dht.md).

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

The Codex manifest, CID in particular,
is the ability to uniquely identify the content and
be able to retrieve that content from any single Codex client.

## Semantics

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

The manifest is encoded in multibase base58btc encoding and
has corresponding CID, the manifest content identifier.
In Codex, manifest CID is announced on the DHT, so
the nodes storing the corresponding manifest block can be found by other clients requesting to download the corresponding dataset.

From the manifest, 
providers storing relevant blocks SHOULD be identified using the `treeCid` attribute.
The `treeCid` in Codex is similar to the `info_hash` from BitTorrent.
The `filename` of the orginial dataset SHOULD be included in the manifest.

#### Manifest Attributes

```protobuf

message Manifest {
  optional bytes treeCid = 1;        # cid (root) of the tree
  optional uint32 blockSize = 2;     # size of a single block
  optional uint64 datasetSize = 3;   # size of the dataset
  optional uint32 codec = 4;         # Dataset codec
  optional uint32 hcodec  = 5;        # Multihash codec
  optional uint32 version = 6;       # Cid version
  optional string filename = 7;      # original filename
  optional string mimetype = 8;      # original mimetype
}

```

| attribute | type | description |
|-----------|------|-------------|
| `treeCid` | string | A hash based on [CIDv1](https://github.com/multiformats/cid#cidv1) of the root of the [Codex Tree], which is a form of a Merkle Tree corresponding to the dataset described by the manifest. Its multicodec is (codex-root, 0xCD03) |
| `blockSize` | bytes | The size of each block for the given dataset. The default block size used in Codex is 64KiB. |
| `datasetSize` | bytes | The total size of all blocks for the original dataset. |
| `codec` | [MultiCodec](https://github.com/multiformats/multicodec) |  The multicodec used for the CIDs of the dataset blocks. Codex uses (codex-block, 0xCD02) |
| `hcodec` | [MultiCodec](https://github.com/multiformats/multicodec) | Multicodec used for computing of the multihash used in blocks CIDs. Codex uses (sha2-256, 0x12). |
| `version` | string | The version of CID used for the dataset blocks. |
| `filename` | string | When provided, it can be used by the client as a file name while downloading the content. |
| `mimetype` | int | When provided, it can be used by the client to set a content type of the downloaded content.  |

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [BEP3](http://bittorrent.org/beps/bep_0003.html)
- [CODEX-DHT specification](./dht.md)
- [MultiCodec](https://github.com/multiformats/multicodec)

