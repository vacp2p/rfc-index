---
title: ETHEREUM-USAGE
name: Status interactions with the Ethereum blockchain
status: deprecated
description: All interactions that the Status client has with the Ethereum blockchain.
editor: Andrea Maria Piana <andreap@status.im>
contributors:
- 
---

## Abstract

This specification details all interactions
that the Status client has with the Ethereum blockchain.

## Background

This specification documents all interactions
that the Status client has with the Ethereum blockchain.
All interactions are made through JSON-RPC.
Currently, Infura is used.
The client assumes high availability;
otherwise, it will not be able to interact with the Ethereum blockchain.
Status nodes rely on these Infura nodes
to validate transaction integrity and report consistent history.

[Key handling is described here](https://rfc.vac.dev/status/deprecated/9/ethereum-usage.md)

1 [Wallet]
2 [ENS]

## Wallet

The wallet in Status has two main components:

1. Sending transactions
2. Fetching balance

Below are the RPC calls made by the nodes,
with brief descriptions of their functionality and how Status
uses them.

### Sending Transactions

#### EstimateGas

`EstimateGas` tries to estimate the gas needed
to execute a transaction based on the current pending state of the blockchain.
There’s no guarantee this is the actual gas limit, but it provides a reasonable default.

```go
func (ec *Client) EstimateGas(ctx context.Context, msg ethereum.CallMsg)(uint64, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L499)

#### PendingNonceAt

`PendingNonceAt` returns the account nonce of the given account in the pending state.
This should be used for the next transaction.

```go
func (ec *Client) PendingNonceAt(ctx context.Context, account common.Address) (uint64, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L440)

#### SuggestGasPrice

`SuggestGasPrice` retrieves the suggested gas price for timely transaction execution.

```go
func (ec *Client) SuggestGasPrice(ctx context.Context) (*big.Int, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L487)

#### SendTransaction

`SendTransaction` injects a signed transaction into the pending pool for execution.
If it's a contract creation, use `TransactionReceipt`
to get the contract address after it's mined.

```go
func (ec *Client) SendTransaction(ctx context.Context, tx *types.Transaction) error
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L512)

### Fetching Balance

A Status node fetches current and historical [ERC-20](https://eips.ethereum.org/EIPS/eip-20)
and ETH balances for the user wallet address.
It supports default tokens, with custom tokens added
by specifying the address, symbol, and decimals.

#### BlockByHash

`BlockByHash` returns the full block,
used to fetch transfers to the user address (ETH and tokens).

```go
func (ec *Client) BlockByHash(ctx context.Context, hash common.Hash) (*types.Block, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L78)

#### BlockByNumber

`BlockByNumber` returns a block from the canonical chain. If `number` is nil,
it returns the latest known block.

```go
func (ec *Client) BlockByNumber(ctx context.Context, number *big.Int) (*types.Block, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L82)

#### FilterLogs

`FilterLogs` executes a filter query.
Status uses it to filter logs using the block hash and address ofinterest.

```go
func (ec *Client) FilterLogs(ctx context.Context, q ethereum.FilterQuery) ([]types.Log, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L377)

#### NonceAt

`NonceAt` returns the account nonce at a given block number.

```go
func (ec *Client) NonceAt(ctx context.Context, account common.Address, blockNumber *big.Int) (uint64, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L366)

#### TransactionByHash

`TransactionByHash` returns the transaction with the given hash,
used to inspect transactions made or received by the user.

```go
func (ec *Client) TransactionByHash(ctx context.Context, hash common.Hash) (tx *types.Transaction, isPending bool, err error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L202)

#### HeaderByNumber

`HeaderByNumber` returns a block header from the canonical chain.

```go
func (ec *Client) HeaderByNumber(ctx context.Context, number *big.Int) (*types.Header, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L172)

#### TransactionReceipt

`TransactionReceipt` returns the receipt of a transaction by its hash,
used to check if a token transfer was made to the user address.

```go
func (ec *Client) TransactionReceipt(ctx context.Context, txHash common.Hash) (*types.Receipt, error)
```

[Source](https://github.com/ethereum/go-ethereum/blob/26d271dfbba1367326dec38068f9df828d462c61/ethclient/ethclient.go#L270)

### ENS

All interactions with ENS are made through the ENS contract.

#### Registering, Releasing, and Updating

- **Registering a Username**
- **Releasing a Username**
- **Updating a Username**
- **Slashing**
  - Usernames MUST:
    - Contain only alphanumeric characters.
    - Not be in the form `0x[0-9a-f]{5}.*` and must have more than 12 characters.
    - Not be reserved or too short (checked against the contract).
  - **Slash a Username**:
    - Reserved
    - Invalid
    - Too similar to an address
    - Too short

ENS names are propagated through `ChatMessage` and `ContactUpdate` payloads.
A client SHOULD verify ENS names against the sender's public key
on message receipt, using the ENS contract.

## Copyright

Waived via CC0.
