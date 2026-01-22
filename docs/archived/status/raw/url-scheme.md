# STATUS-URL-SCHEME

| Field | Value |
| --- | --- |
| Name | Status URL Scheme |
| Slug | 114 |
| Status | raw |
| Category | Standards Track |
| Editor | Felicio Mununga <felicio@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/raw/url-scheme.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`f01d5b9`](https://github.com/vacp2p/rfc-index/blob/f01d5b9d9f2ef977b8c089d616991b24f2ee4efe/docs/archived/status/raw/url-scheme.md) — chore: fix links (#260)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/raw/url-scheme.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/raw/url-scheme.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/raw/url-scheme.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/raw/url-scheme.md) — ci: add mdBook configuration (#233)
- **2024-09-17** — [`a519e67`](https://github.com/vacp2p/rfc-index/blob/a519e677527d7f66e9df1af94b8b5dd129877e67/status/raw/url-scheme.md) — Move Status-URL-scheme (#98)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/vac/raw/url-scheme.md) — Fix Files for Linting (#94)
- **2024-06-21** — [`89cac77`](https://github.com/vacp2p/rfc-index/blob/89cac77ae4a5fa88142f0a01185eff383b60ef09/vac/raw/url-scheme.md) — feat(60/STATUS-URL-SCHEME): initial draft (#14)

<!-- timeline:end -->

## Abstract

This document describes URL scheme for previewing and
deep linking content as well as for triggering actions.

## Background / Rationale / Motivation

### Requirements

#### Related scope

##### Features

- Onboarding website
- Link preview
- Link sharing
- Deep linking
- Routing and navigation
- Payment requests
- Chat creation

## Wire Format Specification / Syntax

### Schemes

- Internal `status-app://`
- External `https://` (i.e. univers/deep links)

### Paths

| Name | Url | Description |
| ----- | ---- | ---- |
| User profile | `/u/<encoded_data>#<user_chat_key>` | Preview/Open user profile |
| | `/u#<user_chat_key>` | |
| | `/u#<ens_name>` | |
| Community | `/c/<encoded_data>#<community_chat_key>` | Preview/Open community |
| | `/c#<community_chat_key>` | |
| Community channel | `/cc/<encoded_data>#<community_chat_key >`| Preview/Open community channel |
| | `/cc/<channel_uuid>#<community_chat_key>` | |

<!-- # Security/Privacy Considerations

A standard track RFC in `stable` status MUST feature this section.
A standard track RFC in `raw` or `draft` status SHOULD feature this section.
Informational LIPs (in any state) may feature this section.
If there are none, this section MUST explicitly state that fact.
This section MAY contain additional relevant information,
e.g. an explanation as to why there are no security consideration
for the respective document. -->

## Discussions

- See <https://github.com/status-im/specs/pull/159>
- See <https://github.com/status-im/status-web/issues/327>

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [STATUS-URL-DATA](url-data.md)
