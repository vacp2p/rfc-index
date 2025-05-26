---
title: consensus-hashgraphlike
name: Hashgraphlike Consensus Protocol
status: raw
category: Standards Track
tags: 
editor: Ugur Sen <ugur@status.im> 
contributors: Seemenkina <ekaterina@status.im>
---
## Abstract

This document specifies a scalable, decentralized, and Byzantine Fault Tolerant (BFT)
consensus mechanism inspired by Hashgraph, designed for binary decision-making in P2P networks.

## Motivation

Consensus is one of the essential components of decentralization.
In particular, in the decentralized group messaging application is used for

binary decision-making to govern the group.
Therefore, each user contributes to the decision-making process.
Besides achieving decentralization, the consensus mechanism MUST be strong:
under the assumption of at least 2/3 honest users in the network,
each user MUST conclude the same decision and scalability:
message propagation in the network MUST occur within O(log n) rounds, where n is the total number of peers, in order to preserve the scalability of the messaging application.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

## Flow

Any user in the group initializes the consensus by creating a proposal.
Next, the user broadcasts the proposal to the whole network.
Upon each user receives the proposal, validates the proposal,
adds its vote as yes or no and with its signature and timestamp.
Then this user sends the vote to the random node in the network or subscribing channel.
Therefore, each user first validates the signature and then adds its new vote.
Each sending message counts as a round.
After log(n) rounds all users in the network have the others vote
if at least 2/3 number of users are honest where honesty follows the protocol.

In general, the voting-based consensus consists of the following phases:

1. Initialization of voting
2. Exchanging votes across the rounds
3. Counting the votes

### Assumptions

- The users in the P2P network can discover the nodes or they are subscribing same channel in a gossipsub.
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
  repeated Votes = 13;              // Vote list in the proposal
  int32 expected_voters_count = 14; // Maximum number of distinct voters
  int32 round = 15;                 // Number of Votes 
  int64 timestamp = 16;             // Creation time of proposal
  int64 expiration_time = 17;       // The time interval that the proposal is active.  
  bool liveness_criteria_yes = 18;       // Shows how managing the silent peers vote
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

To initiate a consensus for a proposal,
a user MUST complete all the fields in the proposal, including attaching its vote.
Notably, `parent_hash` and `received_hash` are empty strings because there is no previous or received hash.
Then the initialization section ends when the user who creates the proposal sends it
to the random peer from the network or sends it to the proposal to the specific channel.

## 2. Exchanging votes across the peers

Once the peer receives the proposal message P_1 from a 1-1 or a gossipsub channel does the following checks:

- Check the signatures of the each votes in proposal, in particular for proposal P_1,
verify the signature of V_1 where V_1 = P_1.votes[0] with V_1.signature and V_1.vote_owner
- Do `parent_hash` check: If there are repeated votes from the same sender,
check that the hash of the former vote is equal to the `parent_hash` of the later vote.
- Do `received_hash` check: If there are multiple votes in a proposal, check that the hash of a vote is equal to the `received_hash` of the next one.
- If the receiver peer verifies the signature, and hashes
it continues to create P_2 with the new vote V_2 that consists of as following:
  - adding its public key as P_2.vote_owner
  - timestamp
  - boolean vote
  - V_2.parent_hash = 0 if there is no previous peer's vote, otherwise hash of previous owner's vote
  - V_2.received_hash = hash(P_1.votes[0])

  - Calculate vote_hash by  hash of Vote hash(vote_id, owner, timestamp, vote, parent_hash, received_hash)
    then adds the V_2.vote_hash
  - Sign vote_hash with its private key corresponding the public key as vote_owner component then adds V_2.vote_hash.
- Create P_2 with by adding V_2 as follows:
  - P_2.name, P_2.proposal_id and P_2.proposal_owner are the same with P_1.
  - Add the V_2 to the P_2.Votes list.
  - Increase the round by one, namely P_2.round = P_1.round + 1.
  - Verify the time proposal timestamp is valid for expiration time, namely P_2.timestamp - current < P_1.expiration_time.
  If this does not hold, other peers ignore the message.

