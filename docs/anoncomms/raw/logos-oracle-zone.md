# LON-ORACLE-ZONE

| Field | Value |
| --- | --- |
| Name | Logos Oracle Network (LON) Oracle Zone |
| Slug | 244 |
| Status | raw |
| Category | Standards Track |
| Editor | Ugur Sen [ugur@status.im](mailto:ugur@status.im) |
| Contributors |  |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

## Abstract

The following document specifies the Logos Oracle Network (LON),
a dedicated Logos Blockchain zone that aggregates and attests external price data
and pushes it to consumers in the Logos ecosystem,
in particular the Logos Execution Zone (LEZ).
A set of `oracle nodes` fetch prices from external sources,
sign and submit their attestation as inscriptions;
a custom `indexer` logic deterministically verifies signatures, discards outliers,
and computes an attested price as the median of valid observations once a quorum is reached.
The attested price is delivered to LEZ over a regular PACT (Provable Atomic Cross-zone Transactions)
write on a fixed cadence as PUSH method, so consumers always have a fresh value.

The Oracle Zone deliberately holds no general-purpose execution environment.
Therefore, economic security with oracle node staking and slashing, is therefore anchored in LEZ contracts
and bridged to the Oracle Zone through PACT provided by the Logos stack.
This RFC specifies the price-fetching format, the aggregation and attestation logic,
the round/timing and push-delivery model, the incentivization bridge, and the parameters.

## Motivation

A decentralized price oracle must verify multiple independent signed attestation
per update while sustaining a high update frequency.
Regarding this functionality, two categorical design approaches exist:

LEZ-native design:
- All oracle nodes and logic in LEZ environment.
Research shows that ECDSA signature verification exhausts the LEZ cycle budget
at a relatively small committee size, small for a decentralized oracle.
Aggregate-signature schemes relax this but
still couple price-update load to the general-purpose execution layer.

Separate Oracle Zone:
- This approach removes the verification load from LEZ entirely.
Signature verification and aggregation run inside the dedicated zone's indexer logic;
LEZ only consumes the final attested price.
This raises the achievable signer count and update frequency,
which directly improves both **liveness** (more submitters, faster rounds)
and **price accuracy** (more independent sources feeding a robust median).

The rationale for a separate zone is therefore performance.
Price-data feeding does not create load on the LEZ execution layer,
and the zone can be tuned for fast aggregation and
high signature-verification throughput independently of LEZ.

