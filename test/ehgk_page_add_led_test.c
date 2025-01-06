#include <unity.h>
#include <ehgk_page.h>
#include "ehgk_page_test.h"

void test_ehgk_page_value_is_empty_after_init()
{
    ehgk_page_t page = EMPTY_PAGE;
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE, 
        page, 
        "Page value after init should be 0"
    );
}

void test_ehgk_page_add_led1()
{
    ehgk_page_t page = EMPTY_PAGE;

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE, 
        page, 
        "Seems to page is not cleared before test case started"
    );

    ehgk_page_add_led(page, L1);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L1, 
        page, 
        "L1 page should have value 1");

    ehgk_page_add_led(page, L1);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L1, 
        page,
        "L1 page should have value 1 after setting it twice");
}

void test_ehgk_page_add_led2()
{
    ehgk_page_t page = EMPTY_PAGE;
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE, 
        page,
        "Seems to page is not cleared before test case started");

    ehgk_page_add_led(page, L2);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L2, 
        page,
        "L2 page should have value 2");

    ehgk_page_add_led(page, L2);
    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L2, 
        page,
        "L2 page should have value 2 after setting it twice");
}

void test_ehgk_page_add_leds_1_2()
{
    ehgk_page_t page = EMPTY_PAGE;

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        EMPTY_PAGE, 
        page, 
        "Seems to page is not cleared before test case started"
    );

    ehgk_page_add_led(page, L1);
    ehgk_page_add_led(page, L2);

    TEST_ASSERT_EQUAL_UINT64_MESSAGE(
        L1 + L2, 
        page,
        "L1, L2 page value should be equals to 3"
    );

}