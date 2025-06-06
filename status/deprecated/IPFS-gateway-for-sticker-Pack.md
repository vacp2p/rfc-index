---
title: IPFS-gateway-for-Sticker-Pack
name: IPFS gateway for Sticker Pack
status: deprecated
description: This specification describes how Status uses the IPFS gateway to store stickers. 
editor: Filip Dimitrijevic <filip@status.im>
contributors:
  - Gheorghe Pinzaru <gheorghe@status.im>
---

## Abstract

This specification describes how Status uses the IPFS gateway  
to store stickers.  
The specification explores image format,  
how a user uploads stickers,  
and how an end user can see them inside the Status app.

## Definition

| Term             | Description                                                                            |
|------------------|----------------------------------------------------------------------------------------|
| **Stickers**     | A set of images which can be used to express emotions                                  |
| **Sticker Pack** | ERC721 token which includes the set of stickers                                        |
| **IPFS**         | P2P network used to store and share data, in this case, the images for the stickerpack |

## Specification

### Image format

Accepted image file types are `PNG`, `JPG/JPEG` and `GIF`,
with a maximum allowed size of 300kb.
The minimum sticker image resolution is 512x512,
and its background SHOULD be transparent.

### Distribution

The node implements sticker packs as [ERC721 token](https://eips.ethereum.org/EIPS/eip-721)
and contain a set of stickers.
The node stores these stickers inside the sticker pack as a set of hyperlinks pointing to IPFS storage.
These hyperlinks are publicly available and can be accessed by any user inside the status chat.
Stickers can be sent in chat only by accounts that own the sticker pack.

### IPFS gateway

At the moment of writing, the current main Status app uses the [Infura](https://infura.io/) gateway.
However, clients could choose a different gateway or to run own IPFS node.
Infura gateway is an HTTPS gateway,
which based on an HTTP GET request with the multihash block will return the stored content at that block address.

The node requires the use of a gateway to enable easy access to the resources over HTTP.
The node stores each image of a sticker inside IPFS using a unique address that is
derived from the hash of the file.
This ensures that a file can't be overridden,
and an end-user of the IPFS will receive the same file at a given address.

### Security

The IPFS gateway acts as an end-user of the IPFS
and allows users of the gateway to access IPFS without connection to the P2P network.
Usage of a gateway introduces potential risk for the users of that gateway provider.
In case of a compromise in the security of the provider, meta information such as IP address,
User-Agent and other of its users can be leaked.
If the provider servers are unavailable the node loses access through the gateway to the IPFS network.

### Status sticker usage

When the app shows a sticker, the Status app makes an HTTP GET request to IPFS gateway using the hyperlink.

To send a sticker in chat, a user of Status should buy or install a sticker pack.

To be available for installation a Sticker Pack should be submitted to Sticker market by an author.

#### Submit a sticker

To submit a sticker pack, the author should upload all assets to IPFS.
Then generate a payload including name, author, thumbnail,
preview and a list of stickers in the [EDN format](https://github.com/edn-format/edn). Following this structure:
``
{meta {:name "Sticker pack name"
       :author "Author Name"
       :thumbnail "e30101701220602163b4f56c747333f43775fdcbe4e62d6a3e147b22aaf6097ce0143a6b2373"
       :preview "e30101701220ef54a5354b78ef82e542bd468f58804de71c8ec268da7968a1422909357f2456"
       :stickers [{:hash "e301017012207737b75367b8068e5bdd027d7b71a25138c83e155d1f0c9bc5c48ff158724495"}
       {:hash "e301017012201a9cdea03f27cda1aede7315f79579e160c7b2b6a2eb51a66e47a96f47fe5284"}]}}
``
All asset fields, are contenthash fields as per [EIP 1577](https://eips.ethereum.org/EIPS/eip-1577).
The node also uploads this payload to IPFS, and the node uses the IPFS address in the content field of the Sticker Market contract.
See [Sticker Market spec](https://github.com/status-im/sticker-market/blob/651e88e5f38c690e57ecaad47f46b9641b8b1e27/docs/specification.md) for a detailed description of the contract.

#### Install a sticker pack

To install a sticker pack, the node fetches all sticker packs available in Sticker Market.
The node needs the following steps to fetch all sticker packs:

#### 1. Get total number of sticker packs

Call `packCount()` on the sticker market contract, will return number of sticker pack registered as `uint256`.

#### 2. Get sticker pack by id

ID's are represented as `uint256` and are incremental from `0` to total number of sticker packs in the contract,
received in the previous step.
To get a sticker pack call `getPackData(sticker-pack-id)`, the return type is  `["bytes4[]" "address" "bool" "uint256" "uint256" "bytes"]`
which represents the following fields: `[category owner mintable timestamp price contenthash]`.
Price is the SNT value in wei set by sticker pack owner.
The contenthash is the IPFS address described in the [submit description](#submit-a-sticker) above.
Other fields specification could be found in [Sticker Market spec](https://github.com/status-im/sticker-market/blob/651e88e5f38c690e57ecaad47f46b9641b8b1e27/docs/specification.md)

##### 3. Get owned sticker packs

The current Status app fetches owned sticker packs during the open of any sticker view
(a screen which shows a sticker pack, or the list of sticker packs).
To get owned packs, get all owned tokens for the current account address,
by calling `balanceOf(address)` where address is the address for the current account.
This method returns a `uint256` representing the count of available tokens. Using `tokenOfOwnerByIndex(address,uint256)` method,
with the address of the user and ID in form of a `uint256`
which is an incremented int from 0 to the total number of tokens, gives the token id.
To get the sticker pack id from a token call`tokenPackId(uint256)` where `uint256` is the token id.
This method will return an `uint256` which is the id of the owned sticker pack.

##### 4. Buy a sticker pack

To buy a sticker pack call `approveAndCall(address,uint256,bytes)`
where `address` is the address of buyer,`uint256` is the price and third parameters `bytes` is the callback  called if approved.
In the callback, call `buyToken(uint256,address,uint256)`, first parameter is sticker pack id, second buyers address, and the last is the price.

## Copyright

Copyright and related rights waived via [CC0](https://creativecommons.org/publicdomain/zero/1.0/).

## References

- [ERC721 Token Standard](https://eips.ethereum.org/EIPS/eip-721)
- [Infura](https://infura.io/)
- [EDN Format](https://github.com/edn-format/edn)
- [EIP 1577](https://eips.ethereum.org/EIPS/eip-1577)
- [Sticker Market Specification](https://github.com/status-im/sticker-market/blob/651e88e5f38c690e57ecaad47f46b9641b8b1e27/docs/specification.md)
