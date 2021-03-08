TITLE Project 6 - String Primitives and Macros     (Proj6_mckeever.asm)

; Author: Rebecca Mckeever
; Last Modified: 03/07/2021
; OSU email address: ONID_ID@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 03/16/2021
; Description: ***

INCLUDE Irvine32.inc

; ---------------------------------------------------------------
; Name: mGetSring
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
mGetSring MACRO


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
mDisplayString MACRO


ENDM

; (insert constant definitions here)
NUM_COUNT = 10
STR_LEN = 15

.data
    buffer      BYTE    STR_LEN DUP(0)
    intro1      BYTE    "Project 6: Designing low-level I/O procedures by Rebecca Mckeever",13,10,13,10,0
    intro2      BYTE    "Please enter 10 signed decimal integers.",13,10,
                        "Each number must be small enough to fit in a 32 bit register. After you input the ",13,10,
                        "numbers, I will display the numbers entered, their sum, and the average.",13,10,13,10,0
    prompt      BYTE    "Please enter an signed number: ",0
    errorMsg    BYTE    "ERROR: You did not enter a signed number or your number was too big.",13,10,
                        "Please try again: ",0
    numsLabel   BYTE    "You entered the following numbers: ",13,10,0
    sumLabel    BYTE    "The sum of these numbers is: ",0
    aveLabel    BYTE    "The rounded average is: ",0
    goodbye     BYTE    13,10,"Goodbye, thanks for playing!",13,10,0
    numbers     SDWORD  NUM_COUNT DUP(?)
    sum         SDWORD  ?
    average     SDWORD  ?
    
.code
main PROC
    ; set up framing and call ReadVal
    CALL    ReadVal
    
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
; 
; Returns: 
; ---------------------------------------------------------------
ReadVal PROC
    
    
    RET
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


END main
