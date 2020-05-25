;----------------------------------------------------------NPP Plugin Interface:
; REFERENCES:
;	https://npp-user-manual.org/docs/plugin-communication/
;	https://github.com/notepad-plus-plus/npp-usermanual
;		/content/docs/plugin-communication.md
;	https://www.scintilla.org/ScintillaDoc.html
;
;	Although these files are in the plugin kit, main is most recent:
;	https://github.com/notepad-plus-plus/notepad-plus-plus/
;		/PowerEditor/src/menuCmdID.h
;		/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
;		/scintilla/include/Scintilla.h
;	etc.
include '.\npp\PluginInterface.inc'

;required by npp
beNotified: ; SCNotification *notifyCode
virtual at RCX
	.scNote SCNotification
end virtual
	cmp [.scNote.nmhdr.code],NPPN_BUFFERACTIVATED
	jz .NPPN_BUFFERACTIVATED	; are we waiting on a new window?
	; if debugIndex isn't valid, don't try to preserve it
	test [debugFlags],DEBUG_DOC
	jz .no_doc
	cmp [.scNote.nmhdr.code],NPPN_DOCORDERCHANGED
	jz .NPPN_DOCORDERCHANGED	; did our ID change?
	cmp [.scNote.nmhdr.code],NPPN_FILECLOSED
	jz .NPPN_FILECLOSED		; is our ID still valid?
	cmp [.scNote.nmhdr.code],NPPN_READY
	jz .NPPN_READY
.no_doc:
	retn

.NPPN_BUFFERACTIVATED:
	btr [debugFlags],BSF DEBUG_NEW_WAIT
	jnc .no_doc
	mov eax,dword [.scNote.nmhdr.idFrom]
	mov [debugIndex],eax
	or [debugFlags],DEBUG_DOC
	retn

.NPPN_DOCORDERCHANGED:
	mov eax,[debugIndex]
	cmp dword [.scNote.nmhdr.idFrom],eax
	jnz .no_doc
	mov eax,dword [.scNote.nmhdr.hwndFrom]
	mov [debugIndex],eax
	retn

.NPPN_FILECLOSED:
	mov eax,[debugIndex]
	cmp dword [.scNote.nmhdr.idFrom],eax
	jnz .no_doc
	and [debugFlags],NOT DEBUG_DOC
	btr [debugFlags],BSF DEBUG_ACTIVE
	jnc .not_active
	enter 32,0

; TODO: terminate debug watch thread

	xor r9,r9 ; FALSE
	mov r8d,[LogDebugStrings.cmdID]
	mov edx,NPPM_SETMENUITEMCHECK
	mov rcx,[nppHandle]
	call [SendMessageW]
	leave
.not_active:
	retn

.NPPN_READY:
	; create debug string watcher thread
	retn


;required by npp
messageProc: ; LRESULT messageProc(/*Message*/,/*wParam*/,/*lParam*/)
	push 1
	pop rax
	retn


;----------------------------------------------------------------Lexer Specific:

GetLexerStatusText: ; (unsigned int /*Index*/, TCHAR *desc, int buflength)
; Only npp needs this function. It copies up to 32 characters of text for
; the status bar to display when a particular language is being used.
	cmp rcx,LexerCount
	jnc GetLexerName.fail
	shl ecx,6
	lea rax,[LexerStatuses+rcx]
	mov ecx,64
	jmp GetLexerName.part


GetLexerName: ; (unsigned int /*index*/, char *name, int buflength)
; Needed by npp and Scintilla. It copies up to 16 bytes of ASCII text
; providing a short name for the lexer.
	cmp rcx,LexerCount
	jnc .fail
	shl ecx,4
	lea rax,[LexerNames+rcx]
	mov ecx,16
.part:	cmp r8d,ecx
	cmovc ecx,r8d		; MUST respect buffer length
	xchg r8,rax
.cpy:	mov al,[r8+rcx-1]
	mov [rdx+rcx-1],al
	loop .cpy
	xchg eax,ecx
