# BEDROCK-ANONYMOUS-LEADERS-REWARD

| Field | Value |
| --- | --- |
| Name | Bedrock Anonymous Leaders Reward Protocol |
| Slug | 85 |
| Status | raw |
| Category | Standards Track |
| Editor | Thomas Lavaur <thomaslavaur@logos.co> |
| Contributors | David Rusu <davidrusu@logos.co>, Mehmet Gonen <mehmet@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Frederico Teixeira <frederico@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-anonymous-leaders-reward.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-anonymous-leaders-reward.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-03-30 |

# Introduction

In many blockchain designs, leaders receive rewards for producing valid blocks. Traditionally, this reward is linked directly to the block or its producer, potentially opening the door to manipulation or self-censorship, where leaders may avoid including certain transactions or messages out of fear of retaliation or reputational harm. As the Logos Blockchain must protect its nodes and ensure that they do not need to engage in self-censorship, we must design a reward mechanism that preserves the anonymity of block leaders while maintaining correctness and preventing double rewards.

This document specifies the mechanism for anonymous reward distribution based on voucher commitments, nullifiers, and zero-knowledge (ZK) proofs. The goal is to ensure that block leaders can claim their rewards without linking them to specific blocks and without revealing their identities.

# Overview

The protocol introduces a concept of vouchers to unlink the block reward claim from the block itself. Instead of directly crediting themselves in the block, leaders include a commitment (a zkhash in this protocol) to a secret voucher. These commitments are gathered into a Merkle tree. In the first block of an epoch, we add all vouchers from the previous epoch to the voucher Merkle tree, accumulating the vouchers together in a set and guaranteeing a minimal anonymity set. Leaders may anonymously claim their reward using a ZK proof later, proving the ownership of their voucher. This is summarized in the following diagram:

