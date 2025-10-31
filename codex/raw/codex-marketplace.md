---
slug: codex-marketplace
title: CODEX-MARKETPLACE
name: Codex Storage Marketplace
status: raw
category: Standards Track
tags: codex, storage, marketplace, smart-contract
editor: Codex Team and Dmitriy Ryajov <dryajov@status.im>
contributors:
  - Mark Spanbroek <mark@codex.storage>
  - Adam Uhlíř <adam@codex.storage>
  - Eric Mastro <eric@codex.storage>
  - Jimmy Debe <jimmy@status.im>
  - Filip Dimitrijevic <filip@status.im>
---

## Abstract

Codex Marketplace and its interactions are defined by a smart contract deployed on an EVM-compatible blockchain. This specification describes these interactions for the various roles within the network.

The document is intended for implementors of Codex nodes.

## Semantics

The keywords "MUST", "MUST NOT", "REQUIRED", "SHALL", "SHALL NOT", "SHOULD", "SHOULD NOT", "RECOMMENDED", "MAY", and "OPTIONAL" in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Definitions

| Terminology               | Description                                                                                                               |
|---------------------------|---------------------------------------------------------------------------------------------------------------------------|
| Storage Provider (SP)      | A node in the Codex network that provides storage services to the marketplace.                                             |
| Validator                  | A node that assists in identifying missing storage proofs.                                                                |
| Client                     | A node that interacts with other nodes in the Codex network to store, locate, and retrieve data.                           |
| Storage Request or Request | A request created by a client node to persist data on the Codex network.                                                  |
| Slot or Storage Slot       | A space allocated by the storage request to store a piece of the request's dataset.              |
| Smart Contract             | A smart contract implementing the marketplace functionality.                                                               |
| Token               | ERC20-based token used within the Codex network.     |

## Motivation

The Codex network aims to create a peer-to-peer storage engine with robust data durability, data persistence guarantees, and a comprehensive incentive structure.

The marketplace is a critical component of the Codex network, serving as a platform where all involved parties interact to ensure data persistence. It provides mechanisms to enforce agreements and facilitate data repair when SPs fail to fulfill their duties.

Implemented as a smart contract on an EVM-compatible blockchain, the marketplace enables various scenarios where nodes assume one or more roles to maintain a reliable persistence layer for users. This specification details these interactions.

The marketplace contract manages storage requests, maintains the state of allocated storage slots, and orchestrates SP rewards, collaterals, and storage proofs.

A node that wishes to participate in the Codex persistence layer MUST implement one or more roles described in this document.

### Roles

A node can assume one of the three main roles in the network: the client, SP, and validator.

A client is a potentially short-lived node in the network with the purpose of persisting its data in the Codex persistence layer.

An SP is a long-lived node providing storage for clients in exchange for profit. To ensure a reliable, robust service for clients, SPs are required to periodically provide proofs that they are persisting the data.

A validator ensures that SPs have submitted valid proofs each period where the smart contract required a proof to be submitted for slots filled by the SP.

## Storage Request Lifecycle

The diagram below depicts the lifecycle of a storage request:

```
                      ┌───────────┐
                      │ Cancelled │
                      └───────────┘
                            ▲
                            │ Not all
                            │ Slots filled
                            │
    ┌───────────┐    ┌──────┴─────────────┐           ┌─────────┐
    │ Submitted ├───►│ Slots Being Filled ├──────────►│ Started │
    └───────────┘    └────────────────────┘ All Slots └────┬────┘
                                            Filled         │
                                                           │
                                   ┌───────────────────────┘
                           Proving ▼
    ┌────────────────────────────────────────────────────────────┐
    │                                                            │
    │                 Proof submitted                            │
    │       ┌─────────────────────────► All good                 │
    │       │                                                    │
    │ Proof required                                             │
    │       │                                                    │
    │       │         Proof missed                               │
    │       └─────────────────────────► After some time slashed  │
    │                                   eventually Slot freed    │
    │                                                            │
    └────────┬─┬─────────────────────────────────────────────────┘
             │ │                                      ▲
             │ │                                      │
             │ │ SP kicked out and Slot freed ┌───────┴────────┐
All good     │ ├─────────────────────────────►│ Repair process │
Time ran out │ │                              └────────────────┘
             │ │
             │ │ Too many Slots freed         ┌────────┐
             │ └─────────────────────────────►│ Failed │
             ▼                                └────────┘
       ┌──────────┐
       │ Finished │
       └──────────┘
```

![image](./images/storeRequest.png)

## Client Role

A node implementing the client role mediates the persistence of data within the Codex network.

A client has two primary responsibilities:

- Requesting storage from the network by sending a storage request to the smart contract.
- Withdrawing funds from the storage requests previously created by the client.

