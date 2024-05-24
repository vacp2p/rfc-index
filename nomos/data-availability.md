---
slug: 
title: NOMOS-DATA-AVAILABILITY
name: Nomos Data Availability
status: raw
tags: Nomos
editor: 
contributors:
  
---

## Abstract

This specification describes the varies components comprising the data availability portion for the Nomos base layer.

## Background
Nomos is a cluster of blockchains known as zones.
Zones are layer 2 blockchains that utilize Nomos to maintain sovereignty.
Nomos blockchain has two layers that are the most important components for zones. 
One important layer is the base layer which provides a data availibility guarantees to the network. 
The second layer is the coordination layer which enables state transition verification through zero-knowledge validity proofs. 
Nomos zones can to utilize the base layer so users, light clients, 
have the ability to obtain all block data and process it locally.
To achieve this, 
the data availbilty mechanism within Nomos provides guarantees that transaction data within Nomos Zones to be vaild.

## Motivation


## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

Nomos data availibity layer consist of two type of nodes.
Storage nodes store column data and commitments, and 
light nodes verify data availibity through sharding.

Light Nodes

### Data Availability Flow

Zones send block data to base layer to verify the data.
- Data is chucked using an algorithm prefered by the Zone( txns data, smart contract data?)
- 