<figure>
<svg aria-roledescription="flowchart-v2" class="flowchart" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246" role="graphics-document document" style="max-width: 1185.322998046875px;" viewbox="4 4 1185.322998046875 70" width="100%" xmlns="http://www.w3.org/2000/svg"><style>#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:#ccc;}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .error-icon{fill:#a44141;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .error-text{fill:#ddd;stroke:#ddd;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-thickness-normal{stroke-width:1px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-thickness-thick{stroke-width:3.5px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-pattern-solid{stroke-dasharray:0;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-thickness-invisible{stroke-width:0;fill:none;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .marker{fill:lightgrey;stroke:lightgrey;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .marker.cross{stroke:lightgrey;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 svg{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 p{margin:0;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .label{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";color:#ccc;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster-label text{fill:#F9FFFE;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster-label span{color:#F9FFFE;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster-label span p{background-color:transparent;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .label text,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 span{fill:#ccc;color:#ccc;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node rect,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node circle,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node ellipse,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node polygon,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node path{fill:#1f2020;stroke:#ccc;stroke-width:1px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .rough-node .label text,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node .label text,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .image-shape .label,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .icon-shape .label{text-anchor:middle;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node .katex path{fill:#000;stroke:#000;stroke-width:1px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .rough-node .label,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node .label,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .image-shape .label,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .icon-shape .label{text-align:center;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node.clickable{cursor:pointer;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .root .anchor path{fill:lightgrey!important;stroke-width:0;stroke:lightgrey;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .arrowheadPath{fill:lightgrey;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edgePath .path{stroke:lightgrey;stroke-width:2.0px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .flowchart-link{stroke:lightgrey;fill:none;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edgeLabel{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edgeLabel p{background-color:hsl(0, 0%, 34.4117647059%);}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .edgeLabel rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .labelBkg{background-color:rgba(87.75, 87.75, 87.75, 0.5);}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster rect{fill:hsl(180, 1.5873015873%, 28.3529411765%);stroke:rgba(255, 255, 255, 0.25);stroke-width:1px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster text{fill:#F9FFFE;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .cluster span{color:#F9FFFE;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:12px;background:hsl(20, 1.5873015873%, 12.3529411765%);border:1px solid rgba(255, 255, 255, 0.25);border-radius:2px;pointer-events:none;z-index:100;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .flowchartTitleText{text-anchor:middle;font-size:18px;fill:#ccc;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 rect.text{fill:none;stroke-width:0;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .icon-shape,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .image-shape{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .icon-shape p,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .image-shape p{background-color:hsl(0, 0%, 34.4117647059%);padding:2px;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .icon-shape rect,#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .image-shape rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .label-icon{display:inline-block;height:1em;overflow:visible;vertical-align:-0.125em;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 .node .label-icon path{fill:currentColor;stroke:revert;stroke-width:revert;}#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246 :root{--mermaid-font-family:"trebuchet ms",verdana,arial,sans-serif;}</style><g><marker class="marker flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd" markerheight="8" markerunits="userSpaceOnUse" markerwidth="8" orient="auto" refx="5" refy="5" viewbox="0 0 10 10"><path class="arrowMarkerPath" d="M 0 0 L 10 5 L 0 10 z" style="stroke-width: 1; stroke-dasharray: 1, 0;"></path></marker><marker class="marker flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointStart" markerheight="8" markerunits="userSpaceOnUse" markerwidth="8" orient="auto" refx="4.5" refy="5" viewbox="0 0 10 10"><path class="arrowMarkerPath" d="M 0 5 L 10 10 L 10 0 z" style="stroke-width: 1; stroke-dasharray: 1, 0;"></path></marker><marker class="marker flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-circleEnd" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="11" refy="5" viewbox="0 0 10 10"><circle class="arrowMarkerPath" cx="5" cy="5" r="5" style="stroke-width: 1; stroke-dasharray: 1, 0;"></circle></marker><marker class="marker flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-circleStart" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="-1" refy="5" viewbox="0 0 10 10"><circle class="arrowMarkerPath" cx="5" cy="5" r="5" style="stroke-width: 1; stroke-dasharray: 1, 0;"></circle></marker><marker class="marker cross flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-crossEnd" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="12" refy="5.2" viewbox="0 0 11 11"><path class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9" style="stroke-width: 2; stroke-dasharray: 1, 0;"></path></marker><marker class="marker cross flowchart-v2" id="mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-crossStart" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="-1" refy="5.2" viewbox="0 0 11 11"><path class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9" style="stroke-width: 2; stroke-dasharray: 1, 0;"></path></marker></g><g class="subgraphs"></g><g class="nodes"><g class="node default" id="flowchart-A-0" transform="translate(88.72396087646484, 39)"><rect class="basic label-container" height="54" style="" width="153.4479217529297" x="-76.72396087646484" y="-27"></rect><g class="label" style="" transform="translate(-46.723960876464844, -12)"><rect></rect><foreignobject height="24" width="93.44792175292969"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Leader block</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-B-1" transform="translate(286.72396087646484, 39)"><rect class="basic label-container" height="54" style="" width="172.55208587646484" x="-86.27604293823242" y="-27"></rect><g class="label" style="" transform="translate(-56.27604293823242, -12)"><rect></rect><foreignobject height="24" width="112.55208587646484"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>reward voucher</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-F-3" transform="translate(512.6354141235352, 39)"><rect class="basic label-container" height="54" style="" width="209.27084350585938" x="-104.63542175292969" y="-27"></rect><g class="label" style="" transform="translate(-74.63542175292969, -12)"><rect></rect><foreignobject height="24" width="149.27084350585938"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>wait until next epoch</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-C-4" transform="translate(723.3281173706055, 39)"><rect class="basic label-container" height="54" style="" width="142.11458587646484" x="-71.05729293823242" y="-27"></rect><g class="label" style="" transform="translate(-41.05729293823242, -12)"><rect></rect><foreignobject height="24" width="82.11458587646484"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Merkle tree</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-D-6" transform="translate(930.7760314941406, 39)"><rect class="basic label-container" height="54" style="" width="202.78125" x="-101.390625" y="-27"></rect><g class="label" style="" transform="translate(-71.390625, -12)"><rect></rect><foreignobject height="24" width="142.78125"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Claim with ZK proof</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-E-8" transform="translate(1124.2447814941406, 39)"><rect class="basic label-container" height="54" style="" width="114.15625" x="-57.078125" y="-27"></rect><g class="label" style="" transform="translate(-27.078125, -12)"><rect></rect><foreignobject height="24" width="54.15625"><div style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Reward</p></span></div></foreignobject></g></g></g><g class="edges edgePaths"><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M165.448,39L196.448,39" id="L_A_B_0_0" marker-end="url(#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M373,39L404,39" id="L_B_F_0_0" marker-end="url(#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M617.271,39L648.271,39" id="L_F_C_0_0" marker-end="url(#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M794.385,39L825.385,39" id="L_C_D_0_0" marker-end="url(#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M1032.167,39L1063.167,39" id="L_D_E_0_0" marker-end="url(#mermaid-875c0f8f-d027-4ebe-81e8-19c6c41d0246_flowchart-v2-pointEnd)" style=""></path></g><g class="edgeLabels"><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g></g></svg>
</figure>

By anonymizing the identity of block leaders at the time of reward claiming, the protocol removes any direct link between block production and the recipient of the reward. This is essential to prevent self-censorship behaviors. With anonymous claiming, leaders are free to act honestly according to protocol rules without concern for external consequences, thus improving the overall neutrality and robustness of the network.

