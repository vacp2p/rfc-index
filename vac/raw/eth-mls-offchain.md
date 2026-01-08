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
Lastly, this RFC can also be referred to as de-MLS,
decentralized MLS, to emphasize its deviation
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

- The nodes in the P2P network can discover other nodes or will connect to other nodes when subscribing to same topic in a gossipsub.
- We MAY have non-reliable (silent) nodes.
- We MUST have a consensus that is lightweight, scalable and finalized in a specific time.

## Roles

The three roles used in de-MLS is as follows:

- `node`: Nodes are participants in the network that are not currently members
of any secure group messaging session but remain available as potential candidates for group membership.
- `member`: Members are special nodes in the secure group messaging who
obtains current group key of secure group messaging.
Each node is assigned a unique identity represented as a 20-byte value named `member id`.
- `steward`: Stewards are special and transparent members in the secure group
messaging who organize the changes by releasing commit messages upon the voted proposals.
There are two special subsets of steward as epoch and backup steward,
which are defined in the section de-MLS Objects.

## MLS Background

The de-MLS consists of MLS backend, so the MLS services and other MLS components
are taken from the original [MLS specification](https://datatracker.ietf.org/doc/rfc9420/), with or without modifications.

### MLS Services

MLS is operated in two services authentication service (AS) and delivery service (DS).
Authentication service enables group members to authenticate the credentials presented by other group members.
The delivery service routes MLS messages among the nodes or
members in the protocol in the correct order and
manage the `keyPackage` of the users where the `keyPackage` is the objects
 that provide some public information about a user.

### MLS Objects

Following section presents the MLS objects and components that used in this RFC:

`Epoch`: Time intervals that changes the state that is defined by members,
section 3.4 in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).

`MLS proposal message:` Members MUST receive the proposal message prior to the
corresponding commit message that initiates a new epoch with key changes,
in order to ensure the intended security properties, section 12.1 in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).
Here, the add and remove proposals are used.

`Application message`: This message type used in arbitrary encrypted communication between group members.
This is restricted by [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) as if there is pending proposal,
the application message should be cut.
Note that: Since the MLS is based on servers, this delay between proposal and commit messages are very small.

`Commit message:` After members receive the proposals regarding group changes,
the committer, who may be any member of the group, as specified in  [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/),
generates the necessary key material for the next epoch, including the appropriate welcome messages
for new joiners and new entropy for removed members. In this RFC, the committers only MUST be stewards.

### de-MLS Objects

This section presents the de-MLS objects:

`Voting proposal`: Similar to MLS proposals, but processed only if approved through a voting process.
They function as application messages in the MLS group,
allowing the steward to collect them without halting the protocol.
There are three types of `voting proposal` according to the type of consensus as in shown Consensus Types section,
these are, `commit proposal`, `steward election proposal` and `emergency criteria proposal`.

`Epoch steward`: The steward assigned to commit in `epoch E` according to the steward list.
Holds the primary responsibility for creating commit in that epoch.

`Backup steward`: The steward next in line after the `epoch steward` on the `steward list` in `epoch E`.
Only becomes active if the `epoch steward` is malicious or fails,
in which case it completes the commitment phase.
If unused in `epoch E`, it automatically becomes the `epoch steward` in `epoch E+1`.

`Steward list`: It is an ordered list that contains the `member id`s of authorized stewards.
Each steward in the list becomes main responsible for creating the commit message when its turn arrives,
according to this order for each epoch.
For example, suppose there are two stewards in the list `steward A` first and `steward B` last in the list.
`steward A` is responsible for creating the commit message for first epoch.
Similarly, `steward B` is for the last epoch.
Since the `epoch steward` is the primary committer for an epoch,
it holds the main responsibility for producing the commit.
However, other stewards MAY also generate a commit within the same epoch to preserve liveness
in case the epoch steward is inactive or slow.
Duplicate commits are not re-applied and only the single valid commit for the epoch is accepted by the group,
as in described in section filtering proposals against the multiple comitting.

Therefore, if a malicious steward occurred, the `backup steward` will be charged with committing.
Lastly, the size of the list named as `sn`, which also shows the epoch interval for steward list determination.

## Flow

General flow is as follows:

- A steward initializes a group just once, and then sends out Group Announcements (GA) periodically.
- Meanwhile, each `node` creates and sends their `credential` includes `keyPackage`.
- Each `member` creates `voting proposals` sends them to from MLS group during `epoch E`.
- Meanwhile, the `steward` collects finalized `voting proposals` from MLS group and converts them into
`MLS proposals` then sends them with corresponding `commit messages`
- Evantually, with the commit messages, all members starts the next `epoch E+1`.

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

