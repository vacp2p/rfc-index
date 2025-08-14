---
title: ETH-MLS-OFFCHAIN
name: Secure channel setup using decentralized MLS and Ethereum accounts
status: raw
category: Standards Track
tags:
editor: Ugur Sen [ugur@status.im](mailto:ugur@status.im)
contributors: seemenkina [ekaterina@status.im](mailto:ekaterina@status.im)

---

## Abstract

The following document specifies Ethereum authenticated scalable
and decentralized secure group messaging application by
integrating Message Layer Security (MLS) backend.
Decentralization refers each user is a node in P2P network and
each user has voice for any changes in group.
This is achieved by integrating a consensus mechanism.
Lastly, this RFC MAY also be referred to as de-MLS,
short for decentralized MLS, to emphasize its deviation
from the centralized trust assumptions of traditional MLS deployments.

## Motivation

Group messaging is a fundamental part of digital communication,
yet most existing systems depend on centralized servers,
which introduce risks around privacy, censorship, and unilateral control.
In restrictive settings, servers can be blocked or surveilled;
in more open environments, users still face opaque moderation policies,
data collection, and exclusion from decision-making processes.
To address this, we propose a decentralized, scalable peer-to-peer
group messaging system where each participant runs a node, contributes
to message propagation, and takes part in governance autonomously.
Group membership changes are decided collectively through a lightweight
partially synchronous, fault-tolerant consensus protocol without a centralized identity.
This design enables truly democratic group communication and is well-suited
for use cases like activist collectives, research collaborations, DAOs, support groups,
and decentralized social platforms.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Assumptions

- The nodes in the P2P network can discover the nodes or they are subscribing same channel in a gossipsub.
- We MAY have non-reliable (silent) nodes.
- We MUST have a consensus that is lightweight, scalable and finalized in a specific time.

## Roles

In this RFC, there are three roles as follows:

- `node`: Nodes are members of network without being in any secure group messaging.
- `member`: Members are special nodes in the secure group messaging who
obtains current group key of secure group messaging.
- `steward`: Stewards are special and transparent members in secure group
messaging who organizes the changes upon the voted-proposals.

## MLS Background

Since the de-MLS consists of MLS backend, the MLS services and components
often used in following specification as it is or modified.

### MLS Services

MLS is operated in two services authentication service (AS) and delivery service (DS).
Authentication service enables group members to authenticate the credentials presented by other group members.
The delivery service routes MLS messages among the nodes or
members in the protocol in the correct order and 
manage the `keyPackage` of the users where the `keyPackage` is the objects
 that provide some public information about a user.

### MLS Objects

Following section presents the MLS objects and components that used in this RFC:

`Epoch`: Fixed time intervals that changes the state that is defined by members,
section 3.4 in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).

`MLS proposal message:` Members MUST receive the proposal message prior to the
corresponding commit message that initiates a new epoch with key changes,
in order to ensure the intended security properties, section 12.1 in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).
In this RFC, the add and remove proposals are used.

`Application message`: This message type used in arbitrary encrypted communication between group members.
This is restricted by [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) as if there is pending proposal,
the application message should be cut.
Note that: Since the MLS is based on servers, this delay between proposal and commit messages are very small.
`Commit message:` After members receive the proposals regarding group changes,
the committer, who may be any member of the group, as specified in  [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/),
generates the necessary key material for the next epoch, including the appropriate welcome messages
for new joiners and new entropy for removed members. In this RFC, the committers only MUST be stewards.

### de-MLS Objects

`Voting proposal message:` Voting proposal messages are different then MLS proposals as voting proposals are basically
the application message in MLS group. Therefore, the steward can collect the proposals without halting the protocol.

## Flow

General flow is as follows:

- A steward initializes a group just once, and then sends out Group Announcements (GA) periodically.

- Meanwhile, each`node`creates and sends their`credential` includes `keyPackage`.
- Each `member`creates `voting proposals` sends them to from MLS group during epoch E.
- Meanwhile, the `steward` collects finalized `voting proposals` from MLS group and converts them into
`MLS proposals`  then sends them with correspondng `commit messages`
- Evantually, with the commit messages, all members starts the next epoch E+1.

## Creating Voting Proposal

