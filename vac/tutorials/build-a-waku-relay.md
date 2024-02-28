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
The [11/WAKU2-RELAY](https://rfc.vac.dev/spec/11/) is the most important protocol to implement,
as all Waku nodes should be a running a relay.
 

Let's set up the basic libp2p modules that are need for a Waku Relay. 
First, lets create a directory for our new project:

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
## Test Configuration
The py-libp2p is packaged with a a `chat.py` as an example of sending a message between two libp2p. 
We will modify this later to help use send Waku messages.
## Publish/Subsrcibe Method

Now that the we have a simple libp2p node running,
lets add more components to our node.
A Waku node uses Publish/Subscribe (pubsub) to allow peers to communicate with each other.
Peers are able to join topics, within a network,
that they are interseted in using pubsub.
Once joined, they are able to send and 
receive messages within the topic.

The gossipsub protocol is the pubsub protocol used in a Waku node.
To implement gossipsub on your Waku node,
first we will import the proper packages. 

``` python

# import the necessary py-libp2p
from libp2p.pubsub import pubsub
from libp2p.pubsub import gossipsub
from libp2p.peer.id import ID


```
The main functions needed to use gossipsub in a Waku node will be:
- publish
- run
- subscribe
- unsubscribe
- s

``` python
class WakuNode():

def start() -> None:
  
```

