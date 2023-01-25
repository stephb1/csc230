; reset-rightmost.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (b). In this and other
; files provided through the semester, you will see lines of code
; indicating "DO NOT TOUCH" sections. You are *not* to modify the
; lines within these sections. The only exceptions are for specific
; changes announced on conneX or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****
;
; In a more positive vein, you are expected to place your code with the
; area marked "STUDENT CODE" sections.

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; Your task: You are to take the bit sequence stored in R16,
; and to reset the rightmost contiguous sequence of set
; by storing this new value in R25. For example, given
; the bit sequence 0b01011100, resetting the right-most
; contigous sequence of set bits will produce 0b01000000.
; As another example, given the bit sequence 0b10110110,
; the result will be 0b10110000.
;
; Your solution must work, of course, for bit sequences other
; than those provided in the example. (How does your
; algorithm handle a value with no set bits? with all set bits?)

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).

    .cseg
    .org 0

; ==== END OF "DO NOT TOUCH" SECTION ==========
	
	;ldi r16, 0b00000000
	;ldi r16, 0b11111111
	ldi R16, 0b01011100
	; ldi R16, 0b10110110
	;ldi R16, 0b10000000
	;ldi R16, 0b00000001
	;ldi R16, 0b00000010


	; THE RESULT **MUST** END UP IN R25

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

; copying value in r16 to final register r25
	MOV r25, r16

	; setting r29 equal to zero to intialize a counter
	ldi r29, 0

; starting from bit position zero (least-significant bit) check how many cleared bits there are in a row
loop:
	sbrs r25, 0
	lsr r25
	inc r29		; shift rightwards only if bit is un-set, count how many times it does this until it reaches a 1
	nop
	cpi r25, 0	; check if register is zero
	sbrs r25, 0	; if set bit is found, skip branch step
	brne loop
end:
	rjmp loop2

	; set r28 equal to zero to initialize a counter
	ldi r28, 0

; using the same process as the first loop, check how many set bits there are in a row - stop once you reach the next cleared bit
loop2:
	sbrc r25, 0
	lsr r25
	inc r28
	nop
	sbrc r25, 0
	brne loop2
end2:
	add r29, r28	; add two counters to obtain total times shifted rightwards
	ldi r28, 0
	rjmp loop3

; shift left by the total number of shifts right to return any remaining set bits to their original position
loop3:
	lsl r25
	dec r29
	brne loop3
end3:
	rjmp reset_rightmost_stop


; **** END OF "STUDENT CODE" SECTION ********** 



; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
reset_rightmost_stop:
    rjmp reset_rightmost_stop


; ==== END OF "DO NOT TOUCH" SECTION ==========


