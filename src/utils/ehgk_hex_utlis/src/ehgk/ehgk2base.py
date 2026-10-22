"""
Base class for EHGK converter applications.
"""


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

    def __init__(self, input_filename):
        """
        Construct application object.

        Parameters:
            input_filename (str): input file name
        """
        self.input_filename = input_filename

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
