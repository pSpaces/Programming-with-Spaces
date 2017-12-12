This page provides the formal operational semantics for the pSpace programming model.

## Syntax

We start defining the syntax that describes a system S as a multiset of applications. Each application runs on a `host`, has a memory `M` and a multiset of concurrent processes `P`. Parallel composition of applications is denoted with operator `‖`, which is associative, commutative and has the empty set `0` as identity.  

```
S ::= 0 | S‖S | App(host,M,P)
```

Memory `M` is represented as a mapping of variables into values. Among those values we remark spaces and repositories. A local space space `Space(kind,bound,TS)` includes a class of space `kind` (one of `Sequential`, `Queue`, `Stack`, `Pile` and `Random` and `NonDet`), a `bound` on their size (a positive natural number or ∞) and a tuple structure `TS`. A remote space `RemoteSpace(gate/spaceId)` is defined by a `gate` and a space identifier `spaceId`. A repository `Repository(ss,gg)` is defined by a mapping `ss` of space identifiers into actual space variables and a set `gg` of gates.

Concurrent processes are composed with `‖` too. We do not specify control flow constructs and other language ingredients and focus instead on tuple space actions. 

```
P ::= 0 | C‖C | A;P | ...
```

The actions of a process include creation of local and remote spaces, creation of repositories, addition/removal of gates and assignments using tuple space operations.

```
A ::= new P
  | space := new Space(kind,bound)
  | space := new RemoteSpace(gate,spaceId)
  | rep := new Repository()
  | rep.addSpace(spaceId,space)
  | rep.delSpace(spaceId)
  | rep.addGate(gate)
  | rep.delGate(gate)
  | x,y := space.O
```

Operations `O` correspond to the core API

```
O ::= put(t) 
  | query(T) 
  | queryP(T)
  | queryAll(T)
  | get(T)
  | getP(T)
  | getAll(T)
```

A tuple structure `TS` is basically a list of all tuples, composed with the associative operation `*` (with `nil` being the identity operation)

```
TS ::= nil | t | TS * TS 
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
 App(host, M, space := new Space(kind,bound) ; P1 ‖ P2) =>
 App(host, M[space |-> Space(kind,bound)] , P1 ‖ P2 )
```

The following rule describes the behaviour of executing an operation on a local space. Note that the premise of the rule requires a reaction of the space to the operation. Such reactions are described as operational rules below. Note that a space may not react (and thus block the process).  

```
 S1.O => S2,t,e
===================================================================
 App(host, (M , space |-> S1), x,y := space.O ; P1 ‖ P2) =>
 App(host, (M , space |-> S2)[x|->t][y|->e] , P1 ‖ P2)
```

The following rule describes the behaviour of executing an operation on a remote space.

```
   host(gate) = host2        M2[ss[spaceId]].O -> S,t,e
===================================================================
   App(host1, (M1 , space |-> RemoteSpace(gate/spaceId)), x,y := space.O ; P1 ‖ P2 )
 ‖ App(host2, (M2, rep |-> Repository(ss,(gate,gg)) , P3)  =>
   App(host1, (M1 , space |-> RemoteSpace(gate/spaceId))[x|->t][y|->e], P1 ‖ P2 )
 ‖ App(host2, (M2, rep |-> Repository(ss,(gate,gg)) , P3) 
```

Connecting to a remote space is formalised by  

```
   host(gate) = host2         M2[spaceId] defined
===================================================================
   App(host1, M, space := new RemoteSpace(gate/spaceId); )
 ‖ App(host2, (M2, rep |-> Repository(ss),(gate,gg)) , P3)  =>
   App(host1, M[space|->RemoteSpace(gate/spaceId) P1 ‖ P2)
 ‖ App(host2, (M2, rep |-> Repository(ss),(gate,gg)) , P3) 
```

Creating a space repository is formalised by 

```
===================================================================
 App(host, M, rep := new Repository() ; P1  ‖ P2) =>
 App(host, M[rep |-> Repository(0,0)], P1  ‖ P2)
```

Adding and deleting gates and spaces to repositories is formalised by the following set of rules

```
 ss[spaceId] undefined
===================================================================
 App(host, M[rep |-> Repository(ss,gg)], rep.addSpace(spaceId,space) ; P1 ‖ P2) =>
 App(host, M[rep |-> Repository(ss[spaceId |-> space],gg)], P1 ‖ P2)

 host(gate) = host
===================================================================
 App(host, M[rep |-> Repository(ss,gg)], rep.addGate(gate) ; P1 ‖ P2) =>
 App(host, M[rep |-> Repository(ss,(gg,gate))], P1 ‖ P2)


===================================================================
 App(host, M[rep |-> Repository(ss,gg)], rep.delSpace(spaceId,space) ; P1 ‖ P2) =>
 App(host, M[rep |-> Repository(ss/spaceId,gg)], P1 ‖ P2)


===================================================================
 App(host, M[rep |-> Repository(ss,gg)], rep.delGate(gate) ; P1 ‖ P2) =>
 App(host, M[rep |-> Repository(ss,gg/gate)], P1 ‖ P2)
```

Spawning a process just creates a new concurrent activity:

```
===================================================================
 App(host, M, new P1 ; P2 ‖ P3) -> App(host, M, P1 ‖ P2 ‖ P3)
```

## Operational semantics of the core API

In the following rules tuple structures TS are to be understood up to associativity of `*`, and identity of `nil` (i.e. as a list). Note that the result of an operation may alter the tuple structure, and produce a tuple and an error code (either `ok` or `ko`)

The behaviour of `put` is common to all spaces

```
 |TS| <= b
===================================================================
 Space(k,b,TS).put(t) => Space(k,b,t*TS),t,ok
``` 

The behaviour of `query` depends on the class of space:
 
```
 t matches T and no tuple in TS' matches T
===================================================================
Space(Sequential,b,TS*t*TS').query(T) => Space(Sequential,b,TS*t*TS'),t,ok

 t matches T 
===================================================================
 Space(Queue,b,TS*t).query(T) => Space(Queue,b,TS*t),t,ok
	if 
 t matches T 
===================================================================
 Space(Stack,b,t*TS).query(T) => Space(Stack,b,t*TS),t,ok

 t matches T and no tuple in TS matches T
===================================================================
 Space(Pile,b,TS*t*TS').query(T) => Space(Pile,b,TS*t*TS'),t,ko

 t is chosen randomly in { t in TS such that t matches T}
===================================================================
Space(Random,b,TS).query(T) => Space(Random,b,TS),t,ok
	
 t matches T
===================================================================
 Space(NonDet,b,TS*t*TS').query(T) => Space(NonDet,b,TS*t*TS'),t,ok
```

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
