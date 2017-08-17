# Concurrent Programming with Tuple Spaces

This chapter provides a gentle introduction to concurrent programing using spaces. The chapter is based on a simple and traditional notion of tuple space, namely a multiset of tuples. The chapters starts introducing a basic set of operations, which is incrementally enriched with additional operations. The final part discusses how to use tuple spaces to implement basic coordination and synchronisation mechanisms, and how to implement traditional communication means such as message passing and shared memory. The flavour of tuple spaces in this chapter is essentially based on Linda [Gelernter, 1985]. The chapter is illustrated with a scenario where a couple of roommates (Alice, Bob, Charlie,) use a tuple space ```fridge``` to coordinate their activities. 
 
## Blocking vs non-blocking operations

The previous chapter did not mention that ```Get``` is actually a blocking operation. This means that an operation ```Get(s,T)``` will block if there is no tuple matching ```T``` in space ```s```. For example, if Alice tries to behave as in

```go
Get(fridge,"milk",&quantity)
```

she will get stuck if the fridge space contains no tuple of the form ```("milk",n)```, waiting until a tuple ("milk",2) appears in the tuple space. Blocking operations are key to implement synchronisation as we shall see. 

Most operations on tuple spaces have blocking and non-blocking variants. Non-blocking variants have the same name as their blocking counterparts but are typically suffixed with ```P```. For example, operation ```GetP(s,t)``` is pretty much like ```GetP(s,t)``` but it does not block if the operation fails to retrieve a value and it actually returns a boolean value to notify if a tuple was actually retrieved or not.

In our example, Alice can avoid getting stuck and decide what to do next in either case (some ```milk``` tuple, no ```milk``` tuple) with

```go
some_milk := GetP(fridge,"milk",&quantity)
if (some_milk) // go shopping
else put ("milk", 1) ;
```

Also the ```Put``` operation has non-blocking variant ```PutP```, which allows one to progress while tuples are being inserted.

Indeed, the programs

```go
Put(fridge,"milk", 2)
Put(fridge,"butter", 1) 
```

and

```go
PutP(fridge,"milk", 2)
PutP(fridge,"butter", 1) 
```

behave differently. Indeed, the order in which the tuples appear in the tuple space in the second example is not guaranteed and the tuple space may be

```
(fridge,"butter", 1)
```

Note that the previous program may not be identical in behavour to

```go
go Put(fridge,"milk", 2)
Put(fridge,"butter", 1) 
``` 

# Producer/consumer pattern
The combination of pattern matching and non-deterministic retrieval allows one to specify loose coordination mechanisms. We are indeed ready to introduce our first coordinated system, where the behaviour of Alice and Bob is

Alice:
```go
Put(fridge,"milk",2) 
Put(fridge,"butter",1)
...
```

Bob:
```go
for {
    GetP(fridge,?item,?quantity)
    // go shopping 
}
```

The adopted coordination pattern is called *consumer/producer*. Alice has the role of a *producer* of tasks (items to be bought). She generates tasks by adding tuples to the tuple space. Bob has the role of a *consumer* of tasks. He consumes tasks by retrieving tuples from the tuple space. Note that the coordination between Alice and Bob is very loose: they do not need to meet and they do not need to produce or consume the shopping orders in any particular order.

This basic basic coordination pattern can be easily extended to the case in which there are multiple producers and consumers.

# Efficient queries
There are many situations in which one would like inspect the tuple space without actually removing any tuple. A typical example is when the presence of a tuple signals an event and we want to wait until that event happnes. For example, in our case study, Alice and Bob may decide that Bob does not need to go shopping immediately but can wait until Alice decides that the grocery list has enough items, signalled by a tuple ```("shop!")``` as in

Alice:
```go
Put(fridge,"milk",2)
Put(fridge,butter",1)
Put(fridge,"shop!")
```

Bob:
```go
Get(fridge,"shop!")
Put(fridge,"shop!")
for {
    Get(fridge,?item,?quantity)
    // go shopping
}
```

A drawback of this solution is that the check that Bob performs is not atomic. There is hence a moment in which the tuple ```("shop!")``` is removed by Bob which may lead other rooommates. Suppose, for instance, that Alice and Bob are executing their programs while Charlie is executing:

Charlie:
```go
if GetP(fridge,"shop!") {
    Put(fridge,"shop!")
    for {
        Get(fridge,?item,?quantity)
        // go shopping ...
    }
}
else // relax
```

The standard solution to this problem is use the ```query``` operation to perform queries atomically. Operation ```Query(s,T)``` behaves like ```Get(s,T)``` but does not remove the retrived tuple from the space. Now Bob and Charlie can safely check if it is time to shop as follows.

Bob:
```go
Query(fridge,"shop!")
for {
    Get(fridge,?item,?quantity)
    // go shopping
}
```

Charlie:
```go
if QueryP(fridge,"shop!") {
    for {
        Get(fridge,?item,?quantity)
        // go shopping ...
    }
}
```

A unique advantage of introducing the query operation is that it allows concurrent queries efficiently.

# Synchronisation mechanisms
Standard synchronisation mechanisms can be implemented using tuple spaces. For example, a lock can be easily implemented by representing it with a tuple ```(lock)``` and using a simple protocol to work on the tuple space with exclusive access, namely with:

```go
Get(s,"lock")
// work
Put(s,"lock")
```

Another example is a one-time barrier for N processes, which can be implemented using a tuple counting the number of processes that still need to reach the barrier. The barrier can be intialised with

```go
Put(s,"barrier",N) ;
```

and when process reaches the barrier it executes

```go
Get(s,"barrier",&n)
Put(s,"barrier",n−1)
Query(s,"barrier",0)
// move on
```
   
# Reading suggestions
Andrews, G. R. (1999). Foundations of Multithreaded, Parallel, and Dis- tributed Programming. Addison-Wesley, 1 edition
Gelernter, D. (1985). Generative communication in Linda. ACM Trans. Pro- gram. Lang. Syst., 7(1):80–112

NOTE: The above documents present the original Linda approach to tuple spaces. Linda consists of the set of primivites put, get, query and their re- spective non-blocking variants. In the paper and and in the literature you will often find that put, get and query are called out, in and rd (or read). Asynchronous/non-blocking versions of put, get and query are called eval, inp and rdp.
