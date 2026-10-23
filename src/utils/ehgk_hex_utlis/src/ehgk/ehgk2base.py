"""
Base classes for EHGK converter applications.
"""

from abc import ABC, abstractmethod
from ctypes import c_uint64
from typing import Any

from ehgk.parser import EghkPagesParser


class Ehgk2BaseApp:
    """
    Base class for EHGK converter applications.

    Attributes:
        INPUT_FILE_NOT_FOUND_ERROR (int): error code for an input file not found
        OUTPUT_FILE_IO_ERROR (int): error code for output file IO error
        UNKNOWN_ERROR (int): error code for general error
    """

    INPUT_FILE_NOT_FOUND_ERROR: int = 1
    OUTPUT_FILE_IO_ERROR: int = 2
    UNKNOWN_ERROR: int = 7

    def __init__(self, input_filename, output_filename: str):
        """
        Construct application object.

        Parameters:
            input_filename (str): input file name
            output_filename (str): output file name
        """
        self.input_filename = input_filename
        self.output_filename = output_filename

    def _read_input_file(self) -> str:
        """
        Reads input file content.

        Returns: input file content as string
        """
        try:
            with open(self.input_filename, 'r') as file:
                file_content_string = file.read()

            return file_content_string

        except FileNotFoundError:
            print(f"Error: The input file '{self.input_filename}' was not found.")
            exit(self.INPUT_FILE_NOT_FOUND_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(self.UNKNOWN_ERROR)

    def _write_to_output_file(self, content, mode: str) -> int:
        """
        Writes content to output file.

        Parameters:
            content: file content (str for 'w', bytes for 'wb')
            num_bytes: number of bytes written
            mode: file open mode ('w' or 'wb')

        Returns: number of bytes written
        """
        try:
            with open(self.output_filename, mode) as file:
                bytes_written = file.write(content)
            return bytes_written
        except IOError as e:
            print(f"Error writing to file {self.output_filename}: {e}")
            exit(self.OUTPUT_FILE_IO_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(self.UNKNOWN_ERROR)


class Ehgk2ConverterApp(Ehgk2BaseApp, ABC):
    """
    Abstract base for EHGK format converters.

    Implements template method pattern: run() = parse -> prepend count -> serialize -> write.
    Subclasses override _serialize() to provide format-specific logic.
    """

    def __init__(self, input_filename, output_filename: str):
        super().__init__(input_filename, output_filename)

    def run(self):
        """Template method: full conversion pipeline."""
        pages_description = self._read_input_file()
        (result, pages_count) = self._convert(pages_description)
        self._write_to_output_file(result, self._output_mode())
        print(f"Wrote {pages_count} pages to {self.output_filename}")

    def _convert(self, pages_description: str) -> tuple:
        """Parse, prepend page count, delegate serialization."""
        parser = EghkPagesParser()
        ctype_pages = parser.parse(pages_description)
        pages_count = len(ctype_pages)
        ctype_pages = [c_uint64(pages_count)] + ctype_pages
        return self._serialize(ctype_pages), pages_count

    def _convert_no_count(self, pages_description: str) -> tuple:
        """Parse without prepending page count (for C header output)."""
        parser = EghkPagesParser()
        ctype_pages = parser.parse(pages_description)
        return self._serialize(ctype_pages), len(ctype_pages)

    @abstractmethod
    def _serialize(self, pages: list[c_uint64]) -> Any:
        """Override in subclass to return format-specific output."""
        raise NotImplementedError  # pragma: no cover

    def _output_mode(self) -> str:
        """Override in subclass to return 'w' or 'wb'."""
        return "w"
