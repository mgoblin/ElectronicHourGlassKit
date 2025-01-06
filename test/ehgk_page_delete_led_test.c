#include <unity.h>
#include <ehgk_page.h>
#include "ehgk_page_test.h"


void test_ehgk_page_delete_led1_from_empty_page()
{
    ehgk_page_t page = EMPTY_PAGE;

    ehgk_page_delete_led(page, L1);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE,
        page,
        "Value should be equals to 0"
    );
}

void test_ehgk_page_delete_led1()
{
    ehgk_page_t page = L1;
    
    ehgk_page_delete_led(page, L1);

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE,
        page,
        "Value should be equals to 0"
    );
}

void test_ehgk_page_delete_led2()
{
    ehgk_page_t page = L2;
    
    ehgk_page_delete_led(page, L2);

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE,
        page,
        "Value should be equals to 0"
    );
}

void test_ehgk_page_delete_led_1_2()
{
    ehgk_page_t page = L1 + L2;

    ehgk_page_delete_led(page, L1);

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L2,
        page,
        "Value should be equals to 2"
    );

    ehgk_page_delete_led(page, L2);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE,
        page,
        "Value should be equals to 0"
    );
}