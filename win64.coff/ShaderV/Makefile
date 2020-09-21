# set environment
fasmg = fasmg.exe

.SUFFIXES :
.SUFFIXES : .exe .obj .g

.obj.exe :
	link $**

.g.obj	:
	$(fasmg) -n -v 1 -e 2 $< $@

ShaderV64.exe	: ShaderV64.obj
