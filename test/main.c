#include <unity.h>
#include "ehgk_page_test.h"
#include "ehgk_page_iterator_test.h"

void setUp(void) {
    // set stuff up here
}

void tearDown(void) {
    // clean stuff up here
}

int main( int argc, char **argv) {
    UNITY_BEGIN();

    RUN_TEST(test_ehgk_page_value_is_empty_after_init);
    RUN_TEST(test_ehgk_page_add_led1);
    RUN_TEST(test_ehgk_page_add_led2);
    RUN_TEST(test_ehgk_page_add_leds_1_2);

    RUN_TEST(test_ehgk_page_delete_led1_from_empty_page);
    RUN_TEST(test_ehgk_page_delete_led1);
    RUN_TEST(test_ehgk_page_delete_led2);
    RUN_TEST(test_ehgk_page_delete_led_1_2);

    RUN_TEST(test_iterator_init);
    RUN_TEST(test_iterate_once_empty_page);
    RUN_TEST(test_iterate_once_one_led_page);
    
    RUN_TEST(test_iterate_line0_columns_empty_page);
    RUN_TEST(test_iterate_line0_columns_L1_page);
    RUN_TEST(test_iterate_line0_columns_L2_page);
    RUN_TEST(test_iterate_line0_columns_L3_page);
    RUN_TEST(test_iterate_line0_columns_L4_page);
    RUN_TEST(test_iterate_line0_columns_L5_page);

    RUN_TEST(test_iterate_line0_columns_L2_L3_page);

    RUN_TEST(test_iterate_line1_empty_page);
    RUN_TEST(test_iterate_line1_all_columns_page);
    RUN_TEST(test_iterate_all_lines_empty_page);

    UNITY_END();
}
