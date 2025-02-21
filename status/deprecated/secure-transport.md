---
title: SECURE-TRANSPORT
name: Secure Transport
status: deprecated
description: This document describes how Status provides a secure channel between two peers, providing confidentiality, integrity, authenticity, and forward secrecy.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Andrea Maria Piana <andreap@status.im>
  - Corey Petty <corey@status.im>
  - Dean Eigenmann <dean@status.im>
  - Oskar Thorén <oskar@status.im>
  - Pedro Pombeiro <pedro@status.im>
---

## Abstract

This document describes how Status provides a secure channel between two peers,
providing confidentiality, integrity, authenticity, and forward secrecy.  
It is transport-agnostic and works over asynchronous networks.

It builds on the X3DH and Double Ratchet specifications,  
with adaptations to operate in a decentralized environment.

## Introduction

This document describes how nodes establish a secure channel  
and how various conversational security properties are achieved.

## Definitions

Perfect Forward Secrecy provides assurances that session keys remain secure  
even if private keys are later compromised.  
Secret channel describes a communication channel  
where the Double Ratchet algorithm is in use.

## Design Requirements

- **Confidentiality**: The adversary should not be able to learn what data  
  is being exchanged between two Status clients.
- **Authenticity**: The adversary should not cause either endpoint  
  of a Status 1:1 chat to accept data from any third party  
  as though it came from the other endpoint.
- **Forward Secrecy**: The adversary should not learn what data was exchanged  
  between two Status clients, even if later the adversary compromises  
  one or both of the endpoint devices.
- **Integrity**: The adversary should not cause either endpoint  
  of a Status 1:1 chat to accept tampered data.

These properties are ensured by [Signal’s Double Ratchet](https://signal.org/docs/specifications/doubleratchet/).

## Conventions

Types used in this specification are defined using Protobuf.

## Transport Layer

Whisper and Waku serve as the transport layers for the Status chat protocol.

## User Flow for 1-to-1 Communications

### Account Generation

See [Account specification](https://rfc.vac.dev/status/deprecated/account.md).

### Account Recovery

If Alice recovers her account, Double Ratchet state information  
is unavailable, so she can no longer decrypt messages  
received from existing contacts.

If a Whisper/Waku topic message fails to decrypt,  
the node replies with the current bundle, notifying the other end of the device.
Subsequent communications will use this new bundle.

### Messaging

All 1:1 and group chat messaging in Status uses end-to-end encryption  
for privacy and security. Public chat messages are publicly readable,  
as there’s no permission model for public chat participants.

This document covers only 1:1 and private group chat.  
Private group chat reduces to 1:1 chat,  
since each pair-wise participant has a secure channel.

### End-to-End Encryption

End-to-end encryption (E2EE) occurs between two clients.  
The main cryptographic protocol is a Status implementation  
of the Double Ratchet protocol, derived from Off-the-Record protocol.  
The transport protocol encrypts the message payload  
using Whisper/Waku (see Transport Layer),  
and symmetric key encryption.

Status uses prekeys (via X3DH) to operate in an asynchronous environment,  
so two parties need not be online simultaneously  
to initiate an encrypted conversation.

### Prekeys

Each client generates key material stored locally:

- **Identity keypair** based on secp256k1 - IK
- **Signed prekey** based on secp256k1 - SPK
- **Prekey signature** - Sig(IK, Encode(SPK))

More details are in the X3DH Prekey bundle creation section of ACCOUNT.

Prekey bundles can be extracted from any user’s messages  
or found by searching their topic, `{IK}-contact-code`.

### Bundle Retrieval

X3DH enables client apps to create and share a bundle of prekeys  
(X3DH bundle) requested by other interlocutors to start a conversation.  
Status chat clients must achieve this without a centralized server.

Considered approaches, from most to least convenient:

- **Contact codes**
- **Public and one-to-one chats**
- **QR codes**
- **ENS record**
- **Decentralized storage** (e.g., Swarm, IPFS)

Currently, only public and one-to-one messages and Whisper/Waku  
are used to exchange bundles.  
QR codes or ENS records do not update to delete used keys,  
so the bundle rotates every 24 hours, propagated by the app.

### 1:1 Chat Contact Request

The initial negotiation for a 1:1 chat involves two phases:

1. **Identity verification** (e.g., QR code, Identicon matching).  
   A QR code serves both identity verification and bundle retrieval.
2. **Asynchronous initial key exchange**, using X3DH.

See ACCOUNT for account generation and trust establishment.

### Initial Key Exchange Flow (X3DH)

Section 3 of X3DH protocol covers initial key exchange flow,  
with some additional context:

- Users’ identity keys IK_A and IK_B are their respective Status chat keys.
- One-time prekey OPK_B is not used in a decentralized environment.
- Nodes serve Bundles in a decentralized way, as described in bundle retrieval.

Alice retrieves Bob’s prekey bundle, which contains:

protobuf

```protobuf
message Bundle {
  bytes identity = 1;
  map<string,SignedPreKey> signed_pre_keys = 2;
  bytes signature = 4;
  int64 timestamp = 5;
}
```

Fields:

- **identity**: Identity key IK_B
- **signed_pre_keys**: Signed prekey SPK_B for each device, indexed by `installation-id`
- **signature**: Prekey signature `Sig(IK_B, Encode(SPK_B))`
- **timestamp**: When the bundle was created locally

## Double Ratchet

After establishing the initial shared secret SK through X3DH,  
it seeds a Double Ratchet exchange between Alice and Bob.  
Refer to the Double Ratchet spec for more details.

## Security Considerations

These considerations apply as per section 4 of the X3DH spec  
and section 6 of the Double Ratchet spec, with some additions.

### Session Management

A node identifies a peer by:

1. An `installation-id` generated upon creating a new account in Status
2. Their identity Whisper/Waku key

#### Initialization

A node initializes a session after a successful X3DH exchange.  
Subsequent messages use the established session until re-keying is needed.

#### Concurrent Sessions

If two concurrent sessions are created, the one with the symmetric key  
first in byte order **SHOULD** be used, marking the other expired.

#### Re-keying

On receiving a higher version bundle from a peer,  
the old bundle **SHOULD** be marked as expired,  
and a new session **SHOULD** be established on the next sent message.

### Multi-Device Support

Multi-device support is challenging without a central place for device info.  
Nodes propagate multi-device info using x3dh bundles,  
including information about paired devices and the sending device.

### Pairing

When adding a new account in Status, a new `installation-id` is generated.  
Devices should be paired as soon as possible.  
Once paired, contacts are notified of the new device,  
and it is included in further communications.

### Sending Messages to a Paired Group

When sending a message, the peer sends it to other `installation-id`s seen.  
Messages are sent using pairwise encryption, including the sender’s devices.

Account Recovery

Account recovery is similar to adding a new device and handled in the same way.

### Partitioned Devices

If a device receives a message not targeted to its `installation-id`,  
it sends an empty message with bundle information to include it in future communication.

## Changelog

### Version 0.3

- Released May 22, 2020
- Added language to include Waku in all relevant places

## Copyright

Copyright and related rights waived via CC0.
