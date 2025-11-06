; COMMIT 1
; Why: The full poker rules path was getting too complex for assembly.
; This commit resets scope to an ultra-simple 2-player high-card game.
; What: Runnable skeleton that prints a title and exits cleanly.

INCLUDE Irvine32.inc

.data
gameTitle BYTE "=== SIMPLE 2-PLAYER POKER ===",0Dh,0Ah
          BYTE "Highest card wins!",0Dh,0Ah,0
nl BYTE 0Dh,0Ah,0

.code
main PROC
    call Clrscr
    mov edx, OFFSET gameTitle
    call WriteString
    call Crlf
    INVOKE ExitProcess, 0
main ENDP
END main
