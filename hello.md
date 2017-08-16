Let us program our first "hello world!" example.

Before starting, go to the main page of [pSpaces](../) and choose a programming language. Follow the instructions to install it.

We will create a simple program that illustrates the most basic features of spaces. The complete code can be found:
- [Hello World in Go](https://github.com/pSpaces/goSpace/blob/master/examples/HelloWorld/main.go)
- [Hello World in C#](https://github.com/pSpaces/dotSpace/wiki/getting-started)
- [Hello World in Java]

We will go through it step by step.

1. Create a space named `inbox` at port 8080

Go
```go
	inbox := goSpace.NewSpace("8080")
```
C#
```
            FifoSpace dtu = new FifoSpace();
```



2. Put a simple tuple in the space

Go
```go
goSpace.Put(inbox, "Hello World!")
```
C#
```
dtu.Put("Hello world!");
```


3. Retreive the tuple from the space

Go
```go
var message string
goSpace.Get(inbox, &message)
```
C#
```
ITuple tuple = dtu.Get(typeof(string));
```

4. Print the message

Go
```go
fmt.Println(message)
}
```
C#
```
Console.WriteLine(tuple);
```


If you got it, you are now ready for more examples :)
