TITLE Project 6 - String Primitives and Macros     (Proj6_mckeever.asm)

; Author: Rebecca Mckeever
; Last Modified: 03/16/2021
; OSU email address: mckeever@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 03/16/2021
; Description: ***

INCLUDE Irvine32.inc


; ---------------------------------------------------------------
; Name: mGetString
;
; This macro displays a prompt to the user and then read's the
; user's input into a memory variable.
;
; Preconditions: promptStr and buffer are references.
;                bufferSize and numChars are DWORD or immediate.
;
; Receives:
;       promptStr   = address of a string prompt
;       buffer      = address of a string to hold user input
;       bufferSize  = size of string for user input in bytes
;       numChars    = variable to hold number of characters read
; 
; returns:
;       buffer      = string entered by user
;       numChars    = number of characters read
; ---------------------------------------------------------------
mGetString MACRO     promptStr:REQ, buffer:REQ, bufferSize:REQ, numChars:REQ
    PUSH    EAX                             ; save registers
    PUSH    ECX
    PUSH    EDX

    ; display prompt and read user input
    mDisplayString promptStr
    MOV     EDX, buffer
    MOV     ECX, bufferSize
    CALL    ReadString

    ; move input and number of characters read to appropriate memory locations
    MOV     buffer, EDX
    MOV     numChars, EAX

    POP     EDX                             ; restore registers
    POP     ECX
    POP     EAX
ENDM


; ---------------------------------------------------------------
; Name: mDisplayString
;
; This macro prints a string stored in a memory location.
;
; Preconditions: inString is a reference.
;
; Receives:
;       inString = address of a string to display
;
; returns: None
; ---------------------------------------------------------------
mDisplayString MACRO inString:REQ
    PUSH    EDX                             ; save register
    
    MOV     EDX, inString
    CALL    WriteString

    POP     EDX                             ; restore register
ENDM


; (insert constant definitions here)
NUM_COUNT = 10
STR_LEN = 50       ; includes extra bytes to account for user entering multiple leading 0's

.data
    userInput   BYTE    STR_LEN DUP(0)
    intro1      BYTE    "Project 6: Designing low-level I/O procedures by Rebecca Mckeever",
                        13,10,13,10,"Please enter ",0
    intro2      BYTE    " signed decimal integers.",13,10,
                        "Each number must be small enough to fit in a 32 bit register. After ",13,10,
                        "you input the numbers, I will display the numbers entered, their sum, ",
                        13,10,"and the average.",13,10,13,10,0
    prompt      BYTE    "Please enter a signed number: ",0
    errorMsg    BYTE    "ERROR: You did not enter a signed number, or your number was too big. Please try again.",13,10,0
    numsLabel   BYTE    13,10,"You entered the following numbers: ",13,10,0
    sumLabel    BYTE    13,10,"The sum of these numbers is: ",0
    aveLabel    BYTE    13,10,"The rounded average is: ",0
    goodbye     BYTE    13,10,13,10,"Goodbye, thanks for playing!",13,10,0
    commaSp     BYTE    ", ",0
    numberArr   SDWORD  NUM_COUNT DUP(?)

.code
main PROC
    ; set up framing and call intro
    PUSH    OFFSET intro1
    PUSH    OFFSET intro2
    PUSH    NUM_COUNT
    CALL    intro

    ; set up framing and call getIntegers to get integers from user
    PUSH    NUM_COUNT
    PUSH    OFFSET prompt
    PUSH    OFFSET errorMsg
    PUSH    OFFSET userInput
    PUSH    SIZEOF userInput
    PUSH    OFFSET numberArr
    CALL    getIntegers
    
    ; set up framing and call displayResults
    PUSH    OFFSET commaSp
    PUSH    OFFSET numsLabel
    PUSH    OFFSET sumLabel
    PUSH    OFFSET aveLabel
    PUSH    NUM_COUNT
    PUSH    OFFSET numberArr
    CALL    displayResults

    ; set up framing and call showGoodbye
    PUSH    OFFSET goodbye
    CALL    showGoodbye
    
    Invoke ExitProcess,0    ; exit to operating system
main ENDP


