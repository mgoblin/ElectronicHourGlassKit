import unittest

from ehgk.parser import EghkPagesParser

class TestEghkPagesParser(unittest.TestCase):

    def setUp(self):
        self.parser = EghkPagesParser()

    def test_parse_empty_page(self):
        ctype_pages = self.parser.parse('EMPTY_PAGE')
        pages = list(map(lambda x: x.value, ctype_pages))
        self.assertListEqual(pages, [0])

    def test_parse_single_led(self):
        ctype_pages = self.parser.parse('L3') 
        pages = list(map(lambda x: x.value, ctype_pages)) 
        self.assertListEqual(pages, [4]) 

    def test_parse_one_page_leds(self):
        ctype_pages = self.parser.parse('L4 | L3')
        pages = list(map(lambda x: x.value, ctype_pages))
        self.assertListEqual(pages, [12]) 

    def test_parse_mcomment_and_page(self):
        ctype_pages = self.parser.parse(
            '''
                /* This is a 
                 * multiline comment 
                 */
                 L1
            '''
        )
        pages = list(map(lambda x: x.value, ctype_pages))
        self.assertListEqual(pages, [1])

    def test_parse_lcomment_and_page(self):
        ctype_pages = self.parser.parse(
            '''
                L1 // This is a single line comment
            '''
        )
        pages = list(map(lambda x: x.value, ctype_pages))
        self.assertListEqual(pages, [1])

    def test_parse_multi_pages_with_comments(self):
        ctype_pages = self.parser.parse(
            '''
                // Pages example
                L1 | L2,
                L20 | L40 | L1, 
                L57,
                EMPTY_PAGE,
                L1 |
                L4
            '''
        )
        pages = list(map(lambda x: x.value, ctype_pages))
        self.assertListEqual(pages, [3, 549756338177, 72057594037927936, 0, 9])

    def test_parse_state_reset_between_calls(self):
        """Verify that repeated parse() calls on the same parser don't accumulate pages."""
        result1 = self.parser.parse('L1')
        pages1 = list(map(lambda x: x.value, result1))
        self.assertListEqual(pages1, [1])

        result2 = self.parser.parse('L2')
        pages2 = list(map(lambda x: x.value, result2))
        self.assertListEqual(pages2, [2])

        # First result should still be [1], not [1, 2]
        pages1_after = list(map(lambda x: x.value, result1))
        self.assertListEqual(pages1_after, [1])


if __name__ == '__main__':
    unittest.main()    