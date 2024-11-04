---
slug: 3
title: 3/WHISPER-USAGE
name: Whisper Usage
status: draft
description: Status uses Whisper to provide privacy-preserving routing and messaging on top of devP2P.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Adam Babik <adam@status.im>
  - Andrea Piana <andreap@status.im>
  - Corey Petty <corey@status.im>
  - Oskar Thorén <oskar@status.im>
---

- Abstract
- Reason
- Terminology
- Whisper packets
- Whisper node configuration
- Handshake
- Rate limiting
- Keys management
- Contact code topic
- Partitioned topic
- Public chats
- Group chat topic
- Message encryption
- Message confirmations
- Whisper V6 extensions
- Request historic messages
- shhext_requestMessages
- Changelog

## Abstract

Status uses Whisper to provide privacy-preserving routing  
and messaging on top of devP2P.  
Whisper uses topics to partition its messages,  
which supports chat capabilities.  
For public chats, the channel name maps to its Whisper topic,  
allowing anyone to listen on a single channel.

Whisper relies on decryption to identify recipients,  
but Status nodes add another secure transport layer,  
and Whisper extensions allow for offline messaging.

## Reason

Provide routing, metadata protection, topic-based multicasting,  
and basic encryption for asynchronous chat.

## Terminology

- **Whisper node**: An Ethereum node with Whisper V6 enabled.
- **Whisper network**: A group of Whisper nodes connected through the internet.
- **Message**: A decrypted Whisper message.
- **Offline message**: An archived envelope.
- **Envelope**: An encrypted message with metadata like topic and TTL.

## Whisper Packets

| Packet Name         | Code | EIP-627 | References         |
|---------------------|------|---------|--------------------|
| Status              | 0    | ✔       | Handshake         |
| Messages            | 1    | ✔       | EIP-627           |
| PoW Requirement     | 2    | ✔       | EIP-627           |
| Bloom Filter        | 3    | ✔       | EIP-627           |
| Batch Ack           | 11   | 𝘅       | Undocumented      |
| Message Response    | 12   | 𝘅       | Undocumented      |
| P2P Sync Request    | 123  | 𝘅       | Undocumented      |
| P2P Sync Response   | 124  | 𝘅       | Undocumented      |
| P2P Request         | 126  | ✔       | 4/WHISPER-MAILSERVER |
| P2P Messages        | 127  | ✔/𝘅     | 4/WHISPER-MAILSERVER |

## Whisper Node Configuration

A Whisper node must be configured to receive messages from Status clients.  
Whisper’s PoW deters denial-of-service attacks,  
and all clients **MUST** use:

- PoW requirement ≤ 0.00001
- TTL ≥ 10 seconds
- Payloads < 50000 bytes must use PoW target ≥ 0.002 for backward compatibility

## Handshake

Handshake is an RLP-encoded packet sent to a newly connected peer.  
It **MUST** start with Status Code (0x00)  
and follow up with:

```plaintext
[ protocolVersion, PoW, bloom, isLightNode, confirmationsEnabled, rateLimits ]
```

Optional fields like `bloom`, `isLightNode`,  
and other fields **MUST** be sequential if included to avoid ambiguity.

## Rate Limiting

Nodes **SHOULD** define rate limits for IPs, peer IDs,  
and topics to prevent DoS attacks,  
and rate limits **MAY** be advertised with packet code (0x14).

```plaintext
[ IP limits, PeerID limits, Topic limits ]
```

Nodes **SHOULD** respect peer rate limits  
and throttle packets as needed.

## Keys Management

Keys are required for signing/verifying (asymmetric)  
and encrypting/decrypting (asymmetric or symmetric) messages.  
Keys for PFS are described in 5/SECURE-TRANSPORT.

## Contact Code Topic

Nodes use the contact code topic for X3DH bundle discovery,  
and the topic is derived as follows:

```plaintext
contactCode := "0x" + hexEncode(activePublicKey) + "-contact-code"
```

## Partitioned Topic

Partitioned topics balance efficiency and privacy.  
Nodes use 5000 topics, generated as follows:

```plaintext
partitionTopic := "contact-discovery-" + strconv.FormatInt(partition.Int64(), 10)
```

## Public Chats

Public chat topics derive from the chat name as follows:

```plaintext
var hash []byte = keccak256(name)
```

## Group Chat Topic

Group chats do not use a dedicated topic;  
messages are sent one-to-one.

## Negotiated Topic

One-to-one messages use a negotiated topic based on a Diffie-Hellman key  
exchange,  
and the topic is derived as follows:

```go
sharedKey, err := ecies.ImportECDSA(myPrivateKey).GenerateShared(
      ecies.ImportECDSAPublic(theirPublicKey),
      16,
      16,
)
```

## Flow

To message client B,  
client A **SHOULD**:

1. Listen to B’s Contact Code Topic for bundle info.
2. Send a message on B’s partitioned topic.
3. Listen to the Negotiated Topic between A & B.

## Message Encryption

Whisper requires encryption,  
and public/group messages use symmetric encryption  
with a channel-based key,  
while one-to-one messages use asymmetric encryption.

## Message Confirmations

Message confirmations inform a node that its message has been seen by peers,  
and confirmations **MAY** be sent using Batch Ack (0x0b)  
or Message Response (0x0c) packets.

## Whisper V6 Extensions

### Request Historic Messages

Requests historic messages from a Mailserver,  
and the Mailserver **MUST** be a direct, trusted peer.

### shhext_requestMessages

Parameters:

- **Object**: The message request object
- **mailServerPeer**: Mailserver’s enode address.
- **from**: Lower time bound (default 24 hours back).
- **to**: Upper time bound (default now).
- **limit**: Message limit (default no limit).
- **cursor**: Used for pagination.
- **topics**: Hex-encoded message topics.
- **symKeyID**: Symmetric key ID for Mailserver authentication.

## Changelog

### 0.3

- Updated minimum PoW to 0.00001

### 0.2

- Document created

## Copyright

Copyright and related rights waived via CC0.
