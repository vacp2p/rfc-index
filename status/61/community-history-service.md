---
slug: 61
title: 61/STATUS-Community-History-Service
name: Status Community History Service
status: draft
category: Standards Track
description: Explains how new members of a Status community can request historical messages from archive nodes.
editor: r4bbit <r4bbit@status.im>
contributors:
  - Sanaz Taheri <sanaz@status.im>
  - John Lea <john@status.im>
---

## Abstract

Messages are stored permanently by store nodes
([13/WAKU2-STORE](../../waku/standards/core/13/store.md))
for up to a certain configurable period of time,
limited by the overall storage provided by a store node.
Messages older than that period are no longer provided by store nodes,
making it impossible for other nodes to request historical messages
that go beyond that time range.
This raises issues in the case of Status communities,
where recently joined members of a community
 are not able to request complete message histories of the community channels.

This specification describes how **Control Nodes**
(which are specific nodes in Status communities)
archive historical message data of their communities,
beyond the time range limit provided by Store Nodes using
the [Codex](https://codex.storage) protocol.
It also describes how the archives are distributed to community members via
the Status network,
so they can fetch them and gain access to a complete message history.

## Terminology

The following terminology is used throughout this specification.
Notice that some actors listed here are nodes that operate in Waku networks only,
while others operate in the Status communities layer):

