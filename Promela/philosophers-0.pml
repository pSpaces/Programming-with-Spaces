// This is a model of the classic problem of the dining philosophers
// The solution is a wrong one: the philosophers can end up in a deadlock

// Define the number "N" of philosophers
#define N 3

// We will use "mtype" values as tags (first field) for our tuples
mtype = { fork }

// We define a sequential space named "board" 
// Tuples are of only of type "< mtype , byte >"
// where the first field is the kind of tuple (e.g. "fork")
// and the second field is used as identifier (e.g. identifier of the fork)
chan board = [N] of { mtype , int}


// We define a "waiter" process that setups the dining room
active proctype waiter(){

	int i;

	// put all forks on the table
	printf("Waiter putting forks on the table...\n");
	i = N-1; 
	do
	::i >= 0 ->
	 	board!fork,i;
		printf("Waiter put fork %d on the table.\n",i);
		i--
	:: 	else -> break
	od;

	printf("Waiter done.\n");

}

// We define an array of philosopher processes 
active [N] proctype philosopher() {

	// In Promela "_pid" is the unique integer identifier of the current process
	// We use it to define the id "me" of the philosopher
	int me = _pid % N;

	// We define variables to identify the left and right forks
	int left = me;
	int right = (me+1)%N;

	// The philosopher enters his endless life cycle
	do
	::	// Wait until the left fork is ready (get the corresponding tuple)
		board??fork,eval(left) ->
	   	printf("Philosopher %d got left fork\n",me);

		// Wait until the right fork is ready (get the corresponding tuple)
	   	board??fork,eval(right);
       		printf("Philosopher %d got right fork\n",me);

		// Lunch time
		printf("Philosopher %d is eating...\n",me);

		// Return the forks (put the corresponding tuples)
		board!fork,left;
		board!fork,right;
     		printf("Philosopher %d put both forks on the table\n",me)
	od
}
