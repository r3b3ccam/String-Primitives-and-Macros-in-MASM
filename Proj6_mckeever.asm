TITLE Project 6 - String Primitives and Macros     (Proj6_mckeever.asm)

; Author: Rebecca Mckeever
; Last Modified: 03/12/2021
; OSU email address: mckeever@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 03/16/2021
; Description: ***

INCLUDE Irvine32.inc

; ---------------------------------------------------------------
; Name: mGetString
;
; 
;
; Preconditions: 
;
; Receives:
; 
; 
; 
;
; returns: 
; ---------------------------------------------------------------
mGetString MACRO     promptStr, buffer, bufferSize, numChars
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
; 
;
; Preconditions: 
;
; Receives:
; 
; 
; 
;
; returns: 
; ---------------------------------------------------------------
mDisplayString MACRO inString
    PUSH    EDX                             ; save register
    
    MOV     EDX, inString
    CALL    WriteString

    POP     EDX                             ; restore register
ENDM


; (insert constant definitions here)
NUM_COUNT = 10
STR_LEN = 100                   ; includes extra bytes to account for user entering multiple leading 0's
MIN_VAL = -80000000h            ; -2^31
MAX_VAL = 7FFFFFFFh             ; 2^31 - 1

.data
    userInput   BYTE    STR_LEN DUP(0)
    intro1      BYTE    "Project 6: Designing low-level I/O procedures by Rebecca Mckeever",13,10,13,10,0
    intro2      BYTE    "Please enter 10 signed decimal integers.",13,10,
                        "Each number must be small enough to fit in a 32 bit register. After you input the ",13,10,
                        "numbers, I will display the numbers entered, their sum, and the average.",13,10,13,10,0
    prompt      BYTE    "Please enter a signed number: ",0
    errorMsg    BYTE    "ERROR: You did not enter a signed number, or your number was too big. Please try again.",13,10,0
    numsLabel   BYTE    13,10,"You entered the following numbers: ",13,10,0
    sumLabel    BYTE    "The sum of these numbers is: ",0
    aveLabel    BYTE    "The rounded average is: ",0
    goodbye     BYTE    13,10,"Goodbye, thanks for playing!",13,10,0
 ;   number      SDWORD  0
    numberArr   SDWORD  NUM_COUNT DUP(?)
    sum         SDWORD  ?
    average     SDWORD  ?
    
.code
main PROC
    ; set up framing and call getIntegers to get 10 integers from user
    PUSH    NUM_COUNT
    PUSH    MIN_VAL
    PUSH    MAX_VAL
    PUSH    OFFSET prompt
    PUSH    OFFSET errorMsg
    PUSH    OFFSET userInput
    PUSH    SIZEOF userInput
    PUSH    OFFSET numberArr
    CALL    getIntegers
    
    ; set up framing and call displayResults
    PUSH    OFFSET numsLabel
    PUSH    OFFSET sumLabel
    PUSH    OFFSET aveLabel
    PUSH    NUM_COUNT
    PUSH    OFFSET numberArr
    CALL    displayResults

    ; set up framing and call WriteVal
    CALL    WriteVal
    
    Invoke ExitProcess,0    ; exit to operating system
main ENDP


; ---------------------------------------------------------------
; Name: ReadVal
; 
; 
; 
; Preconditions: 
; 
; Postconditions: 
; 
; Receives: 
;       [EBP + 8*4] = minimum value of user input
;       [EBP + 7*4] = maximum value of user input
;       [EBP + 6*4] = the address of a string prompt
;       [EBP + 5*4] = the address of a string error message
;       [EBP + 4*4] = the address of a string to hold user input
;       [EBP + 3*4] = size of the string that holds user input
;       [EBP + 2*4] = the address of an SDWORD
;
; Returns: 
; ---------------------------------------------------------------
ReadVal PROC
    LOCAL   byteCount: DWORD, curChar: SDWORD, isNegative: BYTE
    PUSH    EAX                                 ; save registers
    PUSH    EBX
    PUSH    ECX
    PUSH    EDX
    PUSH    EDI
    PUSH    ESI

    MOV     EDI, [EBP + 2*4]
    MOV     ESI, [EBP + 4*4]
    MOV     EBX, 0
    MOV     [EDI], EBX
_getInput:
    MOV     isNegative, 0
    ; call mGetString to get user input
    mGetString [EBP + 6*4], ESI, [EBP + 3*4], byteCount

;    MOV     ESI, [EBP + 4*4]
    MOV     ECX, byteCount
    CMP     ECX, 0
    JE      _invalid

    ; get first character of input string to check for possible sign
    CLD
    LODSB
    MOVZX   EAX, AL
    MOV     curChar, EAX

    CMP     curChar, '+'
    JE      _checkLength
    CMP     curChar, '-'
    JE      _checkLength
    JMP     _checkNumerals

