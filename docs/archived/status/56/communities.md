# 56/STATUS-COMMUNITIES

| Field | Value |
| --- | --- |
| Name | Status Communities that run over Waku v2 |
| Slug | 56 |
| Status | draft |
| Category | Standards Track |
| Editor | Aaryamann Challani <p1ge0nh8er@proton.me> |
| Contributors | Andrea Piana <andreap@status.im>, Prem Chaitanya Prathi <prem@waku.org> |

<!-- timeline:start -->

## Timeline

- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/56/communities.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/56/communities.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/56/communities.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/56/communities.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/56/communities.md) — ci: add mdBook configuration (#233)
- **2025-03-07** — [`f4b34af`](https://github.com/vacp2p/rfc-index/blob/f4b34afd1a1e198b0d99b911bf8b371b5b13a6b8/status/56/communities.md) — Fix Linting Errors (#135)
- **2025-02-21** — [`9bed57e`](https://github.com/vacp2p/rfc-index/blob/9bed57e4ad5d6609202a18f581a00b2fd81f6acb/status/56/communities.md) — docs: define basic sharding for Communities (#132)
- **2025-01-02** — [`dc7497a`](https://github.com/vacp2p/rfc-index/blob/dc7497a3123623f2834d80ebd3a7c77e0d605074/status/56/communities.md) — add usage guidelines for waku content topics (#117)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/56/communities.md) — Fix Files for Linting (#94)
- **2024-08-05** — [`eb25cd0`](https://github.com/vacp2p/rfc-index/blob/eb25cd06d679e94409072a96841de16a6b3910d5/status/56/communities.md) — chore: replace email addresses (#86)
- **2024-02-05** — [`11bdc3b`](https://github.com/vacp2p/rfc-index/blob/11bdc3bbb705afe1b493bbb40d61e2e6d7af6a6a/status/56/communities.md) — Update communities.md
- **2024-02-01** — [`8350742`](https://github.com/vacp2p/rfc-index/blob/83507420c3060f93acac0454276a69df40c4b52c/status/56/communities.md) — Update and rename COMMUNITIES.md to communities.md
- **2024-01-27** — [`a786356`](https://github.com/vacp2p/rfc-index/blob/a786356887a5443d4624a076e878314b30aa4609/status/56/COMMUNITIES.md) — Create COMMUNITIES.md

<!-- timeline:end -->

## Abstract

This document describes the design of Status Communities over Waku v2,
allowing for multiple users to communicate in a discussion space.
This is a key feature for the Status messaging app.

## Background and Motivation

The purpose of Status communities, as specified in this document,
is allowing for large group chats.
Communities can have further substructure, e.g. specific channels.

Smaller group chats, on the other hand,
are out of scope for this document and
can be built over [55/STATUS-1TO1-CHAT](../55/1to1-chat.md).
We refer to these smaller group chats simply as "group chats",
to differentiate them from Communities.

For group chats based on [55/STATUS-1TO1-CHAT](../55/1to1-chat.md),
the key exchange mechanism MUST be X3DH,
as described in [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md).

However, this method does not scale as the number of participants increases,
for the following reasons -

1. The number of messages sent over the network increases with the number of participants.
2. Handling the X3DH key exchange for each participant is computationally expensive.

Having multicast channels reduces the overhead of a group chat based on 1:1 chat.
Additionally, if all the participants of the group chat have a shared key,
then the number of messages sent over the network is reduced to one per message.

## Terminology

- **Community**: A group of peers that can communicate with each other.
- **Member**: A peer that is part of a community.
- **Admin**: A member that has administrative privileges.
Used interchangeably with "owner".
- **Channel**: A designated subtopic for a community. Used interchangeably with "chat".

## Design Requirements

Due to the nature of communities,
the following requirements are necessary for the design of communities  -

1. The creator of the Community is the owner of the Community.
2. The Community owner is trusted.
3. The Community owner can add or remove members from the Community.
This extends to banning and kicking members.
4. The Community owner can add, edit and remove channels.
5. Community members can send/receive messages
to the channels which they have access to.
6. Communities may be encrypted (private) or unencrypted (public).
7. A Community is uniquely identified by a public key.
8. The public key of the Community is shared out of band.
9. The metadata of the Community can be found by listening on a content topic
derived from the public key of the Community.
10. Community members run their own Waku nodes,
with the configuration described in [Waku-Protocols](#waku-protocols).
Light nodes solely implementing
[19/WAKU2-LIGHTPUSH](../../../messaging/standards/core/19/lightpush.md)
may not be able to run their own Waku node with the configuration described.

## Design

### Cryptographic Primitives

The following cryptographic primitives are used in the design -

- X3DH
- Single Ratchet
  - The single ratchet is used to encrypt the messages sent to the Community.
  - The single ratchet is re-keyed when a member is added/removed from the Community.

## Wire format

<!--   
The wire format is described first to give an overview of the protocol.
It is referenced in the flow of community creation and community management.
More or less an intersection of https://github.com/status-im/specs/blob/403b5ce316a270565023fc6a1f8dec138819f4b0/docs/raw/organisation-channels.md 
and https://github.com/status-im/status-go/blob/6072bd17ab1e5d9fc42cf844fcb8ad18aa07760c/protocol/protobuf/communities.proto,

-->

```protobuf
syntax = "proto3";

message IdentityImage {
  // payload is a context based payload for the profile image data,
  // context is determined by the `source_type`
  bytes payload = 1;
  // source_type signals the image payload source
  SourceType source_type = 2;
  // image_type signals the image type and method of parsing the payload
  ImageType image_type = 3;
  // encryption_keys is a list of encrypted keys that can be used to decrypt an 
  // encrypted payload
  repeated bytes encryption_keys = 4;
  // encrypted signals the encryption state of the payload, default is false.
  bool encrypted = 5;
  // SourceType are the predefined types of image source allowed
  enum SourceType {
    UNKNOWN_SOURCE_TYPE = 0;

    // RAW_PAYLOAD image byte data
    RAW_PAYLOAD = 1;

    // ENS_AVATAR uses the ENS record's resolver get-text-data.avatar data
    // The `payload` field will be ignored if ENS_AVATAR is selected
    // The application will read and 
    // parse the ENS avatar data as image payload data, URLs will be ignored
    // The parent `ChatMessageIdentity` must have a valid `ens_name` set
    ENS_AVATAR = 2;
  }
}

// SocialLinks represents social link associated with given chat identity (personal/community)
message SocialLink {
  // Type of the social link
  string text = 1;
  // URL of the social link
  string url = 2;
}
// ChatIdentity represents identity of a community/chat
message ChatIdentity {
  // Lamport timestamp of the message
  uint64 clock = 1;
  // ens_name is the valid ENS name associated with the chat key
  string ens_name = 2;
  // images is a string indexed mapping of images associated with an identity
  map<string, IdentityImage> images = 3;
  // display name is the user set identity
  string display_name = 4;
  // description is the user set description
  string description = 5;
  string color = 6;
  string emoji = 7;
  repeated SocialLink social_links = 8;
  // first known message timestamp in seconds 
  // (valid only for community chats for now)
  // 0 - unknown
  // 1 - no messages
  uint32 first_message_timestamp = 9;
}

message Grant {
  // Community ID (The public key of the community)
  bytes community_id = 1;
  // The member ID (The public key of the member)
  bytes member_id = 2;
  // The chat for which the grant is given
  string chat_id = 3;
  // The Lamport timestamp of the grant
  uint64 clock = 4;
}

message CommunityMember {
  // The roles a community member MAY have
  enum Roles {
    UNKNOWN_ROLE = 0;
    ROLE_ALL = 1;
    ROLE_MANAGE_USERS = 2;
    ROLE_MODERATE_CONTENT = 3;
  }
  repeated Roles roles = 1;
}

message CommunityPermissions {
  // The type of access a community MAY have
  enum Access {
    UNKNOWN_ACCESS = 0;
    NO_MEMBERSHIP = 1;
    INVITATION_ONLY = 2;
    ON_REQUEST = 3;
  }

  // If the community should be available only to ens users
  bool ens_only = 1;
  // If the community is private
  bool private = 2;
  Access access = 3;
}

message CommunityAdminSettings {
  // If the Community admin may pin messages
  bool pin_message_all_members_enabled = 1;
}

message CommunityChat {
  // A map of members in the community to their roles in a chat
  map<string,CommunityMember> members = 1;
  // The permissions of the chat
  CommunityPermissions permissions = 2;
  // The metadata of the chat
  ChatIdentity identity = 3;
  // The category of the chat
  string category_id = 4;
  // The position of chat in the display
  int32 position = 5;
}

message CommunityCategory {
  // The category id 
  string category_id = 1;
  // The name of the category
  string name = 2;
  // The position of the category in the display
  int32 position = 3;
}

message CommunityInvitation {
  // Encrypted/unencrypted community description
  bytes community_description = 1;
  // The grant offered by the community
  bytes grant = 2;
  // The chat id requested to join
  string chat_id = 3;
  // The public key of the community
  bytes public_key = 4;
}

message CommunityRequestToJoin {
  // The Lamport timestamp of the request  
  uint64 clock = 1;
  // The ENS name of the requester
  string ens_name = 2;
  // The chat id requested to join
  string chat_id = 3;
  // The public key of the community
  bytes community_id = 4;
  // The display name of the requester
  string display_name = 5;
}

message CommunityCancelRequestToJoin {
  // The Lamport timestamp of the request
  uint64 clock = 1;
  // The ENS name of the requester
  string ens_name = 2;
  // The chat id requested to join
  string chat_id = 3;
  // The public key of the community
  bytes community_id = 4;
  // The display name of the requester
  string display_name = 5;
  // Magnet uri for community history protocol
  string magnet_uri = 6;
}

message CommunityRequestToJoinResponse {
  // The Lamport timestamp of the request
  uint64 clock = 1;
  // The community description
  CommunityDescription community = 2;
  // If the request was accepted
  bool accepted = 3;
  // The grant offered by the community
  bytes grant = 4;
  // The community public key
  bytes community_id = 5;
}

message CommunityRequestToLeave {
  // The Lamport timestamp of the request
  uint64 clock = 1;
  // The community public key
  bytes community_id = 2;
}

message CommunityDescription {
  // The Lamport timestamp of the message
  uint64 clock = 1;
  // A mapping of members in the community to their roles
  map<string,CommunityMember> members = 2;
  // The permissions of the Community
  CommunityPermissions permissions = 3;
  // The metadata of the Community
  ChatIdentity identity = 5;
  // A mapping of chats to their details
  map<string,CommunityChat> chats = 6;
  // A list of banned members
  repeated string ban_list = 7;
  // A mapping of categories to their details
  map<string,CommunityCategory> categories = 8;
  // The admin settings of the Community
  CommunityAdminSettings admin_settings = 10;
  // If the community is encrypted
  bool encrypted = 13;
  // The list of tags
  repeated string tags = 14;
}
```

Note: The usage of the clock is described in the [Clock](#clock) section.

### Functional scope and shard assignment

We define two special [functional scopes](../raw/status-app-protocols.md#functional-scope) for messages related to Status Communities:

1. Global community control
2. Global community content

All messages that relate to controlling communities MUST be assigned the _global community control_ scope.
All messages that carry user-generated content for communities MUST be assigned the _global community content_ scope.

> **Note:** a previous iteration of Status Communities defined separate community-wide scopes for each community.
However, this model was deprecated and all communities now operate on a global, shared scope.
This implies that different communities will share shards on the routing layer.

The following [Waku transport layer](../raw/status-app-protocols.md#waku-transport-layer) allocations are reserved for communities:
As per [STATUS-SIMPLE-SCALING](https://rfc.vac.dev/status/raw/simple-scaling/#relay-shards), communities use the default cluster ID `16`
set aside for all Status app protocols.
Within this cluster, the following [shards](../raw/status-app-protocols.md#pubsub-topics-and-sharding) are reserved for the community functional scopes:

1. All messages with a _global community control_ scope MUST be published to shard `128`
2. All messages with a _global community content_ scope MUST be published to shard `256`

### Content topic level encryption

-a universal chat identifier is used for all community chats.
<!-- Don't enforce any constraints on the unique id generation -->

All messages are encrypted before they are handed over to waku ir-respective of the encryption explained above.
All community chats are encrypted using a symmetric key generated from universal chat id using pbkdf2.

```js
symKey = pbkdf2(password:universalChatID, salt:nil, iteration-count:65356,key-length:32, hash-func: random-sha256)
```

### Content topic usage

"Content topic" refers to the field in [14/WAKU2-MESSAGE](../../../messaging/standards/core/14/message.md#message-attributes),
further elaborated in [10/WAKU2](../../../messaging/standards/core/10/waku2.md#overview-of-protocol-interaction).
The content-topic usage follows the guidelines specified at [23/topics](../../../messaging/informational/23/topics.md#content-topic-usage-guidelines)

#### Advertising a Community

The content topic that the community is advertised on
MUST be derived from the public key of the community.
The content topic MUST be the first four bytes of the keccak-256 hash
of the compressed (33 bytes) public key of the community encoded into a hex string.

```js
hash = hex(keccak256(encodeToHex(compressedPublicKey)))

topicLen = 4
if len(hash) < topicLen {
    topicLen = len(hash)
}

var topic [4]byte
for i = 0; i < topicLen; i++ {
    topic[i] = hash[i]
}

contentTopic = "/waku/1/0x" + topic + "/rfc26"
```

#### Community event messages

Message such as community description
MUST be sent to the content topic derived from the public key of the community.
The content topic
MUST be the hex-encoded keccak-256 hash of the public key of the community.

```js
hash = hex(keccak256(encodeToHex(publicKey)))

topicLen = 4
if len(hash) < topicLen {
    topicLen = len(hash)
}
var topic [4]byte
for i = 0; i < topicLen; i++ {
    topic[i] = hash[i]
}

contentTopic = "/waku/1/0x" + topic + "/rfc26"
```

#### Community Requests

Requests to leave, join, kick and ban, as well as key exchange messages, MUST be sent to the content topic derived from the public key of the community on the common shard.

The content topic
MUST be the keccak-256 hash of hex-encoded universal chat id (public key appended with fixed string) of the community omitting the first 2 bytes.

```js
universalChatId = publicKey+"-memberUpdate"
hash = hex(keccak256(encodeToHex(universalChatId))[2:])

topicLen = 4
if len(hash) < topicLen {
    topicLen = len(hash)
}
var topic [4]byte
for i = 0; i < topicLen; i++ {
    topic[i] = hash[i]
}

contentTopic = "/waku/1/0x" + topic + "/rfc26"
```

#### Community Shard Info

If a community is assigned a dedicated shard then the shard info for that community is published on a content topic derived from a specialized key. This is useful for users joining the new community so that they can subscribe to this specific content topic.

```js
chatID = publicKey+"-shard-info"
hash = hex(keccak256(encodeToHex(chatID))[2:])

topicLen = 4
if len(hash) < topicLen {
    topicLen = len(hash)
}
var topic [4]byte
for i = 0; i < topicLen; i++ {
    topic[i] = hash[i]
}

contentTopic = "/waku/1/0x" + topic + "/rfc26"
```

#### Community channels/chats

All channels/chats shall use a single content-topic which is derived from a universal chat id irrespective of their individual unique chat ids.

### Community Management

The flows for Community management are as described below.

#### Community Creation Flow

1. The Community owner generates a public/private key pair.
2. The Community owner configures the Community metadata,
according to the wire format "CommunityDescription".
3. The Community owner publishes the Community metadata on a content topic
derived from the public key of the Community.
the Community metadata SHOULD be encrypted with the public key of the Community.
The Community metadata is sent during fixed intervals,
to ensure that the Community metadata is available to members.
The Community metadata SHOULD be sent every time the Community metadata is updated.
4. The Community owner MAY advertise the Community out of band,
by sharing the public key of the Community on other mediums of communication.

#### Community Join Flow (peer requests to join a Community)

1. A peer and the Community owner establish a 1:1 chat as described in [55/STATUS-1TO1-CHAT](../55/1to1-chat.md).
2. The peer requests to join a Community by sending a
"CommunityRequestToJoin" message to the Community.
At this point, the peer MAY send a
"CommunityCancelRequestToJoin" message to cancel the request.
3. The Community owner MAY accept or reject the request.
4. If the request is accepted,
the Community owner sends a "CommunityRequestToJoinResponse" message to the peer.
5. The Community owner then adds the member to the Community metadata, and
publishes the updated Community metadata.

#### Community Join Flow (peer is invited to join a Community)

1. The Community owner and peer establish a 1:1 chat as described in [55/STATUS-1TO1-CHAT](../55/1to1-chat.md).
2. The peer is invited to join a Community by the Community owner,
by sending a "CommunityInvitation" message.
3. The peer decrypts the "CommunityInvitation" message, and verifies the signature.
4. The peer requests to join a Community by sending a
"CommunityRequestToJoin" message to the Community.
5. The Community owner MAY accept or reject the request.
6. If the request is accepted,
the Community owner sends a "CommunityRequestToJoinResponse" message to the peer.
7. The Community owner then adds the member to the Community metadata, and
publishes the updated Community metadata.

#### Community Leave Flow

1. A member requests to leave a Community by sending a
"CommunityRequestToLeave" message to the Community.
2. The Community owner MAY accept or reject the request.
3. If the request is accepted,
the Community owner removes the member from the Community metadata,
and publishes the updated Community metadata.

#### Community Ban Flow

1. The Community owner adds a member to the ban list, revokes their grants,
and publishes the updated Community metadata.
2. If the Community is Private,
Re-keying is performed between the members of the Community,
to ensure that the banned member is unable to decrypt any messages.

### Waku Protocols

The following Waku protocols SHOULD be used to implement Status Communities -

1. [11/WAKU2-RELAY](../../../messaging/standards/core/11/relay.md) -
To send and receive messages
2. [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md) -
To encrypt and decrypt messages
3. [54/WAKU2-X3DH-SESSIONS](../../../messaging/standards/application/54/x3dh-sessions.md)-
To handle session keys
4. [14/WAKU2-MESSAGE](../../../messaging/standards/core/14/message.md) -
To wrap community messages in a Waku message
5. [13/WAKU2-STORE](../../../messaging/standards/core/13/store.md) -
To store and retrieve messages for offline devices

The following Waku protocols MAY be used to implement Status Communities -

1. [12/WAKU2-FILTER](../../../messaging/standards/core/12/filter.md) -
Content filtering for resource restricted devices
2. [19/WAKU2-LIGHTPUSH](../../../messaging/standards/core/19/lightpush.md) -
Allows Light clients to participate in the network

### Backups

The member MAY back up their local settings,
by encrypting it with their public key, and
sending it to a given content topic.
The member MAY then rely on this backup to restore their local settings,
in case of a data loss.
This feature relies on
[13/WAKU2-STORE](../../../messaging/standards/core/13/store.md)
for storing and retrieving messages.

### Clock

The clock used in the wire format refers to the Lamport timestamp of the message.
The Lamport timestamp is a logical clock that is used to determine the order of events
in a distributed system.
This allows ordering of messages in an asynchronous network
where messages may be received out of order.

## Security Considerations

1. The Community owner is a single point of failure.
If the Community owner is compromised, the Community is compromised.

2. Follows the same security considerations as the
[53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md) protocol.

## Future work

1. To scale and optimize the Community management,
the Community metadata should be stored on a decentralized storage system, and
only the references to the Community metadata should be broadcasted.
The following document describes this method in more detail -
[Optimizing the `CommunityDescription` dissemination](https://hackmd.io/rD1OfIbJQieDe3GQdyCRTw)

2. Token gating for communities

3. Sharding the content topic used for [#Community Event Messages](#community-event-messages),
since members of the community don't need to receive all the control messages.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)
- [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md)
- [19/WAKU2-LIGHTPUSH](../../../messaging/standards/core/19/lightpush.md)
- [14/WAKU2-MESSAGE](../../../messaging/standards/core/14/message.md)
- [10/WAKU2](../../../messaging/standards/core/10/waku2.md)
- [11/WAKU2-RELAY](../../../messaging/standards/core/11/relay.md)
- [54/WAKU2-X3DH-SESSIONS](../../../messaging/standards/application/54/x3dh-sessions.md)
- [13/WAKU2-STORE](../../../messaging/standards/core/13/store.md)
- [12/WAKU2-FILTER](../../../messaging/standards/core/12/filter.md)

### informative

- [community.go](https://github.com/status-im/status-go/blob/6072bd17ab1e5d9fc42cf844fcb8ad18aa07760c/protocol/communities/community.go)
- [organisation-channels.md](https://github.com/status-im/specs/blob/403b5ce316a270565023fc6a1f8dec138819f4b0/docs/raw/organisation-channels.md)
