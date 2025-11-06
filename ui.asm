; ui.asm - Poker UI routines - Author: Christian Prieto
INCLUDE Irvine32.inc

.data
welcomeMsg BYTE "Welcome to MASM Poker!", 0

.code
main PROC
    mov edx, OFFSET welcomeMsg   ; Set pointer to string for display
    call WriteString             ; prints string at EDX
    call Crlf                   ; Newline for output clarity
    ; UI rendering and menu logic will go below heree
    exit
main ENDP
END main
