TITLE Programming Assignment #4     (Program04.asm)

; Author: Jordan Hamilton
; Last Modified: 2/17/2019
; OSU email address: hamiltj2@oregonstate.edu
; Course number/section: CS271-400
; Project Number: 4                Due Date: 2/17/2019
; Description: This program prompts the user to enter the number of composite numbers they'd like to display, up to 400.
; The requested number of composite numbers is then output to the screen.

INCLUDE Irvine32.inc

LOWERLIMIT          EQU       1
UPPERLIMIT          EQU       400
NUMBERSPERLINE      EQU       10

.data

intro               BYTE      "Programming assignment #4 by Jordan Hamilton",0
instruction         BYTE      "This program will display up to 400 composite numbers.",0
promptForNumber     BYTE      "Please enter a positive integer between 1 and 400, inclusive: ",0
retryMsg            BYTE      "Error: This number is out of range.",0
outro               BYTE      "Thanks for playing!",0

outputSpacing       BYTE      "   ",0
isCompositeNumber   BYTE      ?

numberToDisplay     DWORD     ?
numbersPrinted      DWORD     0
numberToCheck       DWORD     3
divisor             DWORD     2

.code

main PROC

     call      introduction
     call      getUserData
     call      showComposites
     call      farewell
     
     ; Exit to the operating system
	invoke    ExitProcess,0

main ENDP


introduction PROC

     ; Introduce the program (and programmer)
     mov       edx, OFFSET intro
     call      WriteString
     call      Crlf

     ; Give the user instructions on how to begin displaying composites
     mov       edx, OFFSET instruction
     call      WriteString
     call      Crlf
     ret

introduction ENDP


getUserData PROC

     ; Ask the user for a number in the valid range, then read input from the keyboard
     ; Call the validate procedure to verify that the number was in the requested range
     mov       edx, OFFSET promptForNumber
     call      WriteString
     call      ReadInt
     mov       numberToDisplay, eax
     call      validate
     ret

getUserData ENDP


validate PROC

     ; Compare the entered number with the bounds of the range, jumping to the invalidInput label for values outside the range
     ; Otherwise, continue the program by popping the return address into the instruction pointer from the stack
     cmp       numberToDisplay, LOWERLIMIT
     jl        invalidInput
     cmp       numberToDisplay, UPPERLIMIT
     jg        invalidInput
     jmp       goodInput
     
     ; Display an error message if the number provided was out of range, then call getUserData to prompt for input again
     invalidInput:
          mov       edx, OFFSET retryMsg
          call      WriteString
          call      Crlf
          call      getUserData

     goodInput:
          ret

validate ENDP


showComposites PROC

     ; Set the  loop counter to the user's entered number
     mov       ecx, numberToDisplay
     
     checkNumber:
          ; Set the first number to check whether it's composite or not to 4
          ; Since we know that 1 through 3 are prime, these would be trivial
          ; Increment this number every time thereafter
          inc       numberToCheck
          mov       eax, numberToCheck
          call      isComposite
          
          ; If the number we just checked was not composite, check the next number without decrementing the loop counter
          ; or printing a number
          cmp       isCompositeNumber, 0
          je        checkNumber
     
     ; Print the number if it was composite, then increment the number of composite numbers printed
     mov       eax, numberToCheck
     call      WriteDec
     inc       numbersPrinted

     ; Move the number of lines we've printed to the eax register, then divide by the number of composite numbers per line
     ; If there's no remainder, print a new line, otherwise, print spacing
     mov       eax, numbersPrinted
     mov       ebx, NUMBERSPERLINE
     mov       edx, 0
     div       ebx
     cmp       edx, 0
     jne       spacing
          
     ; If we just printed the 10th number on a line, only move to a new line without printing spaces
     call      Crlf
     jmp       endFormatting
          
     ; Print the output spacing after printing the composite number, only if we haven't moved to a new line
     spacing:
          mov       edx, OFFSET outputSpacing
          call      WriteString

     ; Decrement the loop counter since this was one of the composite numbers requested by the user
     endFormatting:
          loop      checkNumber
     
     ; Return once we've printed the number of composite numbers the user has requested
     ret

showComposites ENDP


isComposite PROC USES ecx
     
     ; Set our divisor to 2 initially
     ; This way, we can increment our divisor to repeatedly check for a division operation that doesn't have a remainder
     ; This would tell us that the number is composite
     mov       ebx, divisor

     ; Store the number we'd like to check in the stack while we figure out how many times we'll have to check, at most,
     ; whether this number is composite
     push      eax
    
     ; Divide the number to check by 2 - this is the maximum number of loops we'll perform to determine that it's prime
     mov       edx, 0
     div       ebx

     ; Set the loop counter to the result of that division
     mov       ecx, eax

     ; Set the eax register back to the number we'd like to check
     pop       eax
     
     checkIfComposite:
          ; Divide the number to check by our current divisor
          mov       edx, 0
          div       ebx
               
          ; Check if the remainder is equal to 0, if it is, we'll note that this number as composite and exit the loop
          cmp       edx, 0
          je        wasComposite
          
          ; If our remainder wasn't 0, then we need to increment our divisor, then move the number to check back into the eax register
          ; We'll loop and check again if the number is visible by the new divisor if the loop counter isn't 0
          inc       ebx
          mov       eax, numberToCheck
          loop      checkIfComposite

     ; If we've exhausted all possibilites for this number, set isCompositeNumber to 0 (indicating that it's prime and should not be printed)
     mov       isCompositeNumber, 0
     jmp       doneChecking
     
     ; Set the isCompositeNumber to 1, indicating that the number we just checked was composite.
     ; This will allow it to be displayed in the showComposites procedure
     wasComposite:
          mov       isCompositeNumber, 1

     ; Leave this function once we've determined that this is a composite number or a prime number
     doneChecking:     
          ret

isComposite ENDP


farewell PROC
     
     ; Display the goodbye message to the user
     call      Crlf
     mov       edx, OFFSET outro
     call      WriteString
     ret

farewell ENDP



END main
