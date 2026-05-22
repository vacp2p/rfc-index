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

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Frederico Teixeira <frederico@logos.co>, Juan Pablo Madrigal-Cianci <jp@logos.co>

Revisions History

Version 

Changes 

Date

1.0.0 

Initial revision. 

2026-04-24

���

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.

All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 

Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

Introduction

The ����[1.0.0] Service Declaration Protocol enables nodes to register for specific services in decentralized public registries by committing a predefined stake. Registered nodes may then provide the declared service in exchange for rewards. The protocol uses staking as a mechanism to ensure Sybil resistance and incentivize honest participation.

This document aims to define an optimal minimum stake value per node in the context of the SDP. The optimal minimum stake value must strike a careful balance: it should be high enough to discourage sybil attacks while remaining low enough to ensure broad participation, especially in early network stages. Importantly, the protocol mandates a uniform, constant stake value across services and sessions, adding constraints to its determination. We focus on static stake estimation method due to its simplicity.

Given that Logos Blockchain is a pre-launch L1 blockchain with no on-chain economic data, we include an analysis that builds on comparative valuation research of privacy related chains (Monero, Zcash, Dash, Mina Protocol, Oasis Network, and Secret Network). The methodology includes:

Estimating Logos Blockchain's Fully Diluted Valuation (FDV) using internal valuation models and comparable projects.

Defining key variables influencing staking mechanics, such as token supply at TGE, staking ratio, and target number of service providers.

Deriving a simple and transparent formula to calculate the required stake per service provider, both in LGO and stablecoins or fiat terms.

Overview

The SDP is a staking-based registration mechanism designed for decentralized services in the Logos Blockchain ecosystem. Its primary purpose is to assign nodes to public service registries by requiring them to lock a predefined amount of LGO tokens as stake. Only nodes who stake the required amount are allowed to offer the service they declare, thereby creating a natural filter that promotes honest behavior and sybil resistance.

This protocol is parameterized by a single stake value that is:

Constant across all services and sessions, to ensure predictability and fairness.

Calibrated to balance security and accessibility, based on Logos Blockchain���s economic assumptions.

Using the model specified below, the protocol ensures that the stake requirement scales proportionally with Logos Blockchain���s market valuation and design goals, while remaining robust to economic fluctuations.

Under the assumptions explained below, we define the minimum stake value in LGO as

StakeLGO=0.001%���STGE.\text{Stake}_{\text{LGO}} = 0.001\% \cdot S_{\text{TGE}}.StakeLGO���=0.001%���STGE���.

Assuming a fully diluted valuation of 100100100 million FIAT, and STGE=SmaxS_{\text{TGE}}=S_{\text{max}}STGE���=Smax���, then the minimum stake would be valued at

StakeFIAT=1,000 FIAT.\text{Stake}_{\text{FIAT}} = 1,000 \text{ FIAT}.StakeFIAT���=1,000 FIAT.

Construction

Generic Model

Let

SmaxS_{\text{max}}Smax��� denote the maximum supply of LGO (e.g., 10 million LGO).

FDV\text{FDV}FDV denote the expected fully diluted valuation in FIAT (e.g., $100 million).

STGES_{\text{TGE}}STGE��� denote the supply at token generation event (e.g., 1 million LGO).

McapM_{\text{cap}}Mcap��� denote the market cap at TGE in FIAT.

Mcap=STGESmax��FDVM_{\text{cap}} = \dfrac{S_{\text{TGE}}}{S_{\text{max}}} \times \text{FDV}Mcap���=Smax���STGE��������FDV

PLGOP_{\text{LGO}}PLGO��� denote the Price per LGO in FIAT.

PLGO=McapSTGEP_{\text{LGO}} = \dfrac{M_{\text{cap}}}{S_{\text{TGE}}}PLGO���=STGE���Mcap������

rstaker_{\text{stake}}rstake��� denote the fraction of TGE supply expected to be staked by a service (e.g., 15%).

NstakersN_{\text{stakers}}Nstakers��� denote the expected initial number of stakers (e.g., 1,000).

The following quantities are derived from the definitions above:

Total LGO to be staked:

Sstaked=rstake��STGES_{\text{staked}} = r_{\text{stake}} \times S_{\text{TGE}}Sstaked���=rstake�����STGE���

Amount of stake per staker in LGO:

StakeLGO=SstakedNstakers=rstake��STGENstakers\text{Stake}_{LGO} = \frac{S_{\text{staked}}}{N_{\text{stakers}}} = r_{\text{stake}} \times \frac{S_{\text{TGE}}}{N_{\text{stakers}}}StakeLGO���=Nstakers���Sstaked������=rstake�����Nstakers���STGE������

Amount of stake per staker in FIAT:

StakeFIAT=StakeLGO��PLGO=rstakeNstakers��STGESmax��FDV \begin{equation}
\text{Stake}_{\text{FIAT}} = \text{Stake}_{LGO} \times P_{\text{LGO}} = \dfrac{r_{\text{stake}}}
{N_{\text{stakers}}} \times
\frac{S_{\text{TGE}}}{S_{\text{max}}} \times
\text{FDV}
\end{equation}StakeFIAT���=StakeLGO�����PLGO���=Nstakers���rstake��������Smax���STGE��������FDV������

Staking Ratio (rstaker_{\text{stake}}rstake���)

The ����[1.0.0] Block Rewards proposes a 30% of TGE tokens as a target for the security of the PoS participation of Cryptarchia. This implies that it should not be possible for a single entity to acquire 15%15\%15% of TGE supply. Therefore, we set rstake=15%r_{\text{stake}}=15\%rstake���=15%.

Number of Service Providers (NstakersN_{\text{stakers}}Nstakers���)

