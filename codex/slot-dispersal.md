---
title: CODEX-SLOT-DISPERSAL
name: Codex SLOT Dispersal
status: raw
tags: codex
editor: 
contributors:
---

## Abstract

This specification desribes a method that is used by the Codex network for slot dispersal.
To achieve a true decentralized storage network, data being stored on mutlple nodes is required.

## Motivation
Client nodes benefit from resistant data storage when multiple nodes are storing their requested data.
In a marketplace envirnoment where storage providers announce storage availability,
high performance nodes may have an advantage to be choosen to store requested data.
This creates a centralized scenario as only high performance nodes will participate 
and be rewarded in the network. 

The Codex network does not implement a first come, first serve method to avoid centralized behaviors.
Instead, the Codex network encourages stroage requests to allow only a select few storage providers to create a storage contracts with the client node requests.

## Specification