| Name                 | References |
| -------------------- | --- |
| Waku node            | An Waku node ([10/WAKU2](../../waku/standards/core/10/waku2.md)) that implements [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md)|
| Store node           | A Waku node that implements [13/WAKU2-STORE](../../waku/standards/core/13/store.md) |
| Waku network         | A group of Waku nodes forming a graph, connected via [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md) |
| Status user          | An Status account that is used in a Status consumer product, such as Status Mobile or Status Desktop |
| Status node          | A Status client run by a Status application |
| Control node      | A Status node that owns the private key for a Status community |
| Community member     | A Status user that is part of a Status community, not owning the private key of the community |
| Community member node| A Status node with message archive capabilities enabled, run by a community member |
| Live messages        | Waku messages received through the Waku network |
| Codex node           | A program implementing the [Codex](https://codex.storage) protocol |
| CID                  | A content identifier, uniquely identifies a file that can be downloaded by Codex nodes |

## Requirements / Assumptions

This specification has the following assumptions:

- Store nodes,
([13/WAKU2-STORE](../../waku/standards/core/13/store.md)),
 are available 24/7 ensuring constant live message availability.
- The storage time range limit is 30 days.
- Store nodes have enough storage to persist historical messages for up to 30 days.
- No store nodes have storage to persist historical messages older than 30 days.
- All nodes are honest.
- The network is reliable.

Furthermore, it assumes that:

- Control nodes have enough storage to persist historical messages
older than 30 days.
- Control nodes provide archives with historical messages **at least** every 30 days.
- Control nodes receive all community messages.
- Control nodes are honest.
- Control nodes know at least one store node from which it can query historical messages.

These assumptions are less than ideal and will be enhanced in future work.
This [forum discussion](https://forum.vac.dev/t/status-communities-protocol-and-product-point-of-view/114)
provides more details.

## Overview

The following is a high-level overview of the user flow and
features this specification describes.
 For more detailed descriptions, read the dedicated sections in this specification.

### Serving community history archives

Control nodes go through the following
(high level) process to provide community members with message histories:

1. Community owner creates a Status community
(previously known as [org channels](https://github.com/status-im/specs/pull/151))
which makes its node a Control node.
2. Community owner enables message archive capabilities
(on by default but can be turned off as well - see [UI feature spec](https://github.com/status-im/feature-specs/pull/36)).
3. A special type of channel to exchange metadata about the archival data is created,
this channel is not visible in the user interface.
4. Community owner invites community members.
5. Control node receives messages published in channels and
stores them into a local database.
6. Every 7 days, the control node exports and
compresses last 7 days worth of messages from database and
creates a message archive file.
7. It uploads the messsage archive file to a Codex node, producing a CID.
8. It updates the [message archive index](#wakumessagearchiveindex) by adding the new CID
and its metadata, and uploads it to a Codex node as well, producing a CID.
9. Control node sends the CID created in the previous step to community members via
special channel created in step 3 through the Waku network.

### Serving archives for missed messages

If the control node goes offline
(where "offline" means, the control node's main process is no longer running),
it MUST go through the following process:

1. Control node restarts
2. Control node requests messages from store nodes
for the missed time range for all channels in their community
3. All missed messages are stored into control node's local message database
4. If 7 or more days have elapsed since the last message history torrent was created,
the control node will perform step 6 through 9
 of [Serving community history archives](#serving-community-history-archives)
for every 7 days worth of messages in the missed time range
(e.g. if the node was offline for 30 days, it will create 4 message history archives)

### Receiving community history archives

Community member nodes go through the following (high level) process to fetch and
restore community message histories:

1. User joins community and becomes community member (see [org channels spec](../56/communities.md))
2. By joining a community,
member nodes automatically subscribe to special channel for
message archive metadata exchange provided by the community
3. Member node requests live message history
(last 30 days) of all the community channels,
including the special channel from store nodes
4. Member node receives Waku message
([14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md))
that contains the CID of the message archive index file from the special channel
5. Member node extracts the CID from the Waku message and
uses a Codex node to download it
6. Member node interprets the
[message archive index](#message-history-archive-index) file and
determines the CIDs of missing message archives
7. Member node uses a Codex node to download the missing message archive files
8. Member node unpacks and
decompresses message archive data to then hydrate its local database,
deleting any messages,
for that community that the database previously stored in the same time range,
as covered by the message history archive

## Storing live messages

For archival data serving, the control node MUST store live messages as [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md).
This is in addition to their database of application messages.
This is required to provide confidentiality, authenticity,
and integrity of message data distributed via Codex, and
later validated by community members when they unpack message history archives.

Control nodes SHOULD remove those messages from their local databases
once they are older than 30 days and
after they have been turned into message archives and
distributed to the Codex network.

### Exporting messages for bundling

Control nodes export Waku messages from their local database for creating and
bundling history archives using the following criteria:

- Waku messages to be exported MUST have a `contentTopic`
that match any of the topics of the community channels
- Waku messages to be exported MUST have a `timestamp`
that lies within a time range of 7 days

The `timestamp` is determined by the context in which the control node attempts
to create a message history archives as described below:

1. The control node attempts to create an archive periodically
for the past seven days (including the current day).
In this case, the `timestamp` has to lie within those 7 days.
2. The control node has been offline
(control node's main process has stopped and needs restart) and
attempts to create archives for all the live messages it has missed
since it went offline.
In this case,
the `timestamp` has to lie within the day the latest message was received and
the current day.

Exported messages MUST be restored as
[14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md) for bundling.
Waku messages that are older than 30 days and
have been exported for bundling can be removed from the control node's database
(control nodes still maintain a database of application messages).

## Message history archives

Message history archives are represented as `WakuMessageArchive` and
created from Waku messages exported from the local database.
Message history archives are implemented using the following protocol buffer.

### WakuMessageHistoryArchive

The `from` field SHOULD contain a timestamp of the time range's lower bound.
The type parallels the `timestamp` of [WakuMessage](../../waku/standards/core/14/message.md/).

The `to` field SHOULD contain a timestamp of the time range's the higher bound.

The `contentTopic` field MUST contain a list of all communiity channel topics.

The `messages` field MUST contain all messages that belong into the archive
given its `from`, `to` and `contentTopic` fields.

```protobuf
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
}
```

## Message History Archive Index

Control nodes MUST provide message archives for the entire community history.
The entirey history consists of a set of `WakuMessageArchive`'s
where each archive contains a subset of historical `WakuMessage`s
for a time range of seven days.
Each `WakuMessageArchive` is an individual file.

Control nodes MUST create a message history archive index
(`WakuMessageArchiveIndex`) with metadata that allows receiving nodes
to only fetch the message history archives they are interested in.

### WakuMessageArchiveIndex

A `WakuMessageArchiveIndex` is a map where the key is the KECCAK-256 hash of
the `WakuMessageArchiveIndexMetadata` derived from a 7-day archive and
the value is an instance of that `WakuMessageArchiveIndexMetadata`
corresponding to that archive.

The `cid` is the Codex CID by which the message archive can be retrieved.

```protobuf
syntax = "proto3"

message WakuMessageArchiveIndexMetadata {
  uint8 version = 1
  WakuMessageArchiveMetadata metadata = 2
  string cid = 3
}

message WakuMessageArchiveIndex {
  map<string, WakuMessageArchiveIndexMetadata> archives = 1
}
```

The control node MUST update the `WakuMessageArchiveIndex`
every time it creates one or
more `WakuMessageArchive`s, and upload it to Codex. The resulting CID from the upload operation must be sent to the special community channel.
For every created `WakuMessageArchive`,
there MUST be a `WakuMessageArchiveIndexMetadata` entry in the `archives` field `WakuMessageArchiveIndex`.

## Creating message archives

Controls nodes MUST create each message history
archive file, and their index files in a dedicated location on the file system.

Control nodes SHOULD store these files in a dedicated folder that is identifiable,
via the community id.

### Seeding message history archives

The control node MUST ensure that the
[generated archive files](#creating-message-archives) are stored in their Codex node.
The individual archive files must be stored indefinitely.
Only the most recent archive index file must be stored.

The control node SHOULD delete CIDs for older message history archive index files.
Only one archive index file per community should be stored in the Codex node at a time.

### Message archive distribution

Message archives are available via the Codex network as they are being
[seeded by the control node](#seeding-message-history-archives).
Other community member nodes will download the message archives
from the Codex network once they receive a CID
that contains a message archive index.

The control node MUST send CIDs for message archive index files to a special community channel.
The topic of that special channel follows the following format:

```text
/{application-name}/{version-of-the-application}/{content-topic-name}/{encoding}
```

All messages sent with this topic MUST be instances of `ApplicationMetadataMessage`
([62/STATUS-PAYLOADS](../62/payloads.md)) with a `payload` of `CommunityMessageArchiveIndex`.

Only the control node MAY post to the special channel.
Other messages on this specified channel MUST be ignored by clients.
Community members MUST NOT have permission to send messages to the special channel.
However, community member nodes MUST subscribe to special channel
to receive Waku messages containing CIDs for message archives.

### Canonical message histories

Only control nodes are allowed to distribute messages with CIDs via
the special channel for CID exchange.
Community members MUST NOT be allowed to post any messages to the special channel.

Status nodes MUST ensure that any message
that isn't signed by the control node in the special channel is ignored.

Since the CIDs are created from the control node's database
(and previously distributed archives),
the message history provided by the control node becomes the canonical message history
and single source of truth for the community.

Community member nodes MUST replace messages in their local databases
with the messages extracted from archives within the same time range.
Messages that the control node didn't receive MUST be removed and
are no longer part of the message history of interest,
even if it already existed in a community member node's database.

## Fetching message history archives

Generally, fetching message history archives is a three step process:

1. Receive [message archive index](#message-history-archive-index)
CID as described in [Message archive distribution],
download `index` file from Codex, then determine which message archives to download
2. Download individual archives

Community member nodes subscribe to the special channel
that control nodes publish CIDs for message history archives to.
There are two scenarios in which member nodes can receive such a CID message
from the special channel:

1. The member node receives it via live messages, by listening to the special channel
2. The member node requests messages for a time range of up to 30 days
from store nodes (this is the case when a new community member joins a community)

### Downloading message archives

When member nodes receive a message with a `CommunityMessageHistoryArchive`
([62/STATUS-PAYLOADS](../62/payloads.md)) from the aforementioned channnel,
they MUST extract the `cid` and
pass it to their underlying Codex node
so they can fetch the latest message history archive index file,
which is the `index` file to access individual message history archive files (see [Creating message archives](#creating-message-archives)).

Due to the nature of distributed systems,
there's no guarantee that a received message is the "last" message.
This is especially true
when member nodes request historical messages from store nodes.

Therefore, member nodes MUST wait for 20 seconds
after receiving the last `CommunityMessageArchive`
before they start extracting the CID to fetch the latest archive index.

Once a message history archive index is downloaded and
parsed back into `WakuMessageArchiveIndex`,
community member nodes use a local lookup table
to determine which of the listed archives are missing
using the KECCAK-256 hashes stored in the index.

For this lookup to work,
member nodes MUST store the KECCAK-256 hashes
of the `WakuMessageArchiveIndexMetadata` provided by the `index` file
for all of the message history archives that have been downlaoded
in their local database.

Given a `WakuMessageArchiveIndex`,
member nodes can access individual `WakuMessageArchiveIndexMetadata`
to download individual archives.

Community member nodes MUST choose one of the following options:

1. **Download all archives** - Request and
download all CIDs provided by the index file
(this is the case for new community member nodes
that haven't downloaded any archives yet)
2. **Download only the latest archive** -
Request and download only the latest CID in the `WakuMessageArchiveIndexMetadata` list
(this the case for any member node
that already has downloaded all previous history and
is now interested in only the latst archive)
3. **Download specific archives** -
Look into `from` and
`to` fields of every `WakuMessageArchiveIndexMetadata` and
determine the CIDs for archives of a specific time range
(can be the case for member nodes that have recently joined the network and
are only interested in a subset of the complete history)

### Storing historical messages

When message archives are fetched,
community member nodes MUST unwrap the resulting `WakuMessage` instances
into `ApplicationMetadataMessage` instances and store them in their local database.
Community member nodes SHOULD NOT store the wrapped `WakuMessage` messages.

All message within the same time range
MUST be replaced with the messages provided by the message history archive.

Community members nodes MUST ignore the expiration state of each archive message.

## Considerations

The following are things to be considered when implementing this specification.

## Control node honesty

This spec assumes that all control nodes are honest and behave according to the spec.
Meaning they don't inject their own messages into, or
remove any messages from historic archives.

## Bandwidth consumption

Community member nodes will download the latest archive
they've received from the archive index,
which includes messages from the last seven days.
Assuming that community members nodes were online for that time range,
they have already downloaded that message data and
will now download an archive that contains the same.

This means there's a possibility member nodes
will download the same data at least twice.

## Multiple community owners

It is possible for control nodes
to export the private key of their owned community and
pass it to other users so they become control nodes as well.
This means, it's possible for multiple control nodes to exist.

This might conflict with the assumption that the control node
serves as a single source of truth.
Multiple control nodes can have different message histories.

Not only will multiple control nodes
multiply the amount of archive index messages being distributed to the network,
they might also contain different sets of CIDs and their corresponding hashes.

Even if just a single message is missing in one of the histories,
the hashes presented in archive indices will look completely different,
resulting in the community member node to download the corresponding archive
(which might be identical to an archive that was already downloaded,
except for that one message).

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [13/WAKU2-STORE](../../waku/standards/core/13/store.md)
- [10/WAKU2](../../waku/standards/core/10/waku2.md)
- [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md)
- [forum discussion](https://forum.vac.dev/t/status-communities-protocol-and-product-point-of-view/114)
- [org channels](https://github.com/status-im/specs/pull/151)
- [UI feature spec](https://github.com/status-im/feature-specs/pull/36)
- [org channels spec](../56/communities.md)
- [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md)
- [62/STATUS-PAYLOADS](../62/payloads.md)
- [Codex](https://codex.storage)
