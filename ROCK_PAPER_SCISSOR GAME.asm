.MODEL SMALL
.STACK 100H
.DATA 

    C1 DB 10 DUP(?) ; user1's choice
    C2 DB 10 DUP(?) ; user2's choice
    S1 DB 0 ; user1's score
    S2 DB 0 ; user2's score 
    NUM DW 0 ; number of turns
    TURN DB 0AH,0DH,"Enter the number of turns(1-9): $"
    PROMPT DB 0AH,0DH,"Press R for Rock, P for Paper, S for Scissors: $"
    E DB 0AH,0DH,"INVALID INPUT!!! TRY AGAIN!!! $"
    NEWLINE DB 0AH, 0DH, "$" ; Newline characters for output
    A DB 0AH,0DH,"Insert the move of user1: $"
    B DB 0AH,0DH,"Insert the move of user2: $"
    T DB 0AH,0DH, "IT'S A TIE!!! $"
    P DB 0AH,0DH, "USER 1 WON!!! $"
    Q DB 0AH,0DH, "USER 2 WON!!! $"

.CODE  

MAIN PROC
    MOV AX, @DATA
    MOV DS, AX 
      
    ; Get the number of turns from the user
    LEA DX, TURN
    MOV AH, 09H
    INT 21H 

    ; Input for number of turns
    MOV AH, 01H
    INT 21H
    CMP AL,"1"
    JL INVALID
    CMP AL, "9"
    JG INVALID 
    JMP VALID
    
INVALID:    
    ; If the input is invalid, display an error message  
    LEA DX, E
    MOV AH, 09H
    INT 21H
    JMP EXIT
     
VALID:
    SUB AL, 30H   ; Convert ASCII to integer
    MOV BL,0      ; We need this value to run the loop. But since CX is 16 bit register we can't directly use AL
    ADD BL,AL     ; By adding it with BL and then moving the total value of BX makes it easier to access CX properly
    MOV NUM, BX    ; Storing the value in the NUM variable
          
    
    ; Display the prompt
    LEA DX,PROMPT
    MOV AH,09H
    INT 21H

    ; Input for user1 and user2
    MOV CX,NUM
    MOV SI,0

INPUT:
    LEA DX,A    ; Get user1's input
    MOV AH,09H
    INT 21H

    MOV AH, 01H
    INT 21H
    
    CMP AL,"R"
    JE VALID_INPUT1
    CMP AL,"P"
    JE VALID_INPUT1
    CMP AL,"S"
    JE VALID_INPUT1
    
    ; If the input is invalid, display an error message
    LEA DX,E
    MOV AH,09H
    INT 21H
    JMP INPUT
    
VALID_INPUT1:    
    MOV C1[SI], AL    ; Store user1's input into an array if there's no error

    LEA DX,B          ; Get user2's input
    MOV AH,09H
    INT 21H

    MOV AH, 01H
    INT 21H
     
    CMP AL,"R"
    JE VALID_INPUT2
    CMP AL,"P"
    JE VALID_INPUT2
    CMP AL,"S"
    JE VALID_INPUT2
    
    ; If the input is invalid, display an error message
    LEA DX,E
    MOV AH,09H
    INT 21H
    JMP INPUT
    
VALID_INPUT2:    
    MOV C2[SI], AL    ; Store user2's input into an array if there's no error

    LEA DX,NEWLINE
    MOV AH,09H
    INT 21H

    INC SI         ; Move to the next element in the arrays
    LOOP INPUT     ; Continue the loop until CX becomes zero 
    
 

    ; Analyzing the moves
    MOV CX, SI
    MOV SI, 0 

CHECK:
    MOV AL, C1[SI]  ; Load values from the first array (C1) into AL sequentially by index
    CMP AL,"R"
    JE ROCK
    CMP AL,"P"
    JE PAPER
    CMP AL,"S"
    JE SCISSOR

ROCK:
    MOV AL,C2[SI]   ; Load the value of the same index from the second array (C2)
    CMP AL,"P"
    JE USER2_SCORE
    CMP AL,"S"
    JE USER1_SCORE
    JMP CONTINUE   ;Values are similar

PAPER:
    MOV AL,C2[SI]  ; Load the value of the same index from the second array (C2)
    CMP AL,"R"
    JE USER1_SCORE
    CMP AL,"S"
    JE USER2_SCORE
    JMP CONTINUE   ;Values are similar

SCISSOR:
    MOV AL,C2[SI]  ; Load the value of the same index from the second array (C2)
    CMP AL,"P"
    JE USER1_SCORE
    CMP AL,"R"
    JE USER2_SCORE
    JMP CONTINUE   ;Values are similar

USER1_SCORE:
   INC S1 
   JMP CONTINUE  ; Jump back into the loop

USER2_SCORE:
   INC S2
   JMP CONTINUE  ; Jump back into the loop

CONTINUE:
   INC SI          ; Move to the next element in the arrays
   LOOP CHECK      ; Continue the loop until CX becomes zero             

RESULT:
   MOV AL,S1       ;Load the score of User1
   MOV BL,S2       ;Load the score of User2
   CMP AL,BL
   JE TIE
   JG USER1
   JL USER2

TIE:            ;Executes when the scores are similar
   LEA DX,T
   MOV AH,09H
   INT 21H
   JMP EXIT

USER1:          ;Executes when User1's score is higher
   LEA DX,P
   MOV AH,09H
   INT 21H
   JMP EXIT

USER2:         ;Executes when User2's score is higher
   LEA DX,Q
   MOV AH,09H
   INT 21H
   JMP EXIT   

EXIT:                   
   MOV AX, 4C00H
   INT 21H 

MAIN ENDP
END MAIN
