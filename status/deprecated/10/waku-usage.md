---
title: WAKU-USAGE
name: Waku Usage
status: draft
description: Status uses Waku to provide privacy-preserving routing and messaging on top of devP2P.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Adam Babik <adam@status.im>
  - Corey Petty <corey@status.im>
  - Oskar Thorén <oskar@status.im>
  - Samuel Hawksby-Robinson <samuel@status.im>
---

## Abstract

Status uses Waku for privacy-preserving routing and messaging on top of devP2P.
Waku uses topics to partition its messages,  
which are leveraged for all chat capabilities.  
In public chats, the channel name maps directly to its Waku topic,  
allowing anyone to listen on a single channel.

Since anyone can receive Waku envelopes,
it relies on the ability to decrypt messages to identify the correct recipient.
Status nodes do not rely on this property,  
and implement another secure transport layer on top of Whisper.

## Reason

To provide routing, metadata protection, topic-based multicasting,
and basic encryption properties that support asynchronous chat.

## Terminology

- **Waku node**: an Ethereum node with Waku V1 enabled.
- **Waku network**: a group of Waku nodes connected over the internet.
- **Message**: a decrypted Waku message.
- **Offline message**: an archived envelope.
- **Envelope**: an encrypted message with metadata like topic and Time-To-Live.

## Waku Packets

| Packet Name         | Code | References                      |
|---------------------|------|---------------------------------|
| Status              | 0    | Status, WAKU-1                 |
| Messages            | 1    | WAKU-1                         |
| Batch Ack           | 11   | Undocumented. Marked for Deprecation |
| Message Response    | 12   | WAKU-1                         |
| Status Update       | 22   | WAKU-1                         |
| P2P Request Complete| 125  | WAKU-MAILSERVER             |
| P2P Request         | 126  | WAKU-MAILSERVER, WAKU-1     |
| P2P Messages        | 127  | WAKU-MAILSERVER, WAKU-1     |

## Waku Node Configuration

A Waku node must be properly configured to receive messages from Status clients.

Nodes use Waku’s Proof Of Work (PoW) algorithm to deter denial of service  
and spam/flood attacks.  
Since Status’ main client is mobile,
this can lead to battery drain and poor app performance.  
All clients **MUST** use the following settings:

- Proof-of-work requirement not exceeding 0.002 for payloads under 50,000 bytes.
- Proof-of-work requirement not exceeding 0.000002 for payloads of 50,000 bytes
or more.
- Time-to-live no lower than 10 seconds.

### Status Handshake

The handshake is an RLP-encoded packet sent to a newly connected peer.  
It **MUST** start with a Status Code (0x00), followed by items:

```plaintext
[
  [ pow-requirement-key pow-requirement ]
  [ bloom-filter-key bloom-filter ]
  [ light-node-key light-node ]
  [ confirmations-enabled-key confirmations-enabled ]
  [ rate-limits-key rate-limits ]
  [ topic-interest-key topic-interest ]
]
```

| Option Name           | Key   | Type   | Description                                         | References                      |
|-----------------------|-------|--------|-----------------------------------------------------|---------------------------------|
| pow-requirement       | 0x00  | uint64 | minimum PoW accepted by the peer                    | WAKU-1#pow-requirement          |
| bloom-filter          | 0x01  | []byte | bloom filter of Waku topic accepted by the peer     | WAKU-1#bloom-filter             |
| light-node            | 0x02  | bool   | when true, the peer won’t forward envelopes         | WAKU-1#light-node               |
| confirmations-enabled | 0x03  | bool   | when true, peer sends message confirmations         | WAKU-1#confirmations-enabled    |
| rate-limits           | 0x04  |        | Rate limiting details                               | WAKU-1#rate-limits              |
| topic-interest        | 0x05  | array  | Specifies interest in envelopes with certain topics | WAKU-1#topic-interest           |

## Rate Limiting

Each node **SHOULD** define its own rate limits as a basic DoS protection,  
applying these limits on IPs, peer IDs, and envelope topics.

Nodes **MAY** whitelist certain IPs or peer IDs,  
meaning they are not subject to rate limits.  
If a peer exceeds rate limits, the connection **MAY** be dropped.

Nodes **SHOULD** broadcast their rate limits to peers using packet code 0x00  
or 0x22. This information is RLP-encoded as:

```plaintext
[ IP limits, PeerID limits, Topic limits ]
```

## Keys Management

The protocol requires keys (symmetric or asymmetric) for:

- Signing & verifying messages (asymmetric key)
- Encrypting & decrypting messages (symmetric or asymmetric key)

Keys are stored in memory and required at all times for message processing.  
PFS key management is described in SECURE-TRANSPORT.

## Contact Code Topic

Nodes use the contact code topic for discovering X3DH bundles  
so the first message can be PFS-encrypted.  
Each user periodically publishes to this topic.  
If user A wants to contact user B,  
they **SHOULD** search for their bundle on this contact code topic.

## Partitioned Topic

Waku is a broadcast-based protocol,
where a unique topic per conversation would be inefficient and impact privacy.  
Instead, nodes use partitioned topics to balance efficiency and privacy.

Nodes use 5,000 partitioned topics, generated as follows:

```plaintext
partitionTopic := "contact-discovery-" + strconv.FormatInt(partition.Int64(), 10)
```

## Public Chats

Public chats **MUST** use a topic derived from a public chat name  
with the following algorithm:

```plaintext
var hash []byte = keccak256(name)
```

## Group Chat Topic

Group chats do not have a dedicated topic.  
Messages (including membership updates) are sent
as one-to-one messages to multiple recipients.

## Negotiated Topic

For one-to-one messages, the client **MUST** listen to a negotiated topic,  
computed by generating a Diffie-Hellman key exchange  
and taking the first four bytes of the SHA3-256 key generated.

## Message Encryption

The Waku protocol requires message encryption,  
even though an encryption layer is specified above the transport layer.  
Public and group messages use symmetric encryption,  
creating the key from a channel name string.

## Message Confirmations

Messages may fail to be delivered for various reasons.  
Message confirmations notify the sender that the message  
has been received by direct peers.  

The sender **MAY** send confirmations using Batch Acknowledge (0x0b)  
or Message Response (0x0c) packets.

## Waku V1 Extensions

### Request Historic Messages

To request historic messages, a node **MUST** send a P2P Request (0x7e)  
to a trusted Mailserver peer. The request does not await a response.

## Changelog

### Version 0.1

- Released May 22, 2020
- Created document
- Forked from 3-whisper-usage
- Updated terminology to keep Mailserver term consistent

## Copyright

Copyright and related rights waived via CC0.
