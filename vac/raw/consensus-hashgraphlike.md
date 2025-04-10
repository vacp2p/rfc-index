---
title: consensus-hashgraphlike
name: Hashgraphlike Consensus Protocol
status: raw
category: Standards Track
tags: 
editor: Ugur Sen <ugur@status.im>
contributors:
---
## Abstract

The following specification covers the scalable, decentralized and
BFT-based consensus mechanism which is based on hashgraph and voting for P2P networks.

## Motivation

Consensus is one of the essential components of decentralization.
In particular, the decentralized group messaging application is used for
binary decision-making to govern the group.
Therefore, each user contributes to the decision-making process.
Besides achieving decentralization, the consensus mechanism MUST be strong:
under the assumption of at least 2/3 honest users in the network,
each user MUST conclude the same decision and scalability:
the rounds MUST be growth logarithmic so as not to lose the scalability of the messaging applications.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Flow

Any user in the group initializes the consensus by creating a template that
consists of the proposal without any registration phase.
Next, the user broadcasts the template to the whole network.
Upon each user receives the template, validates the proposal,
adds its vote as yes or no and with its signature and timestamp.
Then this user sends the vote to the random node in the network or subscribing channel.
Therefore, each user first validates the signature and then adds its new vote.
Each sending message counts as a round after log(n) rounds all users in the network
have the others vote if at least 2/3 number of users are honest where honesty follows the protocol.

In general, the voting-based consensus consists of the following phases:

1. Initialization of voting
2. Exchanging votes across the rounds
3. Counting the votes

### Assumptions

- The users in the P2P network can discover the nodes or they are subscribing same channel in a gossipsub.
- Require 1-1 communication, especially for verifying signatures.
- We MAY have non-reliable (silent) nodes.
- Proposal owners MUST know the number of voters.

## 1. Initialization of voting

A user initializes the voting with the proposal payload which is
implemented using [protocol buffers v3](https://protobuf.dev/) as follows:

```bash
syntax = "proto3";

package vac.voting;

message Proposal {
  string name = 10;                 // Proposal name
  int32 proposal_id = 11;           // Unique identifier of the proposal
  bytes proposal_owner = 12;        // Public key of the creator 
  repeated Votes = 13;              // Accumulated votes in the proposal
  int32 expected_voters_count = 14; // maximum number of possible voters
}

message Vote {
  int32 vote_id = 20;             // Unique identifier of the vote
  bytes vote_owner = 11;          // Voter's public key
  int64 timestamp = 22;           // Time when the vote was cast
  bool vote = 23;                 // Vote bool value (true/false)
  bytes parent_hash = 24;         // Hash of previous owner's Vote
  bytes received_hash = 25;       // Hash of previous received Vote
  bytes vote_hash 26 =            // hash of Vote hash(vote_id, owner, timestamp, 
  vote, parent_hash, received_hash)
  bytes signature = 27;           // Signature of hash Sign (hash)
}

```

In particular, to initialize a consensus for a proposal,
a user MUST fulfill all the fields in the proposal including attaching its vote.
In particular, parent_hash and received_hash are zero since there is no previous or received hash.
Then the initialization section ends when the user who creates the proposal sends it
to the random peer from the network or sends it to the proposal to the specific channel.

## 2. Exchanging votes across the peers

Once the peer receives the proposal message P_1 with its votes does the following checks:

- Check the signatures of the voting(should it be the recursive from the first one to the last one)
- Check the hash checks in particular:
  - Parenthash check prevents double voting
  - Receivedhash check provides tampering attacks

In particular, proposal message P_1 where its vote V_1 = P_1.votes[0] and performs as follows:

- Verifies the vote V_1.signature with with the V_1.vote_owner in the proposal.
- If the peer verifies the signature,
it continues to create P_2 with the new vote V_2 that consists of as following:
  - adding its public key
  - timestamp
  - boolean vote
  - V_2.parent_hash = 0 if there is no previous peer's vote, otherwise Hash of previous owner's vote
  - V_2.received_hash = P_1.votes[0]
  - Calculates vote_hash by  hash of Vote hash(vote_id, owner, timestamp, vote, parent_hash, received_hash)
    then adds the V_2.vote_hash
  - Sign vote_hash with its private key then adds V_2.vote_hash.
- Create P_2 with by adding V_2 as follows:
  - P_2.name, P_2.proposal_id and P_2.proposal_owner are the same with P_1.
  - Add the V_2 to the P_2.Votes list.
  - Increase the voting_round by one.

After the peer creates the proposal P_2 with its vote V_2,
sends it to the random peer from the network or
sends it to the proposal to the specific channel.

## 3. Determining the Result

Since a peer cannot know if the votes are enough for the consensus without counting,
it requires checking each time by the peers.
The voting result is set YES if the majority of the 2n/3 from the distinct peers vote YES.

To check the findDistintVoter method takes the proposal and extracts the number of distinct voters by
traversing the accumulated Votes in the proposal.
If this method returns true, then we check the strong validation of the vote as follows:

- Check each signature in the vote
  - as shown in the section Exchanging votes across the peers.
- check the parent hash chain
  - if there are multiple votes from the same owner namely vote_i and vote_i+1 respectively,
    the parent hash of vote_i+1 should be the hash of vote_i
- check the previous hash chain
  - each received hash of vote_i+1 should be equal to the hash of vote_i.
- Check the timestamp against the replay attack:
  - timestamps check the freshness of the message against the replay.
    In particular, the timestamp cannot be the old in the determined threshold.

If a proposal is verified by all the checks,
the countVote method counts each YES vote from the accumulated Votes.
If the YES votes are greater than the n/2, the result is YES.
The peer calculates the result and broadcasts it.
Otherwise, the voting MUST be continued.

## Security

This RFC uses cryptographic primitives to prevent the
malicious behaviours as follows:

- Vote forgery attempt: creating unsigned invalid votes
- Inconsistent voting: both yes and no voting in different stages.
- Integrity breaking attempt: tampering history by changing previous votes.
- Replay attack: storing the old votes to maliciously use in fresh voting.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

## References

* [Hedera Hashgraph](https://hedera.com/learning/hedera-hashgraph/what-is-hashgraph-consensus)
* [Gossip about gossip](https://docs.hedera.com/hedera/core-concepts/hashgraph-consensus-algorithms/gossip-about-gossip)
* [Simple implementation of hashgraph consensus](https://github.com/conanwu777/hashgraph)