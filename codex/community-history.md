---
title: CODEX-COMMUNITY-HISTORY
name: Codex Community History
status: raw
tags: codex
editor:
contributors:
---

## Abstract

This document describes how Control Nodes, nodes in Status communities,
archive historical message data of their communities,
beyond the time range limit provided by Store Nodes using the BitTorrent protocol.
It also describes how the archives are distributed to community members via the Status network,
so they can fetch them and
gain access to a complete message history.

## Background

Messages are stored permanently by store nodes (13/WAKU2-STORE) for up to a certain configurable period of time,
limited by the overall storage provided by a store node.
Messages older than that period are no longer provided by store nodes,
making it impossible for other nodes to request historical messages that go beyond that time range.
This raises issues in the case of Status communities,
where recently joined members of a community are not able to request complete message histories of the community channels.

### Terminology

| Name | Description |
| ---- | -------------- |
| Waku node |	A [10/WAKU2]() node that implements [11/WAKU2-RELAY]() |
| Store node | A [10/WAKU2]() node that implements [13/WAKU2-STORE]() |
| Waku network |	A group of [10/WAKU2]() nodes forming a graph, connected via [11/WAKU2-RELAY]() |
| Status user |	An Status account that is used in a Status consumer product, such as Status Mobile or Status Desktop |
| Status node |	A Status client run by a Status application |
| Control node|	A Status node that owns the private key for a Status community |
| Community member |	A Status user that is part of a Status community, not owning the private key of the community|
| Community member node	| A Status node with message archive capabilities enabled, run by a community member |
| Live messages |	Waku messages received through the Waku network |
| BitTorrent client |	A program implementing the BitTorrent protocol |
| Torrent/Torrent file |	A file containing metadata about data to be downloaded by BitTorrent clients |
| Magnet link |	A link encoding the metadata provided by a torrent file (Magnet URI scheme) |

## Specification

### Message History Archive

Message history archives are represented as `WakuMessageArchive` and
created from a [14/WAKU-MESSAGE]() exported from the local database.
The following describes the protocol buffer for `WakuMessageArchive` :

``` protobuf

syntax = "proto3"

message WakuMessageArchiveMetadata {
  uint8 version = 1
  uint64 from = 2
  uint64 to = 3
  repeated string contentTopic = 4
}

message WakuMessageArchive {
  uint8 version = 1
  WakuMessageArchiveMetadata metadata = 2
  repeated WakuMessage messages = 3 // `WakuMessage` is provided by 14/WAKU2-MESSAGE
  bytes padding = 4
}

```

The `from` field SHOULD contain a timestamp of the `timestamps` time range's lower bound.
The type parallels the `timestamp` of a `WakuMessage`.
The `to` field SHOULD contain a `timestamp` of the time range's the higher bound.
The `contentTopic` field MUST contain a list of all communiity channel topics.
The `messages` field MUST contain all messages that belong into the archive given its `from`,
`to` and `contentTopic` fields.

The `padding` field MUST contain the amount of zero bytes needed,
so that the overall byte size of the protobuf encoded `WakuMessageArchive` is a multiple of the pieceLength used to divide
the message archive data into pieces.
This is needed for seamless encoding and
decoding of archival data in interation with BitTorrent,
as explained in [creating message archive torrents]().

### Message History Archive Index

Control nodes MUST provide message archives for the entire community history.
The entire history consists of a set of `WakuMessageArchive`,
where each archive contains a subset of historical `WakuMessages` for a time range of seven days.
All the `WakuMessageArchive` are concatenated into a single file as a byte string [(see Ensuring reproducible data pieces)]().

Control nodes MUST create a message history archive index,
`WakuMessageArchiveIndex` with metadata,
that allows receiving nodes to only fetch the message history archives they are interested in.

### WakuMessageArchiveIndex

``` protobuf

syntax = "proto3"

message WakuMessageArchiveIndexMetadata {
  uint8 version = 1
  WakuMessageArchiveMetadata metadata = 2
  uint64 offset = 3
  uint64 num_pieces = 4
}

message WakuMessageArchiveIndex {
  map<string, WakuMessageArchiveIndexMetadata> archives = 1
}

```


A `WakuMessageArchiveIndex` is a map where the key is the KECCAK-256 hash of the `WakuMessageArchiveIndexMetadata` derived from a 7-day archive
and the value is an instance of that `WakuMessageArchiveIndexMetadata` corresponding to that archive.

The `offset` field MUST contain the position at which the message history archive starts in the byte string
of the total message archive data.
This MUST be the sum of the length of all previously created message archives in bytes [(see Creating message archive torrents)]().

