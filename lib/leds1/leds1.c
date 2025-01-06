#include <leds1.h>

#define LOW 0
#define HIGH 1


void leds_off()
{
    // All P3 and P1 pins should be in input only mode.
    // Pins in nnput only mode have high impedance and low current consuption.  
    pin_port_input_only_init(P3);
    pin_port_input_only_init(P1);
}

void led_1_on()
{
    /**  
     * For turning L1 led on:
     * * P3.0 and P1.0 should be in push pull mode. 
     *   In this mode pins can have strong HIGH or LOW values and drive the led
     * * P3.0 should be HIGH
     * * P1.0 should be LOW 
     */

    pin_push_pull_init(P3, 0);
    pin_push_pull_init(P1, 0);

    P10 = LOW;
    P30 = HIGH; 
}