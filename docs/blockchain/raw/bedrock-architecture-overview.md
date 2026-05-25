# BEDROCK-ARCHITECTURE-OVERVIEW

| Field | Value |
| --- | --- |
| Name | Bedrock Architecture Overview |
| Slug | 146 |
| Status | raw |
| Category | Informational |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Álvaro Castro-Castilla <alvaro@logos.co>, Daniel Kashepava <danielkashepava@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-30** — [`0ef87b1`](https://github.com/logos-co/logos-lips/blob/0ef87b1ba9491c854e48c8dfd7574d34ec69c704/docs/blockchain/raw/bedrock-architecture-overview.md) — New RFC: CODEX-MANIFEST (#191)
- **2026-01-30** — [`5c123d6`](https://github.com/logos-co/logos-lips/blob/5c123d6b676be36053d5d9b9d67bb757138c2ace/docs/blockchain/raw/bedrock-architecture-overview.md) — Nomos/raw/bedrock architecture overview raw (#257)

<!-- timeline:end -->

Owners: @David Rusu

Reviewers: @lvaro Castro-Castilla @Daniel Kashepava

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2025-08-22 |

# Introduction

Bedrock enables high-performance Sovereign Rollups to leverage the security guarantees of Nomos. Sovereign Rollups build on Nomos through Bedrock Mantle, Bedrocks minimal execution layer which in turn runs on Cryptarchia, the Nomos consensus protocol. Taken together, Bedrock provides a private, highly scalable and resilient substrate for high-performance decentralized applications.

# Overview

Bedrock is composed of Cryptarchia and Bedrock Mantle. Bedrock is in turn supported by the Bedrock Services: Blend Network and NomosDA. Together they provide an interface for building high performance Sovereign Rollups that leverage the security and resilience of Nomos.

![](https://nomos-tech.notion.site/image/attachment%3A76639ee2-044c-49a1-b7e5-eac1db7a4e20%3AScreenshot_2025-08-21_at_12.55.03_PM.png?table=block&id=24d261aa-09df-8063-92a2-c620fecd05d6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Bedrock Mantle

Mantle forms the minimal execution layer of Nomos. Mantle Transactions consist of a sequence of Operations together with a Ledger Transaction used for paying fees and transferring funds.

Sovereign Rollups make use of Mantle Transactions when posting their updates to Nomos. This is done through the use of Mantle Channels and Channel Operations.

![](https://nomos-tech.notion.site/image/attachment%3A384930ce-2d0e-47b4-a1d6-9b4175e27c5e%3AScreenshot_2025-08-15_at_2.31.16_AM.png?table=block&id=250261aa-09df-80a6-aa2b-df73d6e0a54b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Mantle Channels

Mantle Channels are lightweight virtual chains overlaid on top of the Nomos Blockchain. Sovereign Rollups are built on top of these channels, allowing them to outsource the hard parts of running a decentralized service to Nomos, namely ordering and replicating state updates.

Channels are permissioned, ordered logs of messages. These messages are signed by the Channel owner and come in two types: Inscriptions or Blobs. Inscriptions store the message data permanently in-ledger, while Blobs store only a commitment to the message data permanently. The actual message data is stored temporarily in NomosDA, just long enough for interested parties to fetch a copy for themselves.

![](https://nomos-tech.notion.site/image/attachment%3A9bbc44ba-a58b-4793-b46a-2416d09a08a0%3AScreenshot_2025-08-15_at_3.04.18_AM.png?table=block&id=250261aa-09df-8019-8525-f9d5dc731f5a&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=640&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### A Note on Transient Blobs

The fact that Blobs are stored only temporarily in NomosDA allows Nomos to provide cheap, temporary storage for Sovereign Rollups without incurring long-term scalability concerns. The network can serve a large amount of data without the risk of bloating with obsolete data after years of operations.

At the same time, the transient nature of Blobs shifts the burden of long-term replication from the Nomos Network to the parties interested in that Blob data - that is, the Sovereign Rollup operators, their clients, and other interested parties (archival nodes, block explorers, etc.). So long as at least one party holds a copy of a Blob and is willing to provide it to the network, the SR can continue to be verified by checking provided Blobs against their corresponding on-chain Blob commitments, which are stored permanently on the Nomos blockchain.

## Cryptarchia

Bedrock Mantle is powered by [Cryptarchia](https://nomos-tech.notion.site/1fd261aa09df81618a76e0ac0f7f154f?pvs=25), a highly scalable, permisionless consensus protocol optimized for privacy and resilience. Cryptarchia is a Private Proof of Stake (PPoS) consensus protocol with properties very similar to Bitcoin. Just like in Bitcoin, where a miners hashing power is not revealed when they win a block, we ensure privacy for block proposers by breaking the link between a proposal and its proposer. Unlike Bitcoin, Nomos extends block proposer confidentiality to the network layer by routing proposals through the Blend Network, making network analysis attacks prohibitively expensive.

## Sovereign Rollups

Sovereign Rollups bridge the gap between traditional server-based applications and decentralized, permissionless applications.

Sovereign Rollups alleviate the contention caused by decentralized applications competing for the limited resources of a single threaded VM (e.g. EVM in Ethereum) while still remaining auditable and fault tolerant. This is achieved through shifting transaction ordering and execution off of the main chain into SR nodes, with SR nodes posting only a state diff or batch of transactions to Nomos as an opaque data Blob.

![](https://nomos-tech.notion.site/image/attachment%3Aa4bdf3d0-2a6e-479a-a304-8f7efa7f1939%3AScreenshot_2025-08-15_at_6.31.51_PM.png?table=block&id=250261aa-09df-8071-8826-dea2bdb4e41b&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
Typical end-to-end flow for clients interacting with a Sovereign Rollup, which in turn interacts with Bedrock. Clients send transactions to Sovereign Rollups who order and bundle them into Blobs, which are stored on Nomos. Clients can get finality guarantees by observing the Nomos blockchain and watching for the inclusion of their transactions.
```

Sovereign Rollups form a virtual chain overlaid on top of the Nomos Blockchain. This architecture allows application developers to easily spin up high performance applications while taking advantage of the security of Nomos to distribute the application state widely for auditing and resilience purposes.

