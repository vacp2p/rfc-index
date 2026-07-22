# Zerokit API

| Field | Value |
| --- | --- |
| Name | Zerokit API |
| Slug | 142 |
| Status | raw |
| Category | Standards Track |
| Editor | Vinh Trinh <vinh@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-05-11** — [`1ac7689`](https://github.com/logos-co/logos-lips/blob/1ac7689ee3fe1665d5d5d1bf9c180ed951cc660d/docs/anoncomms/raw/zerokit-api.md) — chore: split ift ts specs (#334)
- **2026-01-21** — [`70f3cfb`](https://github.com/logos-co/logos-lips/blob/70f3cfb4df4e9a94e56b1284e98ee1dc9df50ac7/docs/ift-ts/raw/zerokit-api.md) — chore: mdbook font fix (#266)

<!-- timeline:end -->

## Abstract

This document specifies the Zerokit API (version 3.0.0),
an implementation of the RLN-V2 protocol.
The specification covers the unified interface exposed through **native Rust**,
C-compatible Foreign Function Interface (FFI) bindings,
and WebAssembly (WASM) bindings.

## Motivation

The main goal of this RFC is to define the API contract,
serialization formats,
and architectural guidance for integrating the Zerokit library
across all supported platforms.
Zerokit is the reference implementation of the RLN-V2 protocol.

## Format Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”,
“SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and “OPTIONAL” in this document
are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Important Note

All terms and parameters used remain the same as in [RLN-V2](rln-v2.md) and [RLN-V1](../draft/32/rln-v1.md#technical-overview).

### Architecture Overview

Zerokit follows a layered architecture where
the core RLN logic is implemented once in **Rust** and
exposed through platform-specific bindings.
The protocol layer handles zero-knowledge proof generation and verification,
Merkle tree operations, and cryptographic primitives.
This core is wrapped by three interface layers:
**native Rust** for direct library integration,
**FFI** for C-compatible bindings consumed by languages (such as C and Nim),
and **WASM** for browser and Node.js environments.
All three interfaces maintain functional parity and
share identical serialization formats for inputs and outputs.

```text
      ┌─────────────────────────────────────────────────────┐
      │                  Application Layer                  │
      └──────────┬───────────────┬───────────────┬──────────┘
                 │               │               │
          ┌──────▼───────┐ ┌─────▼─────┐ ┌───────▼─────┐
          │    FFI API   │ │ WASM API  │ │   Rust API  │
          │   (C/Nim/..) │ │ (Browser) │ │   (Native)  │
          └──────┬───────┘ └─────┬─────┘ └───────┬─────┘
                 └───────────────┼───────────────┘
                                 │
                       ┌─────────▼─────────┐
                       │   RLN Protocol    │
                       │   (Rust Core)     │
                       └───────────────────┘
```

The workspace consists of four crates:
`rln` (protocol core, FFI bindings),
`zerokit_utils` (Merkle trees and Poseidon primitives),
`rln-wasm` (WASM bindings),
and `rln-cli` (example CLI, not published).
All published crates share the unified version 3.0.0.

### Type-Level Configuration

The Merkle tree backend and the stateful/stateless operating mode
are chosen **at the type level** in Rust
(and through dedicated constructors in FFI):

- `RLN<Stateful<T>, ZkProof>` embeds a Merkle tree of type `T`
  and exposes the full tree management API.
- `RLN<Stateless, ZkProof>` carries no tree;
  applications MUST provide Merkle proofs and roots externally.

The available feature flags are:

- `parallel` (`rln`, `zerokit_utils`, `rln-wasm`) enables rayon-based
  parallel computation for proof generation and tree operations.
- `headers` (`rln`) enables C header generation for the FFI surface.
- `panic_hook` (`rln-wasm`) enables the `initPanicHook` console panic hook.
- `utils` (`rln-wasm`) builds a utility-only WASM module
  (field elements, identity keys, hashing) without the proof surface.

#### Merkle Tree Backends

All backends are always compiled and implement the common
`ZerokitMerkleTree` trait; applications pick one by constructing it and
passing it to the builder.

`FullMerkleTree` allocates the complete tree structure in memory.
This backend provides the fastest performance but consumes the most memory.

`OptimalMerkleTree` uses sparse HashMap storage that only allocates nodes as needed.
This backend balances performance and memory efficiency.

`PmTree` persists the tree to disk using a sled database.
This backend enables state durability across process restarts.
It is configured through `PmTreeSledConfig`
(path, temporary flag, cache capacity, flush interval,
sled mode, compression, tree depth).

#### Proof Modes

Every RLN instance operates in one of two circuit modes,
selected by the circuit resources (zkey and graph) loaded at construction:

- **Single message-id mode**: one `message_id` per proof.
  This is the default circuit on native targets.
- **Multi message-id mode**: a batch of message ids per proof.
  The circuit has a fixed slot count `max_out`
  (the embedded default circuit uses `DEFAULT_MAX_OUT = 4`);
  `message_ids` and `selector_used` MUST match it in length,
  with the boolean `selector_used` vector marking the active slots.
  Proof values carry vectors `ys` and `nullifiers`
  instead of scalar `y` and `nullifier`.

Embedded circuit resources are exposed as
`default_zkey_single` / `default_graph_single` and
`default_zkey_multi` / `default_graph_multi`.
The default tree depth is `DEFAULT_TREE_DEPTH = 20`.

#### Parallelization

`parallel` enables rayon-based parallel computation for
proof generation and tree operations.

This flag SHOULD be enabled for end-user clients where
fastest individual proof generation time is required.
For server-side proof services handling multiple concurrent requests,
this flag SHOULD be disabled and
applications SHOULD use dedicated worker threads per proof instead.
The worker thread approach provides significantly higher throughput for
concurrent proof generation.

## The API

### Overview

The API exposes strongly-typed interfaces.
All three platform bindings share the same operations,
differing only in language-specific conventions.
Function signatures documented below are from the Rust perspective.

- Rust: <https://github.com/vacp2p/zerokit/blob/master/rln/src/public.rs>
- FFI: <https://github.com/vacp2p/zerokit/tree/master/rln/src/ffi>
- WASM: <https://github.com/vacp2p/zerokit/tree/master/rln-wasm>

Rust consumers SHOULD import from `rln::prelude`,
which re-exports the full public surface
(RLN types, protocol types, hashers, errors, and serialization traits).

### Error Handling

Error handling differs across platform bindings.

For **native Rust**,
each operation returns a `Result` with a **narrow, operation-specific error enum**
whose variants are all reachable from that code path.
There is no top-level union error type.
The error enums are:
`GenerateProofError`, `VerifyProofError`,
`WitnessInputSingleError`, `WitnessInputMultiError`, `PartialWitnessInputError`,
`ProofValuesMultiError`, `RecoverSecretError`, and `SerializationError`.

For **WASM** and **FFI** bindings,
errors are returned as human-readable string messages.
This simplifies cross-language error propagation at
the cost of type safety.
Applications consuming these bindings SHOULD parse error strings or
use error message prefixes to distinguish error types when needed.

### Initialization

Native Rust construction goes exclusively through `RLNBuilder`,
a type-state builder that fixes the proof backend to
Groth16 over BN254 with the Poseidon hash
(`ArkGroth16Backend<PoseidonHash>`).

`RLNBuilder::stateless().build()` - *Rust | Stateless mode*

- Builds a stateless RLN instance.
- Optional setters `.zkey(...)` and `.graph(...)` accept pre-loaded circuit
  resources; on native targets both default to the Single message-id circuit.
- On `wasm32` targets the resources MUST be supplied.

`RLNBuilder::stateful().tree(tree).build()` - *Rust | Stateful mode*

- Builds a stateful RLN instance around a caller-constructed Merkle tree
  (`FullMerkleTree`, `OptimalMerkleTree`, or `PmTree`).
- The tree hasher MUST match the proof backend hash;
  a mismatch is a compile error.
- Optional `.zkey(...)` / `.graph(...)` setters behave as in `stateless`.

FFI exposes one constructor per backend and mode,
each with a `_default` variant that uses the embedded Single message-id
circuit and `DEFAULT_TREE_DEPTH`:

- `ffi_rln_new_stateless(zkey_data, graph_data)` / `ffi_rln_new_stateless_default()`
- `ffi_rln_new_with_full_merkle_tree(tree_depth, zkey_data, graph_data)` /
  `ffi_rln_new_with_full_merkle_tree_default()`
- `ffi_rln_new_with_optimal_merkle_tree(tree_depth, zkey_data, graph_data)` /
  `ffi_rln_new_with_optimal_merkle_tree_default()`
- `ffi_rln_new_with_pm_tree(tree_depth, zkey_data, graph_data, config_path)` /
  `ffi_rln_new_with_pm_tree_default()`
  (an empty `config_path` selects the default sled configuration)

WASM is **stateless only**:

`WasmRLN.newWithParams(zkey_data, graph_data)` - *WASM | Stateless mode*

- Creates a stateless RLN instance from pre-loaded zkey and graph bytes.
- Witness calculation is performed internally by the embedded witness graph.

### Key Generation

Identity material is represented by dedicated structs.
Secret components are wrapped in `SecretFr`,
a zeroize-on-drop field element with a redacted `Debug` representation
(see [Security/Privacy Considerations](#securityprivacy-considerations)).

`IdentityKeys::generate::<PoseidonHash, R>(rng)`

- Generates a random identity keypair using the caller-supplied
  cryptographically secure RNG `R`.
- Accessors: `identity_secret() -> SecretFr`, `id_commitment() -> Fr`.

`IdentityKeys::generate_seeded::<PoseidonHash, R>(seed)`

- Generates a deterministic identity keypair from a byte seed.
- The seed is expanded with Keccak-256 into the seed of the
  type-level chosen seedable RNG `R`.

`ExtendedIdentityKeys::generate::<PoseidonHash, R>(rng)`

- Generates a random extended identity keypair.
- Accessors: `identity_trapdoor()`, `identity_nullifier()`,
  `identity_secret()` (all `SecretFr`), and `id_commitment() -> Fr`.

`ExtendedIdentityKeys::generate_seeded::<PoseidonHash, R>(seed)`

- Deterministic variant of the extended keypair generation.

FFI and WASM wrappers pin concrete RNG defaults
(`ThreadRng` for random, `ChaCha20Rng` for seeded generation)
so seeded outputs are bit-identical across platforms:
`ffi_identity_keys_generate(_seeded)`,
`ffi_extended_identity_keys_generate(_seeded)`,
`WasmIdentityKeys.generate(Seeded)`,
and `WasmExtendedIdentityKeys.generate(Seeded)`.

### Merkle Tree Management

Tree management methods exist **only** on stateful instances
(`RLN<Stateful<T>, _>`); stateless instances do not expose them
(in FFI, calling a tree operation on a stateless handle returns an error).

`tree_depth()`

- Returns the depth of the internal Merkle tree.

`leaves_set()`

- Returns the number of leaves that have been set in the tree.

`get_root()`

- Returns the current Merkle tree root.

`get_subtree_root(level, index)`

- Returns the root of the subtree at the given `level` on the path to leaf `index`.
- `level` 0 is the tree root; `level` equal to the tree depth is the leaf itself.

`set_leaf(index, leaf)`

- Sets a leaf value at the specified index.

`set_leaves_from(index, leaves)`

- Sets multiple leaves starting from the specified index.
- Updates `next_index` to `max(next_index, index + n)`.
- If `n` leaves are passed, they will be set at positions `index`, `index+1`, ..., `index+n-1`.

`init_tree_with_leaves(leaves)`

- Resets the tree state to default (keeping the current depth) and
  initializes it with the provided leaves starting from index 0.
- Resets the internal `next_index` to 0 before setting the leaves.

`get_leaf(index)`

- Returns the leaf value at the specified index.

`get_empty_leaves_indices()`

- Returns the indices of the leaves set to the default value, up to the last set leaf.

`atomic_operation(index, leaves, indices)`

- Atomically sets `leaves` starting from `index` and resets each entry of `indices`
  to the default value, in a single commit.
- When a written position also appears in `indices`, the write wins.
- Updates `next_index` to `max(next_index, index + n)` where `n` is the number of leaves inserted.

`set_next_leaf(leaf)`

- Sets a leaf at the next never-set index and increments `next_index` by one.

`delete_leaf(index)`

- Resets the leaf at the specified index to the default value.
- Does not change the internal `next_index` value.

`get_merkle_proof(index)`

- Returns the Merkle proof for the leaf at the specified index.
- Any backend proof converts into the canonical `RLNMerkleProof`
  data type (`path_elements`, `identity_path_index`) used by witness construction.

`set_metadata(metadata)` / `get_metadata()`

- Stores and retrieves arbitrary application metadata in the RLN object.
- This metadata is not used by the RLN module.

`close()`

- Closes the tree, flushing pending writes for persistent backends.
- Persistent backends also flush on drop; for in-memory backends this is a no-op.

### Witness Construction

The canonical Merkle proof data type is:

`RLNMerkleProof::new(path_elements, identity_path_index)`

- Wraps externally supplied path data (stateless workflows).
- Tree proofs returned by `get_merkle_proof` convert into it automatically.

Witness inputs are built through validating builders and
are represented by the `RLNWitnessInput` enum
(`Single` / `Multi` variants):

`RLNWitnessInput::new_single(identity_secret, user_message_limit, merkle_proof, x, external_nullifier, message_id).build()`

- Constructs a Single message-id witness.
- `build` checks the structural invariants
  (non-zero `user_message_limit`,
  matching `path_elements` / `identity_path_index` lengths,
  `message_id < user_message_limit`)
  and returns `WitnessInputSingleError` on violation.

`RLNWitnessInput::new_multi(identity_secret, user_message_limit, merkle_proof, x, external_nullifier, message_ids, selector_used).build()`

- Constructs a Multi message-id witness.
- `build` checks the Multi-mode invariants
  (non-zero `user_message_limit`, matching path lengths,
  non-empty `message_ids`, `selector_used` matching `message_ids` in length,
  at least one active selector,
  and unique in-range active `message_id`s)
  and returns `WitnessInputMultiError` on violation.

`RLNPartialWitnessInput`

- The witness subset known ahead of time
  (identity secret, user message limit, Merkle path),
  used for two-step proof generation.
- Constructed via the
  `RLNPartialWitnessInput::new(identity_secret, user_message_limit, merkle_proof).build()`
  builder (`build` checks the structural invariants and returns
  `PartialWitnessInputError` on violation),
  or converted from a full witness (`From<&RLNWitnessInput>`).

Witness calculation is handled internally on **all** platforms,
including WASM, by the embedded witness graph.

### Proof Generation

`generate_proof(witness)`

- Generates a Groth16 zkSNARK proof and its public proof values from a witness.
- Returns `(proof, proof_values)`;
  `proof_values` is an `RLNProofValues` enum (`Single` / `Multi`).
- Fails with `GenerateProofError` on witness/graph inconsistency or backend fault.

`generate_partial_proof(partial_witness)`

- First step of **two-step proof generation**:
  precomputes a partial proof from the inputs known ahead of time
  (identity, message limit, Merkle path),
  before the signal and external nullifier are known.

`finish_proof(partial_proof, witness)`

- Second step: completes the partial proof with the full witness and
  returns `(proof, proof_values)`.
- This split lets latency-sensitive applications move the bulk of the
  proving work off the critical path.

### Proof Verification

All verification methods return an honest `Result<bool>`:
`Ok(true)` / `Ok(false)` is the zkSNARK **verdict**
(an invalid proof is a verdict, not an error),
while `Err` reports only caller-input mismatch
(`InvalidSignal`, `InvalidRoot`) or a backend fault.

`verify(proof, proof_values)`

- Verifies only the zkSNARK proof without root or signal validation.

`verify_with_signal(proof, proof_values, x)`

- Checks that the signal `x` matches the value bound in the proof
  (`Err(InvalidSignal)` on mismatch), then returns the zkSNARK verdict.

`verify_with_roots(proof, proof_values, x, roots)`

- Additionally checks that the proof root is among `roots`
  (`Err(InvalidRoot)` on mismatch).
- If the `roots` slice is empty, root verification is skipped.

The FFI and WASM boundaries preserve this shape:
an FFI `FFI_BoolResult { ok: false, err: null }` and
a WASM `false` return are real "proof invalid" verdicts,
not errors.

### Slashing

`RLNProofValues::recover_secret(other)` (trait `RecoverSecret`)

- Recovers the identity secret from two proof values that share the same
  external nullifier and nullifier.
- Returns `RecoverSecretError` when the two proofs do not yield a matching
  nullifier (no slashing possible).
- Recovery works across modes: Single with Single, Multi with Multi,
  and Single combined with Multi.

`compute_id_secret(share1, share2)`

- Lower-level Shamir reconstruction from two `(x, y)` shares.

FFI: `ffi_rln_recover_id_secret`, `ffi_rln_compute_id_secret`
(the recovered secret is returned as a plain field element deliberately,
since slashing is a reveal).
WASM: `WasmRLNProofValues.recoverIdSecret` / `computeIdSecret`.

### Hash Utilities

`Hasher::<PoseidonHash>::hash_single(input)` / `hash_pair(left, right)` / `hash_list(inputs)`

- Computes the Poseidon hash for arity 1, 2, or list inputs.
- All protocol hashes route through this facade.

`hash_to_field_le(input)` / `hash_to_field_be(input)`

- Hashes arbitrary bytes to a field element using Keccak-256,
  interpreting the digest with little-endian or big-endian byte order.

Boundary equivalents: `ffi_poseidon_hash_pair`, `ffi_hash_to_field_le/be`,
`ffi_uint_to_fr` (FFI); `poseidonHashPair`, `hashToFieldLE/BE` (WASM).

### Serialization

Serialization is trait-based; there are no free serialization functions.
Endianness is chosen at the call site:

- **Little-endian**: the arkworks `CanonicalSerialize` / `CanonicalDeserialize`
  traits (re-exported by the prelude, so consumers do not depend on
  `ark-serialize` directly).
- **Big-endian**: the Zerokit `CanonicalSerializeBE` / `CanonicalDeserializeBE`
  traits, implemented for field elements, vectors, identity keys,
  witnesses, and proof values.
- **Mixed**: `CanonicalSerializeMixed` / `CanonicalDeserializeMixed`
  for `RLNProof` (proof and values in one buffer;
  `toBytesMixed` / `fromBytesMixed` at the boundaries).

Wire format properties:

- A field element is 32 bytes; vectors carry an 8-byte length prefix.
- Enum types (`RLNWitnessInput`, `RLNProofValues`) are tagged with one byte:
  `0` = Single, `1` = Multi.
- The zkSNARK `Proof` and `PartialProof` are little-endian only.
- Deserialization of untrusted big-endian input MUST reject non-canonical
  field elements (values `>=` the field modulus).
- Deserialization enforces the same structural invariants as construction
  and returns typed validation errors through `SerializationError`.

### WASM-Specific Notes

WASM bindings wrap the Rust API with JavaScript-compatible types. Key differences:

- Field elements are wrapped as `WasmFr`
  (`zero`, `one`, `fromUint`, `fromBytesLE/BE`, `toBytesLE/BE`, `debug`).
- Vectors of field elements use `VecWasmFr` with `push`, `get`, `length`.
- Secrets are wrapped as `WasmSecretFr`, which exposes ONLY a redacted
  `debug()` and an `equals()` comparison; raw byte export of a bare secret
  is intentionally not available. Secret persistence goes through
  `WasmIdentityKeys.toBytesLE/BE` (whole-struct).
- Identity generation uses `WasmIdentityKeys.generate()` /
  `generateSeeded(seed)` and `WasmExtendedIdentityKeys` equivalents.
- Witness input uses `WasmRLNWitnessInput.newSingle(...)` / `newMulti(...)`;
  proof generation is `WasmRLN.generateProof(witness)` with witness
  calculation handled internally.
- Two-step proving: `generatePartialProof` / `finishProof` with
  `WasmRLNPartialWitnessInput` and `WasmRLNPartialProof`.
- The WASM surface is stateless only and exposes **no tree methods**;
  JavaScript supplies `path_elements` and `identity_path_index`.
- When the `parallel` feature is enabled, call `initThreadPool()`
  to initialize the rayon thread pool.
- `initPanicHook()` (with the `panic_hook` feature) installs a console
  panic hook for debugging.
- Errors are returned as JavaScript strings that can be caught via try-catch blocks.

### FFI-Specific Notes

FFI bindings use C-compatible types with the `ffi_` function prefix
(pattern `ffi_<type>_<action>_<variant>`). Key differences:

- Field elements are wrapped as `FFI_Fr`; secrets as the opaque `FFI_SecretFr`
  (redacted debug via `ffi_secret_fr_debug`, comparison via `ffi_secret_fr_eq`).
- Fallible functions return `FFI_Result<T>` (heap pointer + error string),
  or `FFI_BoolResult` / `FFI_UsizeResult` for bare values;
  errors are C strings in the `err` field.
- All protocol types cross the boundary as opaque handles:
  `FFI_RLN`, `FFI_IdentityKeys`, `FFI_ExtendedIdentityKeys`,
  `FFI_RLNMerkleProof`, `FFI_RLNWitnessInput`, `FFI_RLNPartialWitnessInput`,
  `FFI_RLNProof`, `FFI_RLNPartialProof`, `FFI_RLNProofValues`.
- Memory must be explicitly freed with the matching `ffi_*_free` function;
  every owned vector type has one (`ffi_vec_fr_free`, `ffi_vec_u8_free`,
  `ffi_vec_bool_free`, `ffi_vec_usize_free`); strings use `ffi_c_string_free`.
- Returned strings and byte buffers are **not** NUL-terminated;
  C callers MUST print them with an explicit length (`%.*s`), never `%s`.
- The C header `rln.h` is generated with
  `cargo run --bin generate_headers --features=headers`.

## Usage Patterns

This section describes common deployment scenarios and
the recommended API combinations for each.

### Stateful with Changing Root

Applies when membership changes over time with members joining and slashing continuously.

Applications MUST maintain a sliding window of recent roots externally.
When members are added or removed via `set_leaf`, `delete_leaf`, or `atomic_operation`,
capture the new root using `get_root` and append it to the history buffer.
Verify incoming proofs using `verify_with_roots` with the root history buffer,
accepting proofs valid against any recent root.

The window size depends on network propagation delays and epoch duration.

### Stateful with Fixed Root

Applies when membership is established once and remains static during an operation period.

Initialize the tree using `init_tree_with_leaves` with the complete membership set.
No root history is required.
Verify proofs using `verify_with_signal`,
optionally combined with `verify_with_roots` against the single internal root.

### Stateless

Applies when membership state is managed externally,
such as by a smart contract or relay network.

Construct the instance with `RLNBuilder::stateless()`
(or `ffi_rln_new_stateless` / `WasmRLN.newWithParams`).
Obtain Merkle proofs and valid roots from the external source.
Wrap externally provided `path_elements` and `identity_path_index` in
`RLNMerkleProof::new` and pass it to the witness builder.
Verify using `verify_with_roots` with externally provided roots.

### Two-Step Proving

Applies when proof latency at message time matters.

Build an `RLNPartialWitnessInput` as soon as the identity and Merkle path
are known and call `generate_partial_proof`.
When the signal arrives, build the full witness and call `finish_proof`
to obtain `(proof, proof_values)` with reduced critical-path latency.

### Epoch and Rate Limit Configuration

The external nullifier is computed as `poseidon_hash([epoch, rln_identifier])`.
The `rln_identifier` is a field element that uniquely identifies your application (e.g., a hash of your app name).

All values that will be hashed MUST be represented as field elements.
For converting arbitrary data to field elements,
use the `hash_to_field_le` or `hash_to_field_be` functions,
which internally use Keccak-256.

Each application SHOULD use a unique `rln_identifier` to
prevent cross-application nullifier collisions.

The `user_message_limit` in the rate commitment determines messages allowed per epoch.
Each `message_id` must be less than `user_message_limit` and
should increment with each message.
In Multi message-id mode a single proof covers a batch of message ids,
with `selector_used` marking the active slots.

Applications MUST persist the `message_id` counter to avoid violations after restarts.

## Security/Privacy Considerations

The security of Zerokit depends on the correct implementation of the RLN-V2 protocol
and the underlying zero-knowledge proof system.
Applications MUST ensure that:

- Identity secrets are kept confidential and never transmitted or logged
- The `message_id` counter is properly persisted to prevent accidental rate limit violations
- External nullifiers are constructed correctly to prevent cross-application attacks
- Merkle tree roots are validated when using stateless mode
- Circuit parameters (zkey and graph data) are obtained from trusted sources

Zerokit handles secrets defensively in-process:
all secret field elements are carried as `SecretFr`,
which zeroizes its memory on drop,
cannot be implicitly copied,
and prints a redacted `Debug` representation so secrets never leak into logs.
The FFI boundary keeps secrets behind the opaque `FFI_SecretFr` handle,
and the WASM boundary exposes no raw byte export for a bare secret.
Note that WASM linear memory remains readable by the host page;
this hygiene is best-effort, not isolation.

When using the `parallel` feature in WASM,
applications MUST serve content with appropriate COOP/COEP headers to
enable SharedArrayBuffer support securely.

The slashing mechanism exposes identity secrets when rate limits are violated.
Applications SHOULD educate users about this risk and
implement safeguards to prevent accidental violations.

## References

### Normative

- [RLN-V1 Specification](../draft/32/rln-v1.md) - Rate Limit Nullifier V1 protocol

### Informative

- [Zerokit GitHub Repository](https://github.com/vacp2p/zerokit) - Reference implementation
- [RLN-V2 Specification](rln-v2.md) - Rate Limit Nullifier V2 protocol
- [Sled Database](https://sled.rs) - Embedded database for persistent Merkle tree storage

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).
