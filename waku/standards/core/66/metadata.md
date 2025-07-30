---
slug: 66
title: 66/WAKU2-METADATA
name: Waku Metadata Protocol
status: draft
editor: Franck Royer <franck@status.im>
contributors:
  - Filip Dimitrijevic <filip@status.im>
  - Alvaro Revuelta <alrevuelta@status.im>
---

## Abstract

This specification describes the metadata
that can be associated with a [10/WAKU2](/waku/standards/core/10/waku2.md) node.

## Metadata Protocol

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”,
“NOT RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

Waku specifies a req/resp protocol that provides information about the node's capabilities.
Such metadata MAY be used by other peers for subsequent actions such as light protocol requests or disconnection.

The node that makes the request,
includes its metadata so that the receiver is aware of it,
without requiring another round trip.
The parameters are the following:

* `clusterId`: Unique identifier of the cluster that the node is running in.
* `shards`: Shard indexes that the node is subscribed to via [`11/WAKU2-RELAY`](/waku/standards/core/11/relay.md).

***Protocol Identifier***

> /vac/waku/metadata/1.0.0

### Request

```protobuf
message WakuMetadataRequest {
  optional uint32 cluster_id = 1;
  repeated uint32 shards = 2;
}
```

### Response

```protobuf
message WakuMetadataResponse {
  optional uint32 cluster_id = 1;
  repeated uint32 shards = 2;
}
```

## Implementation Suggestions

### Triggering Metadata Request

A node SHOULD proceed with metadata request upon first connection to a remote node.
A node SHOULD use the remote node's libp2p peer id as identifier for this heuristic.

A node MAY proceed with metadata request upon reconnection to a remote peer.

A node SHOULD store the remote peer's metadata information for future reference.
A node MAY implement a TTL regarding a remote peer's metadata, and refresh it upon expiry by initiating another metadata request.
It is RECOMMENDED to set the TTL to 6 hours.

A node MAY trigger a metadata request after receiving an error response from a remote note
stating they do not support a specific cluster or shard.
For example, when using a request-response service such as [`19/WAKU2-LIGHTPUSH`](/waku/standards/core/19/lightpush.md).

### Providing Cluster Id

A node MUST include their cluster id into their metadata payload.
It is RECOMMENDED for a node to operate on a single cluster id.

### Providing Shard Information

- Nodes that mount [`11/WAKU2-RELAY`](/waku/standards/core/11/relay.md) MAY include the shards they are subscribed to in their metadata payload.
- Shard-relevant services are message related services,
  such as [`13/WAKU2-STORE`](/waku/standards/core/13/store.md), [12/WAKU2-FILTER](/waku/standards/core/12/filter.md)
  and [`19/WAKU2-LIGHTPUSH`](/waku/standards/core/19/lightpush.md)
  but not [`34/WAKU2-PEER-EXCHANGE`](/waku/standards/core/34/peer-exchange.md)
- Nodes that mount [`11/WAKU2-RELAY`](/waku/standards/core/11/relay.md) and a shard-relevant service SHOULD include the shards they are subscribed to in their metadata payload.
- Nodes that do not mount [`11/WAKU2-RELAY`](/waku/standards/core/11/relay.md) SHOULD NOT include any shard information

### Using Cluster Id

When reading the cluster id of a remote peer, the local node MAY disconnect if their cluster id is different from the remote peer.

### Using Shard Information

It is NOT RECOMMENDED to disconnect from a peer based on the fact that their shard information is different from the local node.

Ahead of doing a shard-relevant request,
a node MAY use the previously received metadata shard information to select a peer that support the targeted shard.

For non-shard-relevant requests, a node SHOULD NOT discriminate a peer based on medata shard information.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

* [10/WAKU2](/waku/standards/core/10/waku2.md)
