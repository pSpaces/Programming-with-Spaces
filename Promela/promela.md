This document provides some guidelines on how to use the [Spin](http://spinroot.com/) model checker to model and verify pSpace applications.

# Spin installation and tutorials
- [Installing Spin](http://spinroot.com/spin/Man/README.html): a guide to install Spin.
- [Tutorials and Manuals](http://spinroot.com/spin/Man/): a list of tutorials and manuals. Pages 8-12 of this [tutorial](http://spinroot.com/spin/Doc/SpinTutorial.pdf) provides a very concise introduction of [Promela](http://spinroot.com/spin/Man/Intro.html), the specification language of Spin.

# Limitations
Models in the Spin model checker are specified in [Promela](http://spinroot.com/spin/Man/Intro.html). Promela is a specification language with a C-like syntax. It supports concurrent processes communicating via shared memory and message channels. Promela does *not* naturally support all features of pSpace implementations but a subset of them can be easily encoded in Promela. In particular, the main limitations are:
- Promela does not support repositories or gates. Spaces are must be directly modelled as channels.
- Only one class of space can be modelled, namely bounded sequential spaces.
- Each space can hold only tuples of the same format (declared statically).
- Tuple fields are limited to [Promela basic data types](http://spinroot.com/spin/Man/datatypes.html).

# Creating a space
A space is created by declaring a correspoding channel. For example 

```C
chan space = [N] of { byte , int};
```

creates a bounded sequential space named `space` able to contain `N` tuples of format `(byte, int)`.

# Operations
Not all operations are supported in Promela and the actual syntax is significantly different from the one in pSpaces. These are the operations directly supported and the way they are expressed in Promela:

- `put`: `space!a,b,...` puts the tuple `(a,b,...)` in the space `space`.
- `query`: `space??template` queries the oldest tuple matching the template `template` (blocks until there is one such tuple). Instead of returning a tuple, the resulting tuple is used to update variables in the template (see the below description on templates and matching), similarly as in [goSpaces](https://github.com/pSpaces/goSpace).
- `queryP`: `space??[template]` returns `true` if a matching tuple is found, and `false` otherwise.
- `get`: `space??template` removes the oldest tuple matching the template `template` (blocks until there is one such tuple). Instead of returning a tuple, the resulting tuple is used to update variables in the template (see the below description on templates and matching).

Additional operations like `getP`, `getAll` and `queryAll` can be encoded in an indirect way.

# Templates and Matching
Templates are comma-separated sequences of expressions (possibly using variables and constants). If a field of the template is just a variable `v`, the value from the corresponding field in the tuple that is matched is copied into `v` upon retrieval of the tuple. To avoid updating the variable and just using the variable as its value, one has to use `eval(v)` to force a match of a message field with the current value of variable `v`. 

For example, the goSpace code 

```go
space.Query(1,x,?y)
```  

would be done in Promela with

```
space??1,eval(x),y
```  

# Examples
The following examples serve as illustration:
- [Hello World!](HelloWorld.md): a "hello world!" example.
- [Dining philosophers 0](philosophers-0.md): wrong solution (deadlocks) to the [dining philosophers problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem).
- [Dining philosophers 1](philosophers-1.md): correct solution to the [dining philosophers problem](https://en.wikipedia.org/wiki/Dining_philosophers_problem), based on tickets.



