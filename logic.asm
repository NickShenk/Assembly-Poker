; SIMPLIFIED PO - Version 8: final Final Release
; 
; PROJECT EVOLUTION SUMMARY:
; Originally planned as a full poker game with complex hand evaluation
; (flushes, straights, pairs, etc.) using bit manipulation and structures.
; After realizing the complexity of implementing full poker rules in assembly,
; we pivoted to a simpler "high card wins" version that focuses on core
; game mechanics: shuffling, dealing, betting, and winner determination.
;
; FINAL FEATURES:
; - 2-player poker (Human vs AI)
; - Simple high-card-wins rules
; - Deck shuffling using random swaps
; - Betting system with Call/Raise/Fold options
; - AI opponent with basic decision making
; - Continuous play until bankruptcy
; - Clean UI with game state display
;
; TECHNICAL IMPROVEMENTS FROM ORIGINAL:
; - Fixed MASM reserved word conflicts (title -> gameTitle)
; - Corrected register size mismatches (BYTE to WORD for raiseAmt)
; - Added proper register preservation in all procedures
; - Simplified from 5 players to 2 for better gameplay
; - Removed complex bit manipulation for hand evaluation

INCLUDE Irvine32.inc

.data
; Simple card deck - values 2-14 (14=Ace)
; 52 cards total: 4 suits x 13 values
deck BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14
     BYTE 2,3,4,5,6,7,8,9,10,11,12,13,14

; Player 1 (Human) data
p1card1 BYTE ?
p1card2 BYTE ?
p1chips WORD 1000
p1bet WORD 0

; Player 2 (AI) data
p2card1 BYTE ?
p2card2 BYTE ?
p2chips WORD 1000
p2bet WORD 0

; Game state variables
pot WORD 0
currentBet WORD 0

; UI Messages
gameTitle BYTE "=== SIMPLE 2-PLAYER POKER ===",0Dh,0Ah
          BYTE "Highest card wins!",0Dh,0Ah,0Dh,0Ah,0
p1msg BYTE "Player 1 (YOU)",0Dh,0Ah,0
p2msg BYTE "Player 2 (AI)",0Dh,0Ah,0
cardmsg BYTE "  Cards: ",0
chipmsg BYTE "  Chips: $",0
betmsg BYTE "  Bet: $",0
potmsg BYTE 0Dh,0Ah,"POT: $",0
nl BYTE 0Dh,0Ah,0

; Betting interface right here
yourTurn BYTE 0Dh,0Ah,"Your turn - (C)all, (R)aise $10, (F)old: ",0
raiseAmt WORD 10  ; Fixed from BYTE to WORD

; AI action messages
aiCallStr BYTE "AI calls",0Dh,0Ah,0
aiCheckStr BYTE "AI checks",0Dh,0Ah,0
aiFoldStr BYTE "AI folds",0Dh,0Ah,0

; Game result messages
winP1 BYTE 0Dh,0Ah,"*** YOU WIN $",0
winP2 BYTE 0Dh,0Ah,"*** AI WINS $",0
winEnd BYTE " ***",0Dh,0Ah,0

; Game flow messages
contMsg BYTE 0Dh,0Ah,"Press any key for next hand...",0
overMsg BYTE 0Dh,0Ah,"GAME OVER - Someone is broke!",0Dh,0Ah,0

.code


; SimpleShuffle - Randomly shuffle the deck
; Uses 30 random swaps for good randomization
; Algorithm: Simplified Fisher-Yates shuffle
SimpleShuffle PROC
    push ecx
    push eax
    push ebx
    
    mov ecx, 30         ; Number of swaps
ShuffleLoop:
    mov eax, 52
    call RandomRange    ; Get random index 1
    mov ebx, eax
    
    mov eax, 52
    call RandomRange    ; Get random index 2
    
    ; Swap cards at the two indices
    push ecx
    mov cl, deck[ebx]
    mov ch, deck[eax]
    mov deck[ebx], ch
    mov deck[eax], cl
    pop ecx
    
    loop ShuffleLoop
    
    pop ebx
    pop eax
    pop ecx
    ret
SimpleShuffle ENDP


; PrintCard - Display card value with face cards
; Input: AL = card value (2-14)
; Converts 11=J, 12=Q, 13=K, 14=A

PrintCard PROC
    push eax
    push edx
    
    cmp al, 11
    jl JustNumber
    
    cmp al, 11
    jne NotJack
    mov al, 'J'
    call WriteChar
    jmp Done
    
NotJack:
    cmp al, 12
    jne NotQueen
    mov al, 'Q'
    call WriteChar
    jmp Done
    
NotQueen:
    cmp al, 13
    jne NotKing
    mov al, 'K'
    call WriteChar
    jmp Done
    
NotKing:
    mov al, 'A'
    call WriteChar
    jmp Done
    
JustNumber:
    movzx eax, al
    call WriteDec
    
Done:
    mov al, ' '
    call WriteChar
    
    pop edx
    pop eax
    ret
PrintCard ENDP

; ShowTable - Display complete game state
; Shows both players' cards, chips, bets, and pot
;
ShowTable PROC
    push eax
    push edx
    
    call Clrscr
    
    mov edx, OFFSET gameTitle
    call WriteString
    
    ; Display Player 1 info
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
    
    ; Display Player 2 info
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
    
    ; Display pot
    mov edx, OFFSET potmsg
    call WriteString
    movzx eax, pot
    call WriteDec
    call Crlf
    
    pop edx
    pop eax
    ret
