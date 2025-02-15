---
title: IPFS-gateway-for-Sticker-Pack
name: IPFS gateway for Sticker Pack
status: draft
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

| Term          | Description                                                      |
|---------------|------------------------------------------------------------------|
| Stickers      | A set of images used to express emotions                         |
| Sticker Pack  | ERC721 token including the set of stickers                       |
| IPFS          | P2P network used to store and share data, e.g., sticker images   |

## Specification

### Image Format

Accepted image file types are PNG, JPG/JPEG, and GIF,  
with a maximum allowed size of 300kb.  
The minimum sticker image resolution is 512x512,  
and its background SHOULD be transparent.

### Distribution

The node implements sticker packs as ERC721 tokens,  
which contain a set of stickers.  
The node stores these stickers inside the sticker pack  
as a set of hyperlinks pointing to IPFS storage.  
These hyperlinks are publicly available  
and can be accessed by any user inside the Status chat.  
Stickers can be sent in chat only by accounts that own the sticker pack.

### IPFS Gateway

The current main Status app uses the Infura gateway,  
but clients may choose a different gateway or run their own IPFS node.  
Infura gateway is an HTTPS gateway,  
which based on an HTTP GET request with the multihash block  
will return the stored content at that block address.

The node requires the use of a gateway  
to enable easy access to resources over HTTP.  
The node stores each sticker image in IPFS  
using a unique address derived from the hash of the file,  
ensuring the file cannot be overridden.  
An end-user will receive the same file at a given address.

### Security

The IPFS gateway acts as an end-user of IPFS,  
allowing gateway users to access IPFS without connecting to the P2P network.  
Using a gateway introduces potential risks for its users.  
In case of a security compromise,  
metadata such as IP address and User-Agent may be leaked.  
If provider servers are unavailable,  
the node loses access to the IPFS network through the gateway.

### Status Sticker Usage

When the app shows a sticker,  
Status makes an HTTP GET request to the IPFS gateway  
using the hyperlink.

To send a sticker in chat,  
a Status user must buy or install a sticker pack.

For a Sticker Pack to be available for installation,  
it should be submitted to the Sticker Market by an author.

### Submit a Sticker

To submit a sticker pack,  
the author should upload all assets to IPFS.  
Then, generate a payload including name, author, thumbnail, preview,  
and a list of stickers in the EDN format, following this structure:

```edn
{meta {:name "Sticker pack name"
       :author "Author Name"
       :thumbnail "e30101701220602163b4f56c747333f43775fdcbe4e62d6a3e147b22aaf6097ce0143a6b2373"
       :preview "e30101701220ef54a5354b78ef82e542bd468f58804de71c8ec268da7968a1422909357f2456"
       :stickers [{:hash "e301017012207737b75367b8068e5bdd027d7b71a25138c83e155d1f0c9bc5c48ff158724495"}
       {:hash "e301017012201a9cdea03f27cda1aede7315f79579e160c7b2b6a2eb51a66e47a96f47fe5284"}]}}
```

All asset fields are contenthash fields as per EIP 1577.  
The node also uploads this payload to IPFS  
and uses the IPFS address in the content field of the Sticker Market contract.  
See Sticker Market spec for a detailed contract description.

### Install a Sticker Pack

To install a sticker pack,  
the node fetches all sticker packs available in Sticker Market  
by following these steps:

1. **Get Total Number of Sticker Packs**  
   Call `packCount()` on the sticker market contract,  
   which returns the number of registered sticker packs as `uint256`.

2. **Get Sticker Pack by ID**  
   IDs are represented as `uint256` and are incremental  
   from 0 to the total number of sticker packs.  
   Call `getPackData(sticker-pack-id)`,  
   which returns fields: `[category, owner, mintable, timestamp, price, contenthash]`.

3. **Get Owned Sticker Packs**  
   When opening any sticker view,  
   the Status app fetches owned sticker packs.  
   Call `balanceOf(address)` with the current account address,  
   returning the count of available tokens.  
   Use `tokenOfOwnerByIndex(address, uint256)`  
   to get the token id, and call `tokenPackId(uint256)`  
   to get the owned sticker pack id.

4. **Buy a Sticker Pack**  
   To buy a sticker pack,  
   call `approveAndCall(address, uint256, bytes)`  
   with the address of the buyer, price,  
   and callback parameters. In the callback,  
   call `buyToken(uint256, address, uint256)`  
   with sticker pack id, buyer's address, and price.

## Copyright

Copyright and related rights waived via CC0.
