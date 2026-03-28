import argparse
from ctypes import c_uint64
import os

from jinja2 import Environment, FileSystemLoader

from ehgk.parser import Eghk_Pages_Parser
from ehgk.serializer import Ehgk_to_Bytes_Serializer

__version__ = "0.0.1"

class Ehgk2CApp:
    '''
    Ehgk2C Application class

    Converts EHGK pages description to c language header file
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
            exit(Ehgk2CApp.INPUT_FILE_NOT_FOUND_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2CApp.UNKNOWN_ERROR)

    def _convert_pages_to_list(self, pages_description) -> list[c_uint64]:
        '''
        Converts text pages description to binary representation

        Parameters:
            pages_description (str): pages description

        Returns: c_uint64 list  
        '''
        # Create parser and serializer objects
        parser = Eghk_Pages_Parser()

        # Parse pages description and convert to bytes
        ctype_pages = parser.parse(pages_description)
        
        return ctype_pages

    def _render_template_from_file(self, template_dir, template_file, context):
        # Set up the Jinja2 environment with a file system loader
        env = Environment(loader=FileSystemLoader(template_dir))
        
        # Load the template file
        template = env.get_template(template_file)
        
        # Render the template with the provided context data
        output = template.render(context)
        return output
    
    def _write_to_output_file(self, pages_str: str):
        '''
        Writes string to output file. Returns number of bytes written

        Parameters:
            pages_str (str): string to write to output file

        Returns: number of bytes written to output file       
        '''
        try:
            with open(self.output_filename, "w") as file:
                bytes_written = file.write(pages_str)
            return bytes_written
        except IOError as e:
            print(f"Error writing to file {self.output_filename}: {e}")
            exit(Ehgk2CApp.OUTPUT_FILE_IO_ERROR)
        except Exception as e:
            print(f"An error occurred: {e}")
            exit(Ehgk2CApp.UNKNOWN_ERROR)   


    def run(self):
        '''
        Reads the input file, converts pages to c language header file, writes to output file.
        '''
        
        print(f"\n\nNow starts the job with {self.input_filename} as input file and {self.output_filename} as output file")
        pages_description = self._read_input_file()

        pages = self._convert_pages_to_list(pages_description)

        # TODO generate header file
        ehgk_pages_c = self._render_template_from_file(
            'templates', 
            'ehgk_pages.j2', 
            {'pages': pages, 'pages_count': len(pages), 'generate_pages_count_def': self.save_header})
        self._write_to_output_file(ehgk_pages_c)
        
        print(f"Wrote {len(pages)} pages to {self.output_filename}")

if __name__ == '__main__':

    # Create the command line args parser
    parser = argparse.ArgumentParser(
        description="Converts EHGK pages description to c language array definition"
    )

    # Add version argument
    parser.add_argument(
        '-v',
        '--version',
        action='version',
        version=f'%(prog)s {__version__}',
        help="show the program's version number and exit."
    )

    # Add input argument
    parser.add_argument(
        "input", 
        help="ehgk pages description file name",
    )

    # Add output argument
    parser.add_argument(
        "-o", "--output", 
        default=None, 
        help="binary file name (default: {input file name}.h)"
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
        args.output = root + ".h"

    app = Ehgk2CApp(args.input, args.output, not args.no_pages_count)
    app.run()    
