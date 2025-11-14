---
title: CODEX-BLOCK-EXCHANGE
name: Codex Block Exchange Protocol
status: raw
category: Standards Track
tags: codex, block-exchange, p2p, data-distribution
editor: Codex Team
contributors:
---

## Abstract

The Block Exchange (BE) is a core Codex component responsible for
peer-to-peer content distribution across the network.
It manages the sending and receiving of data blocks between nodes,
enabling efficient data sharing and retrieval.
This specification defines both an internal service interface and a
network protocol for referring to and providing data blocks.
Blocks are uniquely identifiable by means of an address and represent
fixed-length chunks of arbitrary data.

## Semantics

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this
document are to be interpreted as described in
[RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### Definitions

| Term | Description |
|------|-------------|
| **Block** | Fixed-length chunk of arbitrary data, uniquely identifiable |
| **Standalone Block** | Self-contained block addressed by SHA256 hash (CID) |
| **Dataset Block** | Block in ordered set, addressed by dataset CID + index |
| **Block Address** | Unique identifier for standalone/dataset addressing |
| **WantList** | List of block requests sent by a peer |
| **Block Delivery** | Transmission of block data from one peer to another |
| **Block Presence** | Indicator of whether peer has requested block |
| **Merkle Proof** | Proof verifying dataset block position correctness |
| **CID** | Content Identifier - hash-based identifier for content |
| **Multicodec** | Self-describing format identifier for data encoding |
| **Multihash** | Self-describing hash format |

## Motivation

The Block Exchange module serves as the fundamental layer for content
distribution in the Codex network.
It provides primitives for requesting and delivering blocks of data
between peers, supporting both standalone blocks and blocks that are
part of larger datasets.
The protocol is designed to work over libp2p streams and integrates
with Codex's discovery, storage, and payment systems.

When a peer wishes to obtain a block, it registers its unique address
with the Block Exchange, and the Block Exchange will then be in charge
of procuring it by finding a peer that has the block, if any, and then
downloading it.
The Block Exchange will also accept requests from peers which might
want blocks that the node has, and provide them.

**Discovery Separation:** Throughout this specification we assume that
if a peer wants a block, then the peer has the means to locate and
connect to peers which either: (1) have the block; or (2) are
reasonably expected to obtain the block in the future.
In practical implementations, the Block Exchange will typically require
the support of an underlying discovery service, e.g., the Codex DHT,
to look up such peers, but this is beyond the scope of this document.

The protocol supports two distinct block types to accommodate different
use cases: standalone blocks for independent data chunks and dataset
blocks for ordered collections of data that form larger structures.

## Block Format

The Block Exchange protocol supports two types of blocks:

### Standalone Blocks

Standalone blocks are self-contained pieces of data addressed by their
SHA256 content identifier (CID).
These blocks are independent and do not reference any larger structure.

**Properties:**

- Addressed by content hash (SHA256)
- Default size: 64 KiB
- Self-contained and independently verifiable

### Dataset Blocks

Dataset blocks are part of ordered sets and are addressed by a
`(datasetCID, index)` tuple.
The datasetCID refers to the Merkle tree root of the entire dataset,
and the index indicates the block's position within that dataset.

Formally, we can define a block as a tuple consisting of raw data and
its content identifier: `(data: seq[byte], cid: Cid)`, where standalone
blocks are addressed by `cid`, and dataset blocks can be addressed
either by `cid` or a `(datasetCID, index)` tuple.

**Properties:**

- Addressed by `(treeCID, index)` tuple
- Part of a Merkle tree structure
- Require Merkle proof for verification
- Must be uniformly sized within a dataset
- Final blocks MUST be zero-padded if incomplete

### Block Specifications

All blocks in the Codex Block Exchange protocol adhere to the
following specifications:

| Property | Value | Description |
|----------|-------|-------------|
| Default Block Size | 64 KiB | Standard size for data blocks |
| Multicodec | `codex-block` (0xCD02) | Format identifier |
| Multihash | `sha2-256` (0x12) | Hash algorithm for addressing |
| Padding Requirement | Zero-padding | Incomplete final blocks padded |

## Service Interface

The Block Exchange module exposes two core primitives for
block management:

### `requestBlock`

```python
async def requestBlock(address: BlockAddress) -> Block
```

Registers a block address for retrieval and returns the block data
when available.
This function can be awaited by the caller until the block is retrieved
from the network or local storage.

**Parameters:**

- `address`: BlockAddress - The unique address identifying the block
  to retrieve

**Returns:**

- `Block` - The retrieved block data

### `cancelRequest`

```python
async def cancelRequest(address: BlockAddress) -> bool
```

Cancels a previously registered block request.

**Parameters:**

- `address`: BlockAddress - The address of the block request to cancel

**Returns:**

- `bool` - True if the cancellation was successful, False otherwise

## Dependencies

The Block Exchange module depends on and interacts with several other
Codex components:

| Component | Purpose |
|-----------|---------|
| **Discovery Module** | DHT-based peer discovery for locating nodes |
| **Local Store (Repo)** | Persistent block storage for local blocks |
| **Advertiser** | Announces block availability to the network |
| **Network Layer** | libp2p connections and stream management |

## Protocol Specification

### Protocol Identifier

The Block Exchange protocol uses the following libp2p protocol
identifier:

```text
/codex/blockexc/1.0.0
```

### Connection Model

The protocol operates over libp2p streams.
When a node wants to communicate with a peer:

1. The initiating node dials the peer using the protocol identifier
2. A bidirectional stream is established
3. Both sides can send and receive messages on this stream
4. Messages are encoded using Protocol Buffers
5. The stream remains open for the duration of the exchange session
6. Peers track active connections in a peer context store

The protocol handles peer lifecycle events:

- **Peer Joined**: When a peer connects, it is added to the active
  peer set
- **Peer Departed**: When a peer disconnects gracefully, its context
  is cleaned up
- **Peer Dropped**: When a peer connection fails, it is removed from
  the active set

### Message Format

All messages use Protocol Buffers encoding for serialization.
The main message structure supports multiple operation types in a
single message.

#### Main Message Structure

```protobuf
message Message {
  Wantlist wantlist = 1;
  repeated BlockDelivery payload = 3;
  repeated BlockPresence blockPresences = 4;
  int32 pendingBytes = 5;
  AccountMessage account = 6;
  StateChannelUpdate payment = 7;
}
```

**Fields:**

- `wantlist`: Block requests from the sender
- `payload`: Block deliveries (actual block data)
- `blockPresences`: Availability indicators for requested blocks
- `pendingBytes`: Number of bytes pending delivery
- `account`: Account information for micropayments
- `payment`: State channel update for payment processing

#### Block Address

The BlockAddress structure supports both standalone and dataset
block addressing:

```protobuf
message BlockAddress {
  bool leaf = 1;
  bytes treeCid = 2;    // Present when leaf = true
  uint64 index = 3;     // Present when leaf = true
  bytes cid = 4;        // Present when leaf = false
}
```

**Fields:**

- `leaf`: Indicates if this is dataset block (true) or standalone
  (false)
- `treeCid`: Merkle tree root CID (present when `leaf = true`)
- `index`: Position of block within dataset (present when `leaf = true`)
- `cid`: Content identifier of the block (present when `leaf = false`)

**Addressing Modes:**

- **Standalone Block** (`leaf = false`): Direct CID reference to a
  standalone content block
- **Dataset Block** (`leaf = true`): Reference to a block within an
  ordered set, identified by a Merkle tree root and an index.
  The Merkle root may refer to either a regular dataset, or a dataset
  that has undergone erasure-coding

#### WantList

The WantList communicates which blocks a peer desires to receive:

```protobuf
message Wantlist {
  enum WantType {
    wantBlock = 0;
    wantHave = 1;
  }

  message Entry {
    BlockAddress address = 1;
    int32 priority = 2;
    bool cancel = 3;
    WantType wantType = 4;
    bool sendDontHave = 5;
  }

  repeated Entry entries = 1;
  bool full = 2;
}
```

**WantType Values:**

- `wantBlock (0)`: Request full block delivery
- `wantHave (1)`: Request availability information only (presence check)

**Entry Fields:**

- `address`: The block being requested
- `priority`: Request priority (currently always 0)
- `cancel`: If true, cancels a previous want for this block
- `wantType`: Specifies whether full block or presence is desired
  - `wantHave (1)`: Only check if peer has the block
  - `wantBlock (0)`: Request full block data
- `sendDontHave`: If true, peer should respond even if it doesn't have
  the block

**WantList Fields:**

- `entries`: List of block requests
- `full`: If true, replaces all previous entries; if false, delta update

**Delta Updates:**

WantLists support delta updates for efficiency.
When `full = false`, entries represent additions or modifications to
the existing WantList rather than a complete replacement.

#### Block Delivery

Block deliveries contain the actual block data along with verification
information:

```protobuf
message BlockDelivery {
  bytes cid = 1;
  bytes data = 2;
  BlockAddress address = 3;
  bytes proof = 4;
}
```

**Fields:**

- `cid`: Content identifier of the block
- `data`: Raw block data (up to 100 MiB)
- `address`: The BlockAddress identifying this block
- `proof`: Merkle proof (CodexProof) verifying block correctness
  (required for dataset blocks)

**Merkle Proof Verification:**

When delivering dataset blocks (`address.leaf = true`):

- The delivery MUST include a Merkle proof (CodexProof)
- The proof verifies that the block at the given index is correctly
  part of the Merkle tree identified by the tree CID
- This applies to all datasets, irrespective of whether they have been
  erasure-coded or not
- Recipients MUST verify the proof before accepting the block
- Invalid proofs result in block rejection

#### Block Presence

Block presence messages indicate whether a peer has or does not have a
requested block:

```protobuf
enum BlockPresenceType {
  presenceHave = 0;
  presenceDontHave = 1;
}

message BlockPresence {
  BlockAddress address = 1;
  BlockPresenceType type = 2;
  bytes price = 3;
}
```

**Fields:**

- `address`: The block address being referenced
- `type`: Whether the peer has the block or not
- `price`: Price (UInt256 format)

#### Payment Messages

Payment-related messages for micropayments using Nitro state channels.

**Account Message:**

```protobuf
message AccountMessage {
  bytes address = 1;  // Ethereum address to which payments should be made
}
```

**Fields:**

- `address`: Ethereum address for receiving payments

**State Channel Update:**

```protobuf
message StateChannelUpdate {
  bytes update = 1;   // Signed Nitro state, serialized as JSON
}
```

**Fields:**

- `update`: Nitro state channel update containing payment information

## Security Considerations

### Block Verification

- All dataset blocks MUST include and verify Merkle proofs before acceptance
- Standalone blocks MUST verify CID matches the SHA256 hash of the data
- Peers SHOULD reject blocks that fail verification immediately

### DoS Protection

- Implementations SHOULD limit the number of concurrent block requests per peer
- Implementations SHOULD implement rate limiting for WantList updates
- Large WantLists MAY be rejected to prevent resource exhaustion

### Data Integrity

- All blocks MUST be validated before being stored or forwarded
- Zero-padding in dataset blocks MUST be verified to prevent data corruption
- Block sizes MUST be validated against protocol limits

### Privacy Considerations

- Block requests reveal information about what data a peer is seeking
- Implementations MAY implement request obfuscation strategies
- Presence information can leak storage capacity details

## Rationale

### Design Decisions

**Two-Tier Block Addressing:**
The protocol supports both standalone and dataset blocks to accommodate
different use cases.
Standalone blocks are simpler and don't require Merkle proofs, while
dataset blocks enable efficient verification of large datasets without
requiring the entire dataset.

**WantList Delta Updates:**
Supporting delta updates reduces bandwidth consumption when peers only
need to modify a small portion of their wants, which is common in
long-lived connections.

**Separate Presence Messages:**
Decoupling presence information from block delivery allows peers to
quickly assess availability without waiting for full block transfers.

**Fixed Block Size:**
The 64 KiB default block size balances efficient network transmission
with manageable memory overhead.

**Zero-Padding Requirement:**
Requiring zero-padding for incomplete dataset blocks ensures uniform
block sizes within datasets, simplifying Merkle tree construction and
verification.

**Protocol Buffers:**
Using Protocol Buffers provides efficient serialization, forward
compatibility, and wide language support.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### Normative

- [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt) - Key words for use
  in RFCs to Indicate Requirement Levels
- **libp2p**: <https://libp2p.io>
- **Protocol Buffers**: <https://protobuf.dev>
- **Multihash**: <https://multiformats.io/multihash/>
- **Multicodec**: <https://github.com/multiformats/multicodec>

### Informative

- **Codex Documentation**: <https://docs.codex.storage>
- **Codex Block Exchange Module Spec**:
  <https://github.com/codex-storage/codex-docs-obsidian/blob/main/10%20Notes/Specs/Block%20Exchange%20Module%20Spec.md>
- **Merkle Trees**: <https://en.wikipedia.org/wiki/Merkle_tree>
- **Content Addressing**:
  <https://en.wikipedia.org/wiki/Content-addressable_storage>
