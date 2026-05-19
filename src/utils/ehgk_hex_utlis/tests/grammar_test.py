import unittest

from lark import Lark, Tree, Token, UnexpectedCharacters, UnexpectedToken
from ehgk.parser import Eghk_Pages_Parser, LedNumber_Transformer


class Test_Eghk_Pages_Parser(unittest.TestCase):
    
    def setUp(self):
        self.lark_parser = Lark(
            Eghk_Pages_Parser.ehgk_grammar, 
            start = 'start',
            parser='lalr',
            transformer = LedNumber_Transformer())
        
    def test_empty_page(self):
        tree = self.lark_parser.parse('EMPTY_PAGE')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            tree.children[0], 
            Tree(Token('RULE', 'page_line'), [Tree('empty', [])]))
        
    def test_one_led(self):
        tree = self.lark_parser.parse('L50')
        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            tree.children[0], 
            Tree(
                Token('RULE', 'page_line'), 
                [Tree(Token('RULE', 'leds'), [50])]))
        
    def test_one_led_ws(self):
        with self.assertRaises(UnexpectedCharacters) as ex:
            self.lark_parser.parse('L 50')

        self.assertIn(
            "No terminal matches 'L'",
            str(ex.exception))
        
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

    def test_ignore_tabs(self):
        tree = self.lark_parser.parse("\tL1")    

        self.assertEqual(len(tree.children), 1)
        self.assertEqual(
            str(tree.children),
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [1])])]"
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
            str(tree.children),
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [3, 10, 41])])]"
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
            str(tree.children),
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [3, 10, 41])])]"
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
            str(tree.children),
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [3, 10, 41])])]"
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
            str(tree.children),
            "[Tree(Token('RULE', 'page'), "
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [1, 2])])]), " \
            
            "Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [3, 4])])]"
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

        self.assertEqual(len(tree.children), 4)
        self.assertEqual(
            str(tree.children),
            "[Tree(Token('RULE', 'page'), "
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [1, 2])])]), " \
            
            "Tree(Token('RULE', 'page'), "
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [20, 40, 1])])]), " \
            
            "Tree(Token('RULE', 'page'), "
            "[Tree(Token('RULE', 'page_line'), "
            "[Tree(Token('RULE', 'leds'), [57])])]), " \
            
            "Tree(Token('RULE', 'page_line'), "
            "[Tree('empty', [])])]"
        )


    if __name__ == '__main__':
        unittest.main()    