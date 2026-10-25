import unittest

from lark import Lark, UnexpectedCharacters, UnexpectedToken
from ehgk.parser import EghkPagesParser, LedNumberTransformer


class TestEghkPagesParser(unittest.TestCase):
    
    def setUp(self):
        self.lark_parser = Lark(
            EghkPagesParser.ehgk_grammar,
            start = 'start',
            parser='lalr',
            transformer = LedNumberTransformer())
        
    def test_empty_page(self):
        tree = self.lark_parser.parse('EMPTY_PAGE')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('empty', [])])",
            str(tree.children[0])
        )
        
    def test_one_led(self):
        tree = self.lark_parser.parse('L50')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('leds', [50])])",
            str(tree.children[0])
        )
        
    def test_one_led_ws(self):
        # WS is ignored, so 'L 50' parses as 'L50'
        tree = self.lark_parser.parse('L 50')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('leds', [50])])",
            str(tree.children[0])
        )
        
    def test_led_number_range_more_than2digits(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse(
                """L123"""
            )
        self.assertEqual(
            "LED number 123 not in range 1..57",
            str(cm.exception)
        )        

    def test_led_number_range_2digits(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse(
                """L90"""
            )
        self.assertIn(
            "LED number 90 not in range 1..57",
            str(cm.exception)
        )        

    # --- Boundary values ---

    def test_led_min_boundary(self):
        tree = self.lark_parser.parse('L1')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('leds', [1])])",
            str(tree.children[0])
        )

    def test_led_max_boundary(self):
        tree = self.lark_parser.parse('L57')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('leds', [57])])",
            str(tree.children[0])
        )

    def test_led_below_min(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L0')
        self.assertEqual(
            "LED number 0 not in range 1..57",
            str(cm.exception)
        )

    def test_led_above_max(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L58')
        self.assertEqual(
            "LED number 58 not in range 1..57",
            str(cm.exception)
        )

    def test_led_far_above_max(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L999')
        self.assertEqual(
            "LED number 999 not in range 1..57",
            str(cm.exception)
        )

    # --- Duplicate LED detection ---

    def test_duplicate_led_twice(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L5 | L5')
        self.assertEqual(
            "Duplicate LED numbers: [5]",
            str(cm.exception)
        )

    def test_duplicate_led_three_times(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L5 | L5 | L5')
        self.assertEqual(
            "Duplicate LED numbers: [5]",
            str(cm.exception)
        )

    def test_multiple_different_duplicates(self):
        with self.assertRaises(ValueError) as cm:
            self.lark_parser.parse('L3 | L10 | L3 | L10')
        self.assertIn(
            "Duplicate LED numbers:",
            str(cm.exception)
        )
        self.assertIn("3", str(cm.exception))
        self.assertIn("10", str(cm.exception))

    def test_no_duplicate(self):
        tree = self.lark_parser.parse('L3 | L10 | L41')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "Tree('page_line', [Tree('leds', [3, 10, 41])])",
            str(tree.children[0])
        )

    def test_ignore_tabs(self):
        tree = self.lark_parser.parse("\tL1")    

        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "[Tree('page_line', [Tree('leds', [1])])]",
            str(tree.children)
        )
    
    def test_only_line_comment(self):
        with self.assertRaises(UnexpectedToken) as cm:
            
            self.lark_parser.parse('''
                // This is a comment
            ''')

        self.assertIn(
            'Unexpected token',
            str(cm.exception), 
        )

    def test_only_multi_line_comment_oneliner(self):
        with self.assertRaises(UnexpectedToken) as cm:
            
            self.lark_parser.parse('''
                /* This is a comment */
            ''')

        self.assertIn(
            'Unexpected token',
            str(cm.exception), 
        )

    def test_only_multi_line_comment(self):
        with self.assertRaises(UnexpectedToken) as cm:
            
            self.lark_parser.parse('''
                /* 
                  This is a comment 
                */
            ''')

        self.assertIn(
            'Unexpected token',
            str(cm.exception), 
        )

    def test_not_closed_comment(self):
        with self.assertRaises(UnexpectedCharacters) as cm:
            
            self.lark_parser.parse('''
                /* 
                  L1
            ''')

        self.assertIn(
            "No terminal matches '/'",
            str(cm.exception), 
        )

    def test_led_in_multi_line_comment(self):
        with self.assertRaises(UnexpectedToken) as cm:
            
            self.lark_parser.parse('''
                /* 
                  L1
                */
            ''')

        self.assertIn(
            'Unexpected token',
            str(cm.exception), 
        )

    def test_led_in_one_line_comment(self):
        with self.assertRaises(UnexpectedToken) as cm:
            
            self.lark_parser.parse('''
                // L1
            ''')

        self.assertIn(
            'Unexpected token',
            str(cm.exception), 
        )

    def test_leds_one_line(self):
       tree = self.lark_parser.parse('L3 | L10 | L41') 
       self.assertEqual(len(tree.children), 1)
       self.assertEqual(
            "[Tree('page_line', [Tree('leds', [3, 10, 41])])]",
            str(tree.children)
        )
       
    def test_leds_multiline(self):
        tree = self.lark_parser.parse(
            '''
            L3
              | L10 | 
            L41
            '''
        ) 
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            "[Tree('page_line', [Tree('leds', [3, 10, 41])])]",
            str(tree.children)
        )

    def test_line_comment_leds_one_line(self):
       tree = self.lark_parser.parse(
           '''
           // This is a page
           L3 | L10 | L41 // Another comment
           // Last comment
           ''') 
       self.assertEqual(len(tree.children), 1)
       self.assertEqual(
           "[Tree('page_line', [Tree('leds', [3, 10, 41])])]",
            str(tree.children)
        )


    def test_two_leds_pages(self):
        tree = self.lark_parser.parse(
            '''
            L1 | L2,
            L3 | L4
            '''
        )

        self.assertEqual(len(tree.children), 2)
        self.assertEqual(
           "[Tree('page_line', "
                    "[Tree('leds', [1, 2])]), "
                "Tree('page_line', "
                    "[Tree('leds', [3, 4])])]",
            str(tree.children)
        )


    def test_comment_leds_and_empty_page(self):
        tree = self.lark_parser.parse(
            '''
            // Pages example
            L1 | L2,
            L20 | L40 | L1, 
            L57,
            EMPTY_PAGE
            '''
        )

        self.assertEqual(4, len(tree.children))
        self.assertEqual(
            "[Tree('page_line', "
                    "[Tree('leds', [1, 2])]), "
                "Tree('page_line', "
                    "[Tree('leds', [20, 40, 1])]), "
                "Tree('page_line', "
                    "[Tree('leds', [57])]), "
                "Tree('page_line', "
                    "[Tree('empty', [])])]",
            str(tree.children)
        )


    if __name__ == '__main__':
        unittest.main()    