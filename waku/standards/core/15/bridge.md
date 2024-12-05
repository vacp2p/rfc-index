---
slug: 15
title: 15/WAKU-BRIDGE
name: Waku Bridge
status: draft
tags: waku-core
editor: Hanno Cornelius <hanno@status.im>
---

## Abstract

This specification describes how [6/WAKU1](/waku/standards/legacy/6/waku1.md)
can be used with [10/WAKU2](/waku/standards/core/10/waku2.md).

## Wire Format

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

A bridge requires supporting both Waku versions:

* [6/WAKU1](/waku/standards/legacy/6/waku1.md) - using devp2p RLPx protocol
* [10/WAKU2](/waku/standards/core/10/waku2.md) - using libp2p protocols

## Publishing Packets

Packets received on the [6/WAKU1](/waku/standards/legacy/6/waku1.md) network
SHOULD be published just once on the [10/WAKU2](/waku/standards/core/10/waku2.md).
More specifically, the bridge SHOULD publish
this through the [11/WAKU2-RELAY](/waku/standards/core/11/relay.md) (PubSub domain).

When publishing such packet,
the creation of a new `Message` with a new `WakuMessage` as data field is REQUIRED.
The `data` and
`topic` field, from the [6/WAKU1](/waku/standards/legacy/6/waku1.md) `Envelope`,
MUST be copied to the `payload` and `content_topic` fields of the `WakuMessage`.
See [14/WAKU2-MESSAGE](/waku/standards/core/14/message.md#wire-format)
for message format details.
Other fields such as `nonce`, `expiry` and
`ttl` will be dropped as they become obsolete in [10/WAKU2](/waku/standards/core/10/waku2.md).

Before this is done, the usual envelope verification still applies:

* Expiry & future time verification
* PoW verification
* Size verification

Bridging SHOULD occur through the [11/WAKU2-RELAY](/waku/standards/core/11/relay.md),
but it MAY also be done on other [10/WAKU2](/waku/standards/core/10/waku2.md) protocols
(e.g. [12/WAKU2-FILTER](/waku/standards/core/12/filter.md)).
The latter is however not advised as it will
increase the complexity of the bridge and
because of the [Security Considerations](#security-considerations) explained further below.

Packets received on the [64/WAKU2-NETWORK](/waku/standards/core/64/network.md),
SHOULD be posted just once on the [6/WAKU1](/waku/standards/legacy/6/waku1.md) network.
The [14/WAKU2-MESSAGE](/waku/standards/core/14/message.md) contains only the `payload` and
`contentTopic` fields.
The bridge MUST create a new [6/WAKU1](/waku/standards/legacy/6/waku1.md) `Envelope` and
copy over the `payload` and `contentFilter`
fields to the `data` and `topic` fields.
Next, before posting on the network,
the bridge MUST set a new `expiry`, `ttl` and do the PoW `nonce` calculation.

### Security Considerations

As mentioned above,
a bridge will be posting new [6/WAKU1](/waku/standards/legacy/6/waku1.md) envelopes,
which requires doing the PoW `nonce` calculation.

This could be a DoS attack vector,
as the PoW calculation will make it more expensive to post the message
compared to the original publishing on the [64/WAKU2-NETWORK](/waku/standards/core/64/network.md).
Low PoW setting will lower this problem,
but it is likely that it is still more expensive.

For this reason, it is RECOOMENDED to run bridges independently of other nodes,
so that a bridge that gets overwhelmed does not disrupt regular Waku v2 to v2
traffic.

Bridging functionality SHOULD also be carefully implemented so that messages do
not bounce back and forth between the two networks.
The bridge SHOULD properly track messages with a seen filter,
so that no amplification can be achieved here.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

* [6/WAKU1](/waku/standards/legacy/6/waku1.md)
* [10/WAKU2](/waku/standards/core/10/waku2.md)
* [11/WAKU2-RELAY](/waku/standards/core/11/relay.md)
* [14/WAKU2-MESSAGE](/waku/standards/core/14/message.md)
* [12/WAKU2-FILTER](/waku/standards/core/12/filter.md)
* [64/WAKU2-NETWORK](/waku/standards/core/64/network.md)