.fail:	retn


GetLexerCount:
; Needed by npp and Scintilla. Returns the number of lexers implemented.
	push LexerCount ; NOTE: npp is capped at 30 external lexers total
	pop rax
	retn


GetLexerFactory: ; (unsigned int index)
	xor eax,eax
	cmp rcx,LexerCount
	jnc .fail
	imul ecx,ecx,ILexer4_VTable.bytes shr 3
	lea rax,[LexerVTables+rcx*8]
.fail:	retn


;----------------------------------------------------------------Menu Functions:

LogDebugStrings:
	enter 32,0
	btc [debugFlags],BSF DEBUG_ACTIVE
	jnc .activate

	; suspend / terminate debug watch thread

	xor r9,r9 ; FALSE
	mov r8d,[LogDebugStrings.cmdID]
	mov edx,NPPM_SETMENUITEMCHECK
	mov rcx,[nppHandle]
	call [SendMessageW]
	leave
	retn
.activate:
	push 1 ; TRUE
	pop r9
	mov r8d,[LogDebugStrings.cmdID]
	mov edx,NPPM_SETMENUITEMCHECK
	mov rcx,[nppHandle]
	call [SendMessageW]

	test [debugFlags],DEBUG_DOC
	jnz .doc_forward

	bts [debugFlags],BSF DEBUG_NEW_WAIT
	jc .doc_error ; this can't happen

	mov r9d,40000+1000+1 ; IDM_FILE_NEW, include 'menuCmdID.inc'
	xor r8,r8
	mov edx,NPPM_MENUCOMMAND
	mov rcx,[nppHandle]
	call [SendMessageW]
.doc_exists:
	leave
	retn
.doc_forward:
	; use id
	leave
	retn
.doc_error:
	int3


About:	enter 32,0
	invoke MessageBoxW,0,_about_text,_about_caption,MB_OK
	leave
	retn


;------------------------------------------------------------------------Lexers:

include 'lex_fasmg.inc'
;include 'lex_fasmg_x86.inc'
;include 'lex_fasmg_pp.inc'

;-------------------------------------------------------------Support Functions:

;?

SECTION '.data' DATA READABLE WRITEABLE

_about_caption:
PluginName du "fasmg tools",0
_about_text du "« This is simply a test. »",0




debugIndex	dd ? ; only valid if DEBUG_DOC
debugFlags	dd ?
	DEBUG_ACTIVE	= 1 ; capturing debug strings
	DEBUG_DOC	= 2 ; document id is valid
	DEBUG_NEW_WAIT	= 4 ; waiting on new document id


namespace Buffer
	address	dq Buffer
	bytes	dd sizeof Buffer
	index	dd 0
end namespace



;-------------------------------------------------------------Plugin definition:
align 64
FunctionTable: ; Define the plugin menu layout and functions:

	LogDebugStrings		funcItem	"Just a Test"
		_		funcItem
		_		funcItem
		_		funcItem
		_		funcItem
	About			funcItem	"About"

nbFunc = ($-FunctionTable)/funcItem.bytes


;-----------------------------------------------------------------Required Data:
match LEXERS,LEXERS
align 64
LexerStatuses:	iterate L LEXERS
			du L#.Status
			align 64
		end iterate
align 16
LexerNames:	iterate L LEXERS
			db L#.Name
			align 16
		end iterate
align 8
LexerVTables:	iterate L LEXERS
			L ILexer4
		end iterate
end match


hInstance rq 1
nppHandle rq 1
scintillaMainHandle rq 1
scintillaSecondHandle rq 1

; direct pointer interface:
CallScintilla	rq 1
.windows	rq 2 ; npp currently only has two Scintilla windows


align 64
label Buffer:(1 shl 16)
rb sizeof Buffer


SECTION '.idata' IMPORT DATA READABLE WRITEABLE
library	kernel32,'KERNEL32.DLL',\
	user32,'USER32.DLL'

	include 'api\kernel32.inc'
	include 'api\user32.inc'