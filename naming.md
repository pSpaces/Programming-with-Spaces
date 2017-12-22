This page summarises some of the key programming primitives of pSpaces and their actual naming in the different languages. 

## Tuples

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| Tuple datatype | `t` |  |  |  `Tuple` or `[]interface{}` |  |  | |
| Tuple creation | `tuple := ("a",1,3.14)` |  |  | `tuple := CreateTuple("a",1,3.14)` |  |  
| Tuple access | `tuple[i]` |  |  | `tuple.GetFieldAt(i)` |  |  |  |



## Space API

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| add tuple | `put("a",1)` |  |  | `Put("a",1)` |  |  |
| search tuple | `t := s.query("a",&x)` | `Object[] t = s.get(new ActualField("a"),new FormalField(Integer.class())` | `ITuple t = s.Query("a",typeof(int));` | `t: = query("a",&x)` |  |  |
| wait for tuple) | `queryP` |  |  |  |  |  |
| search all tuples | `queryAll` |  |  |  |  |  |
| wait for tuple and remove ( | `get` |  |  |  |  |  |
| remove tuple | `getP` |  |  |  |  |  |
| remove all tuples | `getAll` |  |  |  |  |  |

## Spaces and repositories

| Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - |
| create local space | `new Space(kind,bound)` | (*)  |  |  |  |  |
| add tuple |                       | `new SequentialSpace()` |  |  |  |  |
| hook to remote space | `new RemoteSpace(gate,spaceId)` |  |  | |  |  |
| create repository | `new Repository()` |  |  | (x) |  |  |
| add space to repository | `r.addSpace(spaceId,space)` |  |  | (x) |  |  |
| remove space from repository  | `r.delSpace(spaceId)` |  |  | (x) |  |  |
| add gate to repository  | `r.addGate(gate)` |  |  | (x) |  |  |
| remove gate from repository  | `r.delGate(gate)` |  |  | (x) |  |  |

(*) `kind` not supported as parameter: one constructor per kind. `bound` not supported (internal choice is ∞)

(x) not supported
