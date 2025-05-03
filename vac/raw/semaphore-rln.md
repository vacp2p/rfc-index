---
title: WAKU2-SEMAPHORE-RATE-LIMIT
name: Semaphore-based Rate Limiting for Waku
status: raw
category: Standards Track
tags: [waku/core-protocol]
editor: [Your Name]
contributors:
---

## Abstract

This document specifies how the Semaphore zero-knowledge protocol can be used to implement rate-limiting functionality in Waku, either as an alternative to or alongside the existing Rate-Limiting Nullifier (RLN) mechanism. Semaphore provides a privacy-preserving way to enforce message rate limits while maintaining sender anonymity. This approach offers potential advantages in flexibility, scalability, and implementation complexity when compared to the current RLN implementation.

## Background / Rationale / Motivation

Waku currently uses the Rate-Limiting Nullifier (RLN) protocol as its primary mechanism for spam prevention in anonymous peer-to-peer settings. RLN is built on top of Semaphore but with additional components for rate limiting and slashing. While effective, the current implementation has some limitations:

1. **Fixed Rate Limits**: The current RLN implementation in Waku enforces a global rate limit that is the same for all users.

2. **Implementation Complexity**: The current RLN implementation involves complex components such as Shamir's Secret Sharing for slashing, making it potentially more difficult to maintain and extend.

3. **Limited Flexibility**: The current architecture may not easily support dynamic rate limits or different rate-limiting strategies for different use cases.

Semaphore, as a more fundamental primitive, provides an opportunity to implement rate limiting with greater flexibility while still preserving the privacy benefits needed for Waku protocols.

## Theory / Semantics

### Semaphore Overview

Semaphore is a zero-knowledge protocol that allows users to prove their membership in a group and send signals anonymously. It uses zero-knowledge proofs to verify membership in a Merkle tree without revealing the member's identity.

The key components of Semaphore include:

1. **Identity**: A user's private identity, typically consisting of a trapdoor and a nullifier
2. **Identity Commitment**: A public commitment of the user's identity added to the Merkle tree
3. **External Nullifier**: A value that prevents double-signaling for a given context
4. **Signal**: The actual data being transmitted anonymously

### Semaphore-based Rate Limiting Approach

This proposal outlines a more flexible approach to rate limiting using Semaphore:

1. **Time-based External Nullifiers**: External nullifiers are generated based on time epochs. For example, each minute (or configurable time unit) generates a new external nullifier.

2. **Customizable Rate Limits**: Different groups of users can have different rate limits enforced by Semaphore.

3. **Scalable Implementation**: Allow for a simpler implementation that can be easily scaled according to network needs.

### Differences from Current RLN Implementation

The key differences from the current RLN implementation are:

1. **Simplified Approach**: We use basic Semaphore properties without the additional layer of secret sharing for slashing.

2. **Flexible Rate Limits**: Support for different rate limits for different user groups.

3. **Deterministic Time Windows**: Rate limiting based on deterministic time windows rather than message sequence.

## Wire Format Specification / Syntax

### Message Format

Messages using Semaphore-based rate limiting will contain the following fields:

```protobuf
message SemaphoreRateLimitProof {
  // The Merkle root of the group
  bytes merkle_root = 1;
  
  // The external nullifier (derived from current time epoch)
  bytes external_nullifier = 2;
  
  // The nullifier hash
  bytes nullifier_hash = 3;
  
  // The zero-knowledge proof
  bytes proof = 4;
  
  // Optional: Intended message rate limit (messages per epoch)
  uint32 rate_limit = 5;
  
  // Optional: Group identifier
  bytes group_id = 6;
}

// Extend the existing WakuMessage
message WakuMessage {
  // Existing fields...
  
  // Optional Semaphore rate limiting proof
  SemaphoreRateLimitProof semaphore_proof = 7;
}
```

### Protocol Flow

1. **Group Registration**:
   - Users register their identity commitments to a Semaphore group
   - Group parameters include the rate limit (messages per epoch)
   - Multiple groups with different rate limits can exist simultaneously

