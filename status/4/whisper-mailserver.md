---
slug: 4
title: 4/WHISPER-MAILSERVER
name: Whisper mailserver
status: draft
description: Whisper Mailserver is a Whisper extension that allows to store messages permanently and deliver them to the clients even though they are already not available in the network and expired.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Adam Babik <adam@status.im>
  - Oskar Thorén <oskar@status.im>
---

## Abstract

Being mostly offline is an intrinsic property of mobile clients.  
They need to save network transfer and battery consumption  
to avoid spending too much money or constant charging.  
Whisper protocol, on the other hand, is an online protocol.  
Messages are available in the Whisper network only for a short period of time,  
calculated in seconds.

Whisper Mailserver is a Whisper extension
that allows storing messages permanently
and delivering them to clients
even after they are no longer available in the network and have expired.

## Mailserver

From the network perspective, a Mailserver is just like any other Whisper node,
with the difference being that it has the capability of archiving messages  
and delivering them to its peers on-demand.

It is important to note that a Mailserver only handles requests
from its direct peers,
and exchanged packets between Mailserver and a peer are p2p messages.

## Archiving Messages

A node providing Mailserver functionality **MUST** store envelopes  
from incoming message packets (Whisper packet-code 0x01).  
The envelopes can be stored in any format,  
but they **MUST** be serialized and deserialized to the Whisper envelope format.

A Mailserver **SHOULD** store envelopes for all topics to be useful for any peer,
but for specific use cases, it **MAY** store envelopes for a subset of topics.

## Requesting Messages

To request historic messages, a node **MUST** send a packet P2P Request (0x7e)  
to a peer providing Mailserver functionality.  
This packet requires one argument, which **MUST** be a Whisper envelope.

In the Whisper envelope’s payload section,  
there **MUST** be RLP-encoded information about the request details:

- **Lower**: 4-byte unsigned integer (UNIX time in seconds;  
  oldest requested envelope’s creation time)
- **Upper**: 4-byte unsigned integer (UNIX time in seconds;  
  newest requested envelope’s creation time)
- **Bloom**: 64-byte array of Whisper topics encoded in a bloom filter  
  to filter envelopes
- **Limit**: 4-byte unsigned integer limiting the number of returned envelopes
- **Cursor**: an array of a cursor returned from the previous request (optional)

The Cursor field **SHOULD** be filled
if the number of envelopes between Lower and Upper exceeds Limit,  
so the requester can send another request with the obtained Cursor value.  
The content of the Cursor depends on the implementation.  
The requester **SHOULD NOT** use a Cursor from one Mailserver  
in a request to another, as the format or result **MAY** differ.

The envelope **MUST** be encrypted
with a symmetric key agreed between the requester and Mailserver.

## Receiving Historic Messages

Historic messages **MUST** be sent to a peer as a packet with a P2P Message code
(0x7f), followed by an array of Whisper envelopes.  
This is incompatible with the original Whisper spec (EIP-627),  
which allows only a single envelope,  
but an array of envelopes is much more performant.  
To stay compatible with EIP-627,
a peer receiving historic messages **MUST** handle both cases.

To receive historic messages from a Mailserver,  
a node **MUST** trust the selected Mailserver,  
which is allowed to send packets with the P2P Message code.  
By default, the node discards such packets.

Received envelopes **MUST** pass through the Whisper envelope pipelines  
so that registered filters can pick them up and pass them to subscribers.

To know that all messages have been sent by the Mailserver,  
the requester **SHOULD** handle P2P Request Complete code (0x7d),  
followed by these parameters:

- **RequestID**: 32-byte array with a Keccak-256 hash of the envelope  
  containing the original request
- **LastEnvelopeHash**: 32-byte array with a Keccak-256 hash of the last sent  
  envelope for the request
- **Cursor**: an array of a cursor returned from the previous request (optional)

If Cursor is not empty, not all messages were sent due to the request’s Limit.  
One or more consecutive requests **MAY** be sent with the Cursor field filled  
to receive the remaining messages.

## Security Considerations

### Confidentiality

The node encrypts all Whisper envelopes.  
A Mailserver node cannot inspect their contents.

### Altruistic and Centralized Operator Risk

To be useful, a Mailserver **SHOULD** be online most of the time,  
meaning users must be somewhat tech-savvy to run their own node  
or rely on someone else.

Currently, one of Status’s legal entities provides Mailservers altruistically,  
but this is suboptimal from a decentralization, continuance,  
and risk perspective.  
Developing a better system is ongoing research.

A Status client **SHOULD** allow the Mailserver selection to be customizable.

### Privacy Concerns

To use a Mailserver, a node connects directly to it, i.e.,  
adds the Mailserver as its peer and marks it as trusted.  
This gives the Mailserver access
to the bloom filter of topics the user is interested in,
as well as metadata like the user’s IP address when online.

### Denial-of-Service (DoS)

A Mailserver delivers expired envelopes  
and has a direct TCP connection with the recipient,  
leaving the recipient vulnerable to DoS attacks from a malicious Mailserver.

## Changelog

### Version 0.3

- Released May 22, 2020
- Change to keep Mailserver term consistent

## Copyright

Copyright and related rights waived via CC0.
