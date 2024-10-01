---
slug: 6
title: 6/PAYLOADS
name: Payloads
status: draft
description: Payload of messages in Status, regarding chat and chat-related use cases.
editor: 
contributors:
- Adam Babik <adam@status.im>
- Andrea Maria Piana <andreap@status.im>
- Oskar Thorén <oskar@status.im>
---

## Abstract

This specification describes how the payload of each message in Status looks
like. It is primarily centered around chat and chat-related use cases.

The payloads aim to be flexible enough to support messaging but also cases
described in the Status Whitepaper as well as various clients created using
different technologies.

## Table of Contents

- [Abstract]
- [Table of Contents]
- [Introduction]
- [Payload wrapper]
- [Encoding]
- [Types of messages]
  - [Message]
    - [Payload]
    - [Payload]
    - [Content types]
      - [Sticker content type]
    - [Message types]
    - [Clock vs Timestamp and message ordering]
    - [Chats]
  - [Contact Update]
    - [Payload]
    - [Contact update]
  - [SyncInstallationContact]
    - [Payload]
  - [SyncInstallationPublicChat]
    - [Payload]
  - [PairInstallation]
    - [Payload]
  - [MembershipUpdateMessage and MembershipUpdateEvent]
- [Upgradability]
- [Security Considerations]
- [Changelog]
  - [Version 0.3]

## Introduction

This document describes the payload format and some special considerations.

## Payload Wrapper

The node wraps all payloads in a protobuf record:

```protobuf
message ApplicationMetadataMessage {
  bytes signature = 1;
  bytes payload = 2;
  
  Type type = 3;

  enum Type {
    UNKNOWN = 0;
    CHAT_MESSAGE = 1;
    CONTACT_UPDATE = 2;
    MEMBERSHIP_UPDATE_MESSAGE = 3;
    PAIR_INSTALLATION = 4;
    SYNC_INSTALLATION = 5;
    REQUEST_ADDRESS_FOR_TRANSACTION = 6;
    ACCEPT_REQUEST_ADDRESS_FOR_TRANSACTION = 7;
    DECLINE_REQUEST_ADDRESS_FOR_TRANSACTION = 8;
    REQUEST_TRANSACTION = 9;
    SEND_TRANSACTION = 10;
    DECLINE_REQUEST_TRANSACTION = 11;
    SYNC_INSTALLATION_CONTACT = 12;
    SYNC_INSTALLATION_PUBLIC_CHAT = 14;
    CONTACT_CODE_ADVERTISEMENT = 15;
    PUSH_NOTIFICATION_REGISTRATION = 16;
    PUSH_NOTIFICATION_REGISTRATION_RESPONSE = 17;
    PUSH_NOTIFICATION_QUERY = 18;
    PUSH_NOTIFICATION_QUERY_RESPONSE = 19;
    PUSH_NOTIFICATION_REQUEST = 20;
    PUSH_NOTIFICATION_RESPONSE = 21;
  }
}
```

`signature` is the bytes of the signed SHA3-256 of the payload,
signed with the key of the author.
The node uses the signature to validate authorship of the message
so it can be relayed to third parties.
Messages without signatures will not be relayed
and are considered plausibly deniable.

`payload` is the protobuf-encoded content of the message,
with the corresponding type set.

## Encoding

The node encodes the payload using Protobuf.

## Types of Messages

### Message

The type `ChatMessage` represents a chat message exchanged between clients.

### Payload

The protobuf description is:

```protobuf
message ChatMessage {
  uint64 clock = 1;            // Lamport timestamp of the chat message
  uint64 timestamp = 2;        // Unix timestamps in milliseconds
  string text = 3;             // Text of the message
  string response_to = 4;      // Id of the message being replied to
  string ens_name = 5;         // Ens name of the sender
  string chat_id = 6;          // Chat id
  MessageType message_type = 7;
  ContentType content_type = 8;

  oneof payload {
    StickerMessage sticker = 9;
  }

  enum MessageType {
    UNKNOWN_MESSAGE_TYPE = 0;
    ONE_TO_ONE = 1;
    PUBLIC_GROUP = 2;
    PRIVATE_GROUP = 3;
    SYSTEM_MESSAGE_PRIVATE_GROUP = 4;
  }

  enum ContentType {
    UNKNOWN_CONTENT_TYPE = 0;
    TEXT_PLAIN = 1;
    STICKER = 2;
    STATUS = 3;
    EMOJI = 4;
    TRANSACTION_COMMAND = 5;
    SYSTEM_MESSAGE_CONTENT_PRIVATE_GROUP = 6;
  }
}
```

