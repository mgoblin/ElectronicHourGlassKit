#include <stdint.h>
#include <eeprom.h>
#include <interrupt.h>
#include <timer0_mode0.h>
#include <timer2_mode0.h>
#include <frequency.h>

#include <ehgk_page.h>
#include <ehgk_page_iterator.h>

#define ADDR_H 0x00
#define ADDR_L 0x00
#define UINT64_BYTES_SIZE 8
#define ORDINAL_PAGE_DELAY 10000
#define PAGES_COUNT 5 

#define MAX_CPU_FREQ_DIVIDER 2
#define MIN_CPU_FREQ_DIVIDER 0

ehgk_page_t page = EMPTY_PAGE;

uint8_t read_eeprom_byte(uint8_t addr_h, uint8_t addr_l)
{
        bit_set(IAP_CONTR, SBIT7);
        /* Set IAP WT2 WT1 WT0 to 011 for eeprom read waiting */
        IAP_CONTR &= ~0x07;
        IAP_CONTR |= 0x03;

        /* Set address */
        IAP_ADDRH = addr_h;
        IAP_ADDRL = addr_l;

        /* Set read operation */
        IAP_CMD = READ_OP;

        /* Set start operation sequence */
        IAP_TRIG = OP_TRIGGER_SEQ_FIRST_BYTE;
        IAP_TRIG = OP_TRIGGER_SEQ_SECOND_BYTE;

        /* Wait for operation to complete */
        NOP();

        return IAP_DATA;
}

void eeprom_ehgk_page_read(uint8_t addr_h, uint8_t addr_low)
{
    page = 0;
    for(uint8_t i = 0; i < UINT64_BYTES_SIZE; i++)
    {
        uint8_t value = read_eeprom_byte(addr_h, addr_low + i);
        page |= ((uint64_t) value) << (i << 3); 
    }
}

void timer2_ISR() __interrupt(INTERRUPT_TIMER2)
{
    ehgk_iterator_next();
    ehgk_apply_iterator_result();
}

void timer0_ISR() __interrupt(INTERRUPT_TIMER0)
{
    eeprom_ehgk_page_read(ADDR_H, ADDR_L);
    ehgk_iterator_init(page);
}

void main(void) 
{
    CLK_DIV = MAX_CPU_FREQ_DIVIDER;

    power_low_voltage_flag_clear();

    timer2_mode0_1T_init();
    timer0_mode0_12T_init();
    enable_timer0_interrupt();

    timer0_mode0_start(0xFFFF);
    timer2_mode0_start(0x0400);
    
    while(1) {}
}