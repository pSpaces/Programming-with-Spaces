The source code of this example is in file [philosophers-1.pml](philosophers-1.pml). The following instructions use the command-line interface of the Spin model checker. One of the GUIs of Spin can be of course used.

# Running the model
Assuming that Spin has been installed, the model can be run with

```
spin philosophers-1.pml
```

Not that the model is deadlock free; the philosophers will never stop and will keep progressing as in:

```
      Waiter putting forks on the table...
      Waiter put fork 2 on the table.
      Waiter put fork 1 on the table.
      Waiter put fork 0 on the table.
      Waiter putting tickets on the bowl...
          Philosopher 1 got a ticket
          Philosopher 1 got left fork
          Philosopher 1 got right fork
          Philosopher 1 is eating...
              Philosopher 2 got a ticket
      Waiter done.
          Philosopher 1 put both forks on the table and the ticket in the bowl
                  Philosopher 0 got a ticket
              Philosopher 2 got left fork
                  Philosopher 0 got left fork
                  Philosopher 0 got right fork
                  Philosopher 0 is eating...
              Philosopher 2 got right fork
              Philosopher 2 is eating...
```

# Verifying deadlock absence
To verify that the model is deadlock free  in the model we need to build a verifier for the model with

```
spin -a philosophers-1.pml
gcc -o pan pan.c
```

and then run it 

```
./pan
```

This will show an output like the following one, which indicates the absence of errors:

```
(Spin Version 6.4.7 -- 19 August 2017)
+ Partial Order Reduction

Full statespace search for:
	never claim         	- (none specified)
	assertion violations	+
	acceptance   cycles 	- (not selected)
	invalid end states	+

State-vector 112 byte, depth reached 243, errors: 0
      739 states, stored
      515 states, matched
     1254 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.099	equivalent memory usage for states (stored*(State-vector + overhead))
    0.290	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage


unreached in proctype waiter
	(0 of 23 states)
unreached in proctype philosopher
	philosophers-1.pml:84, state 15, "-end-"
	(1 of 15 states)
```
