from ctypes import c_ulong
import unittest

from ehgk.parser import Eghk_Pages_Parser

class Test_Eghk_Pages_Parser(unittest.TestCase):

    def setUp(self):
        self.parser = Eghk_Pages_Parser()

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


if __name__ == '__main__':
    unittest.main()    