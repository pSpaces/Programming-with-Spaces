# 3. Distributed Programmiong with Tuple Spaces

This chapter provides a gentle introduction to distributed computing using pSpaces. In the [previous chapter](tutorial-concurrent-programming.md) we explain how spaces can be used to support concurrent programming, where several processes on the same machine communicate and cooperate using one or several shared tuple spaces. In distributed systems, processes and data repositories are spread among several devices possibly far away from each other. This chapter explains how to make spaces accessible from remote applications.

## 3.1 Space URIs

Tu spaces intended to be accessible from remote devices must be explicitly exposed and must have unique addresses to identify them. In pSpaces we use URIs for this purpose. A basic form of URI currently supported in pSpace is

```go
tcp://host:port/space
```
where `tcp` specifies to use the TCP communication protocol, `host` is the name or IP address of the device hosting the tuple space, `port` is a valid port (e.g. a port number, and `space` is the identifier for the tuple space. Some implementations of pSpaces support several protocols beyond `tcp` and can handle additional parameters in the URI as we shall see later.

## 3.2 Sharing a space in Go

Most pSpaces libraries (including [jSpace](https://github.com/pSpaces/jSpace) and [dotSpace](https://github.com/pSpaces/dotSpace)) rely on the notion of space repository and space gates to structure the way local spaces are exposed to external applications. [goSpace](https://github.com/pSpaces/goSpace) does not yet support repositories and gates and relies on a simpler mechanism that we explain here.

Suppose that Alice and her friends want to create a simple chat server to communicate with each other. The server will just host a tuple space for all messages to be collected and it will take care of displaying the messages on a shared screen. The server can create such a space in Go with

```go
chat := NewSpace("tcp://localhost:31415/room123")
```

Once created, the server can keep retrieving and printing messages with

```go
var who string
var message string
for {
  chat.Get(&who, &message)
  fmt.Printf("%s: %s \n", who, message)
}
```

## 3.3 Accesing a remote space

A remote tuple space, possibly residing on another device, accepts the same operations as local tuple space. The only difference is that we need to create the space slightly differently, namely with the `NewRemoteSpace` constructor.

In our example, Alice and her friends can implement clients that connect to the server running in `chathost` in Go with:

```go
chat := NewRemoteSpace("tcp://chathost:3115/room123")
```

after which the space `chat` can be treated as an ordinary tuple space. For example, messages can be sent with 

```go
chat.Put("Alice","Hi!")
```

Remote spaces are accessed similarly in libraries supporting repositories and gates.

## 3.4 Space repositories
Some pSpace implementations (including [jSpace](https://github.com/pSpaces/jSpace) and [dotSpace](https://github.com/pSpaces/dotSpace)) support mechanisms to organise and control how spaces are exposed to external applications. Spaces can be put together in a *space repository*. Each space in the repository must be univocally identified by a name. The following Java code can be used to create a repository and add two chat rooms in the same repository:

```java
SpaceRepository chatRepository = new SpaceRepository();
chatRepository.Add("room123",New SequentialSpace());
chatRepository.Add("room456",New SequentialSpace());
```

## 3.5 Gates
The main purpose of using space repositories is to ease the exposure of spaces that need to have the same kind of external access. Each way to access all spaces within a repository is called a *gate*. A gate can be thought of as a communication port and it is identified by an URI of the form:

```
<protocol>://<address>:<id>/?<par1>&...&<parn>
```

where `<protocol>` identifies the communication protocol, `<address>` is a string identifying the local port used to accept requests, `<id>` is an integer, and `<par1>`,..., `<parn>` are extra parameters that can be used to configure the interaction protocol.

Currently, most pSpace implementations provide support for `tcp` only but some implementations plan to support `udp`, `bt` (blueetooth) and `http`. The fields `<address>` and `<id>` depend on the protocol.  In the case of `tcp`, `<address>` can be the network address of the local network interface used for the communication and  `<id>` the *socket port* used to accept connections, while ```<pari>``` can be used to select the format used to serialise data (e.g. `keep` to keep connections open or `conn` to open a new connection for every tuple space operation).

Following on our example, the server of chat rooms can open a gate for Alice and her friends with

```java
chatRepository.AddGate("tcp://localhost:311415/?keep");
```

Then Alice and her friends con connect to it with

```java
RemoteSpace chat = new RemoteSpace("tcp://chathost:311415/?keep")
```

## 3.6 What can be send around?



## 3.3 A coordination pattern: private spaces

A typical coordination pattern in distributed programming is the creation of fresh contexts for private conversations (e.g. sessions in communication protocols). We illustrate this pattern with our example of the chat server.

## 3.4 A coordination pattern: remote evaluation

Strong forms of code mobility based on sending actual code are currently not supported. This is one of the main reasons why conditional pattern matching (i.e, pattern matching enriched with additional predicates as in SQL'a `WHERE` clauses) and atomic update operations are not currently supported.

## 3.7 Mobility

Strong forms of code mobility based on sending actual code are currently not supported. This is one of the main reasons why conditional pattern matching (i.e, pattern matching enriched with additional predicates as in SQL'a `WHERE` clauses) and atomic update operations are not currently supported.

## Summary
 
We have seen the following operations to access remote spaces:
- `RemoteSpace`: given an URI, it creates a local reference to a remote space.

We have seen the following coordination patterns:
- Private space creation
- Remote evaluation

A complete example for this chapter can be found [here](https://github.com/pSpaces/goSpace-examples/blob/master/tutorial/chat-0/main.go).

## Reading suggestions
De Nicola, R., Ferrari, G. L., and Pugliese, R. (1998). KLAIM: A kernel language for agents interaction and mobility. IEEE Trans. Software Eng., 24(5):315–330

## What next?

Stay tuned for more chapters :)

