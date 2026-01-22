# STATUS-URL-DATA

| Field | Value |
| --- | --- |
| Name | Status URL Data |
| Slug | 112 |
| Status | raw |
| Category | Standards Track |
| Editor | Felicio Mununga <felicio@status.im> |
| Contributors | Aaryamann Challani <aaryamann@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/raw/url-data.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/raw/url-data.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/raw/url-data.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/raw/url-data.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/raw/url-data.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/raw/url-data.md) — ci: add mdBook configuration (#233)
- **2024-11-20** — [`ff87c84`](https://github.com/vacp2p/rfc-index/blob/ff87c84dc71d4f933bab188993914069fea12baa/status/raw/url-data.md) — Update Waku Links (#104)
- **2024-09-17** — [`36f64f0`](https://github.com/vacp2p/rfc-index/blob/36f64f01f0979412fcbdf0c89143ef39442b7675/status/raw/url-data.md) — feat(59/STATUS-URL-DATA): initial draft (#13)

<!-- timeline:end -->

## Abstract

This document specifies serialization, compression, and
encoding techniques used to transmit data within URLs in the context of Status protocols.

## Motivation

When sharing URLs,
link previews often expose metadata to the websites behind those links.
To reduce reliance on external servers for providing appropriate link previews,
this specification proposes a standard method for encoding data within URLs.

## Terminology

- Community: Refer to [STATUS-COMMUNITIES](../56/communities.md)
- Channel: Refer to terminology in [STATUS-COMMUNITIES](../56/communities.md)
- User: Refer to terminology in [STATUS-COMMUNITIES](../56/communities.md)
- Shard Refer to terminology in [WAKU2-RELAY-SHARDING](https://github.com/waku-org/specs/blob/master/standards/core/relay-sharding.md)

## Wire Format

```protobuf
syntax = "proto3";

message Community {
    // Display name of the community
    string display_name = 1;
    // Description of the community
    string description = 2;
    // Number of members in the community
    uint32 members_count = 3;
    // Color of the community title
    string color = 4;
    // List of tag indices
    repeated uint32 tag_indices = 5;
}

message Channel {
    // Display name of the channel
    string display_name = 1;
    // Description of the channel
    string description = 2;
    // Emoji of the channel
    string emoji = 3;
    // Color of the channel title
    string color = 4;
    // Community the channel belongs to
    Community community = 5;
    // UUID of the channel
    string uuid = 6;
}

message User {
    // Display name of the user
    string display_name = 1;
    // Description of the user
    string description = 2;
    // Color of the user title
    string color = 3;
}

message URLData {
    // Community, Channel, or User
    bytes content = 1;
    uint32 shard_cluster = 2;
    uint32 shard_index = 3;
}
```

## Implementation

The above wire format describes the data encoded in the URL.
The data MUST be serialized, compressed, and encoded using the following standards:

Encoding

- [Base64url](https://datatracker.ietf.org/doc/html/rfc4648)

### Compression

- [Brotli](https://datatracker.ietf.org/doc/html/rfc7932)

### Serialization

- [Protocol buffers version 3](https://protobuf.dev/reference/protobuf/proto3-spec/)

### Implementation Pseudocode

Encoding

Encoding the URL MUST be done in the following order:

```protobuf
raw_data = {User | Channel | Community}
serialized_data = protobuf_serialize(raw_data)
compressed_data = brotli_compress(serialized_data)
encoded_url_data = base64url_encode(compressed_data)
```

The `encoded_url_data` is then used to generate a signature using the private key.

#### Decoding

Decoding the URL MUST be done in the following order:

```protobuf
url_data = base64url_decode(encoded_url_data)
decompressed_data = brotli_decompress(url_data)
deserialized_data = protobuf_deserialize(decompressed_data)
raw_data = deserialized_data.content
```

The `raw_data` is then used to construct the appropriate data structure
(User, Channel, or Community).

### Example

- See <https://github.com/status-im/status-web/pull/345/files>

<!-- # (Further Optional Sections) -->

## Discussions

- See <https://github.com/status-im/status-web/issues/327>

## Proof of concept

- See <https://github.com/felicio/status-web/blob/825262c4f07a68501478116c7382862607a5544e/packages/status-js/src/utils/encode-url-data.compare.test.ts#L4>

<!-- # Security Considerations -->

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [Proposal Google Sheet](https://docs.google.com/spreadsheets/d/1JD4kp0aUm90piUZ7FgM_c2NGe2PdN8BFB11wmt5UZIY/edit?usp=sharing)
2. [Base64url](https://datatracker.ietf.org/doc/html/rfc4648)
3. [Brotli](https://datatracker.ietf.org/doc/html/rfc7932)
4. [Protocol buffers version 3](https://protobuf.dev/reference/protobuf/proto3-spec/)
5. [STATUS-URL-SCHEME](url-scheme.md)

<!-- ## informative

A list of additional references. -->
