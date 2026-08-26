# Rotational Versioning


| Field | Value |
| --- | --- |
| Name | Rotational Versioning |
| Slug | TODO (assigned on promotion to draft) |
| Status | raw |
| Type | RFC |
| Category | Informational |
| Tags | logos-chat |
| Editor | jazzz <jazz@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

## Abstract

Deploying a breaking change to a decentralized protocol is slow:
with no operator to force an upgrade,
a change cannot be used until most of the network has adopted it.
This document describes composing protocol functionality from smaller
protocols, each versioned independently and each immutable.
A stable initialization protocol settles which operational protocol an
interaction uses, so a change to one interaction obliges no one outside it.
Breaking changes stop being events the whole network has to live through
together.

## Terminology

The key words "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD",
"SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document
are to be interpreted as described in [RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

- **Interaction** — a bounded exchange of information between a known set of
  parties. In messaging, a conversation.
- **Participant** — a party to an interaction.
- **Protocol** — a specification that defines how parties interact.
  A protocol is immutable: once published it does not change.
  A protocol may be composed of other protocols,
  each versioned independently.
- **Interop-domain** — for a given protocol, the minimal set of parties
  that must agree on it to avoid a partition.
- **Initialization protocol** — the protocol by which parties establish an
  interaction with one another, and settle which operational protocol it will
  use. In messaging, this covers key material and invitations.
- **Operational protocol** — the protocol under which an established
  interaction is conducted. In messaging, a ConversationType.
- **Supported set** — the protocols a given client or application is willing
  to speak. Each chooses its own.
- **Network** — every party that can be reached, whether or not any interaction
  exists between them.

## Motivation

The standard deployment cycle for new decentralized protocol features is slow.
Commits are written, tested and merged quickly.
Those changes do not reach users until enough of the network has adopted them,
and there is no operator who can force that adoption —
no service to upgrade and no old endpoint to close.

For two applications to interoperate they must understand the same payloads,
and an older client simply cannot read a newer one.
In the decentralized context version deployment is a sequence of independent
tasks, each performed by a party the one before it cannot compel:
client developers implement the change,
application developers import the new library and ship a release,
and individual users update their applications.

Enabling a breaking change partitions the network into two sets —
those who can process the new payloads and those who cannot.
The longer a change is left to soak, the smaller the second set becomes.

Two costs follow from this model.

The first is that the pace is set by the least current members of the network.
The most active users may update within days,
but they cannot use what they have until the bulk of the network has followed,
often around 80%.
In practice a change takes three to six months to deploy.
The capability exists on both ends of an interaction and cannot be exercised,
because a third party has not moved.

The second is that contributors and developers spend their time coordinating.
Choosing a soak period, aligning release schedules and tracking adoption
are not protocol work,
and every layer of the stack pays the cost.
Worse, they recur on every breaking change,
so the cost scales with the number of changes rather than being paid once.

The end result is a slow ossification of the protocol.
The overhead of deployment is roughly fixed regardless of the size of the change,
so only large ones are worth putting through it.
Small improvements queue behind them,
and the protocol advances in rare, heavy steps rather than continuously.

The goal of the approach described here is not to eliminate breaking changes
altogether.
It is to allow changes to reach end users without waiting on the rest of the
network, while minimizing the workload of protocol contributors and app
developers alike.

## Theory / Semantics

### Observations

The approach rests on three observations.

**Not all parts of a protocol change at the same rate.**
Breaking changes are not uniformly distributed — they occur in some regions more than others.

**Immutable protocols make compatibility trivial.**
Two parties either speak a given protocol or they do not;
there is no version range to reconcile and no behavior to detect.
Publishing a new protocol adds an option and removes nothing,
so an interaction under an old one continues undisturbed.

**Capability negotiation is an easier task than coordinating upgrades.**
Upgrading requires all entities to coordinate when to switch.
Whereas capability negotiation can occur asynchronously offline.

### Approach

Compose protocol functionality from smaller protocols,
and version each independently.

One of them is initialization.
It establishes contact between parties
and settles which of the others an interaction will use.
Everyone must speak it, so it is built to be stable and changes rarely.

The rest are operational protocols — the conduct of an interaction itself.
Only the participants of a single interaction need to agree
on which operational protocol they use.

Operational protocols are immutable.
A change is published as a new protocol rather than a new version
of an existing one, and the old one remains valid indefinitely.

Nothing upgrades in place.
An interaction runs under the protocol it was created with
for as long as it lasts.
To take up a change, participants establish a new interaction
under the newer protocol and leave the old one behind.
This is a rotation.

Initialization carries no knowledge of the operational protocols.
It names them and settles which one to use without understanding any of them,
which is why new operational protocols can be published
without initialization changing.

### Interoperability domains

Every protocol has an interop-domain:
the set of parties that must understand it for the protocol to work.
These domains are not the same size, and they scale with different things.

Initialization must be understood by everyone or a partition will occur.
Two parties who cannot resolve each other's identity cannot interact at all,
so the domain covers the whole network and grows with the number of accounts.

The operational protocols — in messaging, a ConversationType — are different.
Only their participants need to agree on the protocol,
and no party outside it is affected by what they use.
That domain grows with the number of participants and nothing else.

The size of a protocol's interop-domain sets the cost of changing it.
A protocol understood by everyone can only be changed by agreement of everyone.
A protocol understood by five people needs the agreement of five people.
Treating the whole of a protocol's functionality as one indivisible unit
gives each of its parts the largest domain that any one of them requires,
so every change is priced as the max of these sets.

### Consent

Underneath the mechanics is a single principle:
no participant in the system has a change imposed on them by another.

The system has four layers of choice, and each is free.
Protocol contributors publish what they think is worth publishing.
Client developers decide which of those protocols to expose.
Application developers choose a client, and change clients if another
serves them better.
Users choose an application, and leave if it stops serving them.

Nothing above binds anything below.
A contributor cannot oblige a client to carry a protocol,
a client cannot oblige an application to use one,
and an application cannot oblige a user to stay.
The final decision belongs to users,
and it is exercised by leaving rather than by negotiating.

The mechanics in this document exist to make that principle true in practice
rather than in name.
Immutability means a protocol cannot change under someone who chose it.
Interaction-scoped interoperability means one group's decision
does not reach another group.
A coordinated network upgrade is the opposite of all of this:
it is a moment at which everyone is made to accept a change
chosen on their behalf.

This also bounds what the system can promise.
An application that handles a user's messages can misuse them,
and no protocol prevents that.
What a protocol can do is keep the cost of leaving low,
which means ensuring a user who moves to another application
keeps their identity, remains reachable,
and can still talk to the people they could talk to before.
Exit is only a real choice if it is cheap.

### Protocol Selection

A new interaction is conducted under one operational protocol,
and someone has to pick it.
Initialization establishes which protocols the participants have in common;
the party that initiates the interaction chooses among them —
in messaging, whoever creates the group.

Because a client supports many protocols at once,
several may be available to a given set of participants,
and the initiator may pick any of them, including the oldest.
This is not a problem that selection has to solve.
It is a problem the supported set has already solved.

A client's supported set is its security policy.
A protocol nobody is willing to speak cannot be selected,
and a client that has withdrawn a protocol cannot be steered onto it
by a peer, an administrator, or an attacker.
If the only protocol another party will speak is one this client
does not trust, the correct outcome is that no interaction is established.

Once the set has been curated, what remains is preference rather than safety.
Later protocols generally carry the fixes of earlier ones
along with whatever was added since,
so the newest protocol available to all participants is usually the best one,
and often the only sensible choice.
Where two protocols are genuinely incomparable, the choice is a matter of
taste, and the initiator breaks the tie.

Ordering is held by client developers.
A client sits between protocol contributors and application developers,
and is the natural place for a stated preference over the protocols it exposes.
Contributors should make clear, in changelogs and in libraries,
which protocol they consider current;
that guidance is advisory and binds no one.

### Protocol Deprecation

Adding a protocol costs nobody anything.
Withdrawing one is a breaking change, and it retains all of the old properties:
whoever is still relying on it loses the ability to interoperate.
The coordination cost does not disappear, it moves to the end
of a protocol's life rather than the beginning.
Two cases are worth separating.

**Disuse.** Use has fallen far enough that carrying the code is not worth it.
Nothing here is urgent, so withdrawal can happen on whatever schedule
suits the developer doing it —
including the slow schedule a network upgrade used to require,
now with far less at stake.
The decision has also moved to a better place.
It is no longer a protocol contributor deciding which of the network's users
to strand, but an application developer deciding for their own users,
who can leave if they disagree.

**Compromise.** A protocol is found to be unsafe and should no longer
be reachable.
Here timing matters, and the benefit does not arrive by publishing the fix.
Publishing a replacement protects nobody on its own,
because the unsafe protocol remains valid and remains selectable.
Protection begins when a client refuses the unsafe protocol,
and that refusal is the interoperability break.

The tradeoff is real, but this arrangement improves it in two ways.
Publishing the replacement and withdrawing the original are separate actions
that can happen at different times.
In a coordinated upgrade they are the same event,
which is why the cutover has to be planned and why it is expensive.
Here the replacement can be published immediately
and adopted at whatever rate clients update,
while the unsafe protocol is still supported.
By the time it is withdrawn, fewer parties are still relying on it,
because the population using it has been draining the whole time.

Second, withdrawal requires nobody's agreement.
Any client may refuse a protocol at any moment, unilaterally,
and the cost is limited to the peers who have not yet caught up.
There is no button that disables an unsafe protocol network-wide;
in a decentralized system there never was one.
What this arrangement offers is a response that is itself decentralized,
and that reaches the most active users first.

Users who never update are never protected.
That is true of any decentralized system and is not improved here.

## Implementation Suggestions

A client library should make the supported set a matter of configuration —
a list of protocols passed in, with a sensible default provided —
so that adding or withdrawing a protocol is a configuration change
for an application developer rather than an engineering project.

The default should reflect what contributors currently recommend,
and should be revisited when a protocol is withdrawn for compromise.
Most applications will take the default, which makes it the point at which
the network's behaviour is in practice decided.
It is worth being deliberate about that:
the default is advisory and binds no one,
but it is where coordination has gone,
and it should be maintained with that in mind.

Contributors should state clearly which protocol is current
and why a newer one supersedes an older one.
Where a family of protocols has a single source,
a naming scheme that conveys ordering makes the recommendation
legible without a lookup.
Note that this conflicts with ConversationTypes as currently written,
which holds that names carry no semantic meaning
and imply no ordering or relationship between similarly named types.
One of the two positions has to give.

## Security/Privacy Considerations

### Security

The security of an interaction is determined by the supported sets
of its participants, not by the selection made within them.
A client that continues to support a protocol can be steered onto it,
and should assume it will be.
Withdrawal, not publication, is what removes exposure.

Because clients support several protocols simultaneously,
a party choosing among them may choose the weakest that all participants share.
This is a surface the approach introduces:
where a single protocol is in force, the choice does not exist.
The mitigation is the supported set, and it is the only mitigation.

Withdrawing a compromised protocol strands the parties still using it.
This is a genuine cost and it falls on the least active users,
who are also the least likely to have received the replacement.
Withdrawing early protects more of the active population sooner;
withdrawing late strands fewer people.
The approach narrows the blast radius of that decision to one application's
users and moves the decision to the developer who serves them,
but it does not remove it.

## Copyright

Copyright and related rights waived via
[CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### Informative

- ConversationTypes —
  `docs/messaging/application/raw/conversationtypes.md`