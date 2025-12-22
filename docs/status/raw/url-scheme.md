# STATUS-URL-SCHEME

<div class="rfc-meta">
<table>
<tr><th>Name</th><td>Status URL Scheme</td></tr>
<tr><th>Status</th><td>raw</td></tr>
<tr><th>Category</th><td>Standards Track</td></tr>
<tr><th>Editor</th><td>Felicio Mununga &lt;felicio@status.im&gt;</td></tr>
</table>
</div>
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
Informational RFCs (in any state) may feature this section.
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

- [STATUS-URL-DATA](./url-data.md)