### Payload Fields

| Field       | Name        | Type        | Description                                 |
| ----------- | ----------- | ----------- | ------------------------------------------- |
| 1           | clock       | `uint64`      | The clock of the chat                       |
| 2           | timestamp   | `uint64`      | Sender timestamp at message creation        |
| 3           | text        | `string`      | The content of the message                  |
| 4           | response_to | `string`      | ID of the message replied to                |
| 5           | ens_name    | `string`      | ENS name of the user sending the message    |
| 6           | chat_id     | `string`      | Local ID of the chat                        |
| 7           | message_type | `MessageType` | Type of message (one-to-one, public, group) |
| 8           | content_type | `ContentType` | Type of message content                     |
| 9           | payload     | `Sticker\|nil` | Payload of the message                      |

## Content Types

Nodes require content types to interpret incoming messages. Not all messages
are plain text; some carry additional information.

The following content types **MUST** be supported:

- `TEXT_PLAIN`: Identifies a message with plaintext content.

Other content types that **MAY** be implemented by clients include:

- `STICKER`
- `STATUS`
- `EMOJI`
- `TRANSACTION_COMMAND`

## Mentions

A mention **MUST** be represented as a string in the `@0xpk` format,
where `pk` is the public key of the user to be mentioned,
within the text field of a message with `content_type: TEXT_PLAIN`.
A message **MAY** contain more than one mention.

This specification **RECOMMENDS** that the application does not require the user
to enter the entire public key. Instead, it should allow the user
to create a mention by typing `@` followed by the ENS or 3-word pseudonym,
with auto-completion functionality.

For better user experience, the client **SHOULD** display the ENS name
or 3-word pseudonym corresponding to the key instead of the public key.

## Sticker Content Type

A `ChatMessage` with `STICKER` content type **MUST** specify the ID of the pack
and the hash of the pack in the `Sticker` field:

```protobuf
message StickerMessage {
  string hash = 1;
  int32 pack = 2;
}
```

## Message Types

A node requires message types to decide how to encrypt a message and what
metadata to attach when passing it to the transport layer.

The following message types **MUST** be supported:

- `ONE_TO_ONE`: A one-to-one message.
- `PUBLIC_GROUP`: A message to the public group.
- `PRIVATE_GROUP`: A message to the private group.

## Clock vs Timestamp and Message Ordering

If a user sends a new message before receiving messages that were sent while
they were offline, the new message should be displayed last in the chat.

The Status client speculates that its Lamport timestamp will beat the current
chat timestamp, using the format: `clock = max({timestamp}, chat_clock + 1)`.

This satisfies the Lamport requirement: if `a -> b`, then `T(a) < T(b)`.

- `timestamp` **MUST** be Unix time in milliseconds when the node creates the
message. This field **SHOULD** not be relied upon for message ordering.
- `clock` **SHOULD** be calculated using Lamport timestamps, based on the last
received message's clock value: `max(timeNowInMs, last-message-clock-value + 1)`.

Messages with a clock greater than 120 seconds over the Whisper/Waku timestamp
**SHOULD** be discarded to prevent malicious clock increases. Messages with a
clock less than 120 seconds under the Whisper/Waku timestamp may indicate
attempted insertion into chat history.

The node uses the clock value for message ordering. The distributed nature of
the system produces casual ordering, which may lead to counter-intuitive results
in edge cases. For example, when a user joins a public chat and sends a message
before receiving previous messages, their message clock might be lower, causing
the message to appear in the past once historical messages are fetched.

## Chats

A chat is a structure used to organize messages, helping to display messages
from a single recipient or group of recipients.

