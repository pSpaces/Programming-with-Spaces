# 1. Programming with Spaces

This chapter is a gentle introduction to programming with spaces. The chapter will focus on a particular kind of space, namely a tuple space, and will focus on sequential programming using a tuple space as an ordinary collection data structure (such as lists, sets, stacks and so on). The chapter is illustrated with a scenario where a couple of roommates (Alice, Bob, Charlie,) use a tuple space `fridge` to coordinate their activities.

The tutorial is mainly based on the `Java` and `Go` libraries, but we also use examples in other languages. The [naming table](https://github.com/pSpaces/Programming-with-Spaces/blob/master/naming.md) summarises the main features of the libraries and can be used as a quick reference to adapt the examples we present here.

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
Many programming languages provide types or mechanisms for tuples or value lists. The pSpace implementations provide ad-hoc datatypes for tuples but sometimes admit the use native features from the language.

For example, the Java Library provides a class `Tuple`, which can be used to create a tuple `("milk",1)` as follows

```java
Tuple tuple = new Tuple("milk", 1);
```

Similarly, the Go library provides an interface `Tuple` that can be used to create the same tuple as above as follows:

```go
var tuple Tuple = CreateTuple("milk", 1)
````

Similar datatypes and interfaces can be found in the rest of the libraries (e.g. the `ITuple` interface in C#).

As an alternative to ad-hoc tuple datatypes and interfaces some of the libraries allow to use built-in tuple-like datatypes and features such as parameter lists. This means that tuple constructors such as `Tuple` and `CreateTuple` are not always necessary as tuples can be implicitly created from lists of values. For example, in Java, one can use object arrays and in Go one can use slices, as we shall see later.

Tuple fields are accessed position-wise, very much like acccessing arrays. In Java the `i-1`-th field is accessed with

```
tuple.GetFieldAt(i)
```

In Go, the `i-1`-th field is accessed with

```go
tuple.GetFieldAt(i)
```

Casting may be needed in some cases. For example, in Java, the fields of a `Tuple`-object are objects and need to be casted into their actual types if needed:

```java
Tuple tuple = new Tuple("milk", 1);
String item = (tuple.getElementAt(0)).toString();
Integer quantity = (Integer) tuple.getElementAt(1);
```

likewise, in Go:

```go
var tuple Tuple = CreateTuple("milk", 1)
item := (tuple.GetFieldAt(0)).(string)
quantity := (tuple.GetFieldAt(1)).(int)
```

And similarly in the rest of the languages. See the [naming table](https://github.com/pSpaces/Programming-with-Spaces/blob/master/naming.md) for a quick reference.

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
pSpace implementations provide several datatypes for tuple spaces. We shall discuss them in detail in a later chapter of the tutorial. We focus here on sequential spaces. These are created in Java with the constructor `SequentialSpace()':

```java
Space inbox = new SequentialSpace();
```

and in Go with the constructor `NewSpace`:

```go
fridge := NewSpace("fridge")
```

The `fridge` space is now ready contain tuple spaces of arbitrary types.

Tuple spaces are collection data structures and, as such, they provide operations to inspect and manipulate them. All implementations of spaces support operations to put (i.e. add) tuples, get (i.e. remove), and query (i.e. search) tuples in a space. The [core API](https://github.com/pSpaces/Programming-with-Spaces/blob/master/guide.md#core-space-api) describes such operations. This tutorial introduces them one by one.

## 1.5 Adding tuples with `put`

The operation to add tuples is named ```put```. More precisely the operation

```java
space.put(tuple)
```

adds the tuple ```tuple``` to the tuple space ```space```.

## 1.6 Searching tuples with `queryp`

The operation to search for tuples tuples is called ```queryp```. In detail,

```go
space.queryp(tuple)
```

looks for a tuple like ```tuple``` in the tuple space ```space``` and returns the found tuple (if any).

In Java, for example, we can write

```java
Object[] tuple = fridge.queryp(new ActualField("clean kitchen"));
if (tuple != null) {
    System.out.println("We need to clean the kitchen");
}
```

to check whether there is a tuple saying that we need to clean the kitchen. In the example, the returned tuple (if any) is stored in `obj`. The absence of a tuple is represented with a null value.

## 1.7 Removing tuples with `getp`

The operation to remove tuples is named ```getp``` and has a similar behavour as `queryp`, namely

```java
space.getp(tuple)
```

looks for a tuple like ```tuple``` in the tuple space ```space```. If found, the tuple is returned and removed from the space.

We can use for example

```java
tuple = fridge.getp("clean kitchen")
```

if we are willing to remove the note that says that we need to clean the kitchen.

## 1.8 Tuples are content-addressable with pattern matching

The tuple retrieval operations we have presented are actually more powerful: we do not need to know the actual tuple we are looking for. Indeed, tuples are content-addressable based on the a pattern matching mechanism.

In our example, pattern matching can be used to specify only the grocery item so to retrieve the current number of items for that item with

```java
Object[] tuple = fridge.queryp(new ActualField("milk"), new FormalField(Integer.class));
if (tuple != null) {
    int numberOfBottles = (int)tuple[1];
}
```

which would save the number of milk bottles into variable ```numberOfBottles```.

So actually both `queryp` and `getp` take a pattern ```T``` as an argument. A pattern is like a tuple, where fields can be *actual fields* (i.e. values) or *formal fields* (i.e. placeholders). Formal fields are specified in most pSpace implementations by type names. In goSpaces, however, formal fields are specified with pointer values (e.g. ```&v```, where ```v``` is the name of a variable ). For example the pattern used above for retrieving the number of bottles of milk would be

```go
("milk", &numberOfBottles)
```

Some of the libraries provide ad-hoc datatypes for templates. For instance, jSpace provides the class `Template` and methods for actual fields (i.e. values) and formal fields (i.e. datatypes).

The template of the above example would be constructed in Java with

```java
Template template = new Template(new ActualField("milk"),new FormalField(Integer.class())
```

and retrieving the number of bottles would then be done as follows:

```java
Tuple tuple = fridge.getp(template)
```

or more compactly

```java
Tuple tuple = fridge.getp(new ActualField("milk"),new FormalField(Integer.class())
```

as we did in the first example of this section.

## 1.9 Updating tuples

Note that contrary to some collection datatypes in mainstream languages, the operation `put` adds a fresh copy of the tuple. Once the tuple is in the space, its contents cannot be modified. This means that if the tuple contains values of complex data types with references or pointers, those are deeply copied. The only way to modify a tuple of a space is to remove it from the space and re-insert it

For example, if Alice can increase the number of bottles to be bought with

```java
Tuple tuple = fridge.getp(new ActualField("milk"),new FormalField(Integer.class())
if (tuple =! nil) {
    fridge.put("milk",tuple.getElementAt(1)+1)
}
```

## 1.10 Tuple retrieval is non-deterministic

What should happen when we try to retrieve a tuple with a pattern `T` and there is actually more than one tuple matching the pattern? The specification of the interface for spaces is that any tuple may be retrieved. It is up to the concrete space datatype or class implementing the space interface to specify the concrete (deterministic or even randomised) behaviour.

As an example, consider the following situation. Assume that the current state of the fridge space is

```
("milk",2)
("butter",3)
```

and that Alice wants to look for an item to buy with

```
Object[] tuple = fridge.queryp(new ActualField("milk"), new FormalField(Integer.class));
```

Which of the two tuples `("milk",2)` and `("butter",3)` Alice will retrieve actually depends on the implementation of the tuple space. Most pSpaces implementations provide tuple spaces with different deterministic behaviours (FIFO-like, LIFO-like, etc.). There is also support for randomised behaviours. In our example the `fridge` tuple space is of type `Sequential`, which behaves similarly to a FIFO queue so that the oldest matching tuple will be retrieved.

A list of the tuple space classes supported in each language can be found in the [naming table](https://github.com/pSpaces/Programming-with-Spaces/blob/master/naming.md) and a description of those classes can be found in the [guide for developers](https://github.com/pSpaces/Programming-with-Spaces/blob/master/guide.md). We will come back to in the [next chapter](https://github.com/pSpaces/Programming-with-Spaces/blob/master/tutorial-concurrent-programming.md#26-space-classes-and-retrieval-order) of the tutorial.

## 1.11 Retrieving all matching tuples

Tuple spaces also support operations to find or remove all tuples matching some template. In particular, `queryAll` returns all tuples matching a template and `getAll` behaves similarly but removes the matched tuples.

The following example shows how the grocery list can be retrieved from the `fridge` tuple space and printed afterwards:

```
List<Object[]> groceryList = fridge.queryAll(new FormalField(String.class), new FormalField(Integer.class));
System.out.println("Items to buy: ");
for (Object[] grocery : groceryList) {
    System.out.println(grocery[1] + " units of "+ grocery[0]);
}
```

## Summary

We have seen the following data types
- Tuples: finite lists of values.
- Spaces: collections of tuples.

We have seen the following operations on spaces:
- `put`: adds a tuple to a space.
- `queryp`: searches for a tuple atching a template. It then returns the matched tuple (if any).
- `getp`: like `queryp` but also removes the found tuple (if any).
- `queryAll`: returns all tuples matching a template.
- `getAll`: returns all tuples matching a template and removes them from the space.

Complete examples for this chapter can be found here:
* [example in Java](https://github.com/pSpaces/jSpace-examples/blob/master/tutorial/fridge-0/Fridge_0.java)
* [example in Go](https://github.com/pSpaces/goSpace-examples/blob/master/tutorial/fridge-0/main.go)

## What next?

Move to the next chapter on [concurrent programing with spaces](tutorial-concurrent-programming.md)!
