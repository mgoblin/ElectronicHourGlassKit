"""Dispatcher application for EHGK format converters."""

from __future__ import annotations

import argparse
import os
import sys

from ehgk.ehgk2bin import Ehgk2BinApp
from ehgk.ehgk2c import Ehgk2CApp
from ehgk.ehgk2hex import Ehgk2HexApp


_FORMAT_EXT: dict[str, str] = {"ihex": ".hex", "bin": ".bin", "c": ".h"}

_FORMAT_CLASS: dict[str, type] = {
    "ihex": Ehgk2HexApp,
    "bin": Ehgk2BinApp,
    "c": Ehgk2CApp,
}


class App:
    """CLI application dispatcher.

    Parses arguments, selects the appropriate converter class by format,
    and runs the conversion pipeline.
    """

    def __init__(self, argv: list[str] | None = None) -> None:
        self.args = self._build_parser().parse_args(argv)

    @staticmethod
    def _build_parser() -> argparse.ArgumentParser:
        parser = argparse.ArgumentParser(
            prog="ehgk2any",
            description=(
                "Converts electronic hourglass kit (EHGK) pages description "
                "to Intel HEX / binary / C language representation"
            ),
        )
        parser.add_argument("input", help="EHGK pages description file")
        parser.add_argument(
            "-f",
            "--format",
            choices=tuple(_FORMAT_CLASS.keys()),
            default="bin",
            help="output format (default: %(default)s)",
        )
        parser.add_argument(
            "-o",
            "--output",
            default="-",
            help="output file, '-' for stdout (default: %(default)s)",
        )
        return parser

    def run(self) -> int:
        """Run the selected converter."""
        # Determine output file
        output_filename = self.args.output
        if output_filename == "-":
            base = os.path.splitext(self.args.input)[0]
            output_filename = base + _FORMAT_EXT[self.args.format]

        # Select and run converter
        converter_cls = _FORMAT_CLASS[self.args.format]
        app = converter_cls(self.args.input, output_filename)
        app.run()
        return 0


def main(argv: list[str] | None = None) -> int:
    return App(argv).run()


if __name__ == "__main__":
    sys.exit(main())
