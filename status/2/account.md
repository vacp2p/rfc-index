---
slug: 2
title: 2/ACCOUNT
name: Account
status: draft
description: This specification explains what a Status account is, and how a node establishes trust.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Corey Petty <corey@status.im>
  - Oskar Thorén <oskar@status.im>
  - Samuel Hawksby-Robinson <samuel@status.im>
---

## Abstract

This specification explains what a Status account is,  
and how a node establishes trust.

## Table of Contents

- Abstract
- Table of Contents
- Introduction
- Initial Key Generation
- Public/Private Keypairs
- X3DH Prekey bundle creation
- Account Broadcasting
- X3DH Prekey bundles
- Optional Account additions
- ENS Username
- Trust establishment
- Terms Glossary
- Contact Discovery
- Public channels
- Private 1:1 messages
- Initial Key Exchange
- Bundles
- Contact Verification
- Identicon
- 3 word pseudonym / Whisper/Waku key fingerprint
- ENS name
- Public Key Serialization
- Basic Serialization Example
- Public Key “Compression” Rationale
- Key Encoding
- Public Key Types
- De/Serialization Process Flow
- Serialization Example
- Deserialization Example
- Security Considerations
- Changelog
- Version 0.3

## Introduction

The core concept of an account in Status is a set of cryptographic keypairs,  
namely:

- a Whisper/Waku chat identity keypair
- a set of cryptocurrency wallet keypairs

The node verifies or derives everything else associated with the contact  
from the above items, including:

- Ethereum address (future verification, currently the same base keypair)
- 3-word mnemonic name
- identicon
- message signatures

## Initial Key Generation

### Public/Private Keypairs

An ECDSA (secp256k1 curve) public/private keypair **MUST** be generated via  
a BIP43-derived path from a BIP39 mnemonic seed phrase.

The default paths are defined as:

- Whisper/Waku Chat Key (IK): `m/43'/60'/1581'/0'/0` (post Multiaccount  
  integration), following EIP1581
- Status Wallet paths: `m/44'/60'/0'/0/i` starting at `i=0`, following BIP44

### X3DH Prekey bundle creation

Status follows the X3DH prekey bundle scheme outlined by Open Whisper Systems,  
with the following exceptions:

- Status does not publish one-time keys (OPK) or perform DH including them,  
  as there are no central servers.

A client **MUST** create X3DH prekey bundles, defined by:

- **Identity Key (IK)**
- **Signed prekey (SPK)**
- **Prekey signature**: Sig(IK, Encode(SPK))
- **Timestamp**

## Account Broadcasting

A user broadcasts certain information publicly so others may contact them.

### X3DH Prekey bundles

A client **SHOULD** regenerate a new X3DH prekey bundle every 24 hours.  
This **MAY** be done lazily, so that a client offline for longer  
does not regenerate or broadcast bundles.

The current bundle **SHOULD** be broadcast on a Whisper/Waku topic  
specific to its Identity Key, `{IK}-contact-code`, every six hours.

A bundle **SHOULD** accompany every message sent.

## Optional Account Additions

### ENS Username

A user **MAY** register a public username on the Ethereum Name System (ENS).  
This username is a subdomain of `stateofus.eth` that maps to their  
Whisper/Waku identity key (IK).

## Trust Establishment

Trust establishment involves users verifying they are communicating  
with who they think they are.

## Terms Glossary

| Term           | Description                                             |
|----------------|---------------------------------------------------------|
| privkey        | ECDSA secp256k1 private key                             |
| pubkey         | ECDSA secp256k1 public key                              |
| Whisper/Waku key | pubkey for chat with HD derivation path `m/43’/60’/1581’/0’/0` |

## Contact Discovery

### Public Channels

Public group channels in Status are a broadcast/subscription system.  
All public messages are encrypted with a symmetric key derived from  
the channel name, `K_{pub,sym}`, which is publicly known.

A public group channel’s symmetric key **MUST** follow the  
`web3.ssh.generateSymKeyFromPassword` function.

To post to a public group channel, a client **MUST** have a valid account.  
To listen, a client **MUST** subscribe to the channel name.  
The sender is derived from the message’s signature.

Discovery of channel names is out of band.  
If a new channel name is used, it will be created.

A client **MUST** sign the message; otherwise, recipients discard it.

### Private 1:1 Messages

1:1 messaging **MAY** be achieved by:

- scanning a user-generated QR code
- discovering through the Status app
- asynchronous X3DH key exchange
- public key via public channel listening

The message’s sender derives from the message’s signature.

## Initial Key Exchange

### Bundles

An X3DH prekey bundle is defined by:

- **Identity Key (IK)**
- **SignedPreKeys**: map of installation ID to signed prekeys
- **Signature**: prekey signature
- **Timestamp**: last local creation time

A new bundle **SHOULD** be created every 12 hours,  
generated only when in use,  
and **SHOULD** be distributed on the contact code channel.

## Contact Verification

To verify contact key information:

### Identicon

A low-poly identicon is generated deterministically from the Whisper/Waku chat  
public key.  
This can be compared out of band for verification.

### 3-Word Pseudonym / Whisper/Waku Key Fingerprint

Status generates a 3-word pseudonym from the Whisper/Waku chat public key.  
This pseudonym is a human-readable fingerprint  
and appears in contact profiles and chat UI.

### ENS Name

Status allows registering a subdomain of `stateofus.eth` mapped to the  
Whisper/Waku chat public key, for a stake of 10 SNT.

## Public Key Serialization

The node **SHOULD** provide public key serialization
and deserialization for chat keys.

For flexibility, the node **MUST** support public keys encoded in various  
formats.

### Basic Serialization Example

A typical secp256k1 public key, hex-encoded:

0x04261c55675e55ff25edb50b345cfb3a3f35f60712d251cbaaab97bd50054c6ebc3cd4e22200c68daf7493e1f8da6a190a68a671e2d3977809612424c7c3888bc6

For compatibility, the key is modified as:

fe70104261c55675e55ff25edb50b345cfb3a3f35f60712d251cbaaab97bd50054c6ebc3cd4e22200c68daf7493e1f8da6a190a68a671e2d3977809612424c7c3888bc6

### Public Key “Compression” Rationale

Compressed keys have UI/UX advantages.  
They are smaller and less intimidating,  
with a character length reduction of up to 64%.

For example:

- Uncompressed: 136 characters
- Compressed: 49 characters

### Key Encoding

The node **MUST** use `multiformats/multibase` encoding  
to interpret incoming key data and return encoded data.  
Supported formats include `base2`, `base10`, `base16`, `base58btc`, and others.

## Public Key Types

The node **MUST** support `multicodec` key type identifiers:

| Name           | Tag | Code  | Description             |
|----------------|-----|-------|-------------------------|
| secp256k1-pub  | key | 0xe7  | Secp256k1 public key    |

The public key **MUST** be prepended with the relevant `multiformats/uvarint`  
formatted code.

## De/Serialization Process Flow

The node **MUST** be passed a `multicodec` identified public key,  
encoded with a valid `multibase` identifier.

## Security Considerations

Refer to the security section for additional considerations.

## Changelog

### Version 0.4

- Released June 24, 2020
- Added details of public key serialization and deserialization

### Version 0.3

- Released May 22, 2020
- Added Waku inclusion language
- Clarified Open Whisper Systems

## Copyright

Copyright and related rights waived via CC0.
