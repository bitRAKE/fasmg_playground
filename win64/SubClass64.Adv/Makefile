# set environment
fasmg = fasmg.exe

# store temporary files out of the way
ODIR = $(MAKEDIR)\obj

.SUFFIXES :
.SUFFIXES : .exe .obj .g .res .rc

{$(ODIR)}.obj.exe :
	link $**

.g{$(ODIR)}.obj	:
	$(fasmg) -n -v 1 -e 2 $< $@

.rc{$(ODIR)}.res :
	rc /nologo /fo "$@" /r $<


# first rule is the default
all : init target

target : SubClass64.exe

OBJS =  $(ODIR)\SubClass64.obj \
	$(ODIR)\DialogProc.obj \
	$(ODIR)\ConvertStaticToHyperlink.obj \
	$(ODIR)\Dlg.res

# state immediate dependencies, rules above imply process to get these files
SubClass64.exe	: $(OBJS)
$(ODIR)\Dlg.res	: $(ODIR)\rsrc.xml


# demonstrate inline file
$(ODIR)\rsrc.xml :
	@type <<$@ >NUL
<?xml version="1.0" encoding="UTF-8" standalone="yes"?><assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">
<assemblyIdentity name="YourCorp.YourProduct.YourExe" processorArchitecture="amd64" version="0.0.0.1" type="win32" />
<description>TheProduct</description><dependency><dependentAssembly>
<assemblyIdentity type="win32" name="Microsoft.Windows.Common-Controls" version="6.0.0.0" processorArchitecture="amd64" publicKeyToken="6595b64144ccf1df" language="*" />
</dependentAssembly></dependency></assembly>
<< KEEP
# KEEP to produce only when needed


init :
	if not exist $(ODIR) md $(ODIR)

clean :
	if exist $(ODIR) rd /Q /S $(ODIR)

cleanall : clean
	del SubClass64.exe