### Creating Storage Requests

When a user prompts the client node to create a storage request, the client node SHOULD receive the input parameters for the storage request from the user.

To create a request to persist a dataset on the Codex network, client nodes MUST split the dataset into data chunks, $(c_1, c_2, c_3, \ldots, c_{n})$. Using the erasure coding method and the provided input parameters, the data chunks are encoded and distributed over a number of slots. The applied erasure coding method MUST use the [Reed-Solomon algorithm](https://hackmd.io/FB58eZQoTNm-dnhu0Y1XnA). The final slot roots and other metadata MUST be placed into a `Manifest` (TODO: Manifest RFC). The CID for the `Manifest` MUST then be used as the `cid` for the stored dataset.

After the dataset is prepared, a client node MUST call the smart contract function `requestStorage(request)`, providing the desired request parameters in the `request` parameter. The `request` parameter is of type `Request`:

```solidity
struct Request {
  address client;
  Ask ask;
  Content content;
  uint64 expiry;
  byte32 nonce;
}

struct Ask {
  uint256 proofProbability;
  uint256 pricePerBytePerSecond;
  uint256 collateralPerByte;
  uint64 slots;
  uint64 slotSize;
  uint64 duration;
  uint64 maxSlotLoss;
}

struct Content {
  bytes cid;
  byte32 merkleRoot;
}
```

The the table below provides the description of the `Request` and the associated types attributes:

| attribute | type | description |
|-----------|------|-------------|
| `client` | `address` | The Codex node requesting storage. |
| `ask` | `Ask` | Parameters of Request. |
| `content` | `Content` | The dataset that will be hosted with the storage request. |
| `expiry` | `uint64` | Timeout in seconds during which all the slots have to be filled, otherwise Request will get cancelled. The final deadline timestamp is calculated at the moment the transaction is mined. |
| `nonce` | `byte32` | Random value to differentiate from other requests of same parameters. It SHOULD be a random byte array. |
| `pricePerBytePerSecond` | `uint256` | Amount of tokens that will be awarded to SPs for finishing the storage request. It MUST be an amount of Tokens offered per slot per second per byte. The Ethereum address that submits the `requestStorage()` transaction MUST have [approval](https://docs.openzeppelin.com/contracts/2.x/api/token/erc20#IERC20-approve-address-uint256-) for the transfer of at least an equivalent amount of full reward (`pricePerBytePerSecond * duration * slots * slotSize`) in Tokens. |
| `collateralPerByte` | `uint256` | The amount of tokens per byte of slot's size that SPs submit when they fill slots. Collateral is then slashed or forfeited if SPs fail to provide the service requested by the storage request (more information in the [Slashing](#Slashing) section). |
| `proofProbability` | `uint256` | Determines the average frequency that a proof is required within a period: $\frac{1}{proofProbability}$. SPs are required to provide proofs of storage to the marketplace smart contract when challenged by the smart contract. To prevent hosts from only coming online when proofs are required, the frequency at which proofs are requested from SPs is stochastic and is influenced by the `proofProbability` parameter. |
| `duration` | `uint64` | Total duration of the storage request in seconds. It MUST NOT exceed the limit specified in the configuration `config.requestDurationLimit`. |
| `slots` | `uint64` | The number of requested slots. The slots will all have the same size. |
| `slotSize` | `uint64` | Amount of storage per slot in bytes. |
| `maxSlotLoss` | `uint64` |  Max slots that can be lost without data considered to be lost. |
| `cid`     | `bytes` | An identifier used to locate the Manifest representing the dataset. It MUST be a [CIDv1](https://github.com/multiformats/cid#cidv1), SHA-256 [multihash](https://github.com/multiformats/multihash) and the data it represents SHOULD be discoverable in the network, otherwise the request will be eventually canceled. |
| `merkleRoot` | `byte32` | Merkle root of the dataset, used to verify storage proofs |

#### Renewal of Storage Requests

It should be noted that the marketplace does not support extending requests. It is REQUIRED that if the user wants to extend the duration of a request, a new request with the same CID must be [created](#Creating-storage-requests) **before the original request completes**.

This ensures that the data will continue to persist in the network at the time when the new (or existing) SPs need to retrieve the complete dataset to fill the slots of the new request.

### Withdrawing Funds

The client node SHOULD monitor the status of the requests it created. When a storage request enters the `Cancelled` state (this occurs when not all slots were filled before the `expiry` timeout), the client node SHOULD initiate the withdrawal of the remaining funds from the smart contract using the `withdrawFunds(requestId)` function.

- The request is considered `Cancelled` if no `requestFulfilled(requestId)` event is observed during the timeout specified by the value returned from the `requestExpiresAt(requestId)` function.
- The request is considered `Failed` when the `RequestFailed(requestId)` event is observed.
- The request is considered `Finished` after the interval specified by the value returned from the `getRequestEnd(requestId)` function.

## Storage Provider Role

A Codex node acting as an SP persists data across the network by hosting slots requested by clients in their storage requests.

The following tasks need to be considered when hosting a slot:

- Filling a slot
- Proving
- Repairing a slot
- Collecting request reward and collateral

### Filling Slots

When a new request is created, the `StorageRequested(requestId, ask, expiry)` event is emitted with the following properties:

- `requestId` - the ID of the request.
- `ask` - the specification of the request parameters. For details, see the definition of the `Request` type in the [Creating Storage Requests](#Creating-storage-requests) section above.
- `expiry` - a Unix timestamp specifying when the request will be canceled if all slots are not filled by then.

It is then up to the SP node to decide, based on the emitted parameters and node's operator configuration, whether it wants to participate in the request and attempt to fill its slot(s) (note that one SP can fill more than one slot). If the SP node decides to ignore the request, no further action is required. However, if the SP decides to fill a slot, it MUST follow the remaining steps described below.

The node acting as an SP MUST decide which slot, specified by the slot index, it wants to fill. The SP MAY attempt to fill more than one slot. To fill a slot, the SP MUST first reserve the slot in the smart contract using `reserveSlot(requestId, slotIndex)`. If reservations for this slot are full, or if the SP has already reserved the slot, the transaction will revert. If the reservation was unsuccessful, then the SP is not allowed to fill the slot. If the reservation was successful, the node MUST then download the slot data using the CID of the manifest (**TODO: Manifest RFC**) and the slot index. The CID is specified in `request.content.cid`, which can be retrieved from the smart contract using `getRequest(requestId)`. Then, the node MUST generate a proof over the downloaded data (**TODO: Proving RFC**).

When the proof is ready, the SP MUST call `fillSlot()` on the smart contract with the following REQUIRED parameters:

- `requestId` - the ID of the request.
- `slotIndex` - the slot index that the node wants to fill.
- `proof` - the `Groth16Proof` proof structure, generated over the slot data.

The Ethereum address of the SP node from which the transaction originates MUST have [approval](https://docs.openzeppelin.com/contracts/2.x/api/token/erc20#IERC20-approve-address-uint256-) for the transfer of at least the amount of Tokens required as collateral for the slot (`collateralPerByte * slotSize`).

If the proof delivered by the SP is invalid or the slot was already filled by another SP, then the transaction will revert. Otherwise, a `SlotFilled(requestId, slotIndex)` event is emitted. If the transaction is successful, the SP SHOULD transition into the __proving__ state, where it will need to submit proof of data possession when challenged by the smart contract.

It should be noted that if the SP node observes a `SlotFilled` event for the slot it is currently downloading the dataset for or generating the proof for, it means that the slot has been filled by another node in the meantime. In response, the SP SHOULD stop its current operation and attempt to fill a different, unfilled slot.

### Proving

Once an SP fills a slot, it MUST submit proofs to the smart contract when a challenge is issued by the contract. SPs SHOULD detect that a proof is required for the current period using the `isProofRequired(slotId)` function, or that it will be required using the `willProofBeRequired(slotId)` function in the case that the [pointer is in downtime](https://github.com/codex-storage/codex-research/blob/41c4b4409d2092d0a5475aca0f28995034e58d14/design/storage-proof-timing.md).

Once an SP knows it has to provide a proof it MUST get the proof challenge using `getChallenge(slotId)`, which then
MUST be incorporated into the proof generation as described in Proving RFC (**TODO: Proving RFC**).

When the proof is generated, it MUST be submitted by calling the `submitProof(slotId, proof)` smart contract function.

#### Slashing

There is a slashing scheme orchestrated by the smart contract to incentivize correct behavior and proper proof submissions by SPs. This scheme is configured at the smart contract level and applies uniformly to all participants in the network. The configuration of the slashing scheme can be obtained via the `configuration()` contract call.

The slashing works as follows:

- When SP misses a proof and a validator trigger detection of this event using the `markProofAsMissing()` call, the SP is slashed by `config.collateral.slashPercentage` **of the originally required collateral** (hence the slashing amount is always the same for a given request).
- If the number of slashes exceeds `config.collateral.maxNumberOfSlashes`, the slot is freed, the remaining collateral is burned, and the slot is offered to other nodes for repair. The smart contract also emits the `SlotFreed(requestId, slotIndex)` event.

If, at any time, the number of freed slots exceeds the value specified by the `request.ask.maxSlotLoss` parameter, the dataset is considered lost, and the request is deemed _failed_. The collateral of all SPs that hosted the slots associated with the storage request is burned, and the `RequestFailed(requestId)` event is emitted.

### Repair

When a slot is freed due to too many missed proofs, which SHOULD be detected by listening to the `SlotFreed(requestId, slotIndex)` event, an SP node can decide whether to participate in repairing the slot. Similar to filling a slot, the node SHOULD consider the operator's configuration when making this decision. The SP that originally hosted the slot but failed to comply with proving requirements MAY also participate in the repair. However, by refilling the slot, the SP **will not** recover its original collateral and must submit new collateral using the `fillSlot()` call.

The repair process is similar to filling slots. If the original slot dataset is no longer present in the network, the SP MAY use erasure coding to reconstruct the dataset. Reconstructing the original slot dataset requires retrieving other pieces of the dataset stored in other slots belonging to the request. For this reason, the node that successfully repairs a slot is entitled to an additional reward. (**TODO: Implementation**)

The repair process proceeds as follows:

1. The SP observes the `SlotFreed` event and decides to repair the slot.
2. The SP MUST reserve the slot with the `reserveSlot(requestId, slotIndex)` call. For more information see the [Filling Slots](#filling-slots) section.
3. The SP MUST download the chunks of data required to reconstruct the freed slot's data. The node MUST use the [Reed-Solomon algorithm](https://hackmd.io/FB58eZQoTNm-dnhu0Y1XnA) to reconstruct the missing data.
4. The SP MUST generate proof over the reconstructed data.
5. The SP MUST call the `fillSlot()` smart contract function with the same parameters and collateral allowance as described in the [Filling Slots](#filling-slot) section.

### Collecting Funds

An SP node SHOULD monitor the requests and the associated slots it hosts.

When a storage request enters the `Cancelled`, `Finished`, or `Failed` state, the SP node SHOULD call the `freeSlot(slotId)` smart contract function.

The aforementioned storage request states (`Cancelled`, `Finished`, and `Failed`) can be detected as follows:

- A storage request is considered `Cancelled` if no `RequestFulfilled(requestId)` event is observed within the time indicated by the `expiry` request parameter. Note that a `RequestCancelled` event may also be emitted, but the node SHOULD NOT rely on this event to assert the request expiration, as the `RequestCancelled` event is not guaranteed to be emitted at the time of expiry.
- A storage request is considered `Finished` when the time indicated by the value returned from the `getRequestEnd(requestId)` function has elapsed.
- A node concludes that a storage request has `Failed` upon observing the `RequestFailed(requestId)` event.

For each of the states listed above, different funds are handled as follows:

- In the `Cancelled` state, the collateral is returned along with a proportional payout based on the time the node actually hosted the dataset before the expiry was reached.
- In the `Finished` state, the full reward for hosting the slot, along with the collateral, is collected.
- In the `Failed` state, no funds are collected. The reward is returned to the client, and the collateral is burned. The slot is removed from the list of slots and is no longer included in the list of slots returned by the `mySlots()` function.

## Validator Role

In a blockchain, a contract cannot change its state without a transaction and gas initiating the state change. Therefore, our smart contract requires an external trigger to periodically check and confirm that a storage proof has been delivered by the SP. This is where the validator role is essential.

The validator role is fulfilled by nodes that help to verify that SPs have submitted the required storage proofs.

It is the smart contract that checks if the proof requested from an SP has been delivered. The validator only triggers the decision-making function in the smart contract. To incentivize validators, they receive a reward each time they correctly mark a proof as missing corresponding to the percentage of the slashed collateral defined by `config.collateral.validatorRewardPercentage`.

Each time a validator observes the `SlotFilled` event, it SHOULD add the slot reported in the `SlotFilled` event to the validator's list of watched slots. Then, after the end of each period, a validator has up to `config.proofs.timeout` seconds (a configuration parameter retrievable with `configuration()`) to validate all the slots. If a slot lacks the required proof, the validator SHOULD call the `markProofAsMissing(slotId, period)` function on the smart contract. This function validates the correctness of the claim, and if right, will send a reward to the validator.

If validating all the slots observed by the validator is not feasible within the specified `timeout`, the validator MAY choose to validate only a subset of the observed slots.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

1. [Reed-Solomon algorithm](https://hackmd.io/FB58eZQoTNm-dnhu0Y1XnA)
2. [CIDv1](https://github.com/multiformats/cid#cidv1)
3. [multihash](https://github.com/multiformats/multihash)
4. [Proof-of-Data-Possession](https://hackmd.io/2uRBltuIT7yX0CyczJevYg?view)
5. [Codex market implementation](https://github.com/codex-storage/nim-codex/blob/master/codex/market.nim)
