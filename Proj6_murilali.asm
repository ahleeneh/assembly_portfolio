TITLE Strings and Macros     (Proj6_murilali.asm)

; Author: Aline Murillo
; Last Modified: 4-December-2022
; OSU email address: murilali@oregonstate.edu
; Course number/section:   CS271 Section 403
; Project Number: 6               Due Date: 4-December-2022
; Description: Introduces and describes the program to the user. Prompts the
;     user to enter 10 signed integers that are interpreted as strings. 
;     Validates that the user's input starts with the characters +, -, or 
;     integers; and that the following characters (if any) are also integers
;     that produce an integer small enough to fit inside a 32-bit register.
;     Displays a list of the 10 integers entered and the sum and truncated
;     average of the numbers entered. Displays a goodbye message.

INCLUDE Irvine32.inc

; *****************************************************************************
; Name: mGetString
; 
; Displays a prompt and gets the user's keyboard input into a memory location.
;
; Preconditions: prompt & enteredString are type BYTE. numOfBytesRead is DWORD.
; Postconditions: all 8 32-bit general-purpose registers are restored.
; Receives: 
;     prompt = address of a prompt (to be displayed)
;     enteredString = address of user's keyboard input (to be stored)
;     numOfBytesRead = address of number of bytes read (to be stored)
; Returns: prints a message to the console window and stores the user's input
;     and number of bytes read into the specified memory locations.
; *****************************************************************************
mGetString MACRO prompt, enteredString, numOfBytesRead
	PUSHAD
	MOV		EDX, prompt
	CALL	WriteString
	MOV		EDX, enteredString
	MOV		ECX, STRINGSIZE             ; length of input string can accomodate
	CALL	ReadString
	MOV		EDI, numOfBytesRead
	MOV		[EDI], EAX
	POPAD
ENDM

; *****************************************************************************
; Name: mDisplayString
; 
; Displays a string stored in a specified memory location.
;
; Preconditions: string is a BYTE string.
; Postconditions: EDX restored.
; Receives: 
;     string = address of a string (to be displayed)
; Returns: Prints a string to the console window.
; *****************************************************************************
mDisplayString MACRO string
	PUSH	EDX
	MOV		EDX, string
	CALL	WriteString
	POP		EDX
ENDM

	ARRAYSIZE = 10
	STRINGSIZE = 25			           ; buffer size for user's keyboard input
	BITS_IN_DWORD = 32

.data
	greeting		BYTE	"Welcome to Strings and Macros by Aline Murillo!",13,10,13,10,0
	instruction1	BYTE	"This program will:",13,10,"~ Ask you to enter ",0
	instruction2	BYTE	" signed integers that can fit into a ",0
	instruction3	BYTE	"-bit register.",13,10,"~ Display a list of integers entered.",13,10,
							"~ Display the sum of the integers.",13,10,
							"~ Display the truncated average of the integers.",13,10,13,10,0
	promptUser		BYTE	"Enter a signed integer: ",0
	errorMsg		BYTE	196,196,196," ERROR: The number entered was not a valid integer ",
							"or was too big. Please try again.",13,10,0
	listMsg			BYTE	13,10,"The numbers you entered are:",13,10,0
	sumMsg			BYTE	13,10,"The sum of these numbers is: ",0
	avgMsg			BYTE	13,10,"The truncated average is: ",0
	goodbye			BYTE	13,10,13,10,"Thanks for using Strings and Macros! Toodles!",13,10,0
	comma			BYTE	", ",0
	stringInput		BYTE	STRINGSIZE DUP(?)
	convertedInt	BYTE	STRINGSIZE DUP(?)
	bytesRead		DWORD	?
	convertedString SDWORD	?
	intArray		SDWORD	ARRAYSIZE DUP(?)


.code
main PROC

	PUSH	BITS_IN_DWORD		
	PUSH	ARRAYSIZE			
	PUSH	OFFSET convertedInt	
	PUSH	OFFSET greeting		
	PUSH	OFFSET instruction1	
	PUSH	OFFSET instruction2	
	PUSH	OFFSET instruction3	
	CALL	introduction

	; initialize counter and source register for loop
	MOV		ECX, ARRAYSIZE
	MOV		ESI, OFFSET intArray