The trade-off introduced by this separation is that the Oracle Zone
has no execution environment in which to custody stake or run slashing logic.
This RFC resolves that by keeping all economic security in LEZ and
bridging the stake and slash operations over [PACT](https://lip.logos.co/blockchain/deprecated/digital-signature/appendices/the-logos-blockchain-whitepaper.html?highlight=pact#zone-interoperability).

## Format Specification

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT",
"SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL"
in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

### Assumptions

- At least more than half of the observations aggregated into
any single attestation are honest and follow this protocol.
- The indexer cannot manipulate observation ordering;
ordering authority is delegated entirely to Bedrock's immutable inscription order.
- The indexer has no execution logic beyond aggregation;
stake custody and slashing enforcement are delegated entirely
to LEZ smart contracts via cross zone transactions.
- The active oracle set is large enough that quorum `N` is reached every round;
liveness of attestation depends on this oversizing.

## Roles

The roles used in the Oracle Zone are as follows:

- `oracle node`: An off-chain agent run by an oracle operator.
It fetches prices from external sources, computes a local observation,
signs and publishes it as an inscription.
Each `oracle node` is identified by its public key as `oracle id`.
- `indexer`: The interpretation layer of the Oracle zone.
It subscribes to the ordered inscription stream, verifies each observation's signature,
checks writer membership, discards outliers, and, once a quorum of valid observations exists,
computes and writes the attested price to zone state.
The indexer logic is deterministic and MAY be replicated for liveness.
- `sequencer`: The interface through which an `oracle node`
publishes an inscription to the ordering layer.
- `consumer`: Any program or client that uses the attested price.
The primary consumer is LEZ; other zones may be added later.

## Flow

General flow is as follows:

- Each `oracle node` fetches prices from external sources for the feed,
computes a local observation and signs the observation.
- Each `oracle node` publishes the signed observation as an inscription via its `sequencer` interface.
The ordering layer via Bedrock totally orders and finalizes the inscriptions; no interpretation happens at this layer.
- The `indexer` processes each finalized inscription for the current round:
it deserializes the observation, verifies the signature, checks writer membership,
and filters the observation against the running median.
- When the number of valid observations in the current round reaches the predetermined quorum threshold `N`,
the `indexer` computes then outputs the attested price as the median of all valid observations.
- On each push round as heartbeats, the `indexer` repeats the progress.

## Price Fetching

Each `oracle node` fetches the price of the feed from external sources.
The protocol is agnostic to the specific sources and to the local pre-aggregation method;
it is RECOMMENDED that a node query at least three independent sources and
submit a local median to reduce discarding price as outliers.

Each observation is encoded as a `PriceObservation`.
The price is carried as an integer `price` together with a `decimals` field
so that no floating-point representation crosses the protocol boundary:
the real value is `price * 10^(-decimals)`.
The encoding, not the fetching method, is what this specification governs.

The `signature` field carries a [BIP-340](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki)
Schnorr signature over the SHA-256 hash of the canonical serialization of fields 1-6,
not over the raw payload bytes directly; this follows the hash-then-sign convention specified in BIP-340.
The `membership_proof` is a separate witness and is not covered by the signature.

The `PriceObservation` is specified using [protocol buffers v3](https://protobuf.dev/):

```protobuf
syntax = "proto3";

message PriceObservation {
  string feed_id           = 1;  // asset pair identifier; i.e. "BTC/USDT"
  int64  price             = 2;  // integer-encoded price; real value = price * 10^(-decimals)
  int32  decimals          = 3;  // number of decimal places in `price`
  int64  timestamp         = 4;  // observation time (unix milliseconds), advisory only
  bytes  oracle_id         = 5;  // submitting node's 32-byte BIP-340 x-only public key
  bytes  source_set        = 6;  // OPTIONAL: list of source identifiers used for local median
  bytes  signature         = 7;  // BIP-340 Schnorr signature over SHA-256 of fields 1-6
  bytes  membership_proof  = 8;  // Merkle inclusion proof of oracle_id under the LEZ membership root (outside signature scope)
}
```
## Aggregation

The `indexer` is the core logic of the Oracle Zone.
Within each round it performs the following steps deterministically
over the ordered inscription stream:

1. **Deserialize.** Decode each finalized inscription into a `PriceObservation`.
2. **Verify signature.** Verify `signature` against `oracle_id`
as in [BIP-340](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki).
Invalid signature observations MUST be discarded.
3. **Check membership.** Confirm `oracle_id` is a member of the active oracle set
by verifying a Merkle inclusion proof against the membership root held in LEZ.
Observations from non-members MUST be discarded.
4. **Compute median.** When the count of valid observations reaches the quorum threshold `N`,
compute and output the `attested price` as the median of the `N` valid observations.
The median structurally tolerates up to `N/2 - 1` adversarial values without moving outside the honest range.

The attested price is specified as follows:

```protobuf
syntax = "proto3";

message AttestedPrice {
  string feed_id          = 1;  // asset pair identifier; "BTC/USDT" in v1
  int64  price            = 2;  // attested median; real value = price * 10^(-decimals)
  int32  decimals         = 3;  // number of decimal places in `price`
  uint32 valid_count      = 4;  // valid observations aggregated; packed once this reaches N
  int64  attested_at      = 5;  // height/inscription index at which quorum was met
  bytes confidence ;        // OPTIONAL: 1.4826 * median(|xᵢ - median|) over valid observations

}
```

## Rounds and Timing

The Logos Oracle Zone has no separate zone-level blocks,
since it runs no independent consensus.
Ordering and finality come entirely from the Logos Blockchain.
Every reference to block height or block time in this document is to the Logos Blockchain block.

The Oracle Zone operates in rounds of length `R_round`.
Two rules govern the timing:

1. **Deterministic windowing.** Round boundaries MUST be defined by block height, instead of a wall-clock time.
A wall-clock window is non-deterministic across standby indexer replicas.
Defining the window as a fixed block range lets every replica derive the identical attested price.
2. **Push cadence.** Delivery is push: every heartbeat the indexer writes the current attested price into LEZ over PACT.
An on-chain write cannot occur faster than the Logos Blockchain produces blocks, so `R_round >= T_block`.
With the default `T_block = 30 s`, the default heartbeat is one block (approximately `30 s`).

## Oracle Set Membership

Membership of the active oracle set determines which `oracle id`s submit observations that the indexer will accept.
Membership is also the basis of incentivization, to join, an `oracle node` MUST bond stake in a LEZ contract
and register itself in the membership tree held in LEZ.
Registration is a LEZ-only operation and does not require a cross-zone write into the Oracle Zone.

The indexer does not query LEZ state live, which would make aggregation non-deterministic across replicas.
Instead, each observation carries a Merkle inclusion proof against the LEZ membership root,
and the indexer verifies the proof against the membership root it holds.
The indexer is assumed to hold the latest state of the membership tree.
Each `oracle id` is the submitting node's BIP-340 x-only public key,
the membership tree stores these public keys directly.
The indexer verifies `signature` against `oracle_id`
and checks the accompanying `membership_proof` against the membership root.

## Incentivization

The Oracle Zone has no execution environment of its own,
so it custodies no stake and runs no slashing logic.
All economic security lives in `LEZ contract`.
The stake and slash operations are bridged between the Oracle Zone
and LEZ using `PACT` (Provable Atomic Cross-zone Transactions) provided by the Logos stack.

Two distinct PACT usages exist:

- **Regular PACT (price push).** The attested price is written into LEZ
every heartbeat (see [Rounds and Timing](#rounds-and-timing)).
This is high-frequency.
- **Economic-security PACT (slash).** Slashing enforcement is bridged to LEZ.
This is low-frequency, a slash fires only on an established fault,
so the cross-zone cost is incurred only on those events.

### Rewards and Revenue

`oracle nodes` earn from serving the feed, and this reward stream is not just compensation but a security primitive.
An `oracle node`'s admission right (see [Oracle Set Membership](#oracle-set-membership)) is a scarce,
income-producing, transferable seat whose market value approximates the net present value of its future reward stream.
This franchise value raises the cost of acquiring a median-controlling set and
makes misbehavior economically self-defeating, since a fault forfeits that future income.
For this to hold, rewards SHOULD be fee-backed (funded by consumers of the feed) rather than pure emissions,
so that the seat's value reflects real, sustainable income rather than speculation.

Reward accounting is computed in the Oracle Zone, since only the indexer knows which `oracle nodes` submitted valid,
within-bound observations in the epoch.
At each epoch boundary the indexer commits a reward table (e.g. a Merkle root of `oracle node` amounts)
to a LEZ settlement contract in a single PACT message; this keeps reward traffic off the per-round path.
The settlement contract does not run a scheduler. Oracle node claim against the committed root,
so payout is pull-based and per-epoch rather than a per-block push, and the claimant pays their own settlement cost.

Reward eligibility is assessed against a soft deviation band around the round's attested median.
The indexer marks each observation as reward-eligible if it lies
within a small deviation `D_reward` of the attested median, and reward-ineligible otherwise.
An eligible observation earns a full, equal share regardless of its exact distance from the median (validity, not proximity),
so `oracle nodes` are not pushed to herd toward the median,
while an ineligible observation earns nothing for that round but is not slashed.
This soft band is distinct from, and much tighter than, the hard validity bound whose breach is a slashable out-of-bound fault.
The band affects reward accounting only.
The attested median is always the plain median of all signature- and membership-valid observations, unaffected by `D_reward`.

### Slashing

Slashing MUST fire only on strict and provable conditions.
A slash is triggered by submitting fault evidence to the LEZ contract,
which verifies it and applies the penalty.
Two slashable faults are defined:

1. **Equivocation.** An `oracle id` produces two conflicting signed observations for the same feed and round.
The two BIP-340 signatures are a self-contained fraud proof,
cheaply verified in LEZ, and non-malleable signatures make this unambiguous. 
Because the proof is cryptographic and false positives are effectively impossible,
this fault SHOULD carry the highest penalty, up to the full bonded stake.

2. **Out-of-bound value.** A signed observation lies outside the hard validity bound `D_slash` for the round. 
The signed value plus the round context is itself the proof. 
`D_slash` is wider, absolute sanity bound checked during slashing,
and it is much wider than the tight `D_reward` band used for reward eligibility (`D_reward < D_slash`),
so that an honest node stays well inside it and a value outside it indicates malice or gross malfunction.
Because bound-checking can still have edge cases (a stale reference or a genuine market dislocation may make an honest value appear out of bound),
this fault SHOULD carry a capped fraction rather than the full stake, and MAY be paired with a challenge window.

Slashed stake MAY be burnt or split between a bounty to the party that submitted the fault evidence,
which funds a permissionless watchdog economy, and burn or treasury for the remainder.
Liveness and non-participation are NOT slashed; missing submitters are tolerated by a sufficiently large active set,
and are handled through reward eligibility rather than penalties.
Falling outside the `D_reward` band is likewise NOT a slashable fault;
it only forfeits that round's reward.
Subjective "incorrect price" and within-bound majority bias are also deliberately excluded,
since no trust-minimized programmatic predicate for them exists.
These are addressed economically rather than by slashing,
through the franchise value of the reward stream above, the unbonding period below,
and randomized selection, as discussed in [Security Considerations](#security-considerations).

## Parameters

The parameters below are drawn from values used by comparable oracle systems and adjusted for this design.
Block-time and finality parameters are properties of the host chain and are listed for reference.

| Parameter | Symbol | Default | Notes |
| --- | --- | --- | --- |
| Feed |  | `BTC/USDT` | Single feed, more added later. |
| Quorum threshold | `N` | 50 | Valid observations required to attest a price for a round. |
| Honest-majority assumption |  | `N/2 + 1` of the attesting set | Over the observations aggregated per attestation, not the total pool. |
| Heartbeat / round cadence | `R_round` | 1 block (`~30 s`) | Defined in block-height terms; must be `>= T_block`. |
| Aggregation function |  | median | Plain median of all signature- and membership-valid observations. |
| Reward band | `D_reward` | 0.5%* | Tight band around the median for reward eligibility; `D_reward < D_slash`.  |
| Hard validity bound | `D_slash` | 2.5%* | Wide sanity bound; a signed value outside it is a slashable out-of-bound fault.  |
| Signature scheme | | BIP-340 Schnorr | `oracle_id` is the node's 32-byte x-only public key. |
| Active oracle set size | `n` | 500* | Scarce, transferable seats (~10x `N`) so a random per-round subset resists majority capture; whitelist in v1. |
| Stake requirement |  | fixed floor, greater of token amount or USD value* | Hybrid floor to resist token-price drawdown; magnitude set with tokenomics. |
| Slash fraction (equivocation) |  | up to 100%* | Cryptographic proof, effectively zero false positives, so the highest tier is justified. |
| Slash fraction (out-of-bound) |  | 5% cap* | Capped due to edge-case risk; MAY use a challenge window. |
| Unbonding / cooldown period |  | 21 days* | Cosmos/Band anchor; must exceed fault-proving window plus deep-finality horizon. |
| Reward settlement |  | per epoch, pull-based | Claim against a committed Merkle root|
| Epoch length |  | 7 days* | Weekly settlement. |
| Reward backing |  | fee-backed preferred* | Fees over pure emissions for sustainable franchise value. |
| Host chain block time | `T_block` | 30 s | Logos default assumed here; verify against spec. |
| Host chain finality depth | `k` | immutable bound (reference) | Worst-case bound; practical confirmation depth is much shallower. |

## Security Considerations

Two properties matter most for a price oracle network.
One is liveness, meaning a fresh price is attested every round.
The other is accuracy, meaning the attested price tracks the real market.
Running as a separate zone serves both.
It lifts the per-round signature-verification load off LEZ,
so the zone can sustain a much higher signer count `N` than an LEZ-native design.
A high `N` improves liveness, since quorum is reached even when many submitters are absent,
and it improves accuracy, since more independent sources feed the median.
Accuracy is further backed by the median itself and by the slashing conditions in [Incentivization](#incentivization).
The points below expand on the assumptions this relies on.

1. **Quorum and honest majority.** The quorum `N` sets how many submitters must agree before a price is attested.
A high `N` makes it unlikely that the whole set is malicious,
since an attacker would need to control a majority of many independent submitters.
Accuracy comes from source independence and the median,
whose honest-majority assumption of `N/2 + 1` keeps the attested value within the honest range.

2. **Indexer liveness is not submitter liveness.** Replicating the indexer keeps the indexer layer live.
It does not ensure that enough `oracle nodes` submit each round.
`Oracle node` liveness is handled by keeping the active set large and by rewards,
not by replication or by slashing non-participation.

3. **Cross-zone boundary.** Slashing crosses the PACT boundary.
Its security therefore rests on the soundness of the fault evidence carried over PACT
and on the correct verification of that evidence in LEZ, as defined by the PACT specification.

## Future Work

This section records design directions deferred beyond this version.

- **Randomized attesting-set selection.** The current version RFC accepts observations
in inscription order until quorum, which is adequate while the set is small and curated.
As the set grows, an attacker holding many seats could place a majority into a round and bias the median.
Randomly selecting each round's attesting set from the larger registered set removes this,
since an attacker would then have to control a large fraction of the whole set rather than a bare majority.
This future work also requires having shared randomness and specification of how it is used.

- **Cooldown and unbonding period.** The unbonding period must be long enough
that stake stays locked until any fault can be detected, proven, and settled in LEZ,
plus the Logos Blockchain deep-finality margin.
The exact duration is left to tokenomics and should be set well above the deep-finality bound.
The LEZ contracts that hold stake and enforce the cooldown and unbonding are also left to be specified,
since current version of RFC covers only the Oracle Zone side.

- **Volatility handling.** In fast markets, honest prices spread out.
A fixed `D_reward` band can then mark many honest observations ineligible for reward exactly
when fresh prices matter most.
A mechanism to widen the band or grow the attesting set during high volatility is left to future work.

- **Slash proof submission.** The slashing flow is not yet specified formally.
Who submits the fault evidence is one, and this is an open watcher role paid by the bounty.
What the evidence holds is another.
For equivocation it is the two conflicting signed observations.
For an out-of-bound value it is the signed observation plus the round's attested price.
How the LEZ contract checks the evidence is open.
The challenge window for out-of-bound faults is open too.
An oracle node or watcher always starts it by sending evidence to the LEZ contract.

- **Incentivization parameters.** The concrete values for the stake requirement, the two slash fractions,
the reward rate and backing, the epoch length, and the unbonding duration are left to tokenomics.
They should be sized against the value secured so that the economic-security conditions above hold.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

### References

- Logos Improvement Proposals (LIPs) index: [https://lip.logos.co/](https://lip.logos.co/)
- PACT, Provable Atomic Cross-zone Transactions (Logos): [https://lip.logos.co/blockchain/deprecated/digital-signature/appendices/the-logos-blockchain-whitepaper.html?highlight=pact#zone-interoperability](https://lip.logos.co/blockchain/deprecated/digital-signature/appendices/the-logos-blockchain-whitepaper.html?highlight=pact#zone-interoperability)
- Cryptarchia and Bedrock (Logos): [https://lip.logos.co/blockchain/raw/bedrock-architecture-overview.html?highlight=Cryptarchia#cryptarchia](https://lip.logos.co/blockchain/raw/bedrock-architecture-overview.html?highlight=Cryptarchia#cryptarchia)
- [BIP-340: Schnorr Signatures for secp256k1](https://github.com/bitcoin/bips/blob/master/bip-0340.mediawiki)
- [RFC 2119: Key words for use in RFCs](https://www.ietf.org/rfc/rfc2119.txt)
- [protocol buffers v3](https://protobuf.dev/)
- Flare Time Series Oracle (FTSO): [https://docs.flare.network/tech/ftso/](https://docs.flare.network/tech/ftso/)
- Supra DORA (Distributed Oracle Agreement): [https://docs.supra.com/oracles/dora-price-feeds](https://docs.supra.com/oracles/dora-price-feeds)
- LON proof-of-concept 1: [https://github.com/sydhds/lon_poc](https://github.com/sydhds/lon_poc)
- LON proof-of-concept 2: [https://github.com/seugu/lon_oracle_zone_bench](https://github.com/seugu/lon_oracle_zone_bench)
- LON proof-of-concept 3, mocked zone: [https://github.com/seugu/lon_oracle_zone_bench/tree/mocked-zone](https://github.com/seugu/lon_oracle_zone_bench/tree/mocked-zone)
