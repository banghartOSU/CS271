TITLE  Combinations Calculator  (program6b.asm)

; Author: Thomas Banghart
; Last Modified: 12/1/2019
; OSU email address: banghart@oregonstate.edu
; Course number/section: CS271
; Project Number: 6b                 Due Date: 12/8/2019 
; Description: This program helps users learning combinations. 
;			   It prompts the user with a combinations problem and asks for input (validates for digits only)
;			   It lets the user know if they answered correctly and asks if they want another question.

INCLUDE Irvine32.inc

LO = 3
HI = 12
MAX_INPUT = 101

;displayString macro is an easy way to write strings quickly 
displayString MACRO string
	push	edx
	mov		edx, string
	call	WriteString
	pop		edx
 ENDM

.data
;STRINGS
welcome		BYTE	"Welcome to the Combinations Calculator",0
author		BYTE	"Implemented by Thomas Banghart",0
intro_1		BYTE	"I'll give you a combinations problem",0
intro_2		BYTE	"You enter your answer and I'll let you know if you're right.",0
problem		BYTE	"Problem:",0
eleInSet	BYTE	"Number of elements in the set: ",0
eleChoose	BYTE	"Number of elements to choose from the set: ",0
howMany		BYTE	"How many ways can you choose? ",0

result_1	BYTE	"There are ",0
result_2	BYTE	" combinations of ",0
result_3	BYTE	" items from a set of ",0

practice	BYTE	"You need more practice.",0
correct		BYTE	"You are correct!",0

another		BYTE	"Another problem? (y/n): ",0
invalid		BYTE	"Invalid response.",0
notNum		BYTE	"There's something that isn't a digit, try again.",0

goodbye		BYTE	"OK ... goodbye.",0

period		BYTE	".",0


;INPUT
n			DWORD	?
nFac		DWORD	?
r			DWORD	?
rFac		DWORD	?
divisor		DWORD	?
solution	DWORD	?
inputLen	DWORD	?


;User guess will need to change this later to be a string and convert this to an integer -- for now, treating it as a number
guess		BYTE	101 DUP(?)
guessInt	DWORD	?
guessLength	DWORD	?


.code
main PROC

	;introduction
	push	OFFSET welcome
	push	OFFSET author
	push	OFFSET intro_1
	push	OFFSET intro_2
	call	introduction

playAgain:										;Start of loop to play again
	;getRandNums
	call	Randomize
	push	OFFSET n
	push	OFFSET r
	call	getRandNums

	;combinations
	push	OFFSET solution
	push	n
	push	OFFSET nFac
	push	r
	push	OFFSET rFac
	push	OFFSET divisor
	call	combinations
	 
	;showProblem
	call	CrLf
	call	CrLf
	push	OFFSET problem
	push	OFFSET eleInSet
	push	OFFSET eleChoose
	push	OFFSET n
	push	OFFSET r
	call	showProblem

	;getData
	push	OFFSET guessLength
	push	OFFSET invalid
	push	OFFSET howMany
	push	OFFSET guess
	call	getData

	;convertString
	push	OFFSET guess
	push	OFFSET guessInt
	push	guessLength
	call	convertString
	
	;results
	push	OFFSET result_1
	push	OFFSET result_2
	push	OFFSET result_3
	push	OFFSET period
	push	solution
	push	n
	push	r
	call	showResults

	;compare
	push	OFFSET practice
	push	OFFSET correct
	push	guessInt
	push	solution
	call	compareInput

invalidLoop:										;Loop to make sure input to play again prompt is either 'y' or 'n'
	displayString OFFSET another
	call	ReadChar
	cmp		al, 'y'
	je		playAgain
	cmp		al, 'n'
	je		goodByeProc
	call	CrLf
	displayString OFFSET invalid
	call	 CrLf
	jmp		invalidLoop
		
	goodByeProc:
	call	CrLf
	push	OFFSET goodbye
	call	sayGoodbye

	exit											; exit to operating system

main ENDP

;************************************************************************
;***introduction***
; parameters: &welcome, &author, &intro_1, &intro_2
; registers used: n/a
; returns: n/a
; description: Shows intro strings to user
;************************************************************************
introduction PROC
	push	ebp
	mov		ebp, esp
	displayString	[ebp+20]
	call	CrLf
	displayString	[ebp+16]
	call	CrLf
	displayString	[ebp+12]
	call	CrLf
	displayString	[ebp+8]
	call	CrLf

	pop		ebp
	ret		16
	
introduction ENDP

