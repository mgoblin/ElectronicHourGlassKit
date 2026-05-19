Import('env')

print("Compile stages examples")

SConscript('src/stages/SConscript', exports = ['env'])