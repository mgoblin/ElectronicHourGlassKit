import ctypes
import unittest

from lark import Lark

from ehgk.parser import EghkPageInterpreter, EghkPagesParser, LedNumberTransformer

class Test_Eghk_Page_Interpreter(unittest.TestCase):
    
    def setUp(self):
        self.parser = Lark(
            EghkPagesParser.ehgk_grammar,
            start = 'start',
            parser='lalr',
            transformer = LedNumberTransformer())

    def test_empty_page(self):
        tree = self.parser.parse('EMPTY_PAGE')
        page_interpreter = EghkPageInterpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(0)]'
        )

    def test_L1_led(self):
        tree = self.parser.parse('L1')

        page_interpreter = EghkPageInterpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(1)]'
        )

    def test_L5_led(self):
        tree = self.parser.parse('L5')

        page_interpreter = EghkPageInterpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(16)]'
        )

    def test_L1_and_L5_leds(self):
        tree = self.parser.parse('L1 | L5')

        page_interpreter = EghkPageInterpreter()
        page_interpreter.visit(tree)

        self.assertEqual(
            str(page_interpreter.pages), 
            '[c_ulong(17)]'
        )
    

if __name__ == '__main__':
    unittest.main()    