/**
 * @file eeprom_read.c
 * 
 * @brief STC electronic hourglass kit. Stage 10.
 * 
 * This example demostrates how to use pages description from EEPROM.
 * 
 * EEPROM is used to store pages description.
 * Timer0 is used to read pages from EEPROM and main loop is used 
 * to iterate over pages.
 * 
 * INTO interrupt is used to respond to a button press.
 * When you press the button, the microcontroller's operating frequency 
 * changes, which slows down or speeds up page animation.
 * 
 * This example use STC15 HAL library from https://github.com/mgoblin/STC15lib.
 * 
 * @author Michael Golovanov (mike.golovanov@gmail.com)
 */
#include <stdbool.h>

#include <eeprom.h>
#include <interrupt.h>
#include <timer0_mode0.h>
#include <frequency.h>

#include <ehgk_page.h>
#include <ehgk_page_iterator.h>

typedef unsigned char uint8_t;

/**
 * @brief EEPROM start pages definition address high byte
 */
#define ADDR_H      0x00

/**
 * @brief EEPROM start pages definition address low byte
 */
#define ADDR_LOW    0x00

/**
 * @brief Max CPU frequency divider. Slowest page animation.
 */
#define MAX_CPU_FREQ_DIVIDER 2
/**
 * @brief Min CPU frequency divider. Fastest page animation.
 */
#define MIN_CPU_FREQ_DIVIDER 0

/**
 * @brief pages count in EEPROM
 */
uint8_t pages_count; 

/**
 * @brief Current page
 */
ehgk_page_t page = EMPTY_PAGE;

/**
 * @brief Current page index in pages array
 */
uint16_t page_index = 0;

/**
 * @brief Read page from EEPROM
 * Reads page from EEPROM and stores it in page variable.
 * Page  bytes in EEPROM are stored in little endian order.
 * 
 * @param addr_h EEPROM start page address high byte
 * @param addr_low EEPROM start page address low byte
 */
void eeprom_ehgk_page_read(uint8_t addr_h, uint8_t addr_low)
{
    page = EMPTY_PAGE;
    for(uint8_t i = 0; i < sizeof(uint64_t); i++)
    {
        uint8_t value, error = 0;
        eeprom_read_byte(addr_h, addr_low + i, &value, &error);
        page |= ((uint64_t) value) << (i << 3); 
    }
}

volatile bool load_page_flag = false;
/**
 * @brief Timer0 interrupt handler
 * 
 * Load next page from EEPROM and apply it to page iterator.
 */
void timer0_ISR() __interrupt(INTERRUPT_TIMER0)
{
    load_page_flag = true;
}

/**
 * @brief INTO interrupt handler
 * 
 * Change CPU frequency divider and therefore animation speed.
 */ 
void button_press_handler() __interrupt(INTERRUPT_INT0)
{
}

extern ehgk_iterator_t iterator;

void main(void) 
{
    power_low_voltage_flag_clear();

    timer0_mode0_12T_init();
    enable_timer0_interrupt();

    // Initialize button press handler
    enable_int0_interrupt();
    set_int0_interrupt_trigger(ONLY_FALLING_EDGE);

    eeprom_ehgk_page_read(ADDR_H, ADDR_LOW);
    pages_count = page;
    page = EMPTY_PAGE;
    ehgk_iterator_init(page);

    timer0_mode0_start(0xFFFF);
    
    while(1) 
    {
        if (load_page_flag)
        {
            page_index++;
            if (page_index == pages_count) page_index = pages_count - 1;

            uint16_t addr = (page_index + 1) * sizeof(uint64_t);
            uint8_t addr_low = addr & 0xFF;
            uint8_t addr_high = (uint8_t)(addr >> 8);
            eeprom_ehgk_page_read(addr_high, addr_low);
            ehgk_iterator_init(page);

            load_page_flag = false;
        }

        // Show page
        ehgk_iterator_next();
        ehgk_apply_iterator_result();
    }
}