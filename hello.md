Let us program our first "hello world!" example.

You will need to have one of the frameworks up and running. If not already done, go to the main page of [pSpaces](../), choose a framework and follow the instructions to install it. 

We will now create a simple program that illustrates the most basic features of spaces in different languages. The complete code of the example in each of the languages can be found here:
- [Hello World in Go](https://github.com/pSpaces/goSpace/blob/master/examples/HelloWorld/main.go)
- [Hello World in C#](https://github.com/pSpaces/dotSpace-Examples/blob/master/HelloWorld/Program.cs)
- [Hello World in Java](https://github.com/pSpaces/jSpace/blob/master/examples/HelloWorld/src/main/java/org/jspace/examples/helloworld/HelloWorld.java)
- [Hello World in Swift](https://github.com/pSpaces/SwiftSpace/blob/master/SwiftSpace/Examples/HelloWorld.swift)


We will go through it step by step.

# 1. Create a space named `inbox`

Go
```go
inbox := goSpace.NewSpace()
``` 
C#
```cs
SequentialSpace inbox = new SequentialSpace();
```
Java
```java
Space inbox = new SequentialSpace();
```
Swift
```swift
let inbox = TupleSpace(TupleList())
```

# 2. Put a simple tuple in the space

Go
```go
inbox.Put("Hello world!")
```
C#
```cs
inbox.Put("Hello world!");
```
Java
```java
inbox.put("Hellow world!");
```
Swift
```swift
_ = inbox.put(["Hello World!"])
```

# 3. Retrieve the tuple from the space

Go
```go
var message string;
inbox.Get(&message)
```
C#
```cs
ITuple message = inbox.Get(typeof(string));
```
Java
```java
Object[] tuple = inbox.get(new FormalField(String.class())
```
Swift
```swift
let tuple = inbox.get([FormalTemplateField(String.self)])
```


# 4. Print the message

Go
```go
fmt.Println(message)
```
C#
```cs
Console.WriteLine(tuple);
```
Java
```java
System.out.println(tuple[0]);
```
Swift
```swift
print(tuple)
```


If you got it, you are now ready for more examples :)
