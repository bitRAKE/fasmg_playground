fasmg = fasmg.exe

.SUFFIXES :
.SUFFIXES : .exe .obj .g .res .rc

.obj.exe	:
	link $**

.g.obj	:
	$(fasmg) $< $@


SubClass64.exe	: SubClass64.obj DialogProc.obj ConvertStaticToHyperlink.obj Dlg.res
Dlg.res		: rsrc.xml


# demonstrate inline file
rsrc.xml :
	@type <<$@ >NUL
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<assembly
	xmlns="urn:schemas-microsoft-com:asm.v1"
	manifestVersion="1.0">
	<assemblyIdentity
		name="YourCorp.YourProduct.YourExe"
		processorArchitecture="amd64"
		version="0.0.0.1"
		type="win32"
	/>
	<description>TheProduct</description>
	<dependency>
		<dependentAssembly>
			<assemblyIdentity
				type="win32"
				name="Microsoft.Windows.Common-Controls"
				version="6.0.0.0"
				processorArchitecture="amd64"
				publicKeyToken="6595b64144ccf1df"
				language="*"
			/>
		</dependentAssembly>
	</dependency>
</assembly>
<< NOKEEP

clean	:
	@for %%a in (\
		SubClass64.exe\
		SubClass64.obj\
		DialogProc.obj\
		ConvertStaticToHyperlink.obj\
		Dlg.res\
		rsrc.xml	\
	) do @if exist %%a del %%a
