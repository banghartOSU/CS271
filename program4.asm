TITLE Composite Number Spreadsheet (program4.asm)

; Author: Thomas Banghart
; Last Modified: 11/7/2019
; OSU email address: banghart@oregonstate.edu
; Course number/section: CS 271
; Project Number:  4              
; Due Date: 11/10/2019
; Description: Composite Number Spreadsheet asks a user how many composite numbers they'd like to see starting from 1. 
;			   Users can choose any value between [1..300]. 

INCLUDE Irvine32.inc

MIN_NUM = 1
MAX_NUM = 300
NUM_IN_ROW = 10

.data
;STRINGS
welcome		BYTE	"Welcome to the Composite Number Spreadsheet",0
author		BYTE	"Programmed by Thomas Banghart",0
desc_1		BYTE	"This program is capable of generating a list of composite numbers.",0
desc_2		BYTE	"Simply let me know how many you would like to see.",0
desc_3		BYTE	"I'll accept orders for up to 300 composites.",0
prompt		BYTE	"How many composites do you want to view? [1 .. 300]: ",0

outOfRange	BYTE	"Out of range. Please try again.",0
thankYou	BYTE	"Thanks for using my program!",0

;INPUT
userNum		DWORD	0
countNum	DWORD	0
currentNum	DWORD	0
compFlag	DWORD	0

;PUNCTUATION 
space		BYTE	" ",0

.code
main PROC										;Since this program is focused on using procedures, main simply calls other procedures
call	introduction							;Call introduction to greet user
call	getUserData								;Prompt the user to input a number
call	showComposites							;Call the procedure that will handle most of the work
call	goodbye									;Call goodbye and leave the user with a message

main ENDP

;************************************************************************
;introduction: Provides info regarding the program (title, author).
;************************************************************************
introduction PROC
	mov		edx, OFFSET welcome					;"Welcome to the Composite Number Spreadsheet"
	call	WriteString
	call	CrLf
	mov		edx, OFFSET author					;"Programmed by Thomas Banghart"
	call	WriteString
	call	CrLf
	mov		edx, OFFSET desc_1					;"This program is capable of generating a list of composite numbers."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET desc_2					;"Simply let me know how many you would like to see."
	call	WriteString
	call	CrLf
	mov		edx, OFFSET	desc_3					;"I'll accept orders for up to 300 composites."
	call	WriteString
	call	CrLf
	ret
introduction ENDP

;************************************************************************
;getUserData: Prompts the user for a number within 1 and 300 (inclusive) 
; this procedure calls "validate" to ensure that the input value is within 
; the allowed range.
;************************************************************************
getUserData PROC
	getNum:
		mov		edx, OFFSET prompt				;"How many composites do you want to view? [1 .. 300]: "
		call	WriteString
		call	ReadInt
		push	eax								;Passing parameters to procedure (not necessary but wanted to try it)
		call	validate						;call validate to ensure that value entered is within range
		pop		eax								;pop value of eax back to the stack since this was called from another procedure
		cmp		userNum, 0						;If validate did not set the userNum variable, ask for another number.
		je		getNum
		ret
getUserData ENDP

;************************************************************************
; validate: Subprocedure of getUserData. Validates if user input was within
; the allowed range ([1 .. 300]) 
;************************************************************************
validate PROC
	push	ebp									;Push base pointer on the stack
	mov		ebp, esp							;Set value of base pointer to ESP
	mov		eax, [ebp + 8]						;Move user input on stack to EAX
	invalid_low:
		cmp		eax, MIN_NUM					;Compare input to minimum allowed
		jl		reprompt						;If less, jump to reprompt
	invalid_high:
		cmp		eax, MAX_NUM					;Compare input to max allowed
		jg		reprompt						;If greater, jump to reprompt
	set_userNum:
		mov		userNum, eax					;If within bounds, set input into userNum
		pop		ebp								;Pop base pointer from stack and return
		ret
	reprompt: 
		mov		edx, OFFSET outOfRange			;Show user "Out of range" message
		call	WriteString	
		call	CrLf
		pop		ebp								;Pop base pointer from stack and return
		ret
validate ENDP

;************************************************************************
; showComposites: prints composite values and holds the loop counter for the 
; number of that has been printed.
;************************************************************************
showComposites PROC
	mov		ecx, userNum						;Set loop counter to user input
	checkComposite:								;Start checking (starting from 1 to n) if a number is composite 
		inc		currentNum						;Initailly this is 0, so start with 1
		call	isComposite						;call to isComposite to see if currentNum is composite 
		cmp		compFlag, 1						;If isComposite sets flag, then jump to printNum
		je		printNum						
		inc		ecx								;Else, add one back to loop counter (as it was not composite) and start loop again
		jmp		continueLoop
	printNum:
		mov		eax, currentNum					;print currentNum
		call	WriteDec					
		inc		countNum						;add one to number count (and call checkRowNum - if more than 10 move to new line)
		call	checkRowNum
	continueLoop:
	loop	checkComposite
	
	call	CrLf
	ret
showComposites ENDP

;************************************************************************
; isComposite: Subprocedure of showComposites. Checks if a value is composite 
; and sets compFlag value to 1 if it is composite
;************************************************************************
isComposite PROC
	mov		ebx, currentNum					 ;Set ebx equal to currentNum
	divCheck:
		mov		compFlag, 0					;reset compFlag
		mov		eax, currentNum				;mov currentNum into eax
		mov		edx, 0						;set edx to 0 to make room for remainder
		dec		ebx							;set ebx originally to one less than eax, then ebx = (eax -n)
		jz		return						;if decrementing ebx makes it 0, then simply return 
		div		ebx							;divide 
		cmp		edx, 0						;check for remainder, if there is none, set flag.
		je		setFlag			
		jmp		divCheck
	setFlag:
		cmp		ebx, 1						;check for false positive if ebx was 1 and return (non-composite)
		je		return						
		mov		compFlag, 1					;Else, set flag and return
	return:
		ret
isComposite ENDP

;************************************************************************
; checkRowNum: Subprocedure of showComposite. Responsible for line breaks after 10 
; numbers have been printed.
;************************************************************************
checkRowNum PROC
	cmp		countNum, NUM_IN_ROW			;NUM_IN_ROW set to 10
	je		lineBreak						;if the number of printed nums is 10, make a new line
	mov		edx,OFFSET space				;else, print a space.
	call	WriteString
	jmp		return
	lineBreak:
		call	CrLf						;Make new line
		mov		countNum, 0					;reset counter
	return:
		ret
checkRowNum ENDP

;************************************************************************
; goodBye: Give the user a farewell message and exit the program
;************************************************************************
goodbye PROC
	mov		edx, OFFSET thankYou			
	call	WriteString
	exit	; exit to operating system
goodbye ENDP






END main
