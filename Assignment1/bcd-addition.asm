; bcd-addition.asm
; CSC 230: Fall 2022
;
; Code provided for Assignment #1
;
; Mike Zastre (2022-Sept-22)

; This skeleton of an assembly-language program is provided to help you
; begin with the programming task for A#1, part (c). In this and other
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
; Your task: Two packed-BCD numbers are provided in R16
; and R17. You are to add the two numbers together, such
; the the rightmost two BCD "digits" are stored in R25
; while the carry value (0 or 1) is stored R24.
;
; For example, we know that 94 + 9 equals 103. If
; the digits are encoded as BCD, we would have
;   *  0x94 in R16
;   *  0x09 in R17
; with the result of the addition being:
;   * 0x03 in R25
;   * 0x01 in R24
;
; Similarly, we know than 35 + 49 equals 84. If 
; the digits are encoded as BCD, we would have
;   * 0x35 in R16
;   * 0x49 in R17
; with the result of the addition being:
;   * 0x84 in R25
;   * 0x00 in R24
;

; ANY SIGNIFICANT IDEAS YOU FIND ON THE WEB THAT HAVE HELPED
; YOU DEVELOP YOUR SOLUTION MUST BE CITED AS A COMMENT (THAT
; IS, WHAT THE IDEA IS, PLUS THE URL).



    .cseg
    .org 0

	; Some test cases below for you to try. And as usual
	; your solution is expected to work with values other
	; than those provided here.
	;
	; Your code will always be tested with legal BCD
	; values in r16 and r17 (i.e. no need for error checking).

	;99 + 99 = 98, carry = 1
	; ldi r16, 0x99
	; ldi r17, 0x99

	; 94 + 9 = 03, carry = 1
	; ldi r16, 0x94
	; ldi r17, 0x09

	; 86 + 79 = 65, carry = 1
	; ldi r16, 0x86
	; ldi r17, 0x79

	; 35 + 49 = 84, carry = 0
	; ldi r16, 0x35
	; ldi r17, 0x49

	; 32 + 41 = 73, carry = 0
	ldi r16, 0x32
	ldi r17, 0x41

; ==== END OF "DO NOT TOUCH" SECTION ==========

; **** BEGINNING OF "STUDENT CODE" SECTION **** 

	; copying values of r16 and r17 into different registers to prepare for masking
	 mov r26, r16
	 mov r27, r16
	 mov r28, r17
	 mov r29, r17

	 ; creating values to mask r26, r27, r28, and r29
	 ldi r30, 0x0F
	 ldi r31, 0xF0

	 ; isolating the right nibbles for original values in r16 and r17
	 and r26, r30
	 and r27, r31

	 ; isolating the left nibbles for original values in r16 and r17
	 and r28, r30
	 and r29, r31

	 ldi r18, 0x0A

	 ; adding right most nibbles
	 add r26, r28

	 ; adding left most nibbles
	 swap r27
	 swap r29
	 add r27, r29

	 ; checking if addition on right most nibbles resulted in a value greater than 10 (requires carry)
	 cp r26, r18
	 brge carry_right	; if yes, branch to carry right section
	 jmp check_left		; if no, jump to check left nibbles

; if value of added right nibbles is greater than 10, carry the 1 to the addition of left most nibbles and subtract 10 to return to 4-bit nibble
carry_right:
	inc r27
	sub r26, r18
	jmp check_left

; checking addition of left most nibbles, same as right most
check_left:
	 cp r27, r18
	 brge greater_than_left
	 jmp end

; branch for case that addition resulted in a carry
greater_than_left:
	inc r24
	sub r27, r18
	jmp end

; combining left and right bits using an exclusive or and copying result to r25
end:
	swap r27
	eor r26, r27
	mov r25, r26




; **** END OF "STUDENT CODE" SECTION ********** 

; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
bcd_addition_end:
	rjmp bcd_addition_end



; ==== END OF "DO NOT TOUCH" SECTION ==========
