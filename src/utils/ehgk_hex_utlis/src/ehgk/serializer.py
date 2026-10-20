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
    def pages_to_hex(pages: list[ctypes.c_uint64]) -> str:
        bytes_list = list(
            map(
                lambda x: x.value.to_bytes(8, byteorder='little'), pages
            )
        )

        b: bytes = b''.join(bytes_list)

        ih = IntelHex()
        ih.frombytes(b)

        buf = StringIO()
        ih.write_hex_file(buf)
        return buf.getvalue()