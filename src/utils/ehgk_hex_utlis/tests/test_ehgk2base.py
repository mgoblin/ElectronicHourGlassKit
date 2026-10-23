import os
import tempfile
import unittest

from ctypes import c_uint64

from ehgk.ehgk2base import Ehgk2BaseApp, Ehgk2ConverterApp


class _TestApp(Ehgk2BaseApp):
    """Concrete subclass for testing Ehgk2BaseApp methods."""

    def __init__(self, input_filename, output_filename):
        super().__init__(input_filename, output_filename)


class _TestConverterApp(Ehgk2ConverterApp):
    """Concrete subclass for testing Ehgk2ConverterApp methods."""

    def __init__(self, input_filename, output_filename,
                 serialize_fn=None, output_mode="w"):
        super().__init__(input_filename, output_filename)
        self._serialize_fn = serialize_fn or (lambda pages: str(pages))
        self._output_mode_val = output_mode

    def _serialize(self, pages: list[c_uint64]) -> str | bytes:
        return self._serialize_fn(pages)

    def _output_mode(self) -> str:
        return self._output_mode_val


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


class Ehgk2ConverterAppTest(unittest.TestCase):
    """Tests for Ehgk2ConverterApp template method and helpers."""

    def setUp(self):
        self.tmpdir = tempfile.TemporaryDirectory()
        self.input_file = os.path.join(self.tmpdir.name, "input.ehgk")
        self.output_file = os.path.join(self.tmpdir.name, "output.txt")
        # Default serialize_fn returns bytes for easy inspection
        self.app = _TestConverterApp(
            self.input_file, self.output_file,
            serialize_fn=lambda pages: b''.join(
                p.value.to_bytes(8, byteorder='little') for p in pages
            )
        )

    def tearDown(self):
        self.tmpdir.cleanup()

    # --- _convert ---

    def test_convert_single_page(self):
        result, count = self.app._convert("L1")
        self.assertEqual(count, 1)
        # First 8 bytes = page count (1) in little-endian
        self.assertEqual(int.from_bytes(result[:8], 'little'), 1)
        # Next 8 bytes = L1 value (bit 0 = 1) in little-endian
        self.assertEqual(int.from_bytes(result[8:16], 'little'), 1)

    def test_convert_multiple_pages(self):
        result, count = self.app._convert("L1, L2")
        self.assertEqual(count, 2)
        # First 8 bytes = page count (2)
        self.assertEqual(int.from_bytes(result[:8], 'little'), 2)
        # L1 = bit 0 = 1, L2 = bit 1 = 2
        self.assertEqual(int.from_bytes(result[8:16], 'little'), 1)
        self.assertEqual(int.from_bytes(result[16:24], 'little'), 2)

    def test_convert_empty_page(self):
        result, count = self.app._convert("EMPTY_PAGE")
        self.assertEqual(count, 1)
        # First 8 bytes = page count (1)
        self.assertEqual(int.from_bytes(result[:8], 'little'), 1)
        # EMPTY_PAGE -> 0
        self.assertEqual(int.from_bytes(result[8:16], 'little'), 0)

    def test_convert_with_count_prepend(self):
        """Verify that page count is prepended as first uint64."""
        result, count = self.app._convert("L1, L2, L3")
        self.assertEqual(count, 3)
        # First 8 bytes = page count (3) in little-endian
        self.assertEqual(int.from_bytes(result[:8], 'little'), 3)

    # --- _convert_no_count ---

    def test_convert_no_count_excludes_page_count(self):
        """Verify that page count is NOT prepended."""
        result, count = self.app._convert_no_count("L1")
        self.assertEqual(count, 1)
        # First 8 bytes = L1 value (1), NOT page count
        self.assertEqual(int.from_bytes(result[:8], 'little'), 1)

    def test_convert_no_count_multiple_pages(self):
        result, count = self.app._convert_no_count("L1, L5")
        self.assertEqual(count, 2)
        # First page should be L1 value (1), not count
        self.assertEqual(int.from_bytes(result[:8], 'little'), 1)
        # Second page = L5 = bit 4 = 16
        self.assertEqual(int.from_bytes(result[8:16], 'little'), 16)

    # --- run() ---

    def test_run_full_pipeline(self):
        """End-to-end: read file -> parse -> serialize -> write."""
        with open(self.input_file, 'w') as f:
            f.write("L1, EMPTY_PAGE, L57")

        app = _TestConverterApp(
            self.input_file, self.output_file,
            serialize_fn=lambda pages: b''.join(
                p.value.to_bytes(8, byteorder='little') for p in pages
            ),
            output_mode="wb"
        )
        app.run()

        self.assertTrue(os.path.exists(self.output_file))
        with open(self.output_file, 'rb') as f:
            data = f.read()
        # First 8 bytes = page count (3)
        self.assertEqual(int.from_bytes(data[:8], 'little'), 3)
        # L1 = 1
        self.assertEqual(int.from_bytes(data[8:16], 'little'), 1)
        # EMPTY_PAGE = 0
        self.assertEqual(int.from_bytes(data[16:24], 'little'), 0)
        # L57 = bit 56 = 1 << 56
        self.assertEqual(int.from_bytes(data[24:32], 'little'), 1 << 56)

    def test_run_single_page(self):
        with open(self.input_file, 'w') as f:
            f.write("L10")

        app = _TestConverterApp(
            self.input_file, self.output_file,
            serialize_fn=lambda pages: b''.join(
                p.value.to_bytes(8, byteorder='little') for p in pages
            ),
            output_mode="wb"
        )
        app.run()

        self.assertTrue(os.path.exists(self.output_file))
        with open(self.output_file, 'rb') as f:
            data = f.read()
        # First 8 bytes = page count (1)
        self.assertEqual(int.from_bytes(data[:8], 'little'), 1)
        # L10 = bit 9 = 512
        self.assertEqual(int.from_bytes(data[8:16], 'little'), 512)

    # --- _output_mode ---

    def test_output_mode_default(self):
        self.assertEqual(self.app._output_mode(), "w")

    def test_output_mode_binary(self):
        app = _TestConverterApp(
            self.input_file, self.output_file,
            output_mode="wb"
        )
        self.assertEqual(app._output_mode(), "wb")

    def test_run_writes_binary_mode(self):
        """Verify that _output_mode='wb' actually writes binary."""
        with open(self.input_file, 'w') as f:
            f.write("L1")

        app = _TestConverterApp(
            self.input_file, self.output_file,
            serialize_fn=lambda pages: b'\x01\x02\x03\x04',
            output_mode="wb"
        )
        app.run()

        with open(self.output_file, 'rb') as f:
            self.assertEqual(f.read(), b'\x01\x02\x03\x04')


if __name__ == '__main__':
    unittest.main()
