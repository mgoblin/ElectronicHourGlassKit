/** 
 * @file led_main.c
 * 
 * @brief STC electronic hourglass kit. Stage 1.
 * 
 * @details
 * This example demostrate how to put ON one LED L1 using only main function
 * 
 * L1 anode is connected to P30 pin and L1 cathode is connected to P10.
 * To putting ON the P30 pin should be HIGH and P10 should be LOW.
 * Other pins should be in high impedance mode (input-only STC15 pin mode).
 * 
 * To limit current consumption, the LED blinks almost imperceptibly to the human eye.
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */

/*======================== STC15 HAL headers ====================================*/
#include <sys.h>
#include <delay.h>
#include <pin.h>
/*========================End of STC15 HAL headers ==============================*/

#include <leds1.h> // custom library header for led pins manipulations 


#define LED_BLINK_DELAY_MS 15 // Blink delay in milliseconds

/**
 * Wrapper for delay_ms macro. Used for decrease firmware size
 */
void f_delay_ms(uint16_t ms)
{
    delay_ms(ms);
}

void main()
{
    while (1)
    {
        // Put all LEDs off 
        leds_off();
        f_delay_ms(LED_BLINK_DELAY_MS);
        
        // Put L1 on
        led_1_on();
        f_delay_ms(LED_BLINK_DELAY_MS);
    }
}