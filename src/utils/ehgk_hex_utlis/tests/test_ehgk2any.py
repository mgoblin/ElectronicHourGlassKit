import unittest
from unittest.mock import patch

from ehgk.ehgk2any import build_parser, main


class BuildParserTest(unittest.TestCase):

    def test_parser_returns_argument_parser(self):
        parser = build_parser()
        self.assertEqual(parser.prog, "ehgk2any")

    def test_parser_has_input_argument(self):
        parser = build_parser()
        actions = {a.dest: a for a in parser._actions}
        self.assertIn("input", actions)
        self.assertIn("EHGK pages description file", actions["input"].help)

    def test_parser_has_format_argument(self):
        parser = build_parser()
        actions = {a.dest: a for a in parser._actions}
        self.assertIn("format", actions)
        self.assertEqual(actions["format"].choices, ("ihex", "bin", "c"))

    def test_parser_has_output_argument(self):
        parser = build_parser()
        actions = {a.dest: a for a in parser._actions}
        self.assertIn("output", actions)
        self.assertEqual(actions["output"].default, "-")


class MainTest(unittest.TestCase):

    def test_main_no_args_prints_help(self):
        result = main([])
        self.assertEqual(result, 0)

    def test_main_ihex_format_accepted(self):
        with patch("sys.argv", ["ehgk2any", "input.pd", "-f", "ihex"]):
            result = main(["input.pd", "-f", "ihex"])
            self.assertEqual(result, 0)

    def test_main_bin_format_accepted(self):
        result = main(["input.pd", "-f", "bin"])
        self.assertEqual(result, 0)

    def test_main_c_format_accepted(self):
        result = main(["input.pd", "-f", "c"])
        self.assertEqual(result, 0)

    def test_main_invalid_format_rejected(self):
        with self.assertRaises(SystemExit):
            main(["input.pd", "-f", "invalid"])

    def test_main_output_default_is_stdout(self):
        with patch("sys.argv", ["ehgk2any", "input.pd", "-f", "ihex"]):
            result = main(["input.pd", "-f", "ihex"])
            self.assertEqual(result, 0)


if __name__ == "__main__":
    unittest.main()
