# GROUP-CHAT

| Field | Value |
| --- | --- |
| Name | Group Chat |
| Slug | 120 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |
| Contributors | Andrea Piana <andreap@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/group-chat.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/deprecated/group-chat.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/group-chat.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/group-chat.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/group-chat.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/group-chat.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/group-chat.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This document describes the group chat protocol used by the Status application.
The node uses pairwise encryption among members so a message is exchanged  
between each participant, similarly to a one-to-one message.

## Membership updates

The node uses membership updates messages to propagate group chat membership changes.
The protobuf format is described in the [PAYLOADS](/archived/status/deprecated/payloads.md).
Below describes each specific field.

The protobuf messages are:

```protobuf
// MembershipUpdateMessage is a message used to propagate information
// about group membership changes.
message MembershipUpdateMessage {
  // The chat id of the private group chat
  string chat_id = 1;
  // A list of events for this group chat, first 65 bytes are the signature, then is a 
  // protobuf encoded MembershipUpdateEvent
  repeated bytes events = 2;
  // An optional chat message
  ChatMessage message = 3;
}

message MembershipUpdateEvent {
  // Lamport timestamp of the event as described in [Status Payload Specs](status-payload-specs.md#clock-vs-timestamp-and-message-ordering)
  uint64 clock = 1;
  // List of public keys of the targets of the action
  repeated string members = 2;
  // Name of the chat for the CHAT_CREATED/NAME_CHANGED event types
  string name = 3;
  // The type of the event
  EventType type = 4;

  enum EventType {
    UNKNOWN = 0;
    CHAT_CREATED = 1; // See [CHAT_CREATED](#chat-created)
    NAME_CHANGED = 2; // See [NAME_CHANGED](#name-changed)
    MEMBERS_ADDED = 3; // See [MEMBERS_ADDED](#members-added)
    MEMBER_JOINED = 4; // See [MEMBER_JOINED](#member-joined)
    MEMBER_REMOVED = 5; // See [MEMBER_REMOVED](#member-removed)
    ADMINS_ADDED = 6; // See [ADMINS_ADDED](#admins-added)
    ADMIN_REMOVED = 7; // See [ADMIN_REMOVED](#admin-removed)
  }
}
```

### Payload

`MembershipUpdateMessage`:

| Field | Name | Type | Description |
| ----- | ---- | ---- | ---- |
| 1 | chat-id | `string` | The chat id of the chat where the change is to take place |
| 2 | events | See details | A list of events that describe the membership changes, in their encoded protobuf form |
| 3 | message | `ChatMessage` | An optional message, described in [Message](/archived/status/deprecated/payloads.md#message) |

`MembershipUpdateEvent`:

| Field | Name | Type | Description |
| ----- | ---- | ---- | ---- |
| 1 | clock | `uint64` | The clock value of the event |
| 2 | members | `[]string` | An optional list of hex encoded (prefixed with `0x`) public keys, the targets of the action |
| 3 | name | `name` | An optional name, for those events that make use of it |
| 4 | type | `EventType` | The type of event sent, described below |

### Chat ID

Each membership update MUST be sent with a corresponding `chatId`.
The format of this chat ID MUST be a string of [UUID](https://tools.ietf.org/html/rfc4122),
concatenated with the hex-encoded public key of the creator of the chat, joined by `-`.
This chatId MUST be validated by all clients, and MUST be discarded if it does not follow these rules.

### Signature

The node calculates the signature for each event by encoding each `MembershipUpdateEvent` in its protobuf representation
and prepending the bytes of the chatID, lastly the node signs the `Keccak256` of the bytes
using the private key by the author and added to the `events` field of MembershipUpdateMessage.

### Group membership event

Any `group membership` event received MUST be verified by calculating the signature as per the method described above.
The author MUST be extracted from it, if the verification fails the event MUST be discarded.

#### CHAT_CREATED

Chat `created event` is the first event that needs to be sent.
Any event with a clock value lower than this MUST be discarded.
Upon receiving this event a client MUST validate the `chatId`
provided with the updates and create a chat with identified by `chatId` and named `name`.

#### NAME_CHANGED

`admins` use a `name changed` event to change the name of the group chat.
Upon receiving this event a client MUST validate the `chatId` provided with the updates
and MUST ensure the author of the event is an admin of the chat, otherwise the event MUST be ignored.
If the event is valid the chat name SHOULD be changed to `name`.

#### MEMBERS_ADDED

`admins` use a `members added` event to add members to the chat.
Upon receiving this event a client MUST validate the `chatId`
provided with the updates and MUST ensure the author of the event is an admin of the chat, otherwise the event MUST be ignored.
If the event is valid a client MUST update the list of members of the chat who have not joined, adding the `members` received.
`members` is an array of hex encoded public keys.

#### MEMBER_JOINED

`members` use a `members joined` event to signal that they want to start receiving messages from this chat.
Upon receiving this event a client MUST validate the `chatId` provided with the updates.
If the event is valid a client MUST update the list of members of the chat who joined, adding the signer.
Any `message` sent to the group chat should now include the newly joined member.

#### ADMINS_ADDED

`admins` use an `admins added` event to add make other admins in the chat.
Upon receiving this event a client MUST validate the `chatId` provided with the updates,
MUST ensure the author of the event is an admin of the chat
and MUST ensure all `members` are already `members` of the chat, otherwise the event MUST be ignored.
If the event is valid a client MUST update the list of admins of the chat, adding the `members` received.
`members` is an array of hex encoded public keys.

#### MEMBER_REMOVED

`members` and/or `admins` use a `member-removed` event to leave or kick members of the chat.
Upon receiving this event a client MUST validate the `chatId` provided with the updates, MUST ensure that:

- If the author of the event is an admin, target can only be themselves or a non-admin member.
- If the author of the event is not an admin, the target of the event can only be themselves.

If the event is valid a client MUST remove the member from the list of `members`/`admins` of the chat,
and no further message should be sent to them.

#### ADMIN_REMOVED

`Admins` use an `admin-removed` event to drop admin privileges.
Upon receiving this event a client MUST validate the `chatId` provided with the updates,
MUST ensure that the author of the event is also the target of the event.

If the event is valid a client MUST remove the member from the list of `admins` of the chat.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [PAYLOADS](/archived/status/deprecated/payloads.md)
- [UUID](https://tools.ietf.org/html/rfc4122)
