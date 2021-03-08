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

.data

; (insert variable definitions here)

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
