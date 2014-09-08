ECE382_Lab1
===========

Assembly Language - "A Simple Calculator"


__*PRELAB DISCUSSION*__

  To implement the lab, I first must understand how the program will work. The simple calculator will have a series of words that will be used as the operands and operations of the calculations. 
  
    0x14 0x11 0x12

will store into memory "0x26". The first word is the first operand, the second being the operation and third the second operand. The operation in this example is addition, or ADD_OP. The other operations for full functionality in this lab include SUB_OP (0x22), MUL_OP (0x33), CLR_OP (0x44), and END_OP (0x55).

  Next I will make the flowchart of operations and how I plan to implement the program. I will start with a demonstration in the Raptor program. 
  
![](https://github.com/dustyweisner/ECE382_Lab1/blob/master/Flowchart.GIF?raw)
  
  I used all values as they would be in the assembly programming. I first asked for inputs as part of the functionality of Raptor, and when I enter 55 (symbolizing "0x55") the input loop exited. Then the program, with all the stored words, asked which operation was used by starting with the second word (assuming that the first word is not a CLR_OP or END_OP, which will be fixed in the actual implementation of the design in assembly programming) and looking at the operands before and after the word. Then the required calculation or operation will be stored within each loop through the instructions. After the calculation, all words that were calculated will go through a test to see if the words are greater than "0xFF" (250 - decimal). If they are, the value will change to "0x00". When the END_OP is reached, the program will exit the calculation loop. The rest of the Raptor program was used to test the results. The program ultimately has a successful flow. To take a closer look at the Raptor flowchart, look at [Flowchart Part 1](https://github.com/dustyweisner/ECE382_Lab1/blob/master/FlowchartPart1.GIF) and [Flowchart Part 2](https://github.com/dustyweisner/ECE382_Lab1/blob/master/FlowchartPart2.GIF).
