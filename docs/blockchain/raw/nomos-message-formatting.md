# NOMOS-MESSAGE-FORMATTING

| Field | Value |
| --- | --- |
| Name | Nomos Message Formatting Specification |
| Slug | 89 |
| Status | raw |
| Category | Standards Track |
| Editor | Marcin Pawlowski |
| Contributors | Youngjoon Lee <youngjoon@logos.co>, Alexander Mozeika <alexander.mozeika@logos.co>, Álvaro Castro-Castilla <alvaro@logos.co>, Filip Dimitrijevic <filip@logos.co> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/logos-co/logos-lips/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/blockchain/raw/nomos-message-formatting.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/logos-co/logos-lips/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/blockchain/raw/nomos-message-formatting.md) — Chore/mdbook updates (#258)

<!-- timeline:end -->

# Revision History

| Version | Changes | Date |
| --- | --- | --- |
| 1.0.0 | Initial revision. | 2026-04-09 |

# Introduction

This document defines an implementation-friendly specification of the Message Formatting, which is introduced in the [[1.0.0] Blend Protocol - Formatting](https://nomos-tech.notion.site/Formatting-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df818fb2decabd859c0647) section.

In this document we are reusing notation from [[1.0.0] Message Encapsulation Mechanism - Notation](https://nomos-tech.notion.site/Notation-215261aa09df81309d7fd7f1c2da086b?pvs=24#215261aa09df81df8604de53e43e134a).

# Overview

The message contains a header and a payload. The header informs the protocol about the version of the protocol and the payload type. The message contains a drop or a non-drop payload. The length of a payload is fixed to prevent adversaries from distinguishing types of messages based on their length.

# Construction

## Message

The Message is a structure that contains a public_header, private_header and a payload.

```
class Message:
  	public_header: PublicHeader,
	  private_header: Private_Header,
	  payload: bytes
```

### Public Header

The public_header must be generated as the outcome of the [[1.0.0] Message Encapsulation Mechanism](https://nomos-tech.notion.site/1-0-0-Message-Encapsulation-Mechanism-215261aa09df81309d7fd7f1c2da086b?pvs=24).

The public_header is defined as follows:

```
class PublicHeader:
		version: byte,
public_key: PublicKey,
	  proof_of_quota: ProofOfQuota,
  	signature: Signature
```

Where:

- version=0x01 is version of the protocol.
- public_key is $K^{n}_i$, a public key from the set $\mathbf K^n_h$ as defined in the [Message Encapsulation](https://nomos-tech.notion.site/215261aa09df81309d7fd7f1c2da086b?pvs=25#215261aa09df814f8c13c1389d244c46) spec.
- proof_of_quota is $\pi^{K^{n}_i}_{Q}$, a corresponding proof of quota for the key $K^{n}_i$ from the $\mathbf K^n_h$ it also contains the key nullifier.
- signature is $\sigma_{K^{n}_{i}}(\mathbf {h|P}_i)$, a signature of the concatenation of the $i$-th encapsulation of the payload $\mathbf P$ and the private header $\mathbf h$, that can be verified by the public key $K^{n}_{i}$.

### Private Header

The private_header must be generated as the outcome of the [[1.0.0] Message Encapsulation Mechanism](https://nomos-tech.notion.site/1-0-0-Message-Encapsulation-Mechanism-215261aa09df81309d7fd7f1c2da086b?pvs=24).

The private header contains a set of encrypted blending headers $\mathbf h = (\mathbf b_1,...,\mathbf b_{h_{max}})$.

```
private_header: list[BlendingHeader]
```

The size of the set is limited to $\beta_{max}=3$ BlendingHeader entries, as defined in the [[1.0.0] Blend Protocol - Global Parameters](https://nomos-tech.notion.site/Global-Parameters-215261aa09df81ae8857d71066a80084?pvs=24#215261aa09df8108a3f4e5bdd8f4a4f3).

The BlendingHeader ($\mathbf b_l$) is defined as follows:

```
class BlendingHeader:
	  public_key: PublicKey,
	  proof_of_quota: ProofOfQuota,
	  signature: Signature,
	  proof_of_selection: ProofOfSelection
	  is_last: byte
```

Where:

- public_key is $K^{n}_{l}$, a public key from the set $\mathbf K^n_h$.
- proof_of_quota is $\pi^{K^{n}_l}_{Q}$, a corresponding proof of quota for the key $K^{n}_l$ from the $\mathbf K^n_h$ it also contains the key nullifier.
- signature is $\sigma_{K^{n}_{l}}(\mathbf {h|P}_l)$, a signature of the concatenation of $l$-th encapsulation of the payload $\mathbf P$ and the private header $\mathbf h$, that can be verified by public key $K^{n}_{l}$.
- proof_of_selection is $\pi^{K^{n}_{l+1},m_{l+1}}_{S}$, a proof of selection of the node index $m_{l+1}$ assuming valid proof of quota $\pi^{K^{n}_{l}}_{Q}$.
- is_last is $\Omega$, a flag that indicates that this is the last encapsulation.

### Payload

The payload must be formatted according to the [[1.0.0] Payload Formatting](https://nomos-tech.notion.site/1-0-0-Payload-Formatting-215261aa09df8153a456c555b7dcbe1c?pvs=24). The formatted payload must be generated as the outcome of the [[1.0.0] Message Encapsulation Mechanism](https://nomos-tech.notion.site/1-0-0-Message-Encapsulation-Mechanism-215261aa09df81309d7fd7f1c2da086b?pvs=24).

## Maximum Payload Length

The Max_Payload_Length parameter defines the maximum length of the payload, which for version 1 of the Blend Protocol is fixed as Max_Payload_Length=34003. That is, 34kB for the payload body (Max_Body_Length) and 3 bytes for the payload header. More information about payload formatting can be found in [[1.0.0] Payload Formatting](https://nomos-tech.notion.site/1-0-0-Payload-Formatting-215261aa09df8153a456c555b7dcbe1c?pvs=24).

