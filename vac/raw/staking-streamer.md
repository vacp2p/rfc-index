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

This specification describes the components of the smart contracts for the staking streamer protocol.
The staking streamer protocol is currently used in Status Network.

## Background/Motivation

The Status Network is a layer 2 blockchain that is gasless.
To achieve no gas fees for transactions conducted on the network,
users utilize a staking mechanism with native tokens.
This mechanism, called the staking streamer, 
allow users to accumulate a ERC-20 token called Karma.
With Karma, users can create transactions,
have voting rights on the Status Network, and other benefits.
The goal is to have a staking mechanism that is fair to all participates based on the stake amount and time staked.
Participants will have significant increases in voting power after committing their stake for a longer period of time,
even if their stake is not the largest amongst all participants.

## Specification

The key words “MUST”, “MUST NOT”, “REQUIRED”,
“SHALL”, “SHALL NOT”, “SHOULD”, “SHOULD NOT”, “RECOMMENDED”, “MAY”, and
“OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

The staking streamer protocol is a set of smart contracts that implements the staking system.
The protocol consists of the following components:

- accounts
- staking operator
- multipler points
- reward mechanism

The staking system MUST be supported by an operator who will introduce reward amounts, 
reward periods, the REQUIRED tokens to use within the system and updates to the staking smart contract.
It is the responsibility of the operator to keep accounts informed about requirements and
intended changes to the staking system.

emergencyExit, (MigrationFailed, Not Allowed to leave)/ update,update contract or global state/ prefered minium lock period/ 
### Accounts

Accounts are users who contrbtribute a token, ERC-20 standard, to the staking protocol.
Accounts SHOULD interact with the protocol through a layer-1 blockchain smart contract.
To participate,
users MUST use an external owned account (EOA) to interact with a `stakeVault` contract.
A `stakeVault` is a smart contract that records and
maintains the current amount of tokens transfered by accounts to the protocol.
Each `stakeVault` MUST have one registered as the owner.
Once registered, the user is considered as an account.
Accounts MAY be the owner of one or more `stakeVault`s.

#### Account Staking Flow

To join a staking system, 
accounts MUST use a `stakeVault` to transfer a token amount to the staking system.
The ERC-20 token address used token address MUST match the token address used bybe identified by the operator as the  of the staking system,
see [Operator section](#operatorrole).
Accounts MAY set a predefined duration to lock tokens in the staking system.
Tokens will not be retrievable by accounts until the set duration expires.
This is designed to improve the rewards accured by accounts deciding to lock funds.
When tokens are successfully transfered to the `stakeVault`,
the account responsible will start to accumulate multiper points.
The rewards and multipler points are described in further detail in [Rewards section](#rewards).
If staked tokens are not locked, the account MAY withdraw the full amount of tokens at any time.

### Operator Role

Operators are the owners of the staking system implemented in the staking system.
The operator interacts with a `stakeMangaer` contract to faciltate the requirements of the staking system.
A `stakeManager` is a smart contract that holds the logic for the staking system.
Each account MUST use a `stakeVault` to interact with the `stakeManager`.
Inclcuding when tokens 
- The operator is the owner of the staking protocol and interacts with the `stakeManager` contract.
- A `stakeManager` is a contract holds the logic for the staking protocol and
is operatored by the owner of the staking streamer protocol, .
- The user will be rewarded an ERC-20 token from the `stakeManager` contract, set by the owner of the `stakeManager`.
The user will be awarded a non transferable token (NFT). ****
- 

### Rewards

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
- Those points have a limited duration and will be used by the contract to determine how to reward the ERC20 token.
- Contract SHOULD account for all mp accured by all accounts participating
- 

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
