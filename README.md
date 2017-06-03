# Documentation

# I want to program with Spaces in language X
Just go to xSpaces and follow the instructions ;)

# Can a program written in X and another one written in Y interact through Spaces?
Yes, they can. Instructions coming soon...

# I want to implement a new support for Spaces in language X
Follow the below instructions.
## (1) Adhere to the following API for the tuple space
Spaces should implement an interface supports several operations.

### CORE Interface
All spaces must implement the following operations:
- `put` adds a tuple to a space. 
- `get` blocks until a tuple is found in the space which matches a given template. It then returns the matched tuple and removes it from the space. 
- `getp` is the non-blocking version of `get`. In addition to the matching tuple, it returns whether the operation was successful or not.
- `getall` is a non-blocking operation that returns all tuples matching a template and removes them from the space.
- `query` is the non-destructive version of `get`. Given a template, the operation blocks until a tuple is found in the space which matches the template. It then returns the matched `tuple` and removes it from the space. 
- `queryp` is the non-blocking version of query. In addition to the matching tuple, it returns whether the operation was successful or not.
- `queryall` is the non-destructive version of `getAll`.

All the above operations may fail (e.g. due to communication errors or denied access) and must return a value stating indicating success or failure.


## (2) Provide basic support for accessing remote spaces

Access to remote spaces is done via ports. The default type of port that implementations should support are sockets. Other type of ports may be supported.

Several spaces may be accessible through the same port. Spaces are hence uniquely identified by global space identifier, defined by a port and a space name.

## (3) Adhere to the following protocol for operations on remote spaces

### CORE Protocol

The protocols used to access remote spaces are based on a simple request/response pattern:

  `A ---[request]--> B`

  `A <--[response]-- B`

Party `A` is the one willing to perform the operation on `B`. `A` initiates the protocola and indicates which specific protocol it wants to use (see message format below). The options are `CONN`, `PUSH` and `PULL`.

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
