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
startMsg    BYTE 0Dh,0Ah,"(Poker game coming soon...)",0Dh,0Ah,0
quitMsg     BYTE 0Dh,0Ah,"Quitting. Goodbye!",0Dh,0Ah,0

topNameMsg      BYTE 0Dh,0Ah,"        [Bob]    $1475   Bet: 20",0Dh,0Ah,0
leftNameMsg     BYTE " [Jeff] $900  Bet: 0",0
centerTitleMsg  BYTE 0Dh,0Ah,"==== COMMUNITY CARDS ====   Pot: $120   Street: FLOP",0Dh,0Ah,0
centerCardsMsg  BYTE "  [AH][TS][8C][  ][  ]",0Dh,0Ah,0
rightNameMsg    BYTE "    [Joe] $2150 Bet: 40",0Dh,0Ah,0
bottomNameMsg   BYTE 0Dh,0Ah,"       * YOU *   $1125 Bet: 80",0Dh,0Ah,0

playerColors  DWORD lightGreen + (black*16), lightCyan + (black*16), lightMagenta + (black*16), lightBlue + (black*16)

.code
main PROC
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

DrawPokerTable PROC
    call Clrscr

    ; Top player (Bob)
    mov eax, [playerColors]
    call SetTextColor
    mov edx, OFFSET topNameMsg
    call WriteString

    ; Left player (Jeff)
    mov eax, [playerColors+4]
    call SetTextColor
    mov edx, OFFSET leftNameMsg
    call WriteString

    ; Center (community) yellow, then red for cards
    mov eax, yellow + (black*16)
    call SetTextColor
    mov edx, OFFSET centerTitleMsg
    call WriteString

    mov eax, lightRed + (black*16)
    call SetTextColor
    mov edx, OFFSET centerCardsMsg
    call WriteString

    ; Right player (Joe)
    mov eax, [playerColors+8]
    call SetTextColor
    mov edx, OFFSET rightNameMsg
    call WriteString

    ; Bottom player (YOU)
    mov eax, [playerColors+12]
    call SetTextColor
    mov edx, OFFSET bottomNameMsg
    call WriteString

    mov eax, white + (black*16)
    call SetTextColor

    ret
DrawPokerTable ENDP

END main
