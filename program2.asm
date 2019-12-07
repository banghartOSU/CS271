TITLE Fibonacci Numbers    (program2.asm)

; Author:					Thomas Banghart
; Last Modified:		    10/19/19
; OSU email address:		banghart@oregonstate.edu
; Course number/section:	CS271 - Computer Architecture and Assembly Language
; Project Number:			2       
; Due Date:					10/20/19
; Description:				This program shows the user n numbers in the Fibonacci sequnce starting from 1. 
;							It asks the user for their name and a number between 1-46. Input value for the number 
;							uses a validation loop to ensure the request number is within bounds. The program exists 
;							with a goodbye message 

INCLUDE Irvine32.inc

MAX_NUM = 46
MIN_NUM = 1

.data
;Intro strings
	programTitle	BYTE	"Fibonacci Numbers", 0
	programAuthor	BYTE	"Programmed by Thomas Banghart", 0
	namePrompt		BYTE	"What's your name? ", 0
	hello			BYTE	"Hello, ", 0

;Instruction strings
	firstPrompt		BYTE	"Enter the number of Fibonacci terms to be displayed. ", 0
	secondPrompt	BYTE	"Provide the number as an integer in the range [1 .. 46].", 0
	thirdPrompt		BYTE	"How many Fibonacci terms do you want? ", 0
	validateNumMsg	BYTE	"Out of range. Enter a number in [1 .. 46]", 0
	bufferString	BYTE	"     ", 0

;Exit strings
	resultsString	BYTE	"Results certified by Leonardo Pisano.", 0
	goodbyeString	BYTE	"Goodbye,  ", 0
	period			BYTE	".", 0

;Input strings		
	userName		BYTE	15 DUP(?)

;Fib numbers
	userInputNum	DWORD	?

.code
main PROC

;************************************************************************
;INTRO: Provides info regarding the program (title, author) and then 
;prompts the user to input their name and repeats the input back to them.
;************************************************************************
introduction:
	mov		edx, OFFSET programTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET programAuthor
	call	WriteString
	call	Crlf	
;Prompt user for name 
	mov		edx, OFFSET namePrompt					;"What's your name?"
	call	WriteString
	mov		edx, OFFSET userName					;Pg 645 Irvine - First get variable in edx to hold input
	mov		ecx, (SIZEOF userName) - 1				;Pg 645 Irvine - Allocate space for the user input to stay 
	call	ReadString								;Pg 645 Irvine - The lib procedure reads the input and assigns it to ther var in edx
;Repeat name
	mov		edx, OFFSET	hello						;"Hello <name>"
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	call	CrLf
	
;************************************************************************
;DISPLAY INSTRUCTIONS: This section asks the user for the number of terms of the Fibonacci sequence 
; they would like to see. Only values >=1 and <=46 are allowed. If a user enters a value that is out of range
; then they are prompted to try again until they enter an allowed value. 
;************************************************************************
displayInstructions:
	mov		edx, OFFSET firstPrompt					;"Enter the number of Fibonacci terms to be displayed."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET secondPrompt				;"Provide the number as an integer in the range [1 .. 46]."
	call	WriteString
	call	CrLf
	
;************************************************************************
;GET NUM: Continuation of the above section but holds the logic for the data validation loop
;************************************************************************
getNum:
	mov		edx, OFFSET thirdPrompt					;"How many Fibonacci terms do you want?"
	call	WriteString
	call	ReadInt
	cmp		eax, MIN_NUM							;If input less than 1, show message and get new input - jump to showRevalidateString
	jl		showRevalidateString
	cmp		eax, MAX_NUM
	jg		showRevalidateString					;If input is greater than MAX_NUM show message and get new input - jump to showRevalidateString
	mov		userInputNum, eax
	mov		ecx, userInputNum						;Else load ecx as the loop counter with the user input.
	mov		eax, 1									;Get eax and ebx ready to run the fib sequence
	mov		ebx, 0
	mov		esi, 0									;Use esi to count number of terms displayed for line break.
	jmp		displayFibs								;Jump to displayFibs

	showRevalidateString:
		mov		edx, OFFSET validateNumMsg			;If number is out of range, give the user a message and prompt them 
		call	WriteString							;for another value.
		call	CrLf
		jmp		getNum								;Jump back to above label

;*********************************************************************************************************
;DISPLAY FIBS: This section shows the n terms of the Fibonacci sequence where n = the user input (1-46) 
;*********************************************************************************************************
displayFibs:
	add		eax, ebx								;F(n) = F(n-1) + F(n-2)
	call	WriteDec								;Print new number to screen
	mov		edx, eax								;Move F(n) to edx, it becomes F(n-1)
	mov		eax, ebx								;Move F(n-2) to eax
	mov		ebx, edx								;Move F(n-1) to ebx
	mov		edx, OFFSET bufferString				;Five " " for spacing
	call	WriteString								;Write buffer
	inc		esi										;Add one to esi keep track of when new line is needed
	cmp		esi, 4
	je		newLine									;Move to new line if 4 numbers have been printed
	jmp		continue								;If no new line is needed jump to "continue" which runs the loop again.

	;Jump to new line if we need to go to new line
	newLine:										;If 4 numbers have been printed move to next line
		call	CrLf
		mov		esi, 0
	;Otherwise continue the loop
	continue:
		loop	displayFibs							;When displayFibs is called eax = F(n-2) and ebx = F(n-1)
		call	CrLf
	
;*****************************************************************************
;GOODBYE: Say goodbye to the user and give credit to the sequence's creator.
;*****************************************************************************
goodbye:
	mov		edx, OFFSET	resultsString
	call	WriteString
	call	CrLf
	mov		edx, OFFSET goodbyeString
	call	WriteString
	mov		edx, OFFSET userName
	call	WriteString
	mov		edx, OFFSET period
	call	WriteString

	exit	; exit to operating system
main ENDP

END main
