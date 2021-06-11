#include "wramp.h"

void parallel_main()
{
	int switches = 0;		//Integer variable for storing the switch values.
	int pushButtons = 0;		//Integer variable for storing the pushButton pressed.
	int lastButton = 0x1;		//Integer variable for remembering the last button pressed. Initilised for Hex.
	int boolLoop = 1;		//Integer variable for looping or not.
	
	while(boolLoop)		//Creates an infinite loop.
	{	
		switches = WrampParallel->Switches;		//Update to the switch values.
		pushButtons = WrampParallel->Buttons;		//Update to the push button value.
		
		if (pushButtons != 0x0)		//Check if a button has been pressed.
		{
			lastButton = pushButtons;		//Update the last button pressed.
		}
		
		if (lastButton == 0x1)		//Check if the right-most button is pressed.
		{
			printHex(switches);		//Print the switch values in Hex.
		}
		
		else if (lastButton == 0x2)		//Check if the middle button is pressed.
		{
			printDecimal(switches);		//Print the switch values in Decimal.
		}
		
		else if (lastButton == 0x4)		//Check if the left-most button is pressed.
		{
			return;		//Return to parent.
		}
		
		else		//Error handling.
		{
				//Handle error here.
		}
	}
}

//Method for printing in Decimal to the SSDs.
void printDecimal(int switchValue)
{	
	WrampParallel->UpperLeftSSD = (switchValue / 1000) % 10;		//Output to the left-most SSD.
	
	WrampParallel->UpperRightSSD = ((switchValue / 100) % 10);		//Output to the second (from left) SSD.
	
	WrampParallel->LowerLeftSSD = ((switchValue / 10) % 10);		//Output to the third (from left) SSD.
	
	WrampParallel->LowerRightSSD = (switchValue % 10);		//Output to the right-most SSD.
}

//Method for printing in Hex to the SSDs.
void printHex(int switchValue)
{
	WrampParallel->LowerRightSSD = (switchValue & 0xF);		//Output the right-most value to the right-most SSD.
	switchValue = switchValue>>4;		//SRLI by four bits.
	
	WrampParallel->LowerLeftSSD = (switchValue & 0xF);		//Output the third (from left) value to the third SSD.
	switchValue = switchValue>>4;		//SRLI by four bits.
	
	WrampParallel->UpperRightSSD = (switchValue & 0xF);		//Output the second (from left) value to the second SSD.
	switchValue = switchValue>>4;		//SRLI by four bits.
	
	WrampParallel->UpperLeftSSD = (switchValue & 0xF);		//Output the left-most value to the left-most SSD.
}
