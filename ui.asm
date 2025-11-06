; ui.asm - Poker UI routines - Author: Christian Prieto
INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "Welcome to MASM Poker!", 0
promptMsg  BYTE "Enter your name: ", 0
greetMsg   BYTE "Hello, ", 0
nameBuffer BYTE 32 DUP(0)      ; Buffer for up to 31-character name

.code
main PROC
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

    ; (UI i thin here)

    exit
main ENDP
END main
