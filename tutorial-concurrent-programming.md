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
There are many situations in which one would like inspect the tuple space without actually removing any tuple. A typical example is when the presence of a tuple signals an event and we want to wait until that event happnes. For example, in our case study, Alice and Bob may decide that Bob does not need to go shopping immediately but can wait until Alice decides that the grocery list has enough items, signalled by a tuple ("shop!") as in

Alice:
```go
put (milk, 2) ; ...
put (butter, 1) ; ...
put ("shop!") ; ...
```

Bob:
```go
get ("shop!") ; put ("shop!") ; while true do
get (?item, ?quantity) ; // go shopping
```

A drawback of this solution is that the check that Bob performs is not atomic. There is hence a moment in which the tuple ("shop!") removed by Bob which may lead other rooommates to thing that there is no shopping to be done, as in

Alice:
```go
put (milk, 2) ; ...
put (butter, 1) ; ...
put ("shop!") ; ...
```

Bob
```go
get ("shop!") ;
put ("shop!") ; while true do
get (?item, ?q) ; // go shopping ...
```

Charlie:
```go
if getp ("shop!") then
put ("shop!") ; while true do
get (?item, ?q) ; // go shopping ...
else
// relax
```

The standard solution to this problem is add an operation to perform queries atomically. We call such operation query. A query queryT) takes a pattern T = (?x1, ?x2, .., ?xn) as parameter and has a behaviour similar to the atomic execution of the sequence of commands
get (?x1, ?x2, .., ?xn) ; put (x1, x2, .., xn) ;
Now, Alice, Bob and Charlie can cooperate as follows

Alice:
```go
put (milk, 2) ; ...
put (butter, 1) ; ...
put ("shop!") ; ...

Bob:
```go
query ("shop!") ; while true do
get (?item, ?q) ; // go shopping ...
```

Charlie:
```go
if queryp ("shop!") then while true do
get (?item, ?q) ; // go shopping ...
else
// relax
```

A unique advantage of introducing a query operation is to allow concurrent queries efficiently.

# Efficient updates
A tuple in a tuple space can be easily update by first retrieving it and then inserting an updated version of it. Recall, for example how Alice can update the grocery list by increasing the number of milk bottles

```go
get ("milk", ?x) ; put ("milk", x + 1) ;
```

An annoying thing in this solution is that while Alice is updating the grocery list, there is an moment in which there may be no tuple matching the pattern ("milk", ?x) in the tuple space, so Bob could actually think that no milk needs to be bought. More generally, queries and retrievals may unnecessarily block or fail.
A possible solution to this issue is to introduce an update operation. The operation replace(T,t) waits until there is a tuple matching the template T and then replaces it by a tuple t. It amounts to performing the following sequence atomically

```go
get T; put t;
```

Typically t can contain variables that are bound in T. For example, Alice can now update the grocery list with the command

```
replace ("milk", ?x) with ("milk", x + 1) ;
```

# Synchronisation mechanisms
Standard synchronisation mechanisms can be implemented using tuple spaces. For example, a lock can be easily implemented by representing it with a tuple (lock) and using a simple protocol to work on the tuple space with exclusive access, namely with:

```go
get ("lock") ; // work
put ("lock") ;
```

Another example is a one-time barrier for N processes, which can be im- plemented using a tuple counting the number of processes that still need to reach the barrier. The barrier can be intialised with
put ("barrier", N) ;
and when process reaches the barrier it executes
get ("barrier", ?n) ; put ("barrier", n − 1) ; query ("barrier", 0) ; // move on
which updates the barrier counter and blocks the process until all processes are ready.
 
Alice
```go
x := y + 1 ;
```
is realised with

```go
query ("y", ?A_y) ; get ("x", ?A_x) ; put ("x", A_y + 1) ;
Bob y:=x+1;
Bob
query ("x", ?B_x) ; get ("y", ?B_y) ; put("y",B_x+1);
```

# Tuple spaces and shared memory
Tuple spaces can be used to implement a memory in a similar way in which a map or dictionary can be used to model a memory. The idea is that every variable x is represented by a unique tuple

```
("x", v)
```

where v is the current value of x.

Updating a variable x can be realised by updating the corresponding tu-
ple, possibly after having read the values some other (variable) tuples. For instance, the assignment

```go
x := y + z;
```

can be implemented with

```go
query ("y", ?my_y) ; query ("z", ?my_z) ;
get ("x", ?my_x)
put ("x", my_y + my_z) ;
```go

A tuple space can be hence used as to emulate a shared memory.

since updates are not atomic the tuple space ("x", 0) may end up to be
("y", 0)
("x", 1) ("y", 1)

if the both queries are executed before any update.

## Tuple spaces and message passing
Communication channels can be implemented in tuple spaces in a similar way a set can be used to implement a list or a queue. Consider the simple case of FIFO channels. A possible solution is to represent messages in a channel c with tuples of the form
("c", "msg", i, m)
taking unique consecutive identifiers i, and m as the actual message con- tent.
Then pointers to the next available identifier and the identifier of the message at the head of the channel are used, which initially can be set to
("c", "first", 0) ("c", "next", 0)
For example, a channel Alice’s Inbox with contents <"hi"<"LOL"<"bye"<
can be represented in the tuple space with
("Alice’s Inbox", "first", 0); ("Alice’s Inbox", "msg", 0, "hi"); ("Alice’s Inbox", "msg", 1, "LOL"); ("Alice’s Inbox", "msg", 2, "bye"); ("Alice’s Inbox", "next", 3);
Sending a message m on a channel c can be done as follows:
get (c, "next", ?i) ;
put (c, "msg", i, m) ; put (c, "next", i + 1, 0) ;
while reading the next message from channel m into variable m can be done as follows:
get (c, "first", ?i) ;
while queryp((c, "next", i)) do
skip;
get (c, "msg", i, ?m) ; put (c, "first", i + 1) ;
   
# Reading suggestions
Andrews, G. R. (1999). Foundations of Multithreaded, Parallel, and Dis- tributed Programming. Addison-Wesley, 1 edition
Gelernter, D. (1985). Generative communication in Linda. ACM Trans. Pro- gram. Lang. Syst., 7(1):80–112

NOTE: The above documents present the original Linda approach to tuple spaces. Linda consists of the set of primivites put, get, query and their re- spective non-blocking variants. In the paper and and in the literature you will often find that put, get and query are called out, in and rd (or read). Asynchronous/non-blocking versions of put, get and query are called eval, inp and rdp.
