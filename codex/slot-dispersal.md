---
title: CODEX-SLOT-DISPERSAL
name: Codex SLOT Dispersal
status: raw
tags: codex
editor: 
contributors:
---

## Abstract

This specification desribes a method that is used by the Codex network for slot dispersal.
To achieve a true decentralized storage network, data being stored on mutlple nodes is required.

## Motivation
Client nodes benefit from resistant data storage when multiple nodes are storing their requested data.
In a marketplace envirnoment where storage providers announce storage availability,
high performance nodes may have an advantage to be choosen to store requested data.
This creates a centralized scenario as only high performance nodes will participate 
and be rewarded in the network. 

The Codex network does not implement a first come, first serve method to avoid centralized behaviors.
Instead, the Codex network encourages stroage requests to allow only a select few storage providers to create a storage contracts with the client node requests.

## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

Storage providers compete with one another to store data from storage request.
Before a storage providers can download the data, 
they MUST be selected to obtain a reseversation of a slot.

The Codex network using Kademlia distance function to select eligible  storage providers per slot.
This starts with a random source address hash contructed as:

    hash(blockHash, requestId, slotIndex, reservationIndex)

`blockHash`: 

`requestId`:

`slotIndex`:

`reservationIndex`:

The source address is used along with the storage provider's blockchain address to calculate the Kademlia distance.
This is represented by:

$$ XOR(A,A_0) $$

The calculated Kademlia distance for a storage provider MUST be greater than the allowed distance.
The allowed distance over time $t_1$, can be defined as $2^{256} * F(t_1)$.
When the storage provider's distance is greater than the allowed distance,
the storage provider SHOULD be eligible to to obtain a slot reservation.
- Note after eligiblity, the storage provider MUST provide token collateral and storage proofs

When the value of the allowed distance increases,
more storage providers SHOULD be elgiblable to participate in reserving a slot.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References



