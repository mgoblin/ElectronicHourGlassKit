/**
 * @file line0_timer.c
 * 
 * @brief STC electronic hourglass kit. Stage 3.
 * 
 * @details
 * This example demonstrate how to put 5-LED line on.
 * 
 * Five P3 pins P3.0, P3.1, P3.3, P3.6, P3.7 and P1.0 pin drive 
 * the L1-L5 LEDs.
 * 
 * L1 drives by P3.0 and P1.0. L2 drives by P3.1 and P1.0 and so on.
 * 
 * For put on LED corresponding P3 pin should have HIGH value 
 * and P1.0 should have LOW value.
 * 
 * P1.0 pin permanently set to push pull mode and have LOW value. 
 * Each LED consumes in ~20ma when switched on. 
 * And MCU current should not be more than ~90ma.
 * 
 * To keep the LEDs line lit and not exceed the overall current threshold, 
 * it is necessary to turn on only one LED in the line very quickly in sequence.
 * 
 * On each Timer0 ISR call sequentially only one LED in line turn on.
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.   
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */

/*======================== STC15 HAL headers ====================================*/
#include <pin.h>
#include <timer0_mode0.h>
/*========================End of STC15 HAL headers ==============================*/

#define HIGH    1 // HIGH pin state
#define LOW     0 // LOW pin state

#define TICKS_COUNT 0xBFFF // Timer0 ticks count uint16_t

// P3 LED driver pins count 
#define P3_PINS_COUNT 5 
// P3 values array. Each element of array is corresponds to on of L1-L5 is on.
// Array element values are only one of P3.0, P3.1, P3.3, P3.6, P3.7 pins 
// have HIGH value  
const uint8_t P3_pins[P3_PINS_COUNT] = { 1, 2, 8, 64, 128 }; 

// P3_pins array iteration index. Used by timerISR to sequentially turn on/of L1-L5 LEDs
uint8_t pins_idx = 0;

/**
 * Timer0 interrupt service routine.
 * 
 * Cyclically set HIGH only one of P3.0, P3.1, P3.3, P3.6, P3.7 pins 
 */
void timerISR() __interrupt(1)
{
    P3 = P3_pins[pins_idx]; // set P3 value for turn on current L1-L5 led
    pins_idx == P3_PINS_COUNT - 1 ? pins_idx = 0 : pins_idx++; // Increment pin_idx or set it to 0 if L5 is on.
}

/**
 * Program entry point.
 * 
 * Set P3 in push pull mode enabling strong HIGH/LOW.
 * Initialize all P3 pins to LOW(0) values,
 * 
 * Set P1.0 pin in push pull mode enabling strong HIGH/LOW 
 * and set other P1 pins in input only mode.  
 * Initialize P1.0 pin to LOW(0) value,
 * 
 * Start timer0. 
 * 
 * LEDs line is off after P3 and P1 pins init and waiting for timer ticks  
 */
void main()
{
    // Initialzie P3 pins
    pin_port_pull_push_init(P3);
    P3 = LOW;

    // Initialzie P1 pins
    pin_port_input_only_init(P1);
    pin_push_pull_init(P1, 0);
    P10 = LOW;

    // Initialize and start timer 0 for L1-L5 turn on
    timer0_mode0_1T_init();
    timer0_mode0_start(TICKS_COUNT);

    while (1) {}
}