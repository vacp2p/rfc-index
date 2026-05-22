# BEDROCK-GENESIS-BLOCK

| Field | Value |
| --- | --- |
| Name | Bedrock Genesis Block Specification |
| Slug | 90 |
| Status | raw |
| Category | Standards Track |
| Editor | David Rusu <davidrusu@logos.co> |
| Contributors | Hong-Sheng Zhou, Thomas Lavaur <thomaslavaur@logos.co>, Marcin Pawlowski <marcin@logos.co>, Mehmet Gonen <mehmet@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Daniel Sanchez Quiros <danielsq@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/bedrock-genesis-block.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/bedrock-genesis-block.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

---

> **Note on this content sync:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) via katex; tables and headings
> are converted from Notion HTML. Formatting polish (semantic line breaks, code block fences,
> internal cross-references) may still be needed.

---

## Revisions History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2026-02-12 |
| 1.1.0 | [[RFC] Make Ledger Transaction an Operation](https://nomos-tech.notion.site/RFC-Make-Ledger-Transaction-an-Operation-31e261aa09df80bc9e02ea4e9affc082?pvs=24) Renamed Nomos to Logos Blockchain Remove notions of DA Minor fix in gas price | 2026-03-27 |
| 1.1.1 | [[RFC] Simplify Mantle Transaction and Refactor Ledger Operations](https://nomos-tech.notion.site/RFC-Simplify-Mantle-Transaction-and-Refactor-Ledger-Operations-33d261aa09df803d96b0ebcd83013865?pvs=24) | 2026-05-06 |

## Introduction

The Genesis Block defines the starting state for the Bedrock chain, including the initial bedrock service providers, LGO token distribution and protocol parameters. Its design draws from best practices in the Ouroboros family of protocols (notably Praos and Genesis), as well as privacy and resilience advances from Cryptarchia and related research. The Genesis Block is the root of trust for all subsequent protocol operations and must be constructed in a way that is deterministic, verifiable, and robust against long-range or bootstrap attacks.

## Overview

The Genesis Block establishes the initializing values for the various protocols and services. This includes the initial token distribution, initial nodes participating in Blend Network and the result of running the epoch nonce ceremony.

The block body is a single Mantle Transaction (see [[1.5.0] Mantle](https://nomos-tech.notion.site/1-5-0-Mantle-33d261aa09df8051b0d0cd4d5ddade85?pvs=24)) containing a Transfer Operation distributing the notes to initial token holders. The bedrock services are initialized through

SDP\_DECLARE

Operations embedded in the Mantle Transactions Operations list and protocol initializing constants are encoded through a

CHANNEL\_INSCRIBE

Operation also embedded in the Operations list.

Not all protocol constants are encoded in the Genesis block. The principle we use to decide whether a value should be in the Genesis block or not is whether it is a value that is derived from blockchain activity or whether it is updated through a protocol update (hard / soft fork). For example, the epoch nonce is updated through normal blockchain Operations and therefore it should be specified in the Genesis block. Gas constants are only changed through protocol updates and hard forks and therefore they will be hardcoded in the node implementation.

## Genesis Block Data Structure

The Genesis Block is composed of the Genesis Block Header and the Genesis Mantle Transaction (there is a single transaction in the genesis block). The Mantle Transaction contains all information necessary for initializing Bedrock Services and Cryptarchia state, as well as distributing the initial tokens to stakeholders.

### Initial Token Distribution

Initial tokens will be distributed through a Transfer Operation containing zero inputs and one output note for each initial stakeholder. Note that since the Ledger is transparent, the initial stake allocation is visible to everyone. Those wishing to hide their initial stake may opt to subdivide their note into a few different notes of equal value.

In order to participate in the Cryptarchia lottery, stakeholders must generate their note keys in accordance with the Proof of Leadership protocol specified at [[1.1.0] Proof of Leadership - Protocol](https://nomos-tech.notion.site/Protocol-2e9261aa09df80058244c902defc6da2?pvs=24#2e9261aa09df8034a40fe8405891b855).

The initial state of the Ledger will be derived through normal execution of this Transfer Operation, that is, each outputs note ID will be added to the unspent notes set.

Example

STAKE\_DISTRIBUTION = Transfer(
inputs=[],
outputs=[
Note(value=1000, public\_key=STAKE\_HOLDER\_0\_PK),
Note(value=2000, public\_key=STAKE\_HOLDER\_1\_PK),
Note(value=1500, public\_key=STAKE\_HOLDER\_2\_PK),
# ...
]
)

### Initial Service Declarations

Blend Network MUST initialize its set of providers. This is done through a set of

SDP\_DECLARE

Operations in the Genesis Mantle Transaction.

Blend enforces a minimal network size for the service to be active. Thus, in order to have an active Blend service at Genesis, we MUST have at least as many declarations in the Genesis block to meet Blend services minimal network size [[1.0.0] Blend Protocol - Minimal Network Size](https://nomos-tech.notion.site/Minimal-Network-Size-215261aa09df81ae8857d71066a80084?pvs=24#232261aa09df80b9ba20ec70636e0db6).

Example

BLEND\_DECLARATIONS = [
Declaration(
msg=DeclarationMessage(
ServiceType.BLEND, ["ip://1.1.1.1:3000"], PROVIDER\_ID\_0, ZK\_ID\_0
),
locked\_note\_id=STAKE\_DISTRIBUTION\_TX.output\_note\_id(0)
),
# ... 32 total declarations
]
SERVICE\_DECLARATIONS = BLEND\_DECLARATIONS

### Cryptarchia Parameters

Cryptarchia is initialized with the following parameters:

genesis\_time

: ISO 8601 encoded timestamp.

Cryptarchia uses slots as a measure of time offset from some start time. This timestamp must be agreed upon by all nodes in order to have a common clock.

chain\_id

: string.

It is useful to differentiate testnets from mainnet. To avoid confusion, we place the chain ID in the Genesis block to guarantee that the networks are disjoint.

genesis\_epoch\_nonce

: 32 bytes, hex encoded.

The initial source of randomness for the Cryptarchia lottery. The process for selecting this value is described in detail at [Epoch Nonce Ceremony](https://nomos-tech.notion.site/Epoch-Nonce-Ceremony-33e261aa09df808ea9a5e2a1edbe8dd0?pvs=24#2fd261aa09df82649b2f813c46159fcf).

These parameters are encoded in the Genesis block as an inscription sent to the null channel.

Example

from datetime import datetime
CHAIN\_ID = "logos-blockchain-mainnet"
GENESIS\_TIME = "2026-01-05T19:20:35+00:00"
GENESIS\_EPOCH\_NONCE = "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890"
chain\_id\_enc = CHAIN\_ID.encode("utf-8")
chain\_id\_len = len(chain\_id\_enc).to\_bytes(8, "little")
genesis\_time = int(datetime.fromisoformat(GENESIS\_TIME).timestamp()).to\_bytes(8, "little")
genesis\_epoch\_nonce = bytes.fromhex(GENESIS\_EPOCH\_NONCE)
inscription = chain\_id\_len + chain\_id\_enc + genesis\_time + genesis\_epoch\_nonce
# >>> inscription.hex()
# '0d000000000000006e6f6d6f732d6d61696e6e6574030f5c6900000000abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890'
CRYPTARCHIA\_INSCRIPTION = Inscribe(
channel=bytes(32),
inscription=inscription
parent=bytes(32),
signer=Ed25519PublicKey\_ZERO,
)

#### Epoch Nonce Ceremony

The initial epoch nonce value governs the Cryptarchia lottery randomness for the first epoch. It must be revealed AFTER the initial stake distribution has been frozen. This is done to prevent any stakeholders from gaining an unfair advantage from prior knowledge of the lottery randomness.

The protocol for generating the initial randomness nonce can be found below.

Schedule Epoch Nonce Ceremony Event:

We must fix well in advance when this epoch nonce ceremony will take place, let

t

denote the time of the Epoch Nonce Ceremony, broadcast

t

 widely.

The

STAKE\_DISTRIBUTION

must be finalized before

t

 to ensure a fair Cryptarchia slot lottery.

Randomness Collection:

We collect the entropy from multiple randomness sources:

| Entropy Source | Details |
| --- | --- |
| Bitcoin block hash immediately after time t , denoted as $r\_1$ . | Block hash can be found on [blockchain.com](http://blockchain.com/) s bitcoin block explorer, e.g. <https://www.blockchain.com/explorer/blocks/btc/905030> |
| Ethereum block hash immediately after time t , denoted as $r\_2$ . | Block hash can be found in the more details section of when viewing a block on etherscan, e.g. <https://etherscan.io/block/22894116> |
| DRAND beacon value for the round immediately after t , denoted as $r\_3$ . | Use the default beacon, and find the round number corresponding to t . <https://api.drand.sh/v2/beacons/default/rounds/1234> |

Randomness Derivation:

Once all above entropy contributions, i.e., $r\_1,r\_2,r\_3$ are collected, then we can compute the initial epoch randomness $\eta\_{\text{GENESIS}}$ as:

$$
\eta\_\text{GENESIS}={H}(r\_1,r\_2,r\_3)
$$
GENESIS=H(r1,r2,r3)

where $H$ is a collision-resistant zkhash function.

### Genesis Mantle Transaction

The initial stake distribution, service declarations and Cryptarchia inscription are components of the Genesis Mantle Transaction. This is the single transaction that forms the body of the Genesis block.

GENESIS\_MANTLE\_TX = MantleTx(
ops=[STAKE\_DISTRIBUTION, CRYPTARCHIA\_INSCRIPTION] + SERVICE\_DECLARATIONS,
)

### Block Header Fields

The Genesis Block header fields are set to the following values:

bedrock\_version

: Protocol version (e.g., 1).

parent\_block

: 0 (as this is the first block).

slot

: 0 (the Genesis slot).

block\_root

: Block Merkle root over the (single) initial transaction.

proof\_of\_leadership

: Stubbed leadership proof.

leader\_voucher

: 0 (as there is no leader block reward for the initial block).

entropy\_contribution

: 0 (no entropy is provided through the initial PoL).

proof

: Null Groth16Proof, all values are set to zero.

leader\_key

: Null PublicKey.

Example

GENESIS\_HEADER = Header(
bedrock\_version=1,
parent\_block=0,
slot=0,
block\_root=block\_merkle\_root([GENESIS\_MANTLE\_TX]),
proof\_of\_leadership=ProofOfLeadership(
leader\_voucher=bytes(32),
entropy\_contribution=bytes(32),
proof=Groth16Proof(G1\_ZERO, G2\_ZERO, G1\_ZERO),
leader\_key=Ed25519PublicKey\_ZERO,
)
)

# distribute NMO to all stakeholders
STAKE\_DISTRIBUTION = Transfer(
inputs=[],
outputs=[
Note(value=1000, public\_key=STAKE\_HOLDER\_0\_PK),
Note(value=2000, public\_key=STAKE\_HOLDER\_1\_PK),
Note(value=1500, public\_key=STAKE\_HOLDER\_2\_PK),
# ...
]
)
# set Cryptarchia parameters
CRYPTARCHIA\_PARAMS = {
"chain\_id": "nomos-mainnet",
"genesis\_time": "2026-01-05T19:20:35Z",
"genesis\_epoch\_nonce": "abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890",
}
CRYPTARCHIA\_INSCRIPTION = Inscribe(
channel=bytes(32),
inscription=json.dumps(CRYPTARCHIA\_PARAMS).encode("utf-8"),
parent=bytes(32),
signer=Ed25519PublicKey\_ZERO,
)

# service declarations
BLEND\_DECLARATIONS = [
Declaration(
msg=DeclarationMessage(ServiceType.BLEND, ["ip://1.1.1.1:3000"], PROVIDER\_ID\_0, ZK\_ID\_0),
locked\_note\_id=STAKE\_DISTRIBUTION.output\_note\_id(0)
),
# ... more declarations
]
SERVICE\_DECLARATIONS = BLEND\_DECLARATIONS
# build the genesis Mantle Transaction
GENESIS\_MANTLE\_TX = MantleTx(
ops=[STAKE\_DISTRIBUTION, CRYPTARCHIA\_INSCRIPTION] + SERVICE\_DECLARATIONS,
)
GENESIS\_HEADER = Header(
bedrock\_version=1,
parent\_block=bytes(32),
slot=0,
block\_root=block\_merkle\_root([GENESIS\_MANTLE\_TX]),
proof\_of\_leadership=ProofOfLeadership(
leader\_voucher=bytes(32),
entropy\_contribution=bytes(32),
proof=Groth16Proof(G1.ZERO, G2.ZERO, G1.ZERO),
leader\_key=Ed25519PublicKey\_ZERO,
)
)
GENESIS\_BLOCK = (GENESIS\_HEADER, [GENESIS\_MANTLE\_TX])

## Sample Genesis Block

## Initializing Bedrock

Bedrock is initialized by executing the Mantle Transaction without validating the Mantle Operations. No validation or execution is done for the Genesis block header; in particular, processing of

proof\_of\_leadership

is skipped.

### Mantle Ledger Initialization

The Transfer Operation should be executed without checking that the transaction is balanced. However, other validations are checked, e.g. that output note values are positive and smaller than the maximum allowed value. The result of normal transfer execution adds all outputs to the Ledger.

### Cryptarchia Initialization

The Mantle Transaction contains an inscription sent to the null channel containing the parameters for initializing Cryptarchia.

The Cryptarchia slot clock is initialized to

genesis\_time

,

LIB

is set to the Genesis block and the epoch state is then initialized:

#### Initial Epoch State

Cryptarchia progresses in epochs where the variables governing the lottery are fixed for the duration of an epoch and the activity during that epoch is used to derive the values of those variables for the next epoch. These variables taken together are called the Epoch State. (see [[1.0.1] Cryptarchia Protocol - Epoch State](https://nomos-tech.notion.site/Epoch-State-21c261aa09df810cb85eff1c76e5798c?pvs=24#21c261aa09df817aa264c821681a9efb)).

To initialize the Epoch State, we derive the epoch variables from the genesis block.

$\eta$ : the epoch nonce is taken directly from the

genesis\_epoch\_nonce

.

$\mathbb{C}\_\text{LEAD}$ : Eligible leader commitment is set to the the Ledger Root over all notes from the initial token distribution. The derivation of this root is specified in [[1.1.0] Proof of Leadership - Ledger Root](https://nomos-tech.notion.site/Ledger-Root-2e9261aa09df80058244c902defc6da2?pvs=24#2e9261aa09df8062a622d875b5ad43e9).

$D$ : The initial estimate of total stake will be the total tokens distributed at genesis.

### Bedrock Services Initialization

Blend network is initialized through normal Mantle Transaction execution. The

SDP\_DECLARE

Operations in the Genesis Mantle Transaction will create the initial set of providers in each service.

During normal operations, Blend services would wait until a block is deep enough to be finalized, but for the Genesis block, we consider it finalized by definition and so Blend will immediately use the provider set without the usual finalization delay.

## References

Ouroboros Praos: <https://eprint.iacr.org/2017/573.pdf>

Ouroboros Genesis: <https://eprint.iacr.org/2018/378.pdf>

Ouroboros Crypsinous: <https://eprint.iacr.org/2018/1132.pdf>

Cardano Shelley Genesis File Format: <https://cardano-course.gitbook.io/cardano-course/handbook/protocol-parameters-and-configuration-files/shelley-genesis-file>

Cardano CIP-16 Key Serialisation: <https://cips.cardano.org/cip/CIP-16>
