from ctypes import c_uint64

from jinja2 import Environment, FileSystemLoader, StrictUndefined

from ehgk.ehgk2base import Ehgk2ConverterApp


class Ehgk2CApp(Ehgk2ConverterApp):
    """
    Ehgk2C Application class

    Converts EHGK pages description to C language header file
    Use files as input and output.
    """

    @staticmethod
    def _uint64_to_c_hex(val: c_uint64) -> str:
        """Format c_uint64 as a C language hexadecimal literal."""
        return f"0x{val.value:016X}ULL"

    def _serialize(self, pages: list[c_uint64]) -> str:
        """Render pages to C header via Jinja2 template."""
        values = []
        for page in pages:
            values.append(self._uint64_to_c_hex(page))

        env = Environment(
            loader=FileSystemLoader('templates'),
            undefined=StrictUndefined
        )
        template = env.get_template('ehgk_pages.j2')
        return template.render(pages=values, page_count=len(values))

    def run(self):
        """Reads input, converts pages to C header, writes output (no page count in data)."""
        pages_description = self._read_input_file()
        (pages, pages_count) = self._convert_no_count(pages_description)
        self._write_to_output_file(pages, "w")
        print(f"Wrote {pages_count} pages to {self.output_filename}")
