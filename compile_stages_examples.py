Import('env')

print("Compile stages examples")

SConscript('stages/SConscript', exports = ['env'])