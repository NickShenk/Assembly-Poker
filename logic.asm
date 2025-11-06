; 
;need a deck and a lightweight shuffler.
;Adds a 52-card numeric deck (2..14 = Ace) and SimpleShuffle proc.
;Shuffles once then quits.

INCLUDE Irvine32.inc

.data
; 4 suits × values 2..14 (Ace=14)
deck BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14

gameTitle BYTE "=== SIMPLE 2-PLAYER POKER ===",0Dh,0Ah
          BYTE "Highest card wins!",0Dh,0Ah,0

.code

; SimpleShuffle: swap 30 random pairs
SimpleShuffle PROC
    push eax
    push ebx
    push ecx

    mov ecx, 30
@@loop:
    mov eax, 52
    call RandomRange
    mov ebx, eax        ; i

    mov eax, 52
    call RandomRange    ; j in EAX

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

    INVOKE ExitProcess, 0
main ENDP
END main