; ---------------------------------------------------------------
; Name: intro
;
; This procedure displays the program title and the name of the author,
; then it displays instructions and a description of the program to the user.
;
; Preconditions: None
;
; Postconditions: This strings and numeric value are printed to output.
;
; Receives:
;       [EBP + 4*4] = address of first string to display
;       [EBP + 3*4] = address of second string to display
;       [EBP + 2*4] = numerical value to place between the two strings
;
; Returns: None
; ---------------------------------------------------------------
intro PROC
    PUSH    EBP                             ; save registers
    MOV     EBP, ESP

    ; display first string
    mDisplayString [EBP + 4*4]

    ; display numerical value
    PUSH    [EBP + 2*4]
    CALL    WriteVal

    ; display second string
    mDisplayString [EBP + 3*4]

    MOV     ESP, EBP                        ; restore registers
    POP     EBP
    RET 3*4
intro ENDP


; ---------------------------------------------------------------
; Name: ReadVal
; 
; This procedure reads a numerical value entered by the user
; using the mGetString macro. It converts the string of ascii
; characters into its numerical value. It validates that the number
; is a valid SDWORD value, with no non-numeric characters other than
; a sign at the beginning. If the number is invalid, it discards the
; value, displays an error message, and reprompts.
; 
; Preconditions: The variable to hold the numerical value is SDWORD.
; 
; Postconditions: None
; 
; Receives:
;       [EBP + 6*4] = the address of a string prompt
;       [EBP + 5*4] = the address of a string error message
;       [EBP + 4*4] = the address of a string to hold user input
;       [EBP + 3*4] = size of the string that holds user input
;       [EBP + 2*4] = the address of an SDWORD
;
; Returns: 
;       [EBP + 4*4] = the numerical value entered as a string
;       [EBP + 2*4] = the numerical value entered as an SDWORD
; ---------------------------------------------------------------
ReadVal PROC
    LOCAL   byteCount: DWORD, curChar: DWORD, isNegative: BYTE
    PUSH    EAX                             ; save registers
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX
    PUSH    EDI
    PUSH    ESI

    ; move addresses for the numerical value and the string to EDI/ESI
    MOV     EDI, [EBP + 2*4]
    MOV     ESI, [EBP + 4*4]
    MOV     EBX, 0
    MOV     [EDI], EBX                      ; initialize numerical value to 0

; validation loop for user input
_getInput:
    MOV     isNegative, 0                   ; initialize to "false" (positive)

    ; call mGetString to get user input
    ;           prompt, buffer, buffer size, number of chars
    mGetString [EBP + 6*4], ESI, [EBP + 3*4], byteCount

    ; Move number of characters read to loop counter.
    ; Then, display error and reprompt if no characters entered.
    MOV     ECX, byteCount
    CMP     ECX, 0
    JE      _invalid

    ; get first character of input string into curChar
    CLD
    LODSB
    MOVZX   EAX, AL                         ; clear upper bits of EAX
    MOV     curChar, EAX

    ; check first character for possible sign
    CMP     curChar, '+'
    JE      _checkLength
    CMP     curChar, '-'
    JE      _checkLength

    ; if no sign, process this first character as a numeral
    JMP     _checkNumerals

; ensure that if a sign was entered,
; other characters were entered after it
_checkLength:
    CMP     ECX, 1
    JLE     _invalid

    ; if the sign is negative, set isNegative to true
    ; for either sign, skip to end of loop before reading next character
    CMP     curChar, '-'
    JNE     _endLoop
    MOV     isNegative, 1
    JMP     _endLoop

; loop to process each character of input string
_charLoop:
    ; get next character of input string into curChar
    CLD
    LODSB
    MOVZX   EAX, AL                         ; clear upper bits of EAX
    MOV     curChar, EAX
    JMP _checkNumerals

; repeat loop if more characters to process
_endLoop:
    LOOP    _charLoop
    JMP     _end

; process current character as a numeral
_checkNumerals:
    ; ensure that this character is a valid numeral
    CMP     curChar, '9'
    JG      _invalid
    CMP     curChar, '0'
    JL      _invalid

    ; calculate the value of this character
    SUB     curChar, '0'

    ; if user entered a negative number, negate the value
    CMP     isNegative, 1
    JNE     _continue
    MOV     EAX, -1
    MOV     EDX, 0
    IMUL    EAX, curChar
    MOV     curChar, EAX

; multiply current value accumulated by 10 and
; add value of current character
_continue:
    MOV     EAX, [EDI]                      ; get value accumulated so far
    MOV     EBX, 10
    MOV     EDX, 0

    ; mark input as invalid and reprompt
    ; if either of the following operations results in overflow
    IMUL    EBX
    JO      _invalid
    ADD     EAX, curChar
    JO      _invalid
    MOV     [EDI], EAX
    JMP     _endLoop

