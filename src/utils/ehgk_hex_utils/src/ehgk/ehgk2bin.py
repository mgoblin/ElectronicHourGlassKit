from ctypes import c_uint64

from ehgk.ehgk2base import Ehgk2ConverterApp
from ehgk.serializer import EhgkToBytesSerializer


class Ehgk2BinApp(Ehgk2ConverterApp):
    """
    Ehgk2Bin Application class

    Converts EHGK pages description to binary representation
    Use files as input and output.
    """

    def _serialize(self, pages: list[c_uint64]) -> bytes:
        """Serialize pages to binary representation."""
        return EhgkToBytesSerializer.pages_to_bytes(pages)

    def _output_mode(self) -> str:
        return "wb"
