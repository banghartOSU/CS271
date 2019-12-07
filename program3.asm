TITLE Accumulator Project     (program3.asm)

; Author:					Thomas Banghart
; Last Modified:			10/26/2019
; OSU email address:		banghart@oregonstate.edu
; Course number/section:	CS 271
; Project Number:			#3                
; Due Date:					11/03/2019
;
; Description:				This program asks the user to input negative numbers in the range [-150, -1]. The user can enter as many negative 
;							numbers as they please. If the user enters a non-negative number then the loop is exited and they are shown the
;							sum of the inputed numbers and their rounded average. 

INCLUDE Irvine32.inc
;Define the range as constants
MIN_NUM = -150	
MAX_NUM = -1

.data
;STRINGS
welcomeMsg	BYTE	"Welcome to the Accumulator Project by Thomas Banghart",0
prompt_1	BYTE	"What is your name? ",0
hello		BYTE	"Hello, ",0
prompt_2	BYTE	"Please enter numbers in the range [-150, -1].",0
prompt_3	BYTE	"Enter a non-negative number when you are finished to see results.",0
prompt_4	BYTE	"Enter number: ",0
ignoreNum	BYTE	"Ignored that number! It needs to be in the range [-150, -1].",0
showNum_1	BYTE	"You entered ",0
showNum_2	BYTE	" valid numbers.",0
showSum		BYTE	"The sum of your valid numbers is ",0
showAvg		BYTE	"The rounded average is ",0
goodbye		BYTE	"Thank you for testing my code! It's been a pleasure to meet you, ",0

;EXTRA CREDIT STRINGS
xCredit_1	BYTE	"**EC: This program numbers the lines during user input**",0
xCredit_2	BYTE	"**EC: This program shows the user the range of inputed values**",0
rangeStr	BYTE	"The valid numbers that you entered were in the range ",0

;PUNCTUATION CHARS
lParen		BYTE	"(" ,0
rParen		BYTE	") ",0
lBracket	BYTE	"[" ,0
rBracket	BYTE	"]" ,0
comma		BYTE	", " ,0
period		BYTE	".",0

;USER INPUT 
userName	BYTE	20 DUP(?)

;NUMBER VARS
sum			SDWORD	0
validNum	DWORD	0
entryNum	DWORD	1							;Preset the line number at 1 so that it is ready to display for the first line
minRange	DWORD	?
maxRange	DWORD	?

.code
main PROC
;************************************************************************
; WELCOME: This section greets the user with a welcome message and asks for the user's name
;************************************************************************
welcome:
mov		edx, OFFSET welcomeMsg					;"Welcome to the Accumulator Project by Thomas Banghart"
call	WriteString
call	CrLf
mov		edx, OFFSET xCredit_1					;"**EC: This program numbers the lines during user input**"
call	WriteString
call	CrLf
mov		edx, OFFSET xCredit_2					;"**EC: This program shows the user the range of inputed values**"
call	WriteString
call	CrLf
mov		edx, OFFSET prompt_1					;"What is your name?"
call	WriteString
mov		edx, OFFSET userName					;Pg 645 Irvine - First get variable in edx to hold input
mov		ecx, (SIZEOF userName) - 1				;Pg 645 Irvine - Allocate space for the user input to stay (-1 to not include the enter key I think)
call	ReadString								;Pg 645 Irvine - The lib procedure reads the input and assigns it to ther var in edx
mov		edx, OFFSET hello						;"Hello <userName>"
call	WriteString
mov		edx, OFFSET userName
call	WriteString
call	CrLf

;************************************************************************
; ASK_FOR_NUM: This section asks for the user to input a number beteween -150 and -1 (inclusive). 
; The user can enter a many numbers as they please.
; If the the entered num is less than -150, the input is ignored. If a non-negative number is entered 
; then the program exists the loop.
;************************************************************************
ask_for_num:
mov		edx, OFFSET prompt_2					;"Please enter numbers in the range [-150, -1]."
call	WriteString
call	CrLf
mov		edx, OFFSET prompt_3					;"Enter a non-negative number when you are finished to see results."
mov		ebx, 000
;************************************************************************
; GET_NUM: Continuation of ASK_FOR_NUM. This section controls the data validation and accepting user input logic.
;************************************************************************
get_num:
	mov		edx, OFFSET lParen					;(<entryNum>)
	call	WriteString
	mov		eax, entryNum
	call	WriteDec
	mov		edx, OFFSET rParen
	call	WriteString
	mov		edx, OFFSET prompt_4				;"Enter a number:"
	call	WriteString
	call	ReadInt
	cmp		eax, MIN_NUM						;Compare with -150
	jl		out_of_range						;Show message and prompt user for another input if less than min
	cmp		eax, MAX_NUM						;Compare with -1
	jg		show_results						;If > -1 exit loop and continue program
	cmp		validNum, 0
	je		set_min_range						;If this is the first valid number set it as min, set_min_range will also set max
	cmp		eax, minRange						;If it is not the first valid num, compare with minRange, if smaller make new minRange
	jl		set_min_range
	cmp		eax, maxRange						;If num is larger than current max, make that max
	jg		set_max_range
continue_loop:									;Return point from set_min_range and set_max_range
	inc		validNum							;Increment count of valid nums
	add		sum, eax							;Add the current valid num to what we have
	inc		entryNum							;Add one to entry since this was a valid num
	jmp		get_num

out_of_range:									;Show message to user that the entered number is out of range 
	mov		edx, OFFSET ignoreNum
	call	WriteString
	call	CrLf
	jmp		get_num								;Jump back to get_num again

set_min_range:									;For extra credit: Check to see if current num is less than the current min
	mov		minRange, eax
	cmp		validNum, 0							;Set the min and max of the input range to the same if this is the first valid num
	je		set_max_range						
	jmp		continue_loop						;Jump back to finish the get_num loop


set_max_range:
	mov		maxRange, eax						;Set the maxRange
	jmp		continue_loop						;Jump to return point

;************************************************************************
; SHOW_RESULTS: This shows the user the number of valid numbers they entered as well as the sum and rounded 
; average of those numbers entered.
;************************************************************************			
show_results:
mov		edx, OFFSET showNum_1					;"You entered "
call	WriteString								
mov		eax, validNum							;<validNum>
call	WriteDec
mov		edx, OFFSET showNum_2					;"valid numbers"
call	WriteString
call	CrLf
mov		edx, OFFSET showSum						;"The sum of your valid numbers is "
call	WriteString
mov		eax, sum								;<sum>
call	WriteInt
call	CrLf	

mov		edx, OFFSET showAvg						;"The rounded average is ",
call	WriteString
mov		eax, sum
cdq												;Convert doubleword to quadword -- sign extend EAX into EDX (pg 265)
idiv	validNum								;Quotient of div (no need for remainder since we're "rounding")
call	WriteInt
call	CrLf

mov		edx, OFFSET rangeStr					;"The valid numbers that you entered were in the range [<range>]."
call	WriteString
mov		edx, OFFSET lBracket					;"["
call	WriteString
mov		eax, minRange							;<min>
call	WriteInt
mov		edx, OFFSET comma						;","
call	WriteString
mov		eax, maxRange							;<max>
call	WriteInt	
mov		edx, OFFSET rBracket					;"]"
call	WriteString
mov		edx, OFFSET period						;"."
call	WriteString
call	CrLf
;************************************************************************
; GOODBYE: Tells the user "goodbye" and shows their name again
;************************************************************************	
goodbye_section:
mov		edx, OFFSET goodbye						;"Thank you for testing my code! It's been a pleasure to meet you, "
call	WriteString
mov		edx, OFFSET userName					;<username>
call	WriteString
mov		edx, OFFSET period
call	WriteString								;"."
call	CrLf

exit	; exit to operating system
main ENDP


END main
