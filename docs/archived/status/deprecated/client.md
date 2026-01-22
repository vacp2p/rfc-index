# CLIENT

| Field | Value |
| --- | --- |
| Name | Client |
| Slug | 123 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |
| Contributors | Adam Babik <adam@status.im>, Andrea Maria Piana <andreap@status.im>, Dean Eigenmann <dean@status.im>, Corey Petty <corey@status.im>, Oskar Thorén <oskar@status.im>, Samuel Hawksby-Robinson <samuel@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/client.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/deprecated/client.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/client.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/client.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/client.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/client.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/client.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This specification describes how to write a Status client for communicating  
with other Status clients.  
This specification presents a reference implementation of the protocol
used in a command-line client and a mobile app.

This document consists of two parts.  
The first outlines the specifications required to be a full Status client.  
The second provides a design rationale and answers some common questions.

## Introduction

### Protocol layers

Implementing a Status clients largely means implementing the following layers.
Additionally, there are separate specifications for things like key management and account lifecycle.

Other aspects, such as how a node uses IPFS for stickers or how the browser works, are currently underspecified.
These specifications facilitate the implementation of a Status client for basic private communication.

| Layer             | Purpose                        | Technology                   |
| ----------------- | ------------------------------ | ---------------------------- |
| Data and payloads | End user functionality         | 1:1, group chat, public chat |
| Data sync         | Data consistency               | MVDS.                        |
| Secure transport  | Confidentiality, PFS, etc      | Double Ratchet               |
| Transport privacy | Routing, Metadata protection   | Waku / Whisper               |
| P2P Overlay       | Overlay routing, NAT traversal | devp2p                       |

### Protobuf

