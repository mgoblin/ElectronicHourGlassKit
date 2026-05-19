import argparse
from ctypes import c_uint64
import os

from ehgk.parser import Eghk_Pages_Parser
from ehgk.serializer import Ehgk_to_Bytes_Serializer

__version__ = "0.0.1"

class Ehgk2BinApp:
    '''
    Ehgk2Bin Application class

    Converts EHGK pages description to binary representation
    Use files as input and output.

    Attributes:
        INPUT_FILE_NOT_FOUND_ERROR (int): error code for input file not found
        OUTPUT_FILE_IO_ERROR (int): error code for output file IO error
        UNKNOWN_ERROR (int): error code for general error
    '''

    INPUT_FILE_NOT_FOUND_ERROR: int = 1
    OUTPUT_FILE_IO_ERROR: int = 2
    UNKNOWN_ERROR: int = 7

    def __init__(self, input_filename, output_filename, save_header):
        '''
        Costruct application object.
        Method run() starts the job.

        Parameters:
            input_filename (str): input file name
            output_filename (str): output file name
            save_header (bool): save pages count to output
        '''
        self.input_filename = input_filename
        self.output_filename = output_filename
        self.save_header = save_header

    def _read_input_file(self) -> str:
        '''
        Reads input file content.

        Returns: input file content as string
        '''
        try:
            with open(self.input_filename, 'r') as file:
                file_content_string = file.read()
    
            # You can now use the file_content_string variable
            return file_content_string

        except FileNotFoundError:
            print(f"Error: The input file '{self.input_filename}' was not found.")
            exit(Ehgk2BinApp.INPUT_FILE_NOT_FOUND_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2BinApp.UNKNOWN_ERROR)

    def _convert_pages_to_binary(self, pages_description) -> tuple[bytes, int]:
        '''
        Converts text pages description to binary representation

        Parameters:
            pages_description (str): pages description

        Returns: tuple with binary representation of pages description 
            and pages count as tuple[bytes, int] 
        '''
        # Create parser and serializer objects
        parser = Eghk_Pages_Parser()
        serializer = Ehgk_to_Bytes_Serializer()

        # Parse pages description and convert to bytes
        ctype_pages = parser.parse(pages_description)
        pages_count = len(ctype_pages)
        
        # Prepend pages count to pages list
        if self.save_header:
            ctype_pages = [c_uint64(pages_count)] + ctype_pages

        return (serializer.pages_to_bytes(ctype_pages), pages_count)

    def _write_bin_to_output_file(self, pages_bin: bytes):
        '''
        Writes bytes to output file. Returns number of bytes written

        Parameters:
            pages_bin (bytes): bytes to write to output file

        Returns: number of bytes written to output file       
        '''
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
        '''
        Reads the input file, converts pages to binary, writes to output file.
        '''
        print(f"\n\nNow starts the job with {self.input_filename} as input file and {self.output_filename} as output file")

        pages_description = self._read_input_file()
        (pages_bin, pages_count) = self._convert_pages_to_binary(pages_description)
        self._write_bin_to_output_file(pages_bin)
        print(f"Wrote {pages_count} pages to {self.output_filename}")


if __name__ == '__main__':
    # Create the command line args parser
    parser = argparse.ArgumentParser(
        description="Converts EHGK pages description to binary representation"
    )

    # Add version argument
    parser.add_argument(
        '-v',
        '--version',
        action='version',
        version=f'%(prog)s {__version__}',
        help="show the program's version number and exit."
    )
    
    # Add output argument
    parser.add_argument(
        "-o", "--output", 
        default=None, 
        help="binary file name (default: {input file name}.bin)"
    )

    # Add input argument
    parser.add_argument(
        "input", 
        help="ehgk pages description file name",
    )

    # Add a disable write header boolean flag
    parser.add_argument(
        '-nc', '--no-pages-count',
        action='store_true',
        dest = 'no_pages_count',
        help='dont save pages count to output (default: False)'
    )


    # Parse the arguments
    args = parser.parse_args()
    
    if args.output is None:
        root, extention = os.path.splitext(args.input)
        args.output = root + ".bin"
    
    app = Ehgk2BinApp(args.input, args.output, not args.no_pages_count)
    app.run()    