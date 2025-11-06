;  5 yea
;  Centralized rendering of the table for reuse.
; What: ShowTable prints both hands, chips, bets, and pot.

INCLUDE Irvine32.inc

.data
deck BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14

p1card1 BYTE ?
p1card2 BYTE ?
p1chips WORD 1000
p1bet   WORD 0
p2card1 BYTE ?
p2card2 BYTE ?
p2chips WORD 1000
p2bet   WORD 0
pot WORD 0
currentBet WORD 0

gameTitle BYTE "=== SIMPLE 2-PLAYER POKER ===",0Dh,0Ah
          BYTE "Highest card wins!",0Dh,0Ah,0
p1msg   BYTE "Player 1 (YOU)",0Dh,0Ah,0
p2msg   BYTE "Player 2 (AI)",0Dh,0Ah,0
cardmsg BYTE "  Cards: ",0
chipmsg BYTE "  Chips: $",0
betmsg  BYTE "  Bet: $",0
potmsg  BYTE 0Dh,0Ah,"POT: $",0

.code

; --- SimpleShuffle
SimpleShuffle PROC
    push eax ebx ecx
    mov ecx, 30
@@L:
    mov eax,52
    call RandomRange
    mov ebx,eax
    mov eax,52
    call RandomRange
    push ecx
    mov cl, deck[ebx]
    mov ch, deck[eax]
    mov deck[ebx], ch
    mov deck[eax], cl
    pop ecx
    loop @@L
    pop ecx ebx eax
    ret
SimpleShuffle ENDP

; --- PrintCard
PrintCard PROC
    push eax
    push edx
    cmp al,11
    jl short @num
    cmp al,11
    jne short @q
    mov al,'J'
    call WriteChar
    jmp short @sp
@q: cmp al,12
    jne short @k
    mov al,'Q'
    call WriteChar
    jmp short @sp
@k: cmp al,13
    jne short @a
    mov al,'K'
    call WriteChar
    jmp short @sp
@a: mov al,'A'
    call WriteChar
    jmp short @sp
@num:
    movzx eax, al
    call WriteDec
@sp:
    mov al,' '
    call WriteChar
    pop edx
    pop eax
    ret
PrintCard ENDP

ShowTable PROC
    push eax
    push edx

    call Clrscr
    mov edx, OFFSET gameTitle
    call WriteString

    ; P1
    mov edx, OFFSET p1msg
    call WriteString
    mov edx, OFFSET cardmsg
    call WriteString
    mov al, p1card1
    call PrintCard
    mov al, p1card2
    call PrintCard
    call Crlf

    mov edx, OFFSET chipmsg
    call WriteString
    movzx eax, p1chips
    call WriteDec
    call Crlf

    mov edx, OFFSET betmsg
    call WriteString
    movzx eax, p1bet
    call WriteDec
    call Crlf
    call Crlf

    ; P2
    mov edx, OFFSET p2msg
    call WriteString
    mov edx, OFFSET cardmsg
    call WriteString
    mov al, p2card1
    call PrintCard
    mov al, p2card2
    call PrintCard
    call Crlf

    mov edx, OFFSET chipmsg
    call WriteString
    movzx eax, p2chips
    call WriteDec
    call Crlf

    mov edx, OFFSET betmsg
    call WriteString
    movzx eax, p2bet
    call WriteDec
    call Crlf

    ; Pot
    mov edx, OFFSET potmsg
    call WriteString
    movzx eax, pot
    call WriteDec
    call Crlf

    pop edx
    pop eax
    ret
ShowTable ENDP

main PROC
    call Randomize
    call SimpleShuffle

    mov al, deck[0]
    mov p1card1, al
    mov al, deck[1]
    mov p1card2, al
    mov al, deck[2]
    mov p2card1, al
    mov al, deck[3]
    mov p2card2, al

    call ShowTable
    INVOKE ExitProcess, 0
main ENDP
END main
