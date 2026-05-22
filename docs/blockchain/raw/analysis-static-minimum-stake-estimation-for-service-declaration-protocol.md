# ANALYSISSTATIC-MINIMUM-STAKE-ESTIMATION-FOR-SERVICE-DECLARATION-PROTOCOL

| Field | Value |
| --- | --- |
| Name | [Analysis] Static Minimum Stake Estimation for Service Declaration Protocol |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | Frederico Teixeira <frederico@logos.co> |
| Contributors | Juan Pablo Madrigal-Cianci <jp@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) rendered via katex; tables and headings
> are converted from Notion HTML. A formatting polish (semantic line breaks, code block fences
> for code samples, internal cross-references) is still recommended.

---

## Revisions History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2026-04-24 |

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.
All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein.
Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

## Introduction

The [[1.0.0] Service Declaration Protocol](https://nomos-tech.notion.site/1-0-0-Service-Declaration-Protocol-1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=24) enables nodes to register for specific services in decentralized public registries by committing a predefined stake. Registered nodes may then provide the declared service in exchange for rewards. The protocol uses staking as a mechanism to ensure Sybil resistance and incentivize honest participation.

This document aims to define an optimal minimum stake value per node in the context of the SDP. The optimal minimum stake value must strike a careful balance: it should be high enough to discourage sybil attacks while remaining low enough to ensure broad participation, especially in early network stages. Importantly, the protocol mandates a uniform, constant stake value across services and sessions, adding constraints to its determination. We focus on static stake estimation method due to its simplicity.

Given that Logos Blockchain is a pre-launch L1 blockchain with no on-chain economic data, we include an analysis that builds on comparative valuation research of privacy related chains (Monero, Zcash, Dash, Mina Protocol, Oasis Network, and Secret Network). The methodology includes:

Estimating Logos Blockchain's Fully Diluted Valuation (FDV) using internal valuation models and comparable projects.

Defining key variables influencing staking mechanics, such as token supply at TGE, staking ratio, and target number of service providers.

Deriving a simple and transparent formula to calculate the required stake per service provider, both in LGO and stablecoins or fiat terms.

## Overview

The SDP is a staking-based registration mechanism designed for decentralized services in the Logos Blockchain ecosystem. Its primary purpose is to assign nodes to public service registries by requiring them to lock a predefined amount of LGO tokens as stake. Only nodes who stake the required amount are allowed to offer the service they declare, thereby creating a natural filter that promotes honest behavior and sybil resistance.

This protocol is parameterized by a single stake value that is:

Constant across all services and sessions, to ensure predictability and fairness.

Calibrated to balance security and accessibility, based on Logos Blockchains economic assumptions.

Using the model specified [below](https://www.notion.so/3a2261aa09df83e2a104012e29c21f34#4ab261aa09df8340b44001a8f61cbbf2), the protocol ensures that the stake requirement scales proportionally with Logos Blockchains market valuation and design goals, while remaining robust to economic fluctuations.

Under the assumptions explained below, we define the [minimum stake](https://www.notion.so/3a2261aa09df83e2a104012e29c21f34#65b261aa09df83d99dbd01e269c62e01) value in LGO as

$$
\text{Stake}\_{\text{LGO}} = 0.001\% \cdot S\_{\text{TGE}}.
$$
StakeLGO=0.001%STGE.

Assuming a fully diluted valuation of  $100$  million FIAT, and  $S\_{\text{TGE}}=S\_{\text{max}}$ , then the [minimum stake would be valued](https://nomos-tech.notion.site/3a2261aa09df83e2a104012e29c21f34?pvs=25#266261aa09df83819c5e01ddf1513ba3) at

$$
\text{Stake}\_{\text{FIAT}} = 1,000 \text{ FIAT}.
$$
StakeFIAT=1,000 FIAT.

## Construction

### Generic Model

Let

$S\_{\text{max}}$ denote the maximum supply of LGO (e.g., 10 million LGO).

$\text{FDV}$ denote the expected fully diluted valuation in FIAT (e.g., $100 million).

$S\_{\text{TGE}}$ denote the supply at token generation event (e.g., 1 million LGO).

$M\_{\text{cap}}$ denote the market cap at TGE in FIAT.

$$
M\_{\text{cap}} = \dfrac{S\_{\text{TGE}}}{S\_{\text{max}}} \times \text{FDV}
$$
Mcap=SmaxSTGEFDV

$P\_{\text{LGO}}$ denote the Price per LGO in FIAT.

$$
P\_{\text{LGO}} = \dfrac{M\_{\text{cap}}}{S\_{\text{TGE}}}
$$
PLGO=STGEMcap

$r\_{\text{stake}}$ denote the fraction of TGE supply expected to be staked by a service (e.g., 15%).

$N\_{\text{stakers}}$ denote the expected initial number of stakers (e.g., 1,000).

The following quantities are derived from the definitions above:

Total LGO to be staked:

$$
S\_{\text{staked}} = r\_{\text{stake}} \times S\_{\text{TGE}}
$$
Sstaked=rstakeSTGE

Amount of stake per staker in LGO:

$$
\text{Stake}\_{LGO} = \frac{S\_{\text{staked}}}{N\_{\text{stakers}}} = r\_{\text{stake}} \times \frac{S\_{\text{TGE}}}{N\_{\text{stakers}}}
$$
StakeLGO=NstakersSstaked=rstakeNstakersSTGE

Amount of stake per staker in FIAT:

$$
\begin{equation}
\text{Stake}\_{\text{FIAT}} = \text{Stake}\_{LGO} \times P\_{\text{LGO}} = \dfrac{r\_{\text{stake}}}
{N\_{\text{stakers}}} \times
\frac{S\_{\text{TGE}}}{S\_{\text{max}}} \times
\text{FDV}
\end{equation}
$$
StakeFIAT=StakeLGOPLGO=NstakersrstakeSmaxSTGEFDV

### Staking Ratio ( $r\_{\text{stake}}$ )

The [[1.0.0] Block Rewards](https://nomos-tech.notion.site/1-0-0-Block-Rewards-d96261aa09df838ca36601b4b27b49b4?pvs=24) proposes a 30% of TGE tokens as a target for the security of the PoS participation of [Cryptarchia](https://nomos-tech.notion.site/21c261aa09df810cb85eff1c76e5798c?pvs=25). This implies that it should not be possible for a single entity to acquire  $15\%$  of TGE supply. Therefore, we set  $r\_{\text{stake}}=15\%$ .

### Number of Service Providers ( $N\_{\text{stakers}}$ )

A network size that is considered small has 1000 nodes. Therefore,  $N\_{\text{stakers}}=1000$ .

### Minimum Stake ( $\text{Stake}\_{LGO}$ )

The stake value for the [Service Declaration Protocol](https://nomos-tech.notion.site/1fd261aa09df819ca9f8eb2bdfd4ec1d?pvs=25) (SDP) must satisfy the following requirements:

The stake value for all services should be the same and remain constant across sessions.

It should be high enough to prevent Sybil attacks, and low enough to ensure maximum participation.

Under the following conditions:

While rewards are desirable, there is no guarantee that all services provide rewards.

There is no cap to the amount of validators that can register to a specific service.

Therefore, the size of the stake should facilitate at least  $N\_{\text{stakers}}=1000$  nodes to acquire at least  $r\_{\text{stake}}=15\%$  of TGE supply. This implies the following cap to the stake value (per staker):

$$
\text{Stake}\_{\text{LGO}} \leq 0.015\% \cdot S\_{\text{TGE}}.
$$
StakeLGO0.015%STGE.

In order to lower even further any barriers to enter and promote decentralization, we set the minimum stake as:

$$
\text{Stake}\_{\text{LGO}} = 0.001\% \cdot S\_{\text{TGE}}.
$$
StakeLGO=0.001%STGE.

## Analysis

In what follows, this document defines Logos Blockchain valuation based on comparable projects, and then applies it to derive the minimal stake size in FIAT terms using the equation [(1)](https://www.notion.so/3a2261aa09df83e2a104012e29c21f34#d50261aa09df826d9a8d013ef50f11f9) above. FIAT, in this particular section, is USD.

### Logos Blockchain Valuation ( $\text{FDV}$ )

For a yet-to-be-released L1 blockchain, fundamental valuation is more challenging because there is no on-chain data (users, fees, transactions). Therefore, we will adopt a simple framework that compares Logos Blockchain with similar projects and assumes a valuation based on the mean or median of these comparable valuations.

| Project | Valuation | Last update | Remark |
| --- | --- | --- | --- |
| Monero (XMR) | $4.19B | Feb 2025 | Ring signatures, stealth addresses, confidential transactions Fully private transactions by default; resistance to ASIC mining. |
| Zcash (ZEC) | $534M | Feb 2025 | zk-SNARKs Optional transparency ("shielded" vs. "transparent" addresses). |
| Dash (DASH) | $309M | Feb 2025 | CoinJoin mixing (PrivateSend) Instant transactions (InstantSend); hybrid consensus (masternodes) |
| Mina Protocol | $356M | July 2024 | Recursive zk-SNARKs Constant-sized blockchain (22 KB); lightweight node participation. |
| Oasis Network | $246M | July 2024 | Trusted Execution Environments (TEEs) Privacy-preserving smart contracts; data tokenization for DeFi. |
| Secret Network | $62M | July 2024 | Encrypted contract states, secure MPC Private NFTs; encrypted data governance for decentralized apps. |

Given that the mean and median of the above valuations of already established projects are $949.5 million and $332.5 million, respectively, we establish Logos Blockchain valuation with a starting point of  $\text{FDV}= \$100$  million.

### Minimum Stake in FIAT Terms ( $\text{Stake}\_{\text{FIAT}}$ )

For the sake of this analysis, suppose that

$\text{FDV}= \$100$  million.

$S\_{\text{max}} = 100,000,000$ LGO.

$S\_{\text{TGE}} = S\_{\text{max}} = 100,000,000$ LGO.

$\text{Stake}\_{\text{LGO}} = 0.001\% \cdot S\_{\text{TGE}}.$ 

$N\_{\text{stakers}}=1000$ .

From the Construction section,

$$
\begin{array}{rclrclrclrcl}
\text{Stake}\_{\text{FIAT}} & = & \text{Stake}\_{\text{LGO}} \times P\_{\text{LGO}} = \text{Stake}\_{\text{LGO}} \times \dfrac{M\_{\text{cap}}}{S\_{\text{TGE}}} \\[12pt]
& = & \text{Stake}\_{\text{LGO}} \times \dfrac{\dfrac{S\_{\text{TGE}}}{S\_{\text{max}}} \times \text{FDV}}{S\_{\text{TGE}}} = \text{Stake}\_{\text{LGO}} \times \dfrac{\text{FDV}}{S\_{\text{TGE}}} \\[14pt]
& = & 0.001\% \cdot S\_{\text{TGE}} \times \dfrac{\text{FDV}}{S\_{\text{TGE}}} = 0.001\% \cdot \text{FDV}
\end{array}
$$
StakeFIAT===StakeLGOPLGO=StakeLGOSTGEMcapStakeLGOSTGESmaxSTGEFDV=StakeLGOSTGEFDV0.001%STGESTGEFDV=0.001%FDV

(In the second row,  $S\_{\text{TGE}}$  and  $S\_{\text{max}}$  cancel each other because they are assumed to be equal.)

By plugging the numbers, and considering the above-mentioned assumptions, the single stake value for the SDP would be

$$
\text{Stake}\_{\text{LGO}} = 1,000 \text{ LGO},
$$
StakeLGO=1,000 LGO,

which would be valued at

$$
\text{Stake}\_{\text{FIAT}} = \$1,000.
$$
StakeFIAT=$1,000.
