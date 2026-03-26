#include <stdint.h>
#include <eeprom.h>
#include <interrupt.h>
#include <timer0_mode0.h>
#include <timer2_mode0.h>
#include <frequency.h>

#include <ehgk_page.h>
#include <ehgk_page_iterator.h>

#define ADDR_H 0x00
#define UINT64_BYTES_SIZE 8
#define PAGES_COUNT 5 

#define MAX_CPU_FREQ_DIVIDER 2
#define MIN_CPU_FREQ_DIVIDER 0

ehgk_page_t page = EMPTY_PAGE;
uint8_t page_index = 0;

void eeprom_ehgk_page_read(uint8_t addr_h, uint8_t addr_low)
{
    page = EMPTY_PAGE;
    for(uint8_t i = 0; i < UINT64_BYTES_SIZE; i++)
    {
        uint8_t value, error = 0;
        eeprom_read_byte(addr_h, addr_low + i, &value, &error);
        page |= ((uint64_t) value) << (i << 3); 
    }
}


void timer0_ISR() __interrupt(INTERRUPT_TIMER0)
{
    eeprom_ehgk_page_read(ADDR_H, page_index * UINT64_BYTES_SIZE);
    ehgk_iterator_init(page);
    if (page_index == PAGES_COUNT - 1) page_index = 0; else page_index++;
}

void button_press_handler() __interrupt(INTERRUPT_INT0)
{
    if (CLK_DIV == MAX_CPU_FREQ_DIVIDER) 
    {
        CLK_DIV = MIN_CPU_FREQ_DIVIDER; 
    }
    else 
    {
        CLK_DIV++;
    }
}

void main(void) 
{
    CLK_DIV = MAX_CPU_FREQ_DIVIDER;

    power_low_voltage_flag_clear();

    timer0_mode0_12T_init();
    enable_timer0_interrupt();

    enable_int0_interrupt();
    set_int0_interrupt_trigger(ONLY_FALLING_EDGE);

    timer0_mode0_start(0xFFFF);
    
    while(1) 
    {
        ehgk_iterator_next();
        ehgk_apply_iterator_result();
    }
}