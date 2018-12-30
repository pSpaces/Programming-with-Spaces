# 3. Distributed Programming with Tuple Spaces

This chapter provides a gentle introduction to distributed computing using pSpaces. In the [previous chapter](tutorial-concurrent-programming.md) we explained how spaces can be used to support concurrent programming, where several processes on the same machine communicate and cooperate using one or several shared tuple spaces. In distributed systems, processes and data repositories are spread among several devices possibly far away from each other. This chapter explains how to make spaces accessible from remote applications. As a running example we consider chat application that Alice and her roommates can use exchange messages.

## 3.1 Space repositories
Space repositories are used organise and control how spaces are exposed to external applications. Each space in a repository must be univocally identified by a name. The following Java code can be used to create a repository and add two chat rooms in the same repository:

```java
SpaceRepository chatRepository = new SpaceRepository();
chatRepository.Add("room1",New SequentialSpace());
chatRepository.Add("room2",New SequentialSpace());
```

## 3.2 Gates
Space repositories ease the exposure of spaces that need to have the same kind of external access. This is done through *gates*. A gate can be thought of as a communication port and it is identified by an URI of the form:

```
<protocol>://<address>:<id>/?<par1>&...&<parn>
```

where `<protocol>` identifies the communication protocol, `<address>` is a string identifying the local port used to accept requests, `<id>` is an integer, and `<par1>`,..., `<parn>` are extra parameters that can be used to configure the interaction protocol.

Currently, most pSpace implementations provide support for `tcp` only but some implementations plan to support `udp`, `bt` (bluetooth) and `http`. The fields `<address>` and `<id>` depend on the protocol.  In the case of `tcp`, `<address>` can be the network address of the local network interface used for the communication and  `<id>` the *socket port* used to accept connections, while ```<pari>``` can be used to select the format used to serialise data (e.g. `keep` to keep connections open or `conn` to open a new connection for every tuple space operation).

Following on our example, the server of chat rooms can open a gate for Alice and her friends with

```java
chatRepository.addGate("tcp://localhost:31415/?keep");
```

## 3.3 Accesing a remote space

A remote tuple space, possibly residing on another device, accepts the same operations as a local tuple space. The only difference is that we need to create the space slightly differently, namely with the `RemoteSpace` constructor. In our example Alice and her friends con connect to the chatoom `room1` it with

```java
RemoteSpace chat = new RemoteSpace("tcp://chathost:31415/room1?keep")
```

after which the space `chat` can be treated as an ordinary tuple space. For example, messages can be sent with 

```go
chat.put("Alice","Hi!")
```

## 3.4 What can be send around?

There are limitations on the datatypes that can be used in the remote tuple space operations, partly due to the underlying serialisers used by the libraries. Currently the limitations are language dependent. Some examples are:

