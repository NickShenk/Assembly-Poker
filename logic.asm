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
    push ecx
    push ebx
    ; first card
    mov ecx, 0
    mov cl, players[eax].first_card
    mov cx, cards[ecx]
    ; check if ace

    ; second card
    mov ebx, 0
    mov bl, players[eax].second_card
    mov bx, cards[ebx]
    ;check if ace

    pop ebx

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

    ; Player chooses hit, stay (if hit continue to hit)

    ; dealer chooses hit/stay

    ; winner decided

    call ExitProcess
  quit:
    exit
main ENDP
END main
