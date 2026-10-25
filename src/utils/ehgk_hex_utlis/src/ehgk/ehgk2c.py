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
    def _uint64_to_ehgk(val: c_uint64) -> str:
        """Format c_uint64 as EHGK literals."""
        if val.value == 0:
            return "EMPTY"
        value = ''
        for i in range(1, 58):
            mask = 1 << (i - 1)
            if (val.value & mask) > 0:
                value = value + f" | L{i}"
        return value[3:]

    def _serialize(self, pages: list[c_uint64]) -> str:
        """Render pages to C header via Jinja2 template."""
        values = []
        for page in pages:
            values.append(self._uint64_to_ehgk(page))

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
