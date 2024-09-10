---
slug: 4
title: 4/MVDS-META
name: MVDS Metadata Field
status: draft
editor: Sanaz Taheri <sanaz@status.im>
contributors:
  - Dean Eigenmann <dean@status.im>
  - Andrea Maria Piana <andreap@status.im>
  - Oskar Thorén <oskarth@titanproxy.com>
---

In this specification, we describe a method to construct message history that
will aid the consistency guarantees of [2/MVDS](../2/mvds.md).
Additionally,
we explain how data sync can be used for more lightweight messages that
do not require full synchronization.

## Motivation

In order for more efficient synchronization of conversational messages,
information should be provided allowing a node to more effectively synchronize
the dependencies for any given message.

## Format

We introduce the metadata message which is used to convey information about a message
and how it SHOULD be handled.

```protobuf
package vac.mvds;

message Metadata {
  repeated bytes parents = 1;
  bool ephemeral = 2;
}
```

Nodes MAY transmit a `Metadata` message by extending the MVDS [message](../2/mvds.md/#payloads)
with a `metadata` field.

```diff
message Message {
  bytes group_id = 6001;
  int64 timestamp = 6002;
  bytes body = 6003;
+ Metadata metadata = 6004;
}
```

### Fields

| Name                   |   Description                                                                                                                    |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| `parents`               |   list of parent [`message identifier`s](../2/mvds.md/#payloads) for the specific message. |
| `ephemeral`         |   indicates whether a message is ephemeral or not.                                                             |

## Usage

### `parents`

This field contains a list of parent [`message identifier`s](../2/mvds.md/#payloads)
for the specific message.
It MUST NOT contain any messages as parent whose `ack` flag was set to `false`.
This establishes a directed acyclic graph (DAG)[^2] of persistent messages.

Nodes MAY buffer messages until dependencies are satisfied for causal consistency[^3],
they MAY also pass the messages straight away for eventual consistency[^4].

A parent is any message before a new message that
a node is aware of that has no children.

The number of parents for a given message is bound by [0, N],
where N is the number of nodes participating in the conversation,
therefore the space requirements for the `parents` field is O(N).

If a message has no parents it is considered a root.
There can be multiple roots, which might be disconnected,
giving rise to multiple DAGs.

### `ephemeral`

When the `ephemeral` flag is set to `false`,
a node MUST send an acknowledgment when they have received and processed a message.
If it is set to `true`, it SHOULD NOT send any acknowledgment.
The flag is `false` by default.

Nodes MAY decide to not persist ephemeral messages,
however they MUST NOT be shared as part of the message history.

Nodes SHOULD send ephemeral messages in batch mode.
As their delivery is not needed to be guaranteed.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## Footnotes

1: [2/MVDS](../2/mvds.md)
2: [directed_acyclic_graph](https://en.wikipedia.org/wiki/Directed_acyclic_graph)
3: Jepsen. [Causal Consistency](https://jepsen.io/consistency/models/causal)
Jepsen, LLC.
4: <https://en.wikipedia.org/wiki/Eventual_consistency>
