# Documentation

# I want to program with Spaces in language X
You are in the wrong place :) Go to the the documentation of xSpaces follow the instructions.

# Can a program written in X and another one written in Y interact through Spaces?
Yes, they can. Instructions coming soon...

# I want to implement a new support for Spaces in language X
You should adhere to the below guidelines. The key idea of the programming model is to support interaction by adding and retrieving tuples from local and remote spaces. Programs and spaces can be located in any device. All spaces support the same minimal API and interaction protocols.
 
## Local Spaces
A space is is a collection of tuples supporting a simple API described below. Whenever possible the interface or abstract data type used for specify the API of spaces should be called `Space`.

## Space API
Spaces should implement an interface that supports several operations. Every implementation must support the core API specified below. Other operations may be supported.

### Core Space API
All spaces must implement the following operations:
- `put` adds a tuple to a space. 
- `get` blocks until a tuple is found in the space which matches a given template. It then returns the matched tuple and removes it from the space. 
- `getp` is the non-blocking version of `get`. In addition to the matching tuple, it returns whether the operation was successful or not.
- `getall` is a non-blocking operation that returns all tuples matching a template and removes them from the space.
- `query` is the non-destructive version of `get`. Given a template, the operation blocks until a tuple is found in the space which matches the template. It then returns the matched `tuple` and removes it from the space. 
- `queryp` is the non-blocking version of query. In addition to the matching tuple, it returns whether the operation was successful or not.
- `queryall` is the non-destructive version of `getAll`.

All the above operations may fail (e.g. due to communication errors or denied access) and must return a value stating indicating success or failure.

The core API underspecifies the behaviour of some operations. For example, the order of retrievals is underspecified, and different variants may include FIFO (return the oldest matching tuple), LIFO (return the newest matching tuple), or random (randomly return any matching tuple). The corresponding space structures can be called FifoSpace, LifoSpace, RandomSpace, etc.
 
A space can be accessed locally as an ordinary data structure and can hence offer a local API. Spaces can be accessed remotely and should hence support a remote API. Whenever possible, a wrapper for remote spaces should be offered to support a uniform access to spaces. 

## Space repositories and space gates
To make a space accessible remotely, the space must be part of a space repository. Whenever possible, the data structure for space repositories should be named `SpaceRepository`. Space repositories should be equipped with one or more gates. Each gate is specified by an URI with the following format:
 
`<protocol>://<host>[:<port>][?<mode>]`
 
where
- `protocol` is the protocol used for the communication. The default value is pspaces, which amounts to tcp sockets.
- `host` is the name or ip address of the device where the space is located.
- `port` is a port number. The default value is 31415.
- `mode` specifies an interaction protocol (described below). The options are `KEEP`, `CONN`, `PUSH` and `PULL`. The default value is `KEEP`.
 
As an example, a user should be able to create a space repository at `coolspaces.com` with two spaces `data` and `messages` in an object-oriented language with code along the lines of:
 
```
SpaceRepository repository = new SpaceRepository();
repository.addGate("pspaces://coolspaces.com:8888?CONN");
repository.add(new Space(“data”));
repository.add(new Space(“messages”));
```

Remote spaces are addressed with a space address, which is an URI of the format
 
`<protocol>://host[:port]/<space_name>[?<connectiontype>]`
 
The format is very much like that of gates, but with name of the space.
 
In our example, a programmer should be able to access the spaces created above with code along the lines of

```
Space data= new RemoteSpace(“pspaces://coolspaces.com:8888/data?CONN”);
Space messages= new RemoteSpace(“pspaces://coolspaces:8888/messages?CONN”);
```

assuming a wrapper `RemoteSpace` is supported.
 
## Agents
Programs interacting with local or remote spaces are often called agents in this documentation. Agents need not be implemented as a first class concept in the host programming language and can correspond to any form of behaviour encapsulation provided by the host programming language (routines, threads, programs, activities, objects, ...). If you decide to implement agents as a first-class structure, the name `Agent` should be preferred.

## Protocol for operations on remote spaces

### CORE Protocol

The protocols used to access remote spaces are based on a simple request/response pattern:

  `A ---[request]--> B`

  `A <--[response]-- B`

Party `A` is the one willing to perform the operation on `B`. `A` initiates the protocol and indicates which specific protocol it wants to use (see message format below). The options are `CONN`, `PUSH` and `PULL`.

When method `CONN` is used, only one connnection is used and the request and its response are exchanged in the same connection. When `PUSH` is used, the two messages are exchanged in two separate connections: the first opened by `A` and the second opened by `B`. Finally, in `PULL` mode, a connection is used for each time party `A` tries to get a response from party `B`.

The correlation between requests and response is based on session identifiers (see below). Requests and responses are messages serialised in JSON format and their content depends on the kind of request/response.

### Put requests

Put requests have the following format

`{ "mode": mode_code, "action": "PUT_REQUEST", "source" : source, "session": session, "target": target, "tuple" : tuple }`

where 
- `mode` is the code identifying the actual protocol.
- `source` is a port that identifies the requester.
- `session` is an integer that uniquely identifies the request on the source side (if mode is `CONN` this field is optional).
- `target` identifies the target space with a global identifier.
- `tuple` is the tuple, represent as a json list, that should be added.

### Put responses

`{ "action": "PUT_RESPONSE", "source" : source, "session": session, "target": target, "code" : code , "message": message }`

where 
- `source` identifies the original requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `target` is a global identifier that identifies the target space.
- `code` is an HTTP like return code.
- `message` is a string providing additional information related to the return code.

### Get[p/all]/Query[p/all] requests

Get requests have the following format

`{ "mode": mode_code, "action": response, "source" : source, "session": session, "target": target, "template" : template }`

where 
- `mode' is the code identifying the actual protocol.
- `response` is one of `GET_RESPONSE`, `GETP_RESPONSE`, `GETALL_RESPONSE`, `QUERY_RESPONSE`, `QUERY_RESPONSE`, `QUERYALL_RESPONSE`.
- `source` identifies the requester.
- `session` is a unique session identifier used by the source to distinguish requests (if mode is `CONN` this field is optional).
- `target` is a global identifier that identifies the target space.
- `template` is the template to be considered.

### Get/Query  responses

`{ "action": request, "source" : source, "session": session, "target": target, "result":result , "code" : code , "message": message }`

where 
- `request` is one of `GET_RESPONSE`, `GETP_RESPONSE`, `GETALL_RESPONSE`, `QUERY_RESPONSE`, `QUERY_RESPONSE`, `QUERYALL_RESPONSE`.
- `source` identifies the original requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `target` identifies the target space.
- `success` is a return code (see below).
- `result` contains the result of the operation (if successful) as a list of tuples.
- `code` is an HTTP like return code.
- `message` is a string providing additional information related to the return code.

## Adhere to the following guidelines to structure your project
Instructions coming soon...

## Document your project :)