_fillArray: 
	; loop to fill an array
	PUSH	OFFSET convertedString
	PUSH	OFFSET promptUser
	PUSH	OFFSET stringInput
	PUSH	OFFSET bytesRead
	PUSH	OFFSET errorMsg
	PUSH	ESI
	CALL	ReadVal
	ADD		ESI, 4
	LOOP	_fillArray

	PUSH	ARRAYSIZE			
	PUSH	OFFSET intArray		
	PUSH	OFFSET convertedInt 
	PUSH	OFFSET comma       
	PUSH	OFFSET listMsg     
	CALL	displayArray

	PUSH	ARRAYSIZE			
	PUSH	OFFSET intArray		
	PUSH	OFFSET convertedInt 
	PUSH	OFFSET avgMsg		
	PUSH	OFFSET sumMsg		
	CALL	statisticsCalculator

	PUSH	OFFSET goodbye
	CALL	farewell

	Invoke ExitProcess,0	; exit to operating system
main ENDP


; *****************************************************************************
; Name: introduction
;
; Displays a greeting and description to the user.
;
; Preconditions: the greeting, instructions, and convertedInt are BYTE strings.
; Postconditions: None. EDX restored with mDisplayString macro.
; Receives:
;     [EBP+32] = BITS_IN_DWORD constant
;     [EBP+28] = ARRAYSIZE constant
;     [EBP+24] = address of convertedInt
;     [EBP+20] = address of greeting
;     [EBP+16] = address of instruction1
;     [EBP+12] = address of instruction2
;     [EBP+8] = address of instruction3
; Returns: prints a greeting and description to the console window.
; *****************************************************************************
introduction PROC
	PUSH	EBP
	MOV		EBP, ESP

	; displays the greeting and instruction1
	mDisplayString [EBP+20]   
	mDisplayString [EBP+16]   

	; displays the number '10' = ARRAYSIZE
	PUSH	[EBP+28]
	PUSH	[EBP+24]
	CALL	writeVal

	; displays instruction2
	mDisplayString [EBP+12]  

	; displays the number '32' = BITS_IN_DWORD
	PUSH	[EBP+32]
	PUSH	[EBP+24]
	CALL	writeVal

	; displays instruction3
	mDisplayString [EBP+8]  

	POP		EBP
	RET		28
introduction ENDP


; *****************************************************************************
; Name: readVal
;
; Prompts the user to enter a signed integer small enough to bit in a 32-bit
;     sized register that is entered as a string.
; Converts the entered string into an integer and adds this value to intArray.
;
; Preconditions: promptUser, and errorMsg are BYTE strings; convertedString 
;     is type SDWORD; bytesRead is type DWORD; and stringInput is a BYTE array.
; Postconditions: all 8 32-bit general-purpose registers are restored.
; Receives:
;	  [EBP+28] = address of convertedString
;     [EBP+24] = address of promptUser
;     [EBP+20] = address of stringInput
;     [EBP+16] = address of bytesRead
;     [EBP+12] = address of errorMsg
;     [EBP+8] = ESI (address of intArray)
; Returns: retrieves an integer input by the user as a string, converts the
;     string into an integer, and stores this integer into intArray.
; *****************************************************************************
readVal PROC
	LOCAL	signBool:BYTE
	PUSHAD
	
	; -------------------------------------------------------------------------
	; Prompts the user to enter a signed integer. 
	; Initializes counter to number of bytes read and sets the source register
	; to the address of the user's input. 
 	; -------------------------------------------------------------------------
_tryAgain:
	mGetString [EBP+24], [EBP+20], [EBP+16]	      ; "Enter a signed integer: "
	MOV		signBool, 0
	MOV		EAX, [EBP+16]	
	MOV		ECX, [EAX]	         ; ECX = bytesRead
	XOR		EAX, EAX
	MOV		ESI, [EBP+20]

	; -------------------------------------------------------------------------
	; Converts the string of ASCII digits to its numerical value representation
	; (SDWORD) and validates that the user's input is a valid number.
	; Uses the formula numInt = 10 * numInt + (numChar - 48)
	; -------------------------------------------------------------------------
_convertString:
	; 1st step in conversion process (10 * numInt) = EBX
	MOV		EBX, 10
	MUL		EBX
	JO		_error
	MOV		EBX, EAX			 ; EBX = (10 * numInt)
	
	; resets EAX to load numChar into AL and determine if on first character
	XOR		EAX, EAX
	LODSB
	MOV		EDX, [EBP+16]
	CMP		ECX, [EDX]           ; if ECX = bytesRead, first pass through loop
	JZ		_analyzeFirstChar

	; validates if the current character is an integer, 0 <= character <= 9
	CMP		AL, 48				 ; 48 (ASCII) = 0 (decimal)
	JL		_error
	CMP		AL, 57				 ; 57 (ASCII) = 9 (decimal)
	JG		_error

_convertStringContinued:
	; determines if local variable signBool is set
	CMP		signBool, 1			
	JE		_convertStringNeg	

	; if local variable signBool is clear, perform data validation on (+) value
	SUB		EAX, 48
	ADD		EAX, EBX
	JO		_error
	JS		_error
	JMP		_determineEndLoop

