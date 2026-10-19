import ctypes
import unittest

from lark import Lark

from ehgk.parser import Eghk_Page_Inrerpreter, Eghk_Pages_Parser, LedNumber_Transformer

class Test_Eghk_Page_Interpreter(unittest.TestCase):
    
    def setUp(self):
        self.parser = Lark(
            Eghk_Pages_Parser.ehgk_grammar, 
            start = 'start',
            parser='lalr',
            transformer = LedNumber_Transformer())

    def test_empty_page(self):
        tree = self.parser.parse('EMPTY_PAGE')
        page_interpreter = Eghk_Page_Inrerpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(0)]'
        )

    def test_L1_led(self):
        tree = self.parser.parse('L1')

        page_interpreter = Eghk_Page_Inrerpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(1)]'
        )

    def test_L5_led(self):
        tree = self.parser.parse('L5')

        page_interpreter = Eghk_Page_Inrerpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(16)]'
        )

    def test_L1_and_L5_leds(self):
        tree = self.parser.parse('L1 | L5')

        page_interpreter = Eghk_Page_Inrerpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(17)]'
        )
    

if __name__ == '__main__':
    unittest.main()    