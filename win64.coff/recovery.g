; coding: utf-8, tab: 8
include './.win64/coffms64.g'

; some constants
include './.win64/equates/winnt.g'
include './.win64/equates/WinBase.g'
include './.win64/equates/wincon.g'
include './.win64/equates/windef.g'
include './.win64/equates/WinUser.g'
include './.win64/equates/CommCtrl.g' ; ~ ProMiNick's version
;include './.win64/equates/kernel64.inc'
;include './.win64/equates/user64.inc'

section '.drectve' linkinfo linkremove
db '-SUBSYSTEM:"WINDOWS,6.2" -STACK:0,0 -HEAP:0,0 '

; Resource Constants:

DLG_MAIN=37
	ID_EDIT_NOTE	=	31
	ID_STATUSBAR	=	63
; menu items
ID_FILE_CRASH	=	127
ID_FILE_RESTART =	126
ID_FILE_RECOVER =	125
ID_FILE_EXIT	=	0



macro ZEROMEM A*,I*
	push rdi
	lea rdi,[A]
	mov ecx,I
	xor eax,eax
	rep stosb
	pop rdi
end macro

macro MOVMEM M0*,M1*,length*
	push rsi rdi
	lea rsi,[M0]
	lea rdi,[M1]
	mov ecx,length
	rep movsb
	pop rdi rsi
end macro

macro CMPMEM M0*,M1*,length*
	push rsi rdi
	lea rsi,[M0]
	lea rdi,[M1]
	mov ecx,length
	repz cmpsb
	pop rdi rsi
end macro

; sources : null pointer terminate (bad), null string skipped (okay)
macro MULTICATW dest*,sources&
	local skip,copy,X
	push rsi
	push rdi
	push 0
	iterate S,sources
		indx %%-%+1 ; reverse order
		match =ADDR? A,S
			lea rdi,[A]
			push rdi
		else
			push S
		end match
	end iterate
	lea rdi,[dest]

skip:	pop rcx
	jrcxz X
	push rcx ; xchg rsi,rcx ; mov rsi,[rsp-8]
	pop rsi
copy:	cmp word [rsi],0
	jz skip
	movsw
	jmp copy
X:	xchg eax,ecx
	; finalize stringz
	stosw
	sub edi,[rsp]
	; return string length in bytes
	xchg eax,edi
	pop rdi
	pop rsi
end macro


macro u64__to_CHAR dest*,source
	local N,A
	push rdi
	lea rdi,[dest]
	match any,source
		mov rax,source
	end match
	push rdi
	push 0
N:	xor edx,edx
	div [_10]
	add edx,'0'
	push rdx
	test rax,rax
	jnz N
	pop rax
A:	stosb
	pop rax
	test eax,eax
	jnz A
	sub edi,[rsp]
	; return bytes written to string
	xchg eax,edi
	pop rdi
	pop rdi
end macro

macro u64__to_WCHAR dest*,source
	local N,A
	push rdi
	lea rdi,[dest]
	match any,source
		mov rax,source
	end match
	push rdi
	push 0
N:	xor edx,edx
	div [_10]
	add edx,'0'
	push rdx
	test rax,rax
	jnz N
	pop rax
A:	stosw
	pop rax
	test eax,eax
	jnz A
	sub edi,[rsp]
	; return bytes written to string
	xchg eax,edi
	pop rdi
	pop rdi
end macro


macro WCHAR__to_u64 dest*,chars=rcx,source*,temp=rax
; Convert wide-char to unsigned integer and character count, using an auxiliary register.
	local N,X

	or reg32.#chars,-1
	xor reg32.#dest,reg32.#dest
N:	add reg32.#chars,1
	movzx reg32.#temp,word [source + chars*2]
	sub reg32.#temp,'0'
	jc X
	cmp reg32.#temp,10
	jc X
	imul dest,10
	add dest,temp
	jnc N
X:
; \chars\ (ECX) is number of digits read - zero when source is non-numeric. Advancing string afterward would be: LEA source,[source+chars*2]
end macro




; An extension of the following example:
; https://github.com/MicrosoftDocs/win32/blob/docs/desktop-src/Recovery/registering-for-application-recovery.md#saving-data-and-application-state-when-application-is-being-closed-due-to-a-software-update
;
; This application tries to track execution modalities with data preservation.
; It should be able to indicate if a restart happened and the reason for
; restart and return data to the start prior to restart.


section '.data' data readable writeable align 64

hMod_MSFTEDIT:
_MSFTEDIT db 'MSFTEDIT',0
align 8

_10		dq 10 ; for number conversion

g_hWndDesktop	rq	1
g_hInstance	rq	1
g_hHeap		rq	1
g_hWnd		rq	1
g_hWndStatus	rq	1

g_pRestartCommandLine	dq _restart ; default to just flagging execution is a restart
g_dwRecordId	dd 0

align 8
_roption Δ du 0,'-r:'
assert 8 = sizeof _roption
	du 0

;define RESTART_SWITCH_LEN ((sizeof _restart - 1) shr 1) ; characters not including null
_restart Δ du "/restart",0

