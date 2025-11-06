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

; CHRIS: String definitions for output messages
; Source: Irvine32 library documentation - WriteString requires null-terminated strings
; Reference: https://csc.csudh.edu/mmccullough/asm/help/source/irvinelib/writestring.htm
handPrompt BYTE "Your current hand value: ", 0
choicePrompt BYTE "Enter 1 to HIT or 2 to STAY: ", 0
dealerHandMsg BYTE "Dealer's final hand value: ", 0
youWinMsg BYTE "YOU WON!", 0
youLoseMsg BYTE "YOU LOST!", 0
cardDisplay BYTE "Card 1: ", 0
cardDisplay2 BYTE "Card 2: ", 0
; Card suit symbols using ASCII
; Source: https://www.gamedev.net/forums/topic/337396-displaying-hearts-clubs-spades-diamonds/
; ASCII codes: 3=heart, 4=diamond, 5=club, 6=spade
suitSymbols BYTE 3, 4, 5, 6  ; hearts, diamonds, clubs, spades

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
    jmp playerTurn


    hit:
    mov edx, 0
    inc ebx
    mov dl, cards[ebx * TYPE card].value ; used to store new card value
    ; jump ahead if dl > 0
    cmp dl, 0
    jg handleCard
    ; this means we picked up an ace
    ; jump ahead if ecx > 10
    cmp ecx, 10
    jg handleCard
    ; else we have an ace acting as 11 and it needs to be changed to soft
    mov players[eax].soft, 1
    mov edx, 10

    handleCard:
    add ecx, edx
    add ecx, 1
    ; check if bust, check if soft then sub ten if soft
    cmp ecx, 21
    jle playerTurn

    ; bust territory
    cmp players[eax].soft, 0
    je youLost

    ; has a soft hand so we can subtract 10 and continue
    sub ecx, 10
    mov players[eax].soft, 0
    
    playerTurn:
    ; CHRIS : display their hand amount and cards(optional for cards)
    ; Source: Irvine32 WriteString and WriteInt documentation
    ; Reference: https://csc.csudh.edu/mmccullough/asm/help/source/irvinelib/writeint.htm
    ; Reference: https://www.philadelphia.edu.jo/academics/qhamarsheh/uploads/Lecture%2016%20Procedures-I.pdf
    
    ; Display hand value message
    push eax                        ; Save player index
    push ecx                        ; Save hand value
    mov edx, OFFSET handPrompt      ; Load address of prompt string
    call WriteString                ; Display "Your current hand value: "
    pop ecx                         ; Restore hand value
    mov eax, ecx                    ; Move hand value to EAX for display
    call WriteDec                   ; Display the hand value as unsigned decimal
    call Crlf                       ; New line - carriage return/line feed
                                    ; Source: https://csc.csudh.edu/mmccullough/asm/help/source/irvinelib/crlf.htm
    pop eax                         ; Restore player index


    ; Player chooses hit, stay (if hit continue to hit)


    ; CHRIS : Take choice input
    ; Source: ReadInt procedure from Irvine32 library
    ; Reference: https://csc.csudh.edu/mmccullough/asm/help/source/irvinelib/readint.htm
    ; ReadInt reads a 32-bit signed integer from standard input into EAX
    
    push eax                        ; Save player index
    push ecx                        ; Save hand value
    mov edx, OFFSET choicePrompt    ; Load address of choice prompt
    call WriteString                ; Display "Enter 1 to HIT or 2 to STAY: "
    call ReadInt                    ; Read user input into EAX
                                    ; Reference: https://stackoverflow.com/questions/2718332/how-can-i-do-input-output-on-a-console-with-masm
    mov edi, eax                    ; Store choice in EDI temporarily
    pop ecx                         ; Restore hand value
    pop eax                         ; Restore player index
    
    ; choice (jump if choice condition is met, else stay)
    cmp edi, 1                      ; Compare choice with 1 (HIT)
    je hit                          ; If user chose 1, jump to hit
    ; Otherwise, player chose to STAY, continue to dealer's turn


    ; dealer chooses hit/stay ; make sure to mul * TYPE Player to eax for calc sum
    mov eax, TYPE Player
    mov edx, 0
    push ecx ; push player's hand value to stack
    call calcSum ; dealer's hand is now in ecx
    mov edx, ecx
    pop ecx ; return player's hand to dealer

    ; dealer hits while their hand is less than 17 or until above player's
    ; CHRIS I will store dealer's end hand value in edx display it
    jmp dealerChoice
    push ecx
    dealerHit: ; ----------------- dealer hits logic -----------------
    inc ebx ; pick new card off the top
    mov ecx, 0
    mov cl, cards[ebx * TYPE card].value ; used to store new card value
    ; jump ahead if cl > 0
    cmp cl, 0
    jg handleCardDealer
    ; this means we picked up an ace
    ; jump ahead if edx > 10
    cmp edx, 10
    jg handleCardDealer
    ; else we have an ace acting as 11 and it needs to be changed to soft
    mov players[eax].soft, 1
    mov ecx, 10

    handleCardDealer:
    add edx, ecx
    add edx, 1
    ; check if bust, check if soft then sub ten if soft
    cmp edx, 21
    jle dealerChoice

    ; bust territory
    cmp players[eax].soft, 0
    je youWon

    ; has a soft hand so we can subtract 10 and continue
    sub edx, 10
    mov players[eax].soft, 0
    
    pop ecx

    dealerChoice:
    ; hit again if less than 17 and less then ecx
    cmp edx, 17
    jl dealerHit
    cmp edx, ecx
    jl dealerHit
    ; dealer stays continues down

    ; Source: Same WriteString and WriteDec procedures used above
    push eax                        ; Save registers
    push ecx   
    push edx
    mov edx, OFFSET dealerHandMsg   ; Load dealer hand message
    call WriteString                ; Display "Dealer's final hand value: "
    pop edx
    pop ecx                         ; Restore player hand value
    pop eax                         ; Restore register
    
    push ecx                        ; Save player hand
    mov eax, edx                    ; Move dealer hand value to EAX
    call WriteDec                   ; Display dealer's hand value
    call Crlf                       ; New line
    pop ecx                         ; Restore player hand
    
    ; Determine winner by comparing player (ecx) vs dealer (edx)
    cmp ecx, edx                    ; Compare player hand to dealer hand
    jg youWon                       ; If player > dealer, player wins
    jmp youLost                     ; Otherwise, player loses

    youLost:
    ; CHRIS add a "you lose" message
    ; Source: WriteString to display null-terminated string
    ; Reference: https://people.uncw.edu/ricanekk/teaching/spring05/csc241/slides/chapt_05.pdf
    
    mov edx, OFFSET youLoseMsg      ; Load address of "YOU LOST!" message
    call WriteString                ; Display the message
    call Crlf                       ; New line
    jmp endGame                     ; Jump to end

    youWon:
    ; CHRIS add a "you won" message
    
    mov edx, OFFSET youWinMsg       ; Load address of "YOU WON!" message
    call WriteString                ; Display the message
    call Crlf                       ; New line
    
    endGame:
    call ExitProcess
  quit:
    exit
main ENDP
END main
