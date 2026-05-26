# CRYPTARCHIA-V1-BOOTSTR-SYNC

| Field | Value |
| --- | --- |
| Name | Cryptarchia v1 Bootstrapping & Synchronization |
| Slug | 96 |
| Status | raw |
| Category | Standards Track |
| Editor | Youngjoon Lee <youngjoon@logos.co> |
| Contributors | David Rusu <david@logos.co>, Giacomo Pasini <giacomo@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Daniel Sanchez Quiros <daniel@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/cryptarchia-v1-bootstr-sync.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/cryptarchia-v1-bootstr-sync.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-02-17 |

# Introduction

When a new node joins the network or a previously-bootstrapped node has been offline for a while, it cannot follow the most recent honest chain solely by receiving only new blocks because those new blocks cannot be added to the block tree that does not have their parent block. These nodes must first catch up with the most recent honest chain by fetching missing blocks from their peers before they start listening for new blocks.

This document specifies a protocol for nodes to bootstrap with the honest chain efficiently while mitigating long range attacks. It also defines how to handle the case which the node falls behind after the bootstrapping is complete.

This protocol adheres to the key invariant: We never roll back blocks that are deeper than the latest immutable block $B_\text{imm}$ in the local chain $c_{loc}$, as defined in [🔀\[1.0.1\] Cryptarchia Protocol](https://nomos-tech.notion.site/1-0-1-Cryptarchia-Protocol-21c261aa09df810cb85eff1c76e5798c?pvs=24) .

# Overview

This protocol defines the bootstrapping mechanism that covers all of the following cases:

- From the Genesis block
- From the checkpoint block obtained from a trusted checkpoint provider
- From the local block tree (with $B_\text{imm}$ newer than the Genesis and the checkpoint)

Additionally, the protocol defines the synchronization mechanism that handles orphan blocks while listening for new blocks after the bootstrapping is completed.

The protocol consists of the following key components:

- Determining the fork choice rule ([🔀\[1.0.0\] Cryptarchia Fork Choice Rule - Bootstrap Fork Choice Rule](https://nomos-tech.notion.site/Bootstrap-Fork-Choice-Rule-21b261aa09df811584dfd362abb26627?pvs=24#21b261aa09df81e4a352dd365c9ebe8c) or [🔀\[1.0.0\] Cryptarchia Fork Choice Rule - Online Fork Choice Rule](https://nomos-tech.notion.site/Online-Fork-Choice-Rule-21b261aa09df811584dfd362abb26627?pvs=24#21b261aa09df812caa08ce2f637a6278)) at startup
- Switching the fork choice rule from Bootstrap to Online
- Downloading blocks from peers

The details are described in the [Protocol](https://nomos-tech.notion.site/Protocol-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81998017dbb900a84273). This section provides only a high-level overview.

```text
​
```

Upon startup, a node determines the fork choice rule, as defined in [Setting the Fork Choice Rule](https://nomos-tech.notion.site/Setting-the-Fork-Choice-Rule-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81299066c768c56a06f1). If the Bootstrap rule is selected, it is maintained for the [Prolonged Bootstrap Period](https://nomos-tech.notion.site/Prolonged-Bootstrap-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8162be49e5aa02199378), after which the node switches to the Online rule.

Using the fork choice rule chosen, the node downloads blocks to catch up with the tip of the local chain $c_{loc}$ of each peer.

After downloading is done, the node starts listening for new blocks. Upon receiving a new block, the node validates and adds it to its local block tree. If the ancestors of the block are missing from the local block tree, the node downloads missing ancestors using the same mechanism as above.

The node can propose blocks after switching to the Online fork choice rule.

# Protocol

## Constants

| Constant | Name | Description | Value |
| --- | --- | --- | --- |
| $T_\text{offline}$​ | Offline Grace Period | A period during which a node can be restarted without switching to the Bootstrap rule. | 20 minutes |
| $T_\text{boot}$​ | Prolonged Bootstrap Period | A period during which Bootstrap fork choice rule must be continuously used after Initial Block Download is completed. This gives nodes additional time to compare their synced chain with a broader set of peers. | 24 hours |
| $s_\text{gen}$​ | Density Check Slot Window | A number of slots used by density check of Bootstrap rule. This constant is defined in [Not found](https://nomos-tech.notion.site/21b261aa09df81f1aa58d741e75c1840?pvs=24#21b261aa09df81f1aa58d741e75c1840). | $\lfloor\frac{k}{4f}\rfloor$ (=4h30m) |

## Setting the Fork Choice Rule

Upon startup, a node sets the fork choice rule to the Bootstrap rule in one of the following cases. Otherwise, the node uses the Online fork choice rule.

- A node is starting with $B_\text{imm}$ set to the Genesis block or from a checkpoint block.
    The node is setting its latest immutable block $B_\text{imm}$ to the Genesis or a checkpoint, which clearly indicates that the node intends to catch up with the subsequent blocks. Regardless of how many subsequent blocks remain, the node should use the Bootstrap rule to mitigate long range attacks.
- A node is restarting after being offline longer than $T_\text{offline}$ (20 minutes).
    Unlike starting from Genesis or checkpoint, in the case where a node is restarted while preserving its existing block tree, the node must choose a fork choice rule depending on how long it has been offline.
    If it is certain that a node has been offline longer than the offline grace period $T_\text{offline}$ since it last used the Online rule, the node uses the Bootstrap rule upon startup. Otherwise, it starts with the Online rule.
    Details of $T_\text{offline}$ are described in [Offline Grace Period](https://nomos-tech.notion.site/Offline-Grace-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8168a95af51c8be83732). A recommended way how to measure the offline duration is introduced in [Offline Duration Measurement](https://nomos-tech.notion.site/Offline-Duration-Measurement-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81e89e68d101a284a8e1).
- A node operator set the Bootstrap rule explicitly (e.g., by --bootstrap flag).
    In any case where the node operator is clearly aware that the node has fallen behind by more than $k$ blocks, they should be able to start the node with the Bootstrap rule. For example, the operator may obtain the latest block height from another trusted operator and realize that their node has fallen significantly behind due to some issue.

## Initial Block Download

If peers for Initial Block Download (IBD) are configured, a node performs IBD by downloading blocks to catch up with the tip of the local chain $c_{loc}$ of each peer using the fork choice rule chosen in [Setting the Fork Choice Rule](https://nomos-tech.notion.site/Setting-the-Fork-Choice-Rule-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81299066c768c56a06f1). If no peer is configured, the node skips IBD. For example, genesis nodes will configure no IBD peer because they have to build a chain from scratch.

Blocks are downloaded in parent-to-child order, as defined in the [Downloading Blocks](https://nomos-tech.notion.site/Downloading-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8157959fd9f30c9f99ea) mechanism. This mechanism applies not only when a node starts from the Genesis block, but also when it already has the local block tree (or a checkpoint block)

```text
> Loading Python code…​
```

![Diagram](https://nomos-tech.notion.site/image/attachment%3Ac92ab5f8-2d32-4320-876c-635fb3134162%3Aimage.png?table=block&id=1fd261aa-09df-81f6-bb41-fdbd8907329f&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The downloaded blocks are validated and added to the local block tree using the fork choice rule determined above. Both block headers and block bodies must be validated. The header validation rules are defined in [🔀\[1.0.1\] Cryptarchia Protocol - Block Header Validation](https://nomos-tech.notion.site/Block-Header-Validation-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df810bb539f80ba66dba13).

If the node fails to catch up with at least one IBD peer (e.g., network error or invalid blocks), the node is terminated with an error, allowing the operator to restart the node with other IBD peers.

If downloading is done successfully, the node starts listening for new blocks as described in [Listening for New Blocks](https://nomos-tech.notion.site/Listening-for-New-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df817e97feea688aea50c2).

## Prolonged Bootstrap Period

After [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) is completed, a node must maintain the Bootstrap fork choice rule during the Bootstrap Period $T_\text{boot}$, if the node chose the Bootstrap rule at [Setting the Fork Choice Rule](https://nomos-tech.notion.site/Setting-the-Fork-Choice-Rule-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81299066c768c56a06f1).

The purpose of the Prolonged Bootstrap Period is giving a syncing node additional time to compare its synced chain with a broader set of peers. In other words, it provides the node with an opportunity to connect to different peers and verify whether they are on the same chain. If the syncing node has downloaded blocks only from peers within an isolated network, the result of [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) may not reflect the honest chain followed by the majority of the entire network. To resolve such situations, the node should continue using the Bootstrap rule while discovering additional peers, allowing it to switch to a better chain if one is found.

Theoretically, the Bootstrap rule should be prolonged until the node has seen a sufficient number of blocks beyond the $s_\text{gen}$ slot window, which is required for the density check of the Bootstrap rule to be meaningful. However, if the node has seen a fork longer than $k$ blocks from its divergence block during [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375), it means that the node has already seen more slots than $s_\text{gen}$ with very high probability, considering the small size of $s_\text{gen}={k}/{(4f}$). If the node has never seen any fork longer than $k$ blocks, it means that all forks could have been handled by the longest chain rule, which is part of the Bootstrap rule. Therefore, this protocol does not explicitly wait $s_\text{gen}$ slots after [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375). In other words, the protocol does not use $s_\text{gen}$ to configure the Prolonged Bootstrap Period.

This protocol configures the Bootstrap Period to 24 hours.

A timer must be started when [Listening for New Blocks](https://nomos-tech.notion.site/Listening-for-New-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df817e97feea688aea50c2) is started after [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) is completed. Once the time is completed, the fork choice rule is switched to the Online rule.

## Listening for New Blocks

Once [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) is complete and [Prolonged Bootstrap Period](https://nomos-tech.notion.site/Prolonged-Bootstrap-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8162be49e5aa02199378) is started, a node starts listening for new blocks relayed by its peers.

Upon receiving a new block, the node tries to validate and add it to its local block tree, as defined in [🔀\[1.0.1\] Cryptarchia Protocol - Chain Maintenance](https://nomos-tech.notion.site/Chain-Maintenance-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df81de81bac3a3286dc212).

If the parent of the block is missing from the local block tree, the block cannot be fully validated and added. These blocks are called orphan blocks. To handle an orphan block, the node downloads missing blocks from a randomly selected peer, as described in [Downloading Blocks](https://nomos-tech.notion.site/Downloading-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8157959fd9f30c9f99ea). If the request fails, the node may retry with different peers before abandoning the orphan block. The retry policy can be configured by implementers.

Note that downloading missing blocks does not need to be triggered if it is clear that the orphan block is in a fork diverged before the latest immutable (committed) block, as the node should never revert immutable blocks.

```text
> Loading Python code…​
```

## Downloading Blocks

For performing [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) and handling orphan blocks while [Listening for New Blocks](https://nomos-tech.notion.site/Listening-for-New-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df817e97feea688aea50c2), a node sends a DownloadBlocksRequest to a peer, which must respond with blocks in parent-to-child order. This communication should be implemented based on the [Libp2p streaming](https://github.com/libp2p/rust-libp2p/tree/master/protocols/stream).

Libp2p Protocol ID

- Mainnet: /logos-blockchain/cryptarchia/sync/1.0.0
- Testnet: /logos-blockchain-testnet/cryptarchia/sync/1.0.0

```text
> Loading Python code…​
```

The responding peer uses KnownBlocks to determine the optimal starting block for the response stream, aiming to minimize the number of blocks to be returned. The requesting node can include any block it believes could assist in this process to the KnownBlocks.additional_blocks. To avoid spamming responders, the size of KnownBlocks.additional_blocks is limited to 5.

The responding peer finds the latest common ancestor (i.e. LCA) between the target_block and each of the known blocks. Then, it returns a stream of blocks, starting from the highest LCA. To mitigate malicious downloading requests, the peer limits the number of blocks to be returned. The detailed implementation is up to implementers, depending on their internal architecture (e.g. storage design).

![Diagram](https://nomos-tech.notion.site/image/attachment%3A4712e2ca-b5cb-4315-8c2b-9e6e97743c4d%3Aimage.png?table=block&id=1fd261aa-09df-8138-b041-c737c9e0071c&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

The requesting node should repeat DownloadBlocksRequests by updating the KnownBlocks in order to download the next batches of blocks. The following code shows how the requesting node can be implemented.

```text
> Loading Python code…​
```

If the node is continuing from a previous DownloadBlocksRequest, it is important to include the latest downloaded block to the KnownBlocks.additional_blocks to avoid downloading duplicate blocks.

![Diagram](https://nomos-tech.notion.site/image/attachment%3A6dae2426-76b3-45e4-822a-bc654c36d490%3Aimage.png?table=block&id=1fd261aa-09df-81c8-b0ff-c858bf97c965&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

If the requesting node is downloading blocks up to the peer’s tip $c_{loc}$ (e.g. [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375)) by repeating DownloadBlocksRequests, the $c_{loc}$ may switch between requests. The algorithm described above also handles this case by specifying the most recent peer’s tip each time when a DownloadBlocksRequest is constructed.

![Diagram](https://nomos-tech.notion.site/image/attachment%3A06b0f3f3-f9d6-439f-b11b-1ab9180a1071%3Aimage.png?table=block&id=1fd261aa-09df-8157-b410-e2246d81a3fb&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

## Proposing New Blocks

Unlike [Listening for New Blocks](https://nomos-tech.notion.site/Listening-for-New-Blocks-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df817e97feea688aea50c2), a node can start proposing blocks after [Prolonged Bootstrap Period](https://nomos-tech.notion.site/Prolonged-Bootstrap-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8162be49e5aa02199378) is complete. In other words, the node should not propose blocks before switching to the Online fork choice rule.

## Bootstrapping from Checkpoint

Instead of bootstrapping from the Genesis block or from the local block tree, a node can choose to bootstrap the honest chain starting from a checkpoint block obtained from a trusted checkpoint provider. In this case, the node fully trusts the checkpoint provider and considers blocks deeper than the checkpoint block as immutable (including the checkpoint block itself).

A trusted checkpoint provider exposes a HTTP endpoint, allowing nodes to download the checkpoint block and the corresponding ledger state. The details are defined in [Checkpoint Provider HTTP API](https://nomos-tech.notion.site/Checkpoint-Provider-HTTP-API-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8177b6ccd2181d079a81).

The bootstrapping node imports the downloaded checkpoint block and ledger state before starting bootstrapping. The imported checkpoint block is used as the latest immutable block $B_{imm}$ and the local chain tip $c_{loc}$. Starting from the checkpoint block, the same [Initial Block Download](https://nomos-tech.notion.site/Initial-Block-Download-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81bd899ff05e97d66375) is used to downloads blocks up to the tip of the local chain of each peer. As defined in [Setting the Fork Choice Rule](https://nomos-tech.notion.site/Setting-the-Fork-Choice-Rule-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81299066c768c56a06f1), the Bootstrap fork choice rule must be used upon startup.

![Diagram](https://nomos-tech.notion.site/image/attachment%3A8e7736d5-e7ae-4058-af18-ba6fd7ced46e%3Aimage.png?table=block&id=1fd261aa-09df-817b-883e-df4c9ca6ae54&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

If it turns out that none of the peers’ local chains are connected to the checkpoint block, the node is terminated with an error, allowing the node operator to select a new checkpoint.

![Diagram](https://nomos-tech.notion.site/image/attachment%3Aee8ffb1b-e03d-498c-8816-07f6ab3c52d8%3Aimage.png?table=block&id=1fd261aa-09df-8138-99a6-eab12e93aeb6&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1410&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)

# Details

## Offline Grace Period

The offline grace period $T_\text{offline}$ is a period during which a node can be restarted without switching to the Bootstrap rule.

This protocol configures $T_\text{offline}$ to 20 minutes. Here are the advantages and disadvantages of a short period:

- Advantages
    - Limits chances for malicious peers to build long alternative chains beyond the scope of the Online rule.
    - Conservatively enables the Bootstrap rule to handle long forks.
- Disadvantages
    - Even a short offline duration can too sensitively trigger the Bootstrap rule, which then lasts for the long [Prolonged Bootstrap Period](https://nomos-tech.notion.site/Prolonged-Bootstrap-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8162be49e5aa02199378).

The following example explains why $T_\text{offline}$ should not be set too long.

- A local node stopped in the following situation. A malicious peer is building a fork which is now a little shorter ($k-d$) than the honest chain.
    ![Diagram](https://nomos-tech.notion.site/image/attachment%3Ac6f1bce4-8cca-4008-8396-1a8a4fb9f858%3Aimage.png?table=block&id=1fd261aa-09df-81bf-8212-c190c5627c6e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1330&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
- The local node has been offline shorter than $T_\text{offline}$ and just restarted. As defined in this protocol, the Online fork choice rule is used because the offline duration is short.
- During the offline duration, the malicious peer made its fork longer by adding $k-d$ blocks. Now the fork is in the same length as the honest chain.
- If the malicious peer sends the fork to the restarted node faster than the honest peer, the restarted node will commit to the fork because it has $k$ new blocks. Even if the node later receives the honest chain from the honest peer, it cannot revert blocks that are already immutable.
    ![Diagram](https://nomos-tech.notion.site/image/attachment%3A214199c1-8424-4c9f-902c-184a11913d9d%3Aimage.png?table=block&id=1fd261aa-09df-811a-b946-d313dfbdfd4e&spaceId=8dee56ee-6a26-4946-83e5-607a431da45d&width=1330&userId=&cache=v2&imgBuildSrc=requestProxiedImageUrl)
- If $T_\text{offline}$ is short, the malicious peer would not have enough time to make its fork acceptable by the Online rule. Even if the malicious peer made its fork long enough after $T_\text{offline}$, the fork will be rejected by the syncing node because it will use the Bootstrap rule if it has been offline longer after $T_\text{offline}$.

A disadvantage is that a syncing node, which has been offline longer than $T_\text{offline}$, should maintain the Bootstrap rule during the [Prolonged Bootstrap Period](https://nomos-tech.notion.site/Prolonged-Bootstrap-Period-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df8162be49e5aa02199378), which is 24 hours in the current setting. In the future, the team will consider designing a better mechanism to replace the long Bootstrap Period.

## Offline Duration Measurement

As defined in [Setting the Fork Choice Rule](https://nomos-tech.notion.site/Setting-the-Fork-Choice-Rule-1fd261aa09df81ac94b5fb6a4eff32a6?pvs=24#1fd261aa09df81299066c768c56a06f1), when a node is restarted, it should be able to choose a proper fork choice rule depending on how long it has been offline since it last used the Online rule.

It is considered unsafe to rely on any external information (e.g. the slot or height of peer’s tip) to check how long the node has been offline, since such information could be manipulated as an attack vector. Instead, it is recommended to employ a local method to measure the offline duration.

While the specific implementation is left to the discretion of implementers, one approach is for the node to periodically record the current time to a local file while it is running with the Online fork choice rule. Upon restart, it can use this timestamp to calculate how long it has been offline.

## Checkpoint Provider HTTP API

A trusted checkpoint provider serves the GET /checkpoint API, allowing users (which are not connected via p2p) to download the latest checkpoint block and its corresponding ledger state.

```text
> Loading YAML code…​
```

