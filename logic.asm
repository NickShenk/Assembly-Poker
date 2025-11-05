INCLUDE ui.INC
INCLUDE IRVINE32.INC
.data
card STRUCT
 value BYTE
 suit BYTE
card ENDS

cards card 52 DUP(<>) ; Found online how to initialize a struct array https://stackoverflow.com/questions/75139036/array-of-custom-structs-masm-windows-api

Player STRUCT
 cards WORD 4 DUP(0)
Player ENDS
.code
main PROC
    ; initialize cards
    mov eax, 52
    initialize:
    dec eax

    mov cards[eax].value, eax MOD 14
    cards[eax].suit, eax / 4
    cmp ax, eax
    jnz initialize
    

    call ExitProcess
  quit:
    exit
main ENDP
END main
