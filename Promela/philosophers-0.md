The source code of this example is in file [philosophers-0.pml](philosophers-0.pml). The following instructions use the command-line interface of the Spin model checker. One of the GUIs of Spin can be of course used.

# Running the model
Assuming that Spin has been installed, the model can be run with

```
spin philosophers-0.pml
```

this will run the model and print some verbose information about the behavour of the philosophers. For example:

```
             Philosopher 2 got left fork
              Philosopher 2 got right fork
          Philosopher 1 got left fork
              Philosopher 2 is eating...
          Philosopher 1 got right fork
          Philosopher 1 is eating...
              Philosopher 2 put both forks on the table
      Philosopher 0 got left fork
          Philosopher 1 put both forks on the table
      Philosopher 0 got right fork
      Philosopher 0 is eating...
              Philosopher 2 got left fork
              Philosopher 2 got right fork
              Philosopher 2 is eating...
```

# Finding deadlocks
To find deadlocks in the model we need to build a verifier for the model with

```
spin -0 philosophers-0.pml
gcc -o pan pan.c
```

and then run it 

```
./pan
```

This will show an output like the following one, which indicates the existence of a deadlock (invalid state)

```
pan:1: invalid end state (at depth 15)
pan: wrote philosophers-0.pml.trail

(Spin Version 6.4.4 -- 1 November 2015)
Warning: Search not completed
	+ Partial Order Reduction

Full statespace search for:
	never claim         	- (none specified)
	assertion violations	+
	acceptance   cycles 	- (not selected)
	invalid end states	+

State-vector 72 byte, depth reached 16, errors: 1
       17 states, stored
        2 states, matched
       19 transitions (= stored+matched)
        0 atomic steps
hash conflicts:         0 (resolved)

Stats on memory usage (in Megabytes):
    0.002	equivalent memory usage for states (stored*(State-vector + overhead))
    0.292	actual memory usage for states
  128.000	memory used for hash table (-w24)
    0.534	memory used for DFS stack (-m10000)
  128.730	total actual memory usage
```
This will generate a trace of the deadlock in a file, which can be used to reproduce the error with:

```
spin philosophers-0.pml -replay philosophers-0.pml.trail 
```
