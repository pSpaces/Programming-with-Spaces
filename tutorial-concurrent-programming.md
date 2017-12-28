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
fridge.Get("milk",&quantity)
```

she will get stuck if the fridge space contains no tuple of the form ```("milk",n)```, waiting until a tuple `("milk",n)` appears in the tuple space. Blocking operations are key to implement synchronisation among activities.

Most operations on tuple spaces have blocking and non-blocking variants. Non-blocking variants have the same name as their blocking counterparts but are typically suffixed with ```P```. For example, operation ```GetP(s,t)``` is pretty much like ```Get(s,t)``` but it does not block if the operation fails to retrieve a value and it actually returns a value to notify if a tuple was actually retrieved or not.

In our example, Alice can avoid getting stuck and decide what to do next in either case (some ```milk``` tuple, no ```milk``` tuple) with

```go
_,err := fridge.GetP("milk",&quantity)
if (err !=nil) {
  // go shopping
} else {
  fridge.Put ("milk", 1)
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

This basic coordination pattern can be easily extended to the case in which there are multiple producers and consumers.

## 2.4 Concurrent queries: why queries are in the API
There are many situations in which one would like to inspect the tuple space without actually removing any tuple. A typical example is when the presence of a tuple signals an event and we want to wait until that event happnes. For example, in our case study, Alice and Bob may decide that Bob does not need to go shopping immediately but can wait until Alice decides that the grocery list has enough items, signalled by a tuple ```("shop!")``` as in

Alice:
```go
fridge.Put("milk",2)
fridge.Put("butter",1)
fridge.Put("shop!")
```

Bob:
```go
fridge.Get("shop!")
fridge.Put("shop!")
for {
    fridge.Get(&item,&quantity)
    // go shopping
}
```

A drawback of this solution is that the check that Bob performs is not atomic. There is hence a moment in which the tuple ```("shop!")``` is removed by Bob which may lead other rooommates. Suppose, for instance, that Alice and Bob are executing their programs while Charlie is executing:

Charlie:
```go
_,err := fridge.GetP(fridge,"shop!") 
if err != nil {
    fridge.Put("shop!")
    for {
        fridge.Get(&item,&quantity)
        // go shopping ...
    }
} else // relax
```

The standard solution to this problem is use the ```Query``` operation to perform queries atomically. Operation ```Query(s,T)``` behaves like ```Get(s,T)``` but does not remove the retrived tuple from the space. Now Bob and Charlie can safely check if it is time to shop as follows.

Bob:
```go
fridge.Query("shop!")
for {
    fridge.Get(&item,&quantity)
    // go shopping
}
```

Charlie:
```go
_,err := fridge.GetP(fridge,"shop!") 
if err != nil {
    for {
        fridge.Get(&item,&quantity)
        // go shopping ...
    }
}
```

A unique advantage of introducing the `Query` operation it eases performant implementations of concurrent queries.

## 2.5 Another coordination pattern: global locks 
Standard synchronisation mechanisms can be implemented using tuple spaces. Global locks can be used to grant exclusive access to the tuple space and to provide atomicity of complex operations on the tuple space. A lock on a tuple space `s` can be easily implemented by representing it with a tuple ```("lock")``` that is initally placed in the tuple space `s` with

```go
s.Put("lock")
```

The pattern to have exclusive access to the tuple space is then

```go
s.Get("lock")
// work
s.Put("lock")
```
Suppose, for instance, that Alice needs to increase the number of milk buttles and butter bars atomically. She can proceed as follows:

```go
s.Get("lock")
s.Get("milk",&x)
s.Get("butter",&y)
s.Put("milk",x+1)
s.Put("butter",y+1)
s.Put("lock")
```

## 2.6 Another coordination pattern: multiple-readers/single-writer locks 

Simple locks limit concurrency and may impact the performance of the tuple space. *Multiple-readers/single-writer* locks mitigate this by allowing for multiple readers to work concurrently on the tuple space, while requiring exclusive access on writers. With this coordination pattern we ensure that either none, at most one writer (and no readers), or multiple readers (but no writer) are accessing the tuple space. This coordination pattern can be implemented using a standard solution based on a counter for the number of readers (represented as a tuple `("readers",n)` and two locks: `lock` (a global lock) and `reader_lock` (to lock the counter).

Processes that need to modify the tuple space (i.e. writers) have to adhere to the following protocol:

```
s.Get("lock")
// update the tuple space with get/put operations
s.Put("lock")
```

Processes that just need to search for tuples without modifying the tuple space (i.e. readers) can proceed as follows:
```
s.Get("reader_lock")
s.Get("readers",&num_readers)
num_readers++
s.Put("readers",num_readers)
if num_readers == 1 { 
  s.Get("lock")
}
s.Put("reader_lock")
// search for tuples with query operations
s.Get("reader_lock")
s.Get("readers",&num_readers)
num_readers--
s.Put("readers",num_readers)
if num_readers == 0 { 
  s.Put("lock")
}
s.Put("reader_lock")
```


## 2.7 Another coordination pattern: barriers
Another example is a one-time barrier for N processes, which can be implemented using a tuple counting the number of processes that still need to reach the barrier. The barrier can be intialised with

```go
s.Put("barrier",N) ;
```

and when a process reaches the barrier it has to execute the following code

```go
s.Get("barrier",&n)
s.Put("barrier",n−1)
s.Query("barrier",0)
// move on
```

## Summary
 
We have seen the following operations on spaces:
- `Query`: blocks until a tuple is found which matches a given template. It then returns the matched tuple.
- `Get`: like `Query` but also removes the found tuple.

We have seen the following coordination patterns:
- Producer/consumer: use a tuples space as a bag of tasks. Producers put tuples representing tasks; consumers get tuples representing tasks.
- Global locks: use a tuple to represent the exclusive right to access the tuple space (or a part of it). Only the process with the tuple can access the space.
- Multiple-readers/single-writer locks: use a counter and two locks to allow for multiple process to search for tuples concurrently, or one process to update the tuple space.
- Barriers: use tuples to count how many processses have reached some status in their computation.

A complete example for this chapter can be found [here](https://github.com/pSpaces/goSpace-examples/blob/master/tutorial/fridge-1/main.go).

## Reading suggestions
* Andrews, G. R. (1999). Foundations of Multithreaded, Parallel, and Distributed Programming. Addison-Wesley, 1 edition
* Gelernter, D. (1985). [Generative communication in Linda]([Linda](https://dl.acm.org/citation.cfm?id=2433)). ACM Trans. Program. Lang. Syst., 7(1):80–112

NOTE: The above documents present the original Linda approach to tuple spaces. Linda consists of the set of primivites put, get, query and their respective non-blocking variants. In the paper and and in the literature you will often find that `put`, `get` and `query` are called `out`, `in` and `rd` or `read`. Asynchronous/non-blocking versions of `put`, `get` and `query` are called `eval`, `inp` and `rdp`.

## What next?

Move to the next chapter on [distributed programing with spaces](tutorial-distributed-programming.md)!
