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
 cards WORD 4 DUP(0) ; data structure for finding flushes, straights, pairs, ect.
 bet WORD 0
 balance WORD 1000
Player ENDS


players Player 5 DUP(<>) ; Create 5 players

.code

fillTable PROC ; eax stores the current player and ebx the current card
    push ecx

    mov si, 1 ; add 1 to flip one bit (value)
    mov edx, 0 ; clear edx
    mov edi, 0 ; clear edi
    mov dl, cards[ebx * TYPE card].suit
    mov di, players[eax].cards[edx]
    mov cl, cards[ebx * TYPE card].value
    shl si, cl
    or di, si
    mov players[eax].cards[edx], di

    pop ecx
    ret
fillTable ENDP

fillPlayers PROC
     NextPlayer:
    mov eax, 0
    call fillTable
    inc eax
    cmp eax, 5
    jne NextPlayer
    ret
fillPlayers ENDP

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

    mov players[eax].cards[0], 0
    mov players[eax].cards[1], 0
    mov players[eax].cards[2], 0
    mov players[eax].cards[3], 0

    shl ebx, 1
    mov players[eax].first_card, bl
    call fillTable ; hope this worked correctly :(
    inc ebx
    mov players[eax].second_card, bl
    call fillTable
    inc ecx
    cmp ecx, 5
    jne dealPlayers
    ; EBX now stores the top of the card pile ! IMPORTANT !

    ; round of bets

    ; end of betting

    ; draw 3 cards
    mov ecx, 3
    NextCard:
    inc ebx ; card off the top of the deck
    call fillPlayers
    dec ecx
    cmp ecx, 0
    jnz NextCard
    ; second round of betting
    ; end of betting
    ; draw 1 card
    inc ebx ; card off the top of the deck
    call fillPlayers
    ; third round of betting
    ; end of betting
    ; draw one card
    inc ebx ; card off the top of the deck
    call fillPlayers
    ; last round of betting
    ; end of betting
    ; announce winner

    ; end of intializing each player

    call ExitProcess
  quit:
    exit
main ENDP
END main
