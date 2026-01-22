# EIPS

| Field | Value |
| --- | --- |
| Name | EIPS |
| Slug | 128 |
| Status | deprecated |
| Editor | Ricardo Guilherme Schmidt <ricardo3@status.im> |
| Contributors | None |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/eips.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/eips.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/eips.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/eips.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/eips.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/eips.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This specification describes how Status relates with EIPs.

## Introduction

Status should follow all standards as possible.
Whenever the Status app needs a feature, it should be first checked if there is a standard for that,
if not, Status should propose a standard.

### Support table

|          | Status v0 | Status v1 | Other    | State    |
|----------|-----------|-----------|----------| -------- |
| BIP32    | N         | Y         | N        | `stable` |
| BIP39    | Y         | Y         | Y        | `stable` |
| BIP43    | N         | Y         | N        | `stable` |
| BIP44    | N         | Y         | N        | `stable` |
| EIP20    | Y         | Y         | Y        | `stable` |
| EIP55    | Y         | Y         | Y        | `stable` |
| EIP67    | P         | P         | N        | `stable` |
| EIP137   | P         | P         | N        | `stable` |
| EIP155   | Y         | Y         | Y        | `stable` |
| EIP165   | P         | N         | N        | `stable` |
| EIP181   | P         | N         | N        | `stable` |
| EIP191   | Y?        | N         | Y        | `stable` |
| EIP627   | Y         | Y         | N        | `stable` |
| EIP681   | Y         | N         | Y        | `stable` |
| EIP712   | P         | P         | Y        | `stable` |
| EIP721   | P         | P         | Y        | `stable` |
| EIP831   | N         | Y         | N        | `stable` |
| EIP945   | Y         | Y         | N        | `stable` |
| EIP1102  | Y         | Y         | Y        | `stable` |
| EIP1193  | Y         | Y         | Y        | `stable` |
| EIP1577  | Y         | P         | N        | `stable` |
| EIP1581  | N         | Y         | N        | `stable` |
| EIP1459  | N         |           | N        | `raw`    |

## Components

### BIP32 - Hierarchical Deterministic Wallets

Support: Dependency.  
[Reference](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
Description: Enable wallets to derive multiple private keys from the same seed.  
Used for: Dependency of BIP39 and BIP43.  

### BIP39 - Mnemonic code for generating deterministic keys

Support: Dependency.  
[Reference](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
Description: Enable wallet to create private key based on a safe seed phrase.
Used for: Security and user experience.

### BIP43 - Purpose Field for Deterministic Wallets

Support: Dependency.  
[Reference](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
Description: Enable wallet to create private keys branched for a specific purpose.
Used for: Dependency of BIP44, uses "ethereum" coin.

### BIP44 - Multi-Account Hierarchy for Deterministic Wallets

Support: Dependency.
[Reference](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
Description: Enable wallet to derive multiple accounts in top of BIP39.  
Used for: Privacy.  
[Source code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L240)
Observation: BIP44 don't solve privacy issues regarding the transparency of transactions, therefore directly connected addresses through a transactions can be identifiable by a "network reconnaissance attack" over transaction history, this attack together with leakage of information from centralized services, such as exchanges, would be fatal against the whole privacy of users, regardless of BIP44.  

### EIP20 - Fungible Token

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-20)
Description: Enable wallets to use tokens based on smart contracts compliant with this standard.  
Used for: Wallet feature.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)  

### EIP55 - Mixed-case checksum address encoding

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-55)
Description: Checksum standard that uses lowercase and uppercase inside address hex value.  
Used for: Sanity check of forms using ethereum address.  
[Related](https://github.com/status-im/status-mobile/issues/4959) [Also](https://github.com/status-im/status-mobile/issues/8707)
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip55.cljs)

### EIP67 - Standard URI scheme with metadata, value and byte code

Support: Partial.  
[Reference](https://github.com/ethereum/EIPs/issues/67)
Description: A standard way of creating Ethereum URIs for various use-cases.  
Used for: Legacy support.  
[Issue](https://github.com/status-im/status-mobile/issues/875)  

### EIP137 - Ethereum Domain Name Service - Specification

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-137)
Description: Enable wallets to lookup ENS names.  
Used for: User experience, as a wallet and identity feature, usernames.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)

### EIP155 - Simple replay attack protection

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-155)
Description: Defined chainId parameter in the singed ethereum transaction payload.  
Used for: Signing transactions, crucial to safety of users against replay attacks.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/core.cljs)

### EIP165 - Standard Interface Detection

