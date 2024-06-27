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

### Storage Nodes 

Storage nodes MUST NOT process data, 
but only provide data availability guarantees for a limit amount of time.
The role of a storage node is to store polynimal commitment schemes for Nomos zones.

The storage node will encode the data chunks recieved with:
-

- column data and commitments.
NomosDA storage nodes join a membership based list using libp2p,
to announce participation as data availability node role.
Nodes must register during a proof of prossion stage where private keys are verified?****
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


### Message Passing

Nodes that participate in a Nomos zone MUST also be a Nomos data availibility node.
Nomos base layer uses libp2p publish/subscribe protocol to handle message passing between nodes in the network.
Using gossipsub, nodes configuations SHOULD define a `pubsub-topic` shared by all Nomos data availiability nodes:

```rs
pubsub-topic = 'DA_TOPIC';
```

Communication occurs between different zones with [Data Availability Committees](#) directly.
Nomos nodes use a libp2p swarm to read data from other nodes participating in a zone as a validator.
It is the responsibility of zones to maintain the swarm.
When a node in the swarm does not provide access to data,
light nodes MAY use the Nomos data availbilty layer.

#### Sending Data

Zones are responisble for creating data chunks that need to be stored on the blockchain.
The data SHOULD be sent to Nomos data availibity nodes.

#### Encoding and Verification

Nomos protocol allows nodes within a zone to encode data chucks using Reed Solomon and KGZ commitments. 
Data chunks are divided into a finite field element, 
a two-dimensional array also known as a matrices,
where data is organized into rows and columns.
For example: a matrix represented as $Data_{}$ for block data divided into chunks, 
which is represented as ${ \Large c_{jk} }$:

$${ \Large Data = \begin{bmatrix} c_{11} & c_{12} & c_{13} & c_{...} & c_{1k} \cr c_{21} & c_{22} & c_{23} & c_{...} & c_{2k}  \cr c_{31} & c_{32} & c_{33} & c_{...} & c_{3k} \cr c_{...} & c_{...} & c_{...} & c_{...} & c_{...} \cr c_{j1} & c_{j2} & c_{j3} & c_{...} & c_{jk} \end{bmatrix}}$$

Each row is a chunk of data and each column is considered a piece.
So there are ${ \Large k_{} }$ data pieces which include ${ \Large j_{} }$ data chucks.
- Each chuck SHOULD limit byte size of data

For every row ${ \Large i_{} }$,
a unique polynomial ${ \Large f_{i} }$ such that ${ \Large c_{ig} = f_{i}(w^{(g-1)}) }$,
for ${ \Large i_{} = 1,...,k }$ and ${ \Large g_{} = 1,...,j }$.

Random KGZ commitment values for the polynomials compute to:

$${ \Large f_{i} = (c_{i1}, c_{i2}, c_{i3},..., c_{ik}) }$$ and compute ${ \Large r_{i} = com(f_{i}) }$.

##### Reed Solomon Encoding

Nomos protocol REQUIRES data to be encoded using Reed-Solomon encoding after the data blob is divided into chucks,
placed into a matrix of row and columns, and
KZG commitments are computed for each data piece.
Encoding allows zones to ensure the security and integity of its blockchain data.
Using Reed-Solomon encoding, the martix from the previous step is expanded by the rows for redundancy.

The polynomial ${ \Large c_{ig} = f_{i}(w^{(g-1)}) }$ at new points ${ \Large w_{j} }$ where ${ \Large j_{} = k+1, k+2, ..., n }$.
The extended data can be demonstrated:

$${ \Large Extended Data = \begin{bmatrix} c_{11} & c_{12} & c_{...} & c_{1k} & c_{1(k+1)} & c_{1(k+2)} & c_{...} & c_{1(2k)} \cr c_{21} & c_{22} & c_{...} & c_{2k} & c_{...} & c_{...} & c_{...} & c_{...} \cr c_{31} & c_{32} & c_{...} & c_{3k} & c_{...} & c_{...} & c_{...} & c_{...} \cr c_{...} & c_{...} & c_{...} & c_{...} & c_{...} & c_{...} & c_{...} & c_{...} \cr c_{j1} & c_{j2} & c_{...} & c_{jk} & c_{j(k+1)} & c_{j(k+2)} & c_{...} & c_{j(2k)} \end{bmatrix}}$$

- There is an expansion factor of 1/2, so ${ \Large n_{} = 2k }$
- Calculate the row chuck: ${ \Large eval(f_{i}, w^{(j-1)}) \rightarrow c_{ji}, \pi_{c_{ji}} }$

##### Hash and Commitment Value of Colunms

Next, a dispersal client calculates the commitment for the inputs of each column using KGZ commitments.
Assume, ${ \Large j = 1,...,2k }$:

Each column contains ${ \Large j_{} }$ data chucks. 
Using Lagrange interpolation, we can calculate the unique polynomial defined by these chunks. 
Let's denote this polynomial as $\theta$

The commitment values for each column are calculated as follows:

${\Large \theta_j=\text{Interpolate}(data_1^j,data_2^j,\dots,data_\ell^j)}$

${ \Large C_j=com(\theta_j)}$

- In this protocol, we use elliptic curve as a group,
thus the entries of $C_j$’s are also elliptic curve points.
Let’s represent the $x$-coordinate of $C_j$ as $C_j^x$ and the $y $-coordinate of $C_j$ as $C_1^y$.
If you have just $C_j^x$ and one bit of $C_j^y$ then you can construct $C_j$.
Therefore, there is no need to use both coordinates of $C_j$.
However, for the sake of simplicity in the representation, we use only the value $C_j$ for now.

- We also calculate the hash of column data such that;
    
    $H_j=Hash(01data_j^1||02data_j^2||\dots||0\ell data_\ell^j)$

##### Aggregate Column Commitment

The position integrity of each column for all data can be provided by a new column commitments. 
To link each column to one another, we will calculate a new commitment value.

Each $\{H_j, C_j\}$ can be considered the new vector and assume they are in evaluation form. 
In this case, calculate a new polynomial $\Phi$ and vector commitment value $C_{agg}$ as follows:
    
$\Phi=\text{Interpolate}(H_1, C_1,H_2, C_2,\dots,H_n, C_n)$
    
$C_{agg}=com(\Phi)$
    
Also calculate the proof value $\pi_{H_j,C_j}$ for each column.


Data chucks are sent with aggregate commitments, a list of row commitments for entire data blob, and 
a column commitment for the specific data chuck.

##### Dispersal

###### Verification Process

Once encoded, 
the data is dispersed to different Nomos data availibilty provider nodes that have joined a subnet on the base layer.
It is RECCOMENDED that the dispersal client sends a column to 4096 provider nodes for better bandwidth optimization.
A dispersal client sends the following:

```python

class EncodedData:
  column_data: 
  extended_matrix: ChuckMatrix
  row_commitments: List[Commitments]
  row_proofs: List[List[Proof]]
  column_commitment: List[Commitment]
  aggregated_column_commitment: Commitment
  aggregated_column_proofs: List[Proof]
```
These values are represented as:

- `extended_matrix` : 
- `row_commitments` : ${ \Large \{r_1,r_2,\dots,r_{\ell}\} }$
- `row_proofs` : ${ \Large \{\pi^j_{r_1},\pi^j_{r_2}, \dots,\pi^j_{r_\ell}\} }$
- `column_data` : ${ \Large \{data_1^j,data_2^j,\dots,data_\ell^j\} }$
- `column_commitment` : ${ \Large C_{j} }$
- `aggregated_column_commitment` : ${ \Large C_{agg} }$
- `aggregated_column_proofs` : ${ \Large \pi_{H_j,C_j} }$

When a provider node receives data chunks from dispersal nodes,
the data chunk is stored in the provider's node memory.
The following steps SHOULD occur once data is received by a provider node:

1. Checks the `aggregated_column_proofs` and verify the proofs.
Zone calculates the $eval$ value and sends it to $node_j$.

${ \Large eval(\Phi,w^{j-1})\to H_j, C_j }$, ${ \Large \pi_{H_j,C_j} }$

2. Calculates the `column_commitment` data.

${ \Large \theta'_j=\text{Interpolate}(data_1^j,data_2^j,\...\ell^j) }$

This value SHOULD be equal to ${ \Large C_j }$ : ${ \Large C_j\stackrel{?}{=}com(\theta'_j) }$

3. Calulates the hash of `column_data` :

${ \Large H_j=Hash(01data_j^1||02data_j^2||\dots||0\ell data_\ell^j)}$

Then verifies the proof :

${ \Large verify(r_i, data_i^j, \pi_{r_i}^j)\to true/false }$

4. For each `row_commitment`, verifies the proof of every chunk against its corresponding row commitment:

${ \Large verify(r_i, data_i^j, \pi_{r_i}^j)\to true/false }$

If all verification steps are true, this proves that the data has been encoded correctly.
 
### VID Certificate

A verifiable information dispersal certificate, VID certificate,
is a list of attestation from data availibility nodes.
It is used to verify that the data chucks have been dispersed properly amongst nodes in the base layer.
The provider node signs an attestation that contain the hash value of the `row_commitment` and 
of the `aggregated_column_commitment`.
Signitures are verified by dispersal clients and
valid signitures SHOULD be added to the VID certificate

For every provider node $j$, assuming $sk_j$ is the private key, a signature is generated as follows:
    
${ \Large \sigma_j=Sign(sk_j, hash(C_{agg}, r_1,r_2,\dots,r_{\ell})) }$

The provider node sends the signed attestation back to the zone dispersal clients confirming the data has been received and
verified.
Once a dispersal client verifies data chucks have been hashed and signed by the base layer,
the VID certificate SHOULD be created.

The attesstation is created with the following values:


```rs
// Provider node SHOULD hash using Blake2 algorithm
// blob_hash : Hash of row_commitment and column_commitiment
fn sendAsstation () {
  attestation_hash = hash(blob_hash, DAnode);
}
```

The VID certificate is then sent to block builder to be accepted through concensus, 
as desirbed in [Cryptarchia](#).

### Data Availability Sampling

Light nodes MAY choose to be a data availability sampling node.
This node can participate in any other NOMOS service while providing verification of data dispersal services.
For example, a dispersal client can send data to be available through the base layer and
decide to perform data availability sampling to have a great assurance that the data is available.
This would reduce the potential threats from malicious or 
faulty nodes not replicating data in their subnets.

The following steps are REQUIRED by a data availability sampling node to verify data dispersal:

1. Choose a random column value and row value from base layer provider nodes.
2. Assuming provider node $node_t$, it calculates the $eval$ value for the `column_commitment`.
Also calculates the `row_commitment` value $r_{t'}$ and the proof of it.
Then sends these values to the sampling node.

${ \Large eval(\Phi,w^{t-1})\to C_t$, $\pi_{C_t} }$
    
3. Sampling nodes verifies the `row_commitment` and the `column_commitment` as follows:

${ \Large verify(C_{agg},C_r, \pi_{C_r})\to true/false }$

${ \Large verify(C_{agg},C_r, \pi_{C_r})\to true/false}$
    
4. Also, $node_t$ sends to  to the light nodes.


#### Data Availability Committees
Zones create data availability committees for their own block data.
, see [Blockchain Data](#BlockchainData) bellow.

### Blockchain Data

The block data is stored by nodes within zones and can be retreived using the [read api](#).
A block producer, which MAY also be a Nomos data availibility node,
MUST choose certificates that need to be added to a new block from the NomosDA mempool in the order it was received.
- A block will contain a list of certificates.
Once a new block for a zone is created, 
it MUST be sent to the base layer to be persisted for a short period of time.
A zone MAY choose to use alternative methods to persist block data, like decentralized storage solutions.
A data availibilty node will verifiy the certificates of a block recieved is stored in its node memory.
If the node has the same data,
the block SHOULD be persisted.
If the node does not have the data,
the block SHOULD be skipped.


Light nodes are not REQUIRED to download all the blockchain data belonging to a zone. 
To fulfill this requirement, 
zone partipants MAY utilize the data availability of the base layer to retrieve block data and
pay for this resource with the native token.
Other nodes within the a zone are REQUIRED to download block data only related to prefered zones.

Data included in hash for next block in Zone

After block producer verify VID certificates,
the following data is store on the blockchain:

- CertificateID: A hash of the VID Certificate (including the C_agg and signatures from DA Nodes) 
- AppID: The application identification for the specific application(zone) for the data chunk
- Index: A number for a particular sequence or position of the data chunk within the context of its AppID

#### Metadata

Block producers receive certificates (VID) from Zones with metdata, `AppId` and 
`Index`. 
The metadat values are also stored in the blockchain

### Data Availability Core API

Data availiablity nodes utilize `read` and `write` API functions.
The `read` function allow node to query for information and
`write` function for communication for multiple services.
Data chuck is encoded as described above in [Encoding and Verification](#) and
delivered using the message passing protocol described above in [Message Passing](#).

The API functions are detailed below:

```python

class Chunk:
  def __init__(self, data, app_id, index):
    self.data = data
    self.app_id = app_id
    self.index = index

class Metadata:
  def __init__(self, app_id, index):
    self.app_id = app_id
    self.index = index

class Certificate:
  def __init__(self, proof, chunks_info):
    self.proof = proof
    self.chunks_info = chunks_info

class Block:
  def __init__(self, certificates):
    self.certificates = certificates

def receive_chunk():
      # Receives from network new chunks to be processed
      # Returns a tuple of (Chunk, Metadata)
      chunk = Chunk(data = "chunk_data", app_id = "app_id", index = "index")
      metadata = Metadata(app_id = "app_id", index = "index")
      return chunk, metadata

  def receive_block():
      # Read from blockchain latest blocks added
      # Returns a Block
      certificate = Certificate(proof = "proof", chunks_info = "chunks_info")
      block = Block(certificates = [certificate])
      return block

  def write_to_cache(chunk, metadata):
    # Logic to write the chunk {metadata.index} to cache

  def write_to_storage(certificate):
    # Logic to write data to storage based on the certificate.proof

  def da_node():
      while True:
          # Receiving chunk and metadata
          chunk, metadata = receive_chunk()
          write_to_cache(chunk, metadata)

          # Receiving a block
          block = receive_block()

          for certificate in block.certificates:
            write_to_storage(certificate)

```
- d

### Security Consideration

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

