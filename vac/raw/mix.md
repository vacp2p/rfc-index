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

<<<<<<< HEAD
4. **Delta ($δ$)**: The encrypted payload, which can be of variable size.
   - According to the [MixMatch](https://petsymposium.org/popets/2024/popets-2024-0050.pdf)
    paper, the Nym network uses Sphinx packets of a fixed
    size (2413 bytes).
   - Considering this, the maximum $δ$ size can be chosen as 2413 bytes minus
    the header length (which will be derived below).
=======
The following subsections describe how the Mix Protocol integrates with origin
protocols via
the Mix Entry and Exit layers, how per-message anonymity is controlled through
the `mixify` flag,
the rationale for defining Mix as a protocol rather than a transport, and the
end-to-end message
interaction flow.
>>>>>>> main

### 5.1 Integration with Origin Protocols

libp2p protocols that wish to anonymize messages MUST do so by integrating with
the Mix Protocol
via the Mix Entry and Exit layers.

- The **Mix Entry Layer** receives messages to be _mixified_ from an origin
protocol and forwards them
to the local Mix Protocol instance.

<<<<<<< HEAD
The entire Sphinx packet header ($α$, $β$, and $γ$) can fit within a fixed size
of $32 + (r(t+1)+1)\kappa + 16 = 384$ bytes, leaving ample room for a large $δ$ of
up to $2413 - 384 = 2029$ bytes.
=======
- The **Mix Exit Layer** receives the final decrypted message from a Mix
Protocol instance and
forwards it to the appropriate origin protocol instance at the destination over
a client-only connection.
>>>>>>> main

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
<<<<<<< HEAD

```proto
message SphinxPacket {
  bytes alpha = 1; // 32 bytes
  bytes beta = 2; // 304 - 384 bytes
  bytes gamma = 3; // 16 bytes
  bytes delta = 4; // variable size, max 2029 bytes
}
```

### 5. Handler Function

The [handler function](https://docs.libp2p.io/concepts/fundamentals/protocols/#handler-functions)
is responsible for processing connections and messages for
the Mix protocol. It operates according to the mix node roles (_i.e.,_ sender,
intermediary mix node, or exit node) defined in
[Section 2.1](#21-mix-nodes-roles). This function is crucial for implementing
the core functionality of the mixnet protocol within the libp2p framework.

When a node receives a new stream for the `"/mix/1.0.0"` protocol, the handler
function is invoked. It performs different operations based on the node's role
in the current message path:

- **Role Determination**

  The handler first determines the node's role for the incoming message. This
  is typically done by examining the packet structure and the node's position
  in the network.

- **Packet Processing**

  Depending on the role, the handler processes the Sphinx packet differently:

  - For senders, it creates and sends new Sphinx packets.
  - For intermediary nodes, it processes and forwards existing packets.
  - For exit nodes, it decrypts the final layer and disseminates the original message.

- **Error Handling**

  It manages any errors that occur during packet processing, such as invalid
  MACs or decryption failures.

- **Logging and Metrics**

  The handler is also be responsible for logging important events and
  collecting metrics for network analysis and debugging.

The specific implementation of the handler function for each role (_i.e.,_
sender, intermediary, and exit node) is detailed in the following subsections.

#### 5.1 Sender

1. **Convert the libp2p Message to Bytes**

   Serialize the libp2p message to bytes and store the result in
   `libp2p_message`. This can be done using Protocol Buffers or another
   serialization method.

2. **Apply Spam Protection**

   Apply the chosen spam protection mechanism to the `libp2p_message`.
   This could be Proof of Work (PoW), Verifiable Delay Function (VDF),
   Rate Limiting Nullifier (RLN), or other suitable approaches.

   Refer to [Appendix A](#appendix-a-example-spam-protection-using-proof-of-work)
   for details on the current implementation using PoW.

3. **Prepare the Message**

   Prepare the `message` by combining the `libp2p_message` with any necessary data
   from the spam protection mechanism. The exact format of `message` will depend
   on the chosen spam protection method.

   Note: The spam protection mechanism is designed as a pluggable interface,
   allowing for different methods to be implemented based on network requirements.
   This flexibility extends to other components such as peer discovery and incentivization,
   which are not specified in detail to allow for future optimizations and adaptations.

4. **Perform Path Selection** (refer [Section 2.4](#24-node-discovery))

   - Let the Ed25519 public keys of the mix nodes in the path be
    $y_0,\ y_1,\ \ldots,\ y_{L-1}$.

5. **Wrap Final Message in Sphinx Packet**
   Perform the following steps to wrap `message` in a Sphinx packet:

   a. **Compute** **Alphas ($α_i$**, **$i=0$** to **$L-1$)**

   - Select a random exponent $x$ from $\mathbb{Z}_q^*$.
   - Compute initial alpha $α_0$, shared secret $s_0$, and blinding factor $b_0$:
     - $α_0 = g^x$ using Curve25519 scalar multiplication.
     - $s_0 = y_0^x$, where $y_0$ is the public key of the first hop.
     - $b_0 = H(α_0\ |\ s_0)$, where $H$ is the SHA-256 hash function (refer
      _[Section 3](#3-cryptographic-primitives-and-security-parameter)_ for details).
   - For each node $i$ (from $1$ to $L-1$):
     - $α_i = α_{i-1}^{b_{i-1}}$ using Curve25519 scalar multiplication.
     - $s_i = y_{i}^{x\prod_{\text{j=0}}^{\text{i-1}} b_{j}}$, where $y_{i}$ is
      the public key of the i-th hop.
     - $b_i = H(α_i\ |\ s_i)$, where $H$ is the SHA-256 hash function.

   Note that $\alpha_i$ and $s_i$ are group elements, each 32 bytes long.

   b. **Compute** **Filler Strings ($\phi_i$**, **$i=0$** to **$L-1$)**

   - Initialize $\phi_0$ as an empty string.
   - For each $i$ (from $1$ to $L-1$):

     - Derive the AES key and IV:

       $`\text{φ\_aes\_key}_{i-1} = KDF(\text{"aes\_key"}\ |\ s_{i-1})`$

       $`\text{φ\_iv}_{i-1} = H(\text{"iv"}\ |\ s_{i-1})`$ (truncated to 128 bits)

     - Compute the filler string $\phi_i$ using $\text{AES-CTR}^\prime_i$,
       which is AES-CTR encryption with the keystream starting from
       index $((t+1)(r-i)+t+2)\kappa$ :

       $`\phi_i = \text{AES-CTR}^\prime_i(\text{φ\_aes\_key}_{i-1},\ \text{φ\_iv}_{i-1},
       \ \phi_{i-1}\ |\ 0_{(t+1)\kappa})`$,
       where $0_{(t+1)\kappa}$ is the string of $0$ bits of length $(t+1)\kappa$.

   Note that the length of $\phi_i$ is $(t+1)i\kappa$.

   c. **Compute** **Betas and Gammas ($\beta_i$**, $\gamma_i$, **$i=0$** to **$L-1$)**

   For each $i$ (from $L-1$ to $0$):

   - Derive the AES key, MAC key, and IV:

     $`\text{β\_aes\_key}_{i} = KDF(\text{"aes\_key"}\ |\ s_{i})`$

     $`\text{mac\_key}_{i} = KDF(\text{"mac\_key"}\ |\ s_{i})`$

     $`\text{β\_iv}_{i} = H(\text{"iv"}\ |\ s_{i})`$ (truncated to 128 bits)

   - Generate random $`\text{delay\_i}`$, a 16-bit unsigned integer (0-65535 milliseconds).

     Note that top-level applications can use other probability distributions,
     such as an exponential distribution, where shorter delays are more likely
     than longer delays. This can mimic real-world traffic patterns and provide
     robust anonymity against traffic analysis. The trade-off lies in balancing
     the need for flexible delay handling with the risk of exposing
     application-specific traffic patterns.

   - If $i = L-1$ (_i.e.,_ exit node):

     $`\beta_i = \text{AES-CTR}(\text{β\_aes\_key}_{i},\ \text{β\_iv}_{i},\ 0_{((t+1)
     (r-L)+t+2)\kappa})\ |\ \phi_{L-1}`$

   - Otherwise (_i.e.,_ intermediary node):

     $`\beta_i = \text{AES-CTR}(\text{β\_aes\_key}_{i},\ \text{β\_iv}_{i},\ \text
     {addr}_{i+1} \ |\ \text{delay}_{i+1}\ | \ \gamma_{i+1}\ |\ {\beta_{i+1}}_
     {[0\ldots(r(t+1)-t)\kappa−1]})`$

     Note that the length of $\beta_i$ is $(r(t+1)+1)\kappa$, $0 \leq i \leq L-1$,
     where $t$ is the combined length of next hop address and delay.

   - $`\gamma_i = \text{HMAC-SHA-256}(\text{mac\_key}_i,\ β_i)`$\
      Note that the length of $\gamma_i$ is $\kappa$.

   d. **Compute** **Deltas (**$\delta_i$, **$i=0$** to **$L-1$)**

   For each $i$ (from $L-1$ to $0$):

   - Derive the AES key and IV:

     $`\text{δ\_aes\_key}_{i} = KDF(\text{"δ\_aes\_key"}\ |\ s_{i})`$

     $`\text{δ\_iv}_{i} = H(\text{"δ\_iv"}\ |\ s_{i})`$ (truncated to 128 bits)

   - If $i = L-1$ (_i.e.,_ exit node):

     $`\delta_i = \text{AES-CTR}(\text{δ\_aes\_key}_{i},\ \text{δ\_iv}_{i},
     \ 0_{\kappa}\ |\ m)`$, where $m$ is the `message`.

   - Otherwise (_i.e.,_ intermediary node):

     $`\delta_i = \text{AES-CTR}(\text{δ\_aes\_key}_{i},\ \text{δ\_iv}_{i},\ \delta_{i+1})`$

     Note that the length of $\delta$ is $|m| + \kappa$.

     Given that the derived size of $\delta$ is $2029$ bytes, this allows
     `message` to be of length $2029-16 = 2013$ bytes. This means smaller
     messages may need to be padded up to $2013$ bytes (e.g., using PKCS#7
     padding).

   e. **Construct Final Sphinx Packet**

   - Initialize header

     ```pseudocode
     alpha = alpha_0 // 32 bytes
     beta = beta_0 // $(r(t+1)+1)\kappa$ bytes
     gamma = gamma_0 // 16 bytes
     ```

     As discussed earlier, for a maximum path length of $r = 5$, and combined
     length of address and delay $t = 3\kappa = 48$ bytes, the header size is
     just $384$ bytes.
   - Initialize payload

     `delta = delta_0 // variable size, max 2029 bytes`

     For a fixed Sphinx packet size of $2413$ bytes and given the header length
     of $384$ bytes, `delta` size is $2029$ bytes.

6. **Serialize the Sphinx Packet** using Protocol Buffers.

7. **Send the Serialized Packet** to the first mix node using the
   `"/mix/1.0.0"` protocol.

#### 5.2 Intermediary Mix Node

Let $`x_i \in \mathbb{Z}_q^*`$ be the intermediary node’s private key
corresponding to the public key $y_i \in G^*$. It performs the following steps
to relay a message:

1. **Receive and Deserialize** the Sphinx packet using Protocol Buffers.
2. **Compute Shared Secret $s = \alpha^{x_{i}}$**.

3. **Check If Previously Seen**

   a. Compute tag $H(s)$, where $H$ is the SHA-256 hash function.

   b. If tag is in the previously seen list of tags, discard the message.

   c. This list can be reset whenever the node rotates its private key

4. **Compute MAC**

   a. Derive MAC key

   $`\text{mac\_key} = KDF(\text{"mac\_key"}\ |\ s)`$

   b. Check if $`\gamma = \text{HMAC-SHA-256}(\text{mac\_key},\ β)`$ . If not,
   discard the message.

   c. Otherwise, store tag $H(s)$ in the list of seen message tags.

5. **Decrypt One Layer**

   a. Derive the AES key, MAC key, and IV:

   $`\text{β\_aes\_key} = KDF(\text{"aes\_key"}\ |\ s)`$

   $`\text{β\_iv} = H(\text{"iv"}\ |\ s)`$ (truncated to 128 bits)

   b. Compute
   $`B = \text{AES-CTR}(\text{β\_aes\_key},\ \text{β\_iv},\ \beta\ |\ 0_{(t+1)k})`$.

   c. Uniquely parse prefix of $B$

   If $B$ has a prefix of **$0_{((t+1)(r-L)+t+2)\kappa}$,** the current node is the
   exit node (refer exit node operations below).

   Otherwise, it is an intermediary node and it performs the followings steps
   to relay the message.

   d. **Extract Routing Information**

   $`\text{next\_hop} = B_{[0\ldots(t\kappa-17)]}`$ (first $t\kappa-2$ bytes).

   e. **Extract Delay**

   $`\text{delay} = B_{[(t\kappa-16)\ldots(t\kappa-1)]}`$ (following $2$ bytes).

   f. **Extract Gamma**

   $`{\gamma}' = B_{[t\kappa\ldots(t\kappa+\kappa-1)]}`$ (following $\kappa$ bytes).

   g. **Extract Beta**

   $`\beta' = B_{[(t\kappa+\kappa)\ldots(r(t+1)+t+2)\kappa-1]}`$ (following
   $((t+1)r + 1)\kappa$ bytes).

   h. **Compute Alpha**

   - Compute blinding factor $b = H(α\ |\ s)$, where $H$ is the SHA-256 hash
    function.
   - Compute $α^′ = α^b$.

   i. **Compute Delta**

   - Derive the AES key and IV:
     $`\text{δ\_aes\_key} = KDF(\text{"δ\_aes\_key"}\ |\ s)`$
     $`\text{δ\_iv} = H(\text{"δ\_iv"}\ |\ s)$` (truncated to 128 bits)
   - Compute $`\delta' = \text{AES-CTR}(\text{δ\_aes\_key},\ \text{δ\_iv},\ \delta)`$

6. **Construct Final Sphinx Packet**

   a. Initialize header

   ```pseudocode
    alpha = alpha' // 32 bytes
    beta = beta' // $((t+1)r + 1)\kappa$ bytes
    gamma = gamma' // 16 bytes
   ```

   b. Initialize payload

   `delta = delta' // variable size, max 2029 bytes`

7. **Serialize the Sphinx Packet** using Protocol Buffers.
8. **Introduce A Delay** of $`\text{delay}`$ milliseconds.
9. **Send the Serialized Packet** to $`\text{next\_hop}`$ using the
    `"/mix/1.0.0"` protocol.

#### 5.3 Exit Node

1. **Perform _Steps i. to v. b._ Above**, similar to an intermediary node. If
   $B$ has a prefix of $0_{((t+1)(r-L)+t+2)\kappa}$ (in _step 5. c._ above), the
   current node is the exit node. It performs the following steps to
   disseminate the message via the respective libp2p protocol.

2. **Compute Delta**

   - Derive the AES key and IV:

     $`\text{δ\_aes\_key} = KDF(\text{"δ\_aes\_key"}\ |\ s)`$

     $`\text{δ\_iv} = H(\text{"δ\_iv"}\ |\ s)`$ (truncated to 128 bits)

   - Compute $`\delta' = \text{AES-CTR}(\text{δ\_aes\_key},\ \text{δ\_iv},\ \delta)`$.

3. **Extract Message**

   $m = \delta'_{[\kappa\ldots]}$ (remove first $\kappa$ bytes).

4. **Remove Any Padding** from $m$ to obtain the `message` including any
   necessary spam protection data.

5. **Verify Spam Protection**

   Verify the spam protection mechanism applied to the `message`.
   If the verification fails, discard the `message`.
   Refer to [Appendix A](#appendix-a-example-spam-protection-using-proof-of-work)
   for details on the current implementation using PoW.

6. **Deserialize the extracted message** using the respective libp2p protocol's
   definition.

7. **Disseminate the message** via the respective libp2p protocol (_e.g.,_
   GossipSub).

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

### Normative

[Handler function](https://docs.libp2p.io/concepts/fundamentals/protocols/#handler-functions)
[libp2p](https://libp2p.io)\
[Sphinx](https://cypherpunks.ca/~iang/pubs/Sphinx_Oakland09.pdf)

### Informative

[PoW](https://bitcoin.org/bitcoin.pdf)\
[Sphinx packet size](https://petsymposium.org/popets/2024/popets-2024-0050.pdf)

## Appendix A. Example Spam Protection using Proof of Work

The current implementation uses a Proof of Work mechanism for spam protection.
This section details the specific steps for attaching and verifying the PoW.

### Structure

The sender appends the PoW to the serialized libp2p message, `libp2p_message`,
in a structured format, making it easy to parse and verify by the exit node.
The sender includes the PoW as follows:

 `message = <libp2p_message_bytes | timestamp | nonce>`

where:

 `<libp2p_message_bytes>`: Serialized libp2p message (variable length).

`<timestamp>`: The current Unix timestamp in seconds (4 bytes).

`<nonce>`: The nonce that satisfies the PoW difficulty criterion (4 bytes).

**Nonce Size:** The nonce size should be large enough to ensure a sufficiently large
search space. It should be chosen so that the range of possible nonce values
allows for the difficulty target to be met. However, larger nonce sizes can increase
the time and computational effort required to find a valid nonce. We use
a 4-byte nonce to ensure sufficiently large search space with reasonable
computational effort.

**Difficulty Level:** The difficulty level is usually expressed as the number of
leading zeros required in the hash output. It is chosen such that the
computational effort required is significant but not prohibitive.
We recommend a reasonable difficulty level that requires around
16-18 leading zeros in the SHA-256 hash. This would roughly take
0.65 to 2.62 seconds to compute in a low-grade CPU,
capable of computing 100,000 hashes per second.

### Calculate Proof of Work (PoW)

The sender performs the following steps to compute the PoW challenge and response:

i. **Create Challenge**

Retrieves the current Unix timestamp, `timestamp`, in seconds (4 bytes).

ii. **Find A Valid Nonce**

- Initializes the `nonce` to a 4-byte value (initially zero).
  
- Increments the `nonce` until the SHA-256 hash of
  `<libp2p_message_bytes | timestamp | nonce>` has at least
  18 leading zeros.

- The final value of the `nonce` is considered valid.

### Attach the PoW to the libp2p Message

  Append the 4-byte `timestamp` and the valid `nonce` to
  the `libp2p_message_bytes` to form the `message`.

  `message = <libp2p_message_bytes | timestamp | nonce>`

### Verify PoW
  
i. **Extract Timestamp and Nonce**

  Split `message` into 4-byte `nonce` (last 4 bytes), 4-byte `timestamp`
  (the 4 bytes before the nonce), and the serialized libp2p message
  to be published, `libp2p_message_bytes` (the remaining bytes).

ii. **Verify Timestamp**
  
- Check the `timestamp` is within the last 5 minutes.
  
- If the timestamp is outside the acceptable window, the exit node
  discards the message.

iii. **Verify Response**

- Compute the SHA-256 hash of the `message` and check if the hash
  meets the difficulty requirement, _i.e._, has at least 18 leading zeros.
  
- If the hash is not valid, the exit node discards the message. Otherwise,
  it follows the steps to publish the message.
=======
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
>>>>>>> main
