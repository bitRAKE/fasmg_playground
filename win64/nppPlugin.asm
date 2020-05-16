INCLUDE 'win64w.inc'
FORMAT PE64 GUI 5.0 DLL AT 0
SECTION '.text' CODE READABLE EXECUTABLE

; BOOL APIENTRY DllMain(HANDLE hModule, DWORD reasonForCall, LPVOID);
DllMain: ENTRY $
	cmp edx,DLL_PROCESS_ATTACH
	jnz .x
	mov [hInstance],rcx

	; dynamic setup

.x:	push 1
	pop rax
	retn


; REFERENCES:
;	Although these files are in the plugin kit, main is most recent:
;	https://github.com/notepad-plus-plus/notepad-plus-plus/
;		/PowerEditor/src/menuCmdID.h
;		/PowerEditor/src/MISC/PluginsManager/Notepad_plus_msgs.h
;		/scintilla/include/Scintilla.h
;	etc.

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
	retn


beNotified: ; void beNotified(SCNotification *notifyCode)
	retn


messageProc: ; LRESULT messageProc(UINT /*Message*/, WPARAM /*wParam*/, LPARAM /*lParam*/)
	retn


getFuncsArray: ; FuncItem * getFuncsArray(int *nbF)
	lea rax,[Functions]
	mov dword[rcx],nbFunc
	retn

;GetLexerCount:
;GetLexerName:
;GetLexerStatusText:


Name_A:
	retn


Name_B:
	retn


SECTION '.data' DATA READABLE WRITEABLE

PluginName du "TestPlugin",0

;nbChar = 64
;
;struc ShortcutKey
;	_isCtrl rb 1
;	_isAlt rb 1
;	_isShift rb 1
;	_key rb 1
;end struc

macro FuncItem text,func,id=0,chk=0,key=0
	local temp
temp	du text
	rw 64 - (($ - temp) shr 1)
	dq func ;
	dd id
	db chk,?,?,?
	if key=0
		dq 0
	else
		; point to ShortcutKey structure
	end if
end macro
FuncItem.bytes = 152 ; 128+8+4+4+8

align 64
Functions:
	FuncItem "Name A",	Name_A
	FuncItem "-SEPARATOR-",	0
	FuncItem "Name B",	Name_B
nbFunc = ($-Functions)/FuncItem.bytes



hInstance rq 1
nppHandle rq 1
scintillaMainHandle rq 1
scintillaSecondHandle rq 1



;SECTION '.idata' IMPORT DATA READABLE WRITEABLE

;  library kernel32,'KERNEL32.DLL',\
;	  user32,'USER32.DLL'

;  include 'api\kernel32.inc'
;  include 'api\user32.inc'

SECTION '.edata' EXPORT DATA READABLE
export 'ghelper.dll',\
	beNotified	,"beNotified",\
	getFuncsArray	,"getFuncsArray",\
	getName		,"getName",\
	isUnicode	,"isUnicode",\
	messageProc	,"messageProc",\
	setInfo		,"setInfo"
;GetLexerCount		,"GetLexerCount",\
;GetLexerName		,"GetLexerName",\
;GetLexerStatusText	,"GetLexerStatusText"

SECTION '.reloc' FIXUPS DATA READABLE DISCARDABLE