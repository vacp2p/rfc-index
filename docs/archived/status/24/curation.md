# 24/STATUS-CURATION

| Field | Value |
| --- | --- |
| Name | Status Community Directory Curation Voting using Waku v2 |
| Slug | 24 |
| Status | draft |
| Editor | Szymon Szlachtowicz <szymon.s@ethworks.io> |

<!-- timeline:start -->

## Timeline

- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/24/curation.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/24/curation.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/24/curation.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/24/curation.md) — ci: add mdBook configuration (#233)
- **2024-09-13** — [`3ab314d`](https://github.com/vacp2p/rfc-index/blob/3ab314d87d4525ff1296bf3d9ec634d570777b91/status/24/curation.md) — Fix Files for Linting (#94)
- **2024-02-05** — [`60fcdd5`](https://github.com/vacp2p/rfc-index/blob/60fcdd5737ad55b4d9da90e09610ffa06fa4032c/status/24/curation.md) — Update curation.md
- **2024-01-27** — [`de29833`](https://github.com/vacp2p/rfc-index/blob/de298338905426f9f2cb0e374e11b789ecc543bf/status/24/curation.md) — Create curation.md

<!-- timeline:end -->

## Abstract

This specification is a voting protocol for peers to submit votes to a smart contract.
Voting is immutable,
this will help avoid sabotage from malicious peers.

## Motivation

In open p2p protocol there is an issue with voting off-chain
as there is much room for malicious peers to only include votes that support
their case when submitting votes to chain.

Proposed solution is to aggregate votes over waku and
allow users to submit votes to smart contract that aren't already submitted.

### Smart contract

Voting should be finalized on chain so that the finished vote is immutable.
Because of that, smart contract needs to be deployed.
When votes are submitted
smart contract has to verify what votes are properly signed and
that sender has correct amount of SNT.
When Vote is verified
the amount of SNT voted on specific topic by specific sender is saved on chain.

### Double voting

Smart contract should also keep a list of all signatures so
that no one can send the same vote twice.
Another possibility is to allow each sender to only vote once.

### Initializing Vote

When someone wants to initialize vote
he has to send a transaction to smart contract that will create a new voting session.
When initializing a user has to specify type of vote (Addition, Deletion),
amount of his initial SNT to submit and public key of community under vote.
Smart contract will return a ID which is identifier of voting session.
Also there will be function on Smart Contract that
when given community public key it will return voting session ID or
undefined if community isn't under vote.

## Voting

### Sending votes

Sending votes is simple every peer is able to send a message to Waku topic
specific to given application:

```json

/status-community-directory-curation-vote/1/{voting-session-id}/json

```

vote object that is sent over waku should contain information about:

```ts
type Vote = {
    sender: string // address of the sender
    vote: string // vote sent eg. 'yes' 'no'
    sntAmount: BigNumber //number of snt cast on vote
    sign: string // cryptographic signature of a transaction (signed fields: sender,vote,sntAmount,nonce,sessionID)
    nonce: number // number of votes cast from this address on current vote 
    // (only if we allow multiple votes from the same sender)
    sessionID: number // ID of voting session
}
```

### Aggregating votes

Every peer that is opening specific voting session
will listen to votes sent over p2p network, and
aggregate them for a single transaction to chain.

### Submitting to chain

Every peer that has aggregated at least one vote
will be able to send them to smart contract.
When someone votes he will aggregate his own vote and
will be able to immediately send it.

Peer doesn't need to vote to be able to submit the votes to the chain.

Smart contract needs to verify that all votes are valid
(eg. all senders had enough SNT, all votes are correctly signed) and
that votes aren't duplicated on smart contract.

### Finalizing

Once the vote deadline has expired, the smart contract will not accept votes anymore.
Also directory will be updated according to vote results
(community added to directory, removed etc.)

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).
