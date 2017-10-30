This document provides some guidelines on how to use the [Spin](http://spinroot.com/) model checker to model and verify pSpace applications.

# Spin installation and tutorials
- [Installing Spin](http://spinroot.com/spin/Man/README.html)
- [Tutorials and Manuals](http://spinroot.com/spin/Man/)

# Limitations
Models in the Spin model checker are specified in [Promela](http://spinroot.com/spin/Man/Intro.html), a specification language with a C-like syntax which supports concurrent processes communicating via shared memory and message channels. Promela does *not* naturally support all features of pSpace implementations but a subset of them can be easily encoded in Promela. In particular, the main limitations are:
- Promela does not support repositories or gates. Spaces are must be directly modelled as channels.
- Only one class of space can be modelled, namely bounded sequential spaces.
- Each space can hold only tuples of the same format (declared statically).
- Tuple fields are limited to [basic data types](http://spinroot.com/spin/Man/datatypes.html).

# Creating a space
A space is created by declaring a correspoding channel. For example 

```C
chan space = [N] of { type1, type2, ..., typen };
```

creates a bounded sequential space named `space` able to contain `N` tuples of type `type1, type2, ..., typen`.

# Operations
Not all operations are supported in Promela and the actual syntax is significantly different from the one in pSpaces. These are the operations supported and the way they are expressed in Promela:

- PUT: `space!a,b,...` puts the tuple `<a,b,...>` in the space `space`.
- GET: `space??template` gets the oldest matching the template `template`. Instead of returning a tuple, the resulting tuple is used to update variables in the template (see the below description on templates and matching).
- QUERY: `space??<template>` behaves as as above, but without removing the matched tuple.
- QUERYP: `space??[template]` returns `true` if a matching tuple is found, and `false` otherwise.

# Templates and Matching
Templates are comma-separated sequences of expressions (possibly using variables and constants). If a field of the template is just a variable `v`, the value from the corresponding field in the tuple that is matched is copied into `v` upon retrieval of the tuple. To avoid updating the variable and just using the variable as its value, one has to use `eval(v)` to force a match of a message field with the current value of variable `v`. 

# Examples
The following examples are available:
- [Hello World!](HelloWorld.pml): a "hello world!" example.
- [Dining philosophers 0](philosophers-0.md): wrong solution (deadlocks) to the [dining philosophers problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem).
- [Dining philosophers 1](philosophers-1.md): correct solution to the [dining philosophers problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem), based on tickets.



