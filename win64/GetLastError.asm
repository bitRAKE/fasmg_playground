format PE64 CONSOLE 6.2 at $7FFF_FFFE_0000
include 'win64wxp.inc'

struct MSGBOXPARAMSW
cbSize			dd ?,?
hwndOwner		dq ?
hInstance		dq ?
lpszText		dq ?
lpszCaption		dq ?
dwStyle			dd ?,?
lpszIcon		dq ?
dwContextHelpId		dd ?,?
lpfnMsgBoxCallback	dq ?
dwLanguageId		dd ?,?
ends ; MSGBOXPARAMSW

struct HELPINFO
cbSize		dd ?
iContextType	dd ?
iCtrlId		dd ?,?
hItemHandle	dq ?
dwContextId	dd ?,?
MousePos	POINT
ends ; HELPINFO

.code

help_info:
	virtual at RCX
		.hi HELPINFO
	end virtual
	cmp [.hi.dwContextId],55555
	jnz @F
	enter 32,0
	; don't loop back here
	and [mbp__GetLastError.dwStyle],not MB_HELP
	lea rcx,[mbp__GetLastError]
	call [MessageBoxIndirectW]
	leave
@@:	retn



Quilt:

invoke GetStdHandle,STD_OUTPUT_HANDLE
mov [hCon],rax
invoke GetLastError
mov [last_error],rax
invoke FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER\
\	; always use these two together
	or FORMAT_MESSAGE_FROM_SYSTEM\
	or FORMAT_MESSAGE_IGNORE_INSERTS,0,[last_error],0,ADDR lpBuffer,0,0
invoke WriteConsole,[hCon],[lpBuffer],eax,0,0

	push [lpBuffer]
	pop [mbp__GetLastError.lpszText]
	invoke MessageBoxIndirectW,ADDR mbp__GetLastError ; display error

invoke LocalFree,[lpBuffer]
invoke ExitProcess,eax



.data
_title TCHAR "My GetLastError",0

align 8
last_error	rq 1
hCon		rq 1
lpBuffer	rq 1

mbp__GetLastError MSGBOXPARAMSW\
	cbSize:80,\
	hwndOwner:0,\
	hInstance:0,\; zero to use system icon (LoadIcon) value
	lpszCaption:_title,\
	dwStyle:MB_OK or MB_USERICON  or MB_HELP or MB_TASKMODAL,\
	lpszIcon:32518,\
	dwContextHelpId:55555,\
	lpfnMsgBoxCallback:help_info

.end Quilt