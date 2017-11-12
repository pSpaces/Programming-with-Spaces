# 1. Programming with Tuple Spaces

This chapter is a gentle introduction to programming with spaces. The chapter will focus on a particular kind of space, namely a tuple space, and will focus on sequential programming using a tuple space as an ordinary collection data structure (such as lists, sets, stacks and so on). The chapter is illustrated with a scenario where a couple of roommates (Alice, Bob, Charlie,) use a tuple space `fridge` to coordinate their activities.

## 1.1 Tuples are finite lists
A tuple is a finite list of elements that can be used to represent a data item or a message. Tuples can represent coordinates in a map

```(50°18'0"N, 120°30'0"W)```

or dates

```(1984, "September", 13)```

or user credentials

```("Alice", 1234)```

or groceries missing in the fridge

```("milk",1)```

and so on.

## 1.2 Tuples in pSpace
Tuples are supported in many programming languages. Some of pSpace implementations provide ad-hoc datatypes for tuples.

For example in Go, a tuple `("milk",1)` can be declared and initialised as follows

```go
var tuple Tuple = CreateTuple("milk", 1)
````

We shall see that tuple constructors such as `CreateTuple` are not always necessary as tuples can be implicitly created from lists of values. 

Tuple fields are accessed position-wise, very much like acccessing arrays. In Go, the `i`-th field is accessed with

```
(tuple.GetFieldAt(i))
```

## 1.3 Tuple spaces are collections of tuples
A tuple space is a collection of tuples. In general, the term collection has to be understood in the more general sense (no specific order, bound or type for the tuples). However, the traditional interpretation is to consider the simple case of unordered heterogeneous collections of tuples, i.e. multisets of tuples of different types.

Here is an example of a tuple space representing post-its on a fridge

```
("coffee",1)
("clean kitchen")
("butter",2)
("clean kitchen")
("milk",3)
```

Recall that a multiset differs from a list in that the order of elements does not matter, and it differs from a set in that an element can appear more than once.

## 1.4 Tuple spaces in pSpaces
pSpace implementations provide several datatypes for tuple spaces. We shall discuss them in detail in a later chapter of the tutorial. We focus here on sequential spaces. These are created in Go with the constructor `NewSpace`:

```
fridge := NewSpace("fridge")
```

The `fridge` space is now ready contain tuple spaces of arbitrary types.

Tuple spaces are collection data structures and, as such, they provide operations to inspect and manipulate them. All implementations of spaces support operations to put (i.e. add) tuples, get (i.e. remove), and query (i.e. search) tuples in a space. The [core API](https://github.com/pSpaces/Programming-with-Spaces/blob/master/guide.md#core-space-api) describes such operations. This tutorial introduces them one by one. 

## 1.5 Adding tuples with `Put`

The operation to add tuples is named ```Put```. More precisely the operation 

```go
space.Put(tuple)
```

adds the tuple ```tuple``` to the tuple space ```space```.

## 1.6 Searching tuples with `QueryP`

The operation to search for tuples tuples is called ```QueryP```. In detail,

```go
space.QueryP(tuple)
```

looks for a tuple like ```tuple``` in the tuple space ```space``` and returns the found tuple (if any).

In Go, for example, we can write

```go
_, err := fridge.QueryP("clean kitchen")
```

to check whether there is a tuple saying that we need to clean the kitchen. In the example, the returned tuple (first argument) is ignored and we just store whether the tuple was found (`err == nil`).

## 1.7 Removing tuples with `GetP`

The operation to remove tuples tuples is named ```Get``` and has a similar behavour as `Query`, namely

```go
space.GetP(tuple)
```

looks for a tuple like ```tuple``` in the tuple space ```space```. If found, the tuple is returned and removed from the space. 

We can use for example

```go
_, err := fridge.GetP("clean kitchen")
```
If we are willing to remove the note that says that we need to clean the kitchen.

## 1.8 Tuples are content-addressable with pattern matching

The tuple retrieval operations we have presented are actually more powerful: we do not need to know the actual tuple we are looking for. Indeed, tuples are content-addressable based on the a pattern matching mechanism.

In our example, pattern matching can be used to specify only the grocery item so to retrieve the current number of items for that item with

```go
var numberOfBottles int
fridge.GetP("milk", &numberOfBottles)
```

which would save the number of milk bottles into variable ```numberOfBottles```.

So actually both `QueryP` and `GetP` take a pattern ```T``` as an argument. A pattern is like a tuple, where fields can be binders for variables, in addition to ordinary values. A binder for a variable in a pattern is indicated with ```&v```, where ```v``` is the name of the variable to be bound. For example the pattern used above for retrieving the number of bottles of milk is

```
("milk", &numberOfBottles)
```

## 1.9 Patterns must be linear
We consider linear patterns only. A linear pattern is a pattern in which each binding variable appears only once. For example, the following pattern is forbidden

```
(&x,&x)
```

In addition, we forbid patterns where a variable appears both as a binding
variable and as a value, as in ```(&x,x)``` or ```(x,&x)```.

## 1.10 Updating tuples 

Note that contrary to some collection datatypes in mainstream languages, the operato adds a fresh copy of the tuple. Once the tuple is in the space, its contents cannot be modified. This means that if the tuple contains values of complex data types with references or pointers, those are deeply copied. The only way to modify a tuple of a space is to remove it from the space and re-insert it

For example, if Alice can increase the number of bottles to be bought with

```go
fridge.Get("milk",&numberOfBottles)
fridge.Put("milk",numberOfBottles+1)
```
 
## 1.11 Tuple retrieval is non-deterministic 

What should happen when we try to retrieve a tuple with a pattern `T` and there is actually more than one tuple matching the pattern? The specification of generic spaces is that any tuple may be retrieved. It is up to the concrete space data type to specify the concrete (deterministic or even randomised) behaviour.

As an example, consider the following situation. Assume that the current state of the fridge space is

```
("milk",2)
("butter",3)
```

and that Alice wants to look for an item to buy with

```
fridge.QueryP(&item,&quantity);
```

Alice can retrieve any of the two tuples `("milk",2)` and `("butter",3)`. It is actually up to the implementation of the tuple space to decide which one she will actually retrieve. Most pSpaces implementations provide tuple spaces with different deterministic behaviours (FIFO-like, LIFO-like, etc.). There is also support for randomised behaviours. We will come back to in the next chapters of the tutorial.

## 1.12 Retrieving all matching tuples

Tuple spaces also support operations to find or remove all tuples matching some template. In particular, `QueryAll` returns all tuples matching a template and `GetAll` behaves similarly but removes the matched tuples. 

The following example in Go shows how the grocery list can be retrieved from the `fridge` tuple space and printed afterwards:

```
var item string
var quantity int
groceryList, _ := fridge.QueryAll(&item, &quantity)
fmt.Println("Items to buy: ")
fmt.Println(groceryList)
```

## Summary

We have seen the following data types
- Tuples: finite lists of values.
- Spaces: collections of tuples.
 
We have seen the following operations on spaces:
- `Put`: adds a tuple to a space.
- `QueryP`: searches for a tuple atching a template. It then returns the matched tuple (if any).
- `GetP`: like `QueryP` but also removes the found tuple (if any).
- `QueryAll`: returns all tuples matching a template. 
- `GetAll`: returns all tuples matching a template and removes them from the space.

A complete example for this chapter can be found [here](https://github.com/pSpaces/goSpace-examples/blob/master/tutorial/fridge-0/main.go).

## What next?

Move to the next chapter on [concurrent programing with spaces](tutorial-concurrent-programming.md)!
