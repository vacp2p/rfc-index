---

title: Build a Waku Relay Node
name: Build a node
status: draft
editor: Jimmy Debe <jimmy@status.im>
contributors:
  
---
## Building a Waku Node: Waku Relay

This is a tutorial demonstatraing how to build your own Waku node using python. 
Waku provides a collection of protocols on top of libp2p providing messaging anonymity,.
This guide will use the core protocols of Waku v2, as described in [10/WAKU2](https://rfc.vac.dev/spec/10/), 
other protocols can be added to your node after completing the tutorial.
To start, we will implement the [11/WAKU2-RELAY](https://rfc.vac.dev/spec/11/) protocol.

## Configuration

Your node must use configurations detailed in [11/WAKU2-RELAY](https://rfc.vac.dev/spec/11/).
The [11/WAKU2-RELAY](https://rfc.vac.dev/spec/11/) should be the first protocol to implement when building your Waku node.
 
Let's set up the required libp2p modules first. 
Create a directory for our new project:

``` bash

# create a new directory and make sure you change into it
> mkdir waku-node
> cd waku-node

```
In your new directory, download the supported py-libp2p from the github repository.

> Note: py-libp2p is still under development and should not be used for production envirnoments.

``` bash

> git clone git@github.com:libp2p/py-libp2p.git

```
## Publish/Subsrcibe Method

Now that the we have a py-libp2p modules installed lets create our relay.py file.
Below is the components we will add: be lets add more components to our node.
A Waku node uses Publish/Subscribe (pubsub) to allow peers to communicate with each other.
Peers are able to join topics, within a network,
that they are interseted in using pubsub.
Once joined, they are able to send and 
receive messages within the topic.

The gossipsub protocol is the pubsub protocol used in a Waku node.
To implement gossipsub on your Waku node,
we will import the proper packages. 

``` python

# import the necessary py-libp2p
from libp2p.pubsub.abc import IPubsubRouter
from libp2p.pubsub.pubsub import Pubsub
from libp2p.pubsub.gossipsub import GossipSub
from libp2p.peer.id import ID
from libp2p.typing import TProtocol


```
A few more packages will be needed which can be view in the the excutable example scipt.
Above is the important pubsub packages provided by py-libp2p.

- Pubsub : this is the main pubsub packages that enables the interface for the routing mech of the system
- Gossipsub : is the proposed routing mech using the pubsub interface
- IPubsubRouter : a python interface provided by py-libp2p
- TProtocol : interface provided by py-libp2p for simple pubsub rpc use

> Note: This is not a RECCOMMENDED python implementation for production.

We will need a `run` function that will be use to start our node. 
The run will interact with the four 
``` python

  
```