; if input was invalid, clear the value accumulated in EDI,
; display error message, and reprompt
_invalid:
    MOV     EBX, 0
    MOV     [EDI], EBX
    mDisplayString [EBP + 5*4]
    JMP     _getInput

_end:
    POP     ESI                             ; restore registers
    POP     EDI
    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    RET     5*4
ReadVal ENDP


; ---------------------------------------------------------------
; Name: WriteVal
; 
; This procedure converts a numerical value to a string of ascii
; characters. It uses the mDisplayString macro to print the ascii
; characters.
; 
; Preconditions: The input contains an SDWORD value.
; 
; Postconditions: The string of ascii characters is printed to output.
; 
; Receives: 
;       [EBP + 2*4] = the value of an SDWORD
;
; Returns: None
; ---------------------------------------------------------------
WriteVal PROC
    LOCAL   outString[12]: BYTE, inString[12]: BYTE, isNegative: BYTE
    PUSH    EDI                                 ; save registers
    PUSH    ESI
    PUSH    EAX
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX

    ; move local strings and input value into registers
    LEA     ESI, outString
    LEA     EDI, inString
    MOV     EBX, [EBP + 2*4]
    MOV     isNegative, 0                       ; defaults to 0 (positive)

    ; save the addresses of the start of the strings
    PUSH    ESI
    PUSH    EDI

    ; fill both local strings with zeros
    MOV     ECX, 12
    MOV     AL, 0
_fillZeros:
    MOV     [ESI], AL
    CLD
    MOVSB
    LOOP    _fillZeros

    ; restore the addresses of the start of the strings
    POP     EDI
    POP     ESI

    ; initialize loop counter and determine next step based
    ; on sign of input value
    MOV     ECX, 0
    CMP     EBX, 0
    JL      _processSign
    JMP     _checkValue

; if value is negative, place negative sign at beginning of both strings
_processSign:
    MOV     isNegative, 1
    MOV     AL, '-'
    MOV     [ESI], AL
    CLD
    MOVSB

    ; process left-most digit into a character
    MOV     EAX, EBX
    MOV     EBX, 10
    CDQ
    IDIV    EBX
    MOV     EBX, EAX
    MOV     EAX, EDX
    NEG     EBX                             ; negate after processing one
    NEG     EAX                             ; digit so remaining calculations
                                            ; do not result in a negative value
    JMP     _storeCharacter

; break out of loop if remaining value is zero
; and not first iteration
_checkValue:
    CMP     EBX, 0
    JNE     _processValue
    CMP     ECX, 0
    JE      _processValue
    JMP     _endLoop

; process remaining value into characters
_processValue:
    MOV     EDX, 0
    MOV     EAX, EBX
    MOV     EBX, 10

    ; Divide by 10 to get value of last digit as the remainder.
    ; Store the result of the division in a register.
    DIV     EBX
    MOV     EBX, EAX
    MOV     EAX, EDX

; determine ascii value and store
_storeCharacter:
    ADD     EAX, '0'
    CLD
    STOSB
    INC     ECX
    JMP     _checkValue

; swap source and destination so that reversed string can be
; copied into string now in destination register; save address of
; beginning of output string.
_endLoop:
    ; null terminate string
    MOV     AL, 0
    CLD
    STOSB
    SUB     EDI, 2                          ; point to last non-null character written

    ; swap source and destination
    XCHG    EDI, ESI
    PUSH    EDI

; copy reversed value into EDI in correct order
_reverseString:
    STD
    LODSB
    CLD
    STOSB
    LOOP   _reverseString

    ; null terminate string
    MOV     AL, 0
    CLD
    STOSB

    ; restore address of beginning of output string; decrement address
    ; for negative values to include minus character
    POP     EDI
    CMP     isNegative, 1
    JNE     _printString
    DEC     EDI

_printString:
    mDisplayString EDI

    POP     EDX                                 ; restore registers
    POP     ECX
    POP     EBX
    POP     EAX
    POP     ESI
    POP     EDI
    RET     4
WriteVal ENDP


; ---------------------------------------------------------------
; Name: getIntegers
; 
; This procedure uses ReadVal to get a specified number of integers
; from the user and stores the integers in an array.
; 
; Preconditions: The array is type SDWORD.
; 
; Postconditions: None
; 
; Receives: 
;       [EBP + 7*4] = number of values to get from user
;       [EBP + 6*4] = the address of a string prompt
;       [EBP + 5*4] = the address of a string error message
;       [EBP + 4*4] = the address of a string to hold user input
;       [EBP + 3*4] = size of the string that holds user input
;       [EBP + 2*4] = the address of an array of SDWORDs
;
; Returns: [EBP + 2*4] = the array filled with values
; ---------------------------------------------------------------
getIntegers PROC
    PUSH    EBP                             ; save registers
    MOV     EBP, ESP
    PUSH    EAX
    PUSH    EBX
    PUSH    ECX
    PUSH    EDI

    ; move address of array and loop counter to registers
    MOV     EDI, [EBP + 2*4]
    MOV     ECX, [EBP + 7*4]

