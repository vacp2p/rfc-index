# 30/ADAPTIVE-NODES

| Field | Value |
| --- | --- |
| Name | Adaptive nodes |
| Slug | 30 |
| Status | draft |
| Editor | Oskar Thorén <oskarth@titanproxy.com> |
| Contributors | Filip Dimitrijevic <filip@status.im> |

This is an informational spec that show cases the concept of adaptive nodes.

## Node types - a continuum

We can look at node types as a continuum,
from more restricted to less restricted,
fewer resources to more resources.

![Node types - a continuum](./images/adaptive_node_continuum2.png)

### Possible limitations

- Connectivity: Not publicly connectable vs static IP and DNS
- Connectivity: Mostly offline to mostly online to always online
- Resources: Storage, CPU, Memory, Bandwidth

### Accessibility and motivation

Some examples:

- Opening browser window: costs nothing, but contribute nothing
- Desktop: download, leave in background, contribute somewhat
- Cluster: expensive, upkeep, but can contribute a lot

These are also illustrative,
so a node in a browser in certain environment might contribute similarly to Desktop.

### Adaptive nodes

We call these nodes *adaptive nodes* to highlights different modes of contributing,
such as:

- Only leeching from the network
- Relaying messages for one or more topics
- Providing services for lighter nodes such as lightpush and filter
- Storing historical messages to various degrees
- Ensuring relay network can't be spammed with RLN

### Planned incentives

Incentives to run a node is currently planned around:

- SWAP for accounting and settlement of services provided
- RLN RELAY for spam protection
- Other incentivization schemes are likely to follow and is an area of active research

## Node protocol selection

Each node can choose which protocols to support, depending on its resources and goals.

![Protocol selection](./images/adaptive_node_protocol_selection2.png)

Protocols like [11/WAKU2-RELAY](/waku/standards/core/11/relay.md),
as well as [12], [13], [19], and [21], correspond to libp2p protocols.

However, other protocols like 16/WAKU2-RPC
(local HTTP JSON-RPC), 25/LIBP2P-DNS-DISCOVERY,
Discovery v5 (DevP2P) or interfacing with distributed storage,
are running on different network stacks.

This is in addition to protocols that specify payloads, such as 14/WAKU2-MESSAGE,
26/WAKU2-PAYLOAD, or application specific ones.
As well as specs that act more as recommendations,
such as 23/WAKU2-TOPICS or 27/WAKU2-PEERS.

## Waku network visualization

We can better visualize the network with some illustrative examples.

### Topology and topics

This illustration shows an example topology with different PubSub topics
for the relay protocol.

![Waku Network visualization](./images/adaptive_node_network_topology_protocols2.png)

### Legend

This illustration shows an example of content topics a node is interested in.

![Waku Network visualization legend](./images/adaptive_node_network_topology_protocols_legend.png)

The dotted box shows what content topics (application-specific)
a node is interested in.

A node that is purely providing a service to the network might not care.

In this example, we see support for toy chat,
a topic in Waku v1 (Status chat), WalletConnect, and SuperRare community.

### Auxiliary network

This is a separate component with its own topology.

Behavior and interaction with other protocols specified in Logos LIPs,
e.g. [25/LIBP2P-DNS-DISCOVERY](/vac/25/libp2p-dns-discovery.md)
and [15/WAKU-BRIDGE](/waku/standards/core/15/bridge.md).

### Node Cross Section

This one shows a cross-section of nodes in different dimensions and
shows how the connections look different for different protocols.

![Node Cross Section](./images/adaptive_node_cross_section2.png)

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [11/WAKU2-RELAY](/waku/standards/core/11/relay.md)
- [25/LIBP2P-DNS-DISCOVERY](/vac/25/libp2p-dns-discovery.md)
- [15/WAKU-BRIDGE](/waku/standards/core/15/bridge.md)
