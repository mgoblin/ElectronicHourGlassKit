# Electronical hourglass kit to Intel HEX/binary formats converter

## Usage

1. Install dependencies: `pip install -r requirements.txt`
2. Run the converter: `python src/ehgk/ehgk2any.py`
3. Build dist: `hatch build`
4. Build binaries: `pyinstaller --onefile src/ehgk/ehgk2any.py`

# TODO Support led names (L1...L57) on ehgk2c converter export
