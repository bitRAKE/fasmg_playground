; Using the macros and symbols supporting the interfaces means rarely needing
; to change anything in this file.

INCLUDE 'win64w.inc'
FORMAT PE64 GUI 5.0 DLL AT 0
SECTION '.text' CODE READABLE EXECUTABLE

include '..\x64help.inc'
include '.\npp\Notepad_plus_msgs.inc'
	;include '.\npp\menuCmdID.inc'
include '.\npp\Scintilla.inc'
include '.\npp\ILexer4.inc'
	;include '.\npp\IDocument.inc'



; BOOL APIENTRY DllMain(HANDLE hModule, DWORD reasonForCall, LPVOID);
DllMain: ENTRY $
	cmp edx,DLL_PROCESS_ATTACH
	jz .attach
	cmp edx,DLL_PROCESS_DETACH
	jz .detach
	push 1
	pop rax
	retn
.attach:
	mov [hInstance],rcx

	; dynamic setup

.x:	push 1
	pop rax
	retn
.detach:
	push 1
	pop rax
	retn


isUnicode: ; BOOL isUnicode();
	push 1				; npp always UNICODE compiled
	pop rax				; always true
	retn


getName: ; const TCHAR * getName()
	lea rax,[PluginName]
	retn


; NOTE: remove the indirection so the handles can be used directly
setInfo: ; void setInfo(NppData notpadPlusData)
	push qword [rcx]
	push qword [rcx+8]
	push qword [rcx+16]
	pop [scintillaSecondHandle]
	pop [scintillaMainHandle]
	pop [nppHandle]

	enter 32,0

	xor r9,r9
	xor r8,r8
	mov edx,SCI_GETDIRECTFUNCTION
	mov rcx,[scintillaMainHandle]
	call[SendMessageW]
	mov [CallScintilla],rax

	xor r9,r9
	xor r8,r8
	mov edx,SCI_GETDIRECTPOINTER
	mov rcx,[scintillaMainHandle]
	call[SendMessageW]
	mov [CallScintilla.windows],rax

	xor r9,r9
	xor r8,r8
	mov edx,SCI_GETDIRECTPOINTER
	mov rcx,[scintillaSecondHandle]
	call[SendMessageW]
	mov [CallScintilla.windows+8],rax

	leave
	retn


getFuncsArray: ; FuncItem * getFuncsArray(int *nbF)
	lea rax,[FunctionTable]
	mov dword[rcx],nbFunc
	retn


; window handle to view index
macro hWndtoViewId regmem,reg ; byte,qword
	cmp [scintillaMainHandle],reg
	setnz regmem
end macro

; use direct call interface
;	view Id: reg64, [memory] or literal 0 or 1
;	msg: messages defined in Scintilla documentation
;	lp,wp: parameters, support ADDR for address calculation
macro sciCall view*,msg*,lp=0,wp=0
	iterate <R,P>, R9,wp, R8,lp
		match =0,P
			xor R,R
		else match =ADDR? M,P
			lea R,M
		else match =R,R
			; do nothing is an option
		else
			mov R,P
		end match
	end iterate
	mov edx,msg
	match [M],view
		movzx ecx,byte[M]
		mov rcx,[CallScintilla.windows + rcx*8]
	else
		mov rcx,[CallScintilla.windows + view*8]
	end match
	call [CallScintilla]
end macro







;struc ShortcutKey A=?,B=?,C=?,D=?
;	_isCtrl		db A
;	_isAlt		db B
;	_isShift	db C
;	_key		db D
;end struc

funcItem.nbChar := 64
funcItem.bytes := 152 ; 128+8+4+4+8

struc funcItem text=_,chk=0,key=0
match =_,text
	du "-SEPARATOR-"
	rw 65
else
; . is function name, label defined in code - not function table
namespace .
	itemName	du text
			rw 64 - (($ - itemName) shr 1)
	pFunc		dq .
	cmdID		dd 0 ; set by plugin manager
	init2Check	db chk,?,?,?
if key=0
	pShKey		dq 0
else
	pShKey		dq key ; TODO: point to shortcut key structure
end if
end namespace
end match
end struc


POSTPONE;-----------------------------------------------------------------------
SECTION '.edata' EXPORT DATA READABLE
include '..\ToDLL_Name.inc'
export __DLL_NAME__,\
	GetLexerCount		,"GetLexerCount",\	; needed by npp and Scintilla
	GetLexerFactory		,"GetLexerFactory",\	; needed by Scintilla
	GetLexerName		,"GetLexerName",\	; needed by npp and Scintilla
	GetLexerStatusText	,"GetLexerStatusText",\	; needed by npp
	beNotified		,"beNotified",\
	getFuncsArray		,"getFuncsArray",\
	getName			,"getName",\
	isUnicode		,"isUnicode",\
	messageProc		,"messageProc",\
	setInfo			,"setInfo"

SECTION '.reloc' FIXUPS DATA READABLE DISCARDABLE
END POSTPONE