"""
This module provides classes for converting
electronical glass hour kit pages definition
to list of unsigned long's.
"""
from collections import Counter
import ctypes

from lark import Lark, Transformer, Tree
from lark.visitors import Interpreter

class LedNumberTransformer(Transformer):
    """
    LED number transformer validates that parsed numbers are in range 1..57
    (LED_MIN … LED_MAX). Transforms "L" NUMBER pairs into integers.
    """

    LED_MIN = 1
    '''
    Minimal LED number (1)
    '''
    LED_MAX = 57
    '''
    Maximal LED number (57)
    '''

    def led_item(self, tree):
        """
        Transform led_item ("L" NUMBER) into validated integer.
        """
        val = int(tree[-1])
        if self.LED_MIN <= val <= self.LED_MAX:
            return val
        raise ValueError(
            f"LED number {val} not in range {self.LED_MIN}..{self.LED_MAX}"
        )

    @staticmethod
    def leds(tree):
        """
        Collect LED numbers into a list wrapped in a Tree.
        Raise ValueError on duplicate LED numbers.
        """
        if len(tree) != len(set(tree)):
            counter = Counter(tree)
            duplicates = [value for value, count in counter.items() if count > 1]
            raise ValueError(f"Duplicate LED numbers: {duplicates}")
        return Tree('leds', tree)

class EghkPagesParser:
    """
    This class provides methods for converting 
    electronical glass hour kit pages definition to list of unsigned long's.

    Pages definition is comma separated strings of LEDs.
    One page is defined by one LEDs list separated by '|'.
    LEDs are numbered from 1 to 57.
    Special page 'EMPTY_PAGE' is defined by empty list.
    Line and block comments are supported.

    Pages definition example:
        // Pages example
        L1 | L2,
        L20 | L40 | L1, 
        L57,
        EMPTY_PAGE

    Pages definition parsing is done by Lark parser. 

    Each page is converted to unsigned long value.
    First 57s bits of unsigned long value are used to represent LEDs.
    Bits are numbered from 0 to 56. And set bit to 1 means LED is on.


    Attributes:
        parser: :py:class:`lark.Lark` parser. Parse pages definition.
        interpreter: :py:class:`Pages_Interpreter` interpreter. Converts parsed tree to unsigned long's list.
    """
    
    
    ehgk_grammar = '''
        // A bunch of pages
        start: page* page_line

        // Page is a LEDs or empty screen
        ?page: page_line ","

        page_line: (leds | empty)

        // LEDs page
        leds: led_item ("|" led_item)*
        led_item: "L" NUMBER

        // Empty page
        empty: "EMPTY_PAGE" -> empty

        COMMENT: C_LINE_COMMENT | C_BLOCK_COMMENT

        C_LINE_COMMENT: "//" /.*/
        C_BLOCK_COMMENT: "/*" /(.|\\n)*?/ "*/"

        %import common.WORD
        %import common.WS
        %import common.NUMBER

        // Disregard spaces in text
        %ignore WS
        %ignore COMMENT
    '''
    """
    EHGK grammar.
    """

    def __init__(self):
        self.parser = Lark(
            EghkPagesParser.ehgk_grammar,
            start='start',
            parser='lalr',
            transformer=LedNumberTransformer(),
        )

        self.interpreter = EghkPageInterpreter()

    def parse(self, pages_definition):
        """
        Convert pages definition to list of c_uint64.

            Params:
                pages_definition: string. Pages definition.

            Returns: 
                List of pages. Each page element has ctypes.c_uint64 type.
        """

        # parse pages definition
        tree = self.parser.parse(pages_definition)
        # convert parsed tree to pages list
        self.interpreter.visit(tree)
        
        return self.interpreter.pages
        

class EghkPageInterpreter(Interpreter):
    """
    Page LEDs numbers to c_uint64 converter.

    This class used inside :py:class:`Eghk_Page_Parser`

    Attributes:
        pages (list): output values list
    """
    
    def __init__(self):
        """
        Initialize empty pages value list
        """
        self.pages = []

    def empty(self, tree):
        """
        Transforms EMPTY_PAGE to 0
        """
        self.pages.append(ctypes.c_uint64(0))

    def leds(self, tree):
        """
        Transforms one-page LED's numbers list to the output c_uint64 value
        """
        page_value = 0
        for led_num in tree.children:
            offset = led_num - 1
            page_value |= 1 << offset
        self.pages.append(ctypes.c_uint64(page_value))
