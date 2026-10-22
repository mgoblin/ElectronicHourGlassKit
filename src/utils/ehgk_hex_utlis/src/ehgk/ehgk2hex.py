from ctypes import c_uint64

from ehgk.parser import EghkPagesParser
from ehgk.serializer import EhgkToHexSerializer

class Ehgk2HexApp:

    """
    Ehgk2Hex Application class

    Converts EHGK pages description to Intel Hex representation
    Use files as input and output.

    Attributes:
        INPUT_FILE_NOT_FOUND_ERROR (int): error code for input file not found
        OUTPUT_FILE_IO_ERROR (int): error code for output file IO error
        UNKNOWN_ERROR (int): error code for general error
    """

    INPUT_FILE_NOT_FOUND_ERROR: int = 1
    OUTPUT_FILE_IO_ERROR: int = 2
    UNKNOWN_ERROR: int = 7

    def __init__(self, input_filename, output_filename):
        """
        Construct application object.
        Method run() starts the job.

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
    
            # You can now use the file_content_string variable
            return file_content_string

        except FileNotFoundError:
            print(f"Error: The input file '{self.input_filename}' was not found.")
            exit(Ehgk2HexApp.INPUT_FILE_NOT_FOUND_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2HexApp.UNKNOWN_ERROR)

    def _convert_pages_to_intel_hex(self, pages_description) -> tuple[str, int]:
        """
        Converts text pages description to intel hex representation

        Parameters:
            pages_description (str): pages description

        Returns: tuple (string with Intel Hex representation, pages count)
        """
        # Create parser and serializer objects
        ehgk_parser = EghkPagesParser()
        serializer = EhgkToHexSerializer()

        # Parse pages description and convert to bytes
        ctype_pages = ehgk_parser.parse(pages_description)
        pages_count = len(ctype_pages)

        ctype_pages = [c_uint64(pages_count)] + ctype_pages
        return serializer.pages_to_intel_hex(ctype_pages), pages_count


    def run(self):
        """
        Reads the input file, converts pages to Intel Hex, writes to output file.
        """
        print(f"\n\nNow starts the job with {self.input_filename} as input file and {self.output_filename} as output file")

        pages_description = self._read_input_file()
        (pages, pages_count) = self._convert_pages_to_intel_hex(pages_description)

        with open(self.output_filename, 'w') as f:
            f.write(pages)
        print(f"Wrote {pages_count} pages to {self.output_filename}")
