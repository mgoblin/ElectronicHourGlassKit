import unittest

from ctypes import c_uint64

from ehgk.ehgk2c import Ehgk2CApp


class Ehgk2CAppTest(unittest.TestCase):

    def test_uint64_to_ehgk_zero(self):
        val = c_uint64(0)
        self.assertEqual(Ehgk2CApp._uint64_to_ehgk(val), "EMPTY")

    def test_uint64_to_ehgk_single_led(self):
        val = c_uint64(1)
        self.assertEqual(Ehgk2CApp._uint64_to_ehgk(val), "L1")

    def test_uint64_to_ehgk_two_leds(self):
        val = c_uint64(1 | (1 << 4))
        self.assertEqual(Ehgk2CApp._uint64_to_ehgk(val), "L1 | L5")

    def test_uint64_to_ehgk_l57(self):
        val = c_uint64(1 << 56)
        self.assertEqual(Ehgk2CApp._uint64_to_ehgk(val), "L57")

    def test_uint64_to_ehgk_all_leds(self):
        val = c_uint64((1 << 57) - 1)
        expected = " | ".join(f"L{i}" for i in range(1, 58))
        self.assertEqual(Ehgk2CApp._uint64_to_ehgk(val), expected)

    def test_uint64_to_ehgk_returns_string(self):
        val = c_uint64(42)
        result = Ehgk2CApp._uint64_to_ehgk(val)
        self.assertIsInstance(result, str)


if __name__ == '__main__':
    unittest.main()
