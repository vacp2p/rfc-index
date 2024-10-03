---
slug: 19
title: 19/WAKU2-LIGHTPUSH
name: Waku v2 Light Push
status: draft
editor: Hanno Cornelius <hanno@status.im> 
contributors: 
  - Daniel Kaiser <danielkaiser@status.im>
  - Oskar Thorén <oskarth@titanproxy.com>
---

**Protocol identifier**: `/vac/waku/lightpush/2.0.0-beta1`

## Motivation and Goals

Light nodes with short connection windows and
limited bandwidth wish to publish messages into the Waku network.
Additionally,
there is sometimes a need for confirmation
that a message has been received "by the network"
(here, at least one node).

`19/WAKU2-LIGHTPUSH` is a request/response protocol for this.

## Payloads

```protobuf
syntax = "proto3";

message PushRequest {
    string pubsub_topic = 1;
    WakuMessage message = 2;
}

message PushResponse {
    bool is_success = 1;
    // Error messages, etc
    string info = 2;
}

message PushRPC {
    string request_id = 1;
    PushRequest request = 2;
    PushResponse response = 3;
}
```

### Message Relaying

Nodes that respond to `PushRequests` MUST either
relay the encapsulated message via [11/WAKU2-RELAY](../11/relay.md) protocol
on the specified `pubsub_topic`,
or forward the `PushRequest` via 19/LIGHTPUSH on a [WAKU2-DANDELION](https://github.com/waku-org/specs/blob/waku-RFC/standards/application/dandelion.md)
stem.
If they are unable to do so for some reason,
they SHOULD return an error code in `PushResponse`.

## Security Considerations

Since this can introduce an amplification factor,
it is RECOMMENDED for the node relaying to the rest of the network
to take extra precautions.
This can be done by rate limiting via [17/WAKU2-RLN-RELAY](../17/rln-relay.md).

Note that the above is currently not fully implemented.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

* [11/WAKU2-RELAY](../11/relay.md)
* [WAKU2-DANDELION](https://github.com/waku-org/specs/blob/waku-RFC/standards/application/dandelion.md)
* [17/WAKU2-RLN-RELAY](../17/rln-relay.md)
