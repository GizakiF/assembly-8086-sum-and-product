

org 100h
;for restart: last resort
;initialCX dw ?
;MOV initialCX, CX
JMP start
;to do: convert hex to dec


intro_msg db "--------------------------------------------------", 0Dh, 0Ah 
    db "SUM AND PRODUCT CALCULATOR", 0Dh, 0Ah  
    db "BY ARANETA and DE LA TORRE, K21", 0Dh, 0Ah
    db "--------------------------------------------------", 0Dh, 0Ah
    db "Please input two integers ranging from 0-99 :D", 0Dh, 0Ah, 0Ah, "$"
linebreak db "--------------------------------------------------", 0Dh, 0Ah, "$"

num1_msg db "first number ", 09h, ":$"
num2_msg db "second number ", 09h, ":$"

notdigit_msg db "This is not a valid integer ($"
beyond_msg db "queue-error: value is beyond 99! >:($"

linedivider db 09h, 09h, "------------", 0Dh, 0Ah, "$"
sum_msg db 09h, 09h, 08h, 08h, 08h, 08h, 08h, 08h, "SUM = $"
product_msg db 09h, 08h, 08h, "PRODUCT = $"

num1_disp db "first number: $"
num2_disp db "second number: $"

repeat_msg db "repeat program? (y/n): $"
sorry_msg db 09h, "(sorry, didn't catch that!) $" 

end_msg db "Program successfully Terminated!$"

current_str dw ?
invalid_char db ?

num1 dw ?
num2 dw ?

sum_val dw ?
product_val dw ?

not_digitcount dw ?
digitcount dw ?



;string print
SPRINT  MACRO   string
    PUSH AX
    PUSH DX     
    LEA DX, string
    MOV AH, 09h
    INT 21h
    POP AX
    POP DX
ENDM

;string print from what address
SPRINT_A    MACRO   address
    PUSH AX
    PUSH DX
    MOV DX, address
    MOV AH, 09h
    INT 21h
    POP AX
    POP DX
ENDM 
       
;character print
;CPRINT  MACRO char, loopcount
;    PUSH CX
;    PUSH AX
;    MOV CX, loopcount    
;    MOV AL, char
;    MOV AH, 0Eh
;    INT 10h
;    LOOP CPRINT char, loopcount
;    POP CX
;    POP AX
;ENDM

;character print
CPRINT  MACRO   char
    PUSH    AX
    MOV     AL, char
    MOV     AH, 0Eh
    INT     10h     
    POP     AX
ENDM

;CPRINT  MACRO char, loopcount
;    LOCAL print, exit
;    PUSH AX
;    PUSH CX
;    print:
;        MOV AL, char
;        MOV CX, loopcount
;        MOV AH, 0Eh
;        INT 10h
        
;    CMP CX, 0
;    JE exit
    
;    DEC CX
;    JA print
;    exit:
;        POP AX
;        PUSH CX
;ENDM    

;hex to dec
HEXPRINT     MACRO  hex
    LOCAL start, zero, divbyBX, divbyTen, stop, ten
    ten db 10
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX, hex
    MOV CX, 1
    MOV BX, 1000 ;enough for 9801d (99x99) or 2649h
    
    CMP AX, 0 ;if hex is 0h (sum or product is 0 ie 0x0 or 0+0)
    JE zero
    
    start:
        ;0 meant that the converting process is done. It will stay 0 because BX does not store remainder from dividing 1000/100/10/1
        ;the the decimal portion goes to dx ie 1234 /1000 = 1.234 (1 goes to AX) ignoring .234
        CMP BX, 0 
        JE stop
        
        ;prevents leading zeroes from printing; 0Ah = 10, not 010
        CMP CX, 0
        JE divbyBX
        
        CMP AX, BX
        JB divbyTen 
    
    divbyBX: ;AX is from 0-F; ie AX = 0Fh, 0Eh, 0Ah, 09h, 05h, etc
        MOV CX, 0 ;since its one digit hex, set this to zero 
        MOV DX, 0
        DIV BX
        
        ADD AL, 30h
        CPRINT AL
        
        MOV AX, DX
    divbyTen:
        PUSH AX
        MOV DX, 0
        MOV AX, BX
        DIV ten
        XCHG AH, DH ;prevents AH having 01 by exchanging vals with dh otherwise 0000000... will print as AH will remain 01 which makes bx not having 0 val
        MOV BX, AX
        POP AX
        JMP start       
    zero:
        CPRINT 30h ; '0'
    stop:
    POP AX
    POP BX
    POP CX
    POP DX  
ENDM   

start:      
    CPRINT 0Ah
    
    SPRINT intro_msg
    LEA BX, num1_msg
    MOV current_str, BX
    
    
    XOR CX, CX
    CALL getn
    ;reset the remainder of CX REG to 0
    XOR CH, CH
    MOV num1, CX 
    
    CPRINT 0Dh
    CPRINT 0Ah
    
    
    LEA BX, num2_msg
    MOV current_str, BX
    
    ;CX must be 0 to reset
    CALL reset_reg
    CALL getn
    XOR CH, CH
    MOV num2, CX
    
    CALL sum
    CALL product
    
    ;sum_expression:
    ;    CPRINT 0Dh
    ;    CPRINT 0Ah
    ;    PUSH AX
    ;    XOR AX, AX
    ;    num1txt db ?
    ;    MOV AX, num1
    ;    MOV num1txt, AL
    ;    SPRINT num1txt
    ;    POP AX
    
solved:
    CPRINT 0Dh
    CPRINT 0Ah
    CPRINT 0Ah
    
    
    SPRINT linedivider 
    
    
    SPRINT sum_msg
    HEXPRINT sum_val
    
    CPRINT 0Dh
    CPRINT 0Ah
    
    
    SPRINT product_msg
    HEXPRINT product_val
    
    CPRINT 0Dh
    CPRINT 0Ah
    CPRINT 0Ah
    CPRINT 0Ah
    
    
    SPRINT num1_disp
    HEXPRINT num1
    ;CPRINT 2Ch ; ","
    CPRINT 0Ah
    CPRINT 0Dh
    ;CPRINT 20h ; "space"
    SPRINT num2_disp
    HEXPRINT num2
    
    CPRINT 0Dh
    CPRINT 0Ah
    CPRINT 0Ah  
;    JMP endprog
repeat_prompt:
    CPRINT 0Dh
    CPRINT 0Ah 
    SPRINT repeat_msg
    
    ;one char prompt
    MOV AH, 01h
    INT 21h
    
    CMP AL, 'n'
    JE endprog
    CMP AL, 'N'
    JE endprog
    
    CMP AL, 'y'
    JE clear_screen   
    CMP AL, 'Y'
    JE clear_screen
    
   
    SPRINT sorry_msg
    JMP repeat_prompt

clear_screen:
    ; Clears the screen if user input 'y'
    MOV     AH, 06h
    MOV     AL, 0       ;Displays blank page
    MOV     BH, 07h     
    MOV     CX, 0
    MOV     DX, 184Fh
    INT 10h     
                 
    MOV     AH, 02h
    MOV     BH, 0
    XOR     DH, DH
    XOR     DL, DL
    INT 10h
       
restart:
    CPRINT 0Dh
    CPRINT 0Ah
    CALL reset_reg
    JZ start

getn    PROC

PUSH AX
PUSH DX

print: 
    SPRINT_A current_str
    MOV digitcount, 0


get_input:

    ;incase digit is beyond 2; possible when keys are spammed for longer periods
    CMP digitcount, 2
    JA overdigit
    
    ;get keystroke no echo (print)
    MOV AH, 00h
    INT 16h
    
    ;print char (from AL) then advance the cursor
    MOV AH, 0Eh 
    INT 10h 
    
    ;check if carriage ret (enter) is pressed
    CMP AL, 0Dh
    JE halt
    
    ;check if backspace is pressed                                                       
    CMP AL, 08h
    JE remove_digit
    
      
    
    
is_digit:
    
    ;check ascii in hex code
    CMP AL, '0'
    JB not_digit
    CMP AL, '9'
    JA not_digit
    INC digitcount

digit:
    PUSH AX
    MOV AX, CX
    MUL ten
    MOV CX, AX
    POP AX
    
    CMP CX, 99
    JA remove_current


    ;clear the higher values of AX
    MOV AH, 0
    SUB AX, 30h
    ADD CX, AX
    JMP get_input
remove_current: ;removes the space produced by int10;ah=0Eh
    CPRINT 08h 
    JMP remove_digit
        
not_digit:
    PUSH AX
    MOV invalid_char, AL
    CPRINT 09h
    SPRINT notdigit_msg
    CPRINT invalid_char
    CPRINT 29h ; ")"
    CPRINT 0Dh
    CPRINT 0Ah
    XOR CX, CX
    XOR DX, DX
    POP AX
    JMP print
remove_digit:
    ;prevents over backspace
    CMP digitcount, 0 
    JE nochar
    
    XOR CH, CH
    MOV AX, CX
    DIV ten
    MOV CX, AX
    
    CPRINT 20h  
    CPRINT 08h
    DEC digitcount
    JMP get_input
nochar:
    XOR CX, CX
    ;fixes : when bspace is pressed
    CPRINT 3Ah
    JMP get_input        
halt:
    ;checks if digit count is 0, if equal keep prompting
    CMP digitcount, 0
    JE no_reprint
    JA stop 
no_reprint:
    CPRINT 0Dh ;places the cursor at the beginning to prevent reprinting of current_str to the cursor
    JMP print   
overdigit: ;when keys are queued in the AL i.e "123456...16th" then an enter at the same time as the last key pressed, a small chance that int10h;ah=0eh will read both (last key and current key); this label prevents that
;    CPRINT 09h
;    SPRINT beyond_msg
;    CPRINT 0Dh
;    CPRINT 0Ah
    CPRINT 09h
    SPRINT beyond_msg
    CPRINT 0Ah
    CPRINT 0Dh
    MOV digitcount, 0
    CALL reset_reg
    JMP print   
    
    
stop:
    POP AX
    POP DX
    
    RET
        
ten db 10 
getn    ENDP

sum PROC
    
    PUSH AX
    XOR AX, AX
    MOV AX, num1
    
    ADD AX, num2
    MOV sum_val, AX
    POP AX
    RET     
sum ENDP

product PROC
    
    PUSH AX
    XOR AX, AX
    XOR CX, CX
    MOV AX, num1
    
    MUL num2
    
    MOV product_val, AX
    POP AX 
    RET
product ENDP    
    
reset_reg PROC
    XOR AX, AX
    ;XOR BX, BX
    XOR CX, CX
    XOR DX, DX
    RET
reset_reg ENDP

endprog:
    SPRINT end_msg
    END                                                                                   
            
           



    
    
