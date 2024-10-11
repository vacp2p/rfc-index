---
title: STATUS-WAKU2-USAGE
name: Status Waku2 Usage
status: raw
category: Best Current Practice
description: Defines how the Status application uses the Waku protocols.
editor: Aaryamann Challani <p1ge0nh8er@proton.me>
contributors: 
- Jimmy Debe <jimmy@status.im>

---

## Abstract

Status is a chat application which has several features,
including, but not limited to -

- Private 1:1 chats, described by [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
- Large scale group chats, described by [56/STATUS-COMMUNITIES](../56/communities.md)

This specification describes how a Status implementation will make use of
the underlying infrastructure, Waku,
which is described in [10/WAKU2](../../waku/standards/core/10/waku2.md).

## Background

The Status application aspires to achieve censorship resistance and
incorporates specific privacy features,
leveraging the comprehensive set of protocols offered by Waku to enhance these attributes.
Waku protocols provide secure communication capabilities over decentralized networks.
Once integrated, an application will benefit from privacy-preserving,
censorship resistance and spam protected communcation.

Since Status uses a large set of Waku protocols,
it is imperative to describe how each are used.

## Terminology

| Name  | Description |
| --------------- | --------- |
| `RELAY`| This refers to the Waku Relay protocol, described in [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md) |
| `FILTER` | This refers to the Waku Filter protocol, described in [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md) |
| `STORE` | This refers to the Waku Store protocol, described in [13/WAKU2-STORE](../../waku/standards/core/13/store.md) |
| `MESSAGE` | This refers to the Waku Message format, described in [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md) |
| `LIGHTPUSH` | This refers to the Waku Lightpush protocol, described in [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md) |
| Discovery | This refers to a peer discovery method used by a Waku node. |
| `Pubsub Topic` / `Content Topic` | This refers to the routing of messages within the Waku network, described in [23/WAKU2-TOPICS](../../waku/informational/23/topics.md) |

### Waku Node

Software that is configured with a set of Waku protocols.
A Status client comprises of a Waku node that is a `RELAY` node or a non-relay node.

### Light Client

A Status client that operates within resource constrained environments
is a node configured as light client.
Light clients do not run a `RELAY`.
Instead, Status light clients,
can request services from other `RELAY` node that provide `LIGHTPUSH` service.

## Protocol Usage

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

The following is a list of Waku Protocols used by a Status application.

### 1. `RELAY`

The `RELAY` MUST NOT be used by Status light clients.
The `RELAY` is used to broadcast messages between Status clients.
All Status messages are transformed into [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md),
which are sent over the wire.

All Status message types are described in [62/STATUS-PAYLOADS](../62/payloads.md).
Status Clients MUST transform the following object into a `MESSAGE`
as described below -

```go

type StatusMessage struct {
    SymKey[]     []byte // [optional] The symmetric key used to encrypt the message
    PublicKey    []byte // [optional] The public key to use for asymmetric encryption
    Sig          string // [optional] The private key used to sign the message
    PubsubTopic  string // The Pubsub topic to publish the message to     
    ContentTopic string // The Content topic to publish the message to
    Payload      []byte // A serialized representation of a Status message to be sent
    Padding      []byte // Padding that must be applied to the Payload
    TargetPeer   string // [optional] The target recipient of the message
    Ephemeral    bool   // If the message is not to be stored, this is set to `true` 
}

```

1. A user MUST only provide either a Symmetric key OR
an Asymmetric keypair to encrypt the message.
If both are received, the implementation MUST throw an error.
2. `WakuMessage.Payload` MUST be set to `StatusMessage.Payload`
3. `WakuMessage.Key` MUST be set to `StatusMessage.SymKey`
4. `WakuMessage.Version` MUST be set to `1`
5. `WakuMessage.Ephemeral` MUST be set to `StatusMessage.Ephemeral`
6. `WakuMessage.ContentTopic` MUST be set to `StatusMessage.ContentTopic`
7. `WakuMessage.Timestamp` MUST be set to the current Unix epoch timestamp
(in nanosecond precision)

### 2. `STORE`

This protocol MUST remain optional according to the user's preferences,
it MAY be enabled on Light clients as well.

Messages received via [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md), are stored in a database.
When Waku node running this protocol is service node,
it MUST provide the complete list of network messages.
Status clients SHOULD request historical messages from this service node.

The messages that have the `WakuMessage.Ephemeral` flag set to true will not be stored.

The Status client MAY provide a method to prune the database of
older records to save storage.

### 3. `FILTER`

This protocol SHOULD be enabled on Light clients.

This protocol SHOULD be used to filter messages based on a given criteria,
such as the `Content Topic` of a `MESSAGE`.
This allows a reduction in bandwidth consumption by the Status client.

#### Content filtering protocol identifers

The `filter-subcribe` SHOULD be implemented on `RELAY` nodes
to provide `FILTER` services.

`filter-subscribe`:

> /vac/waku/filter-subscribe/2.0.0-beta1

The `filter-push` SHOULD be implemented on light clients to receive messages.

`filter-push`:

> /vac/waku/filter-push/2.0.0-beta1

Status clients SHOULD apply a filter for all the `Content Topic`
they are interested in, such as `Content Topic` derived from -

1. 1:1 chats with other users, described in [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
2. Group chats
3. Community Channels, described in [56/STATUS-COMMUNITIES](../56/communities.md)

### 4. `LIGHTPUSH`

The `LIGHTPUSH` protocol MUST be enabled on Status light clients.
A Status `RELAY` node MAY implement `LIGHTPUSH` to support light clients.
Peers will be able to publish messages,
without running a full-fledged [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md) protocol.

When a Status client is publishing a message,
it MUST check if Light mode is enabled,
and if so, it MUST publish the message via this protocol.

### 5. Discovery

A discovery method MUST be supported by Light clients and Full clients

Status clients SHOULD make use of the following peer discovery methods
that are provided by Waku, such as -

1. [EIP-1459: DNS-Based Discovery](https://eips.ethereum.org/EIPS/eip-1459)
2. [33/WAKU2-DISCV5](../../waku/standards/core/33/discv5.md): A node discovery protocol to
create decentralized network of interconnected Waku nodes.
3. [34/WAKU2-PEER-EXCHANGE](../../waku/standards/core/34/peer-exchange.md):
A peer discovery protocol for resource restricted devices.

Status clients MAY use any combination of the above peer discovery methods,
which is suited best for their implementation.

## Security/Privacy Considerations

This specification inherits the security and
privacy considerations from the following specifications -

1. [10/WAKU2](../../waku/standards/core/10/waku2.md)
2. [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md)
3. [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md)
4. [13/WAKU2-STORE](../../waku/standards/core/13/store.md)
5. [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md)
6. [23/WAKU2-TOPICS](../../waku/informational/23/topics.md)
7. [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md)
8. [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
9. [56/STATUS-COMMUNITIES](../56/communities.md)
10. [62/STATUS-PAYLOADS](../62/payloads.md)
11. [EIP-1459: DNS-Based Discovery](https://eips.ethereum.org/EIPS/eip-1459)
12. [33/WAKU2-DISCV5](../../waku/standards/core/33/discv5.md)
13. [34/WAKU2-PEER-EXCHANGE](../../waku/standards/core/34/peer-exchange.md)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
2. [56/STATUS-COMMUNITIES](../56/communities.md)
3. [10/WAKU2](../../waku/standards/core/10/waku2.md)
4. [11/WAKU2-RELAY](../../waku/standards/core/11/relay.md)
5. [12/WAKU2-FILTER](../../waku/standards/core/12/filter.md)
6. [13/WAKU2-STORE](../../waku/standards/core/13/store.md)
7. [14/WAKU2-MESSAGE](../../waku/standards/core/14/message.md)
8. [23/WAKU2-TOPICS](../../waku/informational/23/topics.md)
9. [19/WAKU2-LIGHTPUSH](../../waku/standards/core/19/lightpush.md)
10. [64/WAKU2-NETWORK](../../waku/standards/core/64/network.md)
11. [62/STATUS-PAYLOADS](../62/payloads.md)
12. [EIP-1459: DNS-Based Discovery](https://eips.ethereum.org/EIPS/eip-1459)
13. [33/WAKU2-DISCV5](../../waku/standards/core/33/discv5.md)
14. [34/WAKU2-PEER-EXCHANGE](../../waku/standards/core/34/peer-exchange.md)