The control node MUST update the `WakuMessageArchiveIndex` every time it creates one or
more `WakuMessageArchive`s and bundle it into a new torrent.
For every created `WakuMessageArchive`,
there MUST be a `WakuMessageArchiveIndexMetadata` entry in the archives field `WakuMessageArchiveIndex`.

### Creating Message Archive Torrents

Control nodes MUST create a `.torrent` file containing metadata to all message history archives***.
To create a `.torrent` file, and
later serve the message archive data in the BitTorrent network,
control nodes MUST store the necessary data in dedicated files on the file system.

A torrent's source folder MUST contain the following two files:

- `data`: Contains all protobuf encoded `WakuMessageArchive`'s (as bit strings)
concatenated in ascending order based on their time
- `index`: Contains the protobuf encoded `WakuMessageArchiveIndex`

Control nodes SHOULD store these files in a dedicated folder that is identifiable, via the community id***.

### Ensuring Reproducible Data Pieces

The control node MUST ensure that the byte string from the protobuf encoded data,
is equal to the byte string data from the previously generated message archive torrent.
Including the data of the latest 7 days worth of messages encoded as `WakuMessageArchive`.
Therefore, the size of data grows every seven days as it's append only.

Control nodes MUST ensure that the byte size of every individual `WakuMessageArchive` encoded protobuf is a multiple of pieceLength: ??? (TODO) using the padding field.
If the protobuf encoded `WakuMessageArchive` is not a multiple of pieceLength,
its padding field MUST be filled with zero bytes and
the `WakuMessageArchive` MUST be re-encoded until its size becomes multiple of pieceLength.

This is necessary because the content of the data file will be split into pieces of pieceLength when the torrent file is created, and the SHA1 hash of every piece is then stored in the torrent file and later used by other nodes to request the data for each individual data piece.

By fitting message archives into a multiple of pieceLength and ensuring they fill possible remaining space with zero bytes, control nodes prevent the next message archive to occupy that remaining space of the last piece, which will result in a different SHA1 hash for that piece.

Example: Without padding
Let WakuMessageArchive "A1" be of size 20 bytes:

``` text
 0 11 22 33 44 55 66 77 88 99
10 11 12 13 14 15 16 17 18 19
```

With a pieceLength of 10 bytes, A1 will fit into 20 / 10 = 2 pieces:

```
 0 11 22 33 44 55 66 77 88 99 // piece[0] SHA1: 0x123
10 11 12 13 14 15 16 17 18 19 // piece[1] SHA1: 0x456
```

Example: With padding
Let WakuMessageArchive "A2" be of size 21 bytes:

```
 0 11 22 33 44 55 66 77 88 99
10 11 12 13 14 15 16 17 18 19
20
```

With a pieceLength of 10 bytes, A2 will fit into 21 / 10 = 2 pieces.

The remainder will introduce a third piece:

```
 0 11 22 33 44 55 66 77 88 99 // piece[0] SHA1: 0x123
10 11 12 13 14 15 16 17 18 19 // piece[1] SHA1: 0x456
20                            // piece[2] SHA1: 0x789
```

The next WakuMessageArchive "A3" will be appended ("#3") to the existing data and occupy the remaining space of the third data piece.

The piece at index 2 will now produce a different SHA1 hash:

```
 0 11 22 33 44 55 66 77 88 99 // piece[0] SHA1: 0x123
10 11 12 13 14 15 16 17 18 19 // piece[1] SHA1: 0x456
20 #3 #3 #3 #3 #3 #3 #3 #3 #3 // piece[2] SHA1: 0xeef
#3 #3 #3 #3 #3 #3 #3 #3 #3 #3 // piece[3]
```

By filling up the remaining space of the third piece with A2 using its padding field, it is guaranteed that its SHA1 will stay the same:

```
 0 11 22 33 44 55 66 77 88 99 // piece[0] SHA1: 0x123
10 11 12 13 14 15 16 17 18 19 // piece[1] SHA1: 0x456
20  0  0  0  0  0  0  0  0  0 // piece[2] SHA1: 0x999
#3 #3 #3 #3 #3 #3 #3 #3 #3 #3 // piece[3]
#3 #3 #3 #3 #3 #3 #3 #3 #3 #3 // piece[4]
```

### Seeding Message History Archives

The control node MUST seed the generated torrent until a new `WakuMessageArchive` is created.

The control node SHOULD NOT seed torrents for older message history archives.
Only one torrent at a time should be seeded.

### Creating Magnet Links

Once a torrent file for all message archives is created,
the control node MUST derive a magnet link following the Magnet URI scheme using the underlying BitTorrent protocol client.

#### Message Archive Distribution

