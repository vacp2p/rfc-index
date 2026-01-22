# 28/STATUS-FEATURING

| Field | Value |
| --- | --- |
| Name | Status community featuring using waku v2 |
| Slug | 28 |
| Status | draft |
| Editor | Szymon Szlachtowicz <szymon.s@ethworks.io> |

<!-- timeline:start -->

## Timeline

- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/28/featuring.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/28/featuring.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/28/featuring.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/28/featuring.md) — ci: add mdBook configuration (#233)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/28/featuring.md) — Fix Files for Linting (#94)
- **2024-02-05** — [`1255162`](https://github.com/vacp2p/rfc-index/blob/1255162d40f33f6a037596174690a9eb4d99c572/status/28/featuring.md) — Update featuring.md
- **2024-01-27** — [`86cafd8`](https://github.com/vacp2p/rfc-index/blob/86cafd8523ee34e6c5aa28a54b22e5a8483ff638/status/28/featuring.md) — Create featuring.md

<!-- timeline:end -->

## Abstract

This specification describes a voting method to feature different active Status Communities.

## Overview

When there is a active community that is seeking new members,
current users of community should be able to feature their community so
that it will be accessible to larger audience.
Status community curation DApp should provide such a tool.

Rules of featuring:
    - Given community can't be featured twice in a row.
    - Only one vote per user per community (single user can vote on multiple communities)
    - Voting will be done off-chain
    - If community hasn't been featured
    votes for given community are still valid for the next 4 weeks

Since voting for featuring is similar to polling solutions proposed
in this spec could be also used for different applications.

### Voting

Voting for featuring will be done through waku v2.

Payload of waku message will be :

```ts
type FeatureVote = {
    voter: string // address of a voter
    sntAmount: BigNumber // amount of snt voted on featuring
    communityPK: string // public key of community
    timestamp: number // timestamp of message, must match timestamp of wakuMessage
    sign: string // cryptographic signature of a transaction (signed fields: voterAddress,sntAmount,communityPK,timestamp)
}
```

timestamp is necessary so that votes can't be reused after 4 week period

### Counting Votes

Votes will be counted by the DApp itself.
DApp will aggregate all the votes in the last 4 weeks and
calculate which communities should be displayed in the Featured tab of DApp.

Rules of counting:
    - When multiple votes from the same address on the same community are encountered
    only the vote with highest timestamp is considered valid.
    - If a community has been featured in a previous week
    it can't be featured in current week.
    - In a current week top 5 (or 10) communities with highest amount of SNT votes
    up to previous Sunday 23:59:59 UTC are considered featured.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
