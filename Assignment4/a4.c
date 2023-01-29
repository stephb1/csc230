/* a4.c
 * CSC Fall 2022
 * 
 * Student name: Stephanie Borissov
 * Student UVic ID: V00985853
 * Date of completed work:
 *
 *
 * Code provided for Assignment #4
 *
 * Author: Mike Zastre (2022-Nov-22)
 *
 * This skeleton of a C language program is provided to help you
 * begin the programming tasks for A#4. As with the previous
 * assignments, there are "DO NOT TOUCH" sections. You are *not* to
 * modify the lines within these section.
 *
 * You are also NOT to introduce any new program-or file-scope
 * variables (i.e., ALL of your variables must be local variables).
 * YOU MAY, however, read from and write to the existing program- and
 * file-scope variables. Note: "global" variables are program-
 * and file-scope variables.
 *
 * UNAPPROVED CHANGES to "DO NOT TOUCH" sections could result in
 * either incorrect code execution during assignment evaluation, or
 * perhaps even code that cannot be compiled.  The resulting mark may
 * be zero.
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

#define __DELAY_BACKWARD_COMPATIBLE__ 1
#define F_CPU 16000000UL

#include <avr/io.h>
#include <avr/interrupt.h>
#include <util/delay.h>

#define DELAY1 0.000001
#define DELAY3 0.01

#define PRESCALE_DIV1 8
#define PRESCALE_DIV3 64
#define TOP1 ((int)(0.5 + (F_CPU/PRESCALE_DIV1*DELAY1))) 
#define TOP3 ((int)(0.5 + (F_CPU/PRESCALE_DIV3*DELAY3)))

#define PWM_PERIOD ((long int)500)

volatile long int count = 0;
volatile long int slow_count = 0;


ISR(TIMER1_COMPA_vect) {
	count++;
}


ISR(TIMER3_COMPA_vect) {
	slow_count += 5;
}

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

void led_state(uint8_t LED, uint8_t state) {
	//setting the leds in PORTL for output
	DDRL = 0xFF;
	
	//outer switch statement checks the cases for the state of the led (on or off)
	//there are only two possibilities - either 0 (off) or any other number (on) - default
	switch (state) {
		case 0: 
			//inner switch statement checks the cases for LED - which LED should be turned off and turns off the corresponding light
			switch (LED) {
				case 3: PORTL &= 0b11111101;
				break;
				case 2: PORTL &= 0b11110111;
				break;
				case 1: PORTL &= 0b11011111;
				break;
				case 0: PORTL &= 0b01111111;
				break;	//breaking out of the switch statement after every case because the others do not need to be checked
			}
		break;
		default:
			//inner switch statement checks the cases for LED - which LED should be turned on and turns on the corresponding light
			switch (LED) {
				case 3: PORTL |= 0b00000010;
				break;
				case 2: PORTL |= 0b00001000;
				break;
				case 1: PORTL |= 0b00100000;
				break;
				case 0: PORTL |= 0b10000000;
				break;
			}
		break;
	}
}



void SOS() {
	//setting the leds in PORTL for output
	DDRL = 0xFF;
	
    uint8_t light[] = {
        0x1, 0, 0x1, 0, 0x1, 0,
        0xf, 0, 0xf, 0, 0xf, 0,
        0x1, 0, 0x1, 0, 0x1, 0,
        0x0
    };

    int duration[] = {
        100, 250, 100, 250, 100, 500,
        250, 250, 250, 250, 250, 500,
        100, 250, 100, 250, 100, 250,
        250
    };

	int length = 19;
	
	//using a for loop that cycles through all 19 elements in the given arrays
	for (int i=0; i < length; i++) {
		//checking the 3 cases for the values in the lights array at index i and turning on or off the corresponding leds
		if (light[i] == 0x1) {
			led_state(0, 1);
			//setting the delay to the length at index i
			_delay_ms(duration[i]);
		//same process in the following if statements as previous
		} else if (light[i] == 0xf) {
			led_state(0, 1);
			led_state(1, 1);
			led_state(2, 1);
			led_state(3, 1);
			_delay_ms(duration[i]);
		} else {
			led_state(0, 0);
			led_state(1, 0);
			led_state(2, 0);
			led_state(3, 0);
			_delay_ms(duration[i]);
		}
	}
	
	
}


void glow(uint8_t LED, float brightness) {
	//setting leds in PORTL for output
	DDRL = 0xFF;
	
	//start of infinite for loop
	for(;;) {
		//setting the threshold to be compared with count - brightness is the floating point input
		float threshold = PWM_PERIOD * brightness;
		//if count is less than threshold we turn the input LED on
		if (count < threshold) {
			led_state(LED, 1);
		//if count is less than the period we turn the input LED off
		} else if (count < PWM_PERIOD) {
			led_state(LED, 0);
		} else {
			//otherwise we reset count and turn the input LED on
			count = 0;
			led_state(LED, 1);
		}
	}
}


void pulse_glow(uint8_t LED) {
	//setting leds in PORTL for output
	DDRL = 0xFF;
	
	//infinite loop because we want the light to get brighter and dimmer infinitely
	for(;;) {
		//resetting slow_count and count
		slow_count = 0;
		count = 0;
		
		//for loop that makes the led get brighter 
		//incrementing threshold each time
		//checking if threshold has reached period
		for (int threshold=0; threshold<PWM_PERIOD; threshold = slow_count*0.1) {
			//same as code in glow()
			if (count < threshold) {
				led_state(LED, 1);
				} else if (count < PWM_PERIOD) {
				led_state(LED, 0);
				} else {
				count = 0;
				led_state(LED, 1);
			}
		}
		//resetting slow_count and count
		slow_count = 0;
		count = 0;
		
		
		//for loop that makes the led get dimmer
		//incrementing threshold each time
		//checking if threshold has reached period
		for (int threshold=0; threshold<PWM_PERIOD; threshold = slow_count*0.1) {
			//same as code in glow() except we flip when the leds are turned on or turned off
			if (count < threshold) {
				led_state(LED, 0);
				} else if (count < PWM_PERIOD) {
				led_state(LED, 1);
				} else {
				count = 0;
				led_state(LED, 0);
			}
		}
	}
}


void light_show() {
	//setting leds in PORTL for output
	DDRL = 0xFF;
	
	//pattern for lights
	uint8_t light[] = {
		0xf,  0,  0xf,  0,  0xf,  0,  0x6,  0,  
		0x9,  0,  0xf,  0,  0xf,  0,  0xf,  0,  
		0x9,  0,  0x6,  0,  0x8, 0x6, 0x3, 0x1, 
		0x3, 0x6, 0x8, 0x6, 0x3, 0x1, 0x3, 0x6,  
		 0,  0xf,  0,  0xf,  0,  0x6,  0,  0x6,  0
	};
	
	//pattern for delays
	int duration[] = {
		250, 100, 250, 100, 250, 100, 100, 100, 
		100, 100, 250, 100, 250, 100, 250, 100, 
		100, 100, 100, 100, 100, 100, 100, 100, 
		100, 100, 100, 100, 100, 100, 100, 100, 
		100, 250, 100, 250, 100, 350, 100, 350, 500
	};

	int length = 41;
	
	//masks for checking which bits are set (which leds need to be turned on)
	int mask1 = 0x1;
	int mask2 = 0x2;
	int mask3 = 0x4;
	int mask4 = 0x8;
	
	//for loop that iterates for the length of the array
	for (int i=0; i < length; i++) {
		//state variables that keep track of the state of the 4 leds we are turning on or off
		int state1 = 0;
		int state2 = 0;
		int state3 = 0;
		int state4 = 0;
		
		//using the initialized masks and a bit-wise and to check if the corresponding led is set in the lights array at index i and therefore needs to be turned on
		if ((light[i] & mask1) == mask1) {
			//if the led is set, we change the state from being off to being on
			state1 = 1;
		}
		//same process for the following if statements
		if ((light[i] & mask2) == mask2) {
			state2 = 1;
		}
		if ((light[i] & mask3) == mask3) {
			state3 = 1;
		}
		if ((light[i] & mask4) == mask4) {
			state4 = 1;
		}
		
		//using the state variables updated previously to turn on or off the leds in PORTL
		led_state(0, state1);
		led_state(1, state2);
		led_state(2, state3);
		led_state(3, state4);
		//setting the delay to be the value at index i in the duration array
		_delay_ms(duration[i]);
		
		
	}
}
		



/* ***************************************************
 * **** END OF FIRST "STUDENT CODE" SECTION **********
 * ***************************************************
 */


