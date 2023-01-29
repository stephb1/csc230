;
; a3part-D.asm
;
; Part D of assignment #3
;
;
; Student name:
; Student ID:
; Date of completed work:
;
; **********************************
; Code provided for Assignment #3
;
; Author: Mike Zastre (2022-Nov-05)
;
; This skeleton of an assembly-language program is provided to help you 
; begin with the programming tasks for A#3. As with A#2 and A#1, there are
; "DO NOT TOUCH" sections. You are *not* to modify the lines within these
; sections. The only exceptions are for specific changes announced on
; Brightspace or in written permission from the course instruction.
; *** Unapproved changes could result in incorrect code execution
; during assignment evaluation, along with an assignment grade of zero. ***
;


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================
;
; In this "DO NOT TOUCH" section are:
; 
; (1) assembler direction setting up the interrupt-vector table
;
; (2) "includes" for the LCD display
;
; (3) some definitions of constants that may be used later in
;     the program
;
; (4) code for initial setup of the Analog-to-Digital Converter
;     (in the same manner in which it was set up for Lab #4)
;
; (5) Code for setting up three timers (timers 1, 3, and 4).
;
; After all this initial code, your own solutions's code may start
;

.cseg
.org 0
	jmp reset

; Actual .org details for this an other interrupt vectors can be
; obtained from main ATmega2560 data sheet
;
.org 0x22
	jmp timer1

; This included for completeness. Because timer3 is used to
; drive updates of the LCD display, and because LCD routines
; *cannot* be called from within an interrupt handler, we
; will need to use a polling loop for timer3.
;
; .org 0x40
;	jmp timer3

.org 0x54
	jmp timer4

.include "m2560def.inc"
.include "lcd.asm"

.cseg
#define CLOCK 16.0e6
#define DELAY1 0.01
#define DELAY3 0.1
#define DELAY4 0.5

#define BUTTON_RIGHT_MASK 0b00000001	
#define BUTTON_UP_MASK    0b00000010
#define BUTTON_DOWN_MASK  0b00000100
#define BUTTON_LEFT_MASK  0b00001000

#define BUTTON_RIGHT_ADC  0x032
#define BUTTON_UP_ADC     0x0b0   ; was 0x0c3
#define BUTTON_DOWN_ADC   0x160   ; was 0x17c
#define BUTTON_LEFT_ADC   0x22b
#define BUTTON_SELECT_ADC 0x316

.equ PRESCALE_DIV=1024   ; w.r.t. clock, CS[2:0] = 0b101

; TIMER1 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP1=int(0.5+(CLOCK/PRESCALE_DIV*DELAY1))
.if TOP1>65535
.error "TOP1 is out of range"
.endif

; TIMER3 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP3=int(0.5+(CLOCK/PRESCALE_DIV*DELAY3))
.if TOP3>65535
.error "TOP3 is out of range"
.endif

; TIMER4 is a 16-bit timer. If the Output Compare value is
; larger than what can be stored in 16 bits, then either
; the PRESCALE needs to be larger, or the DELAY has to be
; shorter, or both.
.equ TOP4=int(0.5+(CLOCK/PRESCALE_DIV*DELAY4))
.if TOP4>65535
.error "TOP4 is out of range"
.endif

reset:
; ***************************************************
; **** BEGINNING OF FIRST "STUDENT CODE" SECTION ****
; ***************************************************

; Anything that needs initialization before interrupts
; start must be placed here.

	;initializing stack pointer
	ldi r16, low(RAMEND)
	ldi r17, high(RAMEND)
	out SPL, r16
	out SPH, r17

	call lcd_init

	.def DATAH=r25		;DATAH:DATAL  store 10 bits data from ADC
	.def DATAL=r24
	.def BOUNDARY_H=r1  ;hold high byte value of the threshold for button
	.def BOUNDARY_L=r0  ;hold low byte value of the threshold for button, r1:r
	
	;setting current charset index and top line content to -1 and an empty character respectively
	ldi r16, 0x00
	dec r16
	sts CURRENT_CHARSET_INDEX, r16
	ldi r16, ' '
	sts TOP_LINE_CONTENT, r16

	;initializing all 16 bytes of memory in current charset index to -1
	clr r16
	ldi r22, 15
	ldi r23, -1
	ldi XH, high(CURRENT_CHARSET_INDEX)
	ldi XL, low(CURRENT_CHARSET_INDEX)
loop:
	st X+, r23
	cp r16, r22
	breq done
	inc r16
	jmp loop

	;initializing all 16 bytes of memory in top line content to an empty character
	clr r16
	ldi r22, 15
	ldi r23, ' '
	ldi YH, high(TOP_LINE_CONTENT)
	ldi YL, low(TOP_LINE_CONTENT)
loop2:
	st Y+, r23
	cp r16, r22
	breq done
	inc r16
	jmp loop2

done:
	jmp following

following:
	;initializing current char index to 0
	ldi r16, 0
	sts CURRENT_CHAR_INDEX, r16

	;initializing all columns in row 0 to an empty character on the lcd panel
	ldi r16, 0
	ldi r17, 0
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 1
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 2
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 3
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 4
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 5
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 6
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 7
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 8
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 9
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 10
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 11
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 12
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 13
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 14
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 0
	ldi r17, 15
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

; ***************************************************
; ******* END OF FIRST "STUDENT CODE" SECTION *******
; ***************************************************

; =============================================
; ====  START OF "DO NOT TOUCH" SECTION    ====
; =============================================

	; initialize the ADC converter (which is needed
	; to read buttons on shield). Note that we'll
	; use the interrupt handler for timer 1 to
	; read the buttons (i.e., every 10 ms)
	;
	ldi temp, (1 << ADEN) | (1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
	sts ADCSRA, temp
	ldi temp, (1 << REFS0)
	sts ADMUX, r16

	; Timer 1 is for sampling the buttons at 10 ms intervals.
	; We will use an interrupt handler for this timer.
	ldi r17, high(TOP1)
	ldi r16, low(TOP1)
	sts OCR1AH, r17
	sts OCR1AL, r16
	clr r16
	sts TCCR1A, r16
	ldi r16, (1 << WGM12) | (1 << CS12) | (1 << CS10)
	sts TCCR1B, r16
	ldi r16, (1 << OCIE1A)
	sts TIMSK1, r16

	; Timer 3 is for updating the LCD display. We are
	; *not* able to call LCD routines from within an 
	; interrupt handler, so this timer must be used
	; in a polling loop.
	ldi r17, high(TOP3)
	ldi r16, low(TOP3)
	sts OCR3AH, r17
	sts OCR3AL, r16
	clr r16
	sts TCCR3A, r16
	ldi r16, (1 << WGM32) | (1 << CS32) | (1 << CS30)
	sts TCCR3B, r16
	; Notice that the code for enabling the Timer 3
	; interrupt is missing at this point.

	; Timer 4 is for updating the contents to be displayed
	; on the top line of the LCD.
	ldi r17, high(TOP4)
	ldi r16, low(TOP4)
	sts OCR4AH, r17
	sts OCR4AL, r16
	clr r16
	sts TCCR4A, r16
	ldi r16, (1 << WGM42) | (1 << CS42) | (1 << CS40)
	sts TCCR4B, r16
	ldi r16, (1 << OCIE4A)
	sts TIMSK4, r16

	sei

; =============================================
; ====    END OF "DO NOT TOUCH" SECTION    ====
; =============================================

; ****************************************************
; **** BEGINNING OF SECOND "STUDENT CODE" SECTION ****
; ****************************************************

polling:
	in r16, TIFR3				;register for timer 3
	sbrs r16, OCF3A				;specific bit in r16
	jmp polling

	ldi r16, (1<<OCF3A)
	out TIFR3, r16

	lds r16, BUTTON_IS_PRESSED	;checking if a button is pressed or not
	cpi r16, 1					;r16 is 1 if yes and 0 if no
	breq star

	;if no button is being pressed a dash character is displayed
	ldi r16, 1			;initializizng second row on arduino board - row 1
	ldi r17, 15			;initializing last column (16th) on arduino board - column 15
	push r16			;pushing and poping values to call lcd function initializing spot on screen
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, '-'		;initializing dash symbol to be displayed
	push r16			;calling lcd function to place the character at the previously intialized space
	call lcd_putchar
	pop r16

	jmp polling			;no button was pressed so we check again

;a button was pressed (value in r16 was 1) therefore we want to display a star on the lcd panel
star:
	ldi r16, 1			;initializing row and column to the same ones in the code for dash
	ldi r17, 15			;second row (row 1) and 16th column (column 15)
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, '*'		;initializing and placing at star character at that spot on the lcd panel
	push r16
	call lcd_putchar
	pop r16

	;clearing character that is currently on the screen (if any)
	;must do this for L, D, U, and R because it is unknown which one last appeared on the lcd panel
	ldi r16, 1
	ldi r17, 3
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 1
	ldi r17, 2
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 1
	ldi r17, 1
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

	ldi r16, 1
	ldi r17, 0
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16

	ldi r16, ' '
	push r16
	call lcd_putchar
	pop r16

;checking which was the last button pressed and branching accordingly
checking:
	;loading the value of current char index into r17 to be used later
	lds r17, CURRENT_CHAR_INDEX
	
	ldi YH, high(TOP_LINE_CONTENT)
	ldi YL, low(TOP_LINE_CONTENT)

	lds r16, LAST_BUTTON_PRESSED
	cpi r16, 'R'
	breq right_button
	cpi r16, 'U'
	breq up_button
	cpi r16, 'D'
	breq down_button
	cpi r16, 'L'
	brne checking
	jmp left_button
	
right_button:
	;setting the position of 'R' on the lcd panel to be on the second row (row 1) and 4th column (column 3)
	push r17
	ldi r16, 1
	ldi r17, 3
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16
	pop r17
	
	;setting the letter 'R' to display at that spot on the lcd panel, set previously
	ldi r16, 'R'
	push r16
	call lcd_putchar
	pop r16
	
	;right button was pressed and displayed, jump back to polling to check next
	jmp polling

up_button:
	;setting the position of 'U' on the lcd panel to be on the second row (row 1) and 3rd column (column 2)
	push r17
	ldi r16, 1
	ldi r17, 2
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16
	pop r17
	
	;setting the letter 'U' to display at that spot on the lcd panel, set previously
	ldi r16, 'U'
	push r16
	call lcd_putchar
	pop r16
	
	;going to the byte in top line content that contains the character to be placed on the lcd pannel
	lds r20, CURRENT_CHAR_INDEX
	clr r21
	
	;adding current char index to the low byte of the word in memory from top line content
	add YL, r20
	adc YH, r21
	;loading the character to r16
	ld r16, Y

	;setting the index on the lcd panel using current char index
	push r21
	push r20
	call lcd_gotoxy
	pop r20
	pop r21
	
	;displaying the character retrieved from program memory
	push r16
	call lcd_putchar
	pop r16

	;up button was pressed and displayed, jump back to polling to check next
	jmp polling

down_button:
	;setting the position of 'D' on the lcd panel to be on the second row (row 1) and 2nd column (column 1)
	push r17
	ldi r16, 1
	ldi r17, 1
	push r16 
	push r17
	call lcd_gotoxy
	pop r17
	pop r16
	pop r17
	
	;setting the letter 'D' to display at that spot on the lcd panel, set previously
	ldi r16, 'D'
	push r16
	call lcd_putchar
	pop r16
	
	;going to the byte in top line content that contains the character to be placed on the lcd pannel
	lds r20, CURRENT_CHAR_INDEX
	clr r21
	
	;adding current char index to the low byte of the word in memory from top line content
	add YL, r20
	adc YH, r21
	;loading the character to r16
	ld r16, Y

	;setting the index on the lcd panel using current char index
	push r21
	push r20
	call lcd_gotoxy
	pop r20
	pop r21

	;displaying the character retrieved from program memory
	push r16
	call lcd_putchar
	pop r16

	;down button was pressed and displayed, jump back to polling to check next
	jmp polling

left_button:
	;setting the position of 'L' on the lcd panel to be on the second row (row 1) and 1st column (column 0)
	push r17
	ldi r16, 1
	ldi r17, 0
	push r16
	push r17
	call lcd_gotoxy
	pop r17
	pop r16
	pop r17
	
	;setting the letter 'L' to display at that spot on the lcd panel, set previously
	ldi r16, 'L'
	push r16
	call lcd_putchar
	pop r16
	
	;left button was pressed and displayed, jump back to polling to check next
	jmp polling

stop:
	rjmp stop




timer1:
	push r23
	in r23, sreg
	;initializing BUTTON_IS_PRESSED to 0
	ldi r16, 0x00
	sts BUTTON_IS_PRESSED, r16

	;initializing the boundary of 900 of the ADC value
	;if the digital value obtained from the ADC is greater than 900, no button was pressed, if less than 900, a button was pressed.
	ldi r16, low(900)
	mov BOUNDARY_L, r16
	ldi r16, high(900)
	mov BOUNDARY_H, r16


	lds	r16, ADCSRA

	;bit 6 = 1 ADSC (ADC Start Conversion bit), remain 1 if conversion not done
	;ADSC changed to 0 if conversion is done
	ori r16, 0x40		;0x40 = 0b01000000
	sts	ADCSRA, r16

	;wait for it to complete, check for bit 6, the ADSC bit
wait:	lds r16, ADCSRA
		andi r16, 0x40
		brne wait

		;read the value, use XH:XL to store the 10-bit result
		lds DATAL, ADCL
		lds DATAH, ADCH

		clr r16
		;if DATAH:DATAL < BOUNDARY_H:BOUNDARY_L
		;     r16=1  a button is pressed
		;else
		;     r16=0
last:	cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brsh skip
		ldi r16, 0x01
		sts BUTTON_IS_PRESSED, r16	;storing value into BUTTON_IS_PRESSED

		;initializing the boundaries of the 'select' button
		ldi r16, low(555)
		mov BOUNDARY_L, r16
		ldi r16, high(555)
		mov BOUNDARY_H, r16

		;testing the values of the 'select' button
		;if the button is pressed, we want a star character to replace the dash but no other changes on the board
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brsh skip

		;initializing the boundaries of the 'right' button
		ldi r16, low(50)
		mov BOUNDARY_L, r16
		ldi r16, high(50)
		mov BOUNDARY_H, r16

		;setting LAST_BUTTON_PRESSED to 'R' if ADC value is less than 50
		ldi r16, 'R'
		sts LAST_BUTTON_PRESSED, r16
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brlt skip
		
		;initializing the boundaries of the 'up' button
		ldi r16, low(176)
		mov BOUNDARY_L, r16
		ldi r16, high(176)
		mov BOUNDARY_H, r16

		;setting LAST_BUTTON_PRESSED to 'U' if ADC value is less than 176 (is now known to be greater than 50)
		ldi r16, 'U'
		sts LAST_BUTTON_PRESSED, r16
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brlt skip

		;initializing the boundaries of the 'down' button
		ldi r16, low(352)
		mov BOUNDARY_L, r16
		ldi r16, high(352)
		mov BOUNDARY_H, r16

		;setting LAST_BUTTON_PRESSED to 'D' if ADC value is less than 352 (is now known to be greater than 176)
		ldi r16, 'D'
		sts LAST_BUTTON_PRESSED, r16
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brlt skip

		;initializing the boundaries of the 'left' button
		ldi r16, low(555)
		mov BOUNDARY_L, r16
		ldi r16, high(555)
		mov BOUNDARY_H, r16

		;setting LAST_BUTTON_PRESSED to 'L' if ADC value is less than 555 (is now known to be greater than 352)
		ldi r16, 'L'
		sts LAST_BUTTON_PRESSED, r16
		cp DATAL, BOUNDARY_L
		cpc DATAH, BOUNDARY_H
		brlt skip

skip:
	pop r23
	reti

; timer3:
;
; Note: There is no "timer3" interrupt handler as you must use
; timer3 in a polling style (i.e. it is used to drive the refreshing
; of the LCD display, but LCD functions cannot be called/used from
; within an interrupt handler).


timer4:
	push ZH
	push ZL

	push XH
	push XL

	push YH
	push YL

	push r16
	push r17
	push r18
	push r19
	push r20
	push r21
	push r22
	push r23

	in r23, sreg

	;checking if a button is being pressed
	lds r16, BUTTON_IS_PRESSED
	cpi r16, 1
	breq next
	jmp pops

next:
	;initializing the Z pseudo-register to point to AVAILABLE_CHARSET
	ldi r17, 0x00
	ldi ZH, high(AVAILABLE_CHARSET<<1)
	ldi ZL, low(AVAILABLE_CHARSET<<1)

;looping through AVAILABLE_CHARSET to determine its length
;once a zero iz found (end of the string) we branch out
;increment the length counter otherwise
determine_length:
	lpm r16, Z+
	cpi r16, 0x00
	breq setting
	inc r17
	jmp determine_length

setting:
	;re-setting the Z pseudo-register to point to the start of memory of AVAILABLE_CHARSET
	ldi ZH, high(AVAILABLE_CHARSET<<1)
	ldi ZL, low(AVAILABLE_CHARSET<<1)

	;initializing the X pseudo-register to point to the start of program memory for current charset index
	ldi XH, high(CURRENT_CHARSET_INDEX)
	ldi XL, low(CURRENT_CHARSET_INDEX)

	;initializing the Y pseudo-register to point to the start of program memory for top line content
	ldi YH, high(TOP_LINE_CONTENT)
	ldi YL, low(TOP_LINE_CONTENT)

	clr r19 

check_button:
	;checking what the last button pressed was
	lds r16, LAST_BUTTON_PRESSED

	;loading r20 with current char index from memory and adding it to the low byte of the word pointed to in memory by the X pseudo-register
	lds r20, CURRENT_CHAR_INDEX

	clr r21
	add XL, r20
	adc XH, r21
	add YL, r20
	adc YH, r21
	;loading the byte pointed to in current charset index into r18
	ld r18, X
	
	;incrementing current charset index by 1 if the up button was pressed
	inc r18
	cpi r16, 'U'
	breq setting_up
	dec r18

	;decrementing currennt charset index by 1 if the down button was pressed
	dec r18
	cpi r16, 'D'
	breq setting_down

	;breaking to update current char index if right button was pressed
	cpi r16, 'R'
	breq setting_right

	;breaking to update current char index if left button was pressed
	cpi r16, 'L'
	breq setting_left

;looping through AVAILABLE_CHARSET until the incremented index is found
;character to be displayed is stored in r16 afterwards
setting_up:
	lpm r16, Z+
	cp r19, r18
	breq end_up
	inc r19

	jmp setting_up

;looping through AVAILABLE_CHARSET until the decremented index is found
;character to be displayed is stored in r16 afterwards
setting_down:
	;checking the bounds so that the spring loops around if it reaches the first index
	;if current charset index is -1 or -2 we need to return it back to the last index in the string
	cpi r18, -1
	breq jump_top_string
	cpi r18, -2
	breq jump_top_string

	lpm r16, Z+
	cp r19, r18
	breq end_down
	inc r19

	jmp setting_down

jump_top_string:
	jmp top_string

;updating current char index if right button was pressed
setting_right:
	cpi r20, 15
	breq reset_right
	inc r20
	sts CURRENT_CHAR_INDEX, r20
	jmp pops

;to deal with bounds 
reset_right:
	ldi r20, -1
	jmp setting_right

;updating current char index if left button was pressed
setting_left:
	cpi r20, -1
	breq reset_left
	dec r20
	sts CURRENT_CHAR_INDEX, r20
	jmp pops

;to deal with bounds
reset_left:
	ldi r20, 15
	jmp setting_left

;once setting up is finished we need to set current charset index to its new incremented value as well as the character at the index into top line content
;after this is done we can jump to the very end - popping the registsers used off the stack
end_up:
	;checking to see if the last incrementation caused us to reach the end of the string
	;comparing index value to the length of the string minus 1
	dec r17
	cp r18, r17
	breq end_string

	;using st because we are accessing bytes in program memory of current charset index and top line content
	st X, r18
	st Y, r16
	jmp pops

;once setting down is finished we need to set current charset index to its new decremented value as well as the character at the index into top line content
;after this is done we can jump to the very end - popping the registers used off the stack
end_down:
	;using st because we are accessing bytes in program memory of current charset index and top line content
	st X, r18
	st Y, r16
	jmp pops

;in setting down, if the decremented value of current charset index has reached -1 or -2 we branch here
;this means it has reached the first value in the string and needs to loop back to the top/end of the string
top_string:
	dec r17
	mov r18, r17

	;using st because we are accessing bytes in program memory of current charset index
	st X, r18
	jmp setting_down

;in end up we check to see if the index has reached the end of the string
;if yes, we branch here and update the index to -1 to prepare for the next incrementation
end_string:
	ldi r18, -1
	;using st because we are accessing bytes in program memory of current charset index and top line content
	st X, r18
	st Y, r16

;popping registers pushed
pops:
	pop r23
	pop r22
	pop r21
	pop r20
	pop r19
	pop r18
	pop r17
	pop r16

	pop YL
	pop YH

	pop XL
	pop XH

	pop ZL
	pop ZH

	reti


; ****************************************************
; ******* END OF SECOND "STUDENT CODE" SECTION *******
; ****************************************************


; =============================================
; ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
; =============================================

; r17:r16 -- word 1
; r19:r18 -- word 2
; word 1 < word 2? return -1 in r25
; word 1 > word 2? return 1 in r25
; word 1 == word 2? return 0 in r25
;
compare_words:
	; if high bytes are different, look at lower bytes
	cp r17, r19
	breq compare_words_lower_byte

	; since high bytes are different, use these to
	; determine result
	;
	; if C is set from previous cp, it means r17 < r19
	; 
	; preload r25 with 1 with the assume r17 > r19
	ldi r25, 1
	brcs compare_words_is_less_than
	rjmp compare_words_exit

compare_words_is_less_than:
	ldi r25, -1
	rjmp compare_words_exit

compare_words_lower_byte:
	clr r25
	cp r16, r18
	breq compare_words_exit

	ldi r25, 1
	brcs compare_words_is_less_than  ; re-use what we already wrote...

compare_words_exit:
	ret

.cseg
AVAILABLE_CHARSET: .db "0123456789abcdef_", 0


.dseg

BUTTON_IS_PRESSED: .byte 1			; updated by timer1 interrupt, used by LCD update loop
LAST_BUTTON_PRESSED: .byte 1        ; updated by timer1 interrupt, used by LCD update loop

TOP_LINE_CONTENT: .byte 16			; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHARSET_INDEX: .byte 16		; updated by timer4 interrupt, used by LCD update loop
CURRENT_CHAR_INDEX: .byte 1			; ; updated by timer4 interrupt, used by LCD update loop


; =============================================
; ======= END OF "DO NOT TOUCH" SECTION =======
; =============================================


; ***************************************************
; **** BEGINNING OF THIRD "STUDENT CODE" SECTION ****
; ***************************************************

.dseg

; If you should need additional memory for storage of state,
; then place it within the section. However, the items here
; must not be simply a way to replace or ignore the memory
; locations provided up above.


; ***************************************************
; ******* END OF THIRD "STUDENT CODE" SECTION *******
; ***************************************************

