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

Authors: David Rusu <davidrusu@status.im>

# Revision History

# Introduction

Bedrock enables high-performance Sovereign Zones to leverage the security guarantees of Logos. Sovereign Zones build on the Logos Blockchain through Mantle, Bedrock���s minimal execution layer which in turn runs on Cryptarchia, Logos' consensus protocol. Taken together, Bedrock provides a private, highly scalable and resilient substrate for high-performance decentralized applications.

# Overview

Bedrock is composed of Cryptarchia and Bedrock Mantle. Bedrock is in turn supported by the Bedrock Services such as the Blend Network. Together, they provide an interface for building high performance Sovereign Zones that leverage the security and resilience of Logos.

![](https://nomos-tech.notion.site/image/attachment%3A2befde39-80d9-4c7a-a3df-2fd211b7afd6%3AScreenshot_2026-01-14_at_9.18.49_PM.png?table=block&id=2e0261aa-09df-8011-ba89-d121ebdc3c19&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Bedrock Mantle

Mantle forms the minimal execution layer of the Logos Blockchain. Mantle Transactions consist of a sequence of Operations together with a Ledger Transaction used for paying fees and transferring funds.

Sovereign Zones make use of Mantle Transactions when posting their updates to Bedrock. This is done through the use of Mantle channels and channel Operations.

![](https://nomos-tech.notion.site/image/attachment%3Af70c41fb-5866-4437-93d5-8d4624e7b5de%3AScreenshot_2026-01-14_at_9.19.29_PM.png?table=block&id=2e0261aa-09df-80e3-ab25-e6d79b7aaa77&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=660&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

### Mantle Channels

Mantle channels are lightweight virtual chains overlaid on top of the Logos Blockchain. Sovereign Zones are built on top of these channels, allowing them to outsource the hard parts of running a decentralized application to Logos, namely ordering and replicating state updates.

Channels are permissioned, ordered logs of messages. These messages, known as Inscriptions, are signed by an authorized party known as the sequencer,  storing the message data permanently in-ledger. A Mantle channel can support several authorized sequencers, who share the right to post messages to that channel. In this case, the parties take turns acting as sequencers in a round-robin fashion.

![](https://nomos-tech.notion.site/image/attachment%3Aa8e186f7-f4d7-43e4-b07a-dff4c4fde813%3AScreenshot_2025-11-24_at_6.45.49_PM_(1).png?table=block&id=2e0261aa-09df-80e0-92a3-dc2820adbb7e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=660&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Channel messages can be used by Sovereign Zone sequencers to asynchronously communicate and coordinate actions amongst themselves. This could include planning cross-Zone transactions that affect the state of several Zones, or agreeing to modify a channel's properties.

Every Mantle channel also has an associated token balance. This balance allows users to bridge tokens from Bedrock to Sovereign Zones and vice versa. Channel balances also facilitate atomic token transfers between several Sovereign Zones.

## Cryptarchia

Bedrock Mantle is powered by the [����[1.0.1] Cryptarchia Protocol](https://nomos-tech.notion.site/1-0-1-Cryptarchia-Protocol-21c261aa09df810cb85eff1c76e5798c?pvs=24), a highly scalable, permisionless consensus protocol optimized for privacy and resilience. Cryptarchia is a Private Proof of Stake (PPoS) consensus protocol with properties very similar to Bitcoin. Just like in Bitcoin, where a miner���s hashing power is not revealed when they win a block, we ensure privacy for block proposers by breaking the link between a proposal and its proposer. Unlike Bitcoin, the Logos Blockchain extends block proposer confidentiality to the network layer by routing proposals through the Blend Network, making network analysis attacks prohibitively expensive.

## Sovereign Zones

Sovereign Zones bridge the gap between traditional server-based applications and decentralized, permissionless applications.

Sovereign Zones alleviate the contention caused by decentralized applications competing for the limited resources of a single threaded VM (e.g. EVM in Ethereum) while still remaining auditable and fault tolerant. This is achieved through shifting transaction ordering and execution off of the main chain into SZ sequencer nodes, with SZ sequencers posting only a state diff or batch of transactions to Bedrock as an Inscription.

![](https://nomos-tech.notion.site/image/attachment%3Afdff755a-fac1-4c86-a5ae-0dc2bd850e5b%3AScreenshot_2026-01-14_at_9.16.49_PM.png?table=block&id=2e0261aa-09df-807c-aaa5-f7e0830169c5&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1420&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

```
Typical end-to-end flow for clients interacting with a Sovereign Zone, which in turn interacts with Bedrock. Clients send transactions to Sovereign Zones who order and bundle them into Inscriptions, which are stored on the Logos Blockchain. Clients can get finality guarantees by observing the Logos Blockchain and watching for the inclusion of their transactions.
```

Sovereign Zones form a virtual chain overlaid on top of the Logos Blockchain. This architecture allows application developers to easily spin up high performance applications while taking advantage of the security of Logos to distribute the application state widely for auditing and resilience purposes.

