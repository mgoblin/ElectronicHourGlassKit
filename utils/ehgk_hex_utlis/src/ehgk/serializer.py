import ctypes

class Ehgk_to_Bytes_Serializer:

    '''
    Serializer from Ehgk ctype.c_uint64 list (pages)
    to bytes
    '''
    
    def uint64_to_bytes(self, x: ctypes.c_uint64) -> bytes:
        '''
        Converts ctypes.c_uint64 to bytes.
        Lowest byte first. Big endian.

        Parameters:
            x (ctypes.c_uint64): ctypes.c_uint64 value

        Returns: flat bytes representation ctypes.c_uint64 value
        '''
        return x.value.to_bytes(8, byteorder='big')

    def pages_to_bytes(self, pages):
        '''
        Converts list of ctypes.c_uint64 to bytes.

        Parameters:
            pages (list): list of ctypes.c_uint64 values

        Returns: flat bytes representation of pages list
        '''
        bytes_list = list(map(self.uint64_to_bytes, pages))
        return b''.join(bytes_list)
