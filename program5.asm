TITLE  Sorting Random Integers   (program5.asm)

; Author: Thomas Banghart
; Last Modified: 11/18/2019
; OSU email address: banghart@oregonstate.edu
; Course number/section: CS271
; Project Number: 5                 Due Date: 11/24/2019 
; Description: This program asks the user for a number between 15 and 200 and displays a random 
;			   array of n elements within [100 - 999]. It then sorts the array in descending order 
;			   and shows the user the sorted array and its median value.

INCLUDE Irvine32.inc

MIN = 15
MAX = 200
LO  = 100
HI  = 999

.data
;PROMPT STRINGS
progTitle		BYTE	"Sorting Random Integers",0
author			BYTE	"Programmed by Thomas Banghart",0
prompt1			BYTE	"This program generates random numbers in the range [100 .. 999],",0
prompt2			BYTE	"displays the original list, sorts the list, and calculates the",0
prompt3			BYTE	"median value. Finally, it displays the list sorted in descending order.",0

;GET DATA PROMPT
getDataPrompt	BYTE	"How many numbers should be generated? [15 .. 200]: ",0

;ERROR STRING
errorStr		BYTE	"Invalid input",0

;RESULT STRINGS
randomDisplay	BYTE	"The unsorted random numbers:",0
medianResult	BYTE	"The median is ",0
sortedDisplay	BYTE	"The sorted list:",0

;PUNCTUATION
period			BYTE	".",0
space			BYTE	"	",0

;GOODBYE
goodbye			BYTE	"Thanks for using my program!",0

;USER ENTRY
request			DWORD	?

;ARRAY
list			DWORD	MAX	DUP(?)

.code
main PROC
	call	Randomize							;To ensure that each random sequence is unique (Irvine proc)
	;introduction()
	call	introduction						

	;getData(&request)						
	push	OFFSET request							;Push request var address on stack
	call	getData
	
	;fillArray(&list, request)
	push	OFFSET list								;Push address of array on the stack
	push	request									;Push request by value on the stack
	call	fillArray
	
	;displayList(&list, request, &randomDisplay)
	push	OFFSET list								;Push address of array on stack
	push	request									;Push request as counter on stack
	push	OFFSET randomDisplay					;Push title string on stack
	call	displayList
	

	;sortList(&list, request)
	push	OFFSET list
	push	request
	call	sortList

	;displayMedian(&list, request)
	push	OFFSET list
	push	request
	call	displayMedian 

	;displayList(&list, request, &randomDisplay)
	push	OFFSET list								;Push address of array on stack
	push	request									;Push request as counter on stack
	push	OFFSET sortedDisplay					;Push title string on stack
	call	displayList



	call	goodbyeProc


	exit											; exit to operating system

main ENDP

;************************************************************************
;***introduction***
; parameters: n/a
; registers used: edx
; returns: n/a -- displays intro strings 
; This procedure greets the user and provides instructions for next steps.
;************************************************************************
introduction PROC
	mov		edx, OFFSET progTitle
	call	WriteString
	call	CrLf
	mov		edx, OFFSET	author
	call	WriteString
	call	CrLf
	mov		edx, OFFSET prompt1
	call	WriteString
	call	CrLf
	mov		edx, OFFSET prompt2
	call	WriteString
	call	CrLf
	mov		edx, OFFSET prompt3
	call	WriteString
	call	CrLf
	ret		
introduction ENDP

;************************************************************************
;***getData***
; parameters: &int (request)
; registers used: eax, ebx, edx
; returns: request = user input
; Prompts user for a number within [15 - 200]. Validates input until 
; user enters a valid number. 
;************************************************************************
getData PROC
	push	ebp
	mov		ebp, esp
	push	ebx									;Preserve the value of ebx in case it held anything prior to the call
	mov		ebx, [ebp + 8]						;Access address of requests var on the stack and move it to ebx
promptForData:
	mov		edx, OFFSET getDataPrompt
	call	WriteString
	call	ReadInt
	cmp		eax, MIN
	jl		invalid
	cmp		eax, MAX
	jg		invalid
	jmp		return

invalid:
	mov		edx, OFFSET errorStr
	call	WriteString
	call	CrLf
	jmp		promptForData

return:
	call	CrLf
	mov	[ebx], eax								;Assign the offset of ebx to the user input
	pop	ebx										;Reset ebx
	pop	ebp										;Clean up stack
	ret 4										;Return and remove offset param from stack
getData ENDP

;************************************************************************
;***fillArray***
; parameters: int(request), &array(list)
; registers used: eax, ecx, edx, esi
; returns: contents of array are filled with random values [100 - 999]
; Fills an array with random ints within the range [100 - 999]
; ATTN: THIS USES STARTER CODE FROM OSUs LECTURES
;************************************************************************
fillArray PROC
	push	ebp
	mov		ebp,esp
	mov		esi, [ebp+12]						;esi@list
	mov		ecx, [ebp+8]						;Loop counter = request
	mov		edx, 0								;edx = array pointer
getRandom:
	mov		eax,HI								;Random number sequence from lecture 7
	sub		eax,LO								;rand = (hi - lo) + 1 to get high end
	inc		eax		
	call	RandomRange
	add		eax,LO

	mov		[esi+edx], eax						;Move random int into array index
	add		edx,4								;Point to next array element
	loop	getRandom							;Loop again
continue:
	pop		ebp
	ret		8

fillArray ENDP



;************************************************************************
; ***sortList***
; parameters: &array(list), int(request)
; registers used:eax, ebx, ecx, edx, esi
; returns: array sorted in dec. order that was 
; Uses selection sort to sort array in descending order (i.e. largest to smallest)
; Uses helper procedure 'exchange' to swap two positions
;************************************************************************
sortList PROC 
	push	ebp
	mov		ebp, esp
	pushad
	mov		esi, [ebp+12]						;esi@list
	mov		ecx, [ebp+8]						;ecx = num of elements
	dec		ecx									;-1 for outer loop
outerLoop:				
	mov		eax, [esi]							;get current outer loop value
	mov		edx, esi							;preserve array index of outer loop 
	push	ecx									;push ecx to stack to preserve value of outer loop counter

	innerLoop:		
		mov		ebx, [esi+4]					;Load "j" in ebx
		mov		eax, [edx]						;Reset eax to point at outer loop value
		cmp		eax, ebx						;comapre "i" to "j"
		jge		continue						;if i > j then no need to change order
	doSwap:									    ;else we need to swap positions
		add		esi,4							;persist esi as next element for call to exchange
		push	esi								;add "j" to the stack
		push	edx								;add "i" to the stack
		call	exchange
		sub		esi, 4
	continue:
		add		esi,4
		loop	innerLoop
	;Back to outer loop
	pop		ecx
	mov		esi, edx
	add		esi,4
	loop	outerLoop

	return:
		popad
		pop	ebp
		ret	8
sortList ENDP


;************************************************************************
;***exchange***  
; parameters: &array[i], &array[j]
; registers used: eax, ebx, ecx, edx
; returns: value &array[i] is swaped with value &array[j] and vice versa
; Swaps the value of elements within an array
;************************************************************************
exchange PROC
	push	ebp
    mov		ebp, esp
	pushad
    
	mov		eax, [ebp + 12]						;address of first element
	mov		edx, [eax]							;edx has value @i
	
	mov	    ebx, [ebp + 8]					    ;address of second element
	mov		ecx, [ebx]							;ecx has value @j
	
	mov		[eax], ecx							;load address @i with value @j								
	mov		[ebx], edx							;load address @j with value @i
	  
		
    popad										;restore registers
    pop		ebp
    ret		8


exchange ENDP


;************************************************************************
;***displayMedian*** 
; parameters &array, int(request)
; registers used: eax, ebx, edx, esi
; returns: determines and displays the median of the sortred array
; Calculates and displays the median value of a sorted array
; Takes the cielinged average of the middle elements if there is an 
; even number of elements.
;************************************************************************
displayMedian PROC
	push	ebp
	mov		ebp,esp
	pushad

	mov		edx, OFFSET medianResult
	call	WriteString
	mov		esi, [ebp+12]						;Point esi at list[0]
evenOrOdd:
	mov		eax, [ebp+8]						;Number of elements									
	mov		edx, 0								;set edx to catch remainder
	mov		ebx, 2
	div		ebx
	mov		edi, edx							;Use edi as a partity flag for later
calcMiddle:
	mov		ebx, 4
	mul		ebx									;Multiply quotient from div operation by four 
	add		esi, eax							;Increment the array pointer by half
	mov		eax, [esi]							;Load eax with the value @esi
	cmp		edi, 0								;if the number is even from above div operation we'll need to take the average of the middle nums
	je		getAverage
	jmp		return

getAverage:
	mov		ebx, [esi-4]
	add		eax, ebx
	mov		ebx, 2
	mov		edx, 0
	div		ebx

return:
	call	WriteDec
	mov		edx, OFFSET period
	call	WriteString
	call	CrLf
	popad
	pop		ebp
	ret		12
displayMedian ENDP

;************************************************************************
;***displayList***  
; parameters: &array(list), int(request) &string(title)
; registers used: ebx, ecx, esi
; returns: n/a -- displays array contents
; Iterates through an array of integers and displays the contents of each element
;************************************************************************
displayList PROC
	push	ebp
	mov		ebp,esp											
	mov		edx, [ebp+8]						;Load edx with title string
	call	WriteString
	call	CrLf
	mov		esi, [ebp+16]						;esi@list
	mov		ecx, [ebp+12]						;Loop counter = request
	mov		ebx, 0								;ebx = num counter
printArray:
	mov		eax, [esi]							;get current element
	call	WriteDec
	add		esi, 4								;point to next element
	inc		ebx									;add one to num counter
	cmp		ebx, 10								;check for 10 printed nums
	je		breakLine							;if 10 nums printed jump to new line
	mov		edx, OFFSET space					;if no jump, print space
	call	WriteString				
	jmp		continueLoop						;if < 10 nums printed continue loop
breakLine:
	call	CrLf
	mov		ebx, 0
continueLoop:
	loop	printArray
endPrint:
	call	CrLf
	pop		ebp									;restore stack and return
	ret		12
displayList ENDP


;************************************************************************
; ***goodbye***
; parameters: n/a
; parameters used: edx
; Shows the user an exit message and returns to main which exits to OS
;************************************************************************
goodbyeProc PROC
	mov		edx, OFFSET goodbye
	call	WriteString
	ret
goodbyeProc ENDP
END main
