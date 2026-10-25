from ctypes import c_uint64

from ehgk.ehgk2base import Ehgk2ConverterApp
from ehgk.serializer import EhgkToHexSerializer


class Ehgk2HexApp(Ehgk2ConverterApp):

    """
    Ehgk2Hex Application class

    Converts EHGK pages description to Intel Hex representation
    Use files as input and output.
    """

    def _serialize(self, pages: list[c_uint64]) -> str:
        """Serialize pages to Intel HEX format string."""
        return EhgkToHexSerializer.pages_to_intel_hex(pages)
