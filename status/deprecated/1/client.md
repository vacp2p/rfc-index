---
title: CLIENT
name: Client
status: deprecated
description: This specification describes how to write a Status client for communicating with other Status clients.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Adam Babik <adam@status.im>
  - Andrea Maria Piana <andreap@status.im>
  - Dean Eigenmann <dean@status.im>
  - Corey Petty <corey@status.im>
  - Oskar Thorén <oskar@status.im>
  - Samuel Hawksby-Robinson <samuel@status.im>
---

## Abstract

This specification describes how to write a Status client for communicating  
with other Status clients.  
This specification presents a reference implementation of the protocol
used in a command-line client and a mobile app.

This document consists of two parts.  
The first outlines the specifications required to be a full Status client.  
The second provides a design rationale and answers some common questions.

## Introduction

Implementing a Status client means implementing multiple layers.  
This includes specifications for key management and account lifecycle.

Other aspects, such as how a node uses IPFS for stickers or how the browser  
works, are currently underspecified.  
These specifications support implementing a Status client for basic private  
communication.

| Layer           | Purpose                | Technology             |
|-----------------|------------------------|------------------------|
| Data and payloads | End user functionality | 1:1, group chat, public chat |
| Data sync       | Data consistency       | MVDS                   |
| Secure transport | Confidentiality, PFS   | Double Ratchet         |
| Transport privacy | Routing, Metadata protection | Waku / Whisper       |
| P2P Overlay     | Overlay routing, NAT traversal | devp2p             |

## Protobuf

`protobuf` is used in different layers, with `proto3` as the default version  
unless otherwise specified.

## Components

### P2P Overlay

Status clients run on a public, permissionless peer-to-peer network,  
as specified by the devP2P network protocols.  
devP2P provides a protocol for node discovery,  
and the RLPx Transport Protocol v5 is used for TCP-based communication.

The client **SHOULD NOT** use Whisper V6.  
Instead, the client **SHOULD** use Waku V1 for privacy-preserving messaging  
and efficient bandwidth usage.

### Node Discovery and Roles

There are four types of node roles:

- Bootstrap node
- Whisper/Waku relayer
- Mailserver (servers and clients)
- Mobile node (Status Clients)

A standard Status client **MUST** implement both Whisper/Waku relayer  
and Mobile node node types.  
Implementing a Mailserver client mode is **RECOMMENDED** for user experience.

### Bootstrapping

Bootstrap nodes allow Status nodes to discover and connect to other nodes.  
Status GmbH provides the main bootstrap nodes,  
but anyone connected to the Whisper/Waku network can run one.

The current list of production bootstrap nodes is available
at locations in Hong Kong, Amsterdam, and Central US.  
These nodes **MAY** change as needed.

### Discovery

A Status client **MUST** discover or have a list of peers to connect to.  
Status uses a light discovery mechanism
based on Discovery v5 and Rendezvous Protocol.  
Static nodes **MAY** also be used.

Discovery V5 is kademlia-based and may consume significant network traffic.  
The Rendezvous protocol is request-response and uses ENR to report peers.

Both discovery mechanisms use topics
to provide peers with specific capabilities.  
Status nodes wanting discovery **MUST** register with the `whisper` topic,  
and Mailservers **MUST** additionally register with `whispermail`.

Using both mechanisms is **RECOMMENDED**, alongside a `PeerPool` structure
for optimal peer count management.

### Mobile Nodes

A Mobile node is a Whisper and/or Waku node connecting to the network.  
Mobile nodes **MAY** relay messages.  
See WHISPER-USAGE and WAKU-USAGE for more details.

For an offline inbox, see WHISPER-MAILSERVER and WAKU-MAILSERVER.

## Transport Privacy and Whisper/Waku Usage

After a Whisper/Waku node is active,  
specific settings are required for communication with other Status nodes.

## Secure Transport

To provide confidentiality, integrity, authentication,  
and forward secrecy, secure transport is implemented on top of Whisper/Waku.  
This applies to 1:1 and group chats, but not public chats.  
See SECURE-TRANSPORT for more.

## Data Sync

MVDS is used for 1:1 and group chats but is currently unused for public chats.  
Status payloads are serialized, wrapped in an MVDS message,  
and encrypted if needed for secure chats before sending.

## Payloads and Clients

On top of secure transport, Status uses various data sync clients  
and payload formats for chat types.  
Refer to PAYLOADS for details.

## BIPs and EIPs Standards Support

For EIPs and BIPs **SHOULD** supported by Status clients, see EIPS.

## Security Considerations

See Appendix A for detailed security considerations.

## Design Rationale

P2P Overlay

### Why devp2p? Why not use libp2p?

At Status's start, devp2p was the most mature option.  
In the future, libp2p may be used for multiple transports,  
NAT traversal, and better protocol negotiation.

#### Why do you use Whisper?

Whisper was part of Ethereum's vision for a "world computer" alongside Swarm.

#### Why do you use Waku?

Waku is an upgraded, optimized version of Whisper,  
addressing resource-restricted device limitations.  
Waku standardizes messages for compatibility and scalability.

Data Sync

### Why is MVDS not used for public chats?

Public chats are broadcast-based,  
and MVDS is not optimized for large group contexts.  
This is an active research area.

## Footnotes

1. [Footnote 1](https://github.com/status-im/status-protocol-go/)
2. [Footnote 2](https://github.com/status-im/status-console-client/)
3. [Footnote 3](https://github.com/status-im/status-mobile/)

## Appendix A: Security Considerations

Chief considerations include scalability, DDoS resistance,  
and privacy depending on the capabilities used.

### Scalability and UX

- **Bandwidth usage**: High in version 1.
- **Mailserver High Availability**:  
  Mailserver needs to be online for receiving messages.
- **Gossip-based routing**:  
  Propagation probability may be low with too many light nodes.
- **Lack of incentives**:  
  Centralized choke points can form without node-running incentives.

### Privacy

- **Light node privacy**:  
  Connected peers know message origin.
- **Bloom filter privacy**:  
  Interests reveal topics in bloom filters.
- **Mailserver client privacy**:  
  Trusted Mailservers reveal topic, IP, and peerID.
- **Privacy guarantees not rigorous**:  
  Privacy not rigorously studied like Tor or mixnets.

### Spam Resistance

Proof of work is ineffective for heterogeneous devices,  
and a Mailserver can overwhelm a node with traffic.

### Censorship Resistance

Devp2p runs on port 30303, making it susceptible to censorship.

## Acknowledgments

- Jacek Sieka

## Changelog

### Version 0.3

- Released May 22, 2020
- Added that Waku **SHOULD** be used
- Added that Whisper **SHOULD NOT** be used
- Updated Mailserver term consistency
- Added language for Waku in all relevant places

## Copyright

Copyright and related rights waived via CC0.
