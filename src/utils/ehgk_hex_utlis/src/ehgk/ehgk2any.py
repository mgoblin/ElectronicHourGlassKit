import argparse
import sys

from ehgk.ehgk2app import App


def build_parser() -> argparse.ArgumentParser:
    return App.build_parser()


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    argv = sys.argv[1:] if argv is None else argv
    if not argv:
        parser.print_help()
        return 0
    return App(argv).run()


if __name__ == "__main__":
    sys.exit(main())
