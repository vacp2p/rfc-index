--- 
title: NOMOS-DATA-AVAILABILITY-LAYER
name: Nomos Data Availability Protocol
status: raw
tags: nomos
editor: 
contributors:
  
---

## Abstract

This specification describes the varies components for the data availability portion for the Nomos base layer.

## Background
Nomos is a cluster of blockchains known as zones.
Zones are layer 2 blockchains that utilize Nomos to maintain sovereignty.
They are initialized by the Nomos network and can utilize the Nomos services, but 
provide resources on their own.
Nomos blockchain has two layers that are the most important components for zones. 
One important layer is the base layer which provides a data availibility guarantees to the network. 
The second layer is the coordination layer which enables state transition verification through zero-knowledge validity proofs. 
Nomos zones can to utilize the base layer so users, light clients, 
have the ability to obtain all block data and process it locally.
To achieve this, 
the data availbilty mechanism within Nomos provides guarantees that transaction data within Nomos Zones to be vaild.

## Motivation and Goal
Decentralized blockchains require full nodes to verify network transactions by downloading all the data of the network.
Light nodes on the other do not download the entire network data,
but require strong data availibility guarantees. 
There is a need for any node to prove the validity of some transaction data being added to the blockchain,
without the need for the node to download all the transaction data.
Downloading all the data does not allow the blockchain network to have light nodes,
requiring all node roles to be limited to full nodes, and
linimiting the scalability of the network.

The Nomos data availability layer is a service that used by Zones for data guarantees.
This includes a data availability sampling mechanism, 
and privacy-perserving mechanism to solve the data availability problem.
The base layer provides guarantees of data availability to Nomos zones for a limit amount of time.

## Specification
The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

The data availability service of the Nomos base layer consist of two roles, light nodes and storage nodes,
who interact with the service.
Nodes who decide to provide resources to the data availibilty service are considered to be a Nomos base-layer node, or storage node.
Light nodes are utilized within Nomos zones and is not a extensive resource role.
In other words based on other roles of the Nomos network, a light node SHOULD NOT download large amounts of block data owned by Zones,
MAY selectivly vailidate zk-proofs from the Nomos coordination layer, but
SHOULD verify data availibility of the base layer.

Data availibity on the base layer is only a temporary guarantee.
The data can only be verified for a predetermined time, based on the Nomos network.
The base layer MUST NOT provide long term incentives or 
allocate resources to repair missing data.
Zones act as [Data Availability Committees](#) for their own blockchain state.
Zones SHOULD provide data availability for the zone blockchain,
in the event that light nodes can not access data from a zone,
light nodess MAY utilize the Nomos data avilability of the base layer.

Nodes that participate in a Nomos zone MUST also be a Nomos data availibility node.
Nomos base layer uses libp2p publish/subscribe protocol to handle message passing between nodes in the network.
Using gossipsub, nodes configuations SHOULD define a `pubsub-topic` shared by all Nomos data availiability nodes:

```
pubsub-topic = 'DA_TOPIC'

```
### Message Passing

Communication occurs between different zones with [Data Availability Committees](#) directly.
Nomos nodes use a libp2p swarm to read data from other nodes participating in a zone as a validator.
It is the responsibility of zones to maintain the swarm.
When a node in the swarm does not provide access to data,
light nodes MAY use the Nomos data availbilty layer.

#### Sending Data

Zones are responisble for creating data chunks that need to be stored on the blockchain.
The data chunks are encoded using a Reed-Solomon encoding.
Once encoded, 
the data is is dispersed to different Nomos data availibilty nodes on the base layer.
When a node receives a data chunks from a zone,
the data chunk is stored in memory.
The data availability node sends an attestation back to the zone block builder confirming the data has been received.
The attesstation is created with the following values:

```
// Nomos node hash using Blake2 algorithm
attestation_hash = hash(blob_hash, DAnode);

```
This attestation MUST be included in the [VID certificate](#),
which is included in the block.
The certificate is sent to the Nomos base layer mempool.

### Blockchain Data

The block producer assigned by the zone, which MAY also be a Nomos data availibility node,
MUST pick the certificate to be added to a block from the mempool in the order it was received.
A block contains a list of certificates.
Once a new block from a zone is created, 
it MUST be sent to the base layer to be persisted.
A data availibilty node will verifiy that it has the data chuck in memory as same.
 
Zones MAY utilize the data availability of the base layer and
pay for the resouce they consume with the native token.

- Nodes in Nomos zones are only REQUIRED to download data related to zones they prefer.

Zone block builder waits for signed data to be returned
- Verifies data chucks are are hashed and signed
- Includes hash in next/current block

Data included in hash for next block in Zone
- Zone block builders create certificates, a Verifiable Information Dispersal Certificate,
- Zone send certificates to DA nodes to store in the NomosDA node's mempool

### Storage Nodes 

Storage nodes MUST NOT process data, 
but only provide data availability guarantees for a limit amount of time.
The role of a storage node is to store polynimal commitment schemes for Nomos zones.

The storage node will encode the data chunks recieved with:

column data and commitments.
NomosDA storage nodes join a membership based list using libp2p,
to announce participation as data availability node role.
The list SHOULD be used by light nodes and 
Nomos zones to find nodes provide data availability.
- storage nodes SHOULD be the only node assigned to a data availability `pubsub-topic`.
Storage of data,
the data MUST not be interpeted or accessed, except for [data availability sampling](#data-sampling), or
block reconstruction by light clients.

### Light Nodes

Light nodes verify block data with data availibity through sharding.
Data originate from Nomos zones by light nodes looking to store data on chain.

- Light clients send data to block builders,
block builders send data to be verified by the data availibilty layer.


### Certificate
A verifiable information dispersal certificate is a list of signutures from DA nodes.
 
- They contain values that verifies data chucks from the zone
- Data chucks are sent with aggregate commitments, a list of row commitments for entire data blob, and a column commitment for the data chuck
- DA nodes check commitments and signs commitments once verified
- The VID certificate is a list of signatures
- Block producers receive certificates and verify
- Block producer hash aggregate commitments and include it in the block

### Data Stored on the Blockchain
Block producers receive certificates (VID) from Zones with the following values:
After block producer verify VID certificates,
the following data is store on the blockchain:

- CertificateID: A hash of the VID Certificate (including the C_agg and signatures from DA Nodes 
- AppID: The application identification for the specific application(zone) for the data chunk
- Index: A number for a particular sequence or position of the data chunk within the context of its AppID

### Data Availbilty Committees

### Data Sampling
Light nodes sample data from zones for it's validity.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

