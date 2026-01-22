# 3RD-PARTY

| Field | Value |
| --- | --- |
| Name | 3rd party |
| Slug | 122 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |
| Contributors | Volodymyr Kozieiev <volodymyr@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/3rd-party.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/3rd-party.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/3rd-party.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/3rd-party.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/3rd-party.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/3rd-party.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This specification discusses 3rd party APIs that Status relies on.  
These APIs provide various capabilities, including:

- communicating with the Ethereum network,  
- allowing users to view address and transaction details on external websites,  
- retrieving fiat/crypto exchange rates,  
- obtaining information about collectibles,  
- hosting the privacy policy.

## Definitions

| Term              | Description                                                                                           |
|-------------------|-------------------------------------------------------------------------------------------------------|
| Fiat money        | Currency established as money, often by government regulation, but without intrinsic value.           |
| Full node         | A computer, connected to the Ethereum network, that enforces all Ethereum consensus rules.            |
| Crypto-collectible| A unique, non-fungible digital asset, distinct from cryptocurrencies where tokens are identical.      |

## Why 3rd Party APIs Can Be a Problem

Relying on 3rd party APIs conflicts with Status’s censorship-resistance principle.
Since Status aims to avoid suppression of information,  
it is important to minimize reliance on 3rd parties that are critical to app functionality.

## 3rd Party APIs Used by the Current Status App

### Infura

**What is it?**  
Infura hosts a collection of Ethereum full nodes and provides an API  
to access the Ethereum and IPFS networks without requiring a full node.

**How Status Uses It**  
Since Status operates on mobile devices,  
it cannot rely on a local node.  
Therefore, all Ethereum network communication happens via Infura.

**Concerns**  
Making an HTTP request can reveal user metadata,  
which could be exploited in attacks if Infura is compromised.  
Infura uses centralized hosting providers;  
if these providers fail or cut off service,  
Ethereum-dependent features in Status would be affected.

### Etherscan

**What is it?**  
Etherscan is a service that allows users to explore the Ethereum blockchain  
for transactions, addresses, tokens, prices,  
and other blockchain activities.

**How Status Uses It**  
The Status Wallet allows users to view address and transaction details on Etherscan.

**Concerns**  
If Etherscan becomes unavailable,  
users won’t be able to view address or transaction details through Etherscan.  
However, in-app information will still be accessible.

### CryptoCompare

**What is it?**  
CryptoCompare provides live crypto prices, charts, and analysis from major exchanges.

**How Status Uses It**  
Status regularly fetches crypto prices from CryptoCompare,  
using this information to calculate fiat values  
for transactions or wallet assets.

**Concerns**  
HTTP requests can reveal metadata,  
which could be exploited if CryptoCompare is compromised.  
If CryptoCompare becomes unavailable,  
Status won’t be able to show fiat equivalents for crypto in the wallet.

### Collectibles

Various services provide information on collectibles:

- [Service 1](https://api.pixura.io/graphql)  
- [Service 2](https://www.etheremon.com/api)  
- [Service 3](https://us-central1-cryptostrikers-prod.cloudfunctions.net/cards/)
- [Service 4](https://api.cryptokitties.co/)  

**Concerns**  
HTTP requests can reveal metadata,  
which could be exploited if these services are compromised.

### Iubenda

**What is it?**  
Iubenda helps create compliance documents for websites and apps across jurisdictions.

**How Status Uses It**  
Status’s privacy policy is hosted on Iubenda.

**Concerns**  
If Iubenda becomes unavailable,  
users will be unable to view the app's privacy policy.

## Changelog

| Version | Comment        |
|---------|-----------------|
| 0.1.0   | Initial release |

## Copyright

Copyright and related rights waived via CC0.

## References

- [GraphQL](https://api.pixura.io/graphql)  
- [Etheremon](https://www.etheremon.com/api)  
- [Cryptostrikers](https://us-central1-cryptostrikers-prod.cloudfunctions.net/cards/)
- [Cryptokitties](https://api.cryptokitties.co/)  
