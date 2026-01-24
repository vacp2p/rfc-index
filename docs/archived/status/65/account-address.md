# 65/STATUS-ACCOUNT-ADDRESS

| Field | Value |
| --- | --- |
| Name | Status Account Address |
| Slug | 65 |
| Status | draft |
| Category | Standards Track |
| Editor | Aaryamann Challani <p1ge0nh8er@proton.me> |
| Contributors | Corey Petty <corey@status.im>, Oskar Thorén <oskarth@titanproxy.com>, Samuel Hawksby-Robinson <samuel@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/65/account-address.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/65/account-address.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/65/account-address.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/65/account-address.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/65/account-address.md) — ci: add mdBook configuration (#233)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/65/account-address.md) — Fix Files for Linting (#94)
- **2024-08-05** — [`eb25cd0`](https://github.com/vacp2p/rfc-index/blob/eb25cd06d679e94409072a96841de16a6b3910d5/status/65/account-address.md) — chore: replace email addresses (#86)
- **2024-02-05** — [`67a1221`](https://github.com/vacp2p/rfc-index/blob/67a1221ab0b0b27e3376c389575c77bfa38057de/status/65/account-address.md) — Update account-address.md
- **2024-02-01** — [`91874da`](https://github.com/vacp2p/rfc-index/blob/91874da9b18b40078d4932819b30d271b321ac53/status/65/account-address.md) — Update and rename ACCOUNT-ADDRESS.md to account-address.md
- **2024-01-27** — [`ae04f02`](https://github.com/vacp2p/rfc-index/blob/ae04f026594cf6c4ede40b5d4ba8bb4e3462a447/status/65/ACCOUNT-ADDRESS.md) — Create ACCOUNT-ADDRESS.md

<!-- timeline:end -->

## Abstract

This specification details what a Status account address is and
how account addresses are created and used.

## Background

The core concept of an account in Status is a set of cryptographic keypairs.
Namely, the combination of the following:

1. a Waku chat identity keypair
1. a set of cryptocurrency wallet keypairs

The Status node verifies or
derives everything else associated with the contact from the above items, including:

- Ethereum address (future verification, currently the same base keypair)
- identicon
- message signatures

## Initial Key Generation

### Public/Private Keypairs

- An ECDSA (secp256k1 curve) public/private keypair MUST be generated via a
[BIP43](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
derived path from a
[BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
mnemonic seed phrase.

- The default paths are defined as such:
  - Waku Chat Key (`IK`): `m/43'/60'/1581'/0'/0`  (post Multiaccount integration)
    - following [EIP1581](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1581.md)
  - Status Wallet paths: `m/44'/60'/0'/0/i` starting at `i=0`
    - following [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
    - NOTE: this (`i=0`) is also the current (and only)
    path for Waku key before Multiaccount integration

## Account Broadcasting

- A user is responsible for broadcasting certain information publicly so
that others may contact them.

### X3DH Prekey bundles

- Refer to [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md)
for details on the X3DH prekey bundle broadcasting, as well as regeneration.

## Optional Account additions

### ENS Username

- A user MAY register a public username on the Ethereum Name System (ENS).
This username is a user-chosen subdomain of the `stateofus.eth`
ENS registration that maps to their Waku identity key (`IK`).

### User Profile Picture

- An account MAY edit the `IK` generated identicon with a chosen picture.
This picture will become part of the publicly broadcasted profile of the account.

<!-- TODO: Elaborate on wallet account and multiaccount -->

## Wire Format

Below is the wire format for the account information that is broadcasted publicly.
An Account is referred to as a Multiaccount in the wire format.

```proto
message MultiAccount {
  string name = 1; // name of the account
  int64 timestamp = 2; // timestamp of the message
  string identicon = 3; // base64 encoded identicon
  repeated ColorHash color_hash = 4; // color hash of the identicon
  int64 color_id = 5; // color id of the identicon
  string keycard_pairing = 6; // keycard pairing code
  string key_uid = 7; // unique identifier of the account
  repeated IdentityImage images = 8; // images associated with the account
  string customization_color = 9; // color of the identicon
  uint64 customization_color_clock = 10; // clock of the identicon color, to track updates

  message ColorHash {
    repeated int64 index = 1;
  }

  message IdentityImage {
    string key_uid = 1; // unique identifier of the image
    string name = 2; // name of the image
    bytes payload = 3; // payload of the image
    int64 width = 4; // width of the image
    int64 height = 5; // height of the image
    int64 filesize = 6; // filesize of the image
    int64 resize_target = 7; // resize target of the image
    uint64 clock = 8; // clock of the image, to track updates
  }
}
```

The above payload is broadcasted when 2 devices
that belong to a user need to be paired.

## Security Considerations

- This specification inherits security considerations of
[53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md) and
[54/WAKU2-X3DH-SESSIONS](../../../messaging/standards/application/54/x3dh-sessions.md).

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### normative

- [53/WAKU2-X3DH](../../../messaging/standards/application/53/x3dh.md)
- [54/WAKU2-X3DH-SESSIONS](../../../messaging/standards/application/54/x3dh-sessions.md)
- [55/STATUS-1TO1-CHAT](../55/1to1-chat.md)

## informative

- [BIP43](https://github.com/bitcoin/bips/blob/master/bip-0043.mediawiki)
- [BIP39](https://github.com/bitcoin/bips/blob/master/bip-0039.mediawiki)
- [EIP1581](https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1581.md)
- [BIP44](https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki)
- [Ethereum Name System](https://ens.domains/)
- [Status Multiaccount](../63/keycard-usage.md)
