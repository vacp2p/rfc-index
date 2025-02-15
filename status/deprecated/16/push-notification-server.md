---
title: PUSH-NOTIFICATION-SERVER
name: Push notification server
status: deprecated
description: Status provides a set of Push notification services that can be used to achieve this functionality.
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Andrea Maria Piana <andreap@status.im>
---

## Reason

Push notifications for iOS and some Android devices rely on centralized services
like APN for iOS or Firebase.
Android devices lacking foreground service support
or killing such services frequently benefit from these services.
iOS only allows certain app types, like VoIP,
to keep connections open in the background,  
which Status does not qualify for.
Background execution on iOS is limited and unreliable for push notifications.

Since a privacy-preserving implementation is challenging,
Status enables push notifications only as an opt-in feature, disabled by default.

## Requirements

The party releasing the app **must** possess an Apple Push Notification certificate
and maintain a publicly accessible Gorush server for notifications.
Status runs its own Gorush instance.

### Components

- **Gorush Instance**: Publicly available for push notifications only.
- **Push Notification Server**: Handles client registration for push notifications.
- **Registering Client**: A Status client that registers to receive notifications.
- **Sending Client**: A Status client that initiates notifications.

## Registering with Push Notification Service

Clients **may** register with one or more push notification services.  
They must send a PNR (Push Notification Registration) message
to a partitioned topic for their public key,
encrypted with AES-GCM using a Diffie–Hellman key derived from client
and server identities.  
The registration payload must follow this format:

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

### Server Requirements

A push notification server **must** validate the registration
and respond with errors if the message is malformed,
has unsupported tokens, or contains empty fields.
Successful responses contain `success = true`.

## Query Topic

On successful registration, the server listens on a topic derived from:

0XHexEncode(Shake256(CompressedClientPublicKey))

## Server Grant

Push notification servers demonstrate authorization via a grant specific  
to the client-server pair:

```Signature(Keccak256(CompressedClientPublicKey . CompressedServerPublicKey .
AccessToken), ClientPrivateKey)```

## Re-registering and Unregistering

Clients **should** re-register when tokens change, ensuring the latest  
PushNotificationRegistration is available and advertising changes.  
To unregister, clients set `unregister = true` in the request.

## Advertising Push Notification Servers

Clients **should** periodically advertise the push notification services  
they registered with for each device. This is done using `PushNotificationQueryInfo`
messages wrapped in `ApplicationMetadataMessage`.

## Discovering Push Notification Servers

Clients discover push notification servers by listening to contact code topics  
or querying mail servers for the latest contact codes.

## Querying the Push Notification Server

If a token is absent in advertisements, clients **should** query the server directly:

```protobuf
message PushNotificationQuery {
  repeated bytes public_keys = 1;
}
```

### Query Response

Servers respond with a `PushNotificationQueryResponse` message containing:

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
```

Clients verify grants to ensure authorized push notifications.

## Sending a Push Notification

Clients send a notification targeting specific installation IDs, using this format:

```protobuf
message PushNotification {
  string access_token = 1;
  string chat_id = 2;
  bytes public_key = 3;
  string installation_id = 4;
  bytes message = 5;
  PushNotificationType type = 6;
  bytes author = 7;
}
```

Servers validate the `access_token` and, if valid, send the notification  
to Gorush, following Gorush’s data structure.

## Security Considerations

For standard operations, registering with a push notification service discloses:

1. Chat key
2. Devices receiving notifications
3. Any filtered chat IDs

In anonymous mode, chat keys are not disclosed.

## Changelog

**Version 0.1**: Initial Release

## Copyright

Copyright and related rights waived via CC0.
