# Distributed Programmiong with Tuple Spaces

In this chapter we provide a gentle introduction to distributed computing using tuple spaces.

In the [previous chapter](tutorial-concurrent-programming.md) we show how spaces can be used to support concurrent programming. Several processes communicate and cooperate using a shared tuple space; that is a reference to a local data structure.

In a distributed systems, processes and data repositories are spread among several hosts/devices possibly far away one from each other. In this context tuple spaces must be identified by an address and the appropriate protocol is used by processes to retrieve data from remote spaces.
The interaction protocol may depend on the specific application context and may be based on TCP/IP for internet based application or based on BlueThoot in the context of IoT.

In the rest of this document we show how spaces can be exposed over a specific protocol and how processes can retrieve data via an appropriate address.

## Space repositories
A *space repository* is a collection of spaces. Each space in the repository is (univocally) identified by a name. The following Java code can be used to create a repository and add two spaces named *fridge* and *pastry* respectively.

```Go
rep = SpaceRepository();
Add(rep,"fridge",aspace);
Add(rep,"pastry",anotherspace);
```

A space repository provides all the operations that are available on a space. However, in the case of a space repository, an extra parameter is used to select the name of the repository where the action takes effect.

If Alice want remove the *eggs* from the pastry and place them into the *fridge*, the following code can be used:

```Go
some_egg = GetP(rep,"pastry","eggs",&quantity)
if (some_egg) Put(rep,"fridge","eggs",quantity)
```  


### Gates
A repository can be also accessed by a remote process. To enable this feature a *gate* must be added to the repository.

A *gate* can be thought of as a communication port and it is identified by an *uri* of the form:

```
<protocol>://<address>:<id>/?<par1>&...&<parn>
```

Above ```<protocol>``` identifies the communication protocol. Different kinds of communication protocols can be considered. Examples of protocols are: ```tcp``` or ```udp```, when standard TCP or UDP sockets are used;  ```http```, when a web-oriented communciation protocol is used; or ```bt```, when BlueThoot communication is supported.

The element ```<address>``` is a string identifying the local port used to accept requests; ```<id>``` is an integer value while ```<par1>```,..., ```<parn>``` are extra parameters that can be used to configure the interaction protocol. The precise meaning of these values is related to the value ```<protocol>```. For instance, when this is ```tcp```, ```<address>``` can be the network address of the local network interface used for the communication, ```<id>``` is the *socket port* used to accept connections, while ```<pari>``` can be used to select the format used to serialise data:

```go
AddGate(rep,"tcp://127.0.0.1:9090/?lang=JSON")
```

### Remote spaces

If Alice is not located at the same host where the repository is stored, she must first create a *remote space*. This can be viewed as a *proxy* that allow to access to a specific space in a repository. To create a remote space, a *uri* is needed:

```Go
remote_pastry = RemoteSpace("tcp://my.host.it:9090/pastry?lang=JSON")
remote_fridge = RemoteSpace("udp://your.host.dk:9191/fridge?lang=XML")
some_egg = GetP(remote_pastry,"eggs",&quantity)
if (some_egg) Put(remote_fridge,"eggs",quantity)
```  

In the code above Alice use ```remote_pastry``` to interact with the space ```pastry``` that is provided by a repository located at ```my.host.it```. This interaction follows the ```tcp``` protocol and messages are serialised by using ```JSON``` documents. At the same time, ```remote_fridge``` is used to interact with a space located ```your.host.dk``` via ```udp```. In this case an ```XML``` encoding is used to serialise data.
