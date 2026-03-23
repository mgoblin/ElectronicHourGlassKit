#include <stdint.h>
#include <eeprom.h>
#include <interrupt.h>

#include <ehgk_page.h>
#include <ehgk_page_iterator.h>

#define ADDR_H 0x00
#define ADDR_L 0x00
#define UINT64_BYTES_SIZE 8
#define ORDINAL_PAGE_DELAY 10000
#define PAGES_COUNT 5 

#define MAX_CPU_FREQ_DIVIDER 2
#define MIN_CPU_FREQ_DIVIDER 0


ehgk_page_t eeprom_ehgk_page_read(uint8_t addr_h, uint8_t addr_low)
{
    ehgk_page_t page = 0;

    for(uint8_t i = 0; i < UINT64_BYTES_SIZE; i++)
    {
        uint8_t value = 0;
        uint8_t error = 0;
        eeprom_read_byte(addr_h, addr_low + i, &value, &error);
        page |= ((uint64_t) value) << (i << 3); 
    }
    return page;
}

void displayPage(uint16_t iteration_delay)
{
    // Iterate through page LEDs and on/of LEDs according to page definition
    for(uint16_t i = 0; i < iteration_delay; i++)
    {
        ehgk_iterator_next();
        ehgk_apply_iterator_result();
    }
}

void int0_ISR() __interrupt(INTERRUPT_INT0)
{
    // Three low CLK_DIV bits are frequency divider scaler 
    if(CLK_DIV == MIN_CPU_FREQ_DIVIDER) 
    { 
        CLK_DIV = MAX_CPU_FREQ_DIVIDER; 
    } 
    else 
    { 
        CLK_DIV--; // Speed up animation
    }
}

void main(void) 
{
    // Configure button handler
    enable_mcu_interrupts();
    enable_int0_interrupt();
    set_int0_interrupt_trigger(ONLY_FALLING_EDGE);

    power_low_voltage_flag_clear();

    CLK_DIV = MAX_CPU_FREQ_DIVIDER;

    while(1)
    {
        for(uint8_t addr = 0; addr < sizeof(uint64_t) * PAGES_COUNT; addr += sizeof(uint64_t))
        {
            ehgk_page_t page = eeprom_ehgk_page_read(ADDR_H, addr);
            ehgk_iterator_init(page);
            displayPage(ORDINAL_PAGE_DELAY);
        }
    }
}