#include <unity.h>

#include <ehgk_page_iterator.h>
#include "ehgk_page_iterator_test.h"
#include "eghk_page_iterator_test_utils.h"

void test_iterate_line0_columns_L2_L3_page()
{
    ehgk_iterator_init(L2 | L3);

    ehgk_iterator_t *iter = ehgk_iterator();

    for(uint8_t i = 0; i < COLUMN_LEDS_COUNT; i++)
    {
        ehgk_iter_result_t *result = ehgk_iterator_next();

        TEST_ASSERT_EQUAL_UINT64_MESSAGE(
                L2 | L3,
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
                "P1M1 should be equals to 0xFE. Only P1.0 in push pull mode, other P.x input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                1,
                result->p1m0,
                "P1M0 should be equals to 0x01. Only P1.0 in push pull mode, other P1.x input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0xF9,
                result->p3m1,
                "P3M1 should be equals to 0xFD. Only P3.1 in push pull mode, P3.2 in quasi bidirectional mode and ohter P3.x in input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x02,
                result->p3m0,
                "P3M0 should be equals to 0x01. Only P3.1 in push pull mode, ohter P3.x in input only mode"
            );

        } // end if i == 1
        else if (i == 2) // L3
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
                "Only P3.3 and P3.2 pins should be HIGH"
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
                0xF3,
                result->p3m1,
                "P3M1 should be equals to 0xF3. Only P3.3 in push pull mode, P3.2 in quasi bidirectional mode and ohter P3.x in input only mode"
            );

            TEST_ASSERT_EQUAL_UINT8_MESSAGE(
                0x08,
                result->p3m0,
                "P3M0 should be equals to 0x08. Only P3.3 in push pull mode, ohter P3.x in input only mode"
            );
        } // end if i == 2
        else
        {
            validate_led_off_result(result);
        } // end if 

    } // end for
}