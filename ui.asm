; ui.asm - Poker UI routines - Author: Christian Prieto
INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "Welcome to MASM Poker!",0
promptMsg  BYTE "Enter your name: ",0
greetMsg   BYTE "Hello, ",0
nameBuffer BYTE 32 DUP(0)

menuMsg    BYTE 0Dh,0Ah,"Main Menu:",0Dh,0Ah,\
            "1. Start Game",0Dh,0Ah,\
            "2. Quit",0Dh,0Ah,\
            "Select an option: ",0
inputBuffer BYTE 8 DUP(0)
startMsg     BYTE 0Dh,0Ah,"(Poker game coming soon...)",0Dh,0Ah,0
quitMsg      BYTE 0Dh,0Ah,"Quitting. Goodbye!",0Dh,0Ah,0

; === Mock test data for dynamic UI seat rendering (for upcoming backend integration) ===
playerNames  BYTE "Bob",0,"Jeff",0,"Joe",0,"You",0
playerChips  DWORD 1475, 900, 2150, 1125
playerBets   DWORD 20, 0, 40, 80
numSeats     DWORD 4

playerColors DWORD lightGreen+(black*16), lightCyan+(black*16), lightMagenta+(black*16), lightBlue+(black*16)

centerTitleMsg  BYTE 0Dh,0Ah,"==== COMMUNITY CARDS ====   Pot: $120   Street: FLOP",0Dh,0Ah,0
centerCardsMsg  BYTE "  [AH][TS][8C][  ][  ]",0Dh,0Ah,0

chipsMsg    BYTE " Chips: ",0
betMsg      BYTE " Bet: ",0

.code
main PROC
    ; Print welcome, prompt for name
    mov edx, OFFSET welcomeMsg
    call WriteString
    call Crlf

    mov edx, OFFSET promptMsg
    call WriteString
    mov edx, OFFSET nameBuffer
    mov ecx, 31
    call ReadString
    call Crlf

    mov edx, OFFSET greetMsg
    call WriteString
    mov edx, OFFSET nameBuffer
    call WriteString
    call Crlf

mainMenu:
    mov edx, OFFSET menuMsg
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 7
    call ReadString

    mov edx, OFFSET inputBuffer
    mov al, [edx]
    cmp al, '1'
    je doStart
    cmp al, '2'
    je doQuit

    call Crlf
    mov edx, OFFSET promptMsg
    call WriteString
    jmp mainMenu

doStart:
    call DrawPokerTable
    jmp mainMenu

doQuit:
    mov edx, OFFSET quitMsg
    call WriteString
    exit
main ENDP

; ----------------------------------
; DrawPokerTable: Print all players
; ------------------------------------------

DrawPokerTable PROC
    call Clrscr

    mov esi, 0                        ; Seat index
    mov ecx, [numSeats]
drawSeatsLoop:
    ; Set text color for this seat
    mov eax, [playerColors + esi*4]
    call SetTextColor

    ; Print player name (offset calculation for zero-terminated names)
    mov edi, 0
    mov edx, OFFSET playerNames
    mov ebx, esi
    findName:
        cmp ebx, 0
        je printName
        ; Move to next null byte for next name
        nextNameChar:
            cmp BYTE PTR [edx], 0
            je foundNull
            inc edx
            jmp nextNameChar
        foundNull:
            inc edx      ; next name
            dec ebx
            jmp findName
    printName:
        call WriteString

    ; Print chips
    mov edx, OFFSET chipsMsg
    call WriteString
    mov eax, [playerChips + esi * 4]
    mov edx, eax
    call WriteDec

    ; Print bet
    mov edx, OFFSET betMsg
    call WriteString
    mov eax, [playerBets + esi * 4]
    mov edx, eax
    call WriteDec

    call Crlf

    inc esi
    cmp esi, ecx
    jl drawSeatsLoop

    ; Community cards and round info
    mov eax, yellow + (black*16)
    call SetTextColor
    mov edx, OFFSET centerTitleMsg
    call WriteString

    mov eax, lightRed + (black*16)
    call SetTextColor
    mov edx, OFFSET centerCardsMsg
    call WriteString

    mov eax, white + (black*16)
    call SetTextColor

    ret
DrawPokerTable ENDP

END main
