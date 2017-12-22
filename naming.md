This page summarises some of the key programming primitives of pSpaces and their actual naming in the different languages. 

## Tuples

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| Tuple datatype | `t` | `Tuple` or `Object[]` |  |  `Tuple` or `[]interface{}` |  |  | |
| Tuple creation | `tuple := ("a",1)` | `Tuple tuple = new Tuple("a",1)` |  | `tuple := CreateTuple("a",1)` |  |  
| Tuple access | `tuple[i]` | tuple.getElementAt[i] |  | `tuple.GetFieldAt(i)` |  |  |  |

## Space API

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| add tuple | `s.put("a",1)` | s.put("a",1) |  | `Put("a",1)` |  |  |
| search tuple | `t := s.query("a",&x)` | `Object[] t = s.query(new ActualField("a"),new FormalField(Integer.class())` | `ITuple t = s.Query("a",typeof(int));` | `t,e := s.QueryP("a",&x)` |  |  |
| wait for tuple) | `queryP` | `Object[] t = s.queryP(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.QueryP("a",&x)` |  |  |
| search all tuples | `queryAll` | `List<Object[]> tl = s.queryAll(new ActualField("a"),new FormalField(Integer.class())` |  | `tl,e := s.QueryAll("a",&x)` |  |  |
| wait for tuple and remove | `get` | `Object[] t = s.get(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.Get("a",&x)` |  |  |
| remove tuple | `getP` | `Object[] t = s.getP(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.GetP("a",&x)` |  |  |
| remove all tuples | `getAll` | `List<Object[]> tl = s.getAll(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.GetAll("a",&x)` |  |  |

## Spaces and repositories

| |  Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| create local space | `new Space(kind,bound)` | (1)  | (1) | (1) | (1) | (1) |
| | `kind` = SequentialSpace | `new SequentialSpace()` |  |  new Space(uri) |  |  |
| | `kind` = QueueSpace      | `new FIFOSpace()` |  |  -not supported- |  |  |
| | `kind` =  StackSpace     | `new LIFOSpace()` |  | -not supported-  |  |  |
| | `kind` = PileSpace       | -not supported-  |  | -not supported-  |  |  |
| | `kind` = RandomSpace     | -not supported-  |  | -not supported-  |  |  |
| hook to remote space | `new RemoteSpace(gate,spaceId)` | `new RemoteSpace(uri)` |  | `new RemoteSpace(uri)`|  |  |
| create repository | `new Repository()` |  |  | -not supported-  |  |  |
| add space to repository | `r.addSpace(spaceId,space)` |  |  | -not supported-  |  |  |
| remove space from repository  | `r.delSpace(spaceId)` |  |  | -not supported-  |  |  |
| add gate to repository  | `r.addGate(gate)` |  |  | -not supported-  |  |  |
| remove gate from repository  | `r.delGate(gate)` |  |  | -not supported-  |  |  |

(1) `kind` not supported as parameter: one constructor per kind. `bound` not supported (internal choice is ∞)
