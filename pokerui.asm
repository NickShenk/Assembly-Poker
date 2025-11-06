; pokerui.asm - Poker UI routines for display after testing doe
INCLUDE Irvine32.inc

.data
chipsMsg    BYTE " Chips: ",0
betMsg      BYTE " Bet: ",0

playerColors DWORD lightGreen+(black*16), lightCyan+(black*16), lightMagenta+(black*16), lightBlue+(black*16)

centerTitleMsg  BYTE 0Dh,0Ah,"==== COMMUNITY CARDS ====   Pot: $120   Street: FLOP",0Dh,0Ah,0
centerCardsMsg  BYTE "  [AH][TS][8C][  ][  ]",0Dh,0Ah,0

EXTERN players : DWORD
EXTERN numPlayers : DWORD

.code

; 
; DrawPokerTable: Refactored to pull from backend 'players' array now from back
; Call from Nick's main or game flow.
; lets go

DrawPokerTable PROC
    call Clrscr

    mov esi, 0                        ; Seat index (player number 0...N)
    mov ecx, numPlayers               ; Total number of players to display

drawSeatsLoop:
    mov eax, [playerColors + esi*4]
    call SetTextColor

    ; Print player name (assumes Player struct has name as BYTE[8], null-terminated)
    mov edx, [players + esi*SIZEOF Player]       
    call WriteString                

    ; Print chips/balance field
    mov eax, [players + esi*SIZEOF Player + 12]  
    mov edx, OFFSET chipsMsg
    call WriteString
    mov edx, eax
    call WriteDec

    ; Print bet field
    mov eax, [players + esi*SIZEOF Player + 8]   
    mov edx, OFFSET betMsg
    call WriteString
    mov edx, eax
    call WriteDec

    call Crlf

    inc esi
    cmp esi, ecx
    jl drawSeatsLoop

    ; Community cards and round info
    mov eax, yellow + (black*16)
    call SetTextColor
    mov edx, OFFSET centerTitleMsg
    call WriteString

    mov eax, lightRed + (black*16)
    call SetTextColor
    mov edx, OFFSET centerCardsMsg
    call WriteString

    mov eax, white + (black*16)
    call SetTextColor

    ret
DrawPokerTable ENDP

END
