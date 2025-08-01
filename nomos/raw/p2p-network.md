---
title: P2P-NETWORK
name: Nomos P2P Network Specification
status: draft
category: networking
tags: [p2p, networking, libp2p, kademlia, gossipsub, quic]
editor: Daniel Sanchez-Quiros <danielsq@status.im>
contributors:
- Filip Dimitrijevic <filip@status.im>
---

## Abstract

This specification defines the peer-to-peer (P2P) network layer for Nomos blockchain nodes. The network serves as the comprehensive communication infrastructure enabling transaction dissemination through mempool and block propagation. The specification leverages established libp2p protocols to ensure robust, scalable performance with low bandwidth requirements and minimal latency while maintaining accessibility for diverse hardware configurations and network environments.

## Motivation

The Nomos blockchain requires a reliable, scalable P2P network that can:

1. **Support diverse hardware**: From laptops to dedicated servers across various operating systems and geographic locations
2. **Enable inclusive participation**: Allow non-technical users to operate nodes with minimal configuration
3. **Maintain connectivity**: Ensure nodes remain reachable even with limited connectivity or behind NAT/routers
4. **Scale efficiently**: Support large-scale networks (+10k nodes) with eventual consistency
5. **Provide low-latency communication**: Enable efficient transaction and block propagation

## Specification

### Network Architecture Overview

The Nomos P2P network addresses three critical challenges:

- **Peer Connectivity**: Mechanisms for peers to join and connect to the network
- **Peer Discovery**: Enabling peers to locate and identify network participants  
- **Message Transmission**: Facilitating efficient message exchange across the network

### Transport Protocol

#### QUIC Transport

The Nomos network employs **QUIC** as the primary transport protocol, leveraging the libp2p implementation.

**Rationale for QUIC:**

- Rapid connection establishment
- Enhanced NAT traversal capabilities (UDP-based)
- Built-in multiplexing simplifies configuration
- Production-tested reliability

**Protocol Identifier:**

```text
/quic-v1
```

### Peer Discovery

#### Kademlia DHT

The network utilizes libp2p's Kademlia Distributed Hash Table (DHT) for peer discovery.

**Protocol Identifiers:**

- **Mainnet**: `/nomos/kad/1.0.0`
- **Testnet**: `/nomos-testnet/kad/1.0.0`

**Features:**

- Proximity-based peer discovery heuristics
- Distributed peer routing table
- Resilient to network partitions
- Automatic peer replacement

#### Identify Protocol

Complements Kademlia by enabling peer information exchange.

**Protocol Identifiers:**

- **Mainnet**: `/nomos/identify/1.0.0`
- **Testnet**: `/nomos-testnet/identify/1.0.0`

**Capabilities:**

- Protocol support advertisement
- Peer capability negotiation
- Network interoperability enhancement

#### Future Considerations

The current Kademlia implementation is acknowledged as interim. Future improvements target:

- Lightweight design without full DHT overhead
- Highly-scalable eventual consistency
- Support for 10k+ nodes with minimal resource usage

### NAT Traversal

The network implements comprehensive NAT traversal solutions to ensure connectivity across diverse network configurations.

**Objectives:**

- Configuration-free peer connections
- Support for users with varying technical expertise
- Enable nodes on standard consumer hardware

**Implementation:**

- Tailored solutions based on user network configuration
- Automatic NAT type detection and adaptation
- Fallback mechanisms for challenging network environments

*Note: Detailed NAT traversal specifications are maintained in a separate document.*

### Message Dissemination

#### Gossipsub Protocol

Nomos employs **gossipsub** for reliable message propagation across the network.

**Integration:**

- Seamless integration with Kademlia peer discovery
- Automatic peer list updates
- Efficient message routing and delivery

#### Topic Configuration

**Mempool Dissemination:**

- **Mainnet**: `/nomos/mempool/0.1.0`
- **Testnet**: `/nomos-testnet/mempool/0.1.0`

**Block Propagation:**

