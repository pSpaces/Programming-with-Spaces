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

The protocol to access remote spaces are based on a simple request/response pattern:

  `A ---[request]--> B`

  `A <--[response]-- B`

Each message must be sent in a separate connection. The correlation between requests and response is based on session identifiers (see below). Requests and responses are messages serialised in JSON format and their content depends on the kind of request/response.

### Put requests

Put requests have the following format

`{ "type": "PUT_REQUEST", "source" : source, "session": session, "target": target, "tuple" : tuple > }`

where 
- `source` is a port that identifies the requester.
- `session` is an integer that uniquely identifies the request on the source side.
- `target` identifies the target space with a global identifier.
- `tuple` is the tuple, represent as a json list, that should be added.

### Put responses

`{ "type": "PUT_RESPONSE", "source" : source, "session": session, "target": target, "code" : code , "message": message> }`

where 
- `source` identifies the original requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `target` is a global identifier that identifies the target space.
- `code` is an HTTP return code.
- `message` is a string providing additional information related to the return code.

### Get[p/all]/Query[p/all] requests

Get requests have the following format

`{ "type": response, "source" : source, "session": session, "target": target, "template" : template }`

where 
- `response` is one of `GET_RESPONSE`, `GETP_RESPONSE`, `GETALL_RESPONSE`, `QUERY_RESPONSE`, `QUERY_RESPONSE`, `QUERYALL_RESPONSE`.
- `source` identifies the requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `target` is a global identifier that identifies the target space.
- `template` is the template to be considered.

### Get/Query  responses

`{ "type": request, "source" : source, "session": session, "target": target, "success" : success, "result":result }`

where 
- `request` is one of `GET_REQUEST`, `GETP_REQUEST`, `GETALL_REQUEST`, `QUERY_REQUEST`, `QUERY_REQUEST`, `QUERYALL_REQUEST`.
- `source` identifies the original requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `target` identifies the target space.
- `success` is a return code (see below).
- `result` contains the result of the operation (if successful) as a list of tuples.

## Adhere to the following guidelines to structure your project
Instructions coming soon...

## Document your project :)
