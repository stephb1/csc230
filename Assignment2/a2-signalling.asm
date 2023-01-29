; a2-signalling.asm
; CSC 230: Fall 2022
;
; Student name:
; Student ID:
; Date of completed work:
;
; *******************************
; Code provided for Assignment #2
;
; Author: Mike Zastre (2022-Oct-15)
;
 
; This skeleton of an assembly-language program is provided to help you
; begin with the programming tasks for A#2. As with A#1, there are "DO
; NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes changes
; announced on Brightspace or in written permission from the course
; instructor. *** Unapproved changes could result in incorrect code
; execution during assignment evaluation, along with an assignment grade
; of zero. ****

.include "m2560def.inc"
.cseg
.org 0

; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

	; initializion code will need to appear in this
    ; section

 	ldi r16, low(RAMEND)
	ldi r17, high(RAMEND)
	out SPL, r16
	out SPH, r17

	ldi r18, 0xFF
	sts DDRL, r18
	out DDRB, r18


; ***************************************************
; **** END OF FIRST "STUDENT CODE" SECTION **********
; ***************************************************

; ---------------------------------------------------
; ---- TESTING SECTIONS OF THE CODE -----------------
; ---- TO BE USED AS FUNCTIONS ARE COMPLETED. -------
; ---------------------------------------------------
; ---- YOU CAN SELECT WHICH TEST IS INVOKED ---------
; ---- BY MODIFY THE rjmp INSTRUCTION BELOW. --------
; -----------------------------------------------------

	rjmp test_part_a
	; Test code


test_part_a:
	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00111000
	rcall set_leds
	rcall delay_short

	clr r16
	rcall set_leds
	rcall delay_long

	ldi r16, 0b00100001
	rcall set_leds
	rcall delay_long

	clr r16
	rcall set_leds

	rjmp end


test_part_b:
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds
	ldi r17, 0b00101010
	rcall slow_leds
	ldi r17, 0b00010101
	rcall slow_leds

	rcall delay_long
	rcall delay_long

	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds
	ldi r17, 0b00101010
	rcall fast_leds
	ldi r17, 0b00010101
	rcall fast_leds

	rjmp end

test_part_c:
	ldi r16, 0b11111000
	push r16
	rcall leds_with_speed
	pop r16

	ldi r16, 0b11011100
	push r16
	rcall leds_with_speed
	pop r16

	ldi r20, 0b00100000
test_part_c_loop:
	push r20
	rcall leds_with_speed
	pop r20
	lsr r20
	brne test_part_c_loop
	 
	rjmp end


test_part_d:
	ldi r21, 'E'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'A'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long


	ldi r21, 'M'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	ldi r21, 'H'
	push r21
	rcall encode_letter
	pop r21
	push r25
	rcall leds_with_speed
	pop r25

	rcall delay_long

	rjmp end


test_part_e:
	ldi r25, HIGH(WORD02 << 1)
	ldi r24, LOW(WORD02 << 1)
	rcall display_message
	rjmp end

end:
    rjmp end



; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

set_leds:
	; pushing registers in use
	push r16
	push r17
	push r18

	;LEDS that correspond to PORTB
	ldi r17, 0x00		
	led_1:
		ldi r18, 0x02	;setting r18 to bit position that corresponds to led1 (PortB - bit 1)
		sbrc r16, 5		;checking if bit position 5 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to empty r17 in order to set the correct bit
	led_2:
		ldi r18, 0x08	;setting r18 to bit position that corresponds to led2 (PortB - bit 3)
		sbrc r16, 4		;checking if bit position 4 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to r17 in order to set bit 3

	out PORTB, r17		;sending r17 to PortB to output results for leds 1 and 2

	;LEDS that correspond to PORTL
	ldi r17, 0x00		;setting r17 to zero because we are working on PortL now
	led_3:
		ldi r18, 0x02	;setting r18 to bit position that corresponds to led3 (PortL - bit 1)
		sbrc r16, 3		;checking if bit position 3 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to r17 in order to set bit 1
	led_4:
		ldi r18, 0x08	;setting r18 to bit position that corresponds to led4 (PortL - bit 3)
		sbrc r16, 2		;checking if bit position 2 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to r17 in order to set bit 3
	led_5:
		ldi r18, 0x20	;setting r18 to bit position that corresponds to led5 (PortL - bit 5)
		sbrc r16, 1		;checking if bit position 1 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to r17 in order to set bit 5
	led_6:
		ldi r18, 0x80	;setting r18 to bit position that corresponds to led6 (PortL - bit 7)
		sbrc r16, 0		;checking if bit position 0 in r16 is set
		add r17, r18	;if it is set, we add value of r18 to r17 in order to set bit 7

	sts PORTL, r17		;sending r17 to PortL to output results for leds 3, 4, 5, and 6

	;popping registers used
	pop r18
	pop r17
	pop r16

	;returning call
	ret


