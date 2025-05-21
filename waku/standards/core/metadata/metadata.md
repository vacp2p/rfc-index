---
slug: 66
title: 66/WAKU2-METADATA
name: Waku Metadata Protocol
status: draft
editor: Alvaro Revuelta <alrevuelta@status.im>
contributors:
 - Filip Dimitrijevic <filip@status.im>
---

## Abstract

This specification describes the metadata
that can be associated with a [10/WAKU2](/waku/standards/core/10/waku2.md) node.

## Metadata Protocol

Waku specifies a req/resp protocol that provides information about the node's medatadata.
Such metadata is meant to be used by the node to decide if a peer is worth connecting
or not.
The node that makes the request,
includes its metadata so that the receiver is aware of it,
without requiring an extra interaction.
The parameters are the following:

* `clusterId`: Unique identifier of the cluster that the node is running in.
* `shards`: Shard indexes that the node is subscribed to.

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

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

* [10/WAKU2](/waku/standards/core/10/waku2.md)
