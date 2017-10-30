// This is a hello world example for how to use Promela to model pSpace applications

// We define a sequential space named "inbox"
// The space is limited to 10 tuples
// The type for the tuples is byte (suitable for characters)
chan inbox = [10] of { byte }

// We define the main process here
active proctype main(){

	byte message[10];

	// Put the message, char-by-char
	inbox!'H';
	inbox!'i';
	inbox!'!';

	// Get the message, char-by-char
	inbox??message[0];
	inbox??message[1];
	inbox??message[2];

	// Print the message
	printf("%c%c%c\n",message[0],message[1],message[2])

}
