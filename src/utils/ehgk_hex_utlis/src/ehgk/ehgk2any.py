import argparse
import os
import sys


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="ehgk2any",
        description=(
            "Converts electronic hourglass kit (EHGK) pages description "
            "to Intel HEX / binary / C language representation"
        ),
    )
    parser.add_argument("input", help="EHGK pages description file")
    parser.add_argument(
        "-f", "--format", choices=("ihex", "bin", "c"), default="bin",
        help="output format (default: %(default)s)",
    )
    parser.add_argument(
        "-o", "--output", default="-",
        help="output file, '-' for stdout (default: %(default)s)",
    )
    return parser


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    argv = sys.argv[1:] if argv is None else argv

    if not argv:
        parser.print_help()
        return 0

    args = parser.parse_args(argv)

    # Determine default output file based on input and format
    if args.output == "-":
        ext = {"ihex": ".hex", "bin": ".bin", "c": ".h"}
        base = os.path.splitext(args.input)[0]
        args.output = base + ext[args.format]

    # ... convert ...
    return 0


if __name__ == "__main__":
    sys.exit(main())