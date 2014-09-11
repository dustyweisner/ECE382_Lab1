;-------------------------------------------------------------------------------
;MSP430 Assembler Code Template for use with TI Code Composer Studio
;C2C Dustin Weisner
;USAF Academy
;Lab1 - A Simple Calculator
;Documentation: September 9, 2014 - C2C Jaksha helped me by telling me the .equ
;   needs a # when being used, and by prompting me to look at how the
;	multiplication will work by telling me to look at how you solve
;	multiplication by hand. Also, Capt. Trimble helped me understand the
;	addressing modes better.
;-------------------------------------------------------------------------------
            		.cdecls C,LIST,"msp430.h"       		; Include device header file

;-------------------------------------------------------------------------------
            		.text                           		; Assemble into program memory
            		.retain                         		; Override ELF conditional linking
                                            				; and retain current section
            		.retainrefs                     		; Additionally retain any sections
                                           					; that have references to current
                                            				; section
;The following is my program stored into ROM:
myProgram: 			.byte	0x22, 0x11, 0x22, 0x22, 0x33, 0x33, 0x08, 0x44, 0x08, 0x22, 0x09, 0x44, 0xff, 0x11, 0xff, 0x44, 0xcc, 0x33, 0x02, 0x33, 0x00, 0x44, 0x33, 0x33, 0x08, 0x55
;The following sets values of the operations:
ADD_OP:				.equ	0x11
SUB_OP:				.equ	0x22
MUL_OP:				.equ	0x33
CLR_OP:				.equ	0x44
END_OP:				.equ	0x55
;The following opens memory space at 0x0200 for my results:
					.data
myResults:			.space	20
;-------------------------------------------------------------------------------
RESET      			mov.w   #__STACK_END,SP         		; Initialize stackpointer
StopWDT     		mov.w   #WDTPW|WDTHOLD,&WDTCTL 			; Stop watchdog timer
;-------------------------------------------------------------------------------
					mov.w	#myResults, r6					;memory pointer for the results
					mov.w	#myProgram, r7					;first operand pointer (r7) at beginning of my program
					mov.b	@r7, r8							;value at the word in the first pointer into r8
					cmp		#CLR_OP, r8						;checks if first word is CLR_OP
					jeq		Clearfirst
					cmp		#END_OP, r8 					;checks if first word is END_OP
					jeq		End
;Start copies the indirect value at r7 into the value at r11, a value holder ultimate used to send to myResults.
Start:				mov.b	@r7, r11
;Setters increment the operands through every loop to move through myProgram.
Setters:			mov.w	r7, r8							;create operation pointer (r8)
					inc		r8								;set operation pointer
					mov.w	r8, r9							;create second operand pointer (R9)
					inc 	r9								;set second operand pointer
					mov.b	@r8, r10						;sets "operation value"
;The following operations are compare "operation value" with the value of the operations.
Addition:			cmp		#ADD_OP, r10
					jnz		Subtraction
					add.b	@r9, r11						;adds the two operand values together
					and.w	#0x0001, r2						;checks for a bit in the 'carry' of r2
					cmp		#0x0001, r2
					jnz		Store
					mov.w	#0x00FF, r11					;if there's a carry, set memory value to overflow (0xFF)
					jmp		Store

Subtraction:		cmp		#SUB_OP, r10
					jnz		Multiplication
					mov.b	@r9, r7							;moves indirect value at operand 2 pointer for use
					sub.w	r7, r11							;subtracts the two operand values together
					cmp		#0x0004, r2						;checks for a bit in the 'zero' of r2
					jnz		Store
					mov.w	#0x0000, r11					;replaces a negative number with 0x00
					jmp		Store

Multiplication:		cmp		#MUL_OP, r10
					jnz		Clear
					mov.b	r11, r10						;keeps value at r11
					mov.w	#0x000, r11						;reset r11 for multiplication shifts
					mov.b	@r9, r8
					mov.w	#0x0001, r12					;sets a counter
					mov.w	r12, r7							;makes a new exponential counter
;Makes a loop of 8 word shifts to add together
Shiftadd:			cmp		#0x0009, r12					;makes the loop go through only 8 times
					jz		Overflow						;if at 9th loop, go store the answer after overflow
					and		r7, r8							;find the bit of the second operand
					cmp		#0x0000, r8						;see if the bit is 0 or 1
					jz		Shift							;skip the add if 0
		 			add.w	r10, r11						;add to value

Shift:				rla.w	r10								;shift the first operand to the left
					mov.b	@r9, r8							;restore second operand
					add.b	r7, r7							;doubles to go through the bits
					inc.b	r12								;increment r12 as a bit
					jmp		Shiftadd

Clear:				cmp		#CLR_OP, r10
					jnz		End
					mov.b	#0x00, 0(r6)					;set the value at the memory pointer to zero
					mov.b	@r9, r11						;set the memory value to the value at r9
					inc		r6								;increment the memory pointer
					mov.w	r9, r7							;moved the second operand pointer to be the first
					jmp		Setters

Overflow:			cmp		#0x00FF, r11					;only for multiplication, because we used a word size
					jn		Store
					mov.w	#0x00FF, r11					;sets highest byte size

Store:				mov.b	r11, 0(r6)						;stores value at myResults
					inc		r6								;increments pointer to myResults
					mov.w	r9, r7							;moved the second operand pointer to be the first
					jmp		Setters
;To debug any problems with there being a clear or End first
Clearfirst:			mov.b	#0x00, 0(r6)					;set 0 to myResults
					inc		r6
					inc		r7
					jmp		Start

End:				jmp		End								;runs forever so computer doesn't crash

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            		.global __STACK_END
            		.sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            		.sect   ".reset"                		; MSP430 RESET Vector
            		.short  RESET
