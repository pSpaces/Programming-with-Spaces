# 3. Distributed Programmiong with Tuple Spaces

This chapter provides a gentle introduction to distributed computing using pSpaces. In the [previous chapter](tutorial-concurrent-programming.md) we showed how spaces can be used to support concurrent programming, where several processes on the same machine communicate and cooperate using a shared tuple space. In a distributed systems, processes and data repositories are spread among several devices possibly far away one from each other. The chapter is illustrated with a scenario where Alice and her friends interact using social networking tools and some other internet-based tools like chats.

## 3.1 Sharing a space

In a distributed system, tuple spaces intended to be accessible from remote devices must be explicitly exposed and must have unique addresses to identify them. In pSpaces we use URIs for this purpose. A basic form of URI currently supported is

```go
tcp://host:port/space
```

where `host` is the name or IP address of the device hosting the tuple space, `port` is a valid port, and `space` is the identifier for the tuple space.

For example, suppose that Alice and her friends want to create a simple chat server to communicate. The server will just host a tuple space for all messages to be collected and displayed. The server can create such a space with

```go
chat := NewSpace(tcp://localhost:3115/room123)
```

Once created, the server can keep retrieving and printing messages with

```go
chat.Get(&who, &message)
fmt.Printf("%s: %s \n", who, message)
```

## 3.2 Accesing a remote space

A remote tuple space, possibly residing on another device, accepts the same operations as local tuple space. The only difference is that we need to create the space slightly differently. In our example, Alice and her friends can implement clients that connect to the server `chat.com` with:

```go
chat := NewRemoteSpace(tcp://chat.com:3115/room123)
```

after which the space `chat` can be treated as an ordinary tuple space. For example, messages can be sent with 

```go
chat.Put("Alice","Hi!")
```

## 3.3 A coordination pattern: private spaces

A typical coordination pattern in distributed programming is the creation of fresh contexts for private conversations (e.g. sessions in communication protocols). We illustrate this pattern with our example of the chat server.

## 3.4 A coordination pattern: remote evaluation

Strong forms of code mobility based on sending actual code are currently not supported. This is one of the main reasons why conditional pattern matching (i.e, pattern matching enriched with additional predicates as in SQL'a `WHERE` clauses) and atomic update operations are not currently supported.

Weak forms of code mobility are of course supported. A typical pattern is *remove evaluation*.


## 3.5 Space repositories
Some pSpace implementations (e.g. jSpace and dotSpace) support mechanisms to organise spaces and their exposition. Spaces can be put together in a *space repository*. Each space in the repository must univocally identified by a name. The following Java code can be used to create a repository and add two chat rooms to the same repository:"

```java
chatRepository = SpaceRepository();
chatRepository.Add("room123",New SequentialSpace());
chatRepository.Add("room456",New SequentialSpace());
```

## 3.6 Gates
The main purpose of using space repositories ease the exposure of spaces on common ports. Access to all spaces within a repository can be done by adding a gate to the repository. A *gate* can be thought of as a communication port and it is identified by an URI of the form:

```
<protocol>://<address>:<id>/?<par1>&...&<parn>
```

where `<protocol>` identifies the communication protocol, `<address>` is a string identifying the local port used to accept requests, `<id>` is an integer, and `<par1>`,..., `<parn>` are extra parameters that can be used to configure the interaction protocol.

Currently, most pSpace implementations provide support for `tcp` only but some implementations plan to support `udp`, `bt` (blueetooth) and `http`. The fields `<address>` and `<id>` depend on the protocol.  In the case of `tcp`, `<address>` can be the network address of the local network interface used for the communication and  `<id>` the *socket port* used to accept connections, while ```<pari>``` can be used to select the format used to serialise data.

## 3.7 Strong mobility

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

