#include "wramp.h"

int counter = 0;		//Global integer variable working as a stopwatch.

//Main method. Used to select which format to output to serial port 2 using.
void serial_main()
{
	int keyPressed = 0;		//Integer variable for checking if a key is pressed.
	int formatSelect = '1';		//Integer variable for picking which fromat to output as. Set to one as default.
	int boolLoop = 1;		//Integer variable for looping or not.

	while (boolLoop)		//Create an infinite loop.
	{
		keyPressed = WrampSp2->Stat;		//"Read" the key status of Serial Port 2.
		
		if (keyPressed & 1)		//Check if a key has been pressed.
		{
			if (WrampSp2->Rx == '1')
			{
				formatSelect = WrampSp2->Rx;		//Set 'formatSelect' to q.
			}
			
			else if (WrampSp2->Rx == '2')		//Check if the '2' key was pressed.
			{
				formatSelect = WrampSp2->Rx;		//Set 'formatSelect' to q.
			}
			
			else if (WrampSp2->Rx == '3')		//Check if the '2' key was pressed.
			{
				formatSelect = WrampSp2->Rx;		//Set 'formatSelect' to q.
			}
			
			else if (WrampSp2->Rx == 'q')		//Check if the '2' key was pressed.
			{
				formatSelect = WrampSp2->Rx;		//Set 'formatSelect' to q.
			}
			
			else		//Error handling.
			{
				//Handle error here.
			}
		}
		
		
		if (formatSelect == '1')		//If the user selected the first format.
		{
			printChar('\r');		//Clear the line.
			fromat1();		//Go to format 1.
		}
		
		else if (formatSelect == '2')		//If the user selected the second format.
		{
			printChar('\r');		//Clear the line.
			fromat2();		//Go to format 2.
		}
		
		else if (formatSelect == '3')		//If the user selected the third format.
		{
			printChar('\r');		//Clear the line.
			fromat3();		//Go to format 3.
		}
		
		else if (formatSelect == 'q')		//If the user selected to exit.
		{
			return;		//Return to parent.
		}
		
		else		//Error handling.
		{
				//Handle error here.
		}
	} 
}

//Method for printing in format 1.
void fromat1 ()
{
	int tempCounter = counter;		//Integer variable for creating a temporary counter equal to 'counter'.
	int numSeconds = (tempCounter / 100);		//Integer variable for counting the number of seconds.
	int temp = (((numSeconds / 600) % 6) + '0');		//Integer variable for temporary number management.

	printChar(temp);		//Print the left minutes digit.
	
	temp = ((numSeconds / 60) % 10) + '0';		//Calculate the right minutes digit.
	printChar(temp);		//Print the digit.
	
	printChar(':'); //print char
	
	temp = ((numSeconds % 60) / 10) + '0';		//Calculate the left seconds digit.
	printChar(temp);		//Print the digit.
	
	temp = (numSeconds % 10) + '0';		//Calculate the right seconds digit.
	printChar(temp);		//Print the digit.
	
	printChar(' ');		//Print a blank digit.
	printChar(' ');		//Print a blank digit.
}	

//Method for printing in format 2.
void fromat2 ()
{
	int tempCounter = counter;		//Integer variable for creating a temporary counter equal to 'counter'.
	int numSeconds = (tempCounter / 100);		//Integer variable for counting the number of seconds.
	int temp = (numSeconds / 1000) + '0';		//Integer variable for temporary number management.

	printChar(temp);		//Print the first (from left) seconds digit.
	
	temp = ((numSeconds / 100) % 10) + '0';		//Calculate the second (from left) seconds digit.
	printChar(temp);		//Print the digit.
	
	temp = ((numSeconds % 100) / 10) + '0';		//Calculate the third (from left) seconds digit.
	printChar(temp);		//Print the digit.
	
	temp = (numSeconds % 10) + '0';		//Calculate the fourth (from left) seconds digit.
	printChar(temp);		//Print the digit.
	
	printChar('.');		//Print a '.'.
	
	temp = ((tempCounter % 100) / 10) + '0';		//Calculate the first (from left) decimal digit.
	printChar(temp);		//Print the digit.
	
	temp = (tempCounter % 10) + '0';		//Calculate the second (from left) decimal digit.
	printChar(temp);		//Print the digit.
	
	printChar(' ');		//Print a blank digit.
	printChar(' ');		//Print a blank digit.
}

//Method for printing in format 3.
void fromat3 ()
{
	int tempCounter = counter;		//Integer variable for creating a temporary counter equal to 'counter'.
	int temp = (tempCounter / 100000) + '0';		//Integer variable for temporary number management.	

	printChar(temp);		//Print the left most timer interupt digit.
	
	temp = ((tempCounter / 10000) % 10) + '0';		//Calculate the second (from left) timer interup digit.
	printChar(temp);		//Print the digit.
	
	temp = ((tempCounter / 1000) % 10) + '0';		//Calculate the third (from left) timer interup digit.
	printChar(temp);		//Print the digit.
	
	temp = ((tempCounter % 1000) / 100) + '0';		//Calculate the fourth (from left) timer interup digit.
	printChar(temp);		//Print the digit.
	
	temp = ((tempCounter % 100) /10) + '0';		//Calculate the fifth (from left) timer interup digit.
	printChar(temp);		//Print the digit.
	
	temp = (tempCounter % 10) + '0';		//Calculate the sixth (from left) timer interup digit.
	printChar(temp);		//Print the digit.
	
	printChar(' ');		//Print a blank digit.
	printChar(' ');		//Print a blank digit.
}

//Method for printing a character in to Serial Port 2.
void printChar (int tempChar)
{
	while(!(WrampSp2->Stat & 0x2))		//While Serial Port 2 is not ready to print.
	{
	}
	
	WrampSp2->Tx = tempChar;		//Print 'tempChar' to Serial Port 2.
}
