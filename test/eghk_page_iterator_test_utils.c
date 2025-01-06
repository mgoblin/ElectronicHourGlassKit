#include "eghk_page_iterator_test_utils.h"

void validate_led_off_result(ehgk_iter_result_t *result)
{
        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0,
            result->p1,
            "All P1 pins should be LOW"
        );

        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0x04,
            result->p3,
            "All P3 pins except P3.2 should be LOW"
        );

        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0xFF,
            result->p1m1,
            "P1M1 should be equals to 0xFF"
        );

        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0,
            result->p1m0,
            "P1M0 should be equals to 0x00"
        );

        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0xFB,
            result->p3m1,
            "P3M1 should be equals to 0xFF"
        );

        TEST_ASSERT_EQUAL_UINT8_MESSAGE(
            0,
            result->p3m0,
            "P3M0 should be equals to 0x00"
        );

}
