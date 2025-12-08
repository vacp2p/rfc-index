---
title: logos-routing-records
name: Logos Routing Records
status: raw
category: Standards Track
tags:
editor: Hanno Cornelius <hanno@status.im>
contributors: Simon-Pierre Vivier <simvivier@status.im>
---

## Abstract

#TODO

## Motivation

#TODO explain we need to add protocols to peer records for discovery

## Wire protocol

The keywords “MUST”, “MUST NOT”, “REQUIRED”, “SHALL”, “SHALL NOT”, “SHOULD”,
“SHOULD NOT”, “RECOMMENDED”, “MAY”, and
 “OPTIONAL” in this document are to be interpreted as described in [2119](https://www.ietf.org/rfc/rfc2119.txt).

### Records

Records MUST adhere to the following structure:

TODO explain we are extending the libp2p signed eveloppe and routing records specs

```protobuf
syntax = "proto3";

package peer.pb;

// PeerRecord messages contain information that is useful to share with other peers.
// Currently, a PeerRecord contains the public listen addresses for a peer, but this
// is expected to expand to include other information in the future.
//
// PeerRecords are designed to be serialized to bytes and placed inside of
// SignedEnvelopes before sharing with other peers.
message PeerRecord {

  // AddressInfo is a wrapper around a binary multiaddr. It is defined as a
  // separate message to allow us to add per-address metadata in the future.
  message AddressInfo {
    bytes multiaddr = 1;
  }

  // peer_id contains a libp2p peer id in its binary representation.
  bytes peer_id = 1;

  // seq contains a monotonically-increasing sequence counter to order PeerRecords in time.
  uint64 seq = 2;

  // addresses is a list of public listen addresses for the peer.
  repeated AddressInfo addresses = 3;

  message ServiceInfo{
    string id = 1;
    optional bytes data = 2;
  }

   // Extensible list of advertised services
  repeated ServiceInfo services = 4;
}
```

DHT participants MAY include their own supported protocols in the `services` field.
For each supported protocol listed, the `id` field MUST be the libp2p protocol identifier (TODO link to spec) and the `data` field MAY contain arbitrary bytes (TODO limits???).

#TODO add new payload type in multicodec for our logos peer records
#TODO link it here