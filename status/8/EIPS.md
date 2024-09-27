---
slug: 8
title: 8/EIPS
name: EIPS
status: draft
description: Status relation with the EIPs
editor: Ricardo Guilherme Schmidt <ricardo3@status.im>
contributors:
- 
---

## Abstract

This specification describes how Status relates with EIPs.

## Table of Contents

- [Abstract]
- [Table of Contents]
- [Introduction]
- [Components]

## Introduction

Status should follow standards as much as possible.
Whenever the Status app needs a feature,
it should first check if a standard exists.
If not, Status should propose a new standard.

## Support Table

|            | Status v0 | Status v1 | Other | State  |
| ---------- | --------- | --------- | ----- | ------ |
| BIP32      | N         | Y         | N     | stable |
| BIP39      | Y         | Y         | Y     | stable |
| BIP43      | N         | Y         | N     | stable |
| BIP44      | N         | Y         | N     | stable |
| EIP20      | Y         | Y         | Y     | stable |
| EIP55      | Y         | Y         | Y     | stable |
| EIP67      | P         | P         | N     | stable |
| EIP137     | P         | P         | N     | stable |
| EIP155     | Y         | Y         | Y     | stable |
| EIP165     | P         | N         | N     | stable |
| EIP181     | P         | N         | N     | stable |
| EIP191     | Y?        | N         | Y     | stable |
| EIP627     | Y         | Y         | N     | stable |
| EIP681     | Y         | N         | Y     | stable |
| EIP712     | P         | P         | Y     | stable |
| EIP721     | P         | P         | Y     | stable |
| EIP831     | N         | Y         | N     | stable |
| EIP945     | Y         | Y         | N     | stable |
| EIP1102    | Y         | Y         | Y     | stable |
| EIP1193    | Y         | Y         | Y     | stable |
| EIP1577    | Y         | P         | N     | stable |
| EIP1581    | N         | Y         | N     | stable |
| EIP1459    | N         | -         | N     | raw    |

## Components

### BIP32 - Hierarchical Deterministic Wallets

- **Support**: Dependency.
- **Reference**:
[BIP32](https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki)
- **Description**: Enable wallets to derive multiple private keys from the same
seed.
- **Used for**: Dependency of BIP39 and BIP43.

### BIP39 - Mnemonic Code for Generating Deterministic Keys

