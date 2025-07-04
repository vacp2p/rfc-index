---
title: LIBP2P-MIX
name: Libp2p Mix Protocol
status: raw
category: Standards Track
tags:
editor: Akshaya Mani <akshaya@status.im>
contributors: Daniel Kaiser <danielkaiser@status.im>
---

## Abstract

The Mix Protocol defines a decentralized anonymous message routing layer for
libp2p networks.
It enables sender anonymity by routing each message through a decentralized mix
overlay network
composed of participating libp2p nodes, known as mix nodes. Each message is
routed independently
in a stateless manner, allowing other libp2p protocols to selectively anonymize
messages without
modifying their core protocol behavior.

## 1. Introduction

The Mix Protocol is a custom libp2p protocol that defines a message-layer
routing abstraction
designed to provide sender anonymity in peer-to-peer systems built on the libp2p
stack.
It addresses the absence of native anonymity primitives in libp2p by offering a
modular,
content-agnostic protocol that other libp2p protocols can invoke when anonymity
is required.

This document describes the design, behavior, and integration of the Mix
Protocol within the
libp2p architecture. Rather than replacing or modifying existing libp2p
protocols, the Mix Protocol
complements them by operating independently of connection state and protocol
negotiation.
It is intended to be used as an optional anonymity layer that can be selectively
applied on a
per-message basis.

Integration with other libp2p protocols is handled through external interface
components&mdash;the Mix Entry
and Exit layers&mdash;which mediate between these protocols and the Mix Protocol
instances.
These components allow applications to defer anonymity concerns to the Mix layer
without altering
their native semantics or transport assumptions.

The rest of this document describes the motivation for the protocol, defines
relevant terminology,
presents the protocol architecture, and explains how the Mix Protocol
interoperates with the broader
libp2p protocol ecosystem.