; some status messages
stat_init Δ du 'Initializing application',0
stat_rset Δ du 'Initializing after restart (record ID is %lu)',0


section '.bitRAKE' code readable executable align 64


Menu__CheckState: ; hack
	push rax rax
	call Menu__ToggleCheck
	jnc @F
	retn
@@:	pop rax rax

Menu__ToggleCheck: ; helper function, return resulting state, CF on error
namespace Menu__ToggleCheck
	frame.enter ,<hMenu:QWORD,miInfo:MENUITEMINFOW,item:DWORD>
	mov [item],eax

	ZEROMEM miInfo,sizeof MENUITEMINFOW
	mov [miInfo.cbSize],sizeof MENUITEMINFOW
	mov [miInfo.fMask],MIIM_STATE

	call USER32:GetMenu,[g_hWnd]
	xchg rcx,rax ; HANDLE
	jrcxz F
	xor r8,r8
	mov edx,[item]
	mov [hMenu],rcx
	call USER32:GetMenuItemInfoW,rcx,rdx,r8,ADDR miInfo
	xchg ecx,eax ; BOOL
	jrcxz F
	xor r8,r8
	mov edx,[item]
	xor [miInfo.fState],MFS_CHECKED ; toggle
	call USER32:SetMenuItemInfoW,[hMenu],rdx,r8,ADDR miInfo
	test [miInfo.fState],MFS_CHECKED
	setnz al
X:	frame.leave
	retn ; ~ZF same as BOOL result ;)

F:	stc ; programer error
	jmp X
end namespace








IsRestartSelected:
namespace IsRestartSelected
	frame.enter ,<miInfo:MENUITEMINFOW>
	ZEROMEM miInfo,sizeof MENUITEMINFOW
	mov [miInfo.cbSize],sizeof MENUITEMINFOW
	mov [miInfo.fMask],MIIM_STATE

	call USER32:GetMenu,[g_hWnd]
	test rax,rax ; HANDLE
	jz @F
	call USER32:GetMenuItemInfoW,rax,ID_FILE_RESTART,0,ADDR miInfo
	test eax,eax ; BOOL
	jz @F
	test [miInfo.fState],MFS_CHECKED
	setnz al
@@:	frame.leave
	retn ; ~ZF same as BOOL result ;)
end namespace


; Implement the recovery callback. This callback lets the application save
; state information or data in the event that the application encounters an
; unhandled exception or becomes unresponsive.
RecoveryCallBack: ; RCX is private parameter
frame.enter <pContext:QWORD>,<			\
	wsCommandLine:rw RESTART_MAX_CMD_LINE,	\
	_id:rw 12,				\
	bCanceled:DWORD				>

;TODO: Recovery work. Save state information.

	call IsRestartSelected
	jz .no_restart

	; update restart commandline

	; convert dwRecordId to ASCII
	mov eax,[g_dwRecordId]
	u64__to_WCHAR _id
	MULTICATW wsCommandLine,ADDR _restart,ADDR _roption,ADDR _id

        call KERNEL32:RegisterApplicationRestart,ADDR wsCommandLine,\
		RESTART_NO_PATCH or RESTART_NO_REBOOT
	xchg ecx,eax
	jrcxz .S_OK
;"RegisterApplicationRestart failed with ox%x.\n"
	int3
.S_OK:
.no_restart:
	call KERNEL32:ApplicationRecoveryInProgress,ADDR bCanceled
	mov ecx,[bCanceled]
	jrcxz @F

;        wprintf(L"Recovery was canceled by the user.\n");

	mov ecx,[bCanceled]
@@:	xor ecx,1 ; only finish if not cancelled, application will terminate
	call KERNEL32:ApplicationRecoveryFinished,rcx
	xor eax,eax
	frame.leave
	retn



MainDlgProcW:
namespace MainDlgProcW
	iterate M, WM_COMMAND,WM_PAINT,WM_CLOSE,WM_INITDIALOG,\
		WM_QUERYENDSESSION,WM_ENDSESSION
		cmp edx,M
		jz _#M
		jmp USER32:DefWindowProcW
	end iterate


_WM_COMMAND:
	iterate M, ID_FILE_CRASH,ID_FILE_RESTART,ID_FILE_RECOVER,ID_FILE_EXIT
		cmp r8w,M
		jz .#M
	end iterate
	jmp USER32:DefWindowProcW

.ID_FILE_EXIT:
	jmp _WM_CLOSE

.ID_FILE_CRASH:
	xor eax,eax
	mov byte [rax],5 ; an exception!
	retn

.ID_FILE_RESTART:
	frame.enter
	mov eax,ID_FILE_RESTART
	call Menu__ToggleCheck
	jc .error
	jnz .ID_FILE_RESTART_checked

	call KERNEL32:UnregisterApplicationRestart
	test eax,eax ; HRESULT
	js .error
	jmp @F

.ID_FILE_RESTART_checked:
	; setup
	call KERNEL32:RegisterApplicationRestart,
	test eax,eax ; HRESULT
	js .error