_checkLength:
    CMP     ECX, 1
    JLE     _invalid

    CMP     curChar, '-'
    JNE     _endLoop
    MOV     isNegative, 1
    JMP     _endLoop

_charLoop:
    CLD
    LODSB
    MOVZX   EAX, AL
    MOV     curChar, EAX
    JMP _checkNumerals

_endLoop:
    LOOP    _charLoop
    JMP     _end

_checkNumerals:
    CMP     curChar, '9'
    JG      _invalid
    CMP     curChar, '0'
    JL      _invalid

    MOV     EAX, [EDI]
    MOV     EBX, 10
    MUL     EBX
    ADD     EAX, curChar
    SUB     EAX, '0'
    MOV     [EDI], EAX
    JMP     _checkLimits

_checkLimits:
    ; check sign to determine which limit to compare to
    CMP     isNegative, 1
    JE      _checkMin

    CMP     EAX, [EBP + 7*4]
    JG      _invalid
    CMP     EAX, 0
    JL      _invalid
 ;   CMP     isNegative, 1
 ;   JNE     _invalid
    JMP     _endLoop

_checkMin:
    NEG     EAX
    CMP     EAX, [EBP + 8*4]
    JL      _invalid
    CMP     EAX, 0
    JG      _invalid
    JMP     _endLoop

_invalid:
    MOV     EBX, 0
    MOV     [EDI], EBX
    mDisplayString [EBP + 5*4]
    JMP     _getInput

_end:
    MOV     [EDI], EAX                          ; move possibly negated value
    POP     ESI                                 ; restore registers
    POP     EDI
    POP     EDX
    POP     ECX
    POP     EBX
    POP     EAX
    RET     7*4
ReadVal ENDP


; ---------------------------------------------------------------
; Name: WriteVal
; 
; 
; 
; Preconditions: 
; 
; Postconditions: 
; 
; Receives: 
; 
; Returns: 
; ---------------------------------------------------------------
WriteVal PROC
    
    
    RET
WriteVal ENDP


; ---------------------------------------------------------------
; Name: getIntegers
; 
; 
; 
; Preconditions: 
; 
; Postconditions: 
; 
; Receives: 
;       [EBP + 9*4] = number of values to get from user
;       [EBP + 8*4] = minimum value of user input
;       [EBP + 7*4] = maximum value of user input
;       [EBP + 6*4] = the address of a string prompt
;       [EBP + 5*4] = the address of a string error message
;       [EBP + 4*4] = the address of a string to hold user input
;       [EBP + 3*4] = size of the string that holds user input
;       [EBP + 2*4] = the address of an array of SDWORDs
;
; Returns: 
; ---------------------------------------------------------------
getIntegers PROC
    LOCAL   number: DWORD
    PUSH    EAX
    PUSH    EBX
    PUSH    ECX
    PUSH    EDI

    MOV     EDI, [EBP + 2*4]
    MOV     ECX, [EBP + 9*4]
    LEA     EBX, number
    CLD
    
_fillArray:
    ; set up framing and call ReadVal to get an integer from user    
    PUSH    [EBP + 8*4]
    PUSH    [EBP + 7*4]
    PUSH    [EBP + 6*4]
    PUSH    [EBP + 5*4]
    PUSH    [EBP + 4*4]
    PUSH    [EBP + 3*4]
    PUSH    EBX
    CALL    ReadVal
    
    MOV     EAX, EBX
    STOSD                           ; place value from user in array
 ;   MOV     [EDI], EAX              
 ;   ADD     EDI, 4                  ; TYPE of array 
    LOOP    _fillArray

    POP     EDI
    POP     ECX
    POP     EBX
    POP     EAX
    RET     8*4
getIntegers ENDP


; ---------------------------------------------------------------
; Name: displayResults
; 
; 
; 
; Preconditions: 
; 
; Postconditions: 
; 
; Receives: 
;       [EBP + 6*4] = the address of a string label for the list of numbers
;       [EBP + 5*4] = the address of a string label for the sum
;       [EBP + 4*4] = the address of a string label for the average
;       [EBP + 3*4] = number of values to get from user
;       [EBP + 2*4] = the address of an array of SDWORDs
;
; Returns: 
; ---------------------------------------------------------------
displayResults PROC
    PUSH    EBP                     ; save registers
    MOV     EBP, ESP
    
    mDisplayString [EBP + 6*4]
    
    
    MOV     ESP, EBP                ; restore registers 
    POP     EBP
    RET     5*4
displayResults ENDP


END main
