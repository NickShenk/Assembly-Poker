; COMMIT 3
; Why: We need minimal player state and a way to see dealt cards.
; What: Adds p1/p2 cards/chips/bets/pot and deals first 4 cards after shuffle.
; Output: Prints raw numbers for sanity.

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

.data?
tmp DWORD ?

.code
SimpleShuffle PROC
    push eax
    push ebx
    push ecx
    mov ecx, 30
@@loop:
    mov eax, 52
    call RandomRange
    mov ebx, eax
    mov eax, 52
    call RandomRange
    push ecx
    mov cl, deck[ebx]
    mov ch, deck[eax]
    mov deck[ebx], ch
    mov deck[eax], cl
    pop ecx
    loop @@loop
    pop ecx
    pop ebx
    pop eax
    ret
SimpleShuffle ENDP

main PROC
    call Clrscr
    mov edx, OFFSET gameTitle
    call WriteString

    call Randomize
    call SimpleShuffle

    ; deal first 4 cards
    mov al, deck[0]  ; p1
    mov p1card1, al
    mov al, deck[1]
    mov p1card2, al
    mov al, deck[2]  ; p2
    mov p2card1, al
    mov al, deck[3]
    mov p2card2, al

    ; show as numbers (temporary)
    movzx eax, p1card1
    call WriteDec
    mov al, ' '
    call WriteChar
    movzx eax, p1card2
    call WriteDec
    call Crlf
    movzx eax, p2card1
    call WriteDec
    mov al, ' '
    call WriteChar
    movzx eax, p2card2
    call WriteDec
    call Crlf

    INVOKE ExitProcess, 0
main ENDP
END main