Key properties of the protocol:

- Anonymity: Block rewards are unlinkable to the blocks they originate from (avoiding deanonymization).
- Soundness: No reward can be claimed twice.

In parallel, the blockchain maintains the value leaders_rewards accumulating the rewards for leaders over time. Each voucher included in the Merkle tree represents the same share of leaders_rewards. Just like for voucher inclusion, more rewards are added to this variable on an epoch-by-epoch basis, which guarantees a stable and equal claimable reward for leaders over an epoch.

# Protocol

## Voucher creation and inclusion

When producing a block, a leader performs the following:

1. Generate a one-time random secret $voucher \overset{{\scriptscriptstyle\$}}{\leftarrow} \mathbb F_p$.
1. Compute the commitment: voucher_cm := zkHash(b"LEAD_VOUCHER_CM_V1, voucher).
1. Include the voucher_cm in the block header.

Each voucher_cm is added to a Merkle tree of voucher commitments by validators during the execution of the first block of the following epoch, maintained throughout the entire blockchain history by everyone.

## Claiming the reward

### Protocol

Each leader may submit a [[1.3.0] Mantle - LEADER_CLAIM](https://nomos-tech.notion.site/LEADER_CLAIM-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81c4a33bddc5ada55f8c) Operation to claim their reward. This Operation includes:

- The Merkle root of the global voucher set when the Mantle Transaction containing the claim is submitted.
- A [[1.3.0] Mantle - Proof of Claim](https://nomos-tech.notion.site/Proof-of-Claim-330261aa09df80a899a6efd74f12a7c4?pvs=24#330261aa09df81d48e26e141e8eed17b).

This Operation increases the balance of a Mantle Transaction by the leader reward amount, letting the leader move the funds as desired through the Ledger transaction or another Operation.

> This means that a leader may use their funds directly, getting their reward and using them atomically.

Note that every leader will receive a reward that is independent of the block content to avoid de-anonymization. This means that the fees of the block cannot be collected by the leader directly, or need to be pooled for all the leaders.

### Leaders Reward

At the start of epoch N+1, validators aggregate the leaders rewards of epoch N into the leader rewards variable. The amount of the reward claimable with a voucher corresponds to a share of the leaders_rewards. This share is exactly equal to the total value of rewards divided by the size of the anonymity set of leaders, that is:

$$
share = \begin{cases}
  0 &\textbf{if } |voucher\_cm|=|voucher\_nf| \\
\frac{leader\_rewards}{|voucher\_cm| - |voucher\_nf|} &\textbf{if } |voucher\_cm| \neq |voucher\_nf|
\end{cases}
$$

This amount is stable through an epoch because when a leader withdraws, both the pool value and the number of unclaimed vouchers decrease proportionally, so the price per share remains unchanged. However, the share value will vary across epochs if the leader rewards are variable.

## Validation

Nodes validate a LEADER_CLAIM Operation by:

1. Verifying the ZK proof.
1. Checking that voucher_nf is not already in the voucher nullifier set.
1. Executing the reward logic:
    - Add the voucher_nf to the voucher nullifier set to prevent claiming the same reward more than once.
    - Increase the balance of the Mantle Transaction by the share amount.
    - Decrease the value of the leaders_rewards by the same amount.

# Details

## Unlinking Block Rewards from Proposals

Each reward voucher is a cryptographic commitment derived from a voucher secret. This commitment, when included in the block header, reveals no information about the block producer's identity or the actual secret voucher. It is computationally infeasible to reverse the commitment to retrieve the voucher secret.

Crucially, when the leader reward is claimed and the voucher nullifier revealed, a third party cannot link this nullifier to the initial voucher commitment. A reward is claimable if its reward voucher is in the reward voucher set and its voucher nullifier is not in the voucher nullifier set.

The reward voucher set will be maintained as a Merkle tree of depth 32, and validators will be required to hold the frontier of the MMR in memory to continue appending to the set. The voucher nullifier set will be maintained as a searchable database.

## ZK Proof of Membership

When claiming a reward, the leader provides a ZK proof that they know a leaf in the global Merkle tree of reward vouchers and the preimage of that leaf. Crucially, the ZK proof does not reveal which leaf is being proven. The verifier only learns that some valid leaf exists in the tree for which the prover knows the secret voucher. This property ensures that the claim cannot be linked to any specific block header or reward voucher commitment.

## Preventing Double Claims Without Breaking Privacy

To prevent double claiming, the leader derives a voucher nullifier. This nullifier is unique to the voucher but reveals nothing about the original reward voucher or block. It acts as a one-way identifier that allows nodes to track whether a voucher has already been claimed, without compromising the anonymity of the claim.

