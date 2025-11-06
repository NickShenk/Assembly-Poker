;INCLUDE ui.INC
INCLUDE IRVINE32.INC
.data
card STRUCT
 value BYTE ?
 suit BYTE ?
card ENDS

cards card 52 DUP(<>) ; Found online how to initialize a struct array https://stackoverflow.com/questions/75139036/array-of-custom-structs-masm-windows-api
random WORD ?


Player STRUCT
 first_card BYTE 0 ; index of card in deck
 second_card BYTE 0 ; index of card in deck
 soft BYTE 0; keep track if there is an Ace or not (this means sum of values can be subtracted by 10)
 bet WORD 0
 balance WORD 1000
Player ENDS


players Player 2 DUP(<>) ; Create dealer and player

.code

calcSum PROC ; eax stores player, ecx should store the sum at the end
    push ebx

    ;reset soft flag
    mov players[eax].soft, 0

    ; first card
    mov ecx, 0
    mov cl, players[eax].first_card
    mov cl, cards[ecx].value

    cmp cx, 9
    jle notFace
    mov cx, 9

    notFace:


    ; check if ace
    cmp cx, 0
    jne notAce
    mov players[eax].soft, 1
    mov ecx, 10
    notAce:
    ; second card
    mov ebx, 0
    mov bl, players[eax].second_card
    mov bl, cards[ebx * TYPE card].value
    cmp bx, 9
    jle notFace2

    mov bx, 9

    notFace2:
    ;check if ace
    cmp bx, 0
    jne notAce2
    mov players[eax].soft, 1
    mov ebx, 10
    notAce2:
    ; add two cards
    add ecx, ebx

    add ecx, 2 ; this should align it with real values rather than each being 1 lower

    pop ebx
    ret
calcSum ENDP

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
    jge modloop
    mov cards[ecx * TYPE card].value, al ; eax mod 13, al is right most byte
    
    cmp ecx,0 
    jnz initialize
    ; end of intialization




    start:
    ; shuffle deck
    ;randomize learned using this https://stackoverflow.com/questions/10963554/generate-random-number-in-a-range-in-assembly
    call randomize

    DealHand:
    mov ecx, 52
    
    shuffle:
    dec ecx
    ; Fisher Yates algorithm
    mov eax, ecx
    call randomrange
    ; ecx = pos and eax = random pos to swap with
    mov edx, eax
    ; swap
    ; swap values
    mov al, cards[ecx * TYPE card].value
    mov bl, cards[edx * TYPE card].value
    mov cards[ecx * TYPE card].value, bl
    mov cards[edx * TYPE card].value, al
    ; swap suits
    mov al, cards[ecx * TYPE card].suit
    mov bl, cards[edx * TYPE card].suit
    mov cards[ecx * TYPE card].suit, bl
    mov cards[edx * TYPE card].suit, al
    ; return to top of shuffle
    
    cmp ecx, 1
    jg shuffle
    ; end of shuffle
    
    ; DEAL CARDS TO PLAYERS
    
    mov ecx, 0
    dealPlayers:
    mov ebx, ecx ; eax is used to track card index while ecx is tracking player index
    mov eax, ecx ; used for type player multiplication

    mov edi, TYPE Player
    mul edi


    shl ebx, 1
    mov players[eax].first_card, bl
    inc ebx
    mov players[eax].second_card, bl
    inc ecx
    cmp ecx, 2
    jne dealPlayers
    ; EBX now stores the top of the card pile ! IMPORTANT !

    ; round of bets

    ; end of betting

    ; calc player's card values
    mov eax, 0
    call calcSum ; this will make ecx the value of the cards combined and set soft to 1 or 0
    mov edx, 0
    mov dl, cards[ebx * TYPE card].value ; used to store new card value


    decision:
    ; Player chooses hit, stay (if hit continue to hit)


    ; if hit
    inc ebx; pick card off top of deck


    ; if stay, just continue to dealer's turn

    ; dealer chooses hit/stay

    ; winner decided

    youLost:

    youWon:

    call ExitProcess
  quit:
    exit
main ENDP
END main
