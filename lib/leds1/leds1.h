#pragma once

/**
 * @file leds1.h
 * 
 * Small library to manipulate leds of electronic hourglass kit
 * 
 * @author Michael Golovanov mike.golovanov@gmail.com
 */

#include <sys.h>
#include <pin.h>

/**
 * @brief Turns off all leds of electronic hourglass kit
 */
void leds_off();

/**
 * @brief Turns on L1 led of electronic hourglass kit  
 */
void led_1_on();