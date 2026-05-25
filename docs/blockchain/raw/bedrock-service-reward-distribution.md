# BEDROCK-SERVICE-REWARD-DISTRIBUTION

| Field | Value |
| --- | --- |
| Name | Bedrock v1.2 Service Reward Distribution Protocol |
| Slug | 86 |
| Status | raw |
| Category | Standards Track |
| Editor | Thomas Lavaur <thomaslavaur@logos.co> |
| Contributors | David Rusu <davidrusu@logos.co>, Mehmet Gonen <mehmet@logos.co>, Marcin Pawlowski <marcin@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-service-reward-distribution.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-service-reward-distribution.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revisions History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial version. | 2025-11-03 |
| 1.1.0 | Removed references to DA Replaced references to Nomos with Logos Blockchain | 2026-04-17 |
| 1.2.1 | [Not found](https://nomos-tech.notion.site/335261aa09df807b9fe3c9bb9bd2c6db?pvs=24#335261aa09df807b9fe3c9bb9bd2c6db). | 2026-04-24 |

# Introduction

Nomos relies on multiple services, including the Data Availability and Blend Network - each operated by independent validator sets. For sustainability and fairness, these services must compensate service validators based on their participation. Validators first declare their participation through [🔀[1.0.0] Service Declaration Protocol](https://nomos-tech.notion.site/1-0-0-Service-Declaration-Protocol-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24). The Service Reward Distribution Protocol enables deterministic, efficient, and verifiable reward distribution to validators based on their activity within each service.

Each service defines:

- The session length, a fixed number of blocks during which its validator set remains unchanged.
- The validator activity rule that distinguishes between active and inactive validators.
- The reward formula for distributing the session’s rewards at the end of the session.

This document describes the protocol's logic for deterministically distributing rewards through Mantle Transactions for services.

# Overview

The protocol unfolds over three key phases, aligned with validator sessions:

1. Service Activity Tracking (Session N+1): Service validators submit signed activity messages to attest to their participation of session N through a Mantle Transaction, including an activity message (see [⚠️[1.4.0] Mantle - SDP_ACTIVE](https://nomos-tech.notion.site/SDP_ACTIVE-335261aa09df8065a38acff4b25aee82?pvs=24#335261aa09df81f5a839f173760b39f9)).
1. Service Reward Derivation (End of Session N+1): Nodes compute each validator’s reward based on validated activity messages and the different service reward policies.
1. Service Reward Distribution (First block of session N+2): Rewards are distributed to validators marked as active for the service. This is done by inserting new notes in the ledger corresponding to the reward amount for each active validator.

![](https://nomos-tech.notion.site/image/attachment%3A79e20c0f-a8b2-43fd-b6c6-8a49c1fb3d40%3ASans-titre-2024-11-18-1443.excalidraw.png?table=block&id=341261aa-09df-804b-ae7f-cec3cb5d830c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

Core Properties:

- Service rewards are distributed to the zk_id from validator [SDP declarations](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25)[.](https://www.notion.so/Service-Declaration-Protocol-Specification-17b8f96fb65c80c69c2ef55e22e29506?d=1b48f96fb65c8011987d001ce8523452#1b38f96fb65c802580d9c334281117a3)
- Minimal Block Overhead: rewards are directly added to the ledger without involving Mantle Transactions.

# Protocol

## Sessions

Each service defines its own session length (e.g., 10000 blocks), during which:

- The service validator set remains static.
- Activity criteria and reward policy are fixed.

## Activity tracking

Throughout session N+1, the block proposers integrate Mantle Transactions containing [SDP_ACTIVE Operations](https://nomos-tech.notion.site/335261aa09df8065a38acff4b25aee82?pvs=25#335261aa09df81f5a839f173760b39f9). These transactions originate from service validators and are used to [derive their activity according to the service provided policy](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25#1fd261aa09df812593c3e167ec7a6efc). The protocol does not prescribe a unique activity rule: each service defines what qualifies as valid participation, enabling flexibility across different services.

Service validators are economically incentivized to participate actively since only active validators will be rewarded. Moreover, by decoupling activity submission from reward calculation, the system remains robust to network latency.

This generalized mechanism accommodates a wide range of services without requiring specialized infrastructure. It enables services to evolve their own activity rules independently while preserving a shared framework for reward distribution.

## Service Reward Calculation

At the end of session N+1, service rewards for the validator n for the session N are computed by the different services taking as input the rewards of the session:

> **LaTeX equation** (source not captured by the Notion scrape). Please regenerate from the original Notion page.

Where $Rewards\_Session$ are the total rewards of session N. The $Rewards\_Session$ is determined by the [No access](https://nomos-tech.notion.site/269261aa09df80d88d2bfcfa253298ac?pvs=24#269261aa09df80d88d2bfcfa253298ac), which calculates how much each service receives based on fees burnt during session N and the blockchain's state. $Rewards^n$ is stored as an array that maps each validator's zk_id to their allocated reward.

## Service Reward Distribution

Starting immediately after session N+1, service rewards are distributed in the first block of session N+2. The rewards are inserted directly in the ledger without triggering any Mantle validation. The NoteId is computed using the result of hash([ServiceType](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25#1fd261aa09df81ee87a6fef65cadb4ea) || session_number) as the op_id. The output number corresponds to the position of the zk_id when sorted in ascending order.

The reward must:

- Transfer the correct reward amount according to [Service Reward Calculation](https://nomos-tech.notion.site/Service-Reward-Calculation-341261aa09df809cbdb6e4a0b0314c4f?pvs=24#341261aa09df805e9f9fcb80f7e7c3c7).2
- Be sent to the public key zk_id of the validator registered during [declaration of the service](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25#1fd261aa09df8192949ae1be9950c7e3).
- Be distributed into a single note if several rewards share the same zk_id.
- Be executed identically by every node processing the first block of session N+2. This happens by inserting notes in the ledger in ascending order of zk_id.
Nodes indirectly verify the correct inclusion of rewards because all consensus-validating nodes must maintain the same ledger view to derive the latest ledger root, which serves as input for verifying the [Proof of Leadership](https://nomos-tech.notion.site/21c261aa09df819ba5b6d95d0fe3066d).

