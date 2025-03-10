---
slug: 14
title: 14/WAKU2-MESSAGE
name: Waku v2 Message
status: draft
category: Standards Track
tags: waku/core-protocol
editor: Hanno Cornelius <hanno@status.im>
contributors:
  - Sanaz Taheri <sanaz@status.im>
  - Aaryamann Challani <p1ge0nh8er@proton.me>
  - Lorenzo Delgado <lorenzo@status.im>
  - Abhimanyu Rawat <abhi@status.im>
  - Oskar Thorén <oskarth@titanproxy.com>
---

## Abstract

Waku v2 is a family of modular peer-to-peer protocols for secure communication.
These protocols are designed to be secure, privacy-preserving,
and censorship-resistant and can run in resource-restricted environments.
At a high level, Waku v2 implements a Pub/Sub messaging pattern over libp2p and
adds capabilities.

The present document specifies the Waku v2 message format,
a way to encapsulate the messages sent with specific information security goals,
and Whisper/Waku v1 backward compatibility.

## Motivation

When sending messages over Waku, there are multiple requirements:

- One may have a separate encryption layer as part of the application.
- One may want to provide efficient routing for resource-restricted devices.
- One may want to provide compatibility with [Waku v1 envelopes](../../legacy/6/waku1.md).
- One may want encrypted payloads by default.
- One may want to provide unlinkability to get metadata protection.

This specification attempts to provide for these various requirements.

## Semantics

### Waku Message

A Waku message is constituted by the combination of data payload and
attributes that, for example, a *publisher* sends to a *topic* and
is eventually delivered to *subscribers*.

Waku message attributes are key-value pairs of metadata associated with a message.
And the message data payload is the part of the transmitted Waku message
that is the actual message information.
The data payload is also treated as a Waku message attribute for convenience.

### Message Attributes

- The `payload` attribute MUST contain the message data payload to be sent.

- The `content_topic` attribute MUST specify a string identifier
that can be used for content-based filtering,
as described in [23/WAKU2-TOPICS](../../../informational/23/topics.md).

- The `meta` attribute, if present,
contains an arbitrary application-specific variable-length byte array
with a maximum length limit of 64 bytes.
This attribute can be utilized to convey supplementary details
to various Waku protocols,
thereby enabling customized processing based on its contents.

- The `version` attribute, if present,
contains a version number to discriminate different types of payload encryption.
If omitted, the value SHOULD be interpreted as version 0.

- The `timestamp` attribute, if present,
signifies the time at which the message was generated by its sender.
This attribute MAY contain the Unix epoch time in nanoseconds.
If the attribute is omitted, it SHOULD be interpreted as timestamp 0.

- The `ephemeral` attribute, if present, signifies the transient nature of the message.
For example, an ephemeral message SHOULD not be persisted by the Waku network.
If this attribute is set to `true`, the message SHOULD be interpreted as ephemeral.
If, instead, the attribute is omitted or set to `false`,
the message SHOULD be interpreted as non-ephemeral.

## Wire Format

