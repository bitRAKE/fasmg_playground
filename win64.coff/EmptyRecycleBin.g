; coding: utf-8, tab: 8
include './.win64/coffms64.g'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" /STACK:0,0 /HEAP:0,0 '

section '.flat' code readable executable align 64

notice Δ TCHAR "Emptying Recycle Bin",10,0
error Δ TCHAR "E: Unable To Empty Recycle Bin. Possibly Already Empty",10,0

public mainCRTStartup:
	frame.enter ,<hConOut:QWORD>
	call KERNEL32:GetStdHandle,-11 ; STD_OUTPUT_HANDLE
	mov [hConOut],rax
	call KERNEL32:WriteConsoleW,[hConOut],ADDR notice,(sizeof notice-1)shr 1,0,0
	call SHELL32:SHEmptyRecycleBinW,0,0,1
	xchg ecx,eax
	jrcxz .S_OK
	call KERNEL32:WriteConsoleW,[hConOut],ADDR error,(sizeof error-1)shr 1,0,0
.S_OK:	call KERNEL32:ExitProcess,0
	frame.leave
	int3
