---
title: STATUS-PROTOCOLS
name: Status Protocol Stack
status: raw
category: Standards Track
description: Specifies the Status application protocol stack
editor: Hanno Cornelius <hanno@status.im>
contributors: 
- Jimmy Debe <jimmy@status.im>
- Aaryamann Challani <p1ge0nh8er@proton.me>

---

## Abstract

This specification describes the Status Application protocol stack.
It focuses on elements and features in the protocol stack for all application-level functions:
- functional scope (also _broadcast audience_)
- content topic
- ephemerality
- end-to-end reliability layer
- encryption layer
- transport layer (Waku)

It also introduces strategies to restrict resource usage, distribute large messages, etc.
Application-level functions are out of scope and specified separately. See:
- [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
- [56/STATUS-COMMUNITIES](../56/communities.md)

## Status protocol stack

See the simplified diagram of the Status application protocol stack:

|  |
|---|
| Status application layer  | 
| End-to-end reliability layer  | 
| Encryption layer |
| Transport layer (Waku) |
| |

## Status application layer

Application level functions are defined in the _application_ layer.
Status currently defines functionality to support three main application features:
- Status Communities, as specified in [56/STATUS-COMMUNITIES](../56/communities.md)
- Status 1:1 Chat, as specified in [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
- Status Private Group Chat, as specified in a subsection of [55/STATUS-1TO1-CHAT](../55/1to1-chat.md#negotiation-of-a-11-chat-amongst-multiple-participants-group-chat)

<!-- TODO: list functions not related to main app features, such as user sync, backup, push notifications, etc. -->

Each application-level function, regardless which feature set it supports, has the following properties:
1. Functional scope
2. Content topic
3. Ephemerality

### Functional Scope

Each Status app-level message MUST define a functional scope.
The functional scope MUST define the _minimum_ scope of the audience that should _participate_ in the app function the message is related to.
In other words, it determines the minimum subset of Status app participants
that should have access to messages related to that function.

Note that the functional scope is distinct from the number of participants that is _addressed_ by a specific message.
For example, a participant will address a 1:1 chat to only one other participant.
However, since all users of the Status app MUST be able to participate in 1:1 chats,
the functional scope of messages enabling 1:1 chats MUST be a global scope.
Similarly, since private group chats can be set up between any subset of Status app users,
the functional scope for messages related to private group chats MUST be global.
As a counter-example, messages that originate within a community (and are _addressed_ to members of that community)
are only of interest to participants that are also members of that community.
Such messages MUST have a community-wide functional scope.
A third group of messages are addressed only to the participant that generated those messages itself.
These _self-addressed_ messages MUST have a local functional scope.

If we further make a distinction between "control" and "content" messages,
we can distinguish five distinct functional scopes.

All Status messages MUST have one of these functional scopes:

#### Global scope

1. _Global control_: messages enabling the basic functioning of the app to control features that all app users should be able to participate in. Examples include Contact Requests, Community Invites, global Status Updates, Group Chat Invites, etc.
2. _Global content_: messages carrying user-generated content for global functions. Examples include 1:1 chat messages, images shared over private group chats, etc.

#### Community scope

3. _Community control_: messages enabling the basic functioning of the app to control features _only relevant to members of a specific community_. Examples include Community Membership Updates, community Status Updates, etc.
4. _Community content_: messages carrying user-generated content _only for members of a specific community_.

#### Local scope

5. _Local_: messages related to functions that are only relevant to a single user. Also known as _self-addressed messages_. Examples include messages used to exchange information between app installations, such as User Backup and Sync messages.

Note that the functional scope is a logical property of Status messages.
It SHOULD however inform the underlying [transport layer sharding](#pubsub-topics-and-sharding) and [transport layer subscriptions](#subscribing).
In general a Status client SHOULD subscribe to participate in:
- all global functions,
- (only) the community functions for communities of which it is a member, and
- its own local functions.

### Content topics

Each Status app-level message MUST define a content topic that links messages in related app-level functions and sub-functions together.
This MUST be based on the filter use cases for [transport layer subscriptions](#subscribing)
and [retrieving historical messages](#retrieving-historical-messages).
A content topic SHOULD be identical across all messages that are always part of the same filter use case (or always form part of the same content-filtered query criteria).
In other words, the number of content topics defined in the app SHOULD match the number of filter use cases.
For the sake of illustration, consider the following common content topic and filter use cases:
- if all messages belonging to the same 1:1 chat are always filtered together, they SHOULD use the same content topic (see [55/STATUS-1TO1-CHAT](../55/1to1-chat.md))
- if all messages belonging to the same Community are always filtered together, they SHOULD use the same content topic (see [56/STATUS-COMMUNITIES](../56/communities.md)).

The app-level content topic MUST be populated in the `content_topic` field in the encapsulating Waku message (see [Waku messages](#waku-messages)).

### Ephemerality

Each Status app-level message MUST define its _ephemerality_.
Ephemerality is a boolean value, set to `true` if a message is considered ephemeral.
Ephemeral messages are messages emitted by the app that are transient in nature.
They only have temporary "real-time" value
and SHOULD NOT be stored and retrievable from historical message stores and sync caches.
Similarly, ephemeral message delivery is best-effort in nature and SHOULD NOT be considered in message reliability mechanisms (see [End-to-end reliability layer](#end-to-end-reliability-layer)).

An example of ephemeral messages would be periodic status update messages, indicating a particular user's online status.
Since only a user's current online status is of value, there is no need to store historical status update messages.
Since status updates are periodic, there is no strong need for end-to-end reliability as subsequent updates are always to follow.

App-level messages that are considered ephemeral, MUST set the `ephemeral` field in the encapsulating Waku message to `true` (see [Waku messages](#waku-messages))

## End-to-end reliability layer

The end-to-end reliability layer contains the functions related to one of the two end-to-end reliability schemes defined for Status app messages:
1. Minimum Viable protocol for Data Synchronisation, or MVDS (see [STATUS-MVDS-USAGE](./status-mvds.md))
2. Scalable distributed log reliability (spec and a punchier name TBD, see the [original forum post announcement](https://forum.vac.dev/t/end-to-end-reliability-for-scalable-distributed-logs/293/16))

Ephemeral messages SHOULD omit this layer.
Non-ephemeral 1:1 chat messages SHOULD make use of MVDS to achieve reliable data synchronisation between the two parties involved in the communication.
Non-ephemeral private group chat messages build on a set of 1:1 chat links
and consequently SHOULD also make use of MVDS to achieve reliable data synchronisation between all parties involved in the communication.
Non-ephemeral 1:1 and private group chat messages MAY make use of of [scalable distributed log reliability](https://forum.vac.dev/t/end-to-end-reliability-for-scalable-distributed-logs/293/16) in future.
Since MVDS does not scale for large number of participants in the communication,
non-ephemeral community messages MUST use scalable distributed log reliability as defined in this [original forum post announcement](https://forum.vac.dev/t/end-to-end-reliability-for-scalable-distributed-logs/293/16).
The app MUST use a single channel ID per community.

## Encryption layer

The encryption layer wraps the Status App and Reliability layers in an encrypted payload.

<!-- TODO: This section is TBD. We may want to design a way for Communities to use de-MLS in a separate spec and generally simplify Status encryption. -->

## Waku transport layer

The Waku transport layer contains the functions allowing Status protocols to use [10/WAKU2](../../waku/standards/core/10/waku2.md) infrastructure as transport.

### Waku messages

Each Status application message MUST be transformed to a [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md) with the following structure:

```protobuf
syntax = "proto3";

message WakuMessage {
  bytes payload = 1;
  string content_topic = 2;
  optional uint32 version = 3;
  optional sint64 timestamp = 10;
  optional bytes meta = 11;
  optional bool ephemeral = 31;
}
```

- `payload` MUST be set to the full encrypted payload received from the higher layers
- `version` MUST be set to `1`
- `ephemeral` MUST be set to `true` if the app-level message is ephemeral
- `content_topic` MUST be set to the app-level content topic
- `timestamp` MUST be set to the current Unix epoch timestamp (in nanosecond precision)

### Pubsub topics and sharding

All Waku messages are published to pubsub topics as defined in [23/WAKU2-TOPICS](../../waku/informational/23/topics.md).
Since pubsub topics define a routing layer for messages,
they can be used to shard traffic.
The pubsub topic used for publishing a message depends on the app-level [functional scope](#functional-scope).

#### Self-addressed messages

The application MUST define at least one distinct pubsub topic for self-addressed messages.
The application MAY define a set of more than one pubsub topic for self-addressed messages to allow traffic sharding for scalability.

#### Global messages

The application MUST define at least one distinct pubsub topic for global control messages and global content messages.
The application MAY defined a set of more than one pubsub topic for global messages to allow traffic sharding for scalability.
It is RECOMMENDED that separate pubsub topics be used for global control messages and global content messages.

#### Community messages

The application SHOULD define at least one separate pubsub topic for each separate community's control and content messages.
The application MAY define a set of more than one pubsub topic per community to allow traffic sharding for scalability.
It is RECOMMENDED that separate pubsub topics be used for community control messages and community content messages.

#### Large messages

The application MAY define separate pubsub topics for large messages.
These pubsub topics for large messages MAY be distinct for each functional scope.

### Resource usage

The application SHOULD use a range of Waku protocols to interact with the Waku transport layer.
The specific set of Waku protocols used depend on desired functionality and resource usage profile for the specific client.
Resources can be restricted in terms of bandwidth and computing resources.

Waku protocols that are more appropriate for resource-restricted environments are often termed "light protocols".
Waku protocols that consume more resources, but simultaneously contribute more to Waku infrastructure, are often termed "full protocols".
The terms "full" and "light" is just a useful abstraction than a strict binary, though,
and Status clients can operate along a continuum of resource usage profiles,
each using the combination of "full" and "light" protocols most appropriate to match its environment and motivations.

To simplify interaction with the selection of "full" and "light" protocols,
Status clients MUST define a "full mode" and "light mode"
to allow users to select whether their client would prefer "full protocols" or "light protocols" by default.
Status Desktop clients are assumed to have more resources available and SHOULD use full mode by default.
Status Mobile clients are assumed to operate with more resource restrictions and SHOULD use light mode by default.

For the purposes of the rest of this document,
clients in full mode will be referred to as "full clients" and
clients in light mode will be referred to as "light clients".

### Subscribing

The application MUST subscribe to receive the traffic necessary for minimal app operation
and to enable the user functions specific to that instance of the application.

The specific Waku protocol used for subscription depends on the resource-availability of the client:
1. Filter client protocol, as specified in [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md), allows subscribing for traffic with content topic granularity and is appropriate for resource-restricted subscriptions.
2. Relay protocol, as specified in [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md), allows subscribing to traffic only with pubsub topic granularity and therefore is more resource-intensive. Relay subscription also allows the application instance to contribute to the overall routing infrastructure, which adds to its overall higher resource usage but benefits the ecosystem.

Full clients SHOULD prefer relay protocol to subscribe to pubsub topics matching the scopes:
1. Global control
2. Global content
3. Community control, for each community of which the app user is a member
4. Community content, for each community of which the app user is a member

Light clients SHOULD use filter protocol to subscribe only to the content topics relevant to the user.

#### Self-addressed messages

Status clients (full or light) MUST NOT subscribe to topics for messages with self-addressed scopes.
See [Self-addressed messages](#self-addressed-messages-4).

#### Large messages

Status clients (full or light) SHOULD NOT subscribe to topics set aside for large messages.
See [Large messages](#large-messages-4).

### Publishing

The application MUST publish user and app generated messages via the Waku transport layer.
The specific Waku protocol used for publishing depends on the resource-availability of the client:
1. Lightpush protocol, as specified in [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md) allows publishing to a pubsub topic via an intermediate "full node" and is more appropriate for resource-restricted publishing.
2. Relay protocol, as specified in [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md), allows publishing directly into the relay routing network and is therefore more resource-intensive.

Full clients SHOULD use relay protocol to publish to pubsub topics matching the scopes:
1. Global control
2. Global content
3. Community control, for each community of which the app user is a member
4. Community content, for each community of which the app user is a member

Light clients SHOULD use lightpush protocol to publish control and content messages.

#### Self-addressed messages

Status clients (full or light) MUST use lightpush protocol to publish self-addressed messages.
See [Self-addressed messages](#self-addressed-messages-4).

#### Large messages

Status clients (full or light) SHOULD use lightpush protocols to publish to pubsub topics set aside for large messages.
See [Large messages](#large-messages-4).

### Retrieving historical messages

Status clients SHOULD use the store query protocol, as specified in [WAKU2-STORE](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md), to retrieve historical messages relevant to the client from store service nodes in the network.

Status clients SHOULD use [content filtered queries](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md#content-filtered-queries) with `include_data` set to `true`,
to retrieve the full contents of historical messages that the client may have missed during offline periods,
or to populate the local message database when the client starts up for the first time.

#### Store queries for reliability

Status clients MAY use periodic content filtered queries with `include_data` set to `false`,
to retrieve only the message hashes of past messages on content topics relevant to the client.
This can be used to compare the hashes available in the local message database with the hashes in the query response
in order to identify possible missing messages.
Once the Status client has identified a set of missing message hashes
it SHOULD use [message hash lookup queries](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md#message-hash-lookup-queries) with `include_data` set to `true`
to retrieve the full contents of the missing messages based on the hash.

Status clients MAY use [presence queries](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md#presence-queries)
to determine if one or more message hashes known to the client is present in the store service node.
Clients MAY use this method to determine if a message that originated from the client
has been successfully stored.

#### Self-addressed messages

Status clients (full or light) SHOULD use store queries (rather than subscriptions) to retrieve self-addressed messages relevant to that client.
See [Self-addressed messages](#self-addressed-messages-4).

#### Large messages

Status clients (full or light) SHOULD use store queries (rather than subscriptions) to retrieve large messages relevant to that client.
See [Large messages](#large-messages-4).

### Providing services

Status clients MAY provide service-side protocols to other clients.

Full clients SHOULD mount
the filter service protocol (see [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md))
and lightpush service protocol (see [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md))
in order to provide light subscription and publishing services to other clients 
for each pubsub topic to which they have a relay subscription.

Status clients MAY mount the store query protocol as service node (see [WAKU2-STORE](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md))
to store historical messages and
provide store services to other clients
for each pubsub topic to which they have a relay subscription

### Self-addressed messages

Messages with a _local_ functional scope (see [Functional scope](#functional-scope)),
also known as _self-addressed_ messages,
MUST be published to a distinct pubsub topic or a distinct _set_ of pubsub topics
used exclusively for messages with local scope (see [Pubsub topics and sharding](#pubsub-topics-and-sharding)).
Status clients (full or light) MUST use lightpush protocol to publish self-addressed messages (see [Publishing](#publishing)).
Status clients (full or light) MUST NOT subscribe to topics for messages with self-addressed scopes (see [Subscribing](#subscribing)).
Status clients (full or light) SHOULD use store queries (rather than subscriptions) to retrieve self-addressed messages relevant to that client (see [Retrieving historical messages](#retrieving-historical-messages)).

### Large messages

The application MAY define separate pubsub topics for large messages.
These pubsub topics for large messages MAY be distinct for each functional scope (see [Pubsub topics and sharding](#pubsub-topics-and-sharding)).
Status clients (full or light) SHOULD use lightpush protocols to publish to pubsub topics set aside for large messages (see [Publishing](#publishing)).
Status clients (full or light) SHOULD NOT subscribe to topics set aside for large messages (see [Subscribing](#subscribing)).
Status clients (full or light) SHOULD use store queries (rather than subscriptions) to retrieve large messages relevant to that client (see [Retrieving historical messages](#retrieving-historical-messages)).

#### Chunking

The Status application MAY use a chunking mechanism to break down large payloads
into smaller segments for individual Waku transport.
The definition of a large message is up to the application.
However, the maximum size for a [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md) payload is 150KB.
Status application payloads that exceed this size MUST be chunked into smaller pieces
and MUST be considered a "large message".

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
2. [56/STATUS-COMMUNITIES](../56/communities.md)
3. [10/WAKU2](../../waku/standards/core/10/waku2.md)
4. [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md)
5. [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md)
6. [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md)
7. [23/WAKU2-TOPICS](../../waku/informational/23/topics.md)
8. [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md)
9. [Scalable distributed log reliability](https://forum.vac.dev/t/end-to-end-reliability-for-scalable-distributed-logs/293/16)
10. [STATUS-MVDS-USAGE](./status-mvds.md)
11. [WAKU2-STORE](https://github.com/waku-org/specs/blob/8fea97c36c7bbdb8ddc284fa32aee8d00a2b4467/standards/core/store.md)