The voting proposal MAY include adding a `node` or removing a `member`.
After the `member` creates the voting proposal,
it is emitted to the network via the MLS `Application message` with a lightweight,
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
the `steward` sends a welcome message to the node as the new `member`,
as in section 12.4.3.1. [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).

## Single steward

To naive way to create a decentralized secure group messaging is having a single transparent `steward`
who only applies the changes regarding the result of the voting.

This is mostly similar with the general flow and specified in voting proposal and welcome message creation sections.

1. Each time a single `steward` initializes a group with group parameters with parameters
as in section 8.1. Group Context in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/).
2. `steward` creates a group anouncement (GA) according to the previous step and
broadcast it to the all network periodically. GA message is visible in network to all `nodes`.
3. The each `node` who wants to be a `member` needs to obtain this anouncement and create `credential`
includes `keyPackage` that is specified in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) section 10.
4. The `node` send the `KeyPackages` in plaintext with its signature with current `steward` public key which
anounced in welcome topic. This step is crucial for security, ensuring that malicious nodes/stewards
cannot use others' `KeyPackages`.
It also provides flexibility for liveness in multi-steward settings,
allowing more than one steward to obtain `KeyPackages` to commit.
5. The `steward` aggregates all `KeyPackages` utilizes them to provision group additions for new members,
based on the outcome of the voting process.
6. Any `member` start to create `voting proposals` for adding or removing users,
and present them to the voting in the MLS group as an application message.

However, unlimited use of `voting proposals` within the group may be misused by
malicious or overly active members.
Therefore, an application-level constraint can be introduced to limit the number
or frequency of proposals initiated by each member to prevent spam or abuse.
7. Meanwhile, the `steward` collects finalized `voting proposals` with in epoch `E`,
that have received affirmative votes from members via application messages.
Otherwise, the `steward` discards proposals that did not receive a majority of "YES" votes.
Since voting proposals are transmitted as application messages, omitting them does not affect
the protocol’s correctness or consistency.
8. The `steward` converts all approved `voting proposals` into
corresponding `MLS proposals` and `commit message`, and
transmits both in a single operation as in [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) section 12.4,
including welcome messages for the new members.
Therefore, the `commit message` ends the previous epoch and create new ones.
9. The `members` applied the incoming `commit message` by checking the signatures and `voting proposals`
and synchronized with the upcoming epoch.

## Multi stewards

Decentralization has already been achieved in the previous section.
However, to improve availability and ensure censorship resistance,
the single steward protocol is extended to a multi steward architecture.
In this design, each epoch is coordinated by a designated steward,
operating under the same protocol as the single steward model.
Thus, the multi steward approach primarily defines how steward roles
rotate across epochs while preserving the underlying structure and logic of the original protocol.
Two variants of the multi steward design are introduced to address different system requirements.

### Consensus Types

Consensus is agnostic with its payload; therefore, it can be used for various purposes.
Note that each message for the consensus of proposals is an `application message` in the MLS object section.
It is used in three ways as follows:

1. `Commit proposal`:  It is the proposal instance that is specified in Creating Voting Proposal section
with `Proposal.payload` MUST show the commit request from `members`.
Any member MAY create this proposal in any epoch and `epoch steward` MUST collect and commit YES voted proposals.
This is the only proposal type common to both single steward and multi steward designs.
2. `Steward election proposal`: This is the process that finalizes the `steward list`,
which sets and orders stewards responsible for creating commits over a predefined number of range in (`sn_min`,`sn_max`).
The validity of the choosen `steward list` ends when the last steward in the list (the one at the final index) completes its commit.
At that point, a new `steward election proposal` MUST be initiated again by any member during the corresponding epoch.
The `Proposal.payload` field MUST represent the ordered identities of the proposed stewards.
Each steward election proposal MUST be verified and finalized through the consensus process
so that members can identify which steward will be responsible in each epoch
and detect any unauthorized steward commits.
3. `Emergency criteria proposal`: If there is a malicious member or steward,
this event MUST be voted on to finalize it.
If the proposal returns YES, a score penalty MUST be applied to the targeted member or steward
by decreasing their peer score, and a score reward MUST be granted to the creator of the proposal;
if the proposal returns NO, a score penalty MUST be applied to the creator of the proposal.
`Proposal.payload` MUST include evidence of dishonesty as defined in the Steward Violation List,
along with the identifier of the malicious member or steward.
This proposal can be created by any member in any epoch.

The order of consensus proposal messages is important to achieving a consistent result.
Therefore, messages MUST be prioritized by type in the following order, from highest to lowest priority:

- `Emergency criteria proposal`

- `Steward election proposal`

- `Commit proposal`

This means that if a higher-priority consensus proposal is present in the network,
lower-priority messages MUST be withheld from transmission until the higher-priority proposals have been finalized.

### Steward list creation

