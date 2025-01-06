#include <ehgk_page_iterator.h>

#define COLUMN_LEDS_COUNT 5
#define LINES_COUNT 12

/**
 * Module iterator instance
 */
ehgk_iterator_t iterator;

/**
 * Module last iteration result instance
 */
ehgk_iter_result_t iter_result;

/**
 * P3 values. Used by iterator
 */
const uint8_t p3_pin_values[5] = { 1, 2, 8, 64, 128 };

/** 
 * P1 values. Used by iterator.
 */
const uint8_t p1_pin_values[6] = { 1, 2, 4, 8, 16, 32 };

ehgk_iterator_t* ehgk_iterator()
{
   return &iterator;
}

void ehgk_iterator_init(ehgk_page_t page)
{
   //Save page and reset iterator state
   iterator.page = page;
   iterator.led_mask = 1;
   iterator.column_idx = 0;
   iterator.line_idx = 0;
}

ehgk_iter_result_t*  ehgk_iterator_next()
{
   /* 
   ================================================== 
     Generate P1 and P3 pins values and modes 
   ================================================== 
   */
   if ((iterator.page & iterator.led_mask) > 0)
   {
      // LED should be turn on

      // Electronic hourglass kit have six lines. 
      // Each line have direct and reverse LEDs groups.
      // Get line from line_idx  
      uint8_t line      = iterator.line_idx >> 1;

      // Get P1 and P3 direct values
      uint8_t p3_value  = p3_pin_values[iterator.column_idx];
      uint8_t p1_value  =  p1_pin_values[line];
      
      // P1M1[7:0] and P1M0[7:0] configure P1 pins mode.
      // P1M1 bit = 1 and P1M0 bit = 0 - input-only (high impedance mode). LED is turn off
      // P1M1 bit = 0 and P1M0 bit = 1 - push-pull mode (strong HIGH or LOW).
      // In push-pull mode LED turn on/off depends of P1 and P3 values
      iter_result.p1m1  = ~p1_value;
      iter_result.p1m0  = p1_value;

      // P3M1[7:0] and P3M0[7:0] configure P3 pins mode.
      // The idea is the same as P1M1/P1M0, but P3.2 should be always in 
      // quasi-bidirectional mode to handle button pressed
      iter_result.p3m1  = ~p3_value & 0xFB;
      iter_result.p3m0  = p3_value & 0xFB;

      // Get P1 and P3 values
      if ((iterator.line_idx & 0x01) == 1)
      {
         // Reverse group. For LED turn on P3 should be LOW and P1 should be HIGH
         iter_result.p1    = p1_value;
         iter_result.p3    = ~p3_value | 0x04;
      }
      else
      {
         // Direct group. For LED turn on P3 should be HIGH and P1 should be LOW
         iter_result.p1    = ~p1_value;
         iter_result.p3    = p3_value | 0x04;
      }
   }
   else
   {
      // LED should be turn off
      iter_result.p1m1  = 0xFF;
      iter_result.p1m0  = 0x00;
      iter_result.p3m1  = 0xFB;
      iter_result.p3m0  = 0x00;

      iter_result.p1 = 0;
      iter_result.p3 = 0x04;
   }

   /* 
   ===============================================================
     Prepare to the next iteraction. Increment internal state. 
   ===============================================================
   */

   iterator.led_mask <<= 1; // Shift left led mask to handle next led in range L1-L57
   
   // If current column is a last column in the line set next column to 0
   // otherwise increment coulumn
   if(iterator.column_idx == COLUMN_LEDS_COUNT - 1)
   {
      // Last column

      iterator.column_idx  = 0;

      // If curren line is a last line in the page then reinit iterator for the next page iteration cycle 
      // ohterwise increment line_idx
      if (iterator.line_idx == LINES_COUNT - 1)
      {
         ehgk_iterator_init(iterator.page);
      }
      else
      {
         iterator.line_idx++;
      }
   }
   else
   {
      // Column is not last in line.
      iterator.column_idx++;
   }

   return &iter_result;
}