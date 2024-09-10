---
slug: 23
title: 23/WAKU2-TOPICS
name: Waku v2 Topic Usage Recommendations
status: draft
category: Informational
editor: Oskar Thoren <oskarth@titanproxy.com>
contributors:
  - Hanno Cornelius <hanno@status.im>
  - Daniel Kaiser <danielkaiser@status.im>
---

This document outlines recommended usage of topic names in Waku v2.
In [10/WAKU2 spec](../../standards/core/10/waku2.md) there are two types of topics:

- pubsub topics, used for routing
- Content topics, used for content-based filtering

## Pubsub Topics

Pubsub topics are used for routing of messages (see [11/WAKU2-RELAY](../../standards/core/11/relay.md)),
and can be named implicitly by Waku sharding (see [RELAY-SHARDING](https://github.com/waku-org/specs/blob/waku-RFC/standards/core/relay-sharding.md)).
This document comprises recommendations for explicitly naming pubsub topics
(e.g. when choosing *named sharding* as specified in [RELAY-SHARDING](https://github.com/waku-org/specs/blob/waku-RFC/standards/core/relay-sharding.md)).

### Pubsub Topic Format

Pubsub topics SHOULD follow the following structure:

`/waku/2/{topic-name}`

This namespaced structure makes compatibility, discoverability,
and automatic handling of new topics easier.

The first two parts indicate

1) it relates to the Waku protocol domain, and
2) the version is 2.

If applicable, it is RECOMMENDED to structure `{topic-name}`
in a hierarchical way as well.

> *Note*: In previous versions of this document, the structure was `/waku/2/{topic-name}/{encoding}`.
The now deprecated `/{encoding}` was always set to `/proto`,
which indicated that the [data field](../../standards/core/11/RELAY.md/#protobuf-definition)
in pubsub is serialized/encoded as protobuf.
The inspiration for this format was taken from
[Ethereum 2 P2P spec](https://github.com/ethereum/eth2.0-specs/blob/dev/specs/phase0/p2p-interface.md#topics-and-messages).
However, because the payload of messages transmitted over [11/WAKU2-RELAY](../../standards/core/11/relay.md)
must be a [14/WAKU2-MESSAGE](../../standards/core/14/message.md),
which specifies the wire format as protobuf,`/proto` is the only valid encoding.
This makes the `/proto` indication obsolete.
The encoding of the `payload` field of a Waku Message
is indicated by the `/{encoding}` part of the content topic name.
Specifying an encoding is only significant for the actual payload/data field.
Waku preserves this option by allowing to specify an encoding
for the WakuMessage payload field as part of the content topic name.

### Default PubSub Topic

The Waku v2 default pubsub topic is:

`/waku/2/default-waku/proto`

The `{topic name}` part is `default-waku/proto`,
which indicates it is default topic for exchanging WakuMessages;
`/proto` remains for backwards compatibility.

### Application Specific Names

Larger apps can segregate their pubsub meshes using topics named like:

```text
/waku/2/status/
/waku/2/walletconnect/
```

This indicates that these networks carry WakuMessages,
but for different domains completely.

### Named Topic Sharding Example

The following is an example of named sharding, as specified in [RELAY-SHARDING](https://github.com/waku-org/specs/blob/waku-RFC/standards/core/relay-sharding.md).

```text
waku/2/waku-9_shard-0/
...
waku/2/waku-9_shard-9/
```

This indicates explicitly that the network traffic has been partitioned into 10 buckets.

## Content Topics

The other type of topic that exists in Waku v2 is a content topic.
This is used for content based filtering.
See [14/WAKU2-MESSAGE spec](../../standards/core/14/message.md)
for where this is specified.
Note that this doesn't impact routing of messages between relaying nodes,
but it does impact how request/reply protocols such as
[12/WAKU2-FILTER](../../standards/core/12/filter.md) and
[13/WAKU2-STORE](../../standards/core/13/store.md) are used.

This is especially useful for nodes that have limited bandwidth,
and only want to pull down messages that match this given content topic.

Since all messages are relayed using the relay protocol regardless of content topic,
you MAY use any content topic you wish without impacting how messages are relayed.

### Content Topic Format

The format for content topics is as follows:

`/{application-name}/{version-of-the-application}/{content-topic-name}/{encoding}`

The name of a content topic is application-specific.
As an example, here's the content topic used for an upcoming testnet:

`/toychat/2/huilong/proto`

### Content Topic Naming Recommendations

Application names should be unique to avoid conflicting issues with other protocols.
Applications should specify their version (if applicable) in the version field.
The `{content-topic-name}` portion of the content topic is up to the application,
and depends on the problem domain.
It can be hierarchical, for instance to separate content, or
to indicate different bandwidth and privacy guarantees.
The encoding field indicates the serialization/encoding scheme
for the [WakuMessage payload](../../standards/core/14/message.md/#payloads) field.

## Differences with Waku v1

In [5/WAKU1](../../deprecated/5/waku0.md) there is no actual routing.
All messages are sent to all other nodes.
This means that we are implicitly using the same pubsub topic
that would be something like:

```text
/waku/1/default-waku/rlp
```

Topics in Waku v1 correspond to Content Topics in Waku v2.

### Bridging Waku v1 and Waku v2

To bridge Waku v1 and Waku v2 we have a [15/WAKU-BRIDGE](../../standards/core/15/bridge.md).
For mapping Waku v1 topics to Waku v2 content topics,
the following structure for the content topic SHOULD be used:

```text
/waku/1/<4bytes-waku-v1-topic>/rfc26
```

The `<4bytes-waku-v1-topic>` SHOULD be the lowercase hex representation
of the 4-byte Waku v1 topic.
A `0x` prefix SHOULD be used.
`/rfc26` indicates that the bridged content is encoded according to RFC [26/WAKU2-PAYLOAD](../../standards/application/26/payload.md).
See [15/WAKU-BRIDGE](../../standards/core/15/bridge.md) for a description
of the bridged fields.

This creates a direct mapping between the two protocols.
For example:

```text
/waku/1/0x007f80ff/rfc26
```

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [10/WAKU2 spec](../../standards/core/10/waku2.md)
- [11/WAKU2-RELAY](../../standards/core/11/relay.md)
- [RELAY-SHARDING](https://github.com/waku-org/specs/blob/waku-RFC/standards/core/relay-sharding.md)
- [Ethereum 2 P2P spec](https://github.com/ethereum/eth2.0-specs/blob/dev/specs/phase0/p2p-interface.md#topics-and-messages)
- [14/WAKU2-MESSAGE](../../standards/core/14/message.md)
- [12/WAKU2-FILTER](../../standards/core/12/filter.md)
- [13/WAKU2-STORE](../../standards/core/13/store.md)
- [6/WAKU1](../../deprecated/5/waku0.md)
- [15/WAKU-BRIDGE](../../standards/core/15/bridge.md)
- [26/WAKU-PAYLOAD](../../standards/application/26/payload.md)
