---
title: NomosDA Network Specification
name: NomosDA Network Specification
status: raw
category:
tags: network, data-availability, da-nodes, executors, sampling
editor: Daniel Sanchez Quiros <danielsq@status.im>
contributors:
- Álvaro Castro-Castilla <alvaro@status.im>
- Daniel Kashepava <danielkashepava@status.im>
- Gusto Bacvinka <augustinas@status.im>
- Filip Dimitrijevic <filip@status.im>
---

## Introduction

NomosDA is the scalability solution protocol for data availability within the Nomos network. This document delineates the protocol's structure at the network level, identifies participants, and describes the interactions among its components.  
Please note that this document does not delve into the cryptographic aspects of the design. For comprehensive details on the cryptographic operations, refer to the Encoding Specification.

## Objectives

NomosDA was created to ensure that data from Nomos zones is distributed, verifiable, immutable, and accessible. At the same time, it is optimised for the following properties:

- **Decentralization**: NomosDA’s data availability guarantees must be achieved with minimal trust assumptions and centralised actors. Therefore, permissioned DA schemes involving a Data Availability Committee (DAC) had to be avoided in the design. Schemes that require some nodes to download the entire blob data were also off the list due to the disproportionate role played by these “supernodes”.

- **Scalability**: NomosDA is intended to be a bandwidth-scalable protocol, ensuring that its functions are maintained as the Nomos network grows. Therefore, NomosDA was designed to minimise the amount of data sent to participants, reducing the communication bottleneck and allowing more parties to participate in the DA process.

To achieve the above properties, NomosDA splits up zone data and distributes it among network participants, with cryptographic properties used to verify the data’s integrity. A major feature of this design is that parties who wish to receive an assurance of data availability can do so very quickly and with minimal hardware requirements. However, this comes at the cost of additional complexity and resources required by more integral participants.

## Requirements

In order to ensure that the above objectives are met, the NomosDA network requires a group of participants that undertake a greater burden in terms of active involvement in the protocol. Recognising that not all node operators can do so, NomosDA assigns different roles to different kinds of participants, depending on their ability and willingness to contribute more computing power and bandwidth to the protocol. It was therefore necessary for NomosDA to be implemented as an opt-in Service Network.

Because the NomosDA network has an arbitrary amount of participants, and the data is split into a fixed number of portions (see the Encoding & Verification Specification), it was necessary to define exactly how each portion is assigned to a participant who will receive and verify it. This assignment algorithm must also be flexible enough to ensure smooth operation in a variety of scenarios, including where there are more or fewer participants than the number of portions.

## Overview

### Network Participants

The NomosDA network includes three categories of participants:

- **Executors**: Tasked with the encoding and dispersal of data blobs.  
- **DA Nodes**: Receive and verify the encoded data, subsequently temporarily storing it for further network validation through sampling.  
- **Light Nodes**: Employ sampling to ascertain data availability.

### Network Distribution

The NomosDA network is segmented into `num_subnets` subnetworks. These subnetworks represent subsets of peers from the overarching network, each responsible for a distinct portion of the distributed encoded data. Peers in the network may engage in one or multiple subnetworks, contingent upon network size and participant count.

### Sub-protocols

The NomosDA protocol consists of the following sub-protocols:

- **Dispersal**: Describes how executors distribute encoded data blobs to subnetworks.  
- **Replication**: Defines how DA nodes distribute encoded data blobs within subnetworks.  
- **Sampling**: Used by sampling clients (e.g., light clients) to verify the availability of previously dispersed and replicated data.  
- **Reconstruction**: Describes gathering and decoding dispersed data back into its original form.  
- **Indexing**: Tracks and exposes blob metadata on-chain.

## Construction

### NomosDA Network Registration

Entities wishing to participate in NomosDA must declare their role via SDP (Service Declaration Protocol). Once declared, they're accounted for in the subnetwork construction.

This enables participation in:

- Dispersal (as executor)
- Replication & sampling (as DA node)
- Sampling (as light node)

### Subnetwork Assignment

NomosDA defines `num_subnets` virtual subnetworks. A subnetwork is a logical group of peers with full mesh connectivity. Subnetwork membership is determined by SDP and is used to coordinate dispersal and replication operations.

#### Assignment Algorithm

```python
from itertools import cycle
from typing import List, Sequence, Set, TypeAlias
import ipaddress

# A NodeDef is a tuple of an SDP peer id and an IP address
DA_ROLE_ID: TypeAlias = bytes
NodeDef = tuple[DA_ROLE_ID, ipaddress.ip_address]

# number of subnets 2048 for current setup)
num_subnets: int,
# minimum filler number per subnetwork (usually total_peers/num_subnets)
replication_factor: int 
) -> List[Set[NodeDef]]:
    """
    Calculate in which subnet(s) to place each node.
    Fills up each subnet up to a count in an iterative mode
    """
    nodes_list = sorted(nodes_list)
    nodes = cycle(nodes_list)
    subnetwork_size = max(len(nodes_list)/num_subnets, replication_factor)
    subnets: List[Set[NodeDef]] = []
    i = 0
    for _ in range(num_subnets):
        subnet = set()
        for _ in range(int(subnetwork_size)):
            subnet.add(nodes_list[i])
            i = (i + 1) % len(nodes_list)
        subnets.append(subnet)
    return subnets
```

## Executor Connections

Each executor maintains a connection with one peer per subnetwork, necessitating at least num_subnets stable and healthy connections.

```python
def select_peers(
    subnetworks: Sequence[Set[PeerId]],
    filtered_subnetworks: Set[int],
    filtered_peers: Set[PeerId]
) -> Set[PeerId]:
    result = set()
    for i, subnetwork in enumerate(subnetworks):
        available_peers = subnetwork - filtered_peers
        if i not in filtered_subnetworks and available_peers:
            result.add(next(iter(available_peers)))
    return result
```

## NomosDA Protocol Steps

### Dispersal

1. Executors encode data.
2. They distribute encoded data to subnetworks (0 to num_subnets - 1).
3. Executors may sample to confirm success.
4. Publish blob_id and metadata to mempool.

### Replication

DA nodes receive and validate columns. If valid, they replicate to connected peers.  
Only one replication per blob is performed.

### Sampling

1. Triggered by role.
2. Node selects sample_size random subnetworks.
3. Queries each for blob column availability. All must respond affirmatively.

### Network Schematics

```flowchart TD
subgraph Replication
    subgraph Subnetwork_N
        N10 -->|Replicate| N20
        N20 -->|Replicate| N30
        N30 -->|Replicate| N10
    end
    subgraph Subnetwork_0
        N1 -->|Replicate| N2
        N2 -->|Replicate| N3
        N3 -->|Replicate| N1
    end
end
subgraph Sampling
    N9 -->|Sample 0| N2
    N9 -->|Sample S| N20
end
subgraph Dispersal
    Executor -->|Disperse| N1
    Executor -->|Disperse| N10
end
```

### Details

The NomosDA network uses QUIC with multiplexed streams.

Stream protocol IDs:

- /nomos/da/{version}/dispersal
- /nomos/da/{version}/replication
- /nomos/da/{version}/sampling

Through stream reuse and virtual subnetworks, the protocol remains scalable.
