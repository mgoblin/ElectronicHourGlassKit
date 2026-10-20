import unittest

import ctypes

from ehgk.serializer import EhgkToBytesSerializer, EhgkToHexSerializer

class Ehgk_to_Bytes_Serializer_Test(unittest.TestCase):

    def setUp(self):
        self.serializer = EhgkToBytesSerializer()
    
    def test_pages_to_bytes(self):
        one = ctypes.c_uint64(1)
        two = ctypes.c_uint64(2)
        page = [one, two]
        serialized_value = self.serializer.pages_to_bytes(page)
        
        self.assertEqual(serialized_value, b'\x01\x00\x00\x00\x00\x00\x00\x00\x02\x00\x00\x00\x00\x00\x00\x00')


class Ehgk_to_Hex_Serializer_Test(unittest.TestCase):

    def setUp(self):
        self.serializer = EhgkToHexSerializer()
    
    def test_pages_to_hex(self):
        one = ctypes.c_uint64(1)
        two = ctypes.c_uint64(2)
        page = [one, two]
        hex_content = self.serializer.pages_to_hex(page)
        
        self.assertIsInstance(hex_content, str)
        self.assertIn(':10', hex_content)  # Intel HEX record
        self.assertIn('00000000', hex_content)  # address record

    def test_pages_to_hex_empty_page(self):
        zero = ctypes.c_uint64(0)
        page = [zero]
        hex_content = self.serializer.pages_to_hex(page)
        
        self.assertIsInstance(hex_content, str)
        self.assertIn(':08', hex_content)  # Intel HEX record for 8 bytes

    def test_pages_to_hex_multiple_pages(self):
        pages = [ctypes.c_uint64(i) for i in range(10)]
        hex_content = self.serializer.pages_to_hex(pages)
        
        self.assertIsInstance(hex_content, str)
        self.assertIn(':10', hex_content)