## 2. Terminology

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”,
“MAY”, and “OPTIONAL” in this document are to be interpreted as described in
[RFC 2119](https://datatracker.ietf.org/doc/html/rfc2119).

The following terms are used throughout this specification:

- **Origin Protocol**
A libp2p protocol (_e.g.,_ Ping, GossipSub) that generates and receives the
actual message payload.
The origin protocol MUST decide on a per-message basis whether to route the
message through the Mix Protocol
or not.

- **Mix Node**
A libp2p node that supports the Mix Protocol and participates in the mix
network.
A mix node initiates anonymous routing when invoked with a message.
It also receives and processes Sphinx packets when selected as a hop in a mix
path.

- **Mix Path**
A non-repeating sequence of mix nodes through which a Sphinx packet is routed
across the mix network.

- **Mixify**
A per-message flag set by the origin protocol to indicate that a message should
be routed using
the Mix Protocol or not.
Only messages with mixify set are forwarded to the Mix Entry Layer.
Other messages SHOULD be routed using the origin protocol’s default behavior.

The phrases 'messages to be mixified', 'to mixify a message' and related
variants are used
informally throughout this document to refer to messages that either have the
`mixify` flag set
or are selected to have it set.

- **Mix Entry Layer**
A component that receives messages to be _mixified_ from an origin protocol and
forwards them to the
local Mix Protocol instance.
The Entry Layer is external to the Mix Protocol.

- **Mix Exit Layer**
A component that receives decrypted messages from a Mix Protocol instance and
delivers them
to the appropriate origin protocol instance at the destination.
Like the Entry Layer, it is external to the Mix Protocol.

- **Mixnet or Mix Network**
A decentralized overlay network formed by all nodes that support the Mix
Protocol.
It operates independently of libp2p’s protocol-level routing and origin protocol
behavior.

- **Sphinx Packet**
A cryptographic packet format used by the Mix Protocol to encapsulate messages.
It uses layered encryption to hide routing information and protect message
contents as packets are forwarded hop-by-hop.
Sphinx packets are fixed-size and indistinguishable from one another, providing
unlinkability and metadata protection.

## 3. Motivation and Background

libp2p enables modular peer-to-peer applications, but it lacks built-in support
for sender anonymity.
Most protocols expose persistent peer identifiers, transport metadata, or
traffic patterns that
can be exploited to deanonymize users through passive observation or
correlation.

While libp2p supports NAT traversal mechanisms such as Circuit Relay, these
focus on connectivity
rather than anonymity. Relays may learn peer identities during stream setup and
can observe traffic
timing and volume, offering no protection against metadata analysis.

libp2p also supports a Tor transport for network-level anonymity, tunneling
traffic through long-lived,
encrypted circuits. However, Tor relies on session persistence and is ill-suited
for protocols
requiring per-message unlinkability.

The Mix Protocol addresses this gap with a decentralized message routing layer
based on classical
mix network principles. It applies layered encryption and per-hop delays to
obscure both routing paths
and timing correlations. Each message is routed independently, providing
resistance to traffic analysis
and protection against metadata leakage

By decoupling anonymity from connection state and transport negotiation, the Mix
Protocol offers
a modular privacy abstraction that existing libp2p protocols can adopt without
altering their
core behavior.

To better illustrate the differences in design goals and threat models, the
following subsection contrasts
the Mix Protocol with Tor, a widely known anonymity system.

### 3.1 Comparison with Tor

The Mix Protocol differs fundamentally from Tor in several ways:

- **Unlinkability**: In the Mix Protocol, there is no direct connection between
source and destination.
Each message is routed independently, eliminating correlation through persistent
circuits.

- **Delay-based mixing**: Mix nodes introduce randomized delays (e.g., from an
exponential distribution)
before forwarding messages, making timing correlation significantly harder.

- **High-latency focus**: Tor prioritizes low-latency communication for
interactive web traffic,
whereas the Mix Protocol is designed for scenarios where higher latency is
acceptable
in exchange for stronger anonymity.

- **Message-based design**: Each message in the Mix Protocol is self-contained
and independently routed.
No sessions or state are maintained between messages.

- **Resistance to endpoint attacks**: The Mix Protocol is less susceptible to
certain endpoint-level attacks,
such as traffic volume correlation or targeted probing, since messages are
delayed, reordered, and unlinkable at each hop.

To understand the underlying anonymity properties of the Mix Protocol, we next
describe the core components of a mix network.

## 4. Mixing Strategy and Packet Format

The Mix Protocol relies on two core design elements to achieve sender
unlinkability and metadata
protection: a mixing strategy and a a cryptographically secure mix packet
format.

### 4.1 Mixing Strategy

A mixing strategy defines how mix nodes delay and reorder incoming packets to
resist timing
correlation and input-output linkage. Two commonly used approaches are
batch-based mixing and
continuous-time mixing.

In batching-based mixing, each mix node collects incoming packets over a fixed
or adaptive
interval, shuffles them, and forwards them in a batch. While this provides some
unlinkability,
it introduces high latency, requires synchronized flushing rounds, and may
result in bursty
output traffic. Anonymity is bounded by the batch size, and performance may
degrade under variable
message rates.

The Mix Protocol instead uses continuous-time mixing, where each mix node
applies a randomized
delay to every incoming packet, typically drawn from an exponential
distribution. This enables
theoretically unbounded anonymity sets, since any packet may, with non-zero
probability,
be delayed arbitrarily long. In practice, the distribution is truncated once the
probability
of delay falls below a negligible threshold. Continuous-time mixing also offers
improved
bandwidth utilization and smoother output traffic compared to batching-based
approaches.

To make continuous-time mixing tunable and predictable, the sender MUST select
the mean delay
for each hop and encode it into the Sphinx packet header. This allows top-level
applications
to balance latency and anonymity according to their requirements.

### 4.2 Mix Packet Format

A mix packet format defines how messages are encapsulated and routed through a
mix network.
It must ensure unlinkability between incoming and outgoing packets, prevent
metadata leakage
(e.g., path length, hop position, or payload size), and support uniform
processing by mix nodes
regardless of direction or content.

The Mix Protocol uses [Sphinx
packets](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf)
to meet these goals.
Each message is encrypted in layers corresponding to the selected mix path. As a
packet traverses
the network, each mix node removes one encryption layer to obtain the next hop
and delay,
while the remaining payload remains encrypted and indistinguishable.

Sphinx packets are fixed in size and bit-wise unlinkable. This ensures that they
appear identical
on the wire regardless of payload, direction, or route length, reducing
opportunities for correlation
based on packet size or format. Even mix nodes learn only the immediate routing
information
and the delay to be applied. They do not learn their position in the path or the
total number of hops.

The packet format is resistant to tagging and replay attacks and is compact and
efficient to
process. Sphinx packets also include per-hop integrity checks and enforces a
maximum path length.
Together with a constant-size header and payload, this provides bounded
protection
against
endless routing and malformed packet propagation.

It also supports anonymous and indistinguishable reply messages through
[Single-Use Reply Blocks
(SURBs)](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf),
although reply support is not implemented yet.

A complete specification of the Sphinx packet structure and fields is provided
in [Section 6].

## 5. Protocol Overview

The Mix Protocol defines a decentralized, message-based routing layer that
provides sender anonymity
within the libp2p framework.

It is agnostic to message content and semantics. Each message is treated as an
opaque payload,
wrapped into a [Sphinx
packet](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf) and routed
independently through a randomly selected mix path. Along the path, each mix
node removes one layer
of encryption, adds a randomized delay, and forwards the packet to the next hop.
This combination of
layered encryption and per-hop delay provides resistance to traffic analysis and
enables message-level
unlinkability.

Unlike typical custom libp2p protocols, the Mix protocol is stateless&mdash;it
does not establish
persistent streams, negotiate protocols, or maintain sessions. Each message is
self-contained
and routed independently.

The Mix Protocol sits above the transport layer and below the protocol layer in
the libp2p stack.
It provides a modular anonymity layer that other libp2p protocols MAY invoke
selectively on a
per-message basis.

Integration with other libp2p protocols is handled through external components
that mediate
between the origin protocol and the Mix Protocol instances. This enables
selective anonymous routing
without modifying protocol semantics or internal behavior.

The following subsections describe how the Mix Protocol integrates with origin
protocols via
the Mix Entry and Exit layers, how per-message anonymity is controlled through
the `mixify` flag,
the rationale for defining Mix as a protocol rather than a transport, and the
end-to-end message
interaction flow.

### 5.1 Integration with Origin Protocols

libp2p protocols that wish to anonymize messages MUST do so by integrating with
the Mix Protocol
via the Mix Entry and Exit layers.

- The **Mix Entry Layer** receives messages to be _mixified_ from an origin
protocol and forwards them
to the local Mix Protocol instance.

- The **Mix Exit Layer** receives the final decrypted message from a Mix
Protocol instance and
forwards it to the appropriate origin protocol instance at the destination over
a client-only connection.

This integration is external to the Mix Protocol and is not handled by mix nodes
themselves.

### 5.2 Mixify Option

Some origin protocols may require selective anonymity, choosing to anonymize
_only_ certain messages
based on their content, context, or destination. For example, a protocol may
only anonymize messages
containing sensitive metadata while delivering others directly to optimize
performance.

To support this, origin protocols MAY implement a per-message `mixify` flag that
indicates whether a message should be routed using the Mix Protocol.

- If the flag is set, the message MUST be handed off to the Mix Entry Layer for
anonymous routing.
- If the flag is not set, the message SHOULD be routed using the origin
protocol’s default mechanism.

This design enables protocols to invoke the Mix Protocol only for selected
messages, providing fine-grained control over privacy and performance
trade-offs.

### 5.3 Why a Protocol, Not a Transport

The Mix Protocol is specified as a custom libp2p protocol rather than a
transport to support
selective anonymity while remaining compatible with libp2p’s architecture.

As noted in [Section 5.2](#52-mixify-option), origin protocols may anonymize
only specific messages
based on content or context. Supporting such selective behavior requires
invoking Mix on a per-message basis.

libp2p transports, however, are negotiated per peer connection and apply
globally to all messages
exchanged between two peers. Enabling selective anonymity at the transport layer
would
therefore require
changes to libp2p’s core transport semantics.

Defining Mix as a protocol avoids these constraints and offers several benefits:

- Supports selective invocation on a per-message basis.
- Works atop existing secure transports (_e.g.,_ QUIC, TLS) without requiring
changes to the transport stack.
- Preserves a stateless, content-agnostic model focused on anonymous message
routing.
- Integrates seamlessly with origin protocols via the Mix Entry and Exit layers.

This design preserves the modularity of the libp2p stack and allows Mix to be
adopted without altering existing transport or protocol behavior.

### 5.4 Protocol Interaction Flow

A typical end-to-end Mix Protocol flow consists of the following three
conceptual phases.
Only the second phase&mdash;the anonymous routing performed by mix
nodes&mdash;is part of the core
Mix Protocol. The entry-side and exit-side integration steps are handled
externally by the Mix Entry
and Exit layers.

1. **Entry-side Integration (Mix Entry Layer):**

   - The origin protocol generates a message and sets the `mixify` flag.
   - The message is passed to the Mix Entry Layer, which invokes the local Mix
Protocol instance with
the message, destination, and origin protocol codec as input.

2. **Anonymous Routing (Core Mix Protocol):**

   - The Mix Protocol instance wraps the message in a Sphinx packet and selects a
random mix path.
   - Each mix node along the path:
     - Processes the Sphinx packet by removing one encryption layer.
     - Applies a delay and forwards the packet to the next hop.
   - The final node in the path (exit node) decrypts the final layer, extracting
the original plaintext message, destination, and origin protocol codec.

3. **Exit-side Integration (Mix Exit Layer):**

   - The Mix Exit Layer receives the plaintext message, destination, and origin
protocol codec.
   - It routes the message to the destination origin protocol instance using a
client-only connection.

The destination node does not need to support the Mix Protocol to receive or
respond
to anonymous messages.

The behavior described above represents the core Mix Protocol. In addition, the
protocol
supports a set of pluggable components that extend its functionality. These
components cover
areas such as node discovery, delay strategy, spam resistance, cover traffic
generation,
and incentivization. Some are REQUIRED for interoperability; others are OPTIONAL
or deployment-specific.
The next section describes each component.

### 5.5 Stream Management and Multiplexing

Each Mix Protocol message is routed independently, and forwarding it to the next
hop requires
opening a new libp2p stream using the Mix Protocol. This applies to both the
initial Sphinx packet
transmission and each hop along the mix path.

In high-throughput environments (_e.g._, messaging systems with continuous
anonymous traffic),
mix nodes may frequently communicate with a subset of mix nodes. Opening a new
stream for each
Sphinx packet in such scenarios can incur performance costs, as each stream
setup requires a
multistream handshake for protocol negotiation.

While libp2p supports multiplexing multiple streams over a single transport
connection using
stream muxers such as mplex and yamux, it does not natively support reusing a
stream over multiple
message transmissions. However, stream reuse may be desirable in the mixnet
setting to reduce overhead
and avoid hitting per protocol stream limits between peers.

The lifecycle of streams, including their reuse, eviction, or pooling strategy,
is outside the
scope of this specification. It SHOULD be handled by the libp2p host, connection
manager, or
transport stack.

Mix Protocol implementations MUST NOT assume persistent stream availability and
SHOULD gracefully
fall back to opening a new stream when reuse is not possible.

## 6. Pluggable Components

Pluggable components define functionality that extends or configures the
behavior of the Mix Protocol
beyond its core message routing logic. Each component in this section falls into
one of two categories:

- Required for interoperability and path construction (_e.g.,_ discovery, delay
strategy).
- Optional or deployment-specific (_e.g.,_ spam protection, cover traffic,
incentivization).

The following subsections describe the role and expected behavior of each.

### 6.1 Discovery

The Mix Protocol does not mandate a specific peer discovery mechanism. However,
nodes participating in
the mixnet MUST be discoverable so that other nodes can construct routing paths
that include them.

To enable this, regardless of the discovery mechanism used, each mix node MUST
make the following
information available to peers:

- Indicate Mix Protocol support (_e.g.,_ using a `mix` field or bit).
- Its X25519 public key for Sphinx encryption.
- One or more routable libp2p multiaddresses that identify the mix node’s own
network endpoints.

To support sender anonymity at scale, discovery mechanism SHOULD support
_unbiased random sampling_
from the set of live mix nodes. This enables diverse path construction and
reduces exposure to
adversarial routing bias.

While no existing mechanism provides unbiased sampling by default,
[Waku’s ambient discovery](https://rfc.vac.dev/waku/standards/core/33/discv5/)
&mdash; an extension
over [Discv5](https://github.com/ethereum/devp2p/blob/master/discv5/discv5.md)
&mdash; demonstrates
an approximate solution. It combines topic-based capability advertisement with
periodic
peer sampling. A similar strategy could potentially be adapted for the Mix
Protocol.

A more robust solution would involve integrating capability-aware discovery
directly into the
libp2p stack, such as through extensions to `libp2p-kaddht`. This would enable
direct lookup of
mix nodes based on protocol support and eliminate reliance on external
mechanisms such as Discv5.
Such an enhancement remains exploratory and is outside the scope of this
specification.

Regardless of the mechanism, the goal is to ensure mix nodes are discoverable
and that path selection
is resistant to bias and node churn.

### 6.2 Delay Strategy

The Mix Protocol uses per-hop delay as a core mechanism for achieving timing
unlinkability.
For each hop in the mix path, the sender MUST specify a mean delay value, which
is embedded in
the Sphinx packet header. The mix node at each hop uses this value to sample a
randomized delay
before forwarding the packet.

By default, delays are sampled from an exponential distribution. This supports
continuous-time mixing,
produces smooth output traffic, and enables tunable trade-offs between latency
and anonymity.
Importantly, it allows for unbounded anonymity sets: each packet may, with
non-zero probability,
be delayed arbitrarily long.

The delay strategy is considered pluggable, and other distributions MAY be used
to match
application-specific anonymity or performance requirements. However, any delay
strategy
MUST ensure that:

- Delays are sampled independently at each hop.
- Delay sampling introduces sufficient variability to obscure timing correlation
between packet
arrival and forwarding across multiple hops.

Strategies that produce deterministic or tightly clustered output delays are NOT
RECOMMENDED,
as they increase the risk of timing correlation. Delay strategies SHOULD
introduce enough uncertainty
to prevent adversaries from linking packet arrival and departure times, even
when monitoring
multiple hops concurrently.

### 6.3 Spam Protection

The Mix Protocol supports optional spam protection mechanisms to defend
recipients against
abusive or unsolicited traffic. These mechanisms are applied at the exit node,
which is the
final node in the mix path before the message is delivered to its destination
via the respective
libp2p protocol.

Exit nodes that enforce spam protection MUST validate the attached proof before
forwarding
the message. If validation fails, the message MUST be discarded.

Common strategies include Proof of Work (PoW), Verifiable Delay Functions
(VDFs), and Rate-limiting Nullifiers (RLNs).

The sender is responsible for appending the appropriate spam protection data
(e.g., nonce, timestamp)
to the message payload. The format and verification logic depend on the selected
method.
An example using PoW is included in Appendix A.

Note: The spam protection mechanisms described above are intended to protect the
destination application
or protocol from message abuse or flooding. They do not provide protection
against denial-of-service (DoS) or
resource exhaustion attacks targeting the mixnet itself (_e.g.,_ flooding mix
nodes with traffic,
inducing processing overhead, or targeting bandwidth).

Protections against attacks targeting the mixnet itself are not defined in this
specification
but are critical to the long-term robustness of the system. Future versions of
the protocol may
define mechanisms to rate-limit clients, enforce admission control, or
incorporate incentives and
accountability to defend the mixnet itself from abuse.

### 6.4 Cover Traffic

Cover traffic is an optional mechanism used to improve privacy by making the
presence or absence
of actual messages indistinguishable to observers. It helps achieve
_unobservability_ where
a passive adversary cannot determine whether a node is sending real messages or
not.

In the Mix Protocol, cover traffic is limited to _loop messages_ &mdash; dummy
Sphinx packets
that follow a valid mix path and return to the originating node. These messages
carry no application
payload but are indistinguishable from real messages in structure, size, and
routing behavior.

Cover traffic MAY be generated by either mix nodes or senders. The strategy for
generating
such traffic &mdash; such as timing and frequency &mdash; is pluggable and not
specified
in this document.

Implementations that support cover traffic SHOULD generate loop messages at
randomized intervals.
This helps mask actual sending behavior and increases the effective anonymity
set. Timing
strategies such as Poisson processes or exponential delays are commonly used,
but the choice is
left to the implementation.

In addition to
enhancing privacy, loop messages can be used to assess network liveness or path
reliability
without requiring explicit acknowledgments.

### 6.5 Incentivization

The Mix Protocol supports a simple tit-for-tat model to discourage free-riding
and promote
mix node participation. In this model, nodes that wish to send anonymous
messages using the
Mix Protocol MUST also operate a mix node. This requirement ensures that
participants contribute to
the anonymity set they benefit from, fostering a minimal form of fairness and
reciprocity.

This tit-for-tat model is intentionally lightweight and decentralized. It deters
passive use
of the mixnet by requiring each user to contribute bandwidth and processing
capacity. However, it
does not guarantee the quality of service provided by participating nodes. For
example, it
does not prevent nodes from running low-quality or misbehaving mix instances,
nor does it
deter participation by compromised or transient peers.

The Mix Protocol does not mandate any form of payment, token exchange, or
accounting. More
sophisticated economic models &mdash; such as stake-based participation,
credentialed relay networks,
or zero-knowledge proof-of-contribution systems &mdash; MAY be layered on top of
the protocol or
enforced via external coordination.

Additionally, network operators or application-layer policies MAY require nodes
to maintain
minimum uptime, prove their participation, or adhere to service-level
guarantees.

While the Mix Protocol defines a minimum participation requirement, additional
incentivization
extensions are considered pluggable and experimental in this version of the
specification.
No specific mechanism is standardized.

## 7. Core Mix Protocol Responsibilities

This section defines the core routing behavior of the Mix Protocol, which all
conforming
implementations MUST support.

The Mix Protocol defines the logic for anonymously routing messages through the
decentralized
mix network formed by participating libp2p nodes. Each mix node MUST implement
support for:

- initiating anonymous routing when invoked with a message.
- receiving and processing Sphinx packets when selected as a hop in a mix path.

These roles and their required behaviors are defined in the following
subsections.

### 7.1 Protocol Identifier

The Mix Protocol is identified by the protocol string `"/mix/1.0.0"`.

All Mix Protocol interactions occur over libp2p streams negotiated using this
identifier.
Each Sphinx packet transmission&mdash;whether initiated locally or forwarded as
part of a
mix path&mdash;involves opening a new libp2p stream to the next hop.
Implementations MAY optimize
performance by reusing streams where appropriate; see [Section
5.5](#55-stream-management-and-multiplexing)
for more details on stream management.

### 7.2 Initiation

A mix node initiates anonymous routing only when it is explicitly invoked with a
message
to be routed. As specified in [Section 5.2](#52-mixify-option), the decision to
anonymize a
message is made by the origin protocol. When anonymization is required, the
origin protocol instance
forwards the message to the Mix Entry Layer, which then passes the message to
the local
Mix Protocol instance for routing.

To perform message initiation, a mix node MUST:

- Select a random mix path.
- Assign a delay value for each hop and encode it into the Sphinx packet header.
- Wrap message in a Sphinx packet by applying layered encryption in reverse
order of nodes
in the selected mix path.
- Forward the resulting packet to the first mix node in the mix path using the
Mix Protocol.

The Mix Protocol does not interpret message content or origin protocol context.
Each invocation is
stateless, and the implementation MUST NOT retain routing metadata or
per-message state
after the packet is forwarded.

### 7.3 Sphinx Packet Receiving and Processing

A mix node that receives a Sphinx packet is oblivious to its position in the
path. The
first hop is indistinguishable from other intermediary hops in terms of
processing and behavior.

After decrypting one layer of the Sphinx packet, the node MUST inspect the
routing information.
If this layer indicates that the next hop is the final destination, the packet
MUST be processed
as an exit. Otherwise, it MUST be processed as an intermediary.

#### 7.3.1 Intermediary Processing

To process a Sphinx packet as an intermediary, a mix node MUST:

- Extract the next hop address and associated delay from the decrypted packet.
- Wait for the specified delay.
- Forward the updated packet to the next hop using the Mix Protocol.

A mix node performing intermediary processing MUST treat each packet as
stateless and self-contained.

#### 7.3.2 Exit Processing

To process a Sphinx packet as an exit, a mix node MUST:

- Extract the plaintext message from the final decrypted packet.
- Validate any attached spam protection proof.
- Discard the message if spam protection validation fails.
- Forward the valid message to the Mix Exit Layer for delivery to the
destination origin protocol instance.

The node MUST NOT retain decrypted content after forwarding.

## 8. Sphinx Packet Format

The Mix Protocol uses the Sphinx packet format to enable unlinkable, multi-hop
message routing
with per-hop confidentiality and integrity. Each message transmitted through the
mix network is
encapsulated in a Sphinx packet constructed by the initiating mix node. The
packet is encrypted in
layers such that each hop in the mix path can decrypt exactly one layer and
obtain the next-hop
routing information and delay value, without learning the complete path or the
message origin.

Sphinx packets are self-contained and indistinguishable on the wire, providing
strong metadata
protection. Mix nodes forward packets without retaining state or requiring
knowledge of the
source or destination beyond their immediate routing target.

To ensure uniformity, each Sphinx packet consists of a fixed-length header and a
payload
that is padded to a fixed maximum size. Although the original message payload
may vary in length,
padding ensures that all packets are identical in size on the wire. This ensures
unlinkability
and protects against correlation attacks based on message size.

If a message exceeds the maximum supported payload size, it MUST be fragmented
before being passed
to the Mix Protocol. Fragmentation and reassembly are the responsibility of the
origin protocol
or the top-level application. The Mix Protocol handles only messages that do not
require
fragmentation.

The structure, encoding, and size constraints of the Sphinx packet are detailed
in the following
subsections.

### 8.1 Packet Structure Overview

Each Sphinx packet consists of three fixed-length header fields &mdash; $α$,
$β$, and $γ$ &mdash;
followed by a fixed-length encrypted payload $δ$. Together, these components
enable per-hop message
processing with strong confidentiality and integrity guarantees in a stateless
and unlinkable manner.

- **$α$ (Alpha)**: An ephemeral public value. Each mix node uses its private key
and $α$ to
derive a shared session key for that hop. This session key is used to decrypt
and process
one layer of the packet.
- **$β$ (Beta)**: The nested encrypted routing information. It encodes the next
hop address, the forwarding delay,
integrity check $γ$ for the next hop, and the $β$ for subsequent hops.
- **$γ$ (Gamma)**: A message authentication code computed over $β$ using the
session key derived
from $α$. It ensures header integrity at each hop.
- **$δ$ (Delta)**: The encrypted payload. It consists of the message padded to a
fixed maximum length and
encrypted in layers corresponding to each hop in the mix path.

At each hop, the mix node derives the session key from $α$, verifies the header
integrity
using $γ$, decrypts one layer of $β$ to extract the next hop and delay, and
decrypts one layer
of $δ$. It then constructs a new packet with updated values of $α$, $β$, $γ$,
and $δ$, and
forwards it to the next hop.

All Sphinx packets are fixed in size and indistinguishable on the wire. This
uniform format,
combined with layered encryption and per-hop integrity protection, ensures
unlinkability,
tamper resistance, and robustness against correlation attacks.

The structure and semantics of these fields, the cryptographic primitives used,
and the construction
and processing steps are defined in the following subsections.

### 8.2 Cryptographic Primitives

This section defines the cryptographic primitives used in Sphinx packet
construction and processing.

- **Security Parameter**: All cryptographic operations target a minimum of
$\kappa = 128$ bits of
security, balancing performance with resistance to modern attacks.

- **Elliptic Curve Group $\mathbb{G}$**:
  - **Curve**: Curve25519
  - **Purpose**: Used for deriving Diffie–Hellman-style shared key at each hop
using $α$.
  - **Representation**: Small 32-byte group elements, efficient for both
encryption and key exchange.

- **Key Derivation Function (KDF)**:
  - **Purpose**: To derive encryption keys, IVs, and MAC key from the shared
session key at each hop.
  - **Construction**: SHA-256 hash with output truncated to 128 bits.
  - **Key Derivation**: The KDF key separation labels (_e.g.,_ `"aes_key"`,
`"mac_key"`)
are fixed strings and MUST be agreed upon across implementations.

- **Symmetric Encryption**: AES-128 in Counter Mode (AES-CTR)
  - **Purpose**: To encrypt $β$ and $δ$ for each hop.
  - **Keys and IVs**: Each derived from the session key for the hop using the KDF.

- **Message Authentication Code (MAC)**:
  - **Construction**: HMAC-SHA-256 with output truncated to 128 bits.
  - **Purpose**: To compute $γ$ for each hop.
  - **Key**: Derived using KDF from the session key for the hop.

These primitives are used consistently throughout packet construction and
decryption, as described in the following sections.
