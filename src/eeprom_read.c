#include <stdint.h>
#include <eeprom.h>

#include <uart.h>
#include <stdio.h>

#define ADDR_H 0x00
#define ADDR_L 0x00
#define DATA_SIZE 8

void main(void) 
{
    // uart1_init(9600);

    power_low_voltage_flag_clear();

    while(1)
    {
        for(uint8_t i = 0; i < DATA_SIZE; i++)
        {
            uint8_t value = 0;
            uint8_t error = 0;
            eeprom_read_byte(ADDR_H, i, &value, &error);

            // if (error)
            // {
            //     printf_tiny("EEPROM read error %x\r\n", error);
            // }
            // else
            // {
            //     printf_tiny("Read from %x %x = %x\r\n", ADDR_H, i, value);
            // }
        }
    }
}