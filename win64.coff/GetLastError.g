; coding: utf-8, tab: 8
include './.win64/coffms64.g'

; some constants
include './.win64/equates/kernel64.inc'
include './.win64/equates/user64.inc'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" ',	\
	'/STACK:0,0 ',			\
	'/HEAP:0,0 '



section '.data' data readable writeable align 8
; global because MB_TASKMODAL, and help_info needs to access it
; zero hInstance to use system icon (LoadIcon) value
mbp MSGBOXPARAMSW				\
	cbSize:			sizeof mbp,	\; 80
	hwndOwner:		0,		\
	hInstance:		0,		\
	lpszCaption:		_title,		\
	dwStyle:		MB_OK or MB_USERICON  or MB_HELP or MB_TASKMODAL, \
	lpszIcon:		32518,		\
	dwContextHelpId:	HLP_LASTERR,	\
	lpfnMsgBoxCallback:	help_info
align 2
_title TCHAR "My GetLastError",0



section '.flat' code readable executable align 64

HLP_LASTERR = 55555

help_info:
	virtual at RCX
		.hi HELPINFO
	end virtual
	cmp [rcx+.hi.dwContextId],HLP_LASTERR
	jz @F
	retn

@@:	lea rcx,[mbp]
	; don't loop back here
	and [rcx+MSGBOXPARAMSW.dwStyle],not MB_HELP
	enter 32,0
	call USER32:MessageBoxIndirectW,rcx ; display error
	leave
	retn


public mainCRTStartup:
frame.enter ,<			\
	hCon:QWORD,		\
	last_error:QWORD,	\
	lpBuffer:QWORD		>

call KERNEL32:GetStdHandle,STD_OUTPUT_HANDLE
mov [hCon],rax
call KERNEL32:GetLastError
mov [last_error],rax
call KERNEL32:FormatMessageW,FORMAT_MESSAGE_ALLOCATE_BUFFER	\
	or FORMAT_MESSAGE_FROM_SYSTEM				\
	or FORMAT_MESSAGE_IGNORE_INSERTS,0,[last_error],0,ADDR lpBuffer,0,0

call KERNEL32:WriteConsoleW,[hCon],[lpBuffer],rax,0,0

push [lpBuffer]
pop [mbp.lpszText]
call USER32:MessageBoxIndirectW,ADDR mbp ; display error

call KERNEL32:LocalFree,[lpBuffer]
xchg ecx,eax
call KERNEL32:ExitProcess,rcx

frame.leave
int3