The `steward list` consists of steward nominees who will become actual stewards if the `steward election proposal` is finalized with YES,
is arbitrarily chosen from `member` and OPTIONALLY adjusted depending on the needs of the implementation.
The `steward list` size, defined by the minimum `sn_min` and maximum `sn_max` bounds,
is determined at the time of group creation.
The `sn_min` requirement is applied only when the total number of members exceeds `sn_min`;
if the number of available members falls below this threshold,
the list size automatically adjusts to include all existing members.

The actual size of the list MAY vary within this range as `sn`, with the minimum value being at least 1.

The index of the slots shows epoch info and value of index shows `member id`s.
The next in line steward for the `epoch E` is named as `epoch steward`, which has index E.
And the subsequent steward in the `epoch E` is named as the `backup steward`.
For example, let's assume steward list is (S3, S2, S1) if in the previous epoch the roles were
(`backup steward`: S2, `epoch steward`: S1), then in the next epoch they become
(`backup steward`: S3, `epoch steward`: S2) by shifting.

If the `epoch steward` is honest, the `backup steward` does not involve the process in epoch,
and the `backup steward` will be the `epoch steward` within the `epoch E+1`.

If the `epoch steward` is malicious, the `backup steward` is involved in the commitment phase in `epoch E`
and the former steward becomes the `backup steward` in `epoch E`.

Liveness criteria:

Once the active `steward list` has completed its assigned epochs,

members MUST proceed to elect the next set of stewards
(which MAY include some or all of the previous members).
This election is conducted through a type 2 consensus procedure, `steward election proposal`.

A `Steward election proposal` is considered valid only if the resulting `steward list`
is produced through a deterministic process that ensures an unbiased distribution of steward assignments,
since allowing bias could enable a malicious participant to manipulate the list
and retain control within a favored group for multiple epochs.

The list MUST consist of at least `sn_min` members, including retained previous stewards,
sorted according to the ascending value of `SHA256(epoch E || member id || group id)`,
where `epoch E` is the epoch in which the election proposal is initiated,
and `group id` for shuffling the list across the different groups.
Any proposal with a list that does not adhere to this generation method MUST be rejected by all members.

We assume that there are no recurring entries in `SHA256(epoch E || member id || group id)`, since the SHA256 outputs are unique
when there is no repetition in the `member id` values, against the conflicts on sorting issues.

### Multi steward with big consensuses

In this model, all group modifications, such as adding or removing members,
must be approved through consensus by all participants,
including the steward assigned for `epoch E`.
A configuration with multiple stewards operating under a shared consensus protocol offers
increased decentralization and stronger protection against censorship.
However, this benefit comes with reduced operational efficiency.
The model is therefore best suited for small groups that value
decentralization and censorship resistance more than performance.

To create a multi steward with a big consensus,
the group is initialized with a single steward as specified as follows:

1. The steward initialized the group with the config file.
This config file MUST contain (`sn_min`,`sn_max`) as the `steward list` size range.
2. The steward adds the members as a centralized way till the number of members reaches the `sn_min`.
Then, members propose lists by voting proposal with size `sn`
as a consensus among all members, as mentioned in the consensus section 2, according to the checks:
the size of the proposed list `sn` is in the interval (`sn_min`,`sn_max`).
Note that if the total number of members is below `sn_min`,
then the steward list size MUST be equal to the total member count.
3. After the voting proposal ends up with a `steward list`,
and group changes are ready to be committed as specified in single steward section
with a difference which is members also check the committed steward is `epoch steward` or `backup steward`,
otherwise anyone can create `emergency criteria proposal`.
4. If the `epoch steward` violates the changing process as described in the Steward Violation List,
one of the members MUST initialize an `emergency criteria proposal` to apply a peer score penalty to the malicious steward.

A large consensus group provides better decentralization, but it requires significant coordination,
which MAY not be suitable for groups with more than 1000 members.

### Multi steward with small consensuses

The small consensus model offers improved efficiency with a trade-off in decentralization.
In this design, group changes require consensus only among the stewards, rather than all members.
Regular members participate by periodically selecting the stewards by `steward election proposal`
but do not take part in commit decision by `commit proposal`.
This structure enables faster coordination since consensus is achieved within a smaller group of stewards.
It is particularly suitable for large user groups, where involving every member in each decision would be impractical.

The flow is similar to the big consensus including the `steward list` finalization with all members consensus
only the difference here, the commit messages requires `commit proposal` only among the stewards.

## Filtering proposals against the multiple comitting

Since stewards are allowed to produce a commit even when they are not the designated `epoch steward`,
multiple commits may appear within the same epoch, often reflecting recurring versions of the same proposal.
To ensure a consistent outcome, the valid commit for the epoch SHOULD be selected as the one derived
from the longest proposal chain, ordered by the ascending value of each proposal as `SHA256(proposal)`.
All other cases, such as invalid commits or commits based on proposals that were not approved through voting,
can be easily detected and discarded by the members.

