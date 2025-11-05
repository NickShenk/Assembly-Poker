INCLUDE ui.INC
INCLUDE IRVINE32.INC
.data
card STRUCT
 value BYTE ?
 suit BYTE ?
card ENDS
Player STRUCT
 cards WORD 4 DUP(0)
Player ENDS
.code
main PROC
    call ExitProcess
  quit:
    exit
main ENDP
END main