Message archives are available via the BitTorrent network as they are being seeded by the control node.
Other community member nodes will download the message archives from the BitTorrent network,
after receiving a magnet link that contains a message archive index.

The control node MUST send magnet links containing message archives and
the message archive index to a special community channel.
The `content_Topic` of that special channel follows the following format:

``` text

/{application-name}/{version-of-the-application}/{content-topic-name}/{encoding}
```

All messages sent with this special channel's `content_Topic` MUST be instances of `ApplicationMetadataMessage`,
with a [62/STATUS-PAYLOADS]() of `CommunityMessageArchiveIndex`.

Only the control node MAY post to the special channel.
Other messages on this specified channel MUST be ignored by clients.
Community members MUST NOT have permission to send messages to the special channel.
However, community member nodes MUST subscribe to special channel,
to receive [14/WAKU2-MESSAGE]() containing magnet links for message archives.

#### Canonical Message Histories

Only control nodes are allowed to distribute messages with magnet links via the special channel for magnet link exchange.
Status nodes MUST ignore all messages in the special channel that isn't signed by a control node.
Since the magnet links are created from the control node's database
(and previously distributed archives),
the message history provided by the control node becomes the canonical message history and
single source of truth for the community.

Community member nodes MUST replace messages in their local databases with the messages extracted from archives
within the same time range***.
Messages that the control node didn't receive MUST be removed and
are no longer part of the message history of interest,
even if it already existed in a community member node's database.

### Fetching Message History Archives

The process of fetching message hsitory:

1. Receive message archive index magnet link as described in [Message archive distribution](),
2. Download index file from torrent, then determine which message archives to download
3. Download individual archives

Community member nodes subscribe to the special channel that control nodes publish magnet links for message history archives to.
Two RECOMMENDED scenarios in which community member nodes can receive such a magnet link message from the special channel:

1. The member node receives it via live messages, by listening to the special channel.
2. The member node requests messages for a time range of up to 30 days from store nodes
(this is the case when a new community member joins a community).
3. Downloading message archives

When community member nodes receive a message with a `CommunityMessageHistoryArchive` [62/STATUS-PAYLOADS](),
they MUST extract the `magnet_uri`. and
Then SHOULD pass it to their underlying BitTorrent client to fetch the latest message history archive index,
which is the index file of the torrent, see [Creating message archive torrents].

Due to the nature of distributed systems,
there's no guarantee that a received message is the "last" message.
This is especially true when community member nodes request historical messages from store nodes.
Therefore, community member nodes MUST wait for 20 seconds after receiving the last `CommunityMessageArchive` before they start extracting the magnet link to fetch the latest archive index.

Once a message history archive index is downloaded and
parsed back into `WakuMessageArchiveIndex`,
community member nodes use a local lookup table to determine which of the listed archives are missing using the KECCAK-256 hashes stored in the index.

For this lookup to work,
member nodes MUST store the KECCAK-256 hashes of the `WakuMessageArchiveIndexMetadata` provided by the index file for all of the message history archives that have been downlaoded in their local database.

Given a WakuMessageArchiveIndex, member nodes can access individual WakuMessageArchiveIndexMetadata to download individual archives.

Community member nodes MUST choose one of the following options:

Download all archives - Request and download all data pieces for data provided by the torrent (this is the case for new community member nodes that haven't downloaded any archives yet)
Download only the latest archive - Request and download all pieces starting at the offset of the latest WakuMessageArchiveIndexMetadata (this is the case for any member node that already has downloaded all previous history and is now interested in only the latst archive)
Download specific archives - Look into from and to fields of every WakuMessageArchiveIndexMetadata and determine the pieces for archives of a specific time range (can be the case for member nodes that have recently joined the network and are only interested in a subset of the complete history)
Storing historical messages
When message archives are fetched, community member nodes MUST unwrap the resulting WakuMessage instances into ApplicationMetadataMessage instances and store them in their local database. Community member nodes SHOULD NOT store the wrapped WakuMessage messages.

All message within the same time range MUST be replaced with the messages provided by the message history archive.

Community members nodes MUST ignore the expiration state of each archive message.

### Security Considerations

#### Multiple Community Owners

It is possible for control nodes to export the private key of their owned community and
pass it to other users so they become control nodes as well.
This means, it's possible for multiple control nodes to exist for one community.

This might conflict with the assumption that the control node serves as a single source of truth.
Multiple control nodes can have different message histories.
Not only will multiple control nodes multiply the amount of archive index messages being distributed to the network,
they might also contain different sets of magnet links and their corresponding hashes.
Even if just a single message is missing in one of the histories,
the hashes presented in archive indices will look completely different,
resulting in the community member node to download the corresponding archive.
This might be identical to an archive that was already downloaded, except for that one message.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
- 
