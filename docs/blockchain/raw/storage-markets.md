# STORAGE-MARKETS

| Field | Value |
| --- | --- |
| Name | Storage Markets |
| Slug | 205 |
| Status | raw |
| Category | Standards Track |
| Editor | Juan Pablo Madrigal-Cianci <jp@logos.co> |
| Contributors | Frederico Teixeira <frederico@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-05-22** — [`e8cedab`](https://github.com/logos-co/logos-lips/blob/e8cedab986dd17a9ff7bc718398b7162c2ab0d89/docs/blockchain/raw/storage-markets.md) — fix(blockchain): re-import 25 Notion-only spec bodies with proper markdown formatting
- **2026-05-22** — [`4c38737`](https://github.com/logos-co/logos-lips/blob/4c38737840346f1d3ba899ecab61c255e5c88f93/docs/blockchain/raw/storage-markets.md) — chore(blockchain): import 25 Notion-only specs as scaffold files (PR #2A)

<!-- timeline:end -->

# Revisions History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-04-24 |

> Disclamer:
> This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
>
> All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 
>
> Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

# Introduction

This document provides the formal specification for the fee collection mechanism of the Permanent Storage market. The primary objective is to define a system that is robust, predictable, and economically sustainable. This mechanism is a critical component of the overall Permanent Storage Market Transaction Fee Mechanism (TFM), which is designed as a self-contained, usage-driven market, economically decoupled from the protocol's core consensus and privacy services.

In what follows, Logos Blockchain Storage refers to the Permanent Storage markets and Logos Blockchain Storage Gas refers to the Permanent Storage Gas respectively.

## Requirements and Rationale

The mechanism is designed with the following core requirements, derived from the project's goals:

1. Predictability: Consumers of the Logos Blockchain Storage require a high degree of cost predictability for their own operational planning.
1. Robustness: The mechanism must be able to adapt to significant, medium-term shifts in demand without requiring constant, emergency governance intervention.
1. Fairness: The fee paid by a user must be directly and transparently proportional to the resources they consume.
1. Simplicity: The on-chain implementation should be as simple as possible to minimize attack surface and ensure auditability.

Justification. As will be discussed later, the tradeoff between adaptability and predictability of the mechanism is determined by its parameters. In scenarios of high volatility, its core design principle is to act as a shock absorber, deliberately filtering out high-frequency, transient volatility by operating over longer timeframes and using a smoothed moving average (EMA). For the primary consumer, reacting to every momentary spike in demand would create untenable price chaos. This model, therefore, intentionally forgoes instantaneous adaptation in favor of providing crucial timeframe-level price certainty, ensuring that fees reflect meaningful, medium-term trends rather than reacting to volatile, short-term market noise.

# Overview

The proposed fee mechanism operates on a simple but powerful principle: the price for Logos Blockchain Storage is fixed and predictable within a given timeframe (epoch for Permanent Storage), but it adjusts smoothly between timeframes based on observed network usage.

When a user submits data, a fee is calculated based on the Logos Blockchain Storage Gas consumption. This fee is determined by a price per Gas, $P_{STR}$, which is known in advance for the entire timeframe.

At the end of each timeframe, the protocol tallies the total amount of Logos Blockchain Storage Gas that was stored. It compares this actual usage to an adaptive targeta "healthy" usage level that is itself a dynamic blend of a long-term policy goal and recent historical usage. Based on whether the actual usage was above or below this target, the price $P_{STR}$ for the next timeframe is adjusted slightly up or down.

This flow can be visualized as follows:

<figure>
<svg aria-roledescription="flowchart-v2" class="flowchart" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4" role="graphics-document document" style="max-width: 807px;" viewbox="4 4 807 595" width="100%" xmlns="http://www.w3.org/2000/svg"><style>#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;fill:#ccc;}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .error-icon{fill:#a44141;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .error-text{fill:#ddd;stroke:#ddd;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-thickness-normal{stroke-width:1px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-thickness-thick{stroke-width:3.5px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-pattern-solid{stroke-dasharray:0;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-thickness-invisible{stroke-width:0;fill:none;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-pattern-dashed{stroke-dasharray:3;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edge-pattern-dotted{stroke-dasharray:2;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .marker{fill:lightgrey;stroke:lightgrey;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .marker.cross{stroke:lightgrey;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 svg{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:16px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 p{margin:0;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .label{font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";color:#ccc;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster-label text{fill:#F9FFFE;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster-label span{color:#F9FFFE;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster-label span p{background-color:transparent;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .label text,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 span{fill:#ccc;color:#ccc;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node rect,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node circle,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node ellipse,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node polygon,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node path{fill:#1f2020;stroke:#ccc;stroke-width:1px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .rough-node .label text,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node .label text,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .image-shape .label,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .icon-shape .label{text-anchor:middle;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node .katex path{fill:#000;stroke:#000;stroke-width:1px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .rough-node .label,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node .label,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .image-shape .label,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .icon-shape .label{text-align:center;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node.clickable{cursor:pointer;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .root .anchor path{fill:lightgrey!important;stroke-width:0;stroke:lightgrey;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .arrowheadPath{fill:lightgrey;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edgePath .path{stroke:lightgrey;stroke-width:2.0px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .flowchart-link{stroke:lightgrey;fill:none;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edgeLabel{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edgeLabel p{background-color:hsl(0, 0%, 34.4117647059%);}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .edgeLabel rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .labelBkg{background-color:rgba(87.75, 87.75, 87.75, 0.5);}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster rect{fill:hsl(180, 1.5873015873%, 28.3529411765%);stroke:rgba(255, 255, 255, 0.25);stroke-width:1px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster text{fill:#F9FFFE;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .cluster span{color:#F9FFFE;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 div.mermaidTooltip{position:absolute;text-align:center;max-width:200px;padding:2px;font-family:ui-sans-serif,-apple-system,BlinkMacSystemFont,"Segoe UI Variable Display","Segoe UI",Helvetica,"Apple Color Emoji","Noto Sans Arabic","Noto Sans Hebrew",Arial,sans-serif,"Segoe UI Emoji","Segoe UI Symbol";font-size:12px;background:hsl(20, 1.5873015873%, 12.3529411765%);border:1px solid rgba(255, 255, 255, 0.25);border-radius:2px;pointer-events:none;z-index:100;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .flowchartTitleText{text-anchor:middle;font-size:18px;fill:#ccc;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 rect.text{fill:none;stroke-width:0;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .icon-shape,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .image-shape{background-color:hsl(0, 0%, 34.4117647059%);text-align:center;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .icon-shape p,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .image-shape p{background-color:hsl(0, 0%, 34.4117647059%);padding:2px;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .icon-shape rect,#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .image-shape rect{opacity:0.5;background-color:hsl(0, 0%, 34.4117647059%);fill:hsl(0, 0%, 34.4117647059%);}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .label-icon{display:inline-block;height:1em;overflow:visible;vertical-align:-0.125em;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 .node .label-icon path{fill:currentColor;stroke:revert;stroke-width:revert;}#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4 :root{--mermaid-font-family:"trebuchet ms",verdana,arial,sans-serif;}</style><g><marker class="marker flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd" markerheight="8" markerunits="userSpaceOnUse" markerwidth="8" orient="auto" refx="5" refy="5" viewbox="0 0 10 10"><path class="arrowMarkerPath" d="M 0 0 L 10 5 L 0 10 z" style="stroke-width: 1; stroke-dasharray: 1, 0;"></path></marker><marker class="marker flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointStart" markerheight="8" markerunits="userSpaceOnUse" markerwidth="8" orient="auto" refx="4.5" refy="5" viewbox="0 0 10 10"><path class="arrowMarkerPath" d="M 0 5 L 10 10 L 10 0 z" style="stroke-width: 1; stroke-dasharray: 1, 0;"></path></marker><marker class="marker flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-circleEnd" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="11" refy="5" viewbox="0 0 10 10"><circle class="arrowMarkerPath" cx="5" cy="5" r="5" style="stroke-width: 1; stroke-dasharray: 1, 0;"></circle></marker><marker class="marker flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-circleStart" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="-1" refy="5" viewbox="0 0 10 10"><circle class="arrowMarkerPath" cx="5" cy="5" r="5" style="stroke-width: 1; stroke-dasharray: 1, 0;"></circle></marker><marker class="marker cross flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-crossEnd" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="12" refy="5.2" viewbox="0 0 11 11"><path class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9" style="stroke-width: 2; stroke-dasharray: 1, 0;"></path></marker><marker class="marker cross flowchart-v2" id="mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-crossStart" markerheight="11" markerunits="userSpaceOnUse" markerwidth="11" orient="auto" refx="-1" refy="5.2" viewbox="0 0 11 11"><path class="arrowMarkerPath" d="M 1,1 l 9,9 M 10,1 l -9,9" style="stroke-width: 2; stroke-dasharray: 1, 0;"></path></marker></g><g class="subgraphs"></g><g class="nodes"><g class="node default" id="flowchart-A-0" transform="translate(377.99999999999994, 241.5)"><rect class="basic label-container" height="102" style="" width="260" x="-130" y="-51"></rect><g class="label" style="" transform="translate(-100, -36)"><rect></rect><foreignobject height="72" width="200"><div style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>timeframes 's' Begins<br/>Price P_STR(s) is Fixed &amp; Known</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-B-2" transform="translate(312.99999999999994, 420)"><rect class="basic label-container" height="150" style="" width="260" x="-130" y="-75"></rect><g class="label" style="" transform="translate(-100, -60)"><rect></rect><foreignobject height="120" width="200"><div style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Data Submission<br/>- Logos Blockchain Storage Gas: S_gas<br/>- Fee = S_gas * P_STR(s) + ...</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-C-4" transform="translate(340.75731921667904, 75)"><rect class="basic label-container" height="126" style="" width="260" x="-130" y="-63"></rect><g class="label" style="" transform="translate(-100, -48)"><rect></rect><foreignobject height="96" width="200"><div style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Protocol State:<br/>- C_Usage(s) += S_gas<br/>- Fee  Storage Reward Bucket</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-D-8" transform="translate(673, 241.5)"><rect class="basic label-container" height="102" style="" width="260" x="-130" y="-51"></rect><g class="label" style="" transform="translate(-100, -36)"><rect></rect><foreignobject height="72" width="200"><div style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>timeframes 's' Ends<br/>- Total Usage C_Usage(s) is Final</p></span></div></foreignobject></g></g><g class="node default" id="flowchart-E-11" transform="translate(673, 468)"><rect class="basic label-container" height="246" style="" width="260" x="-130" y="-123"></rect><g class="label" style="" transform="translate(-100, -108)"><rect></rect><foreignobject height="216" width="200"><div style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="nodeLabel"><p>Price Update Rule Executed:<br/>- Calculate Effective Target T_Effective(s)<br/>- Compare C_Usage(s) to T_Effective(s)<br/>- Calculate and set new price P_STR(s+1) for next timeframes</p></span></div></foreignobject></g></g></g><g class="edges edgePaths"><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M378,292.5L378,341" id="L_A_B_0_0" marker-end="url(#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M313,345L313,340C313,335,313,325,312.638,319.529C312.276,314.057,311.552,313.114,310.719,312.281C309.886,311.448,308.943,310.724,296.221,310.362C283.5,310,259,310,246.279,309.638C233.557,309.276,232.614,308.552,231.781,307.719C230.948,306.886,230.224,305.943,229.862,294.888C229.5,283.833,229.5,262.667,229.5,241.5C229.5,220.333,229.5,199.167,229.862,188.112C230.224,177.057,230.948,176.114,231.781,175.281C232.614,174.448,233.557,173.724,250.905,173.362C268.252,173,302.005,173,319.353,172.638C336.7,172.276,337.643,171.552,338.476,170.719C339.31,169.886,340.033,168.943,340.395,164.138C340.757,159.333,340.757,150.667,340.757,146.333L340.757,142" id="L_B_C_0_0" marker-end="url(#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M275.757,138L275.757,140.083C275.757,142.167,275.757,146.333,275.395,148.888C275.033,151.443,274.31,152.386,273.476,153.219C272.643,154.052,271.7,154.776,245.603,155.138C219.505,155.5,168.252,155.5,142.155,155.862C116.057,156.224,115.114,156.948,114.281,157.781C113.448,158.614,112.724,159.557,112.362,187.029C112,214.5,112,268.5,112.362,295.971C112.724,323.443,113.448,324.386,114.281,325.219C115.114,326.052,116.057,326.776,137.529,327.138C159,327.5,201,327.5,222.471,327.862C243.943,328.224,244.886,328.948,245.719,329.781C246.552,330.614,247.276,331.557,247.638,333.445C248,335.333,248,338.167,248,339.583L248,341" id="L_C_B_0_0" marker-end="url(#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M405.757,138L405.757,140.083C405.757,142.167,405.757,146.333,406.119,148.888C406.481,151.443,407.205,152.386,408.038,153.219C408.872,154.052,409.815,154.776,453.16,155.138C496.505,155.5,582.252,155.5,625.598,155.862C668.943,156.224,669.886,156.948,670.719,157.781C671.552,158.614,672.276,159.557,672.638,164.362C673,169.167,673,177.833,673,182.167L673,186.5" id="L_C_D_0_0" marker-end="url(#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd)" style=""></path><path class="edge-thickness-normal edge-pattern-solid edge-thickness-normal edge-pattern-solid flowchart-link" d="M673,292.5L673,341" id="L_D_E_0_0" marker-end="url(#mermaid-94860c12-07fd-48ab-be0e-53008ee54ce4_flowchart-v2-pointEnd)" style=""></path></g><g class="edgeLabels"><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel" transform="translate(112, 241.5)"><g class="label" transform="translate(-100, -24)"><foreignobject height="48" width="200"><div class="labelBkg" style="display: table; white-space: break-spaces; line-height: 1.5; max-width: 200px; text-align: center; width: 200px;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"><p>Loop for all blocks in timeframes</p></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g><g class="edgeLabel"><g class="label" transform="translate(0, 0)"><foreignobject height="0" width="0"><div class="labelBkg" style="display: table-cell; white-space: nowrap; line-height: 1.5; max-width: 200px; text-align: center;" xmlns="http://www.w3.org/1999/xhtml"><span class="edgeLabel"></span></div></foreignobject></g></g></g></svg>
</figure>

This model provides the best of both worlds: users have perfect price clarity for the duration of a timeframe, while the system as a whole can gracefully adapt to evolving market conditions over time.

# Construction

This section defines the precise algorithm, constants, and state variables for the Logos Blockchain Storage TFM.

### Core Fee Equation

The fee for a Logos Blockchain Storage transaction, $F_{\text{STR}}$, is a linear function of Logos Blockchain Storage Gas' size, $S_{\text{gas}}$, and the price-per-gas for the current timeframe, $P_{\text{STR}}(s)$.

$$
F_{\text{STR}} = S_{\text{gas}} \cdot P_{\text{STR}}(s)
$$

As a remark, the equation above assumes a linear increase of $F_\text{STR}$ with respect to $S_\text{gas}$. For completeness, a more general version can be

$$
\begin{align*}
F_\text{STR}=f(S_\text{gas})\cdot P_\text{STR}
\end{align*}
$$

with $f:\mathbb{N}\to\mathbb{R}_+$ a monotonically increasing function. Making f sublinear can be understood as accounting for economies of scale, while making $f$ superlinear can be understood as a penalization for using larger data sizes. We decided to go with the linear form of $f$ as it was the least opinionated. Examples of this could be

$$
\begin{align*}
F_\text{STR}^\text{exp}&=\exp(\alpha S_\text{gas})\cdot P_\text{STR}\quad \alpha >0\\
F_\text{poly}^\text{exp}&=S^\beta_\text{gas}\cdot P_\text{STR},\quad \beta>1\\
\end{align*}
$$

### Protocol Constants

To ensure on-chain efficiency, the protocol shall use an Exponential Moving Average (EMA) for its adaptive target calculation. The behavior of the TFM is governed by the following on-chain constants, which are set at genesis.

| Symbol | Name | Description | Initial Value | Justification |
| --- | --- | --- | --- | --- |
| $T_{\text{base}}$ | Baseline Target | A static, policy-driven usage target in Logos Blockchain Storage Gas per timeframe. Acts as a long-term gravitational anchor for the dynamic target. | 0 Permanent Storage Gas per block. | It should represent a conservative initial timeframe capacity. providing a healthy buffer and a clear policy goal. |
| $w$ | Anchor Weight | A coefficient in $[0, 1]$ determining the influence of $T_{\text{base}}$. It's the "gravity knob" for the system. | for Permanent Storage: 0 | Allows the target to be primarily driven by recent demand, ensuring adaptability, while the $w$% pull from $T_{\text{base}}$ prevents long-term drift. |
| $\alpha$ | Max Adjustment Factor | The maximum fractional amount the price can change per timeframe. Acts as "safety brakes" to bound price volatility. | 0.125 for Permanent Storage | A $100\alpha$% cap provides strong predictability for users planning across timeframes while allowing the price to respond effectively to sustained demand changes. |
| $\beta$ | EMA Smoothing Factor | A coefficient in $[0, 1]$ controlling the responsiveness of the usage EMA. It governs the speed of adaptation. | 0.5 for Permanent Storage | A value of $\beta$ gives significant weight to the most recent timeframe's usage while incorporating the "memory" of the system with a half-life of 1 timeframe, balancing responsiveness and stability. |
| $T_{\text{RA}}(-1)$ | Initial Usage EMA | First value for EMA | 0 (=$T_{\text{base}}$) | Given $T_{\text{base}} = 0$, this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset. |
| $P_{\text{STR}}(0)$ | Initial Price | The price on the first epoch | 1 LGO/gas | The initial price is set conservatively low at the beginning and let to discover the true market price |
| $s$ | timeframe | How often things adjust | 1 epoch | Primary users of the Storage market plan operational costs over days or weeks, not block-by-block. |

### Parameter Justification

- For simplicity, we set $T_\text{base}=0$ as an anchor and $w=0$ as blocks are already constrained by execution. This is to avoid imposing an opinionated choice of parameters, specially at the beginning of the protocol.
- The EMA factor ($\beta=0.5$) makes the adaptive target highly sensitive to recent network activity by giving 50% weight to the latest session's usage, creating an effective "memory" of approximately 3 epochs.
- The maximum adjustment factor ($\alpha=0.125$) provides a crucial layer of predictability, guaranteeing users that the price cannot change by more than 12.5% between any two epochs, thus fulfilling a core design requirement for stable operational planning.
- The seed value for the EMA is set to $T_{\text{RA}}(-1) = T_{\text{base}} = 0$.  Given $T_{\text{base}} = 0$, this is the least opinionated choice: with no prior usage data at genesis, a neutral prior of zero makes no assumption about initial market activity and anchors the EMA to the long-term policy goal from the outset.
    > Why is the index $-1$, not $0$? The price update algorithm runs at the end of timeframe $s$ and requires $T_{\text{RA}}(s-1)$ as its prior EMA value. When $s = 0$, the algorithm therefore requires $T_{\text{RA}}(-1)$ as its seed. The value $T_{\text{RA}}(0)$ is already a
    > well-defined computed quantity  the EMA produced after the first epoch's observed usage: $T_{\text{RA}}(0) = \beta \cdot C_{\text{usage}}(0) + (1-\beta) \cdot T_{\text{RA}}(-1)$. Using index $-1$ for the seed avoids a naming collision with this computed value.
    > Implementation note. With $w = 0$ and $T_{\text{RA}}(-1) = 0$, the effective target
    > $T_{\text{effective}}$ will be zero during the first epoch unless $C_{\text{usage}}(0) > 0$.
    > The reference implementation handles this correctly via the if effective_target == 0: return self.price guard, which holds the price at $P_{\text{STR}}(0)$ until the first non-zero usage
    > epoch provides a meaningful signal. This is the intended behavior at genesis.
- The precise value of $P_{\text{STR}}(0)$ is not critical to the long-term behavior of the mechanism. As established in the equilibrium analysis, the price update rule converges autonomously to the market-clearing price $P^*$ regardless of the starting point, provided the stability condition $(*)$ holds (see [[1.0.0][Analysis] Storage Market - Price Stability Analysis](https://nomos-tech.notion.site/Price-Stability-Analysis-a03261aa09df83f6bcd6815ba73b72e1?pvs=24#fed261aa09df8241b79c01ca67ef6026)). The only hard requirement is for $P_{\text{STR}}(0)$ to be sufficiently low so as not to suppress early adoption before the mechanism has observed enough demand to self-correct.
    More precisely, since the price can increase by at most $\alpha = 12.5\%$ per epoch, the number
    of epochs required to reach a target price $P^*$ from an initial price $P_{\text{STR}}(0) < P^*$ is bounded above by:
    $$
    N \leq \left\lceil \log_{1+\alpha}\!\left(\frac{P^*}{P_{\text{STR}}(0)}\right) \right\rceil
    = \left\lceil \frac{\ln(P^*/P_{\text{STR}}(0))}{\ln(1.125)} \right\rceil
    $$
    For example, if $P_{\text{STR}}(0)$ is set to one tenth of the true equilibrium price, the mechanism reaches $P^*$ within at most $\lceil \ln(10)/\ln(1.125) \rceil = 20$ epochs. Starting
    one hundredth below requires at most $40$ epochs. Both are negligible relative to the expected lifetime of the network.
    We therefore set:
    $$
    P_{\text{STR}}(0) = 1\ \text{LGO per Permanent Storage Gas}
    $$

This corresponds to a cost of 1 LGO per permanently stored byte. Genesis governance may adjust this value based on the LGO price at TGE, but the adjustment has no long-term consequence: the mechanism will converge to the true market price $P^*$ within $O(\log P^*/P_{\text{STR}}(0))$ epochs regardless.

- The timeframe $s$ corresponds to one epoch. The core reason is that the primary users of the Storage market plan operational costs over days or weeks, not block-by-block. An epoch-length timeframe provides price certainty over hundreds of blocks, directly fulfilling the predictability requirement. It also ensures the EMA aggregates a meaningful volume of usage data before influencing the price, rather than reacting to per-block noise.

### State Variables

The protocol must maintain the following state variables, updated at the end of each timeframe:

| Symbol | Name | Description |
| --- | --- | --- |
| $P_{\text{STR}}(s)$ | Price Per Logos Blockchain Storage Gas | The price per Gas of storage for the current timeframe $s$. |
| $T_{\text{RA}}(s)$ | Usage EMA | The Exponential Moving Average of storage usage, updated with the usage from timeframe $s$. |

### Price Update Algorithm

At the conclusion of each timeframe $s$, the protocol shall execute the following algorithm to determine the price for the next timeframe, $P_{\text{STR}}(s+1)$. This is done as follows.

1. Tally Usage: Aggregate the total Logos Blockchain Storage Gas consumed during timeframe $s$ into a final value, $C_\text{usage}(s)$:

$$
C_{\text{usage}}(s)=\sum_{t\in\mathcal{B}_s}\mathsf{StorageGasUsed}[t]
$$

Where $\mathcal{B}_s$ corresponds to one block in timeframe $s$ and $\mathsf{StorageGasUsed}[t]$ corresponds to the Logos Blockchain Storage Gas used by transaction $t$.

1. Update Usage EMA: Update the Exponential Moving Average of usage.

$$
T_{\text{RA}}(s) = \beta \cdot C_{\text{usage}}(s) + (1-\beta) \cdot T_{\text{RA}}(s-1)
$$

1. Calculate Effective Target: Calculate the blended, effective target, $T_{\text{effective}}(s)$.

$$
T_{\text{effective}}(s) = w \cdot T_{\text{base}} + (1-w) \cdot T_{\text{RA}}(s)
$$

1. Calculate Adjustment Factor: Determine the fractional deviation of usage from the target and clamp the result to the range $[-\alpha, \alpha]$.

$$
\text{adjustment}(s) = \frac{C_{\text{usage}}(s) - T_{\text{effective}}(s)}{T_{\text{effective}}(s)}
$$

$$
\text{clamped\_adjustment}(s) = \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}
$$

1. Update Price: Calculate the price for the next timeframe, $s+1$

$$
P_{\text{STR}}(s+1) = P_{\text{STR}}(s) \cdot [1 + \text{clamped\_adjustment}(s)]
$$

### Implementation

Because computation affect consensus state, the implementation must be fully deterministic across all nodes. For that reason, the normative implementation of the reward function should not rely on floating-point arithmetic, machine-dependent rounding behavior, or comparisons against machine epsilon. Earlier sections use real-valued formulas to explain the mechanism and its economic meaning, but the consensus rule itself should be defined only in terms of integer arithmetic.

The goal of this section is not to change the execution mechanism. It is only to restate the already-specified mechanism in a canonical deterministic form with explicit named constants. To we provide here a reference implementation that uses unsigned integers to have a common reference.

First because we have $w = 0$, $T_\text{RA}(s) = T_\text{effective}(s)$. Then because $\beta=0.5$

$$
T_{\mathrm{RA}}(s)=\frac{C_{\mathrm{usage}}(s)+T_{\mathrm{RA}}(s-1)}{2}
$$

Secondly, we can rewrite $P_\text{STR}$ equation:

$$
\begin{align*}
P_{\text{STR}}(s+1) &= P_{\text{STR}}(s) \cdot [1 + \max \{ -\alpha, \min \{ \alpha, \text{adjustment}(s) \} \}]\\
&= P_{\text{STR}}(s) \cdot \max \{ 1-\alpha, \min \{ 1+ \alpha, 1+\text{adjustment}(s) \} \}\\
&= P_{\mathrm{STR}}(s)\cdot
\max\left\{\frac78,\min\left\{\frac98,\,
\frac{C_{\mathrm{usage}}(s)}{T_{\mathrm{RA}}(s)}
\right\}\right\}
\end{align*}
$$

and so:

$P_{\mathrm{STR}}(s+1)=\begin{cases}\left\lfloor P_{\mathrm{STR}}(s)\cdot \frac78 \right\rfloor,& \text{if } 8\,C_{\mathrm{usage}}(s)\le 7\,T_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P_{\mathrm{STR}}(s)\cdot \frac98 \right\rfloor,& \text{if } 8\,C_{\mathrm{usage}}(s)\ge 9\,T_{\mathrm{RA}}(s),\\[6pt]\left\lfloor P_{\mathrm{STR}}(s)\cdot\frac{C_{\mathrm{usage}}(s)}{T_{\mathrm{RA}}(s)} \right\rfloor,& \text{otherwise.}\end{cases}$

and so we can derive the following reference code:

```
EMA_DENOMINATOR = 2         # 1/beta
CLAMP_DENOMINATOR = 8       # denominator of 1+ alpha and 1-alpha
CLAMP_DOWN_NUMERATOR = 7    # numerator of 1-alpha
CLAMP_UP_NUMERATOR = 9      # numerator of 1+alpha

def update_usage(total_gas_consumed: int, previous_usage: int) -> int:
return (total_gas_consumed + previous_usage) // EMA_DENOMINATOR

def update_storage_price(prev_price: int, total_gas_consumed: int, usage: int) -> int:
if CLAMP_DENOMINATOR * total_gas_consumed <= CLAMP_DOWN_NUMERATOR * usage:
return prev_price * CLAMP_DOWN_NUMERATOR // CLAMP_DENOMINATOR
    elif CLAMP_DENOMINATOR * total_gas_consumed >= CLAMP_UP_NUMERATOR * usage:
return prev_price * CLAMP_UP_NUMERATOR // CLAMP_DENOMINATOR
else:
return prev_price * total_gas_consumed // usage

def update_storage_fee(total_gas_consumed: int, prev_price: int, prev_usage: int) -> tuple[int, int]:
    usage = update_usage(total_gas_consumed, prev_usage)
    price = update_storage_price(prev_price, total_gas_consumed, usage)
return price, usage
```

### Genesis State

The initial state of the TFM at network launch shall be configured as follows:

- Initial Price P_STR(0): Set to a pre-determined value established by genesis governance.
- Initial Usage EMA T_RA(-1): Set to the value of the baseline target, $T_{\text{base}}$. This anchors the mechanism to its long-term policy goal from the outset.

