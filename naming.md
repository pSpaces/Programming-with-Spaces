This page summarises some of the key programming primitives of pSpaces and their actual naming in the different languages. 

## Tuples

| Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - |
| Symbol (type) `t` |  |  |  `Tuple` or `[]interface{}` |  |  | |
| `tuple := ("a",1,3.14)` |  |  | `tuple := CreateTuple("a",1,3.14)` |  |  
| `tuple[i]` |  |  | `tuple.GetFieldAt(i)` |  |  |  |



## Space API

| Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - |
| `put("a",1)` |  |  | `Put("a",1)` |  |  |
| `t := s.query("a",&x)` | `Object[] t = s.get(new ActualField("a"),new FormalField(Integer.class())` | `ITuple t = s.Query("a",typeof(int));` | `t: = query("a",&x)` |  |  |
| `queryP` |  |  |  |  |  |
| `queryAll` |  |  |  |  |  |
| `get` |  |  |  |  |  |
| `getP` |  |  |  |  |  |
| `getAll` |  |  |  |  |  |

## Spaces and repositories

| Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - |
| `new Space(kind,bound)` | (*)  |  |  |  |  |
|                       | `new SequentialSpace()` |  |  |  |  |
| `new RemoteSpace(gate,spaceId)` |  |  | |  |  |
| `new Repository()` |  |  | (x) |  |  |
| `r.addSpace(spaceId,space)` |  |  | (x) |  |  |
| `r.delSpace(spaceId)` |  |  | (x) |  |  |
| `r.addGate(gate)` |  |  | (x) |  |  |
| `r.delGate(gate)` |  |  | (x) |  |  |

(*) `kind` not supported as parameter: one constructor per kind. `bound` not supported (internal choice is ∞)

(x) not supported
