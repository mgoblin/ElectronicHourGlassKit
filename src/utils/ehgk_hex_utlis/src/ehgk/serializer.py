import ctypes
from io import StringIO

from intelhex import IntelHex


class EhgkToBytesSerializer:

    """
    Serializer from ehgk ctype.c_uint64 list (pages)
    to bytes
    """
    
    @staticmethod
    def pages_to_bytes(pages: list[ctypes.c_uint64]) -> bytes:
        """
        Converts list of ctypes.c_uint64 to bytes.

        Parameters:
            pages (list): list of ctypes.c_uint64 values

        Returns: flat bytes representation of pages list
        """
        bytes_list = list(
            map(
                lambda x: x.value.to_bytes(8, byteorder='little'), pages
            )
        )
        return b''.join(bytes_list)
    
class EhgkToHexSerializer:
    @staticmethod
    def pages_to_intel_hex(pages: list[ctypes.c_uint64]) -> str:
        """
        Converts list of ctypes.c_uint64 to Intel HEX format string.

        Parameters:
            pages (list): list of ctypes.c_uint64 values

        Returns: Intel HEX format string
        """
        b: bytes = EhgkToBytesSerializer.pages_to_bytes(pages)

        ih = IntelHex()
        ih.frombytes(b)

        buf = StringIO()
        ih.write_hex_file(buf)
        return buf.getvalue()