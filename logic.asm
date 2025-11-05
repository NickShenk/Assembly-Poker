;INCLUDE ui.INC
INCLUDE IRVINE32.INC
.data
card STRUCT
 value BYTE ?
 suit BYTE ?
card ENDS

cards card 52 DUP(<>) ; Found online how to initialize a struct array https://stackoverflow.com/questions/75139036/array-of-custom-structs-masm-windows-api

Player STRUCT
 first_card BYTE 0 ; index of card in deck
 second_card BYTE 0 ; index of card in deck
 cards WORD 4 DUP(0) ; data structure for finding flushes, straights, pairs, ect.
 bet WORD 0
 balance WORD 1000
Player ENDS

players player 5 DUP(<>) ; Create 5 players

.code
main PROC
    ; initialize cards
    mov ecx, 52
    initialize:
    dec ecx

    mov eax, ecx
    mov edx, 0
    mov ebx, 13
    div ebx
    mov cards[ecx * TYPE card].suit, al ; eax divided by 13, al is right most byte

    mov eax, ecx ; reset eax
    add eax, 13
    modloop:
    sub eax, 13
    cmp eax, 13
    jg modloop
    mov cards[ecx * TYPE card].value, al ; eax mod 13, al is right most byte
    
    cmp ecx,0 
    jnz initialize
    ; end of intialization
    
    ; fill out each player

    ; end of intializing each player

    call ExitProcess
  quit:
    exit
main ENDP
END main