* Java: current support is mainly limited to JSON (see [serialization in jSpace](https://github.com/pSpaces/jSpace/blob/master/docs/jspace_serialization.md))
* Go: current support is mainly limited to datatypes serializable by [gob](https://golang.org/pkg/encoding/gob/)
* C#: current support is limited to primitive datatypes.

Some examples of common restrictions are:
* datatypes should be known on both sides.
* references and pointers cannot be sent, typically the pointed/reference data will be send.

## 3.5 A simple chat application

We can now put everthing that we have discussed so far in a simple chat application for Alice and her roommates. The server will just host a tuple space for all messages to be collected and it will take care of displaying the messages on a shared screen. 

The code for Alice and her roommates would be be as follows

```java
RemoteSpace chat = new RemoteSpace("tcp://server:9001/chat?keep");

while(true) {
    String message = input.readLine();
    chat.put(user_name, message);
}			
```

where `server` is the server name or ip address, which uses the port `9001`.

The server's code would be:

```java
// create repository
SpaceRepository repository = new SpaceRepository();

// Create a local space for the chat messages
SequentialSpace chat = new SequentialSpace();

// Add the space to the repository
repository.add("chat", chat);

// Open a gate
repository.addGate("tcp://server:9001/?keep");

// Keep reading chat messages and printing them 
while (true) {
    Object[] t = chat.get(new FormalField(String.class), new FormalField(String.class));
    System.out.println(t[0] + ":" + t[1]);
}
```

## 3.6 A coordination pattern: private spaces

A very useful coordination pattern in distributed programming is the creation of fresh contexts for private conversations. The typical example is the use of sessions in communication protocols. We illustrate this pattern with our example of the chat server. The main idea is that the server will host a `lobby` space to receive requests to enter specific chatrooms from Alice and her friends. The server reply to those requests with the URI of the space used to handle the corresponding chatroom. If the chatroom does not exist, a new space and a corresponding handler will be created for it.

More in detail, Alice and her friends can request to enter a room by placing a request `("enter", name, roomID)` specifying the identifier `roomID` of the room and then waiting for a reply from the server. The reply has format `("roomURI", name, roomID, roomURI)`, where `roomURI` is the URI of the space where the chatroom resides:

```java
// Connnect to the lobby
RemoteSpace lobby = new RemoteSpace("tcp://server:9001/lobby?keep");
// Send chatroom request
lobby.put("enter", name, roomID);
// Obtain response
Object[] response = chat.get(new ActualField("roomURI"), new ActualField(name), new FormalField(String.class), new FormalField(String.class));
String rooom_uri = response[3];
// Connect to the chatroom
RemoteSpace chatroom = new RemoteSpace(room_uri);
```

The server keeps the list of existing room identifiers and their associated port numbers. If a client requests to enter an existing room then the server builds the URI based on port number associated to the room. Otherwise, a new space is created at a fresh URI and a process `roomHandler` is spawned to handle the chat room. In both cases, the server replies with the URI of the space that is used to handle the requested chat rooom:

```go
while (true) {
    // Read chatroom request
    Object[] request = lobby.get(new ActualField("enter"),new FormalField(String.class), new FormalField(String.class));
    String who = (String) request[1];
    String roomID = (String) request[2];
    
    // If the chatroom exists just prepare the response with the corresponding URI
    Object[] the_room = rooms.queryp(new ActualField(roomID),new FormalField(String.class));
    if (the_room != null) {
    	roomURI = "tcp://127.0.0.1:9001/chat" + the_room[1] + "?keep";
    } 
    // If the chatroom does not exist, create the chatroom and launch a chatroom handler
    else {
        System.out.println("Creating room " + roomID + " for " + who + " ...");	
        roomURI = "tcp://127.0.0.1:9001/chat" + roomC + "?keep";
        new Thread(new roomHandler(roomID,"chat"+roomC,roomURI,repository)).start();
        rooms.put(roomID,roomC);
        roomC++;
    }

    // Sending response back to the chat client
    lobby.put("roomURI", who, roomID, roomURI);
}
```

## 3.7 A coordination pattern: remote procedure call

Strong forms of code mobility based on sending actual code are currently not supported in pSpace libraries. This is one of the main reasons why operations such as atomic updates or conditional pattern matching (i.e, pattern matching enriched with additional predicates as in SQL'a `WHERE` clauses) are not currently supported. However, softer forms of code mobility can obtained. An example are remote procedure calls (RPCs).

Suppose, for example, that Alice and her friends need to compute functions such as `foo(1,2,3)` and `bar("a","b")` and want a server to do the job for them. They can send their RPC requests by first sending the function name and the arguments in separate tuples and then waiting for the result:

Client
```java
server.put("Alice", "func", "foo")
server.put("Alice", "args", 1, 2, 3)
Object[] response = server.get(new ActualField("Alice"), new ActualField("result"), new FormalField(Integer.class)
```

The server process the RPCs of Alice and her friends by getting the function to be executed first and retrieving the arguments (of the right types) then. It would then invoke the function and send back the result to the callee:

```java
for {
  t,_ := mySpace.Get(&callID, "func", &f)
  callID = (t.GetFieldAt(0)).(string)
  f = (t.GetFieldAt(2)).(string)
  switch f {
  case "foo":
    t,_ := mySpace.Get(callID, "args", &x, &y, &z)
    result := foo((t.GetFieldAt(2)).(int), (t.GetFieldAt(3)).(int), (t.GetFieldAt(4)).(int))
    mySpace.Put(callID, "result", result)
  case "bar":
    t,_ := mySpace.Get(callID, "args", &a, &b)
    result := bar((t.GetFieldAt(2)).(string), (t.GetFieldAt(3)).(string))
    mySpace.Put(callID, "result", result)
  default:
    // ignore RPC for unknown functions
    continue
  }
}
```

Note that a mechanism is needed to uniquely identify the RPCs. In the above example we are using the first field of the tuples as identifier for the RPCs but one could also use private spaces as seen above. The server in the above example can of course be made more sophisticatd, e.g. by handling the RPCs asynchronously or dealing with calls to unknown functions differently.

## Summary
 
We have seen the following operations to access remote spaces:
- `RemoteSpace`: constructor to create a local reference to a remote space specified by an URI.
- `Repository`: a collector of spaces.
- `addSpace`: operation to add a space to a space repository.
- `addGate`: operation to open a gate (external access) to a space repository.

We have seen the following coordination patterns:
- Private space creation.
- Remote procedure calls.

Complete examples for this chapter can be found here:
* Java: [simple chat](https://github.com/pSpaces/jSpace-examples/tree/master/tutorial/chat-0), [chat with private spaces for each room](https://github.com/pSpaces/jSpace-examples/tree/master/tutorial/chat1)
* Go: [simple chat](https://github.com/pSpaces/goSpace-examples/tree/master/tutorial/chat-0), [chat with private spaces for each room](https://github.com/pSpaces/goSpace-examples/tree/master/tutorial/chat-1), [remote procedure calls](https://github.com/pSpaces/goSpace-examples/tree/master/tutorial/rpc-0)

## Reading suggestions
* De Nicola, R., Ferrari, G. L., and Pugliese, R. (1998). KLAIM: A kernel language for agents interaction and mobility. IEEE Trans. Software Eng., 24(5):315–330

## What next?

Stay tuned for more chapters :)