2. **Message Sending**:
   - When sending a message, a user generates a current epoch external nullifier
   - The user creates a zero-knowledge proof of their membership in the group
   - The proof and associated data are attached to the Waku message

3. **Message Verification**:
   - Receiving nodes verify the Semaphore proof
   - Nodes maintain a record of nullifier hashes seen for each epoch
   - If a nullifier is reused within the same epoch more times than the rate limit allows, the message is rejected

### Implementation Requirements

Nodes implementing Semaphore-based rate limiting for Waku MUST:

1. Maintain at least one Merkle tree of registered identity commitments
2. Track nullifier hashes for each time epoch to enforce rate limits
3. Verify Semaphore proofs attached to incoming messages
4. Reject messages that exceed their rate limit

Nodes implementing Semaphore-based rate limiting for Waku SHOULD:

1. Support multiple Semaphore groups with different rate limits
2. Implement a mechanism to garbage collect old nullifier records
3. Optimize proof verification to minimize performance impact

## Integration with Existing Waku Protocols

### Relay Integration

Semaphore-based rate limiting can be integrated with Waku Relay protocol as a validation mechanism. Nodes can validate incoming messages against rate limits before relaying them to other peers.

### Store Integration

Waku Store nodes can implement Semaphore validation for queries to prevent spam.

### Filter Integration

Filter nodes can use Semaphore validation to ensure clients don't exceed subscription limits.

### Compatibility with RLN

This specification is designed to be compatible with the existing RLN implementation. Nodes can support both mechanisms simultaneously or use one based on configuration preferences. This allows for a smooth transition between mechanisms if desired.

## Security/Privacy Considerations

### Privacy Benefits

Semaphore-based rate limiting preserves user privacy by:

1. Not revealing the sender's identity when sending messages
2. Ensuring that messages cannot be linked to a specific user identity
3. Protecting against tracking across different content topics

### Security Considerations

Key security aspects to consider:

1. **Collusion Resistance**: The system should be resistant to collusion between users to exceed rate limits.

2. **Sybil Resistance**: The registration process must have sufficient barriers to prevent Sybil attacks.

3. **Denial of Service Protection**: The verification of zero-knowledge proofs must be efficient enough to prevent computational DoS attacks.

4. **Parameter Selection**: The choice of epoch duration and rate limits must balance between usability and spam prevention.

5. **Time Synchronization**: Nodes must have reasonably synchronized clocks for epoch-based rate limiting to function properly.

## Limitations

1. **No Slashing Mechanism**: Unlike RLN, this approach doesn't inherently support slashing (economic penalization) of spammers.

2. **Group Size Limits**: Very large Merkle trees may impact performance, potentially limiting the maximum group size.

3. **Time Sensitivity**: The approach relies on time-based epochs, making it sensitive to clock synchronization issues.

## Future Work

1. **Dynamic Rate Limiting**: Implement mechanisms for dynamically adjusting rate limits based on network conditions.

2. **Optional Slashing Layer**: Add an optional slashing mechanism for environments where economic penalties are desired.

3. **Proof Aggregation**: Explore techniques to aggregate multiple Semaphore proofs to improve efficiency in high-volume scenarios.

4. **Cross-Group Rate Limiting**: Develop mechanisms to enforce limits across multiple groups.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [Semaphore Protocol](https://semaphore.appliedzkp.org/)
2. [Rate Limiting Nullifier Protocol](https://rate-limiting-nullifier.github.io/rln-docs/)
3. [Waku RLN Relay](https://github.com/vacp2p/rfc-index/blob/main/waku/standards/core/17/rln-relay.md)
4. [Semaphore RLN, rate limiting nullifier for spam prevention](https://ethresear.ch/t/semaphore-rln-rate-limiting-nullifier-for-spam-prevention-in-anonymous-p2p-setting/5009)
5. [Strengthening Anonymous DoS Prevention with Rate Limiting Nullifiers in Waku](https://vac.dev/rlog/rln-anonymous-dos-prevention/)