[`protobuf`](https://developers.google.com/protocol-buffers/) is used in different layers, version `proto3` used is unless stated otherwise.

## Components

### P2P Overlay

Status clients run on a public, permissionless peer-to-peer network, as specified by the devP2P
network protocols. devP2P provides a protocol for node discovery which is in
draft mode
[here](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md). See
more on node discovery and management in the next section.

To communicate between Status nodes, the [RLPx Transport
Protocol, v5](https://github.com/ethereum/devp2p/blob/master/rlpx.md) is used, which
allows for TCP-based communication between nodes.

On top of this RLPx-based subprotocols are ran, the client
SHOULD NOT use [Whisper V6](https://eips.ethereum.org/EIPS/eip-627), the client
SHOULD use [Waku V1](/messaging/standards/legacy/6/waku1.md)
for privacy-preserving messaging and efficient usage of a node's bandwidth.

#### Node discovery and roles

There are four types of node roles:

1. `Bootstrap node`
1. `Whisper/Waku relayer`
1. `Mailserver` (servers and clients)
1. `Mobile node` (Status Clients)

A standard Status client MUST implement both `Whisper/Waku relayer` and `Mobile node` node types. The
other node types are optional, but it is RECOMMEND to implement a `Mailserver`
client mode, otherwise the user experience is likely to be poor.

#### Bootstrapping

Bootstrap nodes allow Status nodes to discover and connect to other Status nodes
in the network.

Currently, Status Gmbh provides the main bootstrap nodes, but anyone can
run these provided they are connected to the rest of the Whisper/Waku network.

Status maintains a list of production fleet bootstrap nodes in the following locations:

**Hong Kong:**

- `enode://6e6554fb3034b211398fcd0f0082cbb6bd13619e1a7e76ba66e1809aaa0c5f1ac53c9ae79cf2fd4a7bacb10d12010899b370c75fed19b991d9c0cdd02891abad@47.75.99.169:443`
- `enode://23d0740b11919358625d79d4cac7d50a34d79e9c69e16831c5c70573757a1f5d7d884510bc595d7ee4da3c1508adf87bbc9e9260d804ef03f8c1e37f2fb2fc69@47.52.106.107:443`

**Amsterdam:**

- `enode://436cc6f674928fdc9a9f7990f2944002b685d1c37f025c1be425185b5b1f0900feaf1ccc2a6130268f9901be4a7d252f37302c8335a2c1a62736e9232691cc3a@178.128.138.128:443`
- `enode://5395aab7833f1ecb671b59bf0521cf20224fe8162fc3d2675de4ee4d5636a75ec32d13268fc184df8d1ddfa803943906882da62a4df42d4fccf6d17808156a87@178.128.140.188:443`

**Central US:**

- `enode://32ff6d88760b0947a3dee54ceff4d8d7f0b4c023c6dad34568615fcae89e26cc2753f28f12485a4116c977be937a72665116596265aa0736b53d46b27446296a@34.70.75.208:443`
- `enode://5405c509df683c962e7c9470b251bb679dd6978f82d5b469f1f6c64d11d50fbd5dd9f7801c6ad51f3b20a5f6c7ffe248cc9ab223f8bcbaeaf14bb1c0ef295fd0@35.223.215.156:443`

These bootstrap nodes MAY change and are not guaranteed to stay this way forever
and at some point circumstances might force them to change.

#### Discovery

A Status client MUST discover or have a list of peers to connect to. Status uses a
light discovery mechanism based on a combination of [Discovery v5](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md) and
[Rendezvous Protocol](https://github.com/libp2p/specs/tree/master/rendezvous),
(with some [modifications](https://github.com/status-im/rendezvous#differences-with-original-rendezvous)).
Additionally, some static nodes MAY also be used.

A Status client MUST use at least one discovery method or use static nodes
to communicate with other clients.

Discovery V5 uses bootstrap nodes to discover other peers. Bootstrap nodes MUST support
Discovery V5 protocol as well in order to provide peers. It is kademlia-based discovery mechanism
and it might consume significant (at least on mobile) amount of network traffic to operate.

In order to take advantage from simpler and more mobile-friendly peers discovery mechanism,
i.e. Rendezvous protocol, one MUST provide a list of Rendezvous nodes which speak
Rendezvous protocol. Rendezvous protocol is request-response discovery mechanism.
It uses Ethereum Node Records (ENR) to report discovered peers.

Both peers discovery mechanisms use topics to provide peers with certain capabilities.
There is no point in returning peers that do not support a particular protocol.
Status nodes that want to be discovered MUST register to Discovery V5 and/or Rendezvous
with the `whisper` topic. Status nodes that are `Mailservers` and want to
be discoverable MUST additionally register with the `whispermail` topic.

It is RECOMMENDED to use both mechanisms but at the same time implement a structure
called `PeerPool`. `PeerPool` is responsible for maintaining an optimal number of peers.
For mobile nodes, there is no significant advantage to have more than 2-3 peers and one `Mailserver`.
`PeerPool` can notify peers discovery protocol implementations that they should suspend
their execution because the optimal number of peers is found. They should resume
if the number of connected peers drops or a `Mailserver` disconnects.

It is worth noticing that an efficient caching strategy MAY be of great use, especially,
on mobile devices. Discovered peers can be cached as they rarely change and used
when the client starts again. In such a case, there might be no need to even start
peers discovery protocols because cached peers will satisfy the optimal number of peers.

Alternatively, a client MAY rely exclusively on a list of static peers. This is the most efficient
way because there are no peers discovery algorithm overhead introduced. The disadvantage
is that these peers might be gone and without peers discovery mechanism, it won't be possible to find
new ones.

The current list of static peers is published on <https://fleets.status.im/>. `eth.prod` is the current
group of peers the official Status client uses. The others are test networks.

Finally, Waku node addresses can be retrieved by traversing
the merkle tree found at [`fleets.status.im`](https://fleets.status.im), as described in [EIP-1459](https://eips.ethereum.org/EIPS/eip-1459#client-protocol).

#### Mobile nodes

A `Mobile node` is a Whisper and/or Waku node which connects to part of the respective Whisper
and/or Waku network(s). A `Mobile node` MAY relay messages. See next section for more details on how
to use Whisper and/or Waku to communicate with other Status nodes.

### Transport privacy and Whisper / Waku usage

Once a Whisper and/or Waku node is up and running there are some specific settings required
to communicate with other Status nodes.

See [WHISPER-USAGE](/archived/status/deprecated/whisper-usage.md) and [WAKU-USAGE](/archived/status/deprecated/waku-usage.md) for more details.

For providing an offline inbox, see the complementary [WHISPER-MAILSERVER](/archived/status/deprecated/whisper-mailserver.md) and [WAKU-MAILSERVER](/archived/status/deprecated/waku-mailserver.md).

### Secure Transport

In order to provide confidentiality, integrity, authentication and forward
secrecy of messages the node implements a secure transport on top of Whisper and Waku. This is
used in 1:1 chats and group chats, but not for public chats. See [SECURE-TRANSPORT](/archived/status/deprecated/secure-transport.md) for more.

### Data Sync

[MVDS](/ift-ts/raw/2/mvds.md) is used for 1:1 and group chats, however it is currently not in use for public chats.
[Status payloads](#payloads-and-clients) are serialized and then wrapped inside an
MVDS message which is added to an [MVDS payload](/ift-ts/raw/2/mvds.md#payloads),
the node encrypts this payload (if necessary for 1-to-1 / group-chats) and sends it using
Whisper or Waku which also encrypts it.

### Payloads and clients

On top of secure transport, various types of data sync clients and
the node uses payload formats for things like 1:1 chat, group chat and public chat. These have
various degrees of standardization. Please refer to [PAYLOADS](/archived/status/deprecated/payloads.md) for more details.

### BIPs and EIPs Standards support

For a list of EIPs and BIPs that SHOULD be supported by Status client, please
see [EIPS](/archived/status/deprecated/eips.md).

## Security Considerations

See [Appendix A](#appendix-a-security-considerations)

## Design Rationale

P2P Overlay

### Why devp2p? Why not use libp2p?

At the time Status developed the main Status clients, devp2p was the most
mature. However, in the future libp2p is likely to be used, as it'll
provide us with multiple transports, better protocol negotiation, NAT traversal,
etc.

For very experimental bridge support, see the bridge between libp2p and devp2p
in [Murmur](https://github.com/status-im/murmur).

### What about other RLPx subprotocols like LES, and Swarm?

Status is primarily optimized for resource restricted devices, and at present
time light client support for these protocols are suboptimal. This is a work in
progress.

For better Ethereum light client support, see [Re-enable LES as
option](https://github.com/status-im/status-go/issues/1025). For better Swarm
support, see [Swarm adaptive
nodes](https://github.com/ethersphere/SWIPs/pull/12).

For transaction support, Status clients currently have to rely on Infura.

Status clients currently do not offer native support for file storage.

### Why do you use Whisper?

Whisper is one of the [three parts](http://gavwood.com/dappsweb3.html) of the
vision of Ethereum as the world computer, Ethereum and Swarm being the other
two. Status was started as an encapsulation of and a clear window to this world
computer.

### Why do you use Waku?

Waku is a direct upgrade and replacement for Whisper, the main motivation for
developing and implementing Waku can be found in the [Waku specs](/messaging/README.md).

>Waku was created to incrementally improve in areas that Whisper is lacking in,
>with special attention to resource restricted devices. We specify the standard for
>Waku messages in order to ensure forward compatibility of different Waku clients,
>backwards compatibility with Whisper clients, as well as to allow multiple
>implementations of Waku and its capabilities. We also modify the language to be more
>unambiguous, concise and consistent.

Considerable work has gone into the active development of Ethereum, in contrast Whisper
is not currently under active development, and it has several drawbacks. Among others:

- Whisper is very wasteful bandwidth-wise and doesn't appear to be scalable
- Proof of work is a poor spam protection mechanism for heterogeneous devices
- The privacy guarantees provided are not rigorous
- There are no incentives to run a node

Finding a more suitable transport privacy is an ongoing research effort,
together with [IFT-TS](https://vac.dev/vac-overview) and other teams in the space.

### Why is PoW for Waku set so low?

A higher PoW would be desirable, but this kills the battery on mobile phones,
which is a prime target for Status clients.

This means the network is currently vulnerable to DDoS attacks. Alternative
methods of spam protection are currently being researched.

### Why do you not use Discovery v5 for node discovery?

At the time of implementing dynamic node discovery, Discovery v5 wasn't completed
yet. Additionally, running a DHT on a mobile leads to slow node discovery, bad
battery and poor bandwidth usage. Instead, each client can choose to turn on
Discovery v5 for a short period until the node populates their peer list.

For some further investigation, see
[here](https://github.com/status-im/swarms/blob/master/ideas/092-disc-v5-research.md).

### I heard something about `Mailservers` being trusted somehow?

In order to use a `Mailserver`, a given node needs to connect to it directly, i.e. add the `Mailserver`
as its peer and mark it as trusted.
This means that the `Mailserver` is able to send direct p2p messages to the node instead of broadcasting them.
Effectively, it knows the bloom filter of the topics the node is interested in,
when it is online as well as many metadata like IP address.

### Data sync

#### Why is MVDS not used for public chats?

Currently, public chats are broadcast-based, and there's no direct way of finding
out who is receiving messages. Hence there's no clear group sync state context
whereby participants can sync. Additionally, MVDS is currently not optimized for
large group contexts, which means bandwidth usage will be a lot higher than
reasonable. See [P2P Data Sync for Mobile](https://vac.dev/p2p-data-sync-for-mobile) for more.
This is an active area of research.

## Footnotes

1. <https://github.com/status-im/status-protocol-go/>
2. <https://github.com/status-im/status-console-client/>
3. <https://github.com/status-im/status-mobile/>

## Appendix A: Security considerations

There are several security considerations to take into account when running Status.
Chief among them are: scalability, DDoS-resistance and privacy.
These also vary depending on what capabilities are used, such as `Mailserver`, light node, and so on.

### Scalability and UX

**Bandwidth usage:**

In version 1 of Status, bandwidth usage is likely to be an issue.
In Status version 1.1 this is partially addressed with Waku usage, see [the theoretical scaling model](https://github.com/vacp2p/research/tree/dcc71f4779be832d3b5ece9c4e11f1f7ec24aac2/whisper_scalability).

**`Mailserver` High Availability requirement:**

A `Mailserver` has to be online to receive messages for other nodes, this puts a high availability requirement on it.

**Gossip-based routing:**

Use of gossip-based routing doesn't necessarily scale.
It means each node can see a message multiple times,
and having too many light nodes can cause propagation probability that is too low.
See [Whisper vs PSS](https://our.status.im/whisper-pss-comparison/) for more and a possible Kademlia based alternative.

**Lack of incentives:**

Status currently lacks incentives to run nodes, which means node operators are more likely to create centralized choke points.

### Privacy

**Light node privacy:**

The main privacy concern with light nodes is that directly connected peers will know that a message originates from them (as it are the only ones it sends). This means nodes can make assumptions about what messages (topics) their peers are interested in.

**Bloom filter privacy:**

A user reveals which messages they are interested in, by setting only the topics they are interested in on the bloom filter.
This is a fundamental trade-off between bandwidth usage and privacy,
though the trade-off space is likely suboptimal in terms of the [Anonymity](https://eprint.iacr.org/2017/954.pdf) [trilemma](https://petsymposium.org/2019/files/hotpets/slides/coordination-helps-anonymity-slides.pdf).

**`Mailserver client` privacy:**

A `Mailserver client` has to trust a `Mailserver`, which means they can send direct traffic. This reveals what topics / bloom filter a node is interested in, along with its peerID (with IP).

**Privacy guarantees not rigorous:**

Privacy for Whisper or Waku hasn't been studied rigorously for various threat models like global passive adversary, local active attacker, etc. This is unlike e.g. Tor and mixnets.

**Topic hygiene:**

Similar to bloom filter privacy, using a very specific topic reveals more information. See scalability model linked above.

### Spam resistance

**PoW bad for heterogeneous devices:**

Proof of work is a poor spam prevention mechanism. A mobile device can only have a very low PoW in order not to use too much CPU / burn up its phone battery. This means someone can spin up a powerful node and overwhelm the network.

**`Mailserver` trusted connection:**

A `Mailserver` has a direct TCP connection, which means they are trusted to send traffic. This means a malicious or malfunctioning `Mailserver` can overwhelm an individual node.

### Censorship resistance

**Devp2p TCP port blockable:**

By default Devp2p runs on port `30303`, which is not commonly used for any other service. This means it is easy to censor, e.g. airport WiFi. This can be mitigated somewhat by running on e.g. port `80` or `443`, but there are still outstanding issues. See libp2p and Tor's Pluggable Transport for how this can be improved.

See <https://github.com/status-im/status-mobile/issues/6351> for some discussion.

## Acknowledgments

Jacek Sieka

## Changelog

### Version 0.3

Released [May 22, 2020](https://github.com/status-im/specs/commit/664dd1c9df6ad409e4c007fefc8c8945b8d324e8)

- Added that Waku SHOULD be used
- Added that Whisper SHOULD NOT be used
- Added language to include Waku in all relevant places
- Change to keep `Mailserver` term consistent

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [Protobuf](https://developers.google.com/protocol-buffers/)
- [Discv5](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md)
- [RLPx Transport Protocol, v5](https://github.com/ethereum/devp2p/blob/master/rlpx.md)
- [Whisper V6](https://eips.ethereum.org/EIPS/eip-627)
- [Waku V1](/messaging/standards/legacy/6/waku1.md)
- [Rendezvous Protocol](https://github.com/libp2p/specs/tree/master/rendezvous)
- [Rendezvous Protocol modifications](https://github.com/status-im/rendezvous#differences-with-original-rendezvous)
- [Fleets Status](https://fleets.status.im)
- [EIP-1459](https://eips.ethereum.org/EIPS/eip-1459#client-protocol)
- [WHISPER-USAGE](/archived/status/deprecated/whisper-usage.md)
- [WAKU-USAGE](/archived/status/deprecated/waku-usage.md)
- [WHISPER-MAILSERVER](/archived/status/deprecated/whisper-mailserver.md)
- [WAKU-MAILSERVER](/archived/status/deprecated/waku-mailserver.md)
- [SECURE-TRANSPORT](/archived/status/deprecated/secure-transport.md)
- [MVDS](/ift-ts/raw/2/mvds.md)
- [PAYLOADS](/archived/status/deprecated/payloads.md)
- [EIPS](/archived/status/deprecated/eips.md)
- [Murmur](https://github.com/status-im/murmur)
- [Re-enable LES as option](https://github.com/status-im/status-go/issues/1025)
- [Swarm adaptive nodes](https://github.com/ethersphere/SWIPs/pull/12)
- [Whisper vs PSS](https://our.status.im/whisper-pss-comparison/)
- [Waku specs](/messaging/README.md)
- [IFT-TS](https://vac.dev/vac-overview)
- [theoretical scaling model](https://github.com/vacp2p/research/tree/dcc71f4779be832d3b5ece9c4e11f1f7ec24aac2/whisper_scalability)
- [Anonymity](https://eprint.iacr.org/2017/954.pdf)
- [trilemma](https://petsymposium.org/2019/files/hotpets/slides/coordination-helps-anonymity-slides.pdf)
- [Whisper vs PSS](https://our.status.im/whisper-pss-comparison/)
- [Discovery v5 research](https://github.com/status-im/swarms/blob/master/ideas/092-disc-v5-research.md)
- [P2P Data Sync for Mobile](https://vac.dev/p2p-data-sync-for-mobile)
- [Status protocol go](https://github.com/status-im/status-protocol-go/)
- [Status console client](https://github.com/status-im/status-console-client/)
- [Status mobile](https://github.com/status-im/status-mobile/)
- [Status mobile issue 6351](https://github.com/status-im/status-mobile/issues/6351)