;**************************************************************************
;***getRandNums***
; parameters: &n, &r
; registers used: EAX, ESI
; returns: n=random int [3-12], r=random int [1-n]
; description: Generates two random ints (n and r) to calculate combination equ.  
;**************************************************************************
getRandNums PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		esi, [ebp+12]						;Get "n" first

	getN:
	mov		eax,HI								;Random number sequence from lecture 7
	sub		eax,LO								;rand = (hi - lo) + 1 to get high end
	inc		eax		
	call	RandomRange
	add		eax,LO
	mov	  [esi], eax							;Move random num into address of "n"

	getR:
	mov		eax, [esi]							;value of "n" becomes max range of r
	mov		esi, [ebp+8]
	sub		eax, 1
	inc		eax
	call	RandomRange
	add		eax, 1
	mov	  [esi], eax


	popad
	pop		ebp
	ret		8

getRandNums ENDP

;************************************************************************
;***combinations***
; parameters: &solution, n, &nFac, r, &rFac, &divisor, &solution
; registers used: EAX, EBX, ESI
; returns: solution = solution of combination problem
; description: Calls recursive proc 'factorial' to generate solution to combinations problem
;**************************************************************************
combinations PROC
	push	ebp
	mov		ebp, esp
	pushad

	;Get n!
	mov		eax, [ebp+24]					;Push value of n to stack and call factorial 
	push	eax
	call	factorial
	mov		esi, [ebp+20]					;Set return value to address of nFac
	mov		[esi], eax

	;Get r!
	mov		eax, [ebp+16]					;Push value of r to stack and call factorial
	push	eax
	call	factorial
	mov		esi, [ebp+12]					;Set return value to address of rFac
	mov		[esi], eax
	
	;Get (n-r)!
	mov		eax, [ebp+24]					;n-r
	mov		ebx, [ebp+16]
	sub		eax, ebx		
	push	eax								;Push result to stack and call factorial
	call	factorial

	;r!(n-r)!
	mov		esi, [ebp+12]					;(n-r)! in eax -> set ebx to value of r!
	mov		ebx, [esi]
	mul		ebx								;r!(n-r)!
	mov		esi, [ebp+8]					;Move result to address of "divisor" var
	mov		[esi], eax

	;n!/r!(n-r)!
	mov		esi, [ebp+20]					;Load eax with n!
	mov		eax, [esi]
	mov		esi, [ebp+8]					;Load ebx with r!(n-r)!
	mov		ebx, [esi]
	mov		edx, 0							;Set edx to 0 to catch divisor
	div		ebx
	mov		esi, [ebp+28]					;Set "solution" var value as the quotient 
	mov		[esi], eax

	popad
	pop		ebp
	ret 24
	

combinations ENDP

;************************************************************************
;***factorial***
; parameters: &int
; registers used: EAX, EBX
; returns: eax = factorial of int
; description: Recursively computes factorial of parameter
;**************************************************************************
factorial PROC
	push	ebp
	mov		ebp, esp

	mov		eax, [ebp+8]
	cmp		eax, 0
	ja		callAgain
	mov		eax, 1
	jmp		return

	callAgain:
	dec		eax
	push	eax
	call	factorial

	mov		ebx, [ebp+8]
	mul		ebx


	return:
	pop		ebp
	ret		4
factorial ENDP


;************************************************************************
;***showProblem***
; parameters: &problem, &eleInSet, &eleChoose, &n, &r
; registers used: EAX, ESI
; returns: n/a
; description: Shows user combination problem 
;**************************************************************************
showProblem PROC
	push	ebp
	mov		ebp, esp
	pushad
	displayString	[ebp+24]					;"Problem:"
	call	CrLf

	displayString	[ebp+20]					;"Number of elements in the set:"
	mov		esi, [ebp+12]
	mov		eax, [esi]
	call	WriteDec
	call	CrLf

	displayString	[ebp+16]					;"Number of elements to choose from the set:"
	mov		esi, [ebp+8]
	mov		eax, [esi]
	call	WriteDec
	call	CrLf

	popad
	pop		ebp
	ret		20
showProblem ENDP

