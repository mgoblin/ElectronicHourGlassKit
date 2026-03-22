"""
This module provides classes for converting
electronical glass hour kit pages defintion 
to list of unsigned long's.
"""
import ctypes

from lark import Lark, Transformer, v_args
from lark.visitors import Interpreter

class LedNumber_Transformer(Transformer):
    '''
    LED number transformer validate that parsed number is in range 1..57
    (LED_MIN .. LED_MAX)
    '''
    
    LED_MIN = 1
    '''
    Minimal LED number (1)
    '''
    LED_MAX = 57
    '''
    Maximal LED number (57)
    '''

    @v_args(inline=True)  # Inline gives the token directly, not a list
    def lednum(self, n):
        '''
        Transform led number to integer and validate number in LED numbers range. 
        '''
        if n[0] != 'L':
            raise ValueError(f"LED definition first letter should be L in {n}")

        val = int(n[1:])
        if LedNumber_Transformer.LED_MIN <= val <= LedNumber_Transformer.LED_MAX:
            return val
        raise ValueError(f"LED number {val} not in range {LedNumber_Transformer.LED_MIN}..{LedNumber_Transformer.LED_MAX}")

class Eghk_Pages_Parser:
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
        parser: :py:class:`lark.Lark` parser. Parses pages definition.
        interpreter: :py:class:`Pages_Inrerpreter` interpreter. Converts parsed tree to unsigned long's list.

    """
    
    
    ehgk_grammar = '''
        // A bunch of pages
        start: page* page_line				

        // Page is a LEDs or empty screen
        page: page_line ","

        page_line: (leds | empty)

        // LEDs page
        leds:  lednum ("|" lednum)* 

        // LED number
        lednum: LED_NUM

        // Empty page
        empty: "EMPTY_PAGE" -> empty

        COMMENT: C_LINE_COMMENT | C_BLOCK_COMMENT

        C_LINE_COMMENT: "//" /.*/
        C_BLOCK_COMMENT: "/*" /(.|\\n)*?/ "*/"

        LED_NUM: /L\d+/
        %import common.WORD   
        %import common.WS


        // Disregard spaces in text
        %ignore WS           
        %ignore COMMENT
        %ignore /[\\t]/ // Ignores tab.
    '''
    """
    EHGK grammar.
    """

    def parse(self, pages_definition):
        """
        Convert pages definition to list of c_uint64.

            Params:
                pages_definition: string. Pages definition.

            Returns: 
                List of pages. Each page element has ctypes.c_uint64 type.
        """
        
        parser = Lark(
            Eghk_Pages_Parser.ehgk_grammar, 
            start = 'start',
            parser='lalr',
            transformer = LedNumber_Transformer())
        
        interpreter = Eghk_Page_Inrerpreter()

        # parse pages definition
        tree = parser.parse(pages_definition) 
        # convert parsed tree to pages list
        interpreter.visit(tree)
        
        return interpreter.pages
        

class Eghk_Page_Inrerpreter(Interpreter):
    '''
    Page LEDs numbers to c_uint64 converter.

    This class used inside :py:class:`Eghk_Page_Parser`
    '''
    
    def __init__(self):
        '''
        Initialize empty pages value list

        Attributes:
            pages (list): output values list
        '''
        
        self.pages = []

    def empty(self, tree):
        '''
        Transforms EMPTY_PAGE to 0
        '''
        self.pages.append(ctypes.c_uint64(0))

    def leds(self, tree):
        '''
        Transforms one page LED's numbers list to the output c_uint64 value
        '''
        
        page_value = 0
        for led_num in tree.children:
            offset = led_num - 1
            page_value = page_value | (1 << offset)
        
        self.pages.append(ctypes.c_uint64(page_value))
