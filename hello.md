Let us program our first "hello world!" example.

You will need to have one of the frameworks up and running. If not already done, go to the main page of [pSpaces](../), choose a framework and follow the instructions to install it. 

We will now create a simple program that illustrates the most basic features of spaces. The complete code of our example can be found:
- [Hello World in Go](https://github.com/pSpaces/goSpace/blob/master/examples/HelloWorld/main.go)
- [Hello World in C#](https://github.com/pSpaces/dotSpace/wiki/getting-started)
- [Hello World in Java](https://github.com/pSpaces/jSpace/blob/master/examples/HelloWorld/src/main/java/org/jspace/examples/helloworld/HelloWorld.java)

We will go through it step by step.

1. Create a space named `inbox` at port 8080

| Go | C# | Java |
|----|----|------|
| ``` inbox := goSpace.NewSpace("8080")``` | ``` FifoSpace dtu = new FifoSpace();``` | ```Space space = new SequentialSpace();```|

2. Put a simple tuple in the space

| Go | C# | Java |
|----|----|------|
| ```goSpace.Put(inbox, "Hello world!")``` | ```dtu.Put("Hello world!");``` | ```inbox.put("Hellow world!");```

3. Retreive the tuple from the space

| Go | C# | Java |
|----|----|------|
|```var message string;```<br>```goSpace.Get(inbox, &message) ``` | ```ITuple message = inbox.Get(typeof(string));``` | ```Tuple message = inbox.get(new FormalField(String.class())``` |

4. Print the message

| Go | C# | Java |
|----|----|------|
```fmt.Println(message)``` | ```Console.WriteLine(tuple);``` | ```System.out.println(messsage.at(0));```


If you got it, you are now ready for more examples :)
