; ui.asm - Poker UI routines - Author: Christian Prieto
INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "Welcome to MASM Poker!", 0
promptMsg  BYTE "Enter your name: ", 0
greetMsg   BYTE "Hello, ", 0
nameBuffer BYTE 32 DUP(0)         ; Buffer for up to 31-character name gere too for right in

; === Menu Data Section ===
menuMsg    BYTE 0Dh,0Ah,"Main Menu:",0Dh,0Ah, \
                "1. Start Game",0Dh,0Ah, \
                "2. Quit",0Dh,0Ah, \
                "Select an option: ",0
inputBuffer BYTE 8 DUP(0)
startMsg   BYTE 0Dh,0Ah,"(Game would start...)",0Dh,0Ah,0
quitMsg    BYTE 0Dh,0Ah,"Quitting. Goodbye!",0Dh,0Ah,0

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

    ;menu part for this commit test  ===
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

    ; If input is invalid, show the prompt repeat 
    call Crlf
    mov edx, OFFSET promptMsg
    call WriteString
    jmp mainMenu

doStart:
    mov edx, OFFSET startMsg
    call WriteString
    jmp mainMenu

doQuit:
    mov edx, OFFSET quitMsg
    call WriteString
    exit
main ENDP
END main
