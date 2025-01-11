/**
 * @file all_lines_timer.c
 * 
 * @brief STC electronic hourglass kit. Stage 4.
 * 
 * @details
 * This example demonstrate how to turn all 5-LED lines on.
 * 
 * All electronic hourglass kit leds grouped to lines. Each line
 * contains 5 LEDs. 
 * 
 * Lines numbered from 0 to 11. 
 * The first line have number 0 and includes LEDs L1-L5, the second line 
 * have number 1 and includes L6-L10 LEDs and so on.
 * 
 * Inside line LEDs drives by P3. 
 * LEDs corresponds to P3 pins as 
 * [1 -> P3.0, 2 -> P3.1, 3 -> P3.3, 4 -> P3.6, 5 -> P3.7] 
 * 
 * Even line LEDs turn on when P3.x pin is HIGH and P1.<line_number> is LOW.
 * Odd lines LEDs turn on when P3.x pin is LOW and P1.<line_number> is HIGH
 * 
 * To limit current consumption only one LED in time should be lin.
 * 
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

#define TICKS_COUNT 0x0FFF // Timer0 ticks count uint16_t

// P3 LED-driver pins count 
#define P3_PINS_COUNT 5 
// P3 values array. 
// Each element of array is corresponds to P3.x is HIGH for L1-L5 is on.
// Array element values guaranteed that only one of P3.0, P3.1, P3.3, P3.6, P3.7 pins 
// have HIGH value
// On odd lines array element bits should be inverted    
const uint8_t P3_pins[P3_PINS_COUNT] = { 1, 2, 8, 64, 128 }; 

// P1 LED-driver pins count 
#define P1_PINS_COUNT 6
// P1 values array. 
// Each element of array is correspons to P1.x is LOW.
// Pins P0-P7 drives LEDs.
// On even lines P1 = ~<element value>
const uint8_t P1_pins[P1_PINS_COUNT] = { 1, 2, 4, 8, 16, 32 }; 

// P3_pins array iteration index. 
// Used by timerISR to sequentially turn on/of 1-5 LEDs in line.
uint8_t led_column = 0;

// P1_pins array iteration index
// Used by timerISR to sequentially change LED lines.
uint8_t led_line = 0;

/**
 * @brief is this column is last in line
 * 
 * @param column - uint8_t column number in range [0..4].
 * 
 * @return true if column is last column in line.
 */
bool is_line_iterated(uint8_t column) { return column == P3_PINS_COUNT - 1; }

/**
 * Cyclically increment led_line from 0 to 11
 */
void next_line()
{
    led_line = led_line == (P1_PINS_COUNT << 1) - 1 ? 0 : led_line + 1;
}

/**
 * @brief Turns LED on
 * @details LED defines by it line and column insie line. All other LEDs turns off.
 * 
 * @param column LEDs column in range [0..4]
 * @param line LEDs line in range [0..11] 
 */
void turn_led_on(uint8_t column, uint8_t line)
{
    uint8_t line_idx = line >> 1; // get P1 pin number into line_idx variable

    // Set P1.<line_idx> pin to push pull mode 
    pin_port_input_only_init(P1);
    pin_push_pull_init(P1, line_idx);

    if ((line & 0x01) == 0) // Is line odd or even?
    {
        // Line is even. P1 values need to be inverted
        P3 = P3_pins[column];
        P1 = ~P1_pins[line_idx];
    }
    else 
    {
        // Line is odd. P3 values need to be inverted
        P3 = ~P3_pins[column]; 
        P1 = P1_pins[line_idx];
    }
}

/**
 * Timer0 interrupt service routine.
 * 
 * Cyclically trun on leds of odd led lines  
 */
void timerISR() __interrupt(1)
{
    turn_led_on(led_column, led_line);

    // Change line and column for the next interrupt handler call
    if (is_line_iterated(led_column))
    { 
        led_column = 0;
        next_line();
    } 
    else 
    {
        led_column++;
    }
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
    // Initialzie P3 pins to push pull mode and LOW value
    pin_port_pull_push_init(P3);
    P3 = LOW;

    // Initialzie P1 pins in input only mode
    pin_port_input_only_init(P1);
    P1 = LOW;

    // Initialize and start timer 0 for sequentially LEDs turn on
    timer0_mode0_1T_init();
    timer0_mode0_start(TICKS_COUNT);

    while (1) {}
}