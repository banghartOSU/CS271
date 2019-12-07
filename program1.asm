TITLE Elementary Arithmetic     (program1.asm)

; Author:					Thomas Banghart
; Last Modified:			9/28/2019
; OSU email address:		banghart@oregonstate.edu 
; Course number/section:	CS271 - 400
; Project Number:			1            
; Due Date:					October 13, 2019
; Description:				This program prompts the user for 2 numbers and computes the sum, difference, product, quotient, and remainder of those numbers.
;							Additionally, this program validates that the first number entered is larger than the second. Lastly, it outputs the square of 
;							of both numbers.

INCLUDE Irvine32.inc
	
.data
;STRINGS
nameAndTitle	BYTE	"Elementary Arithmetic by Thomas Banghart", 0
instructions	BYTE	"Enter 2 numbers, and I'll show you the sum, difference, product, quotient, and remainder.", 0
exitMessage		BYTE	"The second number must be less than the first!", 0
remainderString	BYTE	" remainder ", 0
prompt1			BYTE	"First number: ", 0
prompt2			BYTE	"Second number: ", 0
goodBye			BYTE	"Impressed? Bye!", 0
extraCredit1	BYTE	"**EC: Program verifies second number less than first.", 0
extraCredit2	BYTE	"**EC: Program calculates the square of both numbers.",  0
squareResult	BYTE	"Square of ", 0

;ARITHMETIC CHARS
equal			BYTE	" = ", 0
sumOp			BYTE	" + ", 0
diffOp			BYTE	" - ", 0
productOp		BYTE	" * ", 0
divOp			BYTE	" / ", 0

;INPUT NUMBERS
num1			DWORD	?
num2			DWORD	?

;OUTPUT VALUES
sum				DWORD	?
difference		DWORD	?
product			DWORD	?
quotient		DWORD	?
remainder		DWORD	?

.code
main PROC
;display name and program title
	mov		edx, OFFSET nameAndTitle		;"Elementary Arithmetic by Thomas Banghart"	
	call	WriteString
	call	CrLf

;***EXTRA CREDIT 1***
	mov		edx, OFFSET	extraCredit1		;"**EC: Program verifies second number less than first.",
	call	WriteString
	call	CrLf
;***EXTRA CREDIT 2***
	mov		edx, OFFSET extraCredit2		;""**EC: Program calculates the square of both numbers."
	call	WriteString
	call	CrLf

;display instructions for the user
	mov		edx, OFFSET	instructions		;"Enter 2 numbers, and I'll show you the sum, difference, product, quotient, and remainder."
	call	WriteString
	call	CrLf

;prompt user to enter two numbers
	;Get num1
	mov		edx, OFFSET prompt1			
	call	WriteString
	call	ReadDec
	mov		num1, eax;
	
	;Get num2
	mov		edx, OFFSET prompt2
	call	WriteString
	call	ReadDec
	mov		num2, eax;

	;Compare input values
	mov		eax, num1
	cmp		eax, num2
	jle		extra_credit_condition			;Jump if num1 <= to num2 (pg 201 in Irvine)
	jmp		calculate						;Else jump to calculation
	
	extra_credit_condition: 
		mov		edx, OFFSET exitMessage		;"The second number must be less than the first!"
		call	WriteString
		call	CrLf
		jmp		skip_to_exit				;Exit to os since condition fails

	
calculate:
;calculate sum, difference, product, quotient and remainder
	;Calculate SUM
	mov		eax, num1
	add		eax, num2
	mov		sum, eax
	;Print Sum;
	mov		eax, num1						;Print num1
	call	WriteDec
	mov		edx, OFFSET sumOp				;Print "+"
	call	WriteString
	mov		eax, num2						;Print num2
	call	WriteDec	
	mov		edx, OFFSET equal				;Print "="
	call	WriteString
	mov		eax, sum						;Print sum
	call	WriteDec
	call	CrLf

	;Calculate DIFFERENCE
	mov		eax, num1
	sub		eax, num2
	mov		difference, eax
	;Print Differece;
	mov		eax, num1						;Print num1
	call	WriteDec
	mov		edx, OFFSET diffOp				;Print "-"
	call	WriteString
	mov		eax, num2						;Print num2
	call	WriteDec	
	mov		edx, OFFSET equal				;Print "="
	call	WriteString
	mov		eax, difference					;Print sum
	call	WriteDec
	call	CrLf

	;Calculate PRODUCT
	mov		eax, num1
	mov		ebx, num2
	call	GetProduct						;Additional procedure to make extra credit easier
	;Print Product;
	mov		eax, num1						;Print num1
	call	WriteDec
	mov		edx, OFFSET productOp			;Print "*"
	call	WriteString
	mov		eax, num2						;Print num2
	call	WriteDec	
	mov		edx, OFFSET equal				;Print "="
	call	WriteString
	mov		eax, product					;Print sum
	call	WriteDec
	call	CrLf

	;Calculate QUOTIENT and REMAINDER
	mov		eax, num1
	cdq										;Convert doubleword to quadword (from div tutorial and pg 265 Irvine) Needed for proper division.
	mov		ebx, num2
	div		ebx
	mov		quotient,  eax
	mov		remainder, edx
	
	;Print Quotient and Remainder
	mov		eax, num1						;Print num1
	call	WriteDec
	mov		edx, OFFSET divOp				;Print "/"
	call	WriteString
	mov		eax, num2						;Print num2
	call	WriteDec	
	mov		edx, OFFSET equal				;Print "="
	call	WriteString
	mov		eax, quotient					;Print quotient
	call	WriteDec
	mov		edx, OFFSET remainderString		;Print "remainder" literal string
	call	WriteString
	mov		eax, remainder					;Print remainder value
	call	WriteDec
	call	CrLf

	;**EXTRA CREDIT ** Calculate Square of each input num 
	mov		eax, num1						;Calculate square of first number and print it using procedure
	mov		ebx, num1
	call	GetProduct
	call	WriteSquare

	mov		eax, num2						;Calculate square of second number and print it using procedure
	mov		ebx, num2
	call	GetProduct
	call	WriteSquare

skip_to_exit:
;display terminating message
	mov		edx, OFFSET goodBye
	call	WriteString

	exit									;exit to operating system
main ENDP

GetProduct PROC								;Additional procedure to get the product of two number (to make extra credit 2 easier)
	mul		ebx
	mov		product, eax
	ret
GetProduct ENDP

WriteSquare PROC							;Prints the squares of each number (to make extra credit 2 easier)
	mov		edx, OFFSET squareResult		;Print "Square of "
	call	WriteString
	mov		eax, ebx						;Load current num in ebx to output
	call	WriteDec
	mov		edx, OFFSET equal				;" = "
	call	WriteString
	mov		eax, product					;Print product
	call	WriteDec
	call	CrLf
	ret
WriteSquare	ENDP

END main
