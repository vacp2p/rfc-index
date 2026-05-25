# P2P-NETWORK-BOOTSTRAPPING

| Field | Value |
| --- | --- |
| Name | Nomos P2P Network Bootstrapping Specification |
| Slug | 134 |
| Status | raw |
| Category | networking |
| Editor | Daniel Sanchez-Quiros <danielsq@logos.co> |
| Contributors | Álvaro Castro-Castilla <alvaro@logos.co>, Petar Radovic <petar@logos.co>, Gusto Bacvinka <augustinas@logos.co>, Antonio Antonino <antonio@logos.co>, Youngjoon Lee <youngjoon@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/p2p-network-bootstrapping.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/p2p-network-bootstrapping.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/logos-co/logos-lips/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/nomos/raw/p2p-network-bootstrapping.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/logos-co/logos-lips/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/nomos/raw/p2p-network-bootstrapping.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/logos-co/logos-lips/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/nomos/raw/p2p-network-bootstrapping.md) — ci: add mdBook configuration (#233)
- **2025-09-25** — [`aa8a3b0`](https://github.com/logos-co/logos-lips/blob/aa8a3b0c65470b97f5aeee85a8444c7d22dcafc8/nomos/raw/p2p-network-bootstrapping.md) — Created nomos/raw/p2p-network-bootstrapping.md draft (#175)

<!-- timeline:end -->

Authors: Daniel Sanchez Quiros <danielsq@status.im>

# Revision History

# Introduction

Logos Blockchain network bootstrapping is the process by which a new node discovers peers and synchronizes with the existing decentralized network. It ensures that a node can:

1. Discover Peers ��� Find other active nodes in the network.
1. Establish Connections ��� Securely connect to trusted peers.
1. Negotiate (libp2p) Protocols - Ensure that other peers operate in the same protocols as the node needs.

# Overview

The Logos Blockchain P2P network bootstrapping strategy relies on a designated subset of bootstrap nodes to facilitate secure and efficient node onboarding. These nodes serve as the initial entry points for new network participants.

### Key Design Principles

Trusted Bootstrap Nodes

Node Configuration & Onboarding

Network Integration

### Security & Decentralization Considerations

Trust Minimization: While bootstrap nodes provide initial connectivity, the network rapidly transitions to decentralized peer discovery to prevent over-reliance on any single entity.

Authenticated Announcements: The identities and addresses of bootstrap nodes are publicly verifiable to mitigate impersonation attacks. From the [libp2p documentation](https://docs.libp2p.io/concepts/transports/quic/#quic-in-libp2p):

> To authenticate each others��� peer IDs, peers encode their peer ID into a self-signed certificate, which they sign using their host���s private key.

Dynamic Peer Management: After bootstrapping, nodes continuously refine their peer lists to maintain a resilient and distributed network topology.

This approach ensures rapid, secure, and scalable network participation while preserving the decentralized ethos of the Logos Blockchain.

# Protocol

## Step-by-Step bootstrapping process

1. Node Initial Configuration: New nodes load pre-configured bootstrap node addresses. Addresses may be IP or DNS embedded in a compatible [libp2p PeerId multiaddress](https://docs.libp2p.io/concepts/fundamentals/peers/#peer-ids-in-multiaddrs). Node operators may chose to advertise more than one address. This is out of the scope of this protocol. For example:
    /ip4/198.51.100.0/udp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N or
    /dns/foo.bar.net/udp/4242/p2p/QmYyQSo1c1Ym7orWxLYvCrM2EmxFTANf8wXmmE7DWjhx5N
1. Secure Connection: Nodes establish connections to bootstrap nodes announced addresses and verify network identity and protocol compatibility.
1. Peer Discovery: Requests and receive validated peer lists from bootstrap nodes. Each entry includes connectivity details as per the [����[1.0.1] P2P Network - Peer Discovery](https://nomos-tech.notion.site/Peer-Discovery-206261aa09df81db8100d5f410e39d75?pvs=24#206261aa09df81f19c52d887d833e438) protocol engaging after the initial connection.
1. Network Integration: Iteratively connects to discovered peers. Gradually build peer connections.
1. Protocol Engagement: Establishes required protocol channels (gossip/consensus/sync). Begins participating in network operations.
1. Ongoing Maintenance: Continuously evaluates and refreshes peer connections. Ideally removes the connection to the bootstrap node itself. Bootstrap nodes may chose to remove the connection on their side to keep high availability for other nodes.

```
Bootstrap NodeNodeLogos Blockchain NetworkBootstrap NodeNodeLogos Blockchain Networkloop[Interacts with bootstrap node]loop[Connects to Networkparticipants]alt[Bootstrap connection no longerneeded][Bootstrap enforces disconnection]loop[Ongoing maintenance]Fetches bootstrapping addressesConnectsSends discovered peers' informationEngages in connectionsNegotiates protocolsEvaluates peer connectionsDisconnectsDisconnects���
```

# Details

The bootstrapping process for the Logos Blockchain p2p network uses the QUIC transport as specified in the [����[1.0.1] P2P Network - Transport](https://nomos-tech.notion.site/Transport-206261aa09df81db8100d5f410e39d75?pvs=24#206261aa09df81a88aa2d18dd0bbe8f3).

Bootstrapping is separated from the network���s peer discovery protocol. It assumes that there is one protocol that would engage as soon as the connection with the bootstrapping node triggers. Currently, the Logos Blockchain network uses kademlia as the current first approach for the Logos Blockchain p2p network (see [����[1.0.1] P2P Network - Peer Discovery](https://nomos-tech.notion.site/Peer-Discovery-206261aa09df81db8100d5f410e39d75?pvs=24#206261aa09df81f19c52d887d833e438)), which comes built-in.

# Annex

- [Ethereum bootnodes](https://ethereum.org/en/developers/docs/nodes-and-clients/bootnodes/)
- [Bitcoin peer discovery](https://developer.bitcoin.org/devguide/p2p_network.html#peer-discovery)
- [Cardano nodes connectivity](https://docs.cardano.org/stake-pool-operators/node-connectivity) & [peer sharing](https://www.coincashew.com/coins/overview-ada/guide-how-to-build-a-haskell-stakepool-node/part-v-tips/implementing-peer-sharing)

