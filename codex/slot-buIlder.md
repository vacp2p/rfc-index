---
title: CODEX-SLOT-BUILDER
name: Codex Slot Builder
status: raw
tags: codex
editor:
contributors:
---

## Abstract

The Codex slot builder module partitions dataset blocks into slots,
builds individual Merkle trees for each slot enabling cell-level proof generation, and
constructs a root verification tree over all slot roots.

## Background

The Codex protocol places dataset blocks provided to the network by requester into slots.
Slots are then stored by nodes in the marketplace.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “NOT RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [RFC 2119](https://www.ietf.org/rfc/rfc2119.txt).

Build block-level digest trees from raw data
A storage request requires the dataset to 

Construct slot trees from block digests
Create verification trees from slot roots
Manage empty blocks and padding
Store cryptographic proofs in the block store