Support: Dependency/Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-165)
Description: Standard interface for contract to answer if it supports other interfaces.  
Used for: Dependency of ENS and EIP721.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip165.cljs)

### EIP181 - ENS support for reverse resolution of Ethereum addresses

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-181)
Description: Enable wallets to render reverse resolution of Ethereum addresses.  
Used for: Wallet feature.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)

### EIP191 - Signed Message

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-191)
Description: Contract signature standard, adds an obligatory padding to signed message to differentiate from Ethereum Transaction messages.  
Used for: Dapp support, security, dependency of ERC712.  

### EIP627 - Whisper Specification

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-627)
Description: format of Whisper messages within the ÐΞVp2p Wire Protocol.  
Used for: Chat protocol.  

### EIP681 - URL Format for Transaction Requests

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-681)
Description: A link that pop up a transaction in the wallet.  
Used for: Useful as QR code data for transaction requests, chat transaction requests and for dapp links to transaction requests.  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip681.cljs)
Related: [Issue #9183: URL Format for Transaction Requests (EIP681) is poorly supported](https://github.com/status-im/status-mobile/issues/9183) [Issue #9240](https://github.com/status-im/status-mobile/pull/9240) [Issue #9238](https://github.com/status-im/status-mobile/issues/9238) [Issue #7214](https://github.com/status-im/status-mobile/issues/7214) [Issue #7325](https://github.com/status-im/status-mobile/issues/7325) [Issue #8150](https://github.com/status-im/status-mobile/issues/8150)

### EIP712 - Typed Signed Message

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-712)
Description: Standardize types for contract signature, allowing users to easily inspect whats being signed.  
Used for: User experience, security.  
Related: [Isse #5461](https://github.com/status-im/status-mobile/issues/5461) [Commit](https://github.com/status-im/status-mobile/commit/ba37f7b8d029d3358c7b284f6a2383b9ef9526c9)

### EIP721 - Non Fungible Token

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-721)
Description: Enable wallets to use tokens based on smart contracts compliant with this standard.  
Used for: Wallet feature.  
Related: [Issue #8909](https://github.com/status-im/status-mobile/issues/8909)
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/erc721.cljs) [Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)  

### EIP945 - Web 3 QR Code Scanning API