_convertStringNeg:
	; if local variable signBool is set, perform 2nd step in conversion process
	SUB		EAX, 48					; (numChar - 48) = EAX
	ADD		EAX, EBX				; EBX (10 * numInt) + EAX = EAX

_determineEndLoop:
	; determines if the loop should continue or terminate
	LOOP	_convertString

	; -------------------------------------------------------------------------
	; Determines if additional data validation should be performed if the 
	; original integer was negative. EAX holds the current converted integer.
	; -------------------------------------------------------------------------
	CMP		signBool, 1
	JNE		_determineIfStore

	; if the original integer is (-)
	CMP		EAX, 0						
	JNS		_determineIfStore			; if EAX is < 2^31, skip extra steps
	JO		_error						; if EAX is > 2^31, raise error

	; if the current converted integer is already (-)
	MOV		EBX, EAX
	DEC		EBX	
	JS		_error			            ; raise error if EAX < -2^31 - 1

	; -------------------------------------------------------------------------
	; Store the converted string-to-integer into the variable convertedString.
	; Determine if the first character of the original string input is (-). 
	; If so, get the converted string-to-integer's two's complement.
	; -------------------------------------------------------------------------
_determineIfStore:
	MOV		EDX, [EBP+28]
	MOV		[EDX], EAX			 ; store final integer into convertedString

	; checks if first character is (-)
	CMP		signBool, 1
	JNE		_addToArray			 ; if (+) integer, data validation completed
	
	; if the local variable signBool is set, perform extra data validation
	MOV		EAX, [EDX]
	CMP		EAX, 0
	JS		_storeNeg
	NEG		EAX					 ; if current value (+), get 2's complement

_storeNeg:
	; if current value is already (-), skip getting 2's complement
	JO		_error
	MOV		[EDX], EAX			 ; store (-) final integer into convertedString
	JMP		_addToArray

	; -------------------------------------------------------------------------
	; Validates the first character in the entered string and raises an error
	;     if the user enters non-digits other than +, -, or 0 <= x <= 9.
	; -------------------------------------------------------------------------
_analyzeFirstChar:
	; determine if the first character is either +, -, or 0 <= integer <= 9
	CMP		ECX, 20			; if bytesRead > 18
	JA		_error
	CMP		AL, 43			; +
	JE		_firstCharSign	
	CMP		AL, 45			; -
	JE		_firstCharNeg 
	CMP		AL, 48			; 0
	JL		_error
	CMP		AL, 57			; 9
	JG		_error
	JMP		_convertStringContinued

_firstCharNeg:
	; sets signBool if the first character was found to be negative
	MOV		signBool, 1

_firstCharSign:
	; checks if the stringInput is *only* the string +/-
	CMP		ECX, 1
	JE		_error

	; resets EAX so the first step (10 * numInt) = 0
	XOR		EAX, EAX
	JMP		_determineEndLoop

_error:
	; -------------------------------------------------------------------------
	; Displays an error message stating the user should try again. 
	; -------------------------------------------------------------------------
	mDisplayString [EBP+12]
	JMP			_tryAgain

_addToArray:
	; -------------------------------------------------------------------------
	; Stores the converted string-to-integer value into the array intArray.
	; -------------------------------------------------------------------------
	MOV		ESI, [EBP+28]
	MOV		EAX, [ESI]
	MOV		EDI, [EBP+8]
	STOSD	

	POPAD
	RET		24
readVal ENDP


; *****************************************************************************
; Name: writeVal
;
; Converts and displays a numeric SDWORD value into a string of ASCII digits. 
;
; Preconditions: the numeric value is type SDWORD; convertedInt is BYTE string.
; Postconditions: all 8 32-bit general-purpose registers are restored.
; Receives:
;     [EBP+12] = value of numeric SDWORD value that is to be converted
;     [EBP+8] = address of convertedInt
; Returns: converts an integer into a string and prints the string to the 
;     console window.
; *****************************************************************************
writeVal PROC
	; saves registers and creates stack-frame pointer
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; sets destination and accumulator register for procedure
	MOV		EDI, [EBP+8]
	MOV		EAX, [EBP+12]

	; determines if the value to be converted is negative
	CMP		EAX, 0
	JNS		_skipNegation
	NEG		EAX
	
_skipNegation:
	; initializes the dividend to 10
	MOV		EBX, 10
	XOR		ECX, ECX

_pushValues:
	; divides the integer by 10 and pushes the remainder to the stack
	XOR		EDX, EDX
	DIV		EBX
	PUSH	EDX
	INC		ECX
	CMP		EAX, 0
	JNZ		_pushValues

