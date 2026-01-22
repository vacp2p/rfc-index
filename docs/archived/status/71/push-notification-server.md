# 71/STATUS-PUSH-NOTIFICATION-SERVER

| Field | Value |
| --- | --- |
| Name | Push Notification Server |
| Slug | 71 |
| Status | draft |
| Category | Standards Track |
| Editor | Jimmy Debe <jimmy@status.im> |
| Contributors | Andrea Maria Piana <andreap@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/71/push-notification-server.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/71/push-notification-server.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/71/push-notification-server.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/71/push-notification-server.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/71/push-notification-server.md) — ci: add mdBook configuration (#233)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/71/push-notification-server.md) — Fix Files for Linting (#94)
- **2024-02-07** — [`3e21cc0`](https://github.com/vacp2p/rfc-index/blob/3e21cc0aabe72b00bf2e6ce51ed889e929e4a047/status/71/push-notification-server.md) — Update push-notification-server.md
- **2024-02-05** — [`5bce327`](https://github.com/vacp2p/rfc-index/blob/5bce32702ae3dcb1c05f491804a745724533db7e/status/71/push-notification-server.md) — Update push-notification-server.md
- **2024-02-02** — [`8df3f00`](https://github.com/vacp2p/rfc-index/blob/8df3f006cf6a9dd64c3cfa8c99256330cc696df7/status/71/push-notification-server.md) — Update and rename PUSH-NOTIFICATIONS.md to push-notification-server.md
- **2024-01-27** — [`eb7c5bf`](https://github.com/vacp2p/rfc-index/blob/eb7c5bf71edd47cf0b5d0f0919013cdea17c4f43/status/71/PUSH-NOTIFICATIONS.md) — Create PUSH-NOTIFICATIONS.md

<!-- timeline:end -->

## Abstract

A push notification server implementation for IOS devices and Android devices.
This specification provides a set of methods that allow clients
to use push notification services in mobile environments.

## Background

Push notification for iOS and
Android devices can only be implemented by relying on
[APN](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1),
Apple Push Notification, service for iOS or
[Firebase](https://firebase.google.com/) for Android.

For some Android devices, foreground services are restricted,
requiring a user to grant authorization to applications
to use foreground notifications.
Apple iOS devices restrict notifications to
a few internal functions that every application can not use.
Applications on iOS can request execution time when they are in the background.
This has a limited set of use cases for example,
it will not schedule any time if the application was closed with force quit.
Requesting execution time is not responsive enough to
implement a push notification system.
Status provides a set of methods to acheive push notification services.

Since this can not be safely implemented in a privacy-preserving manner,
clients need to be given an option to opt-in to receive and send push notifications.
They are disabled by default.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”,
“SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Definitions

| Terminology  | Description |
| --------------- | --------- |
| client | A node that implements the Status specifications. |
| user | The owner of a device that runs a client. |
| server | A service that performs push notifications. |
| Waku-Store | A Waku node that decides to provide functionality to store messages permanently and deliver the messages to requesting clients. As described in [13/WAKU-STORE](../../../messaging/standards/core/13/store.md) specification.|

### Server Components

| Components | Description |
| --------------- | --------- |
| gorush Instance | Only used by push notification servers and MUST be publicly available.|
| Push Notification Server | Used by clients to register for receiving and sending notifications. |
| Registering Client | A client that wants to receive push notifications. |
| Sending Client | A client that wants to send push notifications. |

### Requirements

The party releasing the app MUST possess a certificate
for the Apple Push Notification service and
it MUST run a [gorush](https://github.com/appleboy/gorush)
publicly accessible server for sending the actual notification.
The party releasing the app MUST run its own [gorush](https://github.com/appleboy/gorush).

### Push Notification Server Flow

#### Registration Process

![registration](images/registration.png)

#### Sending and Receiving Notification Process

![notification](images/notification.png)

### Registering Client

Registering a client with a push notification service.

- A client MAY register with one or
more push notification services in order to increase availability.

- A client SHOULD make sure that all the notification services they registered with
have the same information about their tokens.

- A `PNR message` (Push Notification Registration) MUST be sent to the
[partitioned topic](../../../messaging/standards/application/54/x3dh-sessions.md)
for the public key of the node, encrypted with this key.

- The message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_REGISTRATION`.

- The marshaled protobuf payload MUST also be encrypted with AES-GCM
using the Diffie–Hellman key generated from the client and server identity.
This is done in order to ensure that the extracted key from the signature
will be considered invalid if it can’t decrypt the payload.

The content of the message MUST contain the following [protobuf record](https://developers.google.com/protocol-buffers/):

```protobuf
message PushNotificationRegistration {
  enum TokenType {
    UNKNOWN_TOKEN_TYPE = 0;
    APN_TOKEN = 1;
    FIREBASE_TOKEN = 2;
  }
  TokenType token_type = 1;
  string device_token = 2;
  string installation_id = 3;
  string access_token = 4;
  bool enabled = 5;
  uint64 version = 6;
  repeated bytes allowed_key_list = 7;
  repeated bytes blocked_chat_list = 8;
  bool unregister = 9;
  bytes grant = 10;
  bool allow_from_contacts_only = 11;
  string apn_topic = 12;
  bool block_mentions = 13;
  repeated bytes allowed_mentions_chat_list = 14;
}
```

A push notification server will handle the message according to the following rules:

- it MUST extract the public key of the sender from the signature and
verify that the payload can be decrypted successfully.

- it MUST verify that `token_type` is supported.

- it MUST verify that `device_token` is non empty.

- it MUST verify that `installation_id` is non empty.

- it MUST verify that `version` is non-zero and
greater than the currently stored version for the public key and
`installation_id` of the sender, if any.

- it MUST verify that `grant` is non empty and according to the Grant Server specs.

- it MUST verify that `access_token` is a valid uuid.

- it MUST verify that `apn_topic` is set if token_type is APN_TOKEN.

- The message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_REGISTRATION_RESPONSE`.

The payload of the response is:

```protobuf
message PushNotificationRegistrationResponse {
  bool success = 1;
  ErrorType error = 2;
  bytes request_id = 3;

  enum ErrorType {
    UNKNOWN_ERROR_TYPE = 0;
    MALFORMED_MESSAGE = 1;
    VERSION_MISMATCH = 2;
    UNSUPPORTED_TOKEN_TYPE = 3;
    INTERNAL_ERROR = 4;
  }
}

```

A client SHOULD listen for a response sent on the
[partitioned topic](../../../messaging/standards/application/54/x3dh-sessions.md)
that the key used to register.
If success is true the client has registered successfully.

If `success` is `false`:
 > If `MALFORMED_MESSAGE` is returned,
the request SHOULD NOT be retried without ensuring that it is correctly formed.
 > If `INTERNAL_ERROR` is returned, the request MAY be retried,
but the client MUST backoff exponentially.

#### Handle Errors

- If the message can’t be decrypted, the message MUST be discarded.

- If `token_type` is not supported, a response MUST be sent with `error` set to `UNSUPPORTED_TOKEN_TYPE`.

- If `token`, `installation_id`, `device_tokens`, `version` are empty,
a response MUST be sent with `error` set to `MALFORMED_MESSAGE`.

- If the `version` is equal or less than the currently stored `version`,
a response MUST be sent with `error` set to `VERSION_MISMATCH`.

- If any other error occurs the `error` SHOULD be set to `INTERNAL_ERROR`.

- If the response is successful `success` MUST be set to `true` otherwise
a response MUST be sent with `success` set to `false`.

- `request_id` SHOULD be set to the
[`SHAKE-256`](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.202.pdf)
of the encrypted payload.

- The response MUST be sent on the
[partitioned topic](../../../messaging/standards/application/54/x3dh-sessions.md)
of the sender and MUST not be encrypted using
the secure transport to facilitate the usage of ephemeral keys.

- If no response is returned, the request SHOULD be considered failed and
MAY be retried with the same server or a different one, but clients
MUST exponentially backoff after each trial.

## Push Notification Server

A node that handles receiving and sending push notifications for clients.

### Query Topic

On successful registration the server MUST be listening to the topic derived from:
  > `0x` + HexEncode(Shake256(CompressedClientPublicKey))

Using the topic derivation algorithm described here and listen for client queries.

#### Server Grant

A client MUST authorize a push notification server to send them push notifications.
This is done by building a grant which is specific to a given client-server pair.
When receiving a grant,
the server MUST validate that the signature matches the registering client.

The grant is built as:

```js
`Signature(Keccak256(CompressedPublicKeyOfClient.CompressedPublicKeyOfServer.AccessToken), PrivateKeyOfClient)`
```

#### Unregistering with a Server

- To unregister a client MUST send a `PushNotificationRegistration`
request as described above with `unregister` set to `true`,
or removing their device information.
- The server MUST remove all data about this user if `unregistering` is `true`,
apart from the `hash` of the public key and
the `version` of the last options,
in order to make sure that old messages are not processed.
- A client MAY unregister from a server on explicit logout
if multiple chat keys are used on a single device.

#### Re-registering with a Server

- A client SHOULD re-register with the node if the APN or FIREBASE token changes.
- When re-registering a client SHOULD ensure
that it has the most up-to-date `PushNotificationRegistration` and
increment `version` if necessary.
- Once re-registered, a client SHOULD advertise the changes.
Changing options is handled the same as re-registering.

#### Advertising a Server

Each user registered with one or more push notification servers
SHOULD advertise periodically the push notification services
they have registered with for each device they own.

```protobuf
message PushNotificationQueryInfo {
  string access_token = 1;
  string installation_id = 2;
  bytes public_key = 3;
  repeated bytes allowed_user_list = 4;
  bytes grant = 5;
  uint64 version = 6;
  bytes server_public_key = 7;
}

message ContactCodeAdvertisement {
  repeated PushNotificationQueryInfo push_notification_info = 1;
}

```

#### Handle Advertisement Message

- The message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_QUERY_INFO`.
- If no filtering is done based on public keys,
the access token SHOULD be included in the advertisement.
  Otherwise it SHOULD be left empty.
- This SHOULD be advertised on the
[contact code topic](../../../messaging/standards/application/53/x3dh.md) and
SHOULD be coupled with normal contact-code advertisement.
- When a user register or re-register with a push notification service,
their contact-code SHOULD be re-advertised.
- Multiple servers MAY be advertised for the same installation_id
 for redundancy reasons.

#### Discovering a Server

To discover a push notification service for a given user, their
[contact code topic](../../../messaging/standards/application/53/x3dh.md)
SHOULD be listened to.
A Waku-Store node can be queried for the specific topic
to retrieve the most up-to-date contact code.

#### Querying a Server

If a token is not present in the latest advertisement for a user,
the server SHOULD be queried directly.

To query a server a message:

```protobuf
message PushNotificationQuery {
  repeated bytes public_keys = 1;
}

```

#### Handle Query Message

- The message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_QUERY`.
- it MUST be sent to the server on the topic derived from the hashed public key
of the key we are querying,
[as described above](#query-topic).
- An ephemeral key SHOULD be used and SHOULD NOT be encrypted using the [secure transport](../../../messaging/standards/application/53/x3dh.md).

If the server has information about the client a response MUST be sent:

```protobuf
message PushNotificationQueryInfo {
  string access_token = 1;
  string installation_id = 2;
  bytes public_key = 3;
  repeated bytes allowed_user_list = 4;
  bytes grant = 5;
  uint64 version = 6;
  bytes server_public_key = 7;
}

message PushNotificationQueryResponse {
  repeated PushNotificationQueryInfo info = 1;
  bytes message_id = 2;
  bool success = 3;
}

```

#### Handle Query Response

- A `PushNotificationQueryResponse` message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_QUERY_RESPONSE`.
Otherwise a response MUST NOT be sent.

- If `allowed_key_list` is not set `access_token` MUST be set
and `allowed_key_list` MUST NOT be set.

- If `allowed_key_list` is set `allowed_key_list` MUST be set and
`access_token` MUST NOT be set.

- If `access_token` is returned,
the `access_token` SHOULD be used to send push notifications.

- If `allowed_key_list` are returned,
the client SHOULD decrypt each token by generating an `AES-GCM` symmetric key
from the Diffie–Hellman between the target client and itself.
If AES decryption succeeds,
it will return a valid `uuid` which is what is used for access_token.
The token SHOULD be used to send push notifications.

- The response MUST be sent on the
[partitioned topic](../../../messaging/standards/application/54/x3dh-sessions.md)
of the sender and
MUST NOT be encrypted using the
[secure transport](../../../messaging/standards/application/53/x3dh.md)
to facilitate the usage of ephemeral keys.

- On receiving a response,
a client MUST verify `grant` to ensure that the server
has been authorized to send push notification to a given client.

### Sending Client

Sending a push notification

- When sending a push notification,
only the `installation_id` for the devices targeted by the message SHOULD be used.

- If a message is for all the user devices,
all the `installation_id` known to the client MAY be used.

- The number of devices MAY be capped in order to reduce resource consumption.

- At least 3 devices SHOULD be targeted, ordered by last activity.

- For any device that a token is available, or that
a token is successfully queried,
a push notification message SHOULD be sent to the corresponding
push notification server.

```protobuf
message PushNotification {
  string access_token = 1;
  string chat_id = 2;
  bytes public_key = 3;
  string installation_id = 4;
  bytes message = 5;
  PushNotificationType type = 6;
  enum PushNotificationType {
    UNKNOWN_PUSH_NOTIFICATION_TYPE = 0;
    MESSAGE = 1;
    MENTION = 2;
  }
  bytes author = 7;
}

message PushNotificationRequest {
  repeated PushNotification requests = 1;
  bytes message_id = 2;
}

```

#### Handle Notification Request

- A `PushNotificationRequest` message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_REQUEST`.

- Where `message` is the encrypted payload of the message and
`chat_id` is the `SHAKE-256` of the `chat_id`.
`message_id` is the id of the message,
`author` is the `SHAKE-256` of the public key of the sender.

- If multiple server are available for a given push notification,
only one notification MUST be sent.

- If no response is received a client SHOULD wait at least 3 seconds,
after which the request MAY be retried against a different server.

- This message SHOULD be sent using an ephemeral key.

On receiving the message, the push notification server MUST validate the access token.
If the access token is valid, a notification MUST be sent to the
[gorush](https://github.com/appleboy/gorush) instance with the following data:

```yaml
{
  "notifications": [
    {
      "tokens": ["token_a", "token_b"],
      "platform": 1,
      "message": "You have a new message",
      "data": {
        "chat_id": chat_id,
        "message": message,
        "installation_ids": [installation_id_1, installation_id_2]
      }
    }
  ]
}

```

Where platform is 1 for iOS and 2 for Firebase, according to the [gorush documentation](https://github.com/appleboy/gorush).

A server MUST return a response message:

```protobuf
message PushNotificationReport {
  bool success = 1;
  ErrorType error = 2;
  enum ErrorType {
    UNKNOWN_ERROR_TYPE = 0;
    WRONG_TOKEN = 1;
    INTERNAL_ERROR = 2;
    NOT_REGISTERED = 3;
  }
  bytes public_key = 3;
  string installation_id = 4;
}

```

```protobuf
message PushNotificationResponse {
  bytes message_id = 1;
  repeated PushNotificationReport reports = 2;
}

```

Where `message_id` is the `message_id` sent by the client.

#### Handle Notification Response

- A `PushNotificationResponse` message MUST be wrapped in a
[`ApplicationMetadataMessage`](../62/payloads.md) with type set to `PUSH_NOTIFICATION_RESPONSE`.

- The response MUST be sent on the
[partitioned topic](../../../messaging/standards/application/54/x3dh-sessions.md)
of the sender and
MUST not be encrypted using the
[secure transport](../../../messaging/standards/application/53/x3dh.md)
to facilitate the usage of ephemeral keys.

- If the request is accepted `success` MUST be set to `true`.
Otherwise `success` MUST be set to `false`.

- If `error` is `BAD_TOKEN` the client MAY query again the server for the token and
retry the request.

- If `error` is `INTERNAL_ERROR` the client MAY retry the request.

### Protobuf Description

#### PushNotificationRegistration

`token_type`: the type of token. Currently supported is `APN_TOKEN` for Apple Push.

`device_token`: the actual push notification token sent by `Firebase` or
`APN` and `FIREBASE_TOKEN` for firebase.

`installation_id`: the `installation_id` of the device.

`access_token`: the access token that will be given to clients to send push notifications.

`enabled`: whether the device wants to be sent push notifications.

`version`: a monotonically increasing number identifying the current `PushNotificationRegistration`.
Any time anything is changed in the record it MUST be increased by the client,
otherwise the request will not be accepted.

`allowed_key_list`: a list of `access_token` encrypted with the AES key
generated by Diffie–Hellman between the publisher and the allowed contact.

`blocked_chat_list`: a list of `SHA2-256` hashes of chat ids.
Any chat id in this list will not trigger a notification.

`unregister`: whether the account should be unregistered.

`grant`: the grant for this specific server.

`allow_from_contacts_only`: whether the client only wants
push notifications from contacts.

`apn_topic`: the APN topic for the push notification.

`block_mentions`: whether the client does not want to be notified on mentions.

`allowed_mentions_chat_list`: a list of SHA2-256 hashes of chat ids
where we want to receive mentions.

DATA DISCLOSED

- Type of device owned by a given user.

- The `FIREBASE` or `APN` push notification token,

- Hash of the `chat_id` a user is not interested in for notifications,

- The number of times a push notification record has been modified by the user,

- The number of contacts a client has, in case `allowed_key_list` is set.

#### PushNotificationRegistrationResponse

`success`: whether the registration was successful

`error`: the error type, if any

`request_id`: the `SHAKE-256` hash of the `signature` of the request

`preferences`: the server stored preferences in case of an error

#### ContactCodeAdvertisement

`push_notification_info`: the information for each device advertised

DATA DISCLOSED

- The chat key of the sender

#### PushNotificationQuery

`public_keys`: the `SHAKE-256` of the public keys the client is interested in

DATA DISCLOSED

- The hash of the public keys the client is interested in

#### PushNotificationQueryInfo

`access_token`: the access token used to send a push notification

`installation_id`: the `installation_id` of the device associated with the `access_token`.

`public_key`: the `SHAKE-256` of the public key associated with this `access_token`
and `installation_id`.

`allowed_key_list`: a list of encrypted access tokens to be returned
to the client in case there’s any filtering on public keys in place.

`grant`: the grant used to register with this server.

`version`: the version of the registration on the server.

`server_public_key`: the compressed public key of the server.

#### PushNotificationQueryResponse

`info`: a list of `PushNotificationQueryInfo`.

`message_id`: the message id of the `PushNotificationQueryInfo`
the server is replying to.

`success`: whether the query was successful.

#### PushNotification

`access_token`: the access token used to send a push notification.
`chat_id`: the `SHAKE-256` of the `chat_id`.
`public_key`: the `SHAKE-256` of the compressed public key of the receiving client.
`installation_id`: the `installation_id` of the receiving client.
`message`: the encrypted message that is being notified on.
`type`: the type of the push notification, either `MESSAGE` or `MENTION`
`author`: the `SHAKE-256` of the public key of the sender

Data disclosed

- The `SHAKE-256` hash of the `chat_id` the notification is to be sent for

- The cypher text of the message

- The `SHAKE-256` hash of the public key of the sender

- The type of notification

#### PushNotificationRequest

`requests`: a list of PushNotification
`message_id`: the [Status message id](../62/payloads.md)

Data disclosed

- The status `message_id` for which the notification is for

#### PushNotificationResponse

`message_id`: the `message_id` being notified on.
`reports`: a list of `PushNotificationReport`

#### PushNotificationReport

`success`: whether the push notification was successful.
`error`: the type of the error in case of failure.
`public_key`: the public key of the user being notified.
`installation_id`: the `installation_id` of the user being notified.

### Anonymous Mode

In order to preserve privacy, the client MAY provide anonymous mode of operations
to propagate information about the user.
A client in anonymous mode can register with the server
using a key that is different from their chat key.
This will hide their real chat key. This public key is effectively a secret and
SHOULD only be disclosed to clients approved to notify a user.

- A client MAY advertise the access token on the
[contact-code topic](../../../messaging/standards/application/53/x3dh.md)
of the key generated.

- A client MAY share their public key contact updates in the
[protobuf record](https://developers.google.com/protocol-buffers/).

- A client receiving a push notification public key
SHOULD listen to the contact code topic of the push notification public key for updates.

The method described above effectively does not share the identity of the sender
nor the receiver to the server, but
MAY result in missing push notifications
as the propagation of the secret is left to the client.
This can be mitigated by [device syncing](../62/payloads.md),
but not completely addressed.

## Security/Privacy Considerations

If anonymous mode is not used,
when registering with a push notification service a client will disclose:

- The devices that will receive notifications.

- The chat key.

A client MAY disclose:

- The hash of the `chat_id` they want to filter out.

When running in anonymous mode, the client’s chat key is not disclosed.

When querying a push notification server a client will disclose:

- That it is interested in sending push notification to another client,
but querying client’s chat key is not disclosed.

When sending a push notification a client will disclose:

- The `shake-256` of the `chat_id`.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [PUSH-NOTIFICATION-SERVER, Initial Specification](https://github.com/status-im/specs/blob/master/docs/raw/push-notification-server.md)
2. [Push Notification, Apple Developer](https://developer.apple.com/library/archive/documentation/NetworkingInternet/Conceptual/RemoteNotificationsPG/APNSOverview.html#//apple_ref/doc/uid/TP40008194-CH8-SW1)
3. [Firebase](https://firebase.google.com)
4. [13/WAKU2-STORE](../../../messaging/standards/core/13/store.md)
5. [gorush](https://github.com/appleboy/gorush)
6. [54/WAKU2-X3DH-SESSIONS](../../../messaging/standards/application/54/x3dh-sessions.md)
7. [62/PAYLOAD](../62/payloads.md)
8. [SHAKE-256](https://nvlpubs.nist.gov/nistpubs/fips/nist.fips.202.pdf)
9. [Protocol Buffers](https://developers.google.com/protocol-buffers)
10. [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md)
