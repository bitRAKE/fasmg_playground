include 'format\format.inc'
include 'encoding\utf8.inc'
FORMAT MS64 COFF

extrn '__imp_EndDialog'		as EndDialog:QWORD
extrn '__imp_GetDlgItemTextW'	as GetDlgItemTextW:QWORD
extrn '__imp_ShellExecuteW'	as ShellExecuteW:QWORD

WM_CLOSE	= 0010h
WM_INITDIALOG	= 0110h
WM_COMMAND	= 0111h

BN_CLICKED	= 0

SW_SHOWNORMAL	= 1


IDC_STC_LINK = 401
extrn ConvertStaticToHyperlink


section '.drectve' linkinfo linkremove
	db "/DEFAULTLIB:USER32.LIB "
	db "/DEFAULTLIB:SHELL32.LIB "


section '$zzzz' data readable align 1

	_open	du 'Open',0


section '$' code readable executable align 64

public DialogProc
DialogProc:
	; hWndDlg	rcx
	; msg		rdx
	; wParam	r8
	; lParam	r9

	; common exit condition, FALSE = message not processed
	xor eax,eax

	cmp edx,WM_COMMAND
	je .WM_COMMAND
	cmp edx,WM_INITDIALOG
	je .WM_INITDIALOG
	cmp edx,WM_CLOSE
	je .WM_CLOSE
	retn

	.WM_INITDIALOG:
		; RCX is parent handle
		mov edx,IDC_STC_LINK
		call ConvertStaticToHyperlink
		mov eax,1
		retn

	.WM_CLOSE:
		enter 8*4,0
		; hWnd in RCX
		xor edx,edx
		call [EndDialog]
		jmp .processed

	.WM_COMMAND:
		cmp r8d,BN_CLICKED shl 16 + IDC_STC_LINK
		je .WM_COMMAND.ID_LINK
;		mov rax,0
		retn

	.WM_COMMAND.ID_LINK:
		enter .frame,0
		virtual at rbp-.frame
			; parameter space
					rq 4
			.4		rq 1
			.5		rq 1
			.buffer.. = 2000
			.buffer		rw .buffer..
			.frame = NOT 15 AND ($-$$+15)
		end virtual

		; RCX is dialog handle
		movzx edx,r8w	; ID_LINK ; IDC_STC_LINK
		lea r8,[.buffer]
		mov r9d,.buffer..
		call [GetDlgItemTextW]

		xor ecx,ecx		; HWND_DESKTOP
		lea rdx,[_open]		; lpOperation
		lea r8,[.buffer]	; lpFile
		mov r9,rcx		; lpParameters
		mov [.4],rcx		; lpDirectory
		mov [.5],SW_SHOWNORMAL
		call [ShellExecuteW]
	.processed:
		leave
		mov eax,1
		retn
