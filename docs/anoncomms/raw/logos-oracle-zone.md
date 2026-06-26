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
Therefore, economic security with operator staking and slashing, is therefore anchored in LEZ contracts
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
stake custody and slashing enforcement are delegated entirely to LEZ smart contracts via cross zone transactions.

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
not over the raw payload bytes directly;
this follows the hash-then-sign convention specified in BIP-340.

The `PriceObservation` is specified using [protocol buffers v3](https://protobuf.dev/):

```protobuf
syntax = "proto3";

message PriceObservation {
  string feed_id      = 1;  // asset pair identifier; i.e. "BTC/USDT" 
  int64  price        = 2;  // integer-encoded price; real value = price * 10^(-decimals)
  int32  decimals     = 3;  // number of decimal places in `price`
  int64  timestamp    = 4;  // observation time (unix milliseconds), advisory only
  bytes  oracle_id    = 5;  // public key / identifier of the submitting oracle node
  bytes  source_set   = 6;  // OPTIONAL: list of source identifiers used for local median
  bytes  signature    = 7;  // BIP-340 Schnorr signature over SHA-256 of fields 1-6
}
```
