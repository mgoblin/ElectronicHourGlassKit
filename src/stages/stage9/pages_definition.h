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

#define PAGES_COUNT 15
const ehgk_page_t pages[PAGES_COUNT] = {
    // Page 0
    L1 | L2 | L3 | L4 | L5 | L6 | L7,

    // Page 1
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28, 

    // Page 2
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27, 

    // Page 3
    L1 | L2 | L3 | L4| L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51, 

    // Page 4
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57, 

    // Page 5
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56, 

    // Page 6
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 | 
    L9 | L10 | L11 | L12, 

    // Page 7
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24, 

    // Page 8
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21,

    // Page 9
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21 |
    L46 | L47 | L48 | L49,

    // Page 10
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21 |
    L46 | L47 | L48 | L49 |
    L34 | L37 | L41 | L46,

    // Page 11
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21 |
    L46 | L47 | L48 | L49 |
    L34 | L37 | L41 | L46 |
    L38 | L43,

    // Page 12
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21 |
    L46 | L47 | L48 | L49 |
    L34 | L37 | L41 | L46 |
    L38 | L43 |
    L16,

    // Page 13
    L1 | L2 | L3 | L4 | L5 | L6 | L7 | 
    L8 | L14 | L19 | L23 | L26 | L28 |
    L13 | L18 | L22 | L25 | L27 |
    L30 | L31 | L33 | L36 | L40 | L45 | L51 |
    L32 | L35 | L39 | L44 | L50 | L57 | 
    L52 | L53 | L54 | L55 | L56 |
    L9 | L10 | L11 | L12 |
    L15 | L20 | L24 |
    L17 | L21 |
    L46 | L47 | L48 | L49 |
    L34 | L37 | L41 | L46 |
    L38 | L43 |
    L16 |
    L42,

    // Page 14
    EMPTY_PAGE,

};