The Waku message wire format is specified using [protocol buffers v3](https://developers.google.com/protocol-buffers/).

```protobuf
syntax = "proto3";

message WakuMessage {
  bytes payload = 1;
  string content_topic = 2;
  optional uint32 version = 3;
  optional sint64 timestamp = 10;
  optional bytes meta = 11;
  optional bool ephemeral = 31;
}
```

An example proto file following this specification can be found [here (vacp2p/waku)](https://github.com/vacp2p/waku/blob/main/waku/message/v1/message.proto).

## Payload encryption

The Waku message payload MAY be encrypted.
The message `version` attribute indicates
the schema used to encrypt the payload data.

- **Version 0:**
  The payload SHOULD be interpreted as unencrypted; additionally,
  it CAN indicate that the message payload has been encrypted
  at the application layer.

- **Version 1:**
The payload SHOULD be encrypted using Waku v1 payload encryption specified in [26/WAKU-PAYLOAD](../../application/26/payload.md).
This provides asymmetric and symmetric encryption.
The key agreement is performed out of band.
And provides an encrypted signature and padding for some form of unlinkability.

- **Version 2:**
The payload SHOULD be encoded according to [WAKU2-NOISE](https://github.com/waku-org/specs/blob/master/standards/application/noise.md).
Waku Noise protocol provides symmetric encryption and asymmetric key exchange.

Any `version` value not included in this list is reserved for future specification.
And, in this case, the payload SHOULD be interpreted as unencrypted by the Waku layer.

## Whisper/Waku v1 envelope compatibility

Whisper/Waku v1 envelopes are compatible with Waku v2 messages format.

- Whisper/Waku v1 `topic` field
SHOULD be mapped to Waku v2 message's `content_topic` attribute.
- Whisper/Waku v1 `data` field SHOULD be mapped to Waku v2 message's `payload` attribute.

Waku v2 implements a pub/sub messaging pattern over libp2p.
This makes redundant some Whisper/Waku v1 envelope fields
(e.g., `expiry`, `ttl`, `topic`, etc.), so they can be ignored.

## Deterministic message hashing

In Protocol Buffers v3,
the deterministic serialization is not canonical across the different implementations
and languages.
It is also unstable across different builds with schema changes due to unknown fields.

To overcome this interoperability limitation,
a Waku v2 message's hash MUST be computed following this schema:

```js
message_hash = sha256(concat(pubsub_topic, message.payload, message.content_topic, message.meta, message.timestamp))
```

If an optional attribute, such as `meta`, is absent,
the concatenation of attributes SHOULD exclude it.
This recommendation is made to ensure that the concatenation process proceeds smoothly
when certain attributes are missing and to maintain backward compatibility.

This hashing schema is deemed appropriate for use cases
where a cross-implementation deterministic hash is needed,
such as message deduplication and integrity validation.
The collision probability offered by this hashing schema can be considered negligible.
This is due to the deterministic concatenation order of the message attributes,
coupled with using a SHA-2 (256-bit) hashing algorithm.

### Test vectors

Waku message hash computation (`meta` size of 12 bytes):

```js
pubsub_topic = "/waku/2/default-waku/proto" (0x2f77616b752f322f64656661756c742d77616b752f70726f746f)
message.payload = 0x010203045445535405060708
message.content_topic = "/waku/2/default-content/proto" (0x2f77616b752f322f64656661756c742d636f6e74656e742f70726f746f)
message.meta = 0x73757065722d736563726574
message.timestamp = 0x175789bfa23f8400

message_hash = 0x64cce733fed134e83da02b02c6f689814872b1a0ac97ea56b76095c3c72bfe05
```

Waku message hash computation (`meta` size of 64 bytes):

```js
pubsub_topic = "/waku/2/default-waku/proto" (0x2f77616b752f322f64656661756c742d77616b752f70726f746f)
message.payload = 0x010203045445535405060708
message.content_topic = "/waku/2/default-content/proto" (0x2f77616b752f322f64656661756c742d636f6e74656e742f70726f746f)
message.meta = 0x000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f
message.timestamp = 0x175789bfa23f8400

message_hash = 0x7158b6498753313368b9af8f6e0a0a05104f68f972981da42a43bc53fb0c1b27
```

Waku message hash computation (`meta` attribute not present):

```js
pubsub_topic = "/waku/2/default-waku/proto" (0x2f77616b752f322f64656661756c742d77616b752f70726f746f)
message.payload = 0x010203045445535405060708
message.content_topic = "/waku/2/default-content/proto" (0x2f77616b752f322f64656661756c742d636f6e74656e742f70726f746f)
message.meta = <not-present>
message.timestamp = 0x175789bfa23f8400

message_hash = 0xa2554498b31f5bcdfcbf7fa58ad1c2d45f0254f3f8110a85588ec3cf10720fd8
```

Waku message hash computation (`payload` length 0):

```js
pubsub_topic = "/waku/2/default-waku/proto" (0x2f77616b752f322f64656661756c742d77616b752f70726f746f)
message.payload = []
message.content_topic = "/waku/2/default-content/proto" (0x2f77616b752f322f64656661756c742d636f6e74656e742f70726f746f)
message.meta = 0x73757065722d736563726574
message.timestamp = 0x175789bfa23f8400

message_hash = 0x483ea950cb63f9b9d6926b262bb36194d3f40a0463ce8446228350bd44e96de4
```

## Security Considerations

### Confidentiality, integrity, and authenticity

The level of confidentiality, integrity, and
authenticity of the Waku message payload is discretionary.
Accordingly, the application layer shall utilize the encryption and
signature schemes supported by Waku v2 to meet the application-specific privacy needs.

### Reliability of the `timestamp` attribute

The Waku message `timestamp` attribute is set by the sender.
Therefore, because message timestamps aren’t independently verified,
this attribute is prone to exploitation and misuse.
It should not solely be relied upon for operations such as message ordering.
For example, a malicious actor can arbitrarily set the `timestamp` of a Waku message
to a high value so that it always shows up as the most recent message
in a chat application.
Applications using Waku messages’ `timestamp` attribute
are recommended to use additional methods for more robust message ordering.
An example of how to deal with message ordering against adversarial message timestamps
can be found in the Status protocol,
see [62/STATUS-PAYLOADS](../../../../status/62/payloads.md/#clock-vs-timestamp-and-message-ordering).

### Reliability of the `ephemeral` attribute

The Waku message `ephemeral` attribute is set by the sender.
Since there is currently no incentive mechanism
for network participants to behave correctly,
this attribute is inherently insecure.
A malicious actor can tamper with the value of a Waku message’s `ephemeral` attribute,
and the receiver would not be able to verify the integrity of the message.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [6/WAKU1](../../legacy/6/waku1.md)
- [Google Protocol buffers v3](https://developers.google.com/protocol-buffers/)
- [26/WAKU-PAYLOAD](../../application/26/payload.md)
- [WAKU2-NOISE](https://github.com/waku-org/specs/blob/master/standards/application/noise.md)
- [62/STATUS-PAYLOADS](../../../../status/62/payloads.md/#clock-vs-timestamp-and-message-ordering)