After the peer creates the proposal P_2 with its vote V_2,
sends it to the random peer from the network or
sends it to the proposal to the specific channel.

## 3. Determining the result

Because consensus depends on meeting a quorum threshold,
each peer MUST verify the accumulated votes to determine whether the necessary conditions have been satisfied.
The voting result is set YES if the majority of the 2n/3 from the distinct peers vote YES.

To verify, the findDistinctVoter method processes the proposal by traversing its Votes list to determine the number of unique voters.

If this method returns true, the peer proceeds with strong validation,
which ensures that if any honest peer reaches a decision,
no other honest peer can arrive at a conflicting result.

- Check each signature in the vote
  - as shown in the section 2 Exchanging votes across the peers.
- Check the parent hash chain
  - if there are multiple votes from the same owner namely vote_i and vote_i+1 respectively,
    the parent hash of vote_i+1 should be the hash of vote_i
- Check the previous hash chain
  - each received hash of vote_i+1 should be equal to the hash of vote_i.
- Check the timestamp against the replay attack:
  - timestamps check the freshness of the message against the replay.
    In particular, the timestamp cannot be the old in the determined threshold.

If a proposal is verified by all the checks,
the countVote method counts each YES vote from the list of Votes.

## 4. Properties

The consensus mechanism satisfies liveness and security properties as follows:

### Liveness

Liveness refers to the ability of the protocol to eventually reach a decision when sufficient honest participation is present.
In this protocol, if more than n/2 of the votes among at least 2n/3 distinct peers are YES,
then the consensus result is defined as YES.
 The peer calculates the result locally as shown in section3.
 From the [hashgraph property](https://hedera.com/learning/hedera-hashgraph/what-is-hashgraph-consensus),
 if a node could calculate the result of a proposal,
 it implies that no peer can calculate the opposite of the result.
 Still, reliability issues can cause some situations where peers cannot receive enough messages,
 so they cannot calculate the consensus result.

Rounds are incremented when a peer adds and sends the new proposal.
Calculating the required number of rounds, 2n/3 from the distinct peers' votes is achieved in two ways:

1. 2n/3 rounds in pure P2P networks
2. 2 rounds in gossipsub

Since the message complexity is O(1) in the gossipsub channel,
in case the network has reliability issues,
the second round is used for the peers cannot receive all the messages from the first round.

If an honest and online peer has received at least one vote but not enough to reach consensus,
it MAY continue to propagate its own vote — and any votes it has received — to support message dissemination.
This process can continue beyond the expected round count,
as long as it remains within the expiration time defined in the proposal.
The expiration time acts as a soft upper bound to ensure that consensus is either reached or aborted within a bounded timeframe.

### Silent Node Management

Silent nodes are the nodes that not participate the voting as YES or NO.
There are two possible counting votes for the silent peers.

1. Silent peers means YES:
Silent peers counted as YES vote, if the application prefer the strong rejection for NO votes.
2. Silent peers means NO:
Silent peers counted as NO vote, if the application prefer the strong acception for NO votes.

The proposal is set to default true, which means silent peers' votes are counted as YES namely `liveness_criteria_yes` is set true by default.

### Security

This RFC uses cryptographic primitives to prevent the
malicious behaviours as follows:

- Vote forgery attempt: creating unsigned invalid votes
- Inconsistent voting: a malicious peer submits conflicting votes (e.g., YES to some peers and NO to others)
in different stages of the protocol, violating vote consistency and attempting to undermine consensus.
- Integrity breaking attempt: tampering history by changing previous votes.
- Replay attack: storing the old votes to maliciously use in fresh voting.

## 5. Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

## 6. References

- [Hedera Hashgraph](https://hedera.com/learning/hedera-hashgraph/what-is-hashgraph-consensus)
- [Gossip about gossip](https://docs.hedera.com/hedera/core-concepts/hashgraph-consensus-algorithms/gossip-about-gossip)
- [Simple implementation of hashgraph consensus](https://github.com/conanwu777/hashgraph)