## Steward violation list

A steward’s activity is called a violation if the action is one or more of the following:

1. Broken commit: The steward releases a different commit message from the voted `commit proposal`.
This activity is identified by the `members` since the [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/) provides the methods
that members can use to identify the broken commit messages that are possible in a few situations,
such as commit and proposal incompatibility. Specifically, the broken commit can arise as follows:
    1. The commit belongs to the earlier epoch.
    2. The commit message should equal the latest epoch
    3. The commit needs to be compatible with the previous epoch’s `MLS proposal`.
2. Broken MLS proposal: The steward prepares a different `MLS proposal` for the corresponding `voting proposal`.
This activity is identified by the `members` since both `MLS proposal` and `voting proposal` are visible
and can be identified by checking the hash of `Proposal.payload` and `MLSProposal.payload` is the same as RFC9240 section 12.1. Proposals.
3. Censorship and inactivity: The situation where there is a voting proposal that is visible for every member,
and the Steward does not provide an MLS proposal and commit within the configured `threshold_duration`,
after which the voting process is considered finalized by the majority timer.
This activity is again identified by the `members`since `voting proposals` are visible to every member in the group,
therefore each member can verify that there is no `MLS proposal` corresponding to `voting proposal`,
or commit was produced for a voting proposal that has already been finalized due to timer expiration.

## Peer Scoring

To improve fairness in member and steward management, de-MLS SHOULD incorporate a
lightweight peer-scoring mechanism.
Unfairness is not an intrinsic property of a member.
Instead, it arises as a consequence of punitive actions such as removal following an observed malicious behavior.
However, behaviors that appear malicious are not always the result of intent.
Network faults, temporary partitions, message delays, or client-side failures may lead to unintended protocol deviations.
A peer-scoring mechanism allows de-MLS to account for such transient and non-adversarial conditions by accumulating evidence over time.
This enables the system to distinguish persistent and intentional misbehavior from accidental faults.
Member removal should be triggered only in cases of sustained and intentional malicious activity,
thereby preserving fairness while maintaining security and liveness.
In this approach, each node maintains a local peer score table mapping `member_id` to a score,
with new members starting from a configurable default value `default_peer_score`.
Peer scores may decrease due to violations and increase due to honest behavior;
such score adjustments are derived from observable protocol events, such as
successful commits or emergency criteria proposals, and each peer updates its local table accordingly.
Stewards MUST periodically evaluate peer scores against the predefined threshold `threshold_peer_score`.  
A removal operation MUST be included in the next commit only if a peer’s score is observed to fall below `threshold_peer_score`.
This mechanism allows accidental or transient failures to be tolerated while still enabling
decisive action against repeated or harmful behavior.
The exact scoring rules, recovery mechanisms, and escalation criteria are left for future discussion.

## Timer-Based Anti-Deadlock Mechanism

In de-MLS, a deadlock refers to a prolonged period during which no valid commit is produced
despite a sufficient number of active and online members capable of finalizing consensus.
To mitigate deadlock risks in de-MLS, a timer-based anti-deadlock mechanism SHOULD be introduced.
Each member maintains a local timer that resets whenever a valid commit is observed,
with a `threshold_duration` defined in configuration.
If the `threshold_duration` is exceeded, the member waits an additional buffer period to account
for network delays and then triggers a high-priority `emergency proposal` indicating a potential deadlock.
If the proposal returns YES, temporarily allowing any member to commit and restore liveness.
Since timers may expire at different times in a P2P setting, the buffer period mitigates false positives,
while commit filtering is required to prevent commit flooding during recovery.
Emergency proposals that return NO MUST incur a peer-score penalty for the
creator of the proposal to reduce abuse.

## Security Considerations

In this section, the security considerations are shown as de-MLS assurance.

1. Malicious Steward: A Malicious steward can act maliciously,
as in the Steward violation list section.
Therefore, de-MLS enforces that any steward only follows the protocol under the consensus order
and commits without emergency criteria application.
2. Malicious Member: A member is only marked as malicious
when the member acts by releasing a commit message.
3. Steward list election bias: Although SHA256 is used together with two global variables
to shuffle stewards in a deterministic and verifiable manner,
this approach only minimizes election bias; it does not completely eliminate it.
This design choice is intentional, in order to preserve the efficiency advantages provided by the MLS mechanism.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/)

### References

- [MLS RFC 9420](https://datatracker.ietf.org/doc/rfc9420/)
- [Hashgraphlike Consensus](https://github.com/vacp2p/rfc-index/blob/consensus-hashgraph-like/vac/raw/consensus-hashgraphlike.md)
- [vacp2p/de-mls](https://github.com/vacp2p/de-mls)
