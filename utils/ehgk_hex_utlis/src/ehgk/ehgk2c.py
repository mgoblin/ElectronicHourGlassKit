import argparse
import os

__version__ = "0.0.1"

class Ehgk2CApp:
    def run(self):
        pass

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

    app = Ehgk2CApp()
    app.run()    
