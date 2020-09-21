include '..\.win64\coff.g'

extrn DialogProc
dlgID_EXAMPLE = 37

section '$' code readable executable align 64

; use default /ENTRY, just so we don't need to pass more to linker:
;	/SUBSYSTEM:WINDOWS	WinMainCRTStartup
;	/SUBSYSTEM:CONSOLE	mainCRTStartup 
;	/DLL			_DllMainCRTStartup

public WinMainCRTStartup: ; default "/ENTRY: "
	pop rax
	call KERNEL32:GetModuleHandleW,0
	call USER32:DialogBoxParamW,rax,dlgID_EXAMPLE,0,ADDR DialogProc
	call KERNEL32:ExitProcess,rax
	int3

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:WINDOWS",6" ',\
	"/STACK:0,0 ",\
	"/HEAP:0,0 "
