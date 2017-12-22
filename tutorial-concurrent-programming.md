# 2. Concurrent Programming with Tuple Spaces

This chapter provides a gentle introduction to concurrent programming using spaces. The chapter is based on a simple and traditional notion of tuple space, namely a multiset of tuples. The chapter presents the tuple space operations incrementally. The final part discusses how to use tuple spaces to implement basic coordination and synchronisation mechanism. The programming model for tuple spaces in this chapter is strongly based on [Linda](https://dl.acm.org/citation.cfm?id=2433). The chapter is illustrated with a scenario where a couple of roommates (Alice, Bob, Charlie,) use a tuple space ```fridge``` to coordinate their activities.

## 2.1 Concurrent activities

All programing languages with pSpace libraries provide support for concurrent programming based on some sort of concurrent activities.

Go provides lightweight threads called goroutines that can be used to spawn parallel activities. Suppose that `f` is an ordinary Go function. A parallel activity `f(x,y)` can be spawned with 

```go
go f(x,y)
```
Concurrency is a bit more cumbersome in thread-based languages like Java. For instance, one of the approaches to deal with threads in Java is by implementing the activities we plan to spawn in parallel as classes implementing the `Runnable` interface. Following the above example, we would need to write

```java
public class F implements Runnable {
	public F(int x, int y) {...}
   
	public void run() { // do what f(x,y) is supposed to do }
}
```

to implement the runnable thread and then invoke it with

```java
(new Thread(new F(x,y)).start();
```

The creation of a Thread in C# is similar: 

```c#
(new System.Threading.Thread(new System.Threading.ThreadStart(F(x,y)))).Start();
```

with `F` being a delegate.

For more details on corrency primitives refer to
* [Golang tour on concurrency](https://tour.golang.org/concurrency/1)
* [the Java tutorial on starting threads](https://docs.oracle.com/javase/tutorial/essential/concurrency/runthread.html) for more details.
* [C# How to create threads](https://msdn.microsoft.com/en-us/library/btky721f.aspx?cs-save-lang=1&cs-lang=csharp#code-snippet-2)

## 2.2 Blocking operations

The previous chapter did not mention that ```Get``` is actually a blocking operation. This means that an operation ```Get(s,T)``` will block if there is no tuple matching ```T``` in space ```s```. For example, if Alice tries to behave as in

```go
Get(fridge,"milk",&quantity)
```

she will get stuck if the fridge space contains no tuple of the form ```("milk",n)```, waiting until a tuple `("milk",n)` appears in the tuple space. Blocking operations are key to implement synchronisation among activities.

Most operations on tuple spaces have blocking and non-blocking variants. Non-blocking variants have the same name as their blocking counterparts but are typically suffixed with ```P```. For example, operation ```GetP(s,t)``` is pretty much like ```Get(s,t)``` but it does not block if the operation fails to retrieve a value and it actually returns a value to notify if a tuple was actually retrieved or not.

In our example, Alice can avoid getting stuck and decide what to do next in either case (some ```milk``` tuple, no ```milk``` tuple) with

```go
_,err := fridge.GetP("milk",&quantity)
if (err !=nil) {
  // go shopping
} else {
  put ("milk", 1)
}
```

The ```Put``` operation has non-blocking variant ```PutP```, which allows one to progress while tuples are being inserted.

Indeed, the programs

```go
fridge.Put("milk", 2)
fridge.Put("butter", 1)
```

and

```go
fridge.PutP("milk", 2)
fridge.PutP("butter", 1)
```

behave differently. Indeed, the order in which the tuples appear in the tuple space in the second example is not guaranteed and the tuple space may at some point contain

```
(fridge,"butter", 1)
```

Note that the previous program may not be identical in behaviour to

```go
go fridge.Put("milk", 2)
fridge.Put("butter", 1)
```

since in this example the `Put` invokations may be invoked in different moments.

## 2.3 A basic coordination pattern: producer/consumer
The combination of pattern matching and non-deterministic retrieval allows one to specify loose coordination mechanisms. We are indeed ready to introduce our first coordinated system, where the behaviour of Alice and Bob is

Alice:
```go
fridge.Put("milk",2)
fridge.Put("butter",1)
...
```

Bob:
```go
for {
    fridge.Get(&item,&quantity)
    // go shopping
}
```

The adopted coordination pattern is called *consumer/producer*. Alice has the role of a *producer* of tasks (items to be bought). She generates tasks by adding tuples to the tuple space. Bob has the role of a *consumer* of tasks. He consumes tasks by retrieving tuples from the tuple space. Note that the coordination between Alice and Bob is very loose: they do not need to meet and they do not need to produce or consume the shopping orders in any particular order.

This basic basic coordination pattern can be easily extended to the case in which there are multiple producers and consumers.

## 2.4 Concurrent queries: why queries are in the API
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
    Get(fridge,&item,&quantity)
    // go shopping
}
```

A drawback of this solution is that the check that Bob performs is not atomic. There is hence a moment in which the tuple ```("shop!")``` is removed by Bob which may lead other rooommates. Suppose, for instance, that Alice and Bob are executing their programs while Charlie is executing:

Charlie:
```go
if GetP(fridge,"shop!") {
    Put(fridge,"shop!")
    for {
        Get(fridge,&item,&quantity)
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
    Get(fridge,&item,&quantity)
    // go shopping
}
```

Charlie:
```go
if QueryP(fridge,"shop!") {
    for {
        Get(fridge,&item,&quantity)
        // go shopping ...
    }
}
```

A unique advantage of introducing the query operation is that it allows concurrent queries efficiently.

## 2.5 Another coordination pattern: locks 
Standard synchronisation mechanisms can be implemented using tuple spaces. For example, a lock can be easily implemented by representing it with a tuple ```(lock)``` and using a simple protocol to work on the tuple space with exclusive access, namely with:

```go
Get(s,"lock")
// work
Put(s,"lock")
```

## 2.6 Another coordination pattern: barriers
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

## Summary
 
We have seen the following operations on spaces:
- `Query`: blocks until a tuple is found which matches a given template. It then returns the matched tuple.
- `Get`: like `Query` but also removes the found tuple.

We have seen the following coordination patterns:
- Producer/consumer: use a tuples space as a bag of tasks. Producers put tuples representing tasks; consumers get tuples representing tasks.
- Locks: use a tuple to represent the exclusive right to access the tuple space (or a part of it). Only the process with the tuple can access the space.
- Barriers: use tuples to count how many processses have reached some status in their computation.

A complete example for this chapter can be found [here](https://github.com/pSpaces/goSpace-examples/blob/master/tutorial/fridge-1/main.go).

## Reading suggestions
Andrews, G. R. (1999). Foundations of Multithreaded, Parallel, and Distributed Programming. Addison-Wesley, 1 edition
Gelernter, D. (1985). Generative communication in Linda. ACM Trans. Program. Lang. Syst., 7(1):80–112

NOTE: The above documents present the original Linda approach to tuple spaces. Linda consists of the set of primivites put, get, query and their respective non-blocking variants. In the paper and and in the literature you will often find that `put`, `get` and `query` are called `out`, `in` and `rd` or `read`. Asynchronous/non-blocking versions of `put`, `get` and `query` are called `eval`, `inp` and `rdp`.

## What next?

Move to the next chapter on [distributed programing with spaces](tutorial-distributed-programming.md)!
