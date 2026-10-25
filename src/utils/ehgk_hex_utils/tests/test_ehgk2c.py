import os
import tempfile
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


class Ehgk2CAppIntegrationTest(unittest.TestCase):

    def test_serialize_single_page(self):
        pages = [c_uint64(1)]
        app = Ehgk2CApp.__new__(Ehgk2CApp)
        result = app._serialize(pages)
        self.assertIn("L1", result)
        self.assertIn("PAGES_COUNT 1", result)
        self.assertIn("EMPTY", result)

    def test_serialize_multiple_pages(self):
        pages = [c_uint64(1), c_uint64(0), c_uint64(1 << 56)]
        app = Ehgk2CApp.__new__(Ehgk2CApp)
        result = app._serialize(pages)
        self.assertIn("PAGES_COUNT 3", result)
        self.assertIn("L1", result)
        self.assertIn("EMPTY", result)
        self.assertIn("L57", result)

    def test_run_full_pipeline(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            input_file = os.path.join(tmpdir, "input.pd")
            output_file = os.path.join(tmpdir, "output.h")

            with open(input_file, "w") as f:
                f.write("L1 | L2, EMPTY_PAGE, L57")

            app = Ehgk2CApp(input_file, output_file)
            app.run()

            self.assertTrue(os.path.exists(output_file))
            with open(output_file, "r") as f:
                content = f.read()
            self.assertIn("L1", content)
            self.assertIn("L2", content)
            self.assertIn("EMPTY", content)
            self.assertIn("L57", content)
            self.assertIn("PAGES_COUNT 3", content)


if __name__ == '__main__':
    unittest.main()
