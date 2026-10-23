import os
import tempfile
import unittest

from ehgk.ehgk2base import Ehgk2BaseApp


class _TestApp(Ehgk2BaseApp):
    """Concrete subclass for testing Ehgk2BaseApp methods."""

    def __init__(self, input_filename, output_filename):
        super().__init__(input_filename, output_filename)


class ReadInputFileTest(unittest.TestCase):

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.input_file = os.path.join(self.tmpdir.name, "input.txt")
        self.app = _TestApp(self.input_file, os.path.join(self.tmpdir.name, "out.txt"))

    def tearDown(self):
        self.tmpdir.cleanup()

    def test_read_existing_file(self):
        with open(self.input_file, 'w') as f:
            f.write("test content\n")

        result = self.app._read_input_file()
        self.assertEqual(result, "test content\n")

    def test_read_empty_file(self):
        with open(self.input_file, 'w') as f:
            f.write("")

        result = self.app._read_input_file()
        self.assertEqual(result, "")

    def test_read_missing_file(self):
        with self.assertRaises(SystemExit) as cm:
            self.app._read_input_file()
        self.assertEqual(cm.exception.code, Ehgk2BaseApp.INPUT_FILE_NOT_FOUND_ERROR)


class WriteToOutputFileTest(unittest.TestCase):

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.input_file = os.path.join(self.tmpdir.name, "input.txt")
        self.output_file = os.path.join(self.tmpdir.name, "output.txt")
        self.app = _TestApp(self.input_file, self.output_file)

    def tearDown(self):
        self.tmpdir.cleanup()

    def test_write_string(self):
        content = "hello world"
        written = self.app._write_to_output_file(content, "w")
        self.assertEqual(written, len(content))

        with open(self.output_file, 'r') as f:
            self.assertEqual(f.read(), content)

    def test_write_bytes(self):
        content = b"\x00\x01\x02\x03"
        written = self.app._write_to_output_file(content, "wb")
        self.assertEqual(written, len(content))

        with open(self.output_file, 'rb') as f:
            self.assertEqual(f.read(), content)

    def test_write_empty_string(self):
        content = ""
        written = self.app._write_to_output_file(content, "w")
        self.assertEqual(written, 0)

        with open(self.output_file, 'r') as f:
            self.assertEqual(f.read(), "")

    def test_write_empty_bytes(self):
        content = b""
        written = self.app._write_to_output_file(content, "wb")
        self.assertEqual(written, 0)

        with open(self.output_file, 'rb') as f:
            self.assertEqual(f.read(), b"")


if __name__ == "__main__":
    unittest.main()