A network size that is considered small has 1000 nodes. Therefore, Nstakers=1000N_{\text{stakers}}=1000Nstakers���=1000.

Minimum Stake (StakeLGO\text{Stake}_{LGO}StakeLGO���)

The stake value for the Service Declaration Protocol (SDP) must satisfy the following requirements:

The stake value for all services should be the same and remain constant across sessions.

It should be high enough to prevent Sybil attacks, and low enough to ensure maximum participation.

Under the following conditions:

While rewards are desirable, there is no guarantee that all services provide rewards.

There is no cap to the amount of validators that can register to a specific service.

Therefore, the size of the stake should facilitate at least Nstakers=1000N_{\text{stakers}}=1000Nstakers���=1000 nodes to acquire at least rstake=15%r_{\text{stake}}=15\%rstake���=15% of TGE supply. This implies the following cap to the stake value (per staker):

StakeLGO���0.015%���STGE.\text{Stake}_{\text{LGO}} \leq 0.015\% \cdot S_{\text{TGE}}.StakeLGO������0.015%���STGE���.

In order to lower even further any barriers to enter and promote decentralization, we set the minimum stake as:

StakeLGO=0.001%���STGE.\text{Stake}_{\text{LGO}} = 0.001\% \cdot S_{\text{TGE}}.StakeLGO���=0.001%���STGE���.

Analysis

In what follows, this document defines Logos Blockchain valuation based on comparable projects, and then applies it to derive the minimal stake size in FIAT terms using the equation (1) above. FIAT, in this particular section, is USD.

Logos Blockchain Valuation (FDV\text{FDV}FDV)

For a yet-to-be-released L1 blockchain, fundamental valuation is more challenging because there is no on-chain data (users, fees, transactions). Therefore, we will adopt a simple framework that compares Logos Blockchain with similar projects and assumes a valuation based on the mean or median of these comparable valuations.

Project

Valuation

Last update

Remark

Monero (XMR) 

$4.19B 

Feb 2025 

Ring signatures, stealth addresses, confidential transactions Fully private transactions by default; resistance to ASIC mining.

Zcash (ZEC) 

$534M 

Feb 2025 

zk-SNARKs Optional transparency ("shielded" vs. "transparent" addresses).

Dash (DASH) 

$309M 

Feb 2025 

CoinJoin mixing (PrivateSend) Instant transactions (InstantSend); hybrid consensus (masternodes)

Mina Protocol 

$356M 

July 2024 

Recursive zk-SNARKs Constant-sized blockchain (22 KB); lightweight node participation.

Oasis Network 

$246M 

July 2024 

Trusted Execution Environments (TEEs) Privacy-preserving smart contracts; data tokenization for DeFi.

Secret Network 

$62M 

July 2024 

Encrypted contract states, secure MPC Private NFTs; encrypted data governance for decentralized apps.

Given that the mean and median of the above valuations of already established projects are $949.5 million and $332.5 million, respectively, we establish Logos Blockchain valuation with a starting point of FDV=$100\text{FDV}= \$100FDV=$100 million.

Minimum Stake in FIAT Terms (StakeFIAT\text{Stake}_{\text{FIAT}}StakeFIAT���)

For the sake of this analysis, suppose that

FDV=$100\text{FDV}= \$100FDV=$100 million.

Smax=100,000,000S_{\text{max}} = 100,000,000Smax���=100,000,000 LGO.

STGE=Smax=100,000,000S_{\text{TGE}} = S_{\text{max}} = 100,000,000STGE���=Smax���=100,000,000 LGO.

StakeLGO=0.001%���STGE.\text{Stake}_{\text{LGO}} = 0.001\% \cdot S_{\text{TGE}}.StakeLGO���=0.001%���STGE���.���

Nstakers=1000N_{\text{stakers}}=1000Nstakers���=1000.

From the Construction section,

StakeFIAT=StakeLGO��PLGO=StakeLGO��McapSTGE=StakeLGO��STGESmax��FDVSTGE=StakeLGO��FDVSTGE=0.001%���STGE��FDVSTGE=0.001%���FDV\begin{array}{rclrclrclrcl}
\text{Stake}_{\text{FIAT}} & = & \text{Stake}_{\text{LGO}} \times P_{\text{LGO}} = \text{Stake}_{\text{LGO}} \times \dfrac{M_{\text{cap}}}{S_{\text{TGE}}} \\[12pt]
& = & \text{Stake}_{\text{LGO}} \times \dfrac{\dfrac{S_{\text{TGE}}}{S_{\text{max}}} \times \text{FDV}}{S_{\text{TGE}}} = \text{Stake}_{\text{LGO}} \times \dfrac{\text{FDV}}{S_{\text{TGE}}} \\[14pt]
& = & 0.001\% \cdot S_{\text{TGE}} \times \dfrac{\text{FDV}}{S_{\text{TGE}}} = 0.001\% \cdot \text{FDV}
\end{array}StakeFIAT������===���StakeLGO�����PLGO���=StakeLGO�����STGE���Mcap������StakeLGO�����STGE���Smax���STGE��������FDV���=StakeLGO�����STGE���FDV���0.001%���STGE�����STGE���FDV���=0.001%���FDV���

(In the second row, STGES_{\text{TGE}}STGE��� and SmaxS_{\text{max}}Smax��� cancel each other because they are assumed to be equal.)

By plugging the numbers, and considering the above-mentioned assumptions, the single stake value for the SDP would be 

StakeLGO=1,000 LGO,\text{Stake}_{\text{LGO}} = 1,000 \text{ LGO},StakeLGO���=1,000 LGO,

which would be valued at

StakeFIAT=$1,000.\text{Stake}_{\text{FIAT}} = \$1,000.StakeFIAT���=$1,000.
