# MANTLE-TRANSACTION-ENCODING

| Field | Value |
| --- | --- |
| Name | Mantle Transaction Encoding |
| Slug |  |
| Status | raw |
| Category | Standards Track |
| Editor | David Rusu <davidrusu@logos.co> |
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

Authors: David Rusu <davidrusu@logos.co>

Revisions History

Version 

Changes 

Date

1.0.0 

Initial revision. 

2026-12-01

1.1.0 

����[RFC] Make Ledger Transaction an Operation��� 

2026-03-25

1.2.0 

����[RFC] Add Deposit/Withdraw to Tx Encoding 

2026-04-02

1.3.0 

����[RFC] Enforce NoteId uniqueness 

2026-04-24

1.4.0 

����[RFC] Simplify Mantle Transaction and Refactor Ledger Operations 

2026-05-06

1.4.1 

Removed mention of DA. Updated 
KeyCount from 
Byte to 
UINT16 to follow Mantle. 

2026-05-21

Introduction

This document specifies the canonical encoding of Mantle transactions (see ����[1.5.0] Mantle - Mantle Transaction) and it���s sub-components. Transactions sent through the mempool and included in blocks use this encoding.

Overview

The transaction encoding is specified in ABNF form to remove any ambiguity and guarantee a canonical encoding. The high level encoding choices which were not immediately derivable from the Mantle specification are listed here:

All multi-byte integers use little-endian encoding

Any lists are length-prefixed with fixed width uints

We derive number of proofs and type of proof from the Ops list parsed earlier

Specification

Signed Mantle Tx

SignedMantleTx = MantleTx OpsProofs

���

Mantle Tx

MantleTx = OpCount *Op
OpCount = Byte

���

Operations

Op = Opcode OpPayload
Opcode = Byte

OpPayload = Transfer /
ChannelInscribe /
ChannelConfig /
ChannelDeposit /
ChannelWithdraw /
SDPDeclare /
SDPWithdraw /
SDPActive /
LeaderClaim 

���

Channel Operations

ChannelInscribe = ChannelId Inscription Parent Signer
Inscription = UINT32 *BYTE 

ChannelConfig = ChannelId KeyCount *Signer PostingTimeframe PostingTimeout ConfigThreshold WithdrawThreshold
KeyCount = UINT16
PostingTimeframe = UINT32
PostingTimeout = UINT32
ConfigThreshold = UINT16
WithdrawThreshold = UINT16

ChannelDeposit = ChannelId Inputs Metadata
Inputs = InputCount *NoteId
InputCount = Byte
Metadata = UINT32 *BYTE

ChannelWithdraw = ChannelId Outputs WithdrawNonce
Outputs = OutputCount *Note
OutputCount = Byte
WithdrawNonce = UINT32

ChannelId = Hash32
Parent = Hash32
Signer = Ed25519PublicKey

���

SDP Operations

SDPDeclare = ServiceType LocatorCount *Locator ProviderId ZkId LockedNoteId
ServiceType = Byte ; 0 = BN
LocatorCount = Byte ; Max 8
Locator = 2Byte *BYTE ; Max 329 bytes, multiaddr format
ProviderId = Ed25519PublicKey
ZkId = ZkPublicKey
LockedNoteId = NoteId

SDPWithdraw = DeclarationId Nonce LockedNoteId
DeclarationId = Hash32
Nonce = UINT64

SDPActive = DeclarationId Nonce Metadata
Metadata = UINT32 *BYTE ; Service-specific node activeness metadata

���

Leader operations

LeaderClaim = RewardsRoot VoucherNullifier PublicKey
RewardsRoot = FieldElement ; Merkle root for voucher membership proof
VoucherNullifier = FieldElement
PublicKey = ZkPublicKey

���

Transfer Operations

Transfer = Inputs Outputs
Inputs = InputCount *NoteId
InputCount = Byte
Outputs = OutputCount *Note
OutputCount = Byte

���

Ledger

Note = Value ZkPublicKey
Value = UINT64
NoteId = FieldElement

���

Op Proofs

OpsProofs = *OpProof ; 1. Lenth must equal OpCount
; 2. OpProof variant is derived from the corresponding Op.
; That is, type(OpProofs[i]) == ProofFor(Op[i])

OpProof = Ed25519SigProof /
ZkSigProof /
ZkAndEd25519SigsProof /
ChannelWithdrawOpProof /
ProofOfClaimProof

Ed25519SigProof = Ed25519Signature
ZkSigProof = ZkSignature
ZkAndEd25519SigsProof = ZkSignature Ed25519Signature
ChannelWithdrawOpProof = SignatureCount *Ed25519Signature
ProofOfClaimProof = Groth16

SignatureCount = UINT16

���

Common Structures

; Zero-knowledge signature
ZkSignature = Groth16

; Cryptographic primitives
Groth16 = 128BYTE ; pi_a (32) + pi_b (64) + pi_c (32)
ZkPublicKey = FieldElement
Ed25519PublicKey = 32BYTE
Ed25519Signature = 64BYTE
FieldElement = 32BYTE ; BN254 field element (little-endian)
Hash32 = 32BYTE

; Primitive types
UINT64 = 8BYTE ; 64-bit unsigned integer, little-endian
UINT32 = 4BYTE ; 32-bit unsigned integer, little-endian
UINT16 = 2BYTE ; 16-bit unsigned integer, little-endian
Byte = OCTET

���
