/**
 * @file page_timer.c
 * 
 * @brief STC electronic hourglass kit. Stage 6.
 * 
 * @details
 * This example demonstrate how to use page and iterator for LED on/off with timer.
 * One difference from stage 5 is that timer0 used to render page.
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

extern ehgk_iterator_t iterator;
extern ehgk_iter_result_t iter_result;

void timerISR() __interrupt(1)
{
    ehgk_iterator_next();

    P1 = iter_result.p1;
    P3 = iter_result.p3;

    P1M0 = iter_result.p1m0;
    P1M1 = iter_result.p1m1;
    P3M0 = iter_result.p3m0;
    P3M1 = iter_result.p3m1;
}

void main()
{
    ehgk_iterator_init(
        L2 | L3 | L4 | L5 | L6 | 
         L9 | L10 | L11 | L12 |
          L15 | L16 | L17 |
             L20 | L21 |
                L24 |

                L28 |
                L29 |
                L30 |
                
                L34 |
             L37 | L38 |
          L41 | L42 | L43 |
         L46 | L47 | L48 | L49 |
        L52 | L53 | L54 | L55 |L56
    );

    
    timer0_mode0_1T_init();
    timer0_mode0_direct_start(0xF5, 0x00);

    while (1)
    {
    }
}