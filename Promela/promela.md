This document provides some guidelines on how to use the [Spin](http://spinroot.com/) model checker to model and verify pSpace applications.

# Limitations
Models in of Spin model checker are specified in [Promela](http://spinroot.com/spin/Man/Intro.html), a specification language with a C-like syntax which supports concurrent processes communicating via shared memory and message channels. Promela does *not* support the all features of pSpace implementations but a subset of them can be easily encoded in Promela. In particular, the main limitations are:
- Promela does not support repositories or gates. Spaces are should be directly modelled as channels.
- Only one class of space can be modelled, namely bounded sequential spaces.
- Each space can hold only tuples of the same format (declared statically).

# Creating a space
A space is created by creating a correspoding channel. For example 

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
Templates are specified as follows. If a variable `v` appears in the template, the value from the corresponding field in the tuple that is matched is copied into `v` upon retrieval of the tuple. To avoid updating the variable and just using the variable as its value, one has to use `eval(v)` to force a match of a message field with the current value of variable `v`. 

# Examples
See:
- [Dining philosophers](philosophers-0.md)



