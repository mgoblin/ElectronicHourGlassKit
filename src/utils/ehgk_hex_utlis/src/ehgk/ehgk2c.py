from ctypes import c_uint64

from jinja2 import Environment, FileSystemLoader

from ehgk.ehgk2base import Ehgk2BaseApp
from ehgk.parser import EghkPagesParser


class Ehgk2CApp(Ehgk2BaseApp):
    '''
    Ehgk2C Application class

    Converts EHGK pages description to c language header file
    Use files as input and output.
    '''

    def __init__(self, input_filename, output_filename):
        '''
        Construct application object.
        Method run() starts the job.

        Parameters:
            input_filename (str): input file name
            output_filename (str): output file name
        '''
        super().__init__(input_filename)
        self.output_filename = output_filename

    def _convert_pages_to_list(self, pages_description) -> list[c_uint64]:
        '''
        Converts text pages description to binary representation

        Parameters:
            pages_description (str): pages description

        Returns: c_uint64 list  
        '''
        # Create parser and serializer objects
        parser = EghkPagesParser()

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

        # generate header file
        ehgk_pages_c = self._render_template_from_file(
            'templates', 
            'ehgk_pages.j2', 
            {'pages': pages, 'pages_count': len(pages)})
        self._write_to_output_file(ehgk_pages_c)
        
        print(f"Wrote {len(pages)} pages to {self.output_filename}")
