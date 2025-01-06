#include <unity.h>

#include <ehgk_page_iterator.h>
#include "ehgk_page_iterator_test.h"
#include "eghk_page_iterator_test_utils.h"

void test_iterate_line1_empty_page()
{
    ehgk_iter_result_t *result;

    ehgk_iterator_init(EMPTY_PAGE);
    ehgk_iterator_t *iter = ehgk_iterator();

    // Iterate through first line
    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        result = ehgk_iterator_next();
    }

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0,
        iter->column_idx,
        "After iterate through line column index should be 0 again"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        1,
        iter->line_idx,
        "After iterate through line line index should be incremented to 1 again"
    );

    // Iterate through column 0, line 1
    result = ehgk_iterator_next();
    validate_led_off_result(result);
}

void test_iterate_line1_all_columns_page()
{
    ehgk_iter_result_t *result;

    ehgk_iterator_init(L6 | L7 | L8 | L9 | L10);
    ehgk_iterator_t *iter = ehgk_iterator();

    // Iterate through first line
    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        result = ehgk_iterator_next();
    }

    // Iterate through column 0, line 1
    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        result = ehgk_iterator_next();
        if (i == COLUMN_LEDS_COUNT - 1)
        {
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0,
                iter->column_idx,
                "After iterate through line column index should be 0 again"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                2,
                iter->line_idx,
                "After iterate through line1, line index should be 2"
            );

            // Validate iteration result
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1,
                "After last reverse line column only P1.0 should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x7F,
                result->p3,
                "After last reverse line column only P3.0 should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "After last reverse line column only P1.0 should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1m0,
                "After last reverse line column only P1.0 should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x7B,
                result->p3m1,
                "After last reverse line column only P3.0 should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x80,
                result->p3m0,
                "After last reverse line column only P3.0 should be in push pull mode"
            );

        }
        else if (i == 0 | i == 1) // P3.0 and P3.1
        {
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1,
                "Only P1.0 should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                ~(1 <<  i),
                result->p3,
                "Only P3.i should be LOW"
            );
        }
        else if (i == 2) // P3.3
        {
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1,
                "Only P1.0 should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xF7,
                result->p3,
                "Only P3.6 should be LOW"
            );
        }
        else if (i == 3) // P3.6
        {
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1,
                "Only P1.0 should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xBF,
                result->p3,
                "Only P3.6 should be LOW"
            );
        }
    } // end for iteration through line 1
}

void test_iterate_all_lines_empty_page()
{
    ehgk_iter_result_t *result;

    ehgk_iterator_init(EMPTY_PAGE);
    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < LED_LINES_COUNT * COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iterator_next();
    }

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0,
        iter->column_idx,
        "After iterate through all lines column index should be 0 again"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0,
        iter->line_idx,
        "After iterate through all lines line index should be 0 again"
    );

}