# ANALYSISEXECUTION-MARKET

| Field | Value |
| --- | --- |
| Name | [Analysis] Execution Market |
| Slug |  |
| Status | raw |
| Category | Informational |
| Editor | Juan Pablo Madrigal-Cianci <jp@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Juan Pablo Madrigal-Cianci <jp@logos.co>

Revisions History

Version 

Changes 

Date

1.0.0 

Initial revision 

2026-04-24

���

Disclamer:
This material, including any linked pages or documents, is provided for informational purposes only. It does not constitute investment advice, a solicitation, or an offer to buy or sell any securities, tokens, or other financial instruments, nor should it be construed as legal, financial, or tax advice.

All information regarding project details, token design, distribution mechanisms, technical parameters, and any forward-looking statements is preliminary and subject to change without notice. No representations or warranties are made as to the completeness or accuracy of the information herein. 

Nothing in this material should be relied upon for investment or business decisions. Recipients of this information assume all risks associated with its use and are responsible for seeking independent professional advice regarding any actions based on it.

Introduction

We provide here a formal mathematical analysis of the execution market's fee mechanism. We model the system's dynamics to evaluate its equilibrium state, stability, and the economic impact of its unique features, particularly the block builder subsidy. We also refer the interested reader to Base Fee Manipulation In Ethereum���s EIP-1559 Transaction Fee Mechanism.

System Dynamics and Equilibrium

The state of the system evolves block-by-block, defined by two key variables: the base fee, bexec[s]b_\text{exec}[s]bexec���[s], and the EMA of execution gas usage, Gavg[s]G_{\text{avg}}[s]Gavg���[s]. Their evolution is described by the following system of equations:

Gavg[s]=(1���q)���G(bexec[s])+q���Gavg[s���1]bexec[s+1]=bexec[s]���(1+�����Gavg[s]���GtargetGtarget)\begin{align}
G_{\text{avg}}[s] &= (1 - q) \cdot G(b_\text{exec}[s]) + q \cdot G_{\text{avg}}[s-1]\\
b_\text{exec}[s+1] &= b_\text{exec}[s] \cdot \left(1 + \phi \cdot \frac{G_{\text{avg}}[s] - G_{\text{target}}}{G_{\text{target}}}\right)
\end{align}Gavg���[s]bexec���[s+1]���=(1���q)���G(bexec���[s])+q���Gavg���[s���1]=bexec���[s]���(1+�����Gtarget���Gavg���[s]���Gtarget������)������

Here, we model the total Execution Gas used in a block, G[s]G[s]G[s], as a function of the base fee, G[bexec[s]]G[b_\text{exec}[s] ]G[bexec���[s]], where we assume a standard demand curve with G���<0G' < 0G���<0 (demand for Execution Gas decreases as the price increases).

The system is in equilibrium when its state variables no longer change. Let the equilibrium state be (b���,Gavg���)(b^*, G_{\text{avg}}^*)(b���,Gavg������). From the base fee update rule (2), for bexec[s+1]=bexec[s]=b���b_\text{exec}[s+1] = b_\text{exec}[s] = b^*bexec���[s+1]=bexec���[s]=b���, the adjustment factor must be zero. This implies:

Gavg������Gtarget=0���������������Gavg���=Gtarget
G_{\text{avg}}^* - G_{\text{target}} = 0 \implies \boldsymbol{G_{\text{avg}}^* = G_{\text{target}}}Gavg���������Gtarget���=0���Gavg������=Gtarget���

From the EMA update rule (1), for Gavg[s]=Gavg[s���1]=Gavg���G_{\text{avg}}[s] = G_{\text{avg}}[s-1] = G_{\text{avg}}^*Gavg���[s]=Gavg���[s���1]=Gavg������, we must have:

Gavg���=(1���q)���G[b���]+q���Gavg���(1���q)���Gavg���=(1���q)���G[b���]���������������Gavg���=G[b���]\begin{aligned}G_{\text{avg}}^* =& (1 - q) \cdot G[b^*] + q \cdot G_{\text{avg}}^*\\
(1 - q) \cdot G_{\text{avg}}^* =& (1 - q) \cdot G[b^*]\\
\implies& {G_{\text{avg}}^* = G[b^*]}\end{aligned}Gavg������=(1���q)���Gavg������=������(1���q)���G[b���]+q���Gavg������(1���q)���G[b���]Gavg������=G[b���]���

Conclusion: Combining these results, the system reaches equilibrium when the execution gas demanded by the market at price b���b^*b��� is exactly equal to the protocol's target: G[b���]=Gtarget{G[b^*] = G_{\text{target}}}G[b���]=Gtarget���. The equilibrium base fee, b���b^*b���, is the market-clearing price that induces a level of network activity precisely equal to the desired target.

Base Fee Stability Analysis

Stability analysis determines if the system will naturally converge to the equilibrium state (b���,Gtarget)(b^*, G_{\text{target}})(b���,Gtarget���) after a market shock. Due to the two-variable, cross-dependent nature of the system, we analyze the Jacobian matrix of the linearized system around the equilibrium point.

The system can be written as a function F(bexec[s],Gavg[s���1])=(bexec[s+1],Gavg[s])F(b_\text{exec}[s], G_{\text{avg}}[s-1]) = (b_\text{exec}[s+1], G_{\text{avg}}[s])F(bexec���[s],Gavg���[s���1])=(bexec���[s+1],Gavg���[s]). The Jacobian matrix JJJ is:

