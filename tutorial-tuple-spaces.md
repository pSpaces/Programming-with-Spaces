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
Tuple spaces are data structures and, as such, we need operations to inspect and manipulate them. We start considering a minimal API consisting of just one operation ```put``` to add tuples and one operation ```get``` to retrieve tuples. More precisely the operation

```put t```

adds the tuple ```t``` to the tuple space, while the operation

```get t```

retrieves the tuple ```t``` from the tuple space.

For example, if the tuple space is used by Alice as a grocery list, she can add the need to buy two bottles of milk with

```
put ("milk",2) ;
```

and she can update the number of milk bottles by first retrieving the old
tuple and adding a new one as in

```
get("milk",2)
put("milk",3)
```

## Pattern matching
The get operation we have presented is not very flexible since retrieving a tuple requires to know in advance all of its elements. This can be very in- convenient in some cases, as in the previous example where Alice wanted to increase the number of milk bottles to be bought. Actually, a more relaxed retrieve operation can be defined by incorporating a simple pattern matching mechanism. In particular, one that allows to specify only the grocery item so to retrieve the current number of items with

```
get ("milk",&x)
```

which would save the number of milk bottles into variable x.

We hence extend the get to take a pattern T as an argument. A pattern is like a tuple, where fields can be binder for variables, in addition to ordinary values. A binder for a variable in a pattern is indicated with ?v, where v is the name of the variable to be bound. For example the pattern used above for retrieving the number of bottles of milk is

```
("milk",&x)
```

For the sake of simplicity we will consider in this section linear patterns only. That is patterns in which each binding variable appears only once. For example, the following pattern is forbidden

```
(&x,&x)
```

In addition, we forbid patterns where a variable appears both as a binding
variable and as a value, as in ```(&x,x)``` or ```(x,&x)```.

With the new version of the get operation Alice can now increase the number of bottles with

```
get ("milk",&x) ;
put ("milk",x+1) ;
```
 
## Non-deterministic retrieval
What should happen when we try to retrieve a tuple with a pattern T and there is actually more than one tuple matching the pattern? The answer is that any tuple may be retrieved.

// Change example to make it sequential - AL
As an example, consider the following situation. Assume that Alice and here roommates decide to organise the grocery shopping activities of their house as follows: Alice will take care of identifying the stuff that needs to be bought and Bob will be in charge of the actual shopping. Since they have few chances to talk to each other, they decide to use their personal tuple space, i.e. their fridge, and tuples of the form (item, quantity). Consider now the following behaviour for Alice and Bob

## Non-deterministic retrieval
 Alice
put ("milk", 2) ;
put ("butter", 1) ;
Bob
get (?item, ?quantity) ; // go buy item
    where Alice inserts the tuples (milk, 2) and (butter, 1) to the tuple space and, concurrently, Bob retrieves any tuple matching the pattern (?item, ?quantity) and then goes shopping.
In this example, Bob can retrieve any of the two tuples (milk,2) and (butter, 3). It is actually up to the implementation of the tuple space to decide which one he will actually retrieve.