_checkSign:
	; pushes the (-) sign onto the stack if the original value was negative
	MOV		EAX, [EBP+12]
	CMP		EAX, 0				 ; EAX = original integer value to be converted
	JNS		_popValues
	PUSH	-3
	INC		ECX

_popValues:
	; pops the remainders and adds 48 to get an integer-string character
	POP		EDX
	ADD		EDX, 48
	MOV		EAX, EDX
	STOSB							; stores the remainders into convertedInt
	LOOP	_popValues
	XOR		EAX, EAX				
	STOSB							; add null terminator

	; displays string after the integer has been converted into a string
	mDisplayString [EBP+8]

	POPAD
	POP		EBP
	RET		8
writeVal ENDP


; *****************************************************************************
; Name: displayArray
;
; Displays a title message to display a list of integers and iterates through
;     the array intArray and displays each integer as a string.
;
; Preconditions: intArray is a type SDWORD; convertedInt, comma, and listMsg
;     are BYTE strings.
; Postconditions: all 8 32-bit general-purpose registers are restored.
; Receives:
;     [EBP+24] = ARRAYSIZE constant
;     [EBP+20] = address of intArray
;     [EBP+16] = address of convertedInt
;     [EBP+12] = address of comma
;     [EBP+8] = address of listMsg
; Returns: prints a message stating "The numbers you entered are: " followed
;     by the integers of intArray.
; *****************************************************************************
displayArray PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; prints "The numbers you entered are: "
	mDisplayString [EBP+8]

	; initialize counter and source register for _displayLoop
	MOV		ECX, [EBP+24] 
	MOV		ESI, [EBP+20]
	
_displayLoop:
	; iterates through intArray and prints each integer as strings
	XOR		EAX, EAX
	LODSD
	PUSH	EAX
	PUSH	[EBP+16]
	CALL	writeVal

	; determine if end of array, if not, insert a ", " to separate the integers
	CMP		ECX, 1
	JE		_return
	mDisplayString [EBP+12]
	LOOP	_displayLoop

_return:
	POPAD
	POP		EBP
	RET		20
displayArray ENDP


; *****************************************************************************
; Name: statisticsCalculator
;
; Calculates the sum and truncated average of someArray and displays the 
;     sum and truncated average integers as strings. 
;
; Preconditions: intArray is type SDWORD; convertedInt, avgMsg, and sumMsg are
;     BYTE strings.
; Postconditions: all 8 32-bit general-purpose registers are restored.
;     [EBP+24]: ARRAYSIZE constant
;     [EBP+20]: address of intArray
;     [EBP+16]: address of convertedInt
;     [EBP+12]: address of avgMsg
;     [EBP+8]: address of sumMsg
; Returns: prints a message stating, "The sum of these numbers is: " followed
;     by the sum of integers of intArray; and prints a message stating, "The
;     truncated average is: " followed by the truncated average of intArray.
; *****************************************************************************
statisticsCalculator PROC
	PUSH	EBP
	MOV		EBP, ESP
	PUSHAD

	; initializes counter and source register to tabulate sum for _sumLoop
	MOV		ECX, [EBP+24]
	MOV		ESI, [EBP+20]
	XOR		EBX, EBX	         ; EBX = sum
	
_sumLoop:
	; iterates through intArray to calculate the sum
	XOR		EAX, EAX
	LODSD
	ADD		EBX, EAX
	LOOP	_sumLoop

	; displays sum integer as string
	mDisplayString [EBP+8]
	PUSH	EBX
	PUSH	[EBP+16]
	CALL	writeVal

	; calculates the truncated average of intArray
	mDisplayString [EBP+12]
	XOR		EDX, EDX
	MOV		EAX, EBX
	MOV		EBX, [EBP+24]
	CDQ
	IDIV	EBX
	
	; displays the truncated average integer as string
	PUSH	EAX                  ; EAX = quotient w/o remainder = truncated avg
	PUSH	[EBP+16]
	CALL	writeVal
	
	POPAD
	POP		EBP
	RET		20
statisticsCalculator ENDP


; *****************************************************************************
; Name: farewell
; 
; Displays a goodbye message to the user thanking them for using the program.
;
; Preconditions: goodbye is a BYTE string.
; Postconditions: None. EDX restored with mDisplayString macro.
; Receives: 
;     [EBP+8] = address of goodbye
; Returns: Prints a goodbye message to the console window.
; *****************************************************************************
farewell PROC
	PUSH	EBP
	MOV		EBP, ESP
	mDisplayString [EBP+8]	     ; displays goodbye message
	POP		EBP
	RET		4
farewell ENDP

END main
