import os
from SCons.Script import DefaultEnvironment

from os.path import expanduser
home = expanduser("~")

build_cpu = 'mcs51'
board_f_cpu = '11059200L'
size_iram = '256'
size_heap = '64'
size_xram = '0'
size_code = '4096'
board_model = 'STC15W204S'

path = f'{home}/.platformio/packages/toolchain-sdcc/bin'
os.environ["PATH"] += os.pathsep + path
env = DefaultEnvironment(ENV = os.environ)

env.Append(
    ASFLAGS=["-l", "-s"],
    CFLAGS=["--std-sdcc11"],
    CCFLAGS=[
        "--opt-code-size",  # optimize for size
        "--peep-return",  # peephole optimization for return instructions
        "-m%s" % build_cpu,
        "--Werror", 

    ],
    CPPDEFINES=["F_CPU=" + board_f_cpu, "HEAP_SIZE=" + size_heap],
    LINKFLAGS=[
        "-m%s" % build_cpu,
        "--iram-size",
        size_iram,
        "--xram-size",
        size_xram,
        "--code-size",
        size_code,
        "--out-fmt-ihx",
    ],
)

pioenv = board_model
env['PIOENV'] = pioenv

SConscript (
    'stages/SConscript', 
    exports = 'env'
)

# Build tests
SConscript (
    'SConscriptTests_gcc' 
)

SConscript (
    'SConscriptTests_clang' 
)