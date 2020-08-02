; An example based on: https://board.flatassembler.net/topic.php?t=21491
; Can Notepad be used as a rudamentary debug logger - in a pinch, yes.
;
; Please, just use a real debugger.
;
include 'format/format.inc'
FORMAT PE64 GUI 5.0 at $10000 on "NUL"

SECTION '.flat' CODE READABLE WRITEABLE EXECUTABLE

macro LOG fmt,P&
	local _
	push _
	enter 2048,0
	and spl,-16
	iterate p,P
		mov rax,p
		mov [rsp+24+8*%],rax
	end iterate
	call __DBGOUT__
	db fmt,0
	label _:-1
end macro

; time delta first parameter of log line
macro TLOG fmt,P&
	local _
	push _
	enter 2048,0
	and spl,-16
	Get100ns
	push rax
	sub rax,[_timelast]
	pop [_timelast]
	iterate p,RAX,P
		mov rax,p
		mov [rsp+24+8*%],rax
	end iterate
	call __DBGOUT__
	db "0x%IX: ",fmt,13,10,0
	label _:-1
end macro

__DBGOUT__:
	pop rdx
	lea r8,[rsp+32]
	lea rcx,[rsp+768]
	call[wvsprintfA]

	xor ecx,ecx
	lea rdx,[_notepad_title]
	call [FindWindowA]
	xchg rcx,rax
	jrcxz .Ex

	xor edx,edx
	lea r8,[_EDIT]
	xor r9,r9
	call [FindWindowExA]
	xchg rcx,rax
	jrcxz .Ex

	mov edx,194 ; EM_REPLACESEL
	push 1
	pop r8
	lea r9,[rsp+768]
	call [SendMessageA]

.Ex:	leave
	retn

align 8
_timelast rq 1
; The universal modified title of a new instance.
; Activation requires a fresh character.
_notepad_title db "*Untitled - Notepad",0
_EDIT db "EDIT",0


include 'x64help.inc'
include 'time.inc'

ENTRY $
pop rsi

xor r15,r15
Get100ns
mov [_timelast],rax

call [GetCurrentProcess]
xchg rcx,rax
or rdx,-1
or r8,-1
mov r9d,2 ; QUOTA_LIMITS_HARDWS_MIN_DISABLE
call [SetProcessWorkingSetSizeEx]


MonkeyBusiness:
	xor ecx,ecx
	call [MessageBeep]

add r15,1
TLOG "beep #: %lu",r15

	mov ecx,1000 * 15 - 3 ; overhead of 3 on average
	call [Sleep]
	jmp MonkeyBusiness



kernel_name db 'kernel32',0
user_name db 'user32',0

_GetCurrentProcess db 0,0,"GetCurrentProcess",0
_SetProcessWorkingSetSizeEx db 0,0,"SetProcessWorkingSetSizeEx",0
_Sleep db 0,0,'Sleep',0

_FindWindowA db 0,0,'FindWindowA',0
_FindWindowExA db 0,0,'FindWindowExA',0
_MessageBeep db 0,0,'MessageBeep',0
_SendMessageA db 0,0,'SendMessageA',0
_wvsprintfA db 0,0,'wvsprintfA',0

align 8
DATA IMPORT ; section '.idata' import data readable writeable
dd 0,0,0,RVA kernel_name,RVA kernel_table
dd 0,0,0,RVA user_name,RVA user_table
dd 0,0,0,0,0
align 8
kernel_table:
	GetCurrentProcess dq RVA _GetCurrentProcess
	SetProcessWorkingSetSizeEx dq RVA _SetProcessWorkingSetSizeEx
	Sleep dq RVA _Sleep
	dq 0
user_table:
	FindWindowA	dq RVA _FindWindowA
	FindWindowExA	dq RVA _FindWindowExA
	MessageBeep	dq RVA _MessageBeep
	SendMessageA	dq RVA _SendMessageA
	wvsprintfA	dq RVA _wvsprintfA
	dq 0
END DATA