This page provides the formal operational semantics for a light version of the pSpace programming model.

## Syntax

A pSpace concurrent program `S` is a pair `M |- P`, where `M` is a memory (i.e. a map of variables into values) and `P` is a multiset of concurrent processes. More precisely, the syntax for pSpace programs is

```
S := M |- P
```

A memory `M` is represented as list of mappings `x |-> u`, where `x` is a variable and `u` is a value:

```
M := nil | x |-> u | M , M
```

We use the usual notational conventions:
* Memory `M[x|->u]` is like `M` after updating the value associated to `x` by `u` or adding `x |-> u` if `M[x]` is not defined;
* `M[x]` is the value associated to `x`, if any;
* `M[e]` is the evaluation of `e` in `M` (evaluates all the variables in `e` and evaluates the expression).

Tuple spaces reside in memory just as other values. A tuple space value is denoted by `TS` with the following syntax:

```
TS ::= nil | t | TS * TS
```

Concurrent processes are composed with the parallel composition operator `‖`. Such operator is associative, commutative and has the empty set `0` as identity:  

```
P ::= 0 | P‖P | A;P | ...
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

The operational semantics of concurrent pSpace programs is defined by the below set of inference rules of the form

```
 premises
============
 conclusion
```

and, very often of the shape:

```
 premise1 premise2 ... premiseN
================================
 A => B
```

explaining how a program `A` can perform a computation step and evolve into `B` if the premises hold.

The inference rules provided below can be applied up-to the axioms of the symbols used (e.g. associativity of list concatenation `,` , associativity and commutativity of parallel process composition `‖`, ...).

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
 M[space |-> nil] |- P1 ‖ P2
```

The rule says that new spaces are created with an empty tuple list. The effect of the assignment is to create a new variable `space` (or overwrite `space` if it already exists).

The following rules describes the behaviour of executing an operation `O` on a local space.

```
 TS1.M[O] => TS2,t,e
===================================================================
 (M , space |-> TS1) |- , x,y := space.O ; P1 ‖ P2 =>
 (M , space |-> TS2)[x|->t][y|->e] |- P1 ‖ P2
```

```
 TS1.M[O] => TS2,t,e
===================================================================
 (M , space |-> TS1) |- space.O ; P1 ‖ P2 =>
 (M , space |-> TS2) |- P1 ‖ P2
```

Note that the premise of the above rule requires a reaction of the space to the operation. The tuple space may not react and thus may block the process (by not allowing to fire the rule). The reactions of tuple spaces are described as operational rules below. The effect of the assignment on variables `x` and `y` is the usual one (i.e. update/overwrite the variables). Note also that we evaluate the operation (i.e. any expression occurring in the operation is evaluated into a value).

## Operational semantics of the core API

For the operational semantics we need to formalise the notion of pattern matching. We do so with a boolean predicate `matches(t,T)` that denotes whether an evaluated tuple `t` matches the evaluated template `T` under the memory `M`. An evaluated tuple `t` is a tuple where all expressions have been evaluated, i.e. `t = M[t]`. An evaluated templated is defined similarly: all fields are either values or types.

The predicate is formalised as follows:

```
matches(v,v') = (v == v')

matches(v,τ) = type(v) == τ

matches((v,t),(v',T)) = true if matches(v,v') and matches(t,T)
matches((v,t),(v',T)) = false, otherwise

matches((v,t),(v',T)) = true if matches(v,v') and matches(t,T)
matches((v,t),(τ,T)) = false, otherwise

matches(t,T) = false, otherwise
```

In words, the tuple and the template must have the same length and must match field-wise.
When the template field is an actual field, the fields match when they have the same value. When the template field is a formal field (a type), the fields match when the type of the expression in the field of the tuple coincides with the type in the template field. We assume that the type of an expression `e` can be inferred with a function `type(e)`. Note that the last equation takes care of those cases where the length of the tuple and the template do not coincide.

Recall that tuple lists `TS` are to be understood up to associativity of `*`, and identity of `nil`. Note that the result of an operation may alter the tuple structure `TS`, and that they produce a tuple and an error code (either `ok` or `ko`)

The behaviour of operation `put` is described by the following rule:

```
 M |- TS.put(t) => (t*TS),t,ok
```

The rule essentially says that the `put` operation updates the list of the tuple space with the new tuple `t`.

The behaviour of `query` is governed by the following rule:

```
 matches(t,T,M) and for all t' in TS' not matches(t',T,M)
===================================================================
 TS*t*TS'.query(T) => TS*t*TS',t,ok
 ```

The behaviour of `queryP` is similar but ensures progress and returns error codes accordingly.

```
 matches(t,T) and for all t' in TS' not matches(t',T)
===================================================================
 TS*t*TS'.queryP(T) => TS*t*TS',t,ok

 for all t in TS' not matches(t,T)
===================================================================
 TS.queryP(T) => TS,null,ko
```

The rest of the operations are defined similarly:

```
 matches(t,T) and for all t' in TS' not matches(t',T)
===================================================================
 TS*t*TS'.get(T) => TS*TS',t,ok

 matches(t,T) and for all t' in TS' not matches(t',T)
===================================================================
 TS*t*TS'.getP(T) => TS*TS',t,ok

 for all t in TS not matches(t,T)
===================================================================
 TS.getP(T) => TS,null,ko

 TS' = {t in TS such that matches(t,T)}
===================================================================
 TS.queryAll(T) => TS,TS',ok

 TS' = {t in TS such that matches(t,T)}
===================================================================
 TS.getAll(T) => TS\TS',TS',ok
```
