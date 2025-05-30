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

### User Staking Flow

The staking streamer protocol tracks:

- all tokens being staked
- the accounts responisble for staking, tim
- The owner/operator of the staking contract
- the reward amount and distribution

Accounts can stake token by creating one or more `stakingVault`s.
A `stakeVault` is a contract that records and
maintains the current amount of tokens transfered to the protocol.
Accounts interact with the staking protocol through the `stakingVault`.
The `stakeVault` contract must be owned by an account.
To use a `stakingVault`, 
an account MUST create a transaction to the `stakingVault` contract using a native token recognized by staking protocol.
The native token MUST be known by the operator of the `stakeManager`.

A `stakeManager` is a contract holds the logic for the staking protocol and
is operatored by the owner of the staking streamer protocol, see [Operator Flow](#OperatorFlow).


-
- When tokens are transfered to a `stakeVault` the tokens MAY be locked in the contract for a certain amount of time, set by ther user.
- The user will be rewarded an ERC-20 token from the `stakeManager` contract, set by the owner of the `stakeManager`.
The user will be awarded a non transferable token (NFT). ****
- The user will be start to accure multipler points, desibed below, based on amount of native tokens staked and for how long they are being staked.
Those points have a limited duration and will be used by the contract to determine how to reward the ERC20 token. 
- If staked tokens are not locked, the user can withdraw the full amount of tokens at any time.
- When locked, the user must wait until the time, which is set by the user, expires.
-  

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

### Operator Flow

- The operator is the owner of the staking protocol and interacts with the `stakeManager` contract.
- 

### Rewards

The system distributes rewards based on tree main factors:

- The amount of tokens staked
- The account's Multiplier Points (MP)
- The accounts reward index

Every account in the system has a "weight" associated with it. This weight is calculated as the sum of the staked tokens
and the MP:

$$
\text{Account Weight} = \text{Staked Balance} + \text{MP Balance}
$$

In addition, the system keeps track of the total weight of all accounts in the system:

$$
\text{Total System Weight} = \sum_{i=1}^{n} \text{Account Weight}_i
$$

account MP grow linearly with time, which means, account weights increase with
time, which in turn means, the total weight of the system increases with time as well.

With the weights in place, the system can now calculate the rewards for each account. For an individual account, it's as
simple as dividing the account's weight by the total system weight and multiplying it by the total reward amount:

$$
\text{Reward Amount} = \text{Account Weight} \times \frac{\text{Total Reward Amount}}{\text{Total System Weight}}
$$

rewards are calculated in real-time, they don't actually need to be claimed by any account. whenever an
account performs **state changing** actions, such as staking or unstaking funds, the rewards that have been accrued up
to this point are updated in the account's storage.

- Operator decide amount of rewards should be awarded to stakers.
- The owner MUST specify the amount of time for rewards to be distributed.
- Rewards are accured by accounts over time and are only withdrawal at the end of each reward period
- Based on the reward duration and amount of rewards, stakers will accure rewards in real time based on the rate of rewards which is calculated:

$$
\text{Reward Rate} = \frac{\text{Total Reward Amount}}{\text{Reward Duration}}
$$

- When the `rewardEndTime` period has occured,
the operator MUST set the new reward ratio.
- account weights increase with
time, which in turn means, the total weight of the system increases with time as well.

#### Reward Index

The global reward index represents the cumulative rewards per unit of weight since the system's inception.
This index increases whenever new rewards are added to the system.

$
\text{New Index} = \text{Current Index} + \frac{\text{New Rewards} \times \text{Scale Factor}}{\text{Total System Weight}}
$

Where:

- `Scale Factor` is 1e18 (used for precision)
- `Total System Weight` is the sum of all staked tokens and MP in the system

Each account maintains its own reward index,
which represents the point at which they last claimed rewards.
The difference between the global index and an account's index, multiplied by the account's
weight, determines their unclaimed rewards:

$$
\text{Unclaimed Rewards} = \text{Account Weight} \times (\text{Global Index} - \text{Account Index})
$$

#### Reward Index Updates

The system MUST update indices in the following situations:

- When new rewards are added by the operator
- When accounts stake or unstake tokens

This mechanism ensures that, historical rewards are preserved accurately and
accounts receive their fair share based on their weight over time.
Also, accounts MUST NOT receive the rewards that were accounted for in system at the time the account entered the system.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References
