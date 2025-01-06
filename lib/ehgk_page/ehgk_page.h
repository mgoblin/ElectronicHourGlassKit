#pragma once

/**
 * @file ehgk_page.h
 * 
 * @brief Electronic hourglass kit page format declarations.
 * 
 * @author Michael Golovanov mike.golovanov@gmail.com
 */

#include <stdint.h>

/**
 * @brief LEDs page is 57 bits array to encode one step of LEDs animation.
 * 
 * @details 
 * Page only describes LEDs state and dont really turn on/off LEDs.
 * 
 * Each bit correspons to then one hourglass kit LED state. 
 * 
 * Value 1 means that LED should be turn on and value 0 means that LED 
 * should be turn off.
 * 
 * Page have MSLB order of LED states. Page is stored as uint64.
 * 
 * LED L1 state is stored in the lowest bit (offset 0), LED L2 has offset 1 and so on.
 * LED 57 state stored at offset 56. 
 * Other unused bits (offests 57-63) should be set to 0.  
 */
typedef uint64_t ehgk_page_t;

/**
 * @brief Page with all LEDs is turn off
 */
#define EMPTY_PAGE (uint64_t)0

/**
 * Page with all LEDs is turn on
 */
#define ALL_LEDS_PAGE (uint64_t) 0x1FFFFFFFFFFFFF

/**
 * @brief Turn on LED in page
 * 
 * @details Set LED bit to 1
 * 
 * @param p     ehgk_page_t page
 * @param led   led_t LED to turn on
 */
#define ehgk_page_add_led(p, led)       (p |= led)

/**
 * @brief Turn off LED in page
 * 
 * @details Set LED bit to 0
 * 
 * @param p     ehgk_page_t page
 * @param led   led_t LED to turn off
 */
#define ehgk_page_delete_led(p, led)    (p &= ~led)

/**
 * @brief LEDs enum
 * @details 
 * DEscribe encoding L1-L57 LEDs in page. 
 * Each enum value is 1-bit in LEDs number position 
 * 
 * @see ehgk_page_t
 */
typedef enum led_t
{
    L1  = (uint64_t) 0x1,
    L2  = (uint64_t) 0x2,
    L3  = (uint64_t) 0x4,
    L4  = (uint64_t) 0x8,
    L5  = (uint64_t) 0x10,
    L6  = (uint64_t) 0x20,
    L7  = (uint64_t) 0x40,
    L8  = (uint64_t) 0x80,
    L9  = (uint64_t) 0x100,
    L10 = (uint64_t) 0x200,
    L11 = (uint64_t) 0x400,
    L12 = (uint64_t) 0x800,
    L13 = (uint64_t) 0x1000,
    L14 = (uint64_t) 0x2000,
    L15 = (uint64_t) 0x4000,
    L16 = (uint64_t) 0x8000,
    L17 = (uint64_t) 0x10000,
    L18 = (uint64_t) 0x20000,
    L19 = (uint64_t) 0x40000,
    L20 = (uint64_t) 0x80000,
    L21 = (uint64_t) 0x100000,
    L22 = (uint64_t) 0x200000,
    L23 = (uint64_t) 0x400000,
    L24 = (uint64_t) 0x800000,
    L25 = (uint64_t) 0x1000000,
    L26 = (uint64_t) 0x2000000,
    L27 = (uint64_t) 0x4000000,
    L28 = (uint64_t) 0x8000000,
    L29 = (uint64_t) 0x10000000,
    L30 = (uint64_t) 0x20000000,
    L31 = (uint64_t) 0x40000000,
    L32 = (uint64_t) 0x80000000,
    L33 = (uint64_t) 0x100000000,
    L34 = (uint64_t) 0x200000000,
    L35 = (uint64_t) 0x400000000,
    L36 = (uint64_t) 0x800000000,
    L37 = (uint64_t) 0x1000000000,
    L38 = (uint64_t) 0x2000000000,
    L39 = (uint64_t) 0x4000000000,
    L40 = (uint64_t) 0x8000000000,
    L41 = (uint64_t) 0x10000000000,
    L42 = (uint64_t) 0x20000000000,
    L43 = (uint64_t) 0x40000000000,
    L44 = (uint64_t) 0x80000000000,
    L45 = (uint64_t) 0x100000000000,
    L46 = (uint64_t) 0x200000000000,
    L47 = (uint64_t) 0x400000000000,
    L48 = (uint64_t) 0x800000000000,
    L49 = (uint64_t) 0x1000000000000,
    L50 = (uint64_t) 0x2000000000000,
    L51 = (uint64_t) 0x4000000000000,
    L52 = (uint64_t) 0x8000000000000,
    L53 = (uint64_t) 0x10000000000000,
    L54 = (uint64_t) 0x20000000000000,
    L55 = (uint64_t) 0x40000000000000,
    L56 = (uint64_t) 0x80000000000000,
    L57 = (uint64_t) 0x100000000000000,
} led_t;