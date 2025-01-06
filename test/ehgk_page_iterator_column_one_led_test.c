#include <unity.h>

#include <ehgk_page_iterator.h>
#include "ehgk_page_iterator_test.h"
#include "eghk_page_iterator_test_utils.h"

void test_iterate_line0_columns_empty_page()
{
    ehgk_iterator_init(EMPTY_PAGE);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            EMPTY_PAGE,
            iter->page,
            "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i < COLUMN_LEDS_COUNT - 1)
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 
        }
        else
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->column_idx,
                "After last column is iterated column_idx should be equals to 0"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                1,
                iter->line_idx,
                "After last column is iterated line_idx should be equals to 1"
            );
        } // end if

        validate_led_off_result(result);

    } // end for
}

void test_iterate_line0_columns_L1_page()
{
    ehgk_iterator_init(L1);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                L1,
                iter->page,
                "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i < COLUMN_LEDS_COUNT - 1)
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 
        }
        else
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->column_idx,
                "After last column is iterated column_idx should be equals to 0"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                1,
                iter->line_idx,
                "After last column is iterated line_idx should be equals to 1"
            );
        } // end if

        if (i == 0)
        {
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1,
                "Only P1.0 pin should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x05,
                result->p3,
                "Only P3.0 and P3.2 pins should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "P1M1 should be equals to 0xFE. Only P1.0 in push pull mode, other P.x input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                1,
                result->p1m0,
                "P1M0 should be equals to 0x01. Only P1.0 in push pull mode, other P1.x input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFA,
                result->p3m1,
                "P3M1 should be equals to 0xFE. Only P3.0 in push pull mode, ohter P3.x in input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p3m0,
                "P3M0 should be equals to 0x01. Only P3.0 in push pull mode, ohter P3.x in input only mode"
            );

        } 
        else
        {
            validate_led_off_result(result);
        } // end if
    } // end for
}

void test_iterate_line0_columns_L2_page()
{
    ehgk_iterator_init(L2);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                L2,
                iter->page,
                "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i == 1) // L2
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 

            // Validate L2 result
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
               0xFE,
                result->p1,
                "Only P1.0 pin should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x06,
                result->p3,
                "Only P3.1 and P3.2 pins should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1m0,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xF9,
                result->p3m1,
                "Only P3.1 pin should be in push pull mode, P3.2 in quasi bidirectional"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x02,
                result->p3m0,
                "Only P3.1 pin should be in push pull mode"
            );

        }
        else
        {
            validate_led_off_result(result);
        }
    } // end for
}

void test_iterate_line0_columns_L3_page()
{
    ehgk_iterator_init(L3);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            L3,
            iter->page,
            "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i == 2) // L3
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 

            // Validate L3 result
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
               0xFE,
                result->p1,
                "Only P1.0 pin should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x0C,
                result->p3,
                "Only P3.3 and P3.2 pin should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1m0,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xF3,
                result->p3m1,
                "Only P3.3 pin should be in push pull mode, P3.2 in quasi bidirectional"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x08,
                result->p3m0,
                "Only P3.3 pin should be in push pull mode"
            );

        } 
        else
        {
            validate_led_off_result(result);
        }

    } // end for
}

void test_iterate_line0_columns_L4_page()
{
    ehgk_iterator_init(L4);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                L4,
                iter->page,
                "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i == 3) // L4
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 

            // Validate L3 result
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
               0xFE,
                result->p1,
                "Only P1.0 pin should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x44,
                result->p3,
                "Only P3.6 and P3.2 pins should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1m0,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xBB,
                result->p3m1,
                "Only P3.3 pin should be in push pull mode, P3.2 in quasi bidirectional mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x40,
                result->p3m0,
                "Only P3.3 pin should be in push pull mode"
            );
        }
        else
        {
            validate_led_off_result(result);
        } // end if

    } // end for
}

void test_iterate_line0_columns_L5_page()
{
    ehgk_iterator_init(L5);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                L5,
                iter->page,
                "Page was changed"
        );

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
            1 << (i + 1),
            iter->led_mask,
            "LED mask should be equals to 1 << column_idx"
        );

        if (i < COLUMN_LEDS_COUNT - 1)
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                i + 1,
                iter->column_idx,
                "Column should be equals to i + 1"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->line_idx,
                "Line should be equa to 0"
            ); 

            validate_led_off_result(result);
        }
        else
        {
            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                0,
                iter->column_idx,
                "After last column is iterated column_idx should be equals to 0"
            );

            TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                1,
                iter->line_idx,
                "After last column is iterated line_idx should be equals to 1"
            );

            // Validate  iter_result for L5
            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
               0xFE,
                result->p1,
                "Only P1.0 pin should be LOW"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x84,
                result->p3,
                "Only P3.7 and P3.2 pins should be HIGH"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xFE,
                result->p1m1,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x01,
                result->p1m0,
                "Only P1.0 pin should be in push pull mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x7B,
                result->p3m1,
                "Only P3.7 pin should be in push pull mode, P3.2 in quasi bidirectional mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x80,
                result->p3m0,
                "Only P3.7 pin should be in push pull mode"
            );
        } // end if

    } // end for
}