;************************************************************************
;***getData***
; parameters: &guessLength, &invalid, &howMany, &guess
; registers used: EAX, ECX, ESI, EDI
; returns: guess = user input as string 
; description: Takes user input as string, validates to ensure only digits entered.
;**************************************************************************
getData PROC
	push	ebp
	mov		ebp, esp
	pushad

	promptInput:
	displayString [ebp+12]
	mov		edx, [ebp+8]						;Pass string buffer to edx
	mov		ecx, MAX_INPUT						;Pass ecx the max number of chars to enter call	ReadString
	call	ReadString
	mov		esi, [ebp+20]
	mov		[esi], eax							;Save length of string to later convert ASCII to int
	mov		ecx, eax							;ReadString loads eax with length of string, pass it to loop counter
	mov		esi, [ebp+8]						;Point esi to start of buffer
	mov		edi, esi
	
	cld
	parseChar:
	lodsb										;Load first byte into al
	cmp		al, '0'								;If it is not an interger then jump to invalid input
	jl		invalidInput		
	cmp		al, '9'
	ja		invalidInput
	stosb										;Save the input if it is a valid num
	loop	parseChar							;Loop to validate next char
	jmp		continue							;jump to continue program once user enters valid value

	invalidInput:
	displayString [ebp+16]
	call	CrLf
	jmp promptInput

	continue:
	popad
	pop		ebp
	ret 12

getData ENDP

;************************************************************************
;***convertInt***
; parameters: &guess, &guessInt, guessLength
; registers used: EAX, EBX, ECX, EDX, ESI, EDI
; returns: guessInt = user input as decimal value
; description: Converts user input (string) to decimal value
;**************************************************************************
convertString PROC
	push	ebp
	mov		ebp, esp
	pushad

	mov		ecx, [ebp+8]						;Load ecx with the length of the string
	mov		esi, [ebp+16]						;Point esi to start of string
	mov		edi, esi							;set edi to esi so we convert string in place
	mov		eax, 0
	

	cld											;Clear direction to traverse string normally
	getDec:
	lodsb	
	sub		al, 48								;Subtract 48 to get decimal value from ascii char
	stosb
	loop	getDec								;Point to next char to convert

	
	mov		esi, [ebp+16]						;Reset string pointers
	add		esi, [ebp+8]						;add length to esi and subtract one so we're pointing to the end of the string
	dec		esi
	mov		edi, esi
	mov		ecx, [ebp+8]						;reload counter with length of string
	
	mov		eax, 0								;clear eax just in case
	mov		ebx, 1								;ebx will hold power of 10
	mov		edx, 0								;clear edx just in case, will be accumulator.
	
	baseTen:
	mov		al, [esi]							;Move first char into al
	push	edx									;Push edx into stack to preserve value during mul operation (since result is stored in eax:edx)
	mul		ebx									;Multiply eax by decimal position (...100, 10, 1)
	pop		edx									;Pop edx after mul and add value of eax
	add		edx, eax
	push	eax									;Mul current value of ebx by 10, requires push of eax and edx to preserve values 
	mov		eax, ebx
	mov		ebx, 10
	push	edx
	mul		ebx
	pop		edx
	mov		ebx, eax							;Restore ebx with new power of 10
	pop		eax
	dec		esi									;Move to the next value in input
	loop	baseTen

	mov		esi, [ebp+12]
	mov		[esi], edx							;Return value of eax into guessInt variable 

	popad
	pop		ebp
	ret		12

convertString ENDP

;************************************************************************
;***showResults***
; parameters: &result_1, &result_2, &result_3, &period, solution, n, r
; registers used: EAX
; returns: n/a
; description: Shows the correct answer to the combination problem
;**************************************************************************
showResults PROC
	push	ebp
	mov		ebp, esp
	pushad

	;Display results
	displayString [ebp+32]							;"There are "
	mov		eax, [ebp+16]							;Print solution
	call	WriteDec
	displayString [ebp+28]							;" combinations of "
	mov		eax, [ebp+8]							;Print r
	call	WriteDec
	displayString [ebp+24]							;" from a set of "
	mov		eax, [ebp+12]							;Print n
	call	WriteDec
	displayString [ebp+20]							;"."
	call	CrLf

	popad
	pop		ebp
	ret 28

showResults ENDP

;************************************************************************
;***compareInput***
; parameters: &practice, &correct, guessInt, solution
; registers used: EAX, EBX
; returns: n/a	
; description: Compares users guess with correct value and lets them know if they were correct!
;**************************************************************************
compareInput PROC
	push	ebp
	mov		ebp, esp
	pushad
	mov		eax, [ebp+8]
	mov		ebx, [ebp+12]
	cmp		eax, ebx
	je		correctStr
	
	displayString [ebp+20]
	jmp		return
	
	correctStr:
	displayString [ebp+16]


		
	return:
	call	CrLf
	popad
	pop		ebp
	ret		16


compareInput ENDP

;************************************************************************
;***sayGoodbye***
; parameters: &goodbye
; registers used: n/a (marco uses EDX)
; returns: n/a
; description: Shows goodbye to the user
;**************************************************************************
sayGoodbye PROC
	push	ebp
	mov		ebp, esp
	
	displayString [ebp+8]
	call	CrLf

	pop		ebp
	ret 4

sayGoodbye ENDP


END main