slow_leds:
	;pushing registers in use
	push r16
	push r17
	push r18

	mov r16, r17	;copy r17 to r16 so we can call set_leds with the correct register
	call set_leds	;calling set_leds
	call delay_long	;calling delay_long to delay about 1 sec

	;sending empty register to PortL and PortB to turn off all the LEDS
	ldi r18, 0x00
	sts PORTL, r18
	out PORTB, r18

	;popping registers used
	pop r18
	pop r17
	pop r16

	;returning call
	ret


fast_leds:
	;pushing registers in use
	push r16
	push r17
	push r18
	
	mov r16, r17		;copy r17 to r16 so we can call set_leds with the correct register
	call set_leds		;calling set_leds
	call delay_short	;calling delay_short to delay about 0.25 of a sec

	;sending empty register to PortL and PortB to turn off all the LEDS
	ldi r18, 0x00
	sts PORTL, r18
	out PORTB, r18

	;popping registers used
	pop r18
	pop r17
	pop r16

	;returning call
	ret


leds_with_speed:
	;pushing registers in use
	push ZH
	push ZL
	
	push r16
	push r17
	push r18

	;loading stack pointer to z register
	in ZH, SPH
	in ZL, SPL

	;loading highest memory addres of stack into r16 - finding the first thing that was pushed onto the stack through the position of the stack pointer
	ldd r16, Z+9
	mov r17, r16

	;checking if bit 7 and 6 are set in r16
	ldi r18, 0x00
	bit_7:
		sbrc r16, 7
		inc r18 ;using r18 as a counter - incrementing each time the bit is set
	bit_6:
		sbrc r16, 6
		inc r18

	;if both bits are set, the value in r18 should be 2
	;therefore, check if bit 1 in r18 is set
	check:
		sbrc r18, 1
		call slow_leds	;if bit 1 in r18 is set, call slow_leds to get a 1 sec delay

		sbrs r18, 1		;if bit 1 in r18 is not set, call fast_leds to get a 0.25 sec delay
		call fast_leds

	;sending empty register to PortL and PortB to turn off all the LEDS
	ldi r18, 0x00
	sts PORTL, r18
	out PORTB, r18

	;popping registers used
	pop r18
	pop r17
	pop r16

	pop ZL
	pop ZH

	;returning call
	ret


; Note -- this function will only ever be tested
; with upper-case letters, but it is a good idea
; to anticipate some errors when programming (i.e. by
; accidentally putting in lower-case letters). Therefore
; the loop does explicitly check if the hyphen/dash occurs,
; in which case it terminates with a code not found
; for any legal letter.

encode_letter:
	;pushing registers in use
	push ZH
	push ZL

	push r21
	push r16
	push r17
	push r18

	;loading stack pointer to z register
	in ZH, SPH
	in ZL, SPL

	;loading highest memory addres of stack into r17 - finding the first thing that was pushed onto the stack through the position of the stack pointer
	ldd r17, Z+10

	;initializing the z-pointer to access databytes in PATTERNS
	ldi ZH, high(PATTERNS<<1)
	ldi ZL, low(PATTERNS<<1)

	;initializing values 
	ldi r18, 0x40 ;this will be used as a counter for the corresponding 6 symbols assigned to each letter, used to inform the LED pattern
	ldi r25, 0x00 ;we want our final value to end up in r25

	;looping through to find letter in memory that corresponds to the value in r17
	find_letter:
		lpm r16, Z+
 		cp r16, r17
		brne find_letter

	;once the correct letter in memory is found, 
	get_pattern:
		;each time we load the next constant in program memory, shift the counter right by 1 to indicate so
		lpm r16, Z+
		lsr r18

		;compare the value retrieved from program memory to 0x6F, which corresponds to an "o", meaning that led is on (bit position in r25 is set)
		cpi r16, 0x6F
		breq set_bit ;If yes, break to set_bit

		;checking to see if the counter has been shifted all the way, to account for the 6 leds. If yes, break to section of code that checks the speeds at which the lights should flash
		cpi r18, 0x01
		breq check_speed1

		cpi r18, 0x00
		breq check_speed0
		
		;If counter has not finsihed, loop through get_pattern again
		rjmp get_pattern

	;If code from get_pattern breaks here, that means it has found a bit that must be set in r25. Set the corresponding bit by adding counter (r18) to empty r25. 
	;because we are shifting r18 rightwards, there will only be one set bit, and that bit will correspond to the "o" in the pattern for the current letter
	set_bit:
		add r25, r18
		rjmp get_pattern ;jump back to get_pattern
	
	;counter has now run through all 6 positions, checking set LEDS
	;check if the next constant in program memory is 0x01. If yes, break to slow, then jump to register pops in last
	check_speed1:
		lpm r16, Z+
		cpi r16, 0x01
		breq slow

		rjmp last
	
	check_speed0:
		cpi r16, 0x01
		breq slow

		rjmp last

	;set the first two bits in register r25 to indicate that this light pattern must be delayed about 1 sec
	slow:
		ldi r18, 0xC0
		add r25, r18

	;popping registers used
	last:
		pop r18
		pop r17
		pop r16
		pop r21
		
		pop ZL
		pop ZH

		;returning call
		ret


