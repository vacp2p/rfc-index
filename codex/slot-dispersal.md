---
title: CODEX-SLOT-DISPERSAL
name: Codex SLOT Dispersal
status: raw
tags: codex
editor: 
contributors:
---

## Abstract

This specification describes a method used by the Codex network for node dispersal for filling slot request.
To achieve a truely decentralized storage network, data being stored on mutlple nodes should be prioritized.

## Motivation
Client nodes benefit from resilient data storage when multiple nodes are storing their requested data.
In a distbuted storage solution, 
a storage marketplace allows storage providers the ability to announce storage availability and
storage request to find hosting.
High performance nodes may have an advantage over a majority of nodes participating in the marketplace as storage requests may always choose the high proformance nodes to store data.
This creates a centralized scenario as only high performance nodes will participate 
and be rewarded in the network. 

The Codex network does not implement a first come, first serve method to avoid centralized behaviors.
Instead, the Codex network encourages storage requests to allow only a select few storage providers to create a storage contracts with the client node requests.

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


The allowed distance over time $t_1$, can be defined as $2^{256} * F(t_1)$.
When the storage provider's distance is greater than the allowed distance,
the storage provider SHOULD be eligible to to obtain a slot reservation.
- Note after eligiblity, the storage provider MUST provide token collateral and storage proofs to make change the state of a slot from a reserved state to a filled state, see [slots](https://github.com/vacp2p/rfc-index/blob/codex-marketplace/codex/marketplace.md#slots).

### Filling Slot

When the value of the allowed distance increases,
more storage providers SHOULD be elgiblable to participate in reserving a slot.
The Codex network allows a storage provider is allowed to fill a slot after calculating the storage provider's Kademlia distance is less than the allowed distance.
The total value storage providers MUST obtain can be defined as:

$$ XOR(A,A_0) < 2^{256} * F(t_1) $$

Eligible storage providers represented below:

                             start point
                                  |           Kademlia distance
            t=3    t=2    t=1     v
      <------(------(------(------·------)------)------)------>
                      ^                            ^
                      |                            |
                 this provider is               this provider is
                  allowed at t=2                 allowed at t=3

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
1. [slots](https://github.com/vacp2p/rfc-index/blob/codex-marketplace/codex/marketplace.md#slots)


