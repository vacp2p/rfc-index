---
title: STATUS-STAKING-STREAMER
name: Status Staking Streamer Protocol
status: raw
category: Standards Track
tags: status-network
editor: 
contributors: 
- Jimmy Debe <jimmy@status.im>
---

## Abstract

This specification describes the components of the smart contracts for the Staking streamer protocol.


## Background/Motivation

The Status Network blockchain is a layer 2 blockchain that does not have gas fees for transactions.
Instead, users gain access to the blockchain by staking native tokens on the staking streamer protocol.
Staking will allow users to accumulate a ERC-20 token called Karma which can be used to create transactions,
voting rights on the network, and other benefits.
The goal is to have a staking mechanism that is fair to all participates based on the stake amount and time staked.
A user can have a significant increases in voting power when committed to the network for a longer period of time,
even if their stake is not the largest amongst all participants.


## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”,
“SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Accounts

Users wanting to participate in the protocol should have an EOA account or smart account.
Users should own some amount of the native blockchain coin and/or token that is accepted in the protocol.
Users will make tranaction calls to stake vaults, which are controlled by accounts.

### Staking Flow

- Accounts that want to stake can create one or more staking vaults.
The `stakeVault` contract must be owned by the user(msg.sender).
They must create a transaction to the staking contract using a native token.
The native token must be approved/known  by/to the owner of the `stakeManager`.
- When tokens are transfered to a `stakeVault` the tokens MAY be locked in the contract for a certain amount of time, set by ther user.
- The user will be rewarded an ERC-20 token from the `stakeManager` contract, set by the owner of the `stakeManager`.
The user will be awarded a non transferable token (NFT). ****
- The user will be start to accure multipler points, desibed below, based on amount of native tokens staked and for how long they are being staked.
Those points have a limited duration and will be used by the contract to determine how to reward the ERC20 token. 
- If staked tokens are not locked, the user can withdraw the full amount of tokens at any time.
- When locked, the user must wait until the time, which is set by the user, expires.
- 


### Staking Manager



### Multiplier Points

- In the staking streamer protocol, there are multipler points (MP),
which are internal contract accounting ensuring users are rewarded based on the amount stake and the time of stake.
- The amount are calculated once a user transfers stake to the staking streamer.
- The multipler points are accumulated over time and not non transferable.
- Calcuation is based on two factors, Inital MP and Accured MP.
- Initial MP is the MP that are issued immediately once native tokens are transfered to the `stakingVault` contract.
 The user MAY opt to lock tokens for a specific time period.
- The Initial MP MUST be based on the amount tokens in the `stakingValut` and/or the lock-up duration.
- The Accrued MP are accumulated over time as a function of the stake amount, elapsed time, and annual percentage yield (APY).

## Rewards


## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
