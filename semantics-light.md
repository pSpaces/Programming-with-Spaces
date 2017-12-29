This page provides the formal operational semantics for a light version of the pSpace programming model.

## Syntax

A pSpace concurrent program `S` is a pair `M |- P`, where `M` is a memory (i.e. a map of variables into values) and `P` is a a multiset of concurrent processes. More precisely, the syntax for pSpace programs is 

```
S := M |- P
```

A memory `M` is represented as list of mappings `x |-> u`, where `x` is a variaable and `u` is a value:

```
M := nil | x |-> u | M , M
```

We use the usual notational conventions:
* `M[x]` is the value associated to `x`, if any;
* Memory `M[x|->u]` is like `M` after updating the value associated to `x` by `u` or adding `x |-> u` if `M[x]` is not defined.

Tuple spaces reside in memory just as other values. A tuple space value is denoted by `Space(TS)` where and `TS` is a list of tuples, denoted with the following syntax:

```
TS ::= nil | t | TS * TS 
```

Concurrent processes are composed with the parallel composition operator `‖`. Such operator is associative, commutative and has the empty set `0` as identity:  

```
P ::= 0 | C‖C | A;P | ...
```

For simplicity, we usually drop the final `;0` from programs. We do not specify control flow constructs and other language ingredients and focus instead on tuple space actions `A`. 

The actions of a process include creation of new processes, creation of new tuple spaces and assignments using tuple space operations.

```
A ::= new P
  | space := new Space()
  | space.O
  | x,y := space.O
```

Operations `O` correspond to the core API of pSpaces:

```
O ::= put(t) 
  | query(T) 
  | queryP(T)
  | queryAll(T)
  | get(T)
  | getP(T)
  | getAll(T)
```

Tuples are denoted by non-empty lists of expressions `e`

```
t ::= e | e,t 
```

Templates are denoted as non-empty lists of expressions `e` or types `τ`

```
T ::= e | τ | e,T | τ,T
```

# Operational semantics

The operational semantics of concurrent pSpace programs is defined by the below set of inference rules. The inference rules provided below can be applied up-to the axioms of the symbols used (e.g. associativity of list concatenation `,` , associativity and commutativity of parallel process composition `‖`, ...). 

## Operational semantics for actions

Spawning a process just creates a new concurrent activity:

```
===================================================================
 M |- new P1 ; P2 ‖ P3 => M |- P1 ‖ P2 ‖ P3
```

Creating a new local space is formalised by the following rule:

```
===================================================================
 M |- space := new Space() ; P1 ‖ P2 =>
 M[space |-> Space(nil)] |- P1 ‖ P2 
```

The rule says that new spaces are created with an empty tuple list. The effect of the assignment is to create a new variable `space` (or overwrite `space` if it already exists.

The following rules describes the behaviour of executing an operation on a local space.

```
 S1.O => S2,t,e
===================================================================
 (M , space |-> S1) |- , x,y := space.O ; P1 ‖ P2) =>
 (M , space |-> S2)[x|->t][y|->e] |- P1 ‖ P2)
```

```
 S1.O => S2,t,e
===================================================================
 (M , space |-> S1) |- space.O ; P1 ‖ P2) =>
 (M , space |-> S2) |- P1 ‖ P2)
```

Note that the premise of the above rule requires a reaction of the space to the operation. The tuple space may not react and thus may block the process (by not allowing to fire the rule). The reactions of tuple spaces are described as operational rules below. The effect of the assignment on variables `x` and `y` is the usual one (i.e. update/overwrite the variables).


## Operational semantics of the core API

Recall that tuple lists `TS` are to be understood up to associativity of `*`, and identity of `nil`. Note that the result of an operation may alter the tuple structure `TS`, and that they produce a tuple and an error code (either `ok` or `ko`)

The behaviour of operation `put` is described by the following rule:

```
 Space(TS).put(t) => Space(t,TS),t,ok
``` 

The rule essentially says that the `put` operation updates the list of the tuple space with the new tuple `t`.

The behaviour of `query` is governed by the following rule:
 
```
 t matches T and no tuple in TS' matches T
===================================================================
 Space(TS*t*TS').query(T) => Space(TS*t*TS'),t,ok
 ```

The behaviour of `queryP` is similar but ensures progress and returns error codes accordingly. 

```
 t matches T and no tuple in TS' matches T
===================================================================
 Space(TS*t*TS').queryP(T) => Space(TS*t*TS'),t,ok
	
 no tuple in TS matches T
===================================================================
 Space(TS).queryP(T) => Space(TS),null,ko
```

The rest of the operations are defined similarly:

```
 t matches T and no tuple in TS' matches T
===================================================================
 Space(TS*t*TS').get(T) => Space(TS*TS'),t,ok

 t matches T and no tuple in TS' matches T
===================================================================
 Space(TS*t*TS').getP(T) => Space(TS*TS'),t,ok
	
 no tuple in TS matches T
===================================================================
 Space(TS).getP(T) => Space(TS),null,ko
 
 TS' = {t in TS such that t matches T}
===================================================================
 Space(TS).queryAll(T) => Space(TS),TS',ok
 
 TS' = {t in TS such that t matches T}
===================================================================
 Space(TS).getAll(T) => Space(TS\TS'),TS',ok
 
```


