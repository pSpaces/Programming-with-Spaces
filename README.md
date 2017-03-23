# Documentation

# I want to program with Spaces in language X
Just go to xSpaces ;)

# I want to develop a distributed application where components use different languages
Instructions coming soon...

# I want to implement a new support for Spaces in language X
Follow the below instructions
## Adhere to the following API for the tuple space

Spaces should be implemented as a data structure with an API that supports several operations.

### CORE API
All spaces must implement the following operations:
- put: adds a tuple to a space.
- get: given a template, the operation blocks until a tuple is found in the space which matches the template. It then returns the matched tuple and removes it from the space. 
- getp: non-blocking version of get. In addition to the matching tuple, it returns whether the operation was successful or not.
- query: non-destructive version of get. Given a template, the operation blocks until a tuple is found in the space which matches the template. It then returns the matched tuple and removes it from the space. 
- queryp: non-blocking version of query. In addition to the matching tuple, it returns whether the operation was successful or not.

### EXTRA API
Spaces may offer additional operations:
- getAll
- queryAll
- etc.

## Adhere to the following protocol for operations on remote spaces
Instructions coming soon...

## Adhere to the following guidelines to structure your project
Instructions coming soon...

## Document your project :)