@@:	xor eax,eax
	frame.leave
	retn

.ID_FILE_RECOVER:
	frame.enter
	mov eax,ID_FILE_RECOVER
	call Menu__ToggleCheck
	jc .error
	jnz .ID_FILE_RECOVER_checked

	call KERNEL32:UnregisterApplicationRecoveryCallback
	test eax,eax ; HRESULT
	js .error
	jmp .return_zero

.ID_FILE_RECOVER_checked:
	call KERNEL32:RegisterApplicationRecoveryCallback,ADDR RecoveryCallBack,\
		ADDR g_dwRecordId,RECOVERY_DEFAULT_PING_INTERVAL,0
	test eax,eax ; HRESULT
	jns .return_zero
.error:
	; GetLastError

.return_zero:
	xor eax,eax
	frame.leave
	retn



_WM_PAINT:
	frame.enter <hWnd:QWORD>,<hDC:QWORD,ps:PAINTSTRUCT>
	call USER32:BeginPaint,[hWnd],ADDR ps
	mov [hDC],rax

	; TODO: Add any drawing code here...

	call USER32:BeginPaint,[hWnd],ADDR ps
	frame.leave
	retn


_WM_CLOSE:
	frame.enter
	call USER32:EndDialog,rcx,0
	xor eax,eax
	frame.leave
	retn


_WM_QUERYENDSESSION:
	test r9,ENDSESSION_CLOSEAPP
	jz .no_closeapp

	call KERNEL32:RegisterApplicationRestart,[g_pRestartCommandLine],0
	xchg ecx,eax
	jrcxz .S_OK
	; Log an event or do some error handling.
.S_OK:

.no_closeapp:
	mov eax,1 ; TRUE
	retn


_WM_ENDSESSION:
	test r9,ENDSESSION_CLOSEAPP
	jz .no_closeapp
	test r8,r8 ; BOOL
	jz .not_closing

; You should use this opportunity to save data and state information.

.not_closing:
	call KERNEL32:RegisterApplicationRestart,[g_pRestartCommandLine],0
	xchg ecx,eax
	jrcxz .S_OK
	; Log an event or do some error handling.
.S_OK:

.no_closeapp:
	retn


_WM_INITDIALOG:
	; load edit control text
	;	if not restarting info text
	;	else preserved text
;call :SendDlgItemMessageW,[hDlg],ID_EDIT_NOTE,EM_SETTEXTEX,ADDR stex,[_buffer]
	xor eax,eax
	retn

end namespace





public WinMainCRTStartup:
	frame.enter ,<				\
		iccex:INITCOMMONCONTROLSEX,	\
		argv:QWORD,			\
		argn:DWORD			>


	call KERNEL32:GetSystemTimeAsFileTime,rbp

	call KERNEL32:GetCommandLineW
	call SHELL32:CommandLineToArgvW,rax,ADDR argn
	mov [argv],rax

; look for "/restart -r:<RecordId>" in commandline arguments

	xchg rsi,rax
	mov edx,[argn]
.keep_looking:
	sub edx,1
	js .not_restart
@@:	lodsq
	CMPMEM _restart,rax,sizeof _restart ; null inclusion excludes prefix match
	jnz .keep_looking
	xchg ecx,edx
	jrcxz .not_restart
	lodsq
	mov rcx,[rax]
	shl rcx,16
	cmp [_roption],rcx ; du 0,'-r:'
	jnz .not_restart

	; parse number, if invalid number then .not_restart
	WCHAR__to_u64 rdx,rcx,(rax+8),rbx
	jrcxz .not_restart

	; validated restart state

	nop ; TODO: respond to restart

	jmp .not_restart

.not_restart:
	; parse regular command line
	call KERNEL32:LocalFree,[argv]

	call KERNEL32:GetModuleHandleW,0
	mov [g_hInstance],rax
	call KERNEL32:GetDesktopWindow
	mov [g_hWndDesktop],rax
	call KERNEL32:GetProcessHeap
	mov [g_hHeap],rax

	; register controls needed for dialog
	mov [iccex.dwSize],sizeof iccex
	mov [iccex.dwICC],ICC_BAR_CLASSES
	call COMCTL32:InitCommonControlsEx,ADDR iccex
	sub eax,1
	jnz .get_last_error

	; RICHEDIT50W registered when MSFTEDIT is loaded
	call KERNEL32:LoadLibraryA,ADDR _MSFTEDIT
;	call KERNEL32:GetProcAddressA,[hMod_MSFTEDIT],ADDR _IID_ITextDocument2
	mov [hMod_MSFTEDIT],rax
	xchg rcx,rax
	jrcxz .get_last_error

	call USER32:DialogBoxParamW,[g_hInstance], \
		DLG_MAIN,[g_hWndDesktop],ADDR MainDlgProcW

	call KERNEL32:FreeLibrary,[hMod_MSFTEDIT] ; might be outstanding threads!
.get_last_error:
	call KERNEL32:GetLastError
	xchg rcx,rax
	call KERNEL32:ExitProcess,rcx
	frame.leave
	int3