- **Support**: Dependency.
- **Reference**:
[BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- **Description**: Enable wallet to create private key based on a safe seed
phrase.
- **Used for**: Security and user experience.

### BIP43 - Purpose Field for Deterministic Wallets

- **Support**: Dependency.
- **Reference**:
[BIP43](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
- **Description**: Enable wallet to create private keys branched for a specific
purpose.
- **Used for**: Dependency of BIP44, uses “ethereum” coin.

### BIP44 - Multi-Account Hierarchy for Deterministic Wallets

- **Support**: Dependency.
- **Reference**:
[BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
- **Description**: Enable wallet to derive multiple accounts on top of BIP39.
- **Used for**: Privacy.
- **Source code**:
[BIP44](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L240)
  
_Observation_: BIP44 doesn’t solve privacy issues regarding transaction
transparency. Connected addresses through transactions can be identified via
“network reconnaissance attacks” on transaction history, which may expose user
privacy despite BIP44.

### EIP20 - Fungible Token

- **Support**: Full.
- **Reference**: [EIP20](https://eips.ethereum.org/EIPS/eip-20)
- **Description**: Enable wallets to use tokens based on smart contracts
compliant with this standard.
- **Used for**: Wallet feature.
- **Source code**:
[EIP20](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)

### EIP55 - Mixed-case Checksum Address Encoding

- **Support**: Full.
- **Reference**: [EIP55](https://eips.ethereum.org/EIPS/eip-55)
- **Description**: Checksum standard that uses lowercase and uppercase inside
address hex value.
- **Used for**: Sanity check of forms using Ethereum addresses.
- **Source code**:
[EIP55](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip55.cljs)

### EIP67 - Standard URI Scheme with Metadata, Value, and Byte Code

- **Support**: Partial.
- **Reference**: [EIP67](https://github.com/ethereum/EIPs/issues/67)
- **Description**: A standard way of creating Ethereum URIs for various use-
cases.
- **Used for**: Legacy support.

### EIP137 - Ethereum Domain Name Service

- **Support**: Partial.
- **Reference**: [EIP137](https://eips.ethereum.org/EIPS/eip-137)
- **Description**: Enable wallets to lookup ENS names.
- **Used for**: User experience, as a wallet and identity feature.
- **Source code**:
[EIP137](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)

### EIP155 - Simple Replay Attack Protection

- **Support**: Full.
- **Reference**: [EIP155](https://eips.ethereum.org/EIPS/eip-155)
- **Description**: Defined chainId parameter in the signed Ethereum transaction
payload.
- **Used for**: Signing transactions, crucial for user safety against replay
attacks.
- **Source code**:
[EIP155](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/core.cljs)

### EIP165 - Standard Interface Detection

- **Support**: Dependency/Partial.
- **Reference**: [EIP165](https://eips.ethereum.org/EIPS/eip-165)
- **Description**: Standard interface for contracts to answer if they support
other interfaces.
- **Used for**: Dependency of ENS and EIP721.
- **Source code**:
[EIP165](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip165.cljs)

### EIP181 - ENS Support for Reverse Resolution of Ethereum Addresses

- **Support**: Partial.
- **Reference**: [EIP181](https://eips.ethereum.org/EIPS/eip-181)
- **Description**: Enable wallets to render reverse resolution of Ethereum
addresses.
- **Used for**: Wallet feature.
- **Source code**:
[EIP181](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/ens.cljs#L86)

### EIP191 - Signed Message

- **Support**: Full.
- **Reference**: [EIP191](https://eips.ethereum.org/EIPS/eip-191)
- **Description**: Contract signature standard, adds padding to signed messages
to differentiate from Ethereum transaction messages.
- **Used for**: DApp support, security, dependency of EIP712.

### EIP627 - Whisper Specification

- **Support**: Full.
- **Reference**: [EIP627](https://eips.ethereum.org/EIPS/eip-627)
- **Description**: Format of Whisper messages within the ÐΞVp2p Wire Protocol.
- **Used for**: Chat protocol.

### EIP681 - URL Format for Transaction Requests

- **Support**: Partial.
- **Reference**: [EIP681](https://eips.ethereum.org/EIPS/eip-681)
- **Description**: A link that pops up a transaction in the wallet.
- **Used for**: QR code data for transaction requests, chat transaction requests,
and DApp links to transaction requests.
- **Source code**:
[EIP681](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/eip681.cljs)

### EIP712 - Typed Signed Message

- **Support**: Partial.
- **Reference**: [EIP712](https://eips.ethereum.org/EIPS/eip-712)
- **Description**: Standardize types for contract signatures, allowing users to
inspect what’s being signed.
- **Used for**: User experience, security.

### EIP721 - Non-Fungible Token

- **Support**: Partial.
- **Reference**: [EIP721](https://eips.ethereum.org/EIPS/eip-721)
- **Description**: Enable wallets to use tokens based on smart contracts
compliant with this standard.
- **Used for**: Wallet feature.

### EIP945 - Web3 QR Code Scanning API

- **Support**: Full.
- **Reference**: [EIP945](https://github.com/ethereum/EIPs/issues/945)
- **Used for**: Sharing contact code, reading transaction requests.
- **Related**:
[Issue](https://github.com/status-im/status-mobile/issues/5870)

### EIP1102 - Opt-in Account Exposure

- **Support**: Full.
- **Reference**: [EIP1102](https://eips.ethereum.org/EIPS/eip-1102)
- **Description**: Allow users to opt-in to expose their Ethereum address to dapps.
- **Used for**: Privacy, DApp support.
- **Related**:
[Issue](https://github.com/status-im/status-mobile/issues/7985)

### EIP1193 - Ethereum Provider JavaScript API

- **Support**: Full.
- **Reference**: [EIP1193](https://eips.ethereum.org/EIPS/eip-1193)
- **Description**: Allows dapps to recognize event changes on wallet.
- **Used for**: DApp support.
- **Related**:
[PR](https://github.com/status-im/status-mobile/pull/7246)

### EIP1577 - Contenthash Field for ENS

- **Support**: Partial.
- **Reference**: [EIP1577](https://eips.ethereum.org/EIPS/eip-1577)
- **Description**: Allows users to browse ENS domains using the contenthash standard.
- **Used for**: Browser, DApp support.
- **Related**:
[Issue](https://github.com/status-im/status-mobile/issues/6688)
- **Source code**:
[Contenthash](https://github.com/status-im/status-mobile/blob/develop/src/status_im/utils/contenthash.cljs)

### EIP1581 - Non-wallet Usage of Keys Derived from BIP-32 Trees

- **Support**: Partial.
- **Reference**: [EIP1581](https://eips.ethereum.org/EIPS/eip-1581)
- **Description**: Allow wallets to derive less sensitive keys (non-wallet).
- **Used for**: Security (don’t reuse wallet key), user experience (no keycard).
- **Related**:
[Issue](https://github.com/status-im/status-mobile/issues/9088)
- **Source code**:
[Constants](https://github.com/status-im/status-mobile/blob/develop/src/status_im/constants.cljs#L242)

### EIP1459 - Node Discovery via DNS

- **Support**: N/A.
- **Reference**: [EIP1459](https://eips.ethereum.org/EIPS/eip-1459)
- **Description**: Storing and retrieving nodes via merkle trees in TXT domain records.
- **Used for**: Finding Waku nodes.

---

## Copyright

Copyright and related rights waived via CC0.