; fill array with integers entered by user
_fillArray:
    ; set up framing and call ReadVal to get an integer from user
    PUSH    [EBP + 6*4]
    PUSH    [EBP + 5*4]
    PUSH    [EBP + 4*4]
    PUSH    [EBP + 3*4]
    PUSH    EBX                             ; numerical value output by ReadVal
    CALL    ReadVal
    
    ; place value from user in array using DWORD primitives
    MOV     EAX, [EBX]
    CLD
    STOSD
    LOOP    _fillArray

    POP     EDI                             ; restore registers
    POP     ECX
    POP     EBX
    POP     EAX
    MOV     ESP, EBP
    POP     EBP
    RET     6*4
getIntegers ENDP


; ---------------------------------------------------------------
; Name: displayResults
; 
; This procedure displays the values in the given array, their sum,
; and their average, with string labels.
; 
; Preconditions: The array is filled with SDWORD values.
; 
; Postconditions: The values and string labels are printed to output.
; 
; Receives: 
;       [EBP + 7*4] = the address of a string delimiter to display 
;                       between numbers in list
;       [EBP + 6*4] = the address of a string label for the list of numbers
;       [EBP + 5*4] = the address of a string label for the sum
;       [EBP + 4*4] = the address of a string label for the average
;       [EBP + 3*4] = number of values in the array
;       [EBP + 2*4] = the address of an array of SDWORDs
;
; Returns: None
; ---------------------------------------------------------------
displayResults PROC
    LOCAL   sum: SDWORD
    PUSH    EAX
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX
    PUSH    ESI
    
    ; initialize sum (EBX), loop counter, and array pointer
    MOV     sum, 0
    MOV     ECX, [EBP + 3*4]
    MOV     ESI, [EBP + 2*4]

    ; display label for list of numbers
    mDisplayString [EBP + 6*4]

; step through array of numbers with DWORD primitives; for each value,
; add to sum and display it
_processArray:
    CLD
    LODSD
    ADD     sum, EAX                ; add current value to sum

    ; call WriteVal to display value within list
    PUSH    EAX
    CALL    WriteVal
    CMP     ECX, 1                  ; skip displaying delimiter after last value
    JE      _endLoop                
    mDisplayString [EBP + 7*4]      ; display delimiter
_endLoop:
    LOOP    _processArray

    ; display label for sum and call WriteVal to display sum
    mDisplayString [EBP + 5*4]
    PUSH    sum
    CALL    WriteVal

    ; display label for average
    mDisplayString [EBP + 4*4]

    ; calculate and display rounded average
    MOV     EAX, sum
    MOV     EBX, [EBP + 3*4]
    CDQ
    IDIV    EBX
    IMUL    EDX, 2                  ; double remainder
    CMP     EDX, 0
    JE      _displayAverage
    JL      _negative
    JMP     _positive

; compare doubled remainder to number of values to determine rounding
_negative:
    NEG     EDX
    CMP     EDX, EBX
    JG      _roundDown
    JMP     _displayAverage

_roundDown:
    DEC     EAX
    JMP     _displayAverage

_positive:
    CMP     EDX, EBX
    JGE     _roundUp
    JMP     _displayAverage

_roundUp:
    INC     EAX
    JMP     _displayAverage

_displayAverage:
    PUSH    EAX
    CALL    WriteVal

    POP     ESI                     ; restore registers
    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    RET     6*4
displayResults ENDP


; ---------------------------------------------------------------
; Name: showGoodbye
;
; This procedure displays a goodbye message for the user.
;
; Preconditions: None
;
; Postconditions: This string is printed to output.
;
; Receives:
;       [EBP + 2*4] = address of string to display
;
; Returns: None
; ---------------------------------------------------------------
showGoodbye PROC
    PUSH    EBP                             ; save registers
    MOV     EBP, ESP

    mDisplayString [EBP + 2*4]              ; display string

    MOV     ESP, EBP                        ; restore registers
    POP     EBP
    RET     4
showGoodbye ENDP


END main
