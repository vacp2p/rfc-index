# STATUS-MVDS-USAGE

| Field | Value |
| --- | --- |
| Name | MVDS Usage in Status |
| Slug | 116 |
| Status | raw |
| Category | Best Current Practice |
| Editor | Kaichao Sun <kaichao@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/raw/status-mvds.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/raw/status-mvds.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/raw/status-mvds.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/raw/status-mvds.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/raw/status-mvds.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/raw/status-mvds.md) — ci: add mdBook configuration (#233)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/raw/status-mvds.md) — Fix Files for Linting (#94)
- **2024-08-21** — [`751a01e`](https://github.com/vacp2p/rfc-index/blob/751a01ece441d0fa4265c4deb0ff7f106dd8244f/status/raw/status-mvds.md) — feat: status mvds usage (#87)

<!-- timeline:end -->

## Abstract

This document lists the types of messages that are using [MVDS](/ift-ts/raw/2/mvds.md)
in the Status application.

## Background

Status app uses MVDS to ensure messages going through Waku
are acknolwedged by the recipient.
This is to ensure that the messages are not missed by any interested parties.

## Message types

Various Message Types contain distinct information defined by the app
to facilitate convenient serialization and deserialization.

E2E reliability is a feature that ensures messages are delivered to the recipient.
This is initially achieved by using MVDS in Status.

Chat Type specifies the category of chat that a message belongs to.
It can be OneToOne (aka Direct Message), GroupChat, or CommunityChat.
These are the three main types of chats in Status.

| Message Type                                                               | Use MVDS                            | Need e2e reliability | Chat Type               |
|----------------------------------------------------------------------------|-------------------------------------|----------------------|-------------------------|
| ApplicationMetadataMessage_UNKNOWN                                         | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_CHAT_MESSAGE                                    | Yes for OneToOne & PrivateGroupChat | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_CONTACT_UPDATE                                  | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_MEMBERSHIP_UPDATE_MESSAGE                       | No                                  | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_SYNC_PAIR_INSTALLATION                          | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_DEPRECATED_SYNC_INSTALLATION                    | No                                  | No                   | Pair                    |
| ApplicationMetadataMessage_REQUEST_ADDRESS_FOR_TRANSACTION                 | Yes for OneToOne                    | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_ACCEPT_REQUEST_ADDRESS_FOR_TRANSACTION          | Yes for OneToOne                    | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_DECLINE_REQUEST_ADDRESS_FOR_TRANSACTION         | Yes for OneToOne                    | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_REQUEST_TRANSACTION                             | Yes for OneToOne                    | Yes                  | OneToOne & GroupChat    |
| ApplicationMetadataMessage_SEND_TRANSACTION                                | Yes for OneToOne                    | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_DECLINE_REQUEST_TRANSACTION                     | Yes for OneToOne                    | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_SYNC_INSTALLATION_CONTACT_V2                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_INSTALLATION_ACCOUNT                       | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_CONTACT_CODE_ADVERTISEMENT                      | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_REGISTRATION                  | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_REGISTRATION_RESPONSE         | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_QUERY                         | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_QUERY_RESPONSE                | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_REQUEST                       | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_PUSH_NOTIFICATION_RESPONSE                      | No                                  | No                   | One & Group & Community |
| ApplicationMetadataMessage_EMOJI_REACTION                                  | No                                  | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_GROUP_CHAT_INVITATION                           | Yes                                 | Yes                  | GroupChat               |
| ApplicationMetadataMessage_CHAT_IDENTITY                                   | No                                  | No                   | OneToOne                |
| ApplicationMetadataMessage_COMMUNITY_DESCRIPTION                           | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_INVITATION                            | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_REQUEST_TO_JOIN                       | No                                  | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_PIN_MESSAGE                                     | Yes for OneToOne & PrivateGroupChat | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_EDIT_MESSAGE                                    | Yes for OneToOne & PrivateGroupChat | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_STATUS_UPDATE                                   | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_DELETE_MESSAGE                                  | Yes for OneToOne & PrivateGroupChat | Yes                  | One & Group & Community |
| ApplicationMetadataMessage_SYNC_INSTALLATION_COMMUNITY                     | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_ANONYMOUS_METRIC_BATCH                          | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_SYNC_CHAT_REMOVED                               | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_CHAT_MESSAGES_READ                         | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_BACKUP                                          | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_READ                       | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_ACCEPTED                   | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_DISMISSED                  | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_BOOKMARK                                   | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_CLEAR_HISTORY                              | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_SETTING                                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_MESSAGE_ARCHIVE_MAGNETLINK            | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_SYNC_PROFILE_PICTURES                           | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACCOUNT                                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_ACCEPT_CONTACT_REQUEST                          | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_RETRACT_CONTACT_REQUEST                         | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_COMMUNITY_REQUEST_TO_JOIN_RESPONSE              | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_SYNC_COMMUNITY_SETTINGS                         | Yes                                 | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_REQUEST_CONTACT_VERIFICATION                    | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_ACCEPT_CONTACT_VERIFICATION                     | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_DECLINE_CONTACT_VERIFICATION                    | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_SYNC_TRUSTED_USER                               | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_VERIFICATION_REQUEST                       | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_CONTACT_REQUEST_DECISION                   | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_REQUEST_TO_LEAVE                      | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_SYNC_DELETE_FOR_ME_MESSAGE                      | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_SAVED_ADDRESS                              | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_CANCEL_REQUEST_TO_JOIN                | No                                  | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_CANCEL_CONTACT_VERIFICATION                     | Yes                                 | Yes                  | OneToOne                |
| ApplicationMetadataMessage_SYNC_KEYPAIR                                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_SOCIAL_LINKS                               | No                                  | No                   | Not Applied             |
| ApplicationMetadataMessage_SYNC_ENS_USERNAME_DETAIL                        | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_EVENTS_MESSAGE                        | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_EDIT_SHARED_ADDRESSES                 | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_SYNC_ACCOUNT_CUSTOMIZATION_COLOR                | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACCOUNTS_POSITIONS                         | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_PRIVILEGED_USER_SYNC_MESSAGE          | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_SHARD_KEY                             | Yes                                 | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_SYNC_CHAT                                       | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_DELETED                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_UNREAD                     | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_ACTIVITY_CENTER_COMMUNITY_REQUEST_DECISION | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_SYNC_TOKEN_PREFERENCES                          | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_PUBLIC_SHARD_INFO                     | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_SYNC_COLLECTIBLE_PREFERENCES                    | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_USER_KICKED                           | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_SYNC_PROFILE_SHOWCASE_PREFERENCES               | Yes                                 | Yes                  | Pair                    |
| ApplicationMetadataMessage_COMMUNITY_PUBLIC_STORENODES_INFO                | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_REEVALUATE_PERMISSIONS_REQUEST        | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_DELETE_COMMUNITY_MEMBER_MESSAGES                | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_UPDATE_GRANT                          | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_ENCRYPTION_KEYS_REQUEST               | No                                  | Yes                  | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_TOKEN_ACTION                          | No                                  | Weak Yes             | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_SHARED_ADDRESSES_REQUEST              | No                                  | No                   | CommunityChat           |
| ApplicationMetadataMessage_COMMUNITY_SHARED_ADDRESSES_RESPONSE             | No                                  | No                   | CommunityChat           |

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [MVDS](/ift-ts/raw/2/mvds.md)
