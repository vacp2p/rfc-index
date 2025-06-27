---
title: 3RD-PARTY
name: 3rd party
status: deprecated
description: This specification discusses 3rd party APIs that Status relies on.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Volodymyr Kozieiev <volodymyr@status.im>
---

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
