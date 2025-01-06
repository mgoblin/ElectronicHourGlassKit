/**
 * @file page_timer_animation.c
 * 
 * @brief STC electronic hourglass kit. Stage 8.
 * 
 * @details
 * This example is analog of original firmware with size less than 1024 bytes.
 * It will be runned on STC15W204S and STC15W201S chips.
 * 
 * Example iterates through pages array and animate sand houglass after page displayed.
 * Pages animation is encoded in pages_definition.h
 * 
 * Button press raise INTO.
 * Initially MCU frequency is divided on MAX_CPU_FREQ_DIVIDER.
 * Each button press decrement divider. 
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.   
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */
#include <pin.h>
#include <interrupt.h>
#include <frequency.h>

#include <ehgk_page_iterator.h>

#include "pages_definition.h" // page animation definitions

#define MAX_CPU_FREQ_DIVIDER 2
#define MIN_CPU_FREQ_DIVIDER 0

// Display page MCU cycles
#define ORDINAL_PAGE_DELAY 10000

// Current iteration P1 and P3 state and mode
extern ehgk_iter_result_t iter_result;

/**
 * @brief Display current page
 * 
 * @param iteration_delay uint16_t display page in MCU cycles
 */
void displayPage(uint16_t iteration_delay)
{
    // Iterate through page LEDs and on/of LEDs according to page definition
    for(uint16_t i = 0; i < iteration_delay; i++)
    {
        ehgk_iterator_next();

        P1 = iter_result.p1;
        P3 = iter_result.p3;

        P1M0 = iter_result.p1m0;
        P1M1 = iter_result.p1m1;
        P3M0 = iter_result.p3m0;
        P3M1 = iter_result.p3m1;
    }
}

void int0_ISR() __interrupt(0)
{
    // Three low CLK_DIV bits are frequency divider scaler 
    if(CLK_DIV == MIN_CPU_FREQ_DIVIDER) 
    { 
        CLK_DIV = MAX_CPU_FREQ_DIVIDER; 
    } 
    else 
    { 
        CLK_DIV--; // Speec up animation
    }
}

void main()
{
    // Configure button handler
    enable_mcu_interrupts();
    enable_int0_interrupt();
    set_int0_interrupt_trigger(ONLY_FALLING_EDGE);

    // Set animation speed
    set_frequency_divider_scale(MAX_CPU_FREQ_DIVIDER);

    while (1)
    {
        // Iterate through pages
        for(uint16_t page_idx = 0; page_idx < PAGES_COUNT; page_idx++)
        {
            // Select next page to display
            ehgk_iterator_init(pages[page_idx]);
            // Display page
            displayPage(ORDINAL_PAGE_DELAY);
        }
    }
}