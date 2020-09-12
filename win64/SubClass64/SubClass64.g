include 'format\format.inc'
FORMAT MS64 COFF

extrn '__imp_DialogBoxParamW'	as DialogBoxParam:QWORD
extrn '__imp_ExitProcess'	as ExitProcess:QWORD
extrn '__imp_GetModuleHandleW'	as GetModuleHandle:QWORD

extrn DialogProc
dlgID_EXAMPLE = 37


section '.drectve' linkinfo linkremove
	db "/SUBSYSTEM:WINDOWS,6.02 "
	db "/STACK:0,0 "
	db "/HEAP:0,0 "
	db "/DEFAULTLIB:KERNEL32.LIB "
	db "/DEFAULTLIB:USER32.LIB "


section '$' code readable executable align 64

public WinMainCRTStartup
WinMainCRTStartup:
	pop rax
	xor ecx,ecx
	call [GetModuleHandle]
	xchg rcx,rax
	mov edx,dlgID_EXAMPLE	; LPCTSTR
	xor r8,r8		; hWndParent	HWND_DESKTOP
	lea r9,[DialogProc]	; lpDialogFunc
	call [DialogBoxParam]
	xchg ecx,eax
	call [ExitProcess]
	int3
