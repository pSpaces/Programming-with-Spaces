# Documentation

# I want to program with Spaces in language X
Just go to xSpaces and follow the instructions ;)

# Can a program written in X and another one written in Y interact through Spaces?
Yes, they can. Instructions coming soon...

# I want to implement a new support for Spaces in language X
Follow the below instructions.
## Adhere to the following API for the tuple space
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
All the above operations may fail and must return a value stating indicating success or failure.

## Adhere to the following protocol for operations on remote spaces

Detailed instructions will be included soon. 

### CORE Protocol

The protocol to access remote spaces are based on a simple request/response pattern:

  `A ---<request>--> B`

  `A <--<response>-- B`

Requests and responses are serialised in JSON format and their content depends on the kind of request.

### Put requests

Put requests have the following format

`{ "type": "PUT_REQUEST", "source" : source, "session": session, "target": target, "tuple" : tuple >`

where 
- `source` identifies the requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `session` identifies the target space.
- `tuple` is the tuple that should be added.

### Put responses

`{ "type": "PUT_RESPONSE", "source" : source, "session": session, "target": target, "response" : response >`

where 
- `source` identifies the original requester.
- `session` is a unique session identifier used by the source to distinguish requests.
- `session` identifies the target space.
- `response` is either `true` (the request succeeded) or `false` (the request failed).

More instructions coming soon...

## Adhere to the following guidelines to structure your project
Instructions coming soon...

## Document your project :)
