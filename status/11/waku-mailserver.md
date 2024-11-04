---
slug: 11
title: 11/WAKU-MAILSERVER
name: Waku Mailserver
status: draft
description: Waku Mailserver is a specification that allows messages to be stored permanently and to allow the stored messages to be delivered to requesting client nodes, regardless if the messages are not available in the network due to the message TTL expiring.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Adam Babik <adam@status.im>
  - Oskar Thorén <oskar@status.im>
  - Samuel Hawksby-Robinson <samuel@status.im>
---

## Abstract

Being mostly offline is an intrinsic property of mobile clients.  
They need to save network transfer and battery consumption to avoid high costs  
or constant charging.  
Waku protocol, however, is an online protocol.  
Messages are available in the Waku network only for a short period,
calculated in seconds.

Waku Mailserver is a specification that allows messages to be stored permanently
and to be delivered to requesting client nodes,
even if the messages are no longer  available in the network due to the TTL expiring.

## Mailserver

From a network perspective, a Mailserver is similar to any other Waku node.  
The only difference is that a Mailserver can archive messages
and deliver them to its peers on-demand.

It’s important to note that a Mailserver only handles requests from its direct peers,
and packets exchanged between a Mailserver and a peer are p2p messages.

### Archiving Messages

A node that wants to provide Mailserver functionality
**MUST** store envelopes from incoming message packets (Waku packet-code 0x01).
The envelopes can be stored in any format,  
but **MUST** be serialized and deserialized to the Waku envelope format.

A Mailserver **SHOULD** store envelopes for all topics to be useful for any peer;
however, for specific cases, it **MAY** store envelopes for only a subset of topics.

### Requesting Messages

To request historic messages, a node **MUST** send a P2P Request packet (0x7e)  
to a peer with Mailserver functionality.  
This packet requires one argument, which **MUST** be a Waku envelope.

In the Waku envelope’s payload section,
there **MUST** be RLP-encoded information about the request details:

```plaintext
[ Lower, Upper, Bloom, Limit, Cursor ]
```

- **Lower**: 4-byte unsigned integer (UNIX time in seconds;
oldest requested envelope’s creation time).
- **Upper**: 4-byte unsigned integer (UNIX time in seconds;
newest requested envelope’s creation time).
- **Bloom**: 64-byte array of Waku topics encoded in a bloom filter to filter envelopes.
- **Limit**: 4-byte unsigned integer limiting the number of returned envelopes.
- **Cursor**: array from the previous request (optional).

The **Cursor** field **SHOULD** be filled if the number of envelopes between **Lower**
and **Upper** exceeds the **Limit**.  
The requester **SHOULD NOT** use a **Cursor** from one Mailserver
in a request to another because the format or result **MAY** differ.

The envelope **MUST** be encrypted with a symmetric key agreed upon by the requester
and the Mailserver.

### Receiving Historic Messages

Historic messages **MUST** be sent to a peer
as a packet with a P2P Message code (0x7f), followed by an array of Waku envelopes.

To receive historic messages from a Mailserver,
a node **MUST** trust the selected Mailserver,
allowing it to send packets with the P2P Message code.  
By default, the node discards such packets.

Received envelopes **MUST** pass through the Waku envelope pipelines  
so that registered filters can pick them up and pass them to subscribers.

To confirm that all messages have been sent by a Mailserver,
the requester **SHOULD** handle the P2P Request Complete code (0x7d),  
followed by the following parameters:

```plaintext
[ RequestID, LastEnvelopeHash, Cursor ]
```

- **RequestID**: 32-byte array with a Keccak-256 hash of the envelope
containing the original request.
- **LastEnvelopeHash**: 32-byte array with a Keccak-256 hash of the last sent envelope
for the request.
- **Cursor**: array from the previous request (optional).

If **Cursor** is not empty, it means not all messages were sent
due to the **Limit** in the request.  
The requester **MAY** send more requests with the **Cursor** field
to receive the rest.

## Security Considerations

### Confidentiality

The node encrypts all Waku envelopes, so a Mailserver node cannot inspect their contents.

### Altruistic and Centralized Operator Risk

For usefulness, a Mailserver **SHOULD** be online most of the time.  
Users either need technical skills to run their own node,  
or rely on others to run it for them.

Currently, one of Status’s legal entities provides Mailservers altruistically,  
but this is suboptimal for decentralization, continuity, and risk.  
Research is ongoing to improve this system.

A Status client **SHOULD** allow customizable Mailserver selection.

### Privacy Concerns

To use a Mailserver, a node must connect to it directly, add it as a peer,  
and mark it as trusted.  
This allows the Mailserver to send direct p2p messages to the node  
instead of broadcasting them.  
The Mailserver can access the bloom filter of the topics the user is interested in,
along with metadata like IP address and online status.

### Denial-of-Service

Since a Mailserver delivers expired envelopes and has a direct TCP connection  
with the recipient, the recipient is vulnerable to DoS attacks from a malicious
Mailserver node.

## Changelog

### Version 0.1

- Released May 22, 2020
- Created document
- Forked from 4-whisper-mailserver
- Updated to keep Mailserver terminology consistent
- Replaced Whisper references with Waku

## Copyright

Copyright and related rights waived via CC0.
