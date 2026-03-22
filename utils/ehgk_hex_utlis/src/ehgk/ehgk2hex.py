import argparse

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