- **Mainnet**: `/nomos/cryptarchia/0.1.0`
- **Testnet**: `/nomos-testnet/cryptarchia/0.1.0`

#### Network Parameters

**Peering Degree:**

- **Minimum recommended**: 8 peers
- **Rationale**: Ensures redundancy and efficient propagation
- **Configurable**: Nodes may adjust based on resources and requirements

### Bootstrapping

#### Initial Network Entry

New nodes connect to the network through designated bootstrap nodes.

**Process:**

1. Connect to known bootstrap nodes
2. Obtain initial peer list through Kademlia
3. Establish gossipsub connections
4. Begin participating in network protocols

**Bootstrap Node Requirements:**

- High availability and reliability
- Geographic distribution
- Version compatibility maintenance

### Message Encoding

All network messages follow the Nomos Wire Format specification for consistent encoding and decoding across implementations.

**Key Properties:**

- Deterministic serialization
- Efficient binary encoding
- Forward/backward compatibility support
- Cross-platform consistency

*Note: Detailed wire format specifications are maintained in a separate document.*

## Implementation Requirements

### Mandatory Protocols

All Nomos nodes MUST implement:

1. **QUIC transport**
2. **Kademlia DHT** for peer discovery
3. **Identify protocol** for peer information exchange
4. **Gossipsub** for message dissemination

### Optional Enhancements

Nodes MAY implement:

- Advanced NAT traversal techniques
- Custom peering strategies
- Enhanced message routing optimizations

### Network Versioning

Protocol versions follow semantic versioning:

- **Major version**: Breaking protocol changes
- **Minor version**: Backward-compatible enhancements
- **Patch version**: Bug fixes and optimizations

### Configuration Parameters

#### Peer Discovery Parameters

```yaml
kademlia:
  protocol_id: "/nomos/kad/1.0.0"
  replication_factor: 20
  query_timeout: 60s

identify:
  protocol_id: "/nomos/identify/1.0.0"
  push_interval: 300s
```

#### Gossipsub Parameters

```yaml
gossipsub:
  min_peers: 8
  max_peers: 200
  heartbeat_interval: 1s
  fanout_ttl: 60s
  topics:
    - "/nomos/mempool/0.1.0"
    - "/nomos/cryptarchia/0.1.0"
```

## Security Considerations

### Network-Level Security

1. **Peer Authentication**: Utilize libp2p's built-in peer identity verification
2. **Message Validation**: Implement application-layer message validation
3. **Rate Limiting**: Protect against spam and DoS attacks
4. **Blacklisting**: Mechanism for excluding malicious peers

### Privacy Considerations

1. **Traffic Analysis**: Gossipsub provides some resistance to traffic analysis
2. **Metadata Leakage**: Minimize identifiable information in protocol messages
3. **Connection Patterns**: Randomize connection timing and patterns

### Denial of Service Protection

1. **Resource Limits**: Impose limits on connections and message rates
2. **Peer Scoring**: Implement reputation-based peer management
3. **Circuit Breakers**: Automatic protection against resource exhaustion

## Performance Characteristics

### Scalability

- **Target Network Size**: 10,000+ nodes
- **Message Latency**: Sub-second for critical messages
- **Bandwidth Efficiency**: Optimized for limited bandwidth environments

### Resource Requirements

- **Memory Usage**: Minimal DHT routing table overhead
- **CPU Usage**: Efficient cryptographic operations
- **Network Bandwidth**: Adaptive based on node role and capacity

## References

1. [libp2p Specifications](https://docs.libp2p.io/)
2. [QUIC Protocol Specification](https://docs.libp2p.io/concepts/transports/quic/)
3. [Kademlia DHT](https://docs.libp2p.io/concepts/discovery-routing/kaddht/)
4. [Gossipsub Protocol](https://github.com/libp2p/specs/tree/master/pubsub/gossipsub)
5. [Identify Protocol](https://github.com/libp2p/specs/blob/master/identify/README.md)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
