#pragma once

/**
 * @file pages_definition.h
 * 
 * @brief Electronic hourglass kit animation page definitions
 * 
 * @details
 * Define pages array for animation main part and 
 * l29_l30_pages for sand flow animation
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */

#include <ehgk_page.h>

#define L29_L30_PAGES_COUNT 2
const ehgk_page_t l29_l30_pages[L29_L30_PAGES_COUNT] = { L29, L30 };

#define PAGES_COUNT 29
const ehgk_page_t pages[PAGES_COUNT] = 
{
    // Page 0
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
     L8 | L9 | L10 | L11 | L12 | L13 |
       L14 | L15 | L16 | L17 | L18 | 
          L19 | L20 | L21 | L22 | 
             L23 | L24 | L25 |
              L26 | L27 | L28,

    // Page 1
    L1 | L2 | L3 | L5 | L6 | L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L54, 

    // Page 2
    L1 | L2 | L5 | L6 | L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L53 | L54,

    // Page3
    L1 | L2 | L6 | L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L53 | L54 | L55,

    // Page4
    L1 | L6 | L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L52 | L53 | L54 | L55,

    // Page5
    L1 | L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L52 | L53 | L54 | L55 | L56,

    // Page6
    L7 | L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L51 | L52 | L53 | L54 | L55 | L56,

    // Page7 - high 7 leds are off
    L8 | L9 | L10 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page8 
    L8 | L9 | L11 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L47 | 
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page9 
    L8 | L9 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L47 | L48 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page10 
    L8 | L12 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L46 | L47 | L48 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page11 
    L8 | L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L46 | L47 | L48 | L49 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page12 
    L13 |
    L14 | L15 | L16 | L17 | L18 | L19 | L20 | L21 | L22 | L23 | L24 | L25 |
    L26 | L27 | L28 | 
    L45 | L46 | L47 | L48 | L49 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page13 Nextt 6 LEDs are off
    L14 | L15 | L16 | L17 | L18 | 
    L19 | L20 | L21 | L22 | L23 | L24 | L25 |L26 | L27 | L28 | 
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page14 
    L14 | L15 | L17 | L18 | 
    L19 | L20 | L21 | L22 | L23 | L24 | L25 |L26 | L27 | L28 | 
    L42 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page15 
    L14 | L17 | L18 | 
    L19 | L20 | L21 | L22 | L23 | L24 | L25 |L26 | L27 | L28 | 
    L41 | L42 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page16 
    L14 | L18 | 
    L19 | L20 | L21 | L22 | L23 | L24 | L25 |L26 | L27 | L28 | 
    L41 | L42 | L43 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page17 
    L18 | 
    L19 | L20 | L21 | L22 | L23 | L24 | L25 |L26 | L27 | L28 | 
    L40 |L41 | L42 | L43 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 18 - Next 5 LEDs are off
    L19 | L20 | L21 | L22 | 
    L23 | L24 | L25 | 
    L26 | L27 | 
    L28 | 
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 19
    L19 | L21 | L22 |
    L23 | L24 | L25 | 
    L26 | L27 | 
    L28 | 
    L37 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 20
    L19 | L22 |
    L23 | L24 | L25 | 
    L26 | L27 | 
    L28 | 
    L37 | L38 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 21
    L22 |
    L23 | L24 | L25 | 
    L26 | L27 | 
    L28 | 
    L36 | L37 | L38 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 22 Next 4 LEDs are off
    L23 | L24 | L25 | 
    L26 | L27 | 
    L28 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 23 
    L23 | L25 | 
    L26 | L27 | 
    L28 |
    L34 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 24 
    L25 | 
    L26 | L27 | 
    L28 |
    L33 | L34 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 25 Next 3 LEDs are off 
    L26 | L27 | 
    L28 |
    L33 | L34 | L35 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 26
    L27 | 
    L28 |
    L31 |
    L33 | L34 | L35 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 27 Next 2 LEDs are oaff
    L28 |
    L31 | L32 |
    L33 | L34 | L35 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

    // Page 28 Next 1 LED is oaff
    L31 | L32 |
    L33 | L34 | L35 | 
    L36 | L37 | L38 | L39 |
    L40 |L41 | L42 | L43 | L44 |
    L45 | L46 | L47 | L48 | L49 | L50 |
    L51 | L52 | L53 | L54 | L55 | L56 | L57,

};