ShowTable ENDP

;
; BettingRound - Handle one round of betting
; Player options: Call, Raise $10, or Fold
; AI uses simple probability (80% call, 20% fold)
;
BettingRound PROC
    push eax
    push ebx          ; Fixed: Added register preservation
    push ecx          ; Fixed: Added register preservation
    push edx
    
    ; Player 1 (Human) turn
    mov edx, OFFSET yourTurn
    call WriteString
    call ReadChar
    call WriteChar
    call Crlf
    
    cmp al, 'F'
    je P1Folds
    cmp al, 'f'
    je P1Folds
    
    cmp al, 'R'
    je P1Raises
    cmp al, 'r'
    je P1Raises
    
    ; Default: Call
    mov ax, currentBet
    mov bx, p1bet
    sub ax, bx
    
    cmp ax, 0
    je P1Done           ; It's a check
    
    ; Call the difference
    add p1bet, ax
    sub p1chips, ax
    add pot, ax
    jmp P1Done
    
P1Raises:
    mov ax, raiseAmt    ; Both are WORD now
    add currentBet, ax
    
    mov ax, currentBet
    mov bx, p1bet
    sub ax, bx
    
    add p1bet, ax
    sub p1chips, ax
    add pot, ax
    jmp P1Done
    
P1Folds:
    ; Player 2 wins pot immediately
    mov ax, pot
    add p2chips, ax
    mov pot, 0
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
    
P1Done:
    ; Player 2 (AI) turn - simple logic
    mov eax, 100
    call RandomRange
    
    cmp eax, 20
    jl AIFolds
    
    ; AI calls
    mov ax, currentBet
    mov bx, p2bet
    sub ax, bx
    
    cmp ax, 0
    je AIChecks
    
    add p2bet, ax
    sub p2chips, ax
    add pot, ax
    
    mov edx, OFFSET aiCallStr
    call WriteString
    jmp BetDone
    
AIChecks:
    mov edx, OFFSET aiCheckStr
    call WriteString
    jmp BetDone
    
AIFolds:
    ; Player 1 wins
    mov ax, pot
    add p1chips, ax
    mov pot, 0
    mov edx, OFFSET aiFoldStr
    call WriteString
    
BetDone:
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
BettingRound ENDP

;
; FindWinner - Compare highest cards
; Simple rule: highest single card wins
; Ties split the pot evenly
;
FindWinner PROC
    push eax
    push ebx
    push ecx          ; Fixed: Added register preservation
    push edx
    
    ; Find player 1's highest card
    mov al, p1card1
    mov bl, p1card2
    cmp al, bl
    jge P1Max
    mov al, bl
P1Max:
    mov cl, al          ; CL = P1's best
    
    ; Find player 2's highest card
    mov al, p2card1
    mov bl, p2card2
    cmp al, bl
    jge P2Max
    mov al, bl
P2Max:
    mov dl, al          ; DL = P2's best
    
    ; Compare
    cmp cl, dl
    jg P1Wins
    jl P2Wins
    
    ; Tie - split pot
    mov ax, pot
    shr ax, 1
    add p1chips, ax
    add p2chips, ax
    jmp WinDone
    
P1Wins:
    mov ax, pot
    add p1chips, ax
    mov edx, OFFSET winP1
    call WriteString
    movzx eax, pot
    call WriteDec
    mov edx, OFFSET winEnd
    call WriteString
    jmp WinDone
    
P2Wins:
    mov ax, pot
    add p2chips, ax
    mov edx, OFFSET winP2
    call WriteString
    movzx eax, pot
    call WriteDec
    mov edx, OFFSET winEnd
    call WriteString
    
WinDone:
    mov pot, 0
    
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
FindWinner ENDP

;
; Main Program - Game loop
; Continues until one player runs out of chips
;
main PROC
    call Randomize      ; Initialize RNG
    
NewHand:
    ; Reset for new hand
    mov pot, 0
    mov currentBet, 0
    mov p1bet, 0
    mov p2bet, 0
    
    ; Shuffle deck
    call SimpleShuffle
    
    ; Deal cards (first 4 from shuffled deck)
    mov al, deck[0]
    mov p1card1, al
    mov al, deck[1]
    mov p1card2, al
    mov al, deck[2]
    mov p2card1, al
    mov al, deck[3]
    mov p2card2, al
    
    ; Show table
    call ShowTable
    
    ; Betting
    call BettingRound
    
    ; Show final table
    call ShowTable
    
    ; If pot is 0, someone folded
    cmp pot, 0
    je SkipShowdown
    
    ; Showdown
    call FindWinner
    
SkipShowdown:
    ; Continue?
    mov edx, OFFSET contMsg
    call WriteString
    call ReadChar
    
    ; Check if anyone is broke
    cmp p1chips, 0
    jle GameOver
    cmp p2chips, 0
    jle GameOver
    
    jmp NewHand
    
GameOver:
    mov edx, OFFSET overMsg
    call WriteString
    
    INVOKE ExitProcess, 0
main ENDP
END main