display_message:
	;pushing registers in use
	push ZH
	push ZL

	push r24
	push r25
	push r16
	push r17

	;moving byte addresses of message in program memory from r25 and r24 into the high and low bytes of the z-register respectively
	mov ZH, r25
	mov ZL, r24


	checking:
		lpm r16, Z+		;finding letter required in program memory and loading it into r16
		cpi r16, 0x00	;comparing r16 to 0, which would mean it has reached the end of the message
		breq final		;If yes, break to final pops of registers
		
		mov r17, r16			;copying value of r16 into r17
		push r17				;pushing new value of r17 onto the stack in order to call encode_letter
		call encode_letter		;calling encode_letter with value in r17 pushed onto the stack
		pop r17					;popping r17 to return to its previous value
		mov r17, r25			;copying r25 to r17 - the value that was returned from encode_letter
		push r17				;pushing r17 into stack in order to call leds_with_speed
		call leds_with_speed	;calling leds_with_speed with value in r17 pushed onto the stack
		call delay_short		;calling delay_short twice for timing purposes
		call delay_short
		pop r17					;popping r17 from stack to return to its previous value

		rjmp checking			;jumping back up to checking until a 0 is found, indicating the end of the message

	;popping registers used
	final:
		pop r17
		pop r16
		pop r25
		pop r24

		pop ZL
		pop ZH

		;returning call
		ret


; ****************************************************
; **** END OF SECOND "STUDENT CODE" SECTION **********
; ****************************************************




; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; about one second
delay_long:
	push r16

	ldi r16, 14
delay_long_loop:
	rcall delay
	dec r16
	brne delay_long_loop

	pop r16
	ret


; about 0.25 of a second
delay_short:
	push r16

	ldi r16, 4
delay_short_loop:
	rcall delay
	dec r16
	brne delay_short_loop

	pop r16
	ret

; When wanting about a 1/5th of a second delay, all other
; code must call this function
;
delay:
	rcall delay_busywait
	ret


; This function is ONLY called from "delay", and
; never directly from other code. Really this is
; nothing other than a specially-tuned triply-nested
; loop. It provides the delay it does by virtue of
; running on a mega2560 processor.
;
delay_busywait:
	push r16
	push r17
	push r18

	ldi r16, 0x08
delay_busywait_loop1:
	dec r16
	breq delay_busywait_exit

	ldi r17, 0xff
delay_busywait_loop2:
	dec r17
	breq delay_busywait_loop1

	ldi r18, 0xff
delay_busywait_loop3:
	dec r18
	breq delay_busywait_loop2
	rjmp delay_busywait_loop3

delay_busywait_exit:
	pop r18
	pop r17
	pop r16
	ret


; Some tables
.cseg
.org 0x600

PATTERNS:
	; LED pattern shown from left to right: "." means off, "o" means
    ; on, 1 means long/slow, while 2 means short/fast.
	.db "A", "..oo..", 1
	.db "B", ".o..o.", 2
	.db "C", "o.o...", 1
	.db "D", ".....o", 1
	.db "E", "oooooo", 1
	.db "F", ".oooo.", 2
	.db "G", "oo..oo", 2
	.db "H", "..oo..", 2
	.db "I", ".o..o.", 1
	.db "J", ".....o", 2
	.db "K", "....oo", 2
	.db "L", "o.o.o.", 1
	.db "M", "oooooo", 2
	.db "N", "oo....", 1
	.db "O", ".oooo.", 1
	.db "P", "o.oo.o", 1
	.db "Q", "o.oo.o", 2
	.db "R", "oo..oo", 1
	.db "S", "....oo", 1
	.db "T", "..oo..", 1
	.db "U", "o.....", 1
	.db "V", "o.o.o.", 2
	.db "W", "o.o...", 2
	.db "W", "oo....", 2
	.db "Y", "..oo..", 2
	.db "Z", "o.....", 2
	.db "-", "o...oo", 1   ; Just in case!

WORD00: .db "HELLOWORLD", 0, 0
WORD01: .db "THE", 0
WORD02: .db "QUICK", 0
WORD03: .db "BROWN", 0
WORD04: .db "FOX", 0
WORD05: .db "JUMPED", 0, 0
WORD06: .db "OVER", 0, 0
WORD07: .db "THE", 0
WORD08: .db "LAZY", 0, 0
WORD09: .db "DOG", 0

; =======================================
; ==== END OF "DO NOT TOUCH" SECTION ====
; =======================================

