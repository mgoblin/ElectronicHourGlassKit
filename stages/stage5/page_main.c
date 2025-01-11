/**
 * @file page_main.c
 * 
 * @brief STC electronic hourglass kit. Stage 5.
 * 
 * @details
 * This example demonstrate how to use page and iterator for LED on/off.
 * 
 * Page is the LEDs state description and iterator is a way to get pins 
 * values to display page.
 * 
 * Page description is a bit array. ehgk_page_t type is an alias of uint64.
 * Each bit is corresponding to one bit in the page. 
 * 
 * led_t enum have L1-L57 declaration as a page bits.
 * 
 * First ehgk_iterator_init should be called to init page.
 * And after that each call of ehgk_iterator_next fills 
 * iter_result with p1, p3 values and its pin modes.
 * 
 * ehgk_iterator_next should be called in a cycle. 
 * To display page iter_result values copies to MCU registers.    
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.   
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */

/*======================== STC15 HAL headers ====================================*/
#include <pin.h>
/*========================End of STC15 HAL headers ==============================*/

#include <ehgk_page_iterator.h>

extern ehgk_iterator_t iterator;
extern ehgk_iter_result_t iter_result;

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
    ) ;

    while (1)
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