Support: Full.  
[Reference](https://github.com/ethereum/EIPs/issues/945)
Used for: Sharing contactcode, reading transaction requests.  
Related: [Issue #5870](https://github.com/status-im/status-mobile/issues/5870)

### EIP1102 - Opt-in account exposure

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-1102)
Description: Allow users to opt-in the exposure of their ethereum address to dapps they browse.  
Used for: Privacy, DApp support.  
Related: [Issue #7985](https://github.com/status-im/status-mobile/issues/7985)

### EIP1193 - Ethereum Provider JavaScript API

Support: Full.  
[Reference](https://eips.ethereum.org/EIPS/eip-1193)
Description: Allows dapps to recognize event changes on wallet.  
Used for: DApp support.  
Related: [Issue #7246](https://github.com/status-im/status-mobile/pull/7246)

### EIP1577 - contenthash field for ENS

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-1577)  
Description: Allows users browse ENS domains using contenthash standard.  
Used for: Browser, DApp support.  
Related: [Isse #6688](https://github.com/status-im/status-mobile/issues/6688)
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/utils/contenthash.cljs) [Sourcecode](https://github.com/status-im/status-mobile/blob/develop/test/cljs/status_im/test/utils/contenthash.cljs#L5)  

### EIP1581 - Non-wallet usage of keys derived from BIP-32 trees

Support: Partial.  
[Reference](https://eips.ethereum.org/EIPS/eip-1581)
Description: Allow wallet to derive keys that are less sensible (non wallet).  
Used for: Security (don't reuse wallet key) and user experience (don't request keycard every login).  
Related: [Issue #9096](https://github.com/status-im/status-mobile/issues/9088) [Issue #9096](https://github.com/status-im/status-mobile/pull/9096)  
[Sourcecode](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L242)

### EIP1459 - Node Discovery via DNS

Support: -
[Reference](https://eips.ethereum.org/EIPS/eip-1459)
Description: Allows the storing and retrieving of nodes through merkle trees stored in TXT records of a domain.
Used for: Finding Waku nodes.
Related: -
Sourcecode: -

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [BIP32 - Hierarchical Deterministic Wallets](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
- [BIP39 - Mnemonic code for generating deterministic keys](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- [BIP43 - Purpose Field for Deterministic Wallets](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
- [BIP44 - Multi-Account Hierarchy for Deterministic Wallets](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
- [BIP44 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L240)
- [EIP20 - Fungible Token](https://eips.ethereum.org/EIPS/eip-20)
- [EIP20 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)
- [EIP55 - Mixed-case checksum address encoding](https://eips.ethereum.org/EIPS/eip-55)
- [EIP55 Related Issue 4959](https://github.com/status-im/status-mobile/issues/4959)
- [EIP55 Related Issue 8707](https://github.com/status-im/status-mobile/issues/8707)
- [EIP55 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip55.cljs)
- [EIP67 - Standard URI scheme with metadata, value and byte code](https://github.com/ethereum/EIPs/issues/67)
- [EIP67 Related Issue 875](https://github.com/status-im/status-mobile/issues/875)
- [EIP137 - Ethereum Domain Name Service - Specification](https://eips.ethereum.org/EIPS/eip-137)
- [EIP137 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)
- [EIP155 - Simple replay attack protection](https://eips.ethereum.org/EIPS/eip-155)
- [EIP155 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/core.cljs)
- [EIP165 - Standard Interface Detection](https://eips.ethereum.org/EIPS/eip-165)
- [EIP165 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip165.cljs)
- [EIP181 - ENS support for reverse resolution of Ethereum addresses](https://eips.ethereum.org/EIPS/eip-181)
- [EIP181 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)
- [EIP191 - Signed Message](https://eips.ethereum.org/EIPS/eip-191)
- [EIP627 - Whisper Specification](https://eips.ethereum.org/EIPS/eip-627)
- [EIP681 - URL Format for Transaction Requests](https://eips.ethereum.org/EIPS/eip-681)
- [EIP681 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip681.cljs)
- [EIP681 Related Issue 9183](https://github.com/status-im/status-mobile/issues/9183)
- [EIP681 Related Issue 9240](https://github.com/status-im/status-mobile/pull/9240)
- [EIP681 Related Issue 9238](https://github.com/status-im/status-mobile/issues/9238)
- [EIP681 Related Issue 7214](https://github.com/status-im/status-mobile/issues/7214)
- [EIP681 Related Issue 7325](https://github.com/status-im/status-mobile/issues/7325)
- [EIP681 Related Issue 8150](https://github.com/status-im/status-mobile/issues/8150)
- [EIP712 - Typed Signed Message](https://eips.ethereum.org/EIPS/eip-712)
- [EIP712 Related Issue 5461](https://github.com/status-im/status-mobile/issues/5461)
- [EIP712 Related Commit](https://github.com/status-im/status-mobile/commit/ba37f7b8d029d3358c7b284f6a2383b9ef9526c9)
- [EIP721 - Non Fungible Token](https://eips.ethereum.org/EIPS/eip-721)
- [EIP721 Related Issue 8909](https://github.com/status-im/status-mobile/issues/8909)
- [EIP721 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/erc721.cljs)
- [EIP721 Source Code (Tokens)](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)
- [EIP945 - Web 3 QR Code Scanning API](https://github.com/ethereum/EIPs/issues/945)
- [EIP945 Related Issue 5870](https://github.com/status-im/status-mobile/issues/5870)
- [EIP1102 - Opt-in account exposure](https://eips.ethereum.org/EIPS/eip-1102)
- [EIP1102 Related Issue 7985](https://github.com/status-im/status-mobile/issues/7985)
- [EIP1193 - Ethereum Provider JavaScript API](https://eips.ethereum.org/EIPS/eip-1193)
- [EIP1193 Related Issue 7246](https://github.com/status-im/status-mobile/pull/7246)
- [EIP1577 - contenthash field for ENS](https://eips.ethereum.org/EIPS/eip-1577)
- [EIP1577 Related Issue 6688](https://github.com/status-im/status-mobile/issues/6688)
- [EIP1577 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/utils/contenthash.cljs)
- [EIP1577 Test Source Code](https://github.com/status-im/status-mobile/blob/develop/test/cljs/status_im/test/utils/contenthash.cljs#L5)
- [EIP1581 - Non-wallet usage of keys derived from BIP-32 trees](https://eips.ethereum.org/EIPS/eip-1581)
- [EIP1581 Related Issue 9088](https://github.com/status-im/status-mobile/issues/9088)
- [EIP1581 Related Issue 9096](https://github.com/status-im/status-mobile/pull/9096)
- [EIP1581 Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L242)
- [EIP1459 - Node Discovery via DNS](https://eips.ethereum.org/EIPS/eip-1459)
