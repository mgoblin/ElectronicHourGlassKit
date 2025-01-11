/**
 * @file page_timer_animation.c
 * 
 * @brief STC electronic hourglass kit. Stage 7.
 * 
 * @details
 * This example is analog of original firmware with size less than 1024 bytes.
 * It will be runned on STC15W204S and STC15W201S chips.
 * Button press doesnt handle.
 * 
 * Example iterates through pages array and animate sand houglass after page displayed.
 * Pages animation is encoded in pages_definition.h
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.   
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */

/*======================== STC15 HAL headers ====================================*/
#include <pin.h>
#include <timer0_mode0.h>
/*========================End of STC15 HAL headers ==============================*/

#include <ehgk_page_iterator.h>

#include "pages_definition.h" // page animation definitions

void _mcs51_genRAMCLEAR() {}
void _mcs51_genXRAMCLEAR() {}

// Display page MCU cycles
#define ORDINAL_PAGE_DELAY 20000

// Sand flow animation MCU cycles
#define SAND_FLOW_DELAY 10000

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

void main()
{
    while (1)
    {
        // Iterate through pages
        for(uint16_t page_idx = 0; page_idx < PAGES_COUNT; page_idx++)
        {
            // Select next page to display
            ehgk_iterator_init(pages[page_idx]);
            // Display current page
            displayPage(ORDINAL_PAGE_DELAY);
            
            // Animate sand flow
            for(uint8_t idx = 0; idx < L29_L30_PAGES_COUNT; idx++)
            {
                ehgk_iterator_init(pages[page_idx] | l29_l30_pages[idx]);
                displayPage(SAND_FLOW_DELAY);
            }
        }
    }
}