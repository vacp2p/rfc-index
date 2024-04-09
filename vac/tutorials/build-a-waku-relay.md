---

title: Build a Waku Relay Node
name: Build a node
status: raw
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
In your new directory, create a new file named `relay.py`.
Make sure that your envirnoment has the 3.8 python version.
Then, download the supported py-libp2p from the github repository.

> Note: py-libp2p is still under development and should not be used for production envirnoments.

``` bash

> git clone git@github.com:libp2p/py-libp2p.git

```
## Publish/Subsrcibe Method

Now that the we have a py-libp2p modules installed lets create our `relay.py` file.
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
- TProtocol : interface provided by py-libp2p for simple pubsub rpc use( identify the pubsub `protocol_id` to be used )

> Note: This is not a RECCOMMENDED python implementation for production.

- Initialize the pubsub `protocol_id`

``` python
  PROTOCOL_ID = TProtocol("/relay/1.0.0")
  topics = waku_Test
```

We will need a `run` function that will be use to start our node. 
This `run` will interact with the four packages mentioned above and
will be used locally for testing purposes. 
When testing the `run` function will include a method to open multiple node pointing to different port numbers.

To do this run the `relay.py` with the following command:
> python relay.py -p 8001

The next command should have a different port number
> python relay.py -p 8002

Depending on the testing, multiple node may need to be running.

``` python
    async def run(port: int, pubsubTopic: str) -> None:
      localhost_ip = "127.0.0.1"
      listen_addr = multiaddr.Multiaddr(f"/ip4/0.0.0.0/tcp/{port}")
      
      router = pubsubRouter()
      host = new_host()
      pubsub = Pubsub(host, router)
      gossip = GossipSub(PROTOCOL_ID, 6, 4, 8, 7000)

      async with host.run(listen_addrs=[listen_addr]), trio.open_nursery() as nursery:
        info = info_from_p2p_addr(maddr)
        await host.connect(info)

      async def stream_handler(stream: INetStream) -> None:
          nursery.start_soon(read_data, stream)
          nursery.start_soon(write_data, stream)
            
          host.set_stream_handler(PROTOCOL_ID, stream_handler)
  
```
`run` Parameters:
 - `port` = The port number the node will use.
Will be using a local address for testing purpose.
- `pubsubTopic` = Used for when a node will like to send a message to a topic

  Initalize pubsub object:
  - `router` = Will be used to interact with the pubsub rpc interface
  - `host` = the main libp2p host object
  - `pubsub` = the pubsub interface object
