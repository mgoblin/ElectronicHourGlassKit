#include <unity.h>

#include <ehgk_page_iterator.h>
#include "ehgk_page_iterator_test.h"

void test_iterator_init()
{
    uint64_t page = L1 | L2 | L3; 
    ehgk_iterator_init(page);

    ehgk_iterator_t *iter = ehgk_iterator();

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        page,
        iter->page,
        "Page was changed"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        1,
        iter->led_mask,
        "LED mask should be equals to 1"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        0,
        iter->column_idx,
        "Column should be equals to 0"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        0,
        iter->line_idx,
        "Line should be equa to 0"
    );
}

void test_iterate_once_empty_page()
{
    uint64_t page = EMPTY_PAGE; 
    ehgk_iterator_init(page);

    ehgk_iterator_t *iter = ehgk_iterator();

    ehgk_iter_result_t *result = ehgk_iterator_next();

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        page,
        iter->page,
        "Page was changed"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        2,
        iter->led_mask,
        "LED mask should be equals to 1"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        1,
        iter->column_idx,
        "Column should be equals to 0"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        0,
        iter->line_idx,
        "Line should be equa to 0"
    ); 
    
    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0,
        result->p1,
        "All P1 pins should be LOW"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0x04,
        result->p3,
        "All P3 except P3.2 pins should be LOW"
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

void test_iterate_once_one_led_page()
{
    uint64_t page = L1; 
    ehgk_iterator_init(page);

    ehgk_iterator_t *iter = ehgk_iterator();

    ehgk_iter_result_t *result = ehgk_iterator_next();

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        page,
        iter->page,
        "Page was changed"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        2,
        iter->led_mask,
        "LED mask should be equals to 1"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        1,
        iter->column_idx,
        "Column should be equals to 0"
    );

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        0,
        iter->line_idx,
        "Line should be equa to 0"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0xFE,
        result->p1,
        "Only P1.0 pin should be LOW"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0x05,
        result->p3,
        "Only P3.0 except P3.2 pin should be LOW"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0xFE,
        result->p1m1,
        "P1M1 should be equals to 0xFE. P1.7-P1.1 in input only mode, P1.0 push pull mode"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0x01,
        result->p1m0,
        "P1M0 should be equals to 0x01. P1.7-P1.1 in input only mode, P1.0 in push pull mode "
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0xFA,
        result->p3m1,
        "P3M1 should be equals to 0xFA. P3.7-P3.3, P3.1 in input only mode, P3.2 quasi bidirectional and P3.0 in push pull mode"
    );

    TEST_ASSERT_EQUAL_UINT8_MESSAGE(
        0x01,
        result->p3m0,
        "P3M0 should be equals to 0x01. P3.7-P3.3, P3.1 in input only mode, P3.2 in quasi bidirectional. P3.0 in push pull mode"
    );    
}