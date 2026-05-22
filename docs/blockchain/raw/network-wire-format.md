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

> **Note on this import:** Body imported from the Notion source on 2026-05-22.
> Math equations are preserved as LaTeX ($...$ / $$...$$) rendered via katex; tables and headings
> are converted from Notion HTML. A formatting polish (semantic line breaks, code block fences
> for code samples, internal cross-references) is still recommended.

---

## Revision History

|  |  |  |
| --- | --- | --- |
| Version | Changes | Date |
| 1.0.0 | Initial revision. | 2025-08-20 |
| 1.0.1 | Renamed Nomos to Logos Blockchain | 2026-04-17 |

## Introduction

The Logos Blockchain consists of multiple networks. Peers within these networks need a common language to exchange information effectively. This document defines the standardized language used for this communication.

This document outlines a clear strategy for writing and reading messages transmitted across various Logos Blockchain networks.

The key objectives of this wire format are to have message structures that are sharable across different implementations and languages, and to use a stable encoding and decoding processes that do not depend on interpretation.

## Overview

The Logos Blockchain relies on established message structures and standard encoding/decoding formats rather than creating new ones. All messages follow familiar patterns and utilize widely-adopted industry standards for encoding and decoding.

All data transmitted across Logos Blockchain networks adheres to a single consistent format and serialization structure. The schemas are designed to be compatible with or easily implementable in various programming languages.

## Construction

### Format

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
data: \*uint8\_t
size: size\_t
}

​

### Encoding and Decoding

Logos Blockchain messages are encoded using

bincode

- a compact binary serialization format with zero overhead. The format is defined as "a compact encoder/decoder pair that uses a binary zero-fluff encoding scheme." Bincode has been battle-tested in other blockchain protocol implementations, making it production-ready.

The complete specification can be found in the [official documentation](https://git.sr.ht/~stygianentity/bincode/tree/trunk/item/docs/spec.md).

## Reference

[C structure layout](https://www.gnu.org/software/c-intro-and-ref/manual/html_node/Structure-Layout.html)

[Rust](https://doc.rust-lang.org/nomicon/other-reprs.html#reprc) [repr(c)](https://doc.rust-lang.org/nomicon/other-reprs.html#reprc)

[Bincode serialization specification](https://git.sr.ht/~stygianentity/bincode/tree/trunk/item/docs/spec.md)

[Bincode rust crate docs](https://docs.rs/bincode/2.0.1/bincode/)

Sign up or log in

Report page

Cookie settings

Pages

Loading...

[🔀

[1.0.1] Network Wire Format

Current Page

—

The Logos Blockchain Project

/

Specifications](https://nomos-tech.notion.site/1-0-1-Network-Wire-Format-21e261aa09df809fa107fc6146a1eb35?pvs=26&qid=1:dd40148d-c2e0-4f3f-a339-3bee671acd0c:0)

🔀

The Logos Blockchain Project

/

Specifications

[1.0.1] Network Wire Format

Revision History

Table

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

Rust

#[repr(c)]
struct Foo {
data: Vec<u8>,
size: usize
}

C

struct Foo
{
data: \*uint8\_t
size: size\_t
}

Encoding and Decoding

Logos Blockchain messages are encoded using bincode - a compact binary serialization format with zero overhead. The format is defined as "a compact encoder/decoder pair that uses a binary zero-fluff encoding scheme." Bincode has been battle-tested in other blockchain protocol implementations, making it production-ready.

The complete specification can be found in the official documentation.

Reference

- C structure layout
- Rust repr(c)
- Bincode serialization specification
- Bincode rust crate docs

- Open in new tab
