#pragma once
/**
 * @file ehgk_page_iterator.h
 * 
 * @brief Electronic hourglass kit iterator module.
 * 
 * @details Iterator calculates and return P1 and P3 pins state for page displaying. 
 * 
 * @author Michael Golovanov mike.golovanov@gmail.com
 */
#include <ehgk_page.h>

/**
 * @brief Electronic hourglass kit iterator
 * 
 * @details Iterator calculates and return P1 and P3 pins state for page displaying.
 * 
 * Iterator save page displaying state in its fields
 */
typedef struct ehgk_iterator_t
{
    /**
     * @brief Iterator page 
     */
    ehgk_page_t page;

    /**
     * @brief Current led mask (LED position to calculate P1 and P3 pins state).
     */
    uint64_t led_mask;

    /**
     * @brief Current column
     */
    uint8_t column_idx;

    /**
     * @brief Current line
     */
    uint8_t line_idx;
} ehgk_iterator_t;

/**
 * @brief P1 and P3 state for current LED displaying
 * 
 * @details State is an one iteration result
 */
typedef struct ehgk_iter_result_t
{
    /**
     * P3 pins value
     */
    uint8_t p3;

    /**
     * P1 pins value
     */
    uint8_t p1;

    /**
     * @brief P3M0 value. With the P3M1 set P3 pin mode
     */
    uint8_t p3m0;

    /**
     * @brief P3M1 value. With the P3M0 set P3 pin mode
     */
    uint8_t p3m1;

    /**
     * @brief P1M0 value. With the P1M1 set P1 pin mode
     */
    uint8_t p1m0;

    /**
     * @brief P1M1 value. With the P1M0 set P1 pin mode
     */
    uint8_t p1m1;
} ehgk_iter_result_t;

/**
 * @brief Get page iterator
 * 
 * @return page iterator ref 
 */
ehgk_iterator_t* ehgk_iterator();

/**
 * @brief Initialize iterator
 * 
 * @details Reset internal iterator state and get ready to iterate though page
 * 
 * @param page ehgk_page_t page for iterate through
 */
void ehgk_iterator_init(ehgk_page_t page);

/**
 * @brief take one iteration
 * @details On each iteration calculate P1 and P3 pins values and states 
 * only for one(current) LED.
 * 
 * @return iteration result with P1 and P3 page values and modes
 */
ehgk_iter_result_t* ehgk_iterator_next();
