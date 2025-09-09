---
title: CODEX-DHT
name: Codex DHT
status: draft
tags: 
editor: 
contributors:
---

## Abstract

This document explians the Codex DHT (Data Hash Table) component.
It is used to store Codex's signed-peer-record (SPR) entries,
as well as content identifiers (CID) for each host.

## Background

Codex is a network of peer nodes, identified as hosts,
particapting in a decentralized peer-to-peer storage solution.
Codex offers data durability guarantees, incentive mechanisms and data persistenace guarantees.

The Codex DHT component is a modified version of [DiscV5 DHT](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md).
DiscV5 is a node discovery system used to find peers within a peer-to-peer network.
Codex DHT has signed-peer-record (SPR) and content identifiers (CID) for each host.
This allows for hosts to publish connection information and
information about what content they are storing.
All Codex host run this system at no extra cost other than using resources to store node records.
This allows any node to become the entry point to connect to the current live nodes into the Codex netowork.

## Wire Format

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

- At init `host` SHOULD provide SPR values, config
- `host` connects to bootstrap nodes to retrive current DHT records
- random lookup every 5 minutes?
- A SPR usually consist of the network endpoints of a node, i.e. the node's IP addresses and ports.
- The node MUST provide an IP address and UDP port to have it's record relayed in the DHT.
- Node records are signed according to an `identity`, not nodeID
- CID are converted to nodeID
- disregard unsigned records, verify record signatures,
- Node A MUST have a copy of node B's record in order to communicate with it

## Record Structure

## Publishing Records

- component will contact other nodes in the network to disseminate new and updated records.
- sign its records before transmitting
- 

## Retrieve Records

- nodes in the network to perform queries
- SHOULD update their record, increase the sequence number and sign a new version of the record whenever their information changes
- discard stale records as defined by configuration

## Distance calculation

## Routing table


