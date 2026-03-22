import unittest

import ctypes

from ehgk.serializer import Ehgk_to_Bytes_Serializer

class Ehgk_to_Bytes_Serializer_Test(unittest.TestCase):

    def setUp(self):
        self.serializer = Ehgk_to_Bytes_Serializer()
    
    def test_uint64_to_bytes(self):
        one = ctypes.c_uint64(1)
        one_bytes = self.serializer.uint64_to_bytes(one)
        self.assertEqual(one_bytes, b'\x00\x00\x00\x00\x00\x00\x00\x01')

    def test_pages_to_bytes(self):
        one = ctypes.c_uint64(1)
        two = ctypes.c_uint64(2)
        page = [one, two]
        serialized_value = self.serializer.pages_to_bytes(page)
        
        self.assertEqual(serialized_value, b'\x00\x00\x00\x00\x00\x00\x00\x01\x00\x00\x00\x00\x00\x00\x00\x02')