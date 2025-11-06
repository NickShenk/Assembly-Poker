; ui.asm - Poker UI routines - Author: Christian Prieto
INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "Welcome to MASM Poker!", 0
promptMsg  BYTE "Enter your name: ", 0
greetMsg   BYTE "Hello, ", 0
nameBuffer BYTE 32 DUP(0)         ; Buffer for up to 31-character name

; === Menu Data Section ===
menuMsg    BYTE 0Dh,0Ah,"Main Menu:",0Dh,0Ah,\
                "1. Start Game",0Dh,0Ah,\
                "2. Quit",0Dh,0Ah,\
                "Select an option: ",0
inputBuffer BYTE 8 DUP(0)
startMsg   BYTE 0Dh,0Ah,"(Poker game coming soon...)",0Dh,0Ah,0
quitMsg    BYTE 0Dh,0Ah,"Quitting. Goodbye!",0Dh,0Ah,0

; === Player Table Data (static example for UI) ===
topNameMsg      BYTE 0Dh,0Ah,"     [Bob]    $1475   Bet:  20           ",0Dh,0Ah,0
leftNameMsg     BYTE " [Jeff] $900  Bet:  0",0
centerTitleMsg  BYTE 0Dh,0Ah,"====== COMMUNITY CARDS ======   Pot: $120   Street: FLOP",0Dh,0Ah,0
centerCardsMsg  BYTE "   [AH][TS][8C][  ][  ]",0Dh,0Ah,0
rightNameMsg    BYTE " [Joe] $2150 Bet:  40",0Dh,0Ah,0
bottomNameMsg   BYTE 0Dh,0Ah,"      * YOU *   $1125 Bet:  80",0Dh,0Ah,0

.code
main PROC
    ; === Welcome and Greeting Section ===
    mov edx, OFFSET welcomeMsg   ; Show welcome message
    call WriteString
    call Crlf

    mov edx, OFFSET promptMsg    ; Prompt for name
    call WriteString
    mov edx, OFFSET nameBuffer
    mov ecx, 31                 ; Max characters to read
    call ReadString

    call Crlf                   ; Newline after input

    mov edx, OFFSET greetMsg    ; Print "Hello, "
    call WriteString
    mov edx, OFFSET nameBuffer  ; Print user name
    call WriteString
    call Crlf

    ; === Menu Section (render and handle options) ===
mainMenu:
    mov edx, OFFSET menuMsg       ; Print the menu options
    call WriteString
    mov edx, OFFSET inputBuffer
    mov ecx, 7
    call ReadString

    ; Process user selection here
    mov edx, OFFSET inputBuffer
    mov al, [edx]
    cmp al, '1'
    je doStart
    cmp al, '2'
    je doQuit

    ; If input is invalid, show the prompt and repeat
    call Crlf
    mov edx, OFFSET promptMsg
    call WriteString
    jmp mainMenu

doStart:
    call DrawPokerTable              ; Draw table on start
    jmp mainMenu

doQuit:
    mov edx, OFFSET quitMsg
    call WriteString
    exit
main ENDP

; === Table Drawing Section: Clears screen and shows table players layout and chips ===
DrawPokerTable PROC
    call Clrscr                       ; Clear terminal for clean redraw

    ; Draw top player
    mov edx, OFFSET topNameMsg
    call WriteString

    ; Draw left seat, community, right seat
    mov edx, OFFSET leftNameMsg
    call WriteString
    mov edx, OFFSET centerTitleMsg
    call WriteString
    mov edx, OFFSET centerCardsMsg
    call WriteString
    mov edx, OFFSET rightNameMsg
    call WriteString

    ; Draw bottom player (YOU, marked with star)
    mov edx, OFFSET bottomNameMsg
    call WriteString

    ret
DrawPokerTable ENDP

END main
