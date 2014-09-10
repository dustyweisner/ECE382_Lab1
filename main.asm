;-------------------------------------------------------------------------------
; MSP430 Assembler Code Template for use with TI Code Composer Studio
;Dustin Weisner
;USAF Academy
;Lab1 September 10,2014 - Documentation C2C Jaksha helped me by telling me the .equ
;   needs a # when being used. Capt. Trimble helped me understand the addressing modes
; 	better
;
;
;-------------------------------------------------------------------------------
            .cdecls C,LIST,"msp430.h"       ; Include device header file

;-------------------------------------------------------------------------------
            .text                           ; Assemble into program memory
            .retain                         ; Override ELF conditional linking
                                            ; and retain current section
            .retainrefs                     ; Additionally retain any sections
                                            ; that have references to current
                                            ; section

myProgram: 		.byte						0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0x11, 0xDD, 0x44, 0x08, 0x22, 0x09, 0x44, 0xFF, 0x22, 0xFD, 0x55                                          ; section
ADD_OP:			.equ		0x11
SUB_OP:			.equ		0x22
MUL_OP:			.equ		0x33
CLR_OP:			.equ		0x44
END_OP:			.equ		0x55

				.data
myResults:		.space		20
;-------------------------------------------------------------------------------
RESET       mov.w   #__STACK_END,SP         ; Initialize stackpointer
StopWDT     mov.w   #WDTPW|WDTHOLD,&WDTCTL  ; Stop watchdog timer

;-------------------------------------------------------------------------------
                                            ; Main loop here
;-------------------------------------------------------------------------------
					mov.w	#myResults, r6				;memory pointer
					mov.w	#myProgram, r7				;1st pointer (R7) at first operand
					mov.b	@r7, r8						;value of first word into r8
					cmp		#CLR_OP, r8					;checks if first word is CLR_OP
					jeq		Clearfirst
					cmp		#END_OP, r8 				;checks if first word is END_OP
					jeq		End
Start:				mov.b	@r7, r11

Setters:			mov.w	r7, r8						;create 2nd pointer (R8) for operation
					inc		r8							;set second pointer
					mov.w	r8, r9						;create 3rd pointer (R9) for 2nd operand
					inc 	r9							;set third pointer
					mov.b	@r8, r10

Addition:			cmp		#ADD_OP, r10
					jnz		Subtraction

					add.b	@r9, r11

					jmp		Overflow

Subtraction:		cmp		#SUB_OP, r10
					jnz		Multiplication
					cmp		r9, r7
					mov.b	r2, r7
					jmp		Overflow

Multiplication:		cmp		#MUL_OP, r10
					jnz		Clear
					mov.b	#0x33, r11
					jmp		Overflow

Clear:				cmp		#CLR_OP, r10
					jnz		End
					mov.b	#0x00, r11
					jmp		Store

Overflow:			cmp		#0x0001, r2
					jne		Store
					mov.w	#0x00FF, r11
Store:				mov.b	r11, 0(r6)
					inc		r6
					mov.w	r9, r7
					jmp		Setters

Clearfirst:			mov.b	#0x00, 0(r6)
					inc		r6
					inc		r7
					jmp		Start

End:				jmp	End

;-------------------------------------------------------------------------------
;           Stack Pointer definition
;-------------------------------------------------------------------------------
            .global __STACK_END
            .sect 	.stack

;-------------------------------------------------------------------------------
;           Interrupt Vectors
;-------------------------------------------------------------------------------
            .sect   ".reset"                ; MSP430 RESET Vector
            .short  RESET
