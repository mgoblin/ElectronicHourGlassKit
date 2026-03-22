import argparse

from ehgk.parser import Eghk_Pages_Parser
from ehgk.serializer import Ehgk_to_Bytes_Serializer

from intelhex import IntelHex

class Ehgk2HexApp:

    '''
    Ehgk2Hex Application class

    Converts EHGK pages description to Intel Hex representation
    Use files as input and output.

    Attributes:
        INPUT_FILE_NOT_FOUND_ERROR (int): error code for input file not found
        OUTPUT_FILE_IO_ERROR (int): error code for output file IO error
        UNKNOWN_ERROR (int): error code for general error
    '''

    INPUT_FILE_NOT_FOUND_ERROR: int = 1
    OUTPUT_FILE_IO_ERROR: int = 2
    UNKNOWN_ERROR: int = 7

    def __init__(self, input_filename, output_filename):
        '''
        Costruct application object.
        Method run() starts the job.

        Parameters:
            input_filename (str): input file name
            output_filename (str): output file name
        '''
        self.input_filename = input_filename
        self.output_filename = output_filename

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
            exit(Ehgk2HexApp.INPUT_FILE_NOT_FOUND_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2HexApp.UNKNOWN_ERROR)

    def _convert_pages_to_binary(self, pages_description) -> bytes:
        '''
        Converts text pages description to binary representation

        Parameters:
            pages_description (str): pages description

        Returns: binary representation of pages description
        '''
        # Create parser and serializer objects
        parser = Eghk_Pages_Parser()
        serializer = Ehgk_to_Bytes_Serializer()

        # Parse pages description and convert to bytes
        ctype_pages = parser.parse(pages_description)
        return serializer.pages_to_bytes(ctype_pages)


    def run(self):
        '''
        Reads the input file, converts pages to binary, writes to output file.
        '''
        print(f"\n\nNow starts the job with {self.input_filename} as input file and {self.output_filename} as output file")

        pages_description = self._read_input_file()
        pages_bin = self._convert_pages_to_binary(pages_description)

        ih = IntelHex()
        ih.frombytes(pages_bin)

        ih.write_hex_file(self.output_filename)
        ih.get_memory_size()
        print(f"Wrote {len(pages_bin)} bytes to {self.output_filename}")



if __name__ == '__main__':
    # Create the command line args parser
    parser = argparse.ArgumentParser(
        description="Converts EHGK pages description to Intel HEX representation"
    )

    # Add input argument
    parser.add_argument(
        "-i", "--input", 
        default="input.pd", 
        help="ehgk pages description file name (default: input.pd)",
        required=False
    )

    # Add output argument
    parser.add_argument(
        "-o", "--output", 
        default="output.bin", 
        help="binary file name (default: output.bin)",
        required=False
    )

    # Parse the arguments
    args = parser.parse_args()
    
    if args.input == parser.get_default("input") and args.output == parser.get_default("output"):
        parser.print_help()

    app = Ehgk2HexApp(args.input, args.output)
    app.run()        