A `member` MAY initializes the voting with the proposal payload
which is implemented using [protocol buffers v3](https://protobuf.dev/) as follows:

```protobuf

syntax = "proto3";

message Proposal {
string name = 10;                 // Proposal name
string payload = 11;              // Describes the what is voting fore 
int32 proposal_id = 12;           // Unique identifier of the proposal
bytes proposal_owner = 13;        // Public key of the creator
repeated Vote votes = 14;         // Vote list in the proposal
int32 expected_voters_count = 15; // Maximum number of distinct voters
int32 round = 16;                 // Number of Votes
int64 timestamp = 17;             // Creation time of proposal
int64 expiration_time = 18;       // Time interval that the proposal is active
bool liveness_criteria_yes = 19;  // Shows how managing the silent peers vote
}
```

```bash
message Vote {
int32 vote_id = 20;             // Unique identifier of the vote
bytes vote_owner = 21;          // Voter's public key
int64 timestamp = 22;           // Time when the vote was cast
bool vote = 23;                 // Vote bool value (true/false)
bytes parent_hash = 24;         // Hash of previous owner's Vote
bytes received_hash = 25;       // Hash of previous received Vote
bytes vote_hash = 26;           // Hash of all previously defined fields in Vote
bytes signature = 27;           // Signature of vote_hash
}
```

After the member creates the voting proposal that may include adding or removing a node or member,
the voting proposal is emitted to the network via the MLS `Application message` with a lightweight,

epoch based voting such as [hashgraphlike consensus.](https://github.com/vacp2p/rfc-index/blob/consensus-hashgraph-like/vac/raw/consensus-hashgraphlike.md)
This consensus result MUST be finalized within the epoch as YES or NO.

If the voting result is YES, this points out the voting proposal will be converted into
the MLS proposal by the `steward` and following commit message that starts the new epoch.

## Creating welcome message

When a MLS `MLS proposal message` is created by the `steward`,
a `commit message` SHOULD follow,
as in section 12.04 [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) to the members.
In order for the new `member` joining the group to synchronize with the current members
who received the `commit message`,
the `steward` sends a welcome message to the new `member`,
as in section 12.4.3.1. [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).

## Single steward

To naive way to create a decentralized secure group messaging is having a single transparent `steward`
who only applies the changes regarding the result of the voting.

This is mostly similar with the general flow and specified in voting proposal and welcome message creation sections.

1. Each time a single `steward` initializes a group with group parameters with parameters
as in section 8.1. Group Context in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).
2. `steward` creates a group anouncement (GA) according to the previous step and
broadcast it to the all network periodically. GA message is visible in network to all `nodes`.
3. The each `node` who wants to be a member needs to obtain this anouncement and create `credential`
includes `keyPackage` that is specified in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) section 10.
4. The `steward` aggregates all `KeyPackages` utilizes them to provision group additions for new members,
based on the outcome of the voting process.
5. Any `member` start to create `voting proposals` for adding or removing users,
and present them to the voting in the MLS group as an application message.

However, unlimited use of `voting proposals` within the group may be misused by
malicious or overly active members.
Therefore, an application-level constraint can be introduced to limit the number
or frequency of proposals initiated by each member to prevent spam or abuse.
6. Meanwhile, the `steward` collects finalized `voting proposals` with in epoch `E`,
that have received affirmative votes from members via application messages.
Otherwise, the `steward` discards proposals that did not receive a majority of "YES" votes.
Since voting proposals are transmitted as application messages, omitting them does not affect
the protocol’s correctness or consistency.
7. The `steward` converts all approved `voting proposals` into
corresponding `MLS proposals` and `commit message`, and
transmits both in a single operation as in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) section 12.4,
including welcome messages for the new members. Therefore, the `commit message` ends the previous epoch and create new ones.

## Multi stewards

Decentralization has already been achieved in the previous section.
However, to improve availability and ensure censorship resistance,
the single-steward protocol is extended to a multi-steward architecture.
In this design, each epoch is coordinated by a designated steward,
operating under the same protocol as the single-steward model.
Thus, the multi-steward approach primarily defines how steward roles
rotate across epochs while preserving the underlying structure and logic of the original protocol.
Two variants of the multi-steward design are introduced to address different system requirements.

### Multi steward with single consensus

In this model, all group modifications, such as adding or removing members,
must be approved through consensus by all participants,
including the steward assigned for epoch `E`.
A configuration with multiple stewards operating under a shared consensus protocol offers
increased decentralization and stronger protection against censorship.
However, this benefit comes with reduced operational efficiency.
The model is therefore best suited for small groups that value
decentralization and censorship resistance more than performance.

### Multi steward with two consensuses

The two-consensus model offers improved efficiency with a trade-off in decentralization.
In this design, group changes require consensus only among the stewards, rather than all members.
Regular members participate by periodically selecting the stewards but do not take part in each decision.
This structure enables faster coordination since consensus is achieved within a smaller group of stewards.
It is particularly suitable for large user groups, where involving every member in each decision would be impractical.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

### References

- [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/)
- [Hashgraphlike Consensus](https://github.com/vacp2p/rfc-index/blob/consensus-hashgraph-like/vac/raw/consensus-hashgraphlike.md)
- [vacp2p/de-mls](https://github.com/vacp2p/de-mls)