J=(���bexec[s+1]���bexec[s]���bexec[s+1]���Gavg[s]���Gavg[s]���bexec[s]���Gavg[s]���Gavg[s���1])\begin{aligned}J = \begin{pmatrix}
\displaystyle \frac{\partial b_\text{exec}[s+1]}{\partial b_\text{exec}[s]} & \displaystyle \frac{\partial b_\text{exec}[s+1]}{\partial G_{\text{avg}}[s]} \\
\displaystyle \frac{\partial G_{\text{avg}}[s]}{\partial b_\text{exec}[s]} & \displaystyle\frac{\partial G_{\text{avg}}[s]}{\partial G_{\text{avg}}[s-1]} \end{pmatrix}\end{aligned}J=������bexec���[s]���bexec���[s+1]������bexec���[s]���Gavg���[s]���������Gavg���[s]���bexec���[s+1]������Gavg���[s���1]���Gavg���[s]������������

Evaluating the partial derivatives at the equilibrium point yields:

���bexec[s+1]���bexec[s]=1+��(1���q)b���G���[b���]Gtarget\displaystyle \frac{\partial b_\text{exec}[s+1]}{\partial b_\text{exec}[s]} = 1 + \phi (1-q)\frac{b^* G'[b^*]}{G_{\text{target}}}���bexec���[s]���bexec���[s+1]���=1+��(1���q)Gtarget���b���G���[b���]������

���bexec[s+1]���Gavg[s]=��q���b���Gtarget\displaystyle \frac{\partial b_\text{exec}[s+1]}{\partial G_{\text{avg}}[s]} = \phi \frac{q \cdot b^*}{G_{\text{target}}}���Gavg���[s]���bexec���[s+1]���=��Gtarget���q���b���������

���Gavg[s]���bexec[s]=(1���q)G���[b���]\displaystyle \frac{\partial G_{\text{avg}}[s]}{\partial b_\text{exec}[s]} = (1-q)G'[b^*]���bexec���[s]���Gavg���[s]���=(1���q)G���[b���]���

���Gavg[s]���Gavg[s���1]=q\displaystyle \frac{\partial G_{\text{avg}}[s]}{\partial G_{\text{avg}}[s-1]} = q���Gavg���[s���1]���Gavg���[s]���=q���

The system is stable if and only if the eigenvalues of this matrix have a magnitude less than 1. While the full characteristic equation is complex, the analysis shows that stability is primarily dependent on the parameters ��\phi��, qqq, and the price elasticity of demand, E=b���G���[b���]Gtarget\mathcal{E} = \frac{b^* G'[b^*]}{G_{\text{target}}}E=Gtarget���b���G���[b���]���.

The introduction of the EMA smoothing factor qqq significantly enhances stability compared to the classic EIP-1559 model (which is equivalent to setting q=0q=0q=0). The term qqq acts as a damper, reducing the magnitude of the eigenvalues and making the system resilient to oscillations and divergence, even with highly elastic demand. This mathematical property is the foundation of the mechanism's resistance to base fee manipulation attacks.

User and block builder Incentive Analysis

User Strategy: A rational user has a private valuation for their transaction's inclusion, Vt.V_t.Vt���. Their utility is Ut=Vt���gt���ctU_t = V_t - g_t \cdot c_tUt���=Vt������gt������ct���. For the transaction to be valid, they must set their Execution Gas price ct���bexec[s]c_t \ge b_\text{exec}[s]ct������bexec���[s]. The user's problem is to choose ctc_tct��� to maximize their expected utility.

Setting ctc_tct��� much higher than bexec[s]b_\text{exec}[s]bexec���[s] does not guarantee faster inclusion than setting it slightly higher; inclusion speed is determined by the priority fee pt=ct���bexec[s]p_t = c_t - b_\text{exec}[s]pt���=ct������bexec���[s] relative to other users. 

The optimal strategy is to set ctc_tct��� such that it reflects their true marginal valuation per unit of execution gas, ct���=Vt/gtc_t^* = V_t / g_tct������=Vt���/gt���. They then pay bexec[s]b_\text{exec}[s]bexec���[s] (base fee) plus a competitive tip ptp_tpt��� that they believe is sufficient for inclusion.

block builder Strategy: A rational block builder seeks to maximize their total block reward, RproposerR_{\text{proposer}}Rproposer��� (cf ����[1.0.0] Block Rewards). Maximizing this sum is achieved by a greedy algorithm: sort all valid transactions by their revenue and include them in descending order until the block is full.

Conclusion: The subsidy mechanism, while critical for block builder revenue, does not distort the transaction selection incentive. The dominant strategy remains to prioritize transactions with the highest total tips, which aligns the block builder's interest with that of users who value inclusion the most.

References

����[1.0.0] Blend Protocol - Rewarding 

StableFee https://pubsonline.informs.org/doi/abs/10.1287/mnsc.2023.4735

Base Fee Manipulation In Ethereum���s EIP-1559 Transaction Fee Mechanism

Transaction fees on a honeymoon

����[1.0.0] Anonymous Leaders Reward Protocol 

����[1.0.0][Overview] Cryptoeconomics 

EIP 1559: A transaction fee market proposal���
