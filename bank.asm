
.MODEL SMALL
.STACK 100H

.DATA

; =============== MESSAGES ===============

TITLE_MSG DB 13,10,'====================================',13,10
          DB '       BANKING MANAGEMENT SYSTEM',13,10
          DB '====================================',13,10,'$'

WELCOME DB 13,10,'1. Create Account',13,10
        DB '2. Login',13,10
        DB '3. Exit',13,10
        DB 'Enter Choice: $'

NAME_MSG DB 13,10,'Enter Full Name: $'
AGE_MSG DB 13,10,'Enter Age: $'
MOBILE_MSG DB 13,10,'Enter Mobile Number: $'
PIN_MSG DB 13,10,'Create 4 Digit PIN: $'
DEPOSIT_MSG DB 13,10,'Enter Initial Deposit: $'

CREATED DB 13,10,'Account Created Successfully!',13,10,'$'
ACC_MSG DB 'Your Account Number: $'

LOGIN_ACC DB 13,10,'Enter Account Number: $'
LOGIN_PIN DB 13,10,'Enter PIN: $'

LOGIN_OK DB 13,10,'Login Successful!',13,10,'$'
LOGIN_FAIL DB 13,10,'Invalid Account Number or PIN!',13,10,'$'
NO_ACCOUNT DB 13,10,'Please Create Account First!',13,10,'$'

MENU DB 13,10,'========== BANK DASHBOARD ==========',13,10
     DB '1. Check Balance',13,10
     DB '2. Deposit Money',13,10
     DB '3. Withdraw Money',13,10
     DB '4. Change PIN',13,10
     DB '5. Account Details',13,10
     DB '6. Logout',13,10
     DB 'Enter Choice: $'

BAL_MSG DB 13,10,'Available Balance: Rs. $'
DEP_SUCCESS DB 13,10,'Amount Deposited Successfully!',13,10,'$'
WITH_SUCCESS DB 13,10,'Withdrawal Successful!',13,10,'$'

LOW_BAL DB 13,10,'Insufficient Balance!',13,10,'$'

WITHDRAW_PROMPT DB 13,10,'Enter Withdrawal Amount: $'

NEW_PIN_MSG DB 13,10,'Enter New 4 Digit PIN: $'
PIN_CHANGED DB 13,10,'PIN Changed Successfully!',13,10,'$'

DETAIL_MSG DB 13,10,'======= ACCOUNT DETAILS =======',13,10,'$'
NAME_DISPLAY DB 13,10,'Name: $'
AGE_DISPLAY DB 13,10,'Age: $'
MOBILE_DISPLAY DB 13,10,'Mobile: $'
ACCOUNT_DISPLAY DB 13,10,'Account Number: $'

INVALID DB 13,10,'Invalid Choice!',13,10,'$'
INVALID_PIN DB 13,10,'PIN must contain exactly 4 digits!',13,10,'$'

LOGOUT_MSG DB 13,10,'Logged Out Successfully!',13,10,'$'
EXIT_MSG DB 13,10,'Thank You For Banking With Us!',13,10,'$'

; =============== ACCOUNT DATA ===============

NAME_BUF DB 30,0,31 DUP(0)

; FIXED MOBILE BUFFER
MOBILE_BUF DB 11,0,12 DUP(0)

; FIXED PIN BUFFERS
PIN_BUF DB 5,0,6 DUP(0)
NEW_PIN_BUF DB 5,0,6 DUP(0)

NAME_DATA DB 32 DUP('$')
MOBILE_DATA DB 12 DUP('$')
PIN_DATA DB '0000'

AGE DW 0
ACCOUNT_NO DW 1001
BALANCE DW 0

ACCOUNT_CREATED DB 0

CHOICE DB ?

; =============== CODE SECTION ===============

.CODE

MAIN PROC

    MOV AX,@DATA
    MOV DS,AX

    LEA DX,TITLE_MSG
    MOV AH,09H
    INT 21H

MAIN_MENU:

    LEA DX,WELCOME
    MOV AH,09H
    INT 21H

    MOV AH,01H
    INT 21H

    MOV CHOICE,AL

    MOV AH,01H
    INT 21H

    CMP CHOICE,'1'
    JE CREATE_ACCOUNT

    CMP CHOICE,'2'
    JE LOGIN

    CMP CHOICE,'3'
    JE EXIT_SYSTEM

    LEA DX,INVALID
    MOV AH,09H
    INT 21H

    JMP MAIN_MENU


; =========================================
;              CREATE ACCOUNT
; =========================================

CREATE_ACCOUNT:

    CMP ACCOUNT_CREATED,1
    JE ACCOUNT_EXISTS

    ; ENTER NAME

    LEA DX,NAME_MSG
    MOV AH,09H
    INT 21H

    MOV BYTE PTR NAME_BUF+1,0

    MOV AH,0AH
    LEA DX,NAME_BUF
    INT 21H

    LEA SI,NAME_DATA
    LEA DI,NAME_BUF+2

    MOV CL,NAME_BUF+1
    XOR CH,CH

    JCXZ NAME_DONE

COPY_NAME:

    MOV AL,[DI]
    MOV [SI],AL

    INC SI
    INC DI

    LOOP COPY_NAME

NAME_DONE:

    MOV BYTE PTR [SI],'$'


    ; ENTER AGE

    LEA DX,AGE_MSG
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER

    MOV AGE,AX


    ; ENTER MOBILE NUMBER

    LEA DX,MOBILE_MSG
    MOV AH,09H
    INT 21H

    MOV BYTE PTR MOBILE_BUF+1,0

    MOV AH,0AH
    LEA DX,MOBILE_BUF
    INT 21H

    LEA SI,MOBILE_DATA
    LEA DI,MOBILE_BUF+2

    MOV CL,MOBILE_BUF+1
    XOR CH,CH

    JCXZ MOBILE_DONE

COPY_MOBILE:

    MOV AL,[DI]
    MOV [SI],AL

    INC SI
    INC DI

    LOOP COPY_MOBILE

MOBILE_DONE:

    MOV BYTE PTR [SI],'$'


    ; CREATE PIN

CREATE_PIN:

    LEA DX,PIN_MSG
    MOV AH,09H
    INT 21H

    MOV BYTE PTR PIN_BUF+1,0

    MOV AH,0AH
    LEA DX,PIN_BUF
    INT 21H

    CMP BYTE PTR PIN_BUF+1,4
    JNE PIN_ERROR

    LEA SI,PIN_BUF+2
    LEA DI,PIN_DATA

    MOV CX,4

COPY_INITIAL_PIN:

    MOV AL,[SI]

    CMP AL,'0'
    JB PIN_ERROR

    CMP AL,'9'
    JA PIN_ERROR

    MOV [DI],AL

    INC SI
    INC DI

    LOOP COPY_INITIAL_PIN

    JMP INITIAL_DEPOSIT

PIN_ERROR:

    LEA DX,INVALID_PIN
    MOV AH,09H
    INT 21H

    JMP CREATE_PIN


    ; INITIAL DEPOSIT

INITIAL_DEPOSIT:

    LEA DX,DEPOSIT_MSG
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER

    MOV BALANCE,AX

    MOV ACCOUNT_CREATED,1


    ; ACCOUNT CREATED

    LEA DX,CREATED
    MOV AH,09H
    INT 21H

    LEA DX,ACC_MSG
    MOV AH,09H
    INT 21H

    MOV AX,ACCOUNT_NO
    CALL DISPLAY_NUMBER

    JMP MAIN_MENU


ACCOUNT_EXISTS:

    LEA DX,INVALID
    MOV AH,09H
    INT 21H

    JMP MAIN_MENU


; =========================================
;                   LOGIN
; =========================================

LOGIN:

    CMP ACCOUNT_CREATED,1
    JNE ACCOUNT_NOT_FOUND

    LEA DX,LOGIN_ACC
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER

    CMP AX,ACCOUNT_NO
    JNE LOGIN_ERROR

    LEA DX,LOGIN_PIN
    MOV AH,09H
    INT 21H

    MOV BYTE PTR PIN_BUF+1,0

    MOV AH,0AH
    LEA DX,PIN_BUF
    INT 21H

    CMP BYTE PTR PIN_BUF+1,4
    JNE LOGIN_ERROR

    LEA SI,PIN_BUF+2
    LEA DI,PIN_DATA

    MOV CX,4

CHECK_LOGIN_PIN:

    MOV AL,[SI]
    CMP AL,[DI]

    JNE LOGIN_ERROR

    INC SI
    INC DI

    LOOP CHECK_LOGIN_PIN

    LEA DX,LOGIN_OK
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


ACCOUNT_NOT_FOUND:

    LEA DX,NO_ACCOUNT
    MOV AH,09H
    INT 21H

    JMP MAIN_MENU


LOGIN_ERROR:

    LEA DX,LOGIN_FAIL
    MOV AH,09H
    INT 21H

    JMP MAIN_MENU


; =========================================
;             BANKING DASHBOARD
; =========================================

BANK_MENU:

    LEA DX,MENU
    MOV AH,09H
    INT 21H

    MOV AH,01H
    INT 21H

    MOV CHOICE,AL

    MOV AH,01H
    INT 21H

    CMP CHOICE,'1'
    JE CHECK_BALANCE

    CMP CHOICE,'2'
    JE DEPOSIT_MONEY

    CMP CHOICE,'3'
    JE WITHDRAW_MONEY

    CMP CHOICE,'4'
    JE CHANGE_PIN

    CMP CHOICE,'5'
    JE ACCOUNT_DETAILS

    CMP CHOICE,'6'
    JE LOGOUT

    LEA DX,INVALID
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


; =========================================
;              CHECK BALANCE
; =========================================

CHECK_BALANCE:

    LEA DX,BAL_MSG
    MOV AH,09H
    INT 21H

    MOV AX,BALANCE
    CALL DISPLAY_NUMBER

    JMP BANK_MENU


; =========================================
;              DEPOSIT MONEY
; =========================================

DEPOSIT_MONEY:

    LEA DX,DEPOSIT_MSG
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER

    ADD BALANCE,AX

    LEA DX,DEP_SUCCESS
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


; =========================================
;              WITHDRAW MONEY
; =========================================

WITHDRAW_MONEY:

    LEA DX,WITHDRAW_PROMPT
    MOV AH,09H
    INT 21H

    CALL READ_NUMBER

    CMP AX,BALANCE
    JA INSUFFICIENT_BALANCE

    SUB BALANCE,AX

    LEA DX,WITH_SUCCESS
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


INSUFFICIENT_BALANCE:

    LEA DX,LOW_BAL
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


; =========================================
;                CHANGE PIN
; =========================================

CHANGE_PIN:

    LEA DX,NEW_PIN_MSG
    MOV AH,09H
    INT 21H

    MOV BYTE PTR NEW_PIN_BUF+1,0

    MOV AH,0AH
    LEA DX,NEW_PIN_BUF
    INT 21H

    CMP BYTE PTR NEW_PIN_BUF+1,4
    JNE CHANGE_PIN_ERROR

    LEA SI,NEW_PIN_BUF+2
    LEA DI,PIN_DATA

    MOV CX,4

COPY_NEW_PIN:

    MOV AL,[SI]

    CMP AL,'0'
    JB CHANGE_PIN_ERROR

    CMP AL,'9'
    JA CHANGE_PIN_ERROR

    MOV [DI],AL

    INC SI
    INC DI

    LOOP COPY_NEW_PIN

    LEA DX,PIN_CHANGED
    MOV AH,09H
    INT 21H

    JMP BANK_MENU


CHANGE_PIN_ERROR:

    LEA DX,INVALID_PIN
    MOV AH,09H
    INT 21H

    JMP CHANGE_PIN


; =========================================
;              ACCOUNT DETAILS
; =========================================

ACCOUNT_DETAILS:

    LEA DX,DETAIL_MSG
    MOV AH,09H
    INT 21H

    LEA DX,NAME_DISPLAY
    MOV AH,09H
    INT 21H

    LEA DX,NAME_DATA
    MOV AH,09H
    INT 21H

    LEA DX,AGE_DISPLAY
    MOV AH,09H
    INT 21H

    MOV AX,AGE
    CALL DISPLAY_NUMBER

    LEA DX,MOBILE_DISPLAY
    MOV AH,09H
    INT 21H

    LEA DX,MOBILE_DATA
    MOV AH,09H
    INT 21H

    LEA DX,ACCOUNT_DISPLAY
    MOV AH,09H
    INT 21H

    MOV AX,ACCOUNT_NO
    CALL DISPLAY_NUMBER

    JMP BANK_MENU


; =========================================
;                  LOGOUT
; =========================================

LOGOUT:

    LEA DX,LOGOUT_MSG
    MOV AH,09H
    INT 21H

    JMP MAIN_MENU


; =========================================
;                   EXIT
; =========================================

EXIT_SYSTEM:

    LEA DX,EXIT_MSG
    MOV AH,09H
    INT 21H

    MOV AH,4CH
    INT 21H

MAIN ENDP


; =========================================
;              READ NUMBER
; =========================================

READ_NUMBER PROC

    XOR BX,BX

READ_LOOP:

    MOV AH,01H
    INT 21H

    CMP AL,13
    JE READ_DONE

    CMP AL,'0'
    JB READ_LOOP

    CMP AL,'9'
    JA READ_LOOP

    SUB AL,'0'

    XOR AH,AH

    MOV DI,AX

    MOV AX,BX
    MOV CX,10

    MUL CX

    ADD AX,DI

    MOV BX,AX

    JMP READ_LOOP

READ_DONE:

    MOV AX,BX

    RET

READ_NUMBER ENDP


; =========================================
;             DISPLAY NUMBER
; =========================================

DISPLAY_NUMBER PROC

    PUSH BX
    PUSH CX
    PUSH DX

    MOV BX,10
    XOR CX,CX

    CMP AX,0
    JNE CONVERT_NUMBER

    MOV DL,'0'
    MOV AH,02H
    INT 21H

    JMP DISPLAY_DONE


CONVERT_NUMBER:

    XOR DX,DX

    DIV BX

    PUSH DX

    INC CX

    CMP AX,0
    JNE CONVERT_NUMBER


PRINT_NUMBER:

    POP DX

    ADD DL,'0'

    MOV AH,02H
    INT 21H

    LOOP PRINT_NUMBER


DISPLAY_DONE:

    POP DX
    POP CX
    POP BX

    RET

DISPLAY_NUMBER ENDP

END MAIN
