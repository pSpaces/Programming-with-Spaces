This page summarises some of the key programming primitives of pSpaces and their actual naming in the different languages. 

## Tuples

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| Tuple datatype | `t` | `Tuple` or `Object[]` |  |  `Tuple` or `[]interface{}` | `[TemplateField]` |  |
| Tuple creation | `tuple := ("a",1)` | `Tuple tuple = new Tuple("a",1)` |  | `tuple := CreateTuple("a",1)` | `let tuple = ["a", 1]` | |
| Tuple access | `tuple[i]` | tuple.getElementAt[i] |  | `tuple.GetFieldAt(i)` | `tuple[i]` |  |  

## Space API

| | Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| add tuple | `s.put("a",1)` | s.put("a",1) |  | `Put("a",1)` | `s.put(["a",1])` |  |
| search tuple | `t := s.query("a",&x)` | `Object[] t = s.query(new ActualField("a"),new FormalField(Integer.class())` | `ITuple t = s.Query("a",typeof(int));` | `t,e := s.QueryP("a",&x)` | `let t = s.query(["a",FormalTemplateField(Int.self)])` |  |
| wait for tuple) | `queryP` | `Object[] t = s.queryP(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.QueryP("a",&x)` | `let t = s.queryp(["a",FormalTemplateField(Int.self)])` |  |
| search all tuples | `queryAll` | `List<Object[]> tl = s.queryAll(new ActualField("a"),new FormalField(Integer.class())` |  | `tl,e := s.QueryAll("a",&x)` | `let t = s.queryAll(["a",FormalTemplateField(Int.self)])` |  |
| wait for tuple and remove | `get` | `Object[] t = s.get(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.Get("a",&x)` | `let t = s.get(["a",FormalTemplateField(Int.self)])` |  |
| remove tuple | `getP` | `Object[] t = s.getP(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.GetP("a",&x)` | `let t = s.getp(["a",FormalTemplateField(Int.self)])` |  |
| remove all tuples | `getAll` | `List<Object[]> tl = s.getAll(new ActualField("a"),new FormalField(Integer.class())` |  | `t,e := s.GetAll("a",&x)` | `let t = s.getAll(["a",FormalTemplateField(Int.self)])` |  |

## Spaces and repositories

| |  Formal | Java | C#  | Go | Swift | TypeScript |
| - | - | - | - | - | - | - |
| create local space | `s := new Space(kind,bound)` | (1)  | (1) | (1) | `let s = TupleSpace(kind)` | (1) |
| | `kind` = SequentialSpace | `Space s = new SequentialSpace()` |  |  new Space(uri) |  |  |
| | `kind` = QueueSpace      | `Space s = new FIFOSpace()` |  |  -not supported- | `let s = TupleSpace(TupleList())` |  |
| | `kind` =  StackSpace     | `Space s = new LIFOSpace()` |  | -not supported-  |  |  |
| | `kind` = PileSpace       | -not supported-  |  | -not supported-  |  |  |
| | `kind` = RandomSpace     | -not supported-  |  | -not supported-  |  |  |
| | `kind` = TreeSpace     | -not supported-  |  | -not supported-  | `let s = TupleSpace(TupleList())` |  |
| hook to remote space | `new RemoteSpace(gate,spaceId)` | `new RemoteSpace(uri)` |  | `new RemoteSpace(uri)`| `let rs = RemoteSpace(uri)` |  |
| create repository | `new Repository()` |  |  | -not supported-  | `let sr = SpaceRepository()` |  |
| add space to repository | `r.addSpace(spaceId,space)` |  |  | -not supported-  | `sr.add("id", space)` |  |
| remove space from repository  | `r.delSpace(spaceId)` |  |  | -not supported-  | `sr.remove("id")` |  |
| add gate to repository  | `r.addGate(gate)` |  |  | -not supported-  | `sr.addGate(gate)` |  |
| remove gate from repository  | `r.delGate(gate)` |  |  | -not supported-  | -not yet implemented- |  |

(1) `kind` not supported as parameter: one constructor per kind. `bound` not supported (internal choice is ∞)
