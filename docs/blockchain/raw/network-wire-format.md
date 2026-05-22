# NETWORK-WIRE-FORMAT

| Field | Value |
| --- | --- |
| Name | Network Wire Format |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | Daniel Sanchez Quiros <danielsq@logos.co> |
| Contributors | Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

<!-- timeline:end -->

---

> **Note on this import:** This spec was imported from Notion on 2026-05-22.
> The body below preserves the source text and needs a formatting pass for COSS conventions
> (semantic line breaks, code block markers, table formatting, internal cross-references).
> Treat this commit as the initial migration; subsequent PRs should polish the formatting incrementally.

---

Authors: Daniel Sanchez Quiros <danielsq@logos.co>
Revision History
Version
	
Changes
	
Date


1.0.0
	
Initial revision.
	
2025-08-20


1.0.1
	
Renamed Nomos to Logos Blockchain
	
2026-04-17
Introduction
The Logos Blockchain consists of multiple networks. Peers within these networks need a common language to exchange information effectively. This document defines the standardized language used for this communication.
This document outlines a clear strategy for writing and reading messages transmitted across various Logos Blockchain networks.
The key objectives of this wire format are to have message structures that are sharable across different implementations and languages, and to use a stable encoding and decoding processes that do not depend on interpretation.
Overview
The Logos Blockchain relies on established message structures and standard encoding/decoding formats rather than creating new ones. All messages follow familiar patterns and utilize widely-adopted industry standards for encoding and decoding.
All data transmitted across Logos Blockchain networks adheres to a single consistent format and serialization structure. The schemas are designed to be compatible with or easily implementable in various programming languages.
Construction
Format
Logos Blockchain messages use C layout representation. This means that regardless of the programming language, the order, size, and alignment of fields follow the standardized C/C++ layout.
When you see a message in the specification (typically in Python format), you can easily translate it to its equivalent C-based structure.
For example:
Python
@dataclass
class Foo:
	data: bytes
	size: int

​
Rust
#[repr(c)]
struct Foo {
	data: Vec<u8>,
	size: usize
}

​
C
struct Foo
{
	data: *uint8_t
	size: size_t
}

​
Encoding and Decoding
Logos Blockchain messages are encoded using bincode - a compact binary serialization format with zero overhead. The format is defined as "a compact encoder/decoder pair that uses a binary zero-fluff encoding scheme." Bincode has been battle-tested in other blockchain protocol implementations, making it production-ready.
The complete specification can be found in the official documentation.
Reference
C structure layout
Rust repr(c)
Bincode serialization specification
Bincode rust crate docs
