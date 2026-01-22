# ETHEREUM-USAGE

| Field | Value |
| --- | --- |
| Name | Status interactions with the Ethereum blockchain |
| Slug | 125 |
| Status | deprecated |
| Editor | Filip Dimitrijevic <filip@status.im> |
| Contributors | Andrea Maria Piana <andreap@status.im> |

<!-- timeline:start -->

## Timeline

- **2026-01-19** — [`f24e567`](https://github.com/vacp2p/rfc-index/blob/f24e567d0b1e10c178bfa0c133495fe83b969b76/docs/archived/status/deprecated/ethereum-usage.md) — Chore/updates mdbook (#262)
- **2026-01-16** — [`89f2ea8`](https://github.com/vacp2p/rfc-index/blob/89f2ea89fc1d69ab238b63c7e6fb9e4203fd8529/docs/archived/status/deprecated/ethereum-usage.md) — Chore/mdbook updates (#258)
- **2025-12-22** — [`0f1855e`](https://github.com/vacp2p/rfc-index/blob/0f1855edcf68ef982c4ce478b67d660809aa9830/docs/status/deprecated/ethereum-usage.md) — Chore/fix headers (#239)
- **2025-12-22** — [`b1a5783`](https://github.com/vacp2p/rfc-index/blob/b1a578393edf8487ccc97a5f25b25af9bf41efb3/docs/status/deprecated/ethereum-usage.md) — Chore/mdbook updates (#237)
- **2025-12-18** — [`d03e699`](https://github.com/vacp2p/rfc-index/blob/d03e699084774ebecef9c6d4662498907c5e2080/docs/status/deprecated/ethereum-usage.md) — ci: add mdBook configuration (#233)
- **2025-04-29** — [`614348a`](https://github.com/vacp2p/rfc-index/blob/614348a4982aa9e519ccff8b8fbcd4c554683288/status/deprecated/ethereum-usage.md) — Status deprecated update2 (#134)

<!-- timeline:end -->

## Abstract

This specification documents all the interactions that the Status client has
with the [Ethereum](https://ethereum.org/developers/) blockchain.

## Background

All the interactions are made through [JSON-RPC](https://github.com/ethereum/wiki/wiki/JSON-RPC).
Currently [Infura](https://infura.io/) is used.
The client assumes high-availability,
otherwise it will not be able to interact with the Ethereum blockchain.
Status nodes rely on these Infura nodes
to validate the integrity of the transaction and report a consistent history.

Key handling is described [here](/archived/status/deprecated/account.md)

1. [Wallet](#wallet)
2. [ENS](#ens)

## Wallet

The wallet in Status has two main components:

1) Sending transactions
2) Fetching balance

In the section below are described the `RPC` calls made the nodes, with a brief
description of their functionality and how it is used by Status.

1.[Sending transactions](#sending-transactions)

- [EstimateGas](#estimategas)
- [PendingNonceAt](#pendingnonceat)
- [SuggestGasPrice](#suggestgasprice)
- [SendTransaction](#sendtransaction)

2.[Fetching balance](#fetching-balance)

- [BlockByHash](#blockbyhash)
- [BlockByNumber](#blockbynumber)
- [FilterLogs](#filterlogs)
- [HeaderByNumber](#headerbynumber)
- [NonceAt](#nonceat)
- [TransactionByHash](#transactionbyhash)
- [TransactionReceipt](#transactionreceipt)

### Sending transactions

#### EstimateGas

EstimateGas tries to estimate the gas needed to execute a specific transaction
based on the current pending state of the backend blockchain.
There is no guarantee that this is the true gas limit requirement
as other transactions may be added or removed by miners,
but it should provide a basis for setting a reasonable default.

```go
func (ec *Client) EstimateGas(ctx context.Context, msg ethereum.CallMsg) (uint64, error)
```

[L499](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L499)

#### PendingNonceAt

`PendingNonceAt` returns the account nonce of the given account in the pending state.
 This is the nonce that should be used for the next transaction.

 ```go
func (ec *Client) PendingNonceAt(ctx context.Context, account common.Address) (uint64, error)
```

[L440](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L440)

#### SuggestGasPrice

`SuggestGasPrice` retrieves the currently suggested gas price to allow a timely
execution of a transaction.

```go
func (ec *Client) SuggestGasPrice(ctx context.Context) (*big.Int, error)
```

[L487](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L487)

#### SendTransaction

`SendTransaction` injects a signed transaction into the pending pool for execution.

If the transaction was a contract creation use the TransactionReceipt method to get the
contract address after the transaction has been mined.

```go
func (ec *Client) SendTransaction(ctx context.Context, tx *types.Transaction) error 
```

[L512](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L512)

### Fetching balance

A Status node fetches the current and historical [ECR20](https://eips.ethereum.org/EIPS/eip-20) and ETH balance for the user wallet address.
Collectibles following the [ERC-721](https://eips.ethereum.org/EIPS/eip-721) are also fetched if enabled.

A Status node supports by default the following [tokens](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs). Custom tokens can be added by specifying the `address`, `symbol` and `decimals`.

#### BlockByHash

`BlockByHash` returns the given full block.

It is used by status to fetch a given block which will then be inspected
for transfers to the user address, both tokens and ETH.

```go
func (ec *Client) BlockByHash(ctx context.Context, hash common.Hash) (*types.Block, error)
```

[L78](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L78)

#### BlockByNumber

`BlockByNumber` returns a block from the current canonical chain. If number is nil, the
latest known block is returned.

```go
func (ec *Client) BlockByNumber(ctx context.Context, number *big.Int) (*types.Block, error)
```

[L82](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L82)

#### FilterLogs

`FilterLogs` executes a filter query.

Status uses this function to filter out logs, using the hash of the block
and the address of interest, both inbound and outbound.

```go
func (ec *Client) FilterLogs(ctx context.Context, q ethereum.FilterQuery) ([]types.Log, error) 
```

[L377](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L377)

#### NonceAt

`NonceAt` returns the account nonce of the given account.

```go
func (ec *Client) NonceAt(ctx context.Context, account common.Address, blockNumber *big.Int) (uint64, error)
```

[L366](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L366)

#### TransactionByHash

`TransactionByHash` returns the transaction with the given hash,
used to inspect those transactions made/received by the user.

```go
func (ec *Client) TransactionByHash(ctx context.Context, hash common.Hash) (tx *types.Transaction, isPending bool, err error)
```

[L202](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L202)

#### HeaderByNumber

`HeaderByNumber` returns a block header from the current canonical chain.

```go
func (ec *Client) HeaderByNumber(ctx context.Context, number *big.Int) (*types.Header, error) 
```

[L172](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L172)

#### TransactionReceipt

`TransactionReceipt` returns the receipt of a transaction by transaction hash.
It is used in status to check if a token transfer was made to the user address.

```go
func (ec *Client) TransactionReceipt(ctx context.Context, txHash common.Hash) (*types.Receipt, error)
```

[L270](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L270)

## ENS

All the interactions with `ENS` are made through the [ENS contract](https://github.com/ensdomains/ens)

For the `stateofus.eth` username, one can be registered through these [contracts](https://github.com/status-im/ens-usernames)

### Registering, releasing and updating

- [Registering a username](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L113)
- [Releasing a username](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L131)
- [Updating a username](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L174)

### Slashing

Usernames MUST be in a specific format, otherwise they MAY be slashed:

- They MUST only contain alphanumeric characters
- They MUST NOT  be in the form `0x[0-9a-f]{5}.*` and have more than 12 characters
- They MUST NOT be in the [reserved list](https://github.com/status-im/ens-usernames/blob/47c4c6c2058be0d80b7d678e611e166659414a3b/config/ens-usernames/reservedNames.js)
- They MUST NOT be too short, this is dynamically set in the contract and can be checked against the [contract](https://github.com/status-im/ens-usernames/blob/master/contracts/registry/UsernameRegistrar.sol#L26)

- [Slash a reserved username](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L237)
- [Slash an invalid username](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L261)
- [Slash a username too similar to an address](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L215)
- [Slash a username that is too short](https://github.com/status-im/ens-usernames/blob/77d9394d21a5b6213902473b7a16d62a41d9cd09/contracts/registry/UsernameRegistrar.sol#L200)

ENS names are propagated through `ChatMessage` and `ContactUpdate` [payload](/archived/status/deprecated/payloads.md).
A client SHOULD verify ens names against the public key of the sender on receiving the message against the [ENS contract](https://github.com/ensdomains/ens)

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [Ethereum Developers](https://ethereum.org/developers/)
- [JSON-RPC](https://github.com/ethereum/wiki/wiki/JSON-RPC)
- [Infura](https://infura.io/)
- [Key Handling](/archived/status/deprecated/account.md)
- [ERC-20 Token Standard](https://eips.ethereum.org/EIPS/eip-20)
- [ERC-721 Non-Fungible Token Standard](https://eips.ethereum.org/EIPS/eip-721)
- [Supported Tokens Source Code](https://github.com/status-im/status-mobile/blob/develop/src/status_im/ethereum/tokens.cljs)
- [go-ethereum](https://github.com/ethereum/go-ethereum/)
- [ENS Contract](https://github.com/ensdomains/ens)
