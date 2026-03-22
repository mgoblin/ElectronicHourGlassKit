import ctypes
from intelhex import IntelHex


class Ehgk_to_Bytes_Serializer:

    '''
    Serializer from Ehgk ctype.c_uint64 list (pages)
    to bytes
    '''
    
    def pages_to_bytes(self, pages: list[ctypes.c_uint64]) -> bytes:
        '''
        Converts list of ctypes.c_uint64 to bytes.

        Parameters:
            pages (list): list of ctypes.c_uint64 values

        Returns: flat bytes representation of pages list
        '''
        bytes_list = list(
            map(
                lambda x: x.value.to_bytes(8, byteorder='big'), pages
            )
        )
        return b''.join(bytes_list)
    
class Ehgk_to_Hex_Serializer:
    def pages_to_hex(self, pages: list[ctypes.c_uint64]) -> None:
        bytes_list = list(
            map(
                lambda x: x.value.to_bytes(8, byteorder='big'), pages
            )
        )

        b: bytes = b''.join(bytes_list)

        ih = IntelHex()
        ih.frombytes(b)
        ih.write_hex_file('out.hex')