;  7
; Why: Determine winner by highest card; loop hands until broke.
; What: Adds FindWinner + continue prompt + game over check.

INCLUDE Irvine32.inc

.data
;
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

yourTurn BYTE 0Dh,0Ah,"Your turn - (C)all, (R)aise $10, (F)old: ",0
aiCallStr  BYTE "AI calls",0Dh,0Ah,0
aiCheckStr BYTE "AI checks",0Dh,0Ah,0
aiFoldStr  BYTE "AI folds",0Dh,0Ah,0

winP1 BYTE 0Dh,0Ah,"*** YOU WIN $",0
winP2 BYTE 0Dh,0Ah,"*** AI WINS $",0
winEnd BYTE " ***",0Dh,0Ah,0
contMsg BYTE 0Dh,0Ah,"Press any key for next hand...",0
overMsg BYTE 0Dh,0Ah,"GAME OVER - Someone is broke!",0Dh,0Ah,0
raiseAmt WORD 10

.code
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

BettingRound PROC
    push eax
    push ebx
    push ecx
    push edx


; Winner by highest of the two cards each
FindWinner PROC
    push eax
    push ebx
    push ecx
    push edx

    ; best P1 in CL
    mov al, p1card1
    mov bl, p1card2
    cmp al, bl
    jge @p1ok
    mov al, bl
@p1ok:
    mov cl, al

    ; best P2 in DL
    mov al, p2card1
    mov bl, p2card2
    cmp al, bl
    jge @p2ok
    mov al, bl
@p2ok:
    mov dl, al

    cmp cl, dl
    jg  @p1wins
    jl  @p2wins

    ; tie -> split pot
    mov ax, pot
    shr ax, 1
    add p1chips, ax
    add p2chips, ax
    jmp @done

@p1wins:
    mov ax, pot
    add p1chips, ax
    mov edx, OFFSET winP1
    call WriteString
    movzx eax, pot
    call WriteDec
    mov edx, OFFSET winEnd
    call WriteString
    jmp @done

@p2wins:
    mov ax, pot
    add p2chips, ax
    mov edx, OFFSET winP2
    call WriteString
    movzx eax, pot
    call WriteDec
    mov edx, OFFSET winEnd
    call WriteString

@done:
    mov pot, 0
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FindWinner ENDP

main PROC
NewHand:
    ; reset hand state
    mov pot, 0
    mov currentBet, 0
    mov p1bet, 0
    mov p2bet, 0

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
    call BettingRound
    call ShowTable

    cmp pot, 0
    je @skipShowdown
    call FindWinner

@skipShowdown:
    mov edx, OFFSET contMsg
    call WriteString
    call ReadChar

    cmp p1chips, 0
    jle @gameover
    cmp p2chips, 0
    jle @gameover
    jmp NewHand

@gameover:
    mov edx, OFFSET overMsg
    call WriteString
    INVOKE ExitProcess, 0
main ENDP
END main
