from ctypes import c_uint64

from ehgk.ehgk2base import Ehgk2BaseApp
from ehgk.parser import EghkPagesParser
from ehgk.serializer import EhgkToBytesSerializer


class Ehgk2BinApp(Ehgk2BaseApp):
    """
    Ehgk2Bin Application class

    Converts EHGK pages description to binary representation
    Use files as input and output.
    """

    def __init__(self, input_filename, output_filename):
        """
        Construct application object.
        Method run() starts the job.

        Parameters:
            input_filename (str): input file name
            output_filename (str): output file name
        """
        super().__init__(input_filename)
        self.output_filename = output_filename

    def _convert_pages_to_binary(self, pages_description) -> tuple[bytes, int]:
        """
        Converts text pages description to binary representation

        Parameters:
            pages_description (str): pages description

        Returns: tuple with binary representation of pages description
            and page count as tuple[bytes, int]
        """
        # Create parser and serializer objects
        parser = EghkPagesParser()
        serializer = EhgkToBytesSerializer()

        # Parse pages description and convert to bytes
        ctype_pages = parser.parse(pages_description)
        pages_count = len(ctype_pages)

        ctype_pages = [c_uint64(pages_count)] + ctype_pages
        return serializer.pages_to_bytes(ctype_pages), pages_count

    def _write_bin_to_output_file(self, pages_bin: bytes):
        """
        Writes bytes to an output file. Returns the number of bytes written

        Parameters:
            pages_bin (bytes): bytes to write to an output file

        Returns: number of bytes written to an output file
        """
        try:
            with open(self.output_filename, "wb") as binary_file:
                bytes_written = binary_file.write(pages_bin)
            return bytes_written
        except IOError as e:
            print(f"Error writing to file {self.output_filename}: {e}")
            exit(Ehgk2BinApp.OUTPUT_FILE_IO_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2BinApp.UNKNOWN_ERROR)   

    def run(self):
        """
        Reads the input file, converts pages to binary, writes to an output file.
        """
        print(f"\n\nNow starts the job with {self.input_filename} as input file and {self.output_filename} as output file")

        pages_description = self._read_input_file()
        (pages_bin, pages_count) = self._convert_pages_to_binary(pages_description)
        self._write_bin_to_output_file(pages_bin)
        print(f"Wrote {pages_count} pages to {self.output_filename}")