All incoming messages are matched against a chat. The table below shows how to
calculate a chat ID for each message type:

| Message Type   | Chat ID Calculation                         | Direction      | Comment   |
| -------------- | ------------------------------------------- | -------------- | --------- |
| PUBLIC_GROUP   | Chat ID equals public channel name           | Incoming/Outgoing |           |
| ONE_TO_ONE     | Hex-encode the recipient's public key as chat ID | Outgoing       |           |
| user-message   | Hex-encode the message sender’s public key as chat ID | Incoming | If no match, node may discard or create a new chat |
| PRIVATE_GROUP  | Use chat ID from the message                 | Incoming/Outgoing | If no match, discard message |

## Contact Update

`ContactUpdate` notifies peers that the user has been added as a contact or
that user information has changed.

```protobuf
message ContactUpdate {
  uint64 clock = 1;
  string ens_name = 2;
  string profile_image = 3;
}
```

 Payload Fields

| Field       | Name          | Type    | Description                                      |
| ----------- | ------------- | ------- | ------------------------------------------------ |
| 1           | clock         | uint64  | Clock value of the chat with the user             |
| 2           | ens_name      | string  | ENS name if set                                  |
| 3           | profile_image | string  | Base64-encoded profile picture of the user        |

A client **SHOULD** send a `ContactUpdate` when:

- The `ens_name` has changed.
- The profile image is edited.

Clients **SHOULD** also periodically send `ContactUpdate` messages to contacts.
The Status official client sends these updates every 48 hours.

## SyncInstallationContact

The node uses `SyncInstallationContact` messages to synchronize contacts across
devices in a best-effort manner.

```protobuf
message SyncInstallationContact {
  uint64 clock = 1;
  string id = 2;
  string profile_image = 3;
  string ens_name = 4;
  uint64 last_updated = 5;
  repeated string system_tags = 6;
}
```

Payload Fields

| Field          | Name          | Type          | Description                               |
| -------------- | ------------- | ------------- | ----------------------------------------- |
| 1              | clock         | uint64        | Clock value of the chat                   |
| 2              | id            | string        | ID of the contact synced                  |
| 3              | profile_image | string        | Base64-encoded profile picture of the user |
| 4              | ens_name      | string        | ENS name of the contact                   |
| 5              | system_tags   | array[string] | System tags like ":contact/added"         |

## SyncInstallationPublicChat

The node uses `SyncInstallationPublicChat` to synchronize public chats across
devices.

```protobuf
message SyncInstallationPublicChat {
  uint64 clock = 1;
  string id = 2;
}
```

Payload Fields

| Field       | Name   | Type   | Description           |
| ----------- | ------ | ------ | --------------------- |
| 1           | clock  | uint64 | Clock value of the chat |
| 2           | id     | string | ID of the chat synced  |

## PairInstallation

The node uses `PairInstallation` messages to propagate information about a
device to its paired devices.

```protobuf
message PairInstallation {
  uint64 clock = 1;
  string installation_id = 2;
  string device_type = 3;
  string name = 4;
}
```

Payload Fields

| Field             | Name           | Type   | Description                                    |
| ----------------- | -------------- | ------ | ---------------------------------------------- |
| 1                 | clock          | uint64 | Clock value of the chat                        |
| 2                 | installation_id | string | Randomly generated ID that identifies this device |
| 3                 | device_type    | string | OS of the device (iOS, Android, or desktop)    |
| 4                 | name           | string | Self-assigned name of the device               |

## MembershipUpdateMessage and MembershipUpdateEvent

`MembershipUpdateEvent` propagates information about group membership changes
in a group chat. The details are covered in the [Group Chats specs](https://specs.status.im/draft/7-group-chat.md).

## Upgradability

There are two ways to upgrade the protocol without breaking compatibility:

- A node always supports accretion.
- A node does not support deletion of existing fields or messages,
which might break compatibility.

## Security Considerations

-

## Changelog

### Version 0.3

- **Released**: May 22, 2020
- **Changes**: Added language to include Waku in all relevant places.

## Copyright

Copyright and related rights waived via CC0.
