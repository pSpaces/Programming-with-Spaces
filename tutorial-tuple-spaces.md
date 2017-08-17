# Programming with Tuple Spaces

## What is a tuple space?
A tuple is a finite list of elements that can be used to represent a data item or a message. Tuples can represent, for example,  coordinates in a map

```(50°18'0"N, 120°30'0"W)```

dates

```(1984, "September", 13)```

user credentials

```("Alice", 1234)```

groceries missing in the fridge

```("milk")```

and so on.

A tuple space is a collection of tuples. In general, the term collection has to be understood in the more general sense. However, the traditional interpretation is to consider the simple case of unordered collections of tuples, i.e. multisets of tuples. This is precisely what we shall consider in this chapter. Here is an example of a tuple space representing a grocery list

```
("coffee")
("butter")
("milk")
("bread")
```

Recall that a multiset differs from a list in that the order of elements does not matter, and it differs from a set in that an element can appear more than once.
 
## Adding and retrieving tuples
Tuple spaces are data structures and, as such, we need operations to inspect and manipulate them. We start considering a minimal API consisting of just one operation ```Put``` to add tuples and one operation ```Get``` to retrieve tuples. More precisely the operation 

```go
Put(s,t)
```

adds the tuple ```t``` to the tuple space ```s```, while the operation

```go
Get(s,t)
```

retrieves the tuple ```t``` from the tuple space ```s```.

Assume that Alice has a tuple space ```fridge``` to be used as as a grocery list. She can add the two bottles of milk to the grocery list with

```go
Put(fridge,"milk",2)
```

and she can update the number of milk bottles by first retrieving the old tuple and adding a new one as in

```go
Get(fridge,"milk",2)
Put(fridge,"milk",3)
```

## Pattern matching
The get operation we have presented is not very flexible since retrieving a tuple requires to know in advance all of its elements. This can be very inconvenient in some cases, as in the previous example where Alice wanted to increase the number of milk bottles to be bought. Actually, tuple spaces support more powerful retrieve operations based on pattern matching mechanisms. In our example, pattern matching can be used to specify only the grocery item so to retrieve the current number of items for that item with

```go
Get(fridge,"milk",&x)
```

which would save the number of milk bottles into variable ```x```.

We hence extend the ```Get``` operation to take a pattern ```T``` as an argument. A pattern is like a tuple, where fields can be binders for variables, in addition to ordinary values. A binder for a variable in a pattern is indicated with ```&v```, where ```v``` is the name of the variable to be bound. For example the pattern used above for retrieving the number of bottles of milk is

```
("milk",&x)
```

For the sake of simplicity we will consider in this section linear patterns only. A linear pattern is a pattern in which each binding variable appears only once. For example, the following pattern is forbidden

```
(&x,&x)
```

In addition, we forbid patterns where a variable appears both as a binding
variable and as a value, as in ```(&x,x)``` or ```(x,&x)```.

With the new version of the get operation Alice can now increase the number of bottles with

```go
Get(fridge,"milk",&x)
Put(fridge,"milk",x+1)
```
 
## Non-deterministic retrieval
What should happen when we try to retrieve a tuple with a pattern ```T``` and there is actually more than one tuple matching the pattern The answer is that any tuple may be retrieved.

As an example, consider the following situation. Assume that the current state of the fridge space is

```
("milk",2)
("butter",3)
```

and that Alice wants to execute command

```
Get(fridge,?item,?quantity);
```

Alice can retrieve any of the two tuples ```("milk",2)``` and ```("butter",3)```. It is actually up to the implementation of the tuple space to decide which one she will actually retrieve.
