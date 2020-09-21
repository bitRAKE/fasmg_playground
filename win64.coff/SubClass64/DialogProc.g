include '..\.win64\coff.g'

WM_CLOSE	= 0010h
WM_INITDIALOG	= 0110h
WM_COMMAND	= 0111h
BN_CLICKED	= 0
SW_SHOWNORMAL	= 1


IDC_STC_LINK = 401
extrn ConvertStaticToHyperlink

section '$zzzz' data readable align 2
	_open	du 'Open',0


section '$' code readable executable align 64

public DialogProc:
namespace DialogProc
	; common exit condition, FALSE = message not processed
	xor eax,eax
	iterate msg, WM_COMMAND,WM_INITDIALOG,WM_CLOSE
		cmp edx,msg
		jz _#msg
	end iterate
	retn

_WM_INITDIALOG:
	; RCX is parent handle
	mov edx,IDC_STC_LINK
	call ConvertStaticToHyperlink
	mov eax,1
	retn

_WM_CLOSE:
	enter 8*4,0
	call USER32:EndDialog,rcx,0
	jmp processed

_WM_COMMAND:
	cmp r8d,BN_CLICKED shl 16 + IDC_STC_LINK
	jz .ID_LINK
;	mov rax,0
	retn

.ID_LINK:
	; raw style w/o frame macro
	enter .frame,0
	virtual at rbp-.frame
		; parameter space
				rq 4
		..P4		rq 1
		..P5		rq 1
		.buffer.. = 2000
		.buffer		rw .buffer..
		.frame = NOT 15 AND ($-$$+15)
	end virtual

	movzx edx,r8w	; IDC_STC_LINK
	call USER32:GetDlgItemTextW,rcx,rdx,ADDR .buffer,.buffer..
	call SHELL32:ShellExecuteW,0,ADDR _open,ADDR .buffer,0,0,SW_SHOWNORMAL
processed:
	leave
	mov eax,1
	retn
	
end namespace