/* =============================================
 * ==== BEGINNING OF "DO NOT TOUCH" SECTION ====
 * =============================================
 */

int main() {
    /* Turn off global interrupts while setting up timers. */

	cli();

	/* Set up timer 1, i.e., an interrupt every 1 microsecond. */
	OCR1A = TOP1;
	TCCR1A = 0;
	TCCR1B = 0;
	TCCR1B |= (1 << WGM12);
    /* Next two lines provide a prescaler value of 8. */
	TCCR1B |= (1 << CS11);
	TCCR1B |= (1 << CS10);
	TIMSK1 |= (1 << OCIE1A);

	/* Set up timer 3, i.e., an interrupt every 10 milliseconds. */
	OCR3A = TOP3;
	TCCR3A = 0;
	TCCR3B = 0;
	TCCR3B |= (1 << WGM32);
    /* Next line provides a prescaler value of 64. */
	TCCR3B |= (1 << CS31);
	TIMSK3 |= (1 << OCIE3A);


	/* Turn on global interrupts */
	sei();

/* =======================================
 * ==== END OF "DO NOT TOUCH" SECTION ====
 * =======================================
 */


/* *********************************************
 * **** BEGINNING OF "STUDENT CODE" SECTION ****
 * *********************************************
 */

/* This code could be used to test your work for part A.*/

	/*led_state(0, 1);
	_delay_ms(1000);
	led_state(2, 1);
	_delay_ms(1000);
	led_state(1, 1);
	_delay_ms(1000);
	led_state(2, 0);
	_delay_ms(1000);
	led_state(0, 0);
	_delay_ms(1000);
	led_state(1, 0);
	_delay_ms(1000);*/


/* This code could be used to test your work for part B.*/

	//SOS();

/* This code could be used to test your work for part C.*/

	//glow(2, 0.1);



/* This code could be used to test your work for part D.*/

	//pulse_glow(3);



/* This code could be used to test your work for the bonus part.*/

	//light_show();

/* ****************************************************
 * **** END OF SECOND "STUDENT CODE" SECTION **********
 * ****************************************************
 */
}

