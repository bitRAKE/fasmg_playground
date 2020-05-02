include 'format/format.inc'
include 'cpu/ext/avx2.inc'
FORMAT PE64 GUI 6.2 at $10000 on "NUL"
STACK	1,	0
HEAP	1,	0

SECTION '.flat' CODE READABLE WRITEABLE EXECUTABLE
POSTPONE
	kernel_name db 'kernel32',0
	user_name db 'user32',0

	_GetCurrentProcess db 0,0,"GetCurrentProcess",0
	_SetProcessWorkingSetSizeEx db 0,0,"SetProcessWorkingSetSizeEx",0
	_Sleep db 0,0,'Sleep',0
	_MessageBeep db 0,0,'MessageBeep',0

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
			MessageBeep dq RVA _MessageBeep
			dq 0
	END DATA
END POSTPONE

ENTRY $
pop rsi

call [GetCurrentProcess]
xchg rcx,rax
or rdx,-1
or r8,-1
mov r9d,2 ; QUOTA_LIMITS_HARDWS_MIN_DISABLE
call [SetProcessWorkingSetSizeEx]

MonkeyBusiness:
; https://docs.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-messagebeep
	xor ecx,ecx
	call [MessageBeep]

	mov ecx,1000 * 280 ; little less than 5 min
	call [Sleep]
	jmp MonkeyBusiness