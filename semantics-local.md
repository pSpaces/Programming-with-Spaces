This page provides the formal operational semantics for the "local" part of the pSpace programming model.

## Syntax

A pSpace concurrent program `S` is a pair `M |- P, where `M` is a memory (map of variables into values) `P` is a a multiset of concurrent processes `P`:

```
S := M |- P
```

A memory `M` is represented as a mapping of variables into values. We use the usual notation conventions:
* A memory `M` is represented as `x |-> u , y |-> v , ...` where `x,y,...` are variables and `u,v,...` are values;
* `M[x]` is the value associated to `x`, if any;
* Memory `M[x|->u]` is like `M` after updating the value associated to `x` by `u` or adding `x |-> u` if `M[x]` is not defined.

Tuple spaces reside in memory just as other values. A tuple space value is denoted by `Space(kind,bound,TS)` where
* `kind` (one of `Sequential`, `Queue`, `Stack`, `Pile` and `Random` and `NonDet`)
* a `bound` on their size (a positive natural number or ∞) 
* tuple structure `TS`.

A tuple structure `TS` is basically a list of all tuples, composed with the associative operation `*` (with `nil` being the identity operation)

```
TS ::= nil | t | TS * TS 
```

Concurrent processes are composed with the parallel composition operator `‖`. Such operator is associative, commutative and has the empty set `0` as identity:  

```
P ::= 0 | C‖C | A;P | ...
```

We do not specify control flow constructs and other language ingredients and focus instead on tuple space actions. 

The actions of a process include creation of new processes, creation of new tuple spaces and assignments using tuple space operations.

```
A ::= new P
  | space := new Space(kind,bound)
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

The operational semantics is defined by the below set of inference rules. The inference rules provided below can be applied under any context (i.e. under any sub-term) up-to the axioms of the symbols used (e.g. associativity of `*`). 

## Operational semantics for actions

Creating a new local space

```
===================================================================
 M |- space := new Space(kind,bound) ; P1 ‖ P2 =>
 M[space |-> Space(kind,bound)] |- P1 ‖ P2 
```

The following rule describes the behaviour of executing an operation on a local space. Note that the premise of the rule requires a reaction of the space to the operation. Such reactions are described as operational rules below. Note that a space may not react (and thus block the process).  

```
 S1.O => S2,t,e
===================================================================
 (M , space |-> S1) |- , x,y := space.O ; P1 ‖ P2) =>
 (M , space |-> S2)[x|->t][y|->e] |- P1 ‖ P2)
```

Spawning a process just creates a new concurrent activity:

```
===================================================================
 M |- new P1 ; P2 ‖ P3 => M |- P1 ‖ P2 ‖ P3
```

## Operational semantics of the core API

In the following rules, tuple structures TS are to be understood up to associativity of `*`, and identity of `nil` (i.e. as a list). Note that the result of an operation may alter the tuple structure, and produce a tuple and an error code (either `ok` or `ko`)

The behaviour of `put` is common to all kinds of spaces

```
 |TS| <= b
===================================================================
 Space(k,b,TS).put(t) => Space(k,b,t*TS),t,ok
``` 

The behaviour of `query` depends on the space kind. We present here the rules for kind `SequentialSpace` only:
 
```
 t matches T and no tuple in TS' matches T
===================================================================
 Space(Sequential,b,TS*t*TS').query(T) => Space(Sequential,b,TS*t*TS'),t,ok


The behaviour of `queryP` is similar but ensures progress and returns error codes accordingly. We just provide the rules for sequential spaces, the rest of the rules are defined similarly.

```
 t matches T and no tuple in TS' matches T
===================================================================
 Space(Sequential,b,TS*t*TS').queryP(T) => Space(Sequential,b,TS*t*TS'),t,ok
	
 no tuple in TS matches T
===================================================================
 Space(Sequential,b,TS).queryP(T) => Space(Sequential,b,TS),null,ko
```

The rest of the operations are defined similarly.
