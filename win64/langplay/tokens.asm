include 'winmore.inc'
PROC MainDlgProc hDlg,uMsg,wP,lP
LOCALS
	hCtl	rq 1
ENDL
	mov [hDlg],rcx
	mov [uMsg],rdx
	mov [wP],r8
	mov [lP],r9
	iterate message, WM_INITDIALOG,WM_CLOSE,WM_COMMAND,\
		WM_LBUTTONDOWN,WM_RBUTTONUP,WM_RBUTTONDOWN,WM_SETCURSOR,\
		WM_CTLCOLORDLG,WM_CTLCOLORSTATIC ;,WM_CTLCOLORBTN,WM_CTLCOLOREDIT
		cmp dx,message
		jz _#message
	end iterate
return_FALSE:
	xor eax,eax ; FALSE
	ret

_WM_INITDIALOG:
	invoke SendDlgItemMessageW,[hDlg],ID_EDIT_CODE,EM_SETBKGNDCOLOR,0,$D8A83D
	invoke SendDlgItemMessageW,[hDlg],ID_EDIT_TOKENS,EM_SETBKGNDCOLOR,0,$4D4B4A
return_TRUE:
	mov eax,1
	ret

;_WM_CTLCOLORBTN:
_WM_CTLCOLORDLG:
_WM_CTLCOLORSTATIC:
	invoke SetBkColor,[wP],$5E61D9
	invoke CreateSolidBrush,$5E61D9
	ret ; return the brush


_WM_RBUTTONDOWN: ; force cursor when mouse doesn't move
	mov eax,32648 ; IDC_NO
	jmp @F
_WM_SETCURSOR:
	cmp r8,rcx ; only if mouse is in dialog
	jnz return_FALSE
	cmp word [lP],1 ; HTCLIENT
	jnz return_FALSE
; if only right mouse button down IDC_NO else IDC_SIZEALL
	invoke GetKeyState,VK_RBUTTON
	bt eax,15
	sbb eax,eax
	and eax,2 ; IDC_NO - IDC_SIZEALL
	add eax,32646 ; IDC_SIZEALL
@@:	invoke LoadCursor,0,eax
	invoke SetCursor,rax
	jmp return_TRUE
_WM_LBUTTONDOWN:
; force cursor when mouse doesn't move
;	invoke LoadCursor,0,32646 ; IDC_SIZEALL
;	invoke SetCursor,rax
	invoke PostMessage,[hDlg],WM_NCLBUTTONDOWN,HTCAPTION,[lP]
	jmp return_TRUE
_WM_RBUTTONUP:
_WM_CLOSE: ; from taskbar, etc.
	invoke EndDialog,[hDlg],1
	jmp return_TRUE


_WM_COMMAND:
	cmp dword[wP],ID_EDIT_TOKENS or (0x100 shl 16) ; focus control?
	jnz return_FALSE
	invoke SendDlgItemMessageW,[hDlg],ID_EDIT_CODE,EM_GETTEXTLENGTHEX,ADDR gtlex,0
	test eax,eax ; bytes needed - not including null
	jz return_TRUE
	add eax,1 ; null termination is one byte for UTF8
	mov [gtex.cb],eax
	mov [input_bytes],rax
	invoke HeapAlloc,[hHeap],4,[input_bytes] ; HEAP_GENERATE_EXCEPTIONS
	mov [input_buffer],rax
	invoke SendDlgItemMessageW,[hDlg],ID_EDIT_CODE,EM_GETTEXTEX,ADDR gtex,[input_buffer]

	call Tokenizer

	mov rcx,[result_bytes]
	jrcxz @F
	mov rax,[result_buffer]
	mov byte[rax+rcx],0 ; insure string is null terminated for EM_SETTEXTEX
	invoke SendDlgItemMessageW,[hDlg],ID_EDIT_TOKENS,EM_SETTEXTEX,ADDR stex,[result_buffer]
@@:	invoke HeapFree,[hHeap],0,[result_buffer]
	invoke HeapFree,[hHeap],0,[input_buffer]
	jmp return_TRUE
ENDP



Why:	invoke InitCommonControlsEx,ADDR iccex
	invoke LoadLibraryA,_msftedit
	invoke GetModuleHandle,0
	mov [hInstance],rax
	invoke GetDesktopWindow
	mov [hWndDesktop],rax
	invoke GetProcessHeap
	mov [hHeap],rax
	invoke DialogBoxParamW,[hInstance],1,[hWndDesktop],ADDR MainDlgProc,0
	invoke ExitProcess,0
	int3


;     CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE CODE
display "Working on: ",PARSER
include PARSER ; set on commandline
;     DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA DATA


iccex dd 8,$8000FFFF ; 30 window classes registered

preferred_cursor dd 32646 ; IDC_SIZEALL to start
_msftedit db 'msftedit',0

gtlex GETTEXTLENGTHEX codepage:CP_UTF8,\
	flags:GTL_NUMBYTES or GTL_PRECISE

gtex GETTEXTEX codepage:CP_UTF8,\
	flags:GT_DEFAULT

stex SETTEXTEX codepage:CP_UTF8,\
	flags:ST_DEFAULT


align 64
hInstance	rq 1
hWndDesktop	rq 1
hHeap		rq 1

input_bytes	rq 1
input_buffer	rq 1

result_bytes	rq 1
result_buffer	rq 1



SECTION '.rsrc' RESOURCE DATA READABLE

ID_EDIT_CODE	= $100
ID_EDIT_TOKENS	= $101

directory	RT_DIALOG,	dialogs,\
		RT_MANIFEST,	manifests

resource dialogs,1,LANG_ENGLISH+SUBLANG_DEFAULT,grapejelly
resource manifests,1,LANG_NEUTRAL,manifest

dialog grapejelly,'',0,0,400,200,\
	DS_CENTER or DS_SETFONT or WS_VISIBLE or WS_POPUP,\
	0,0,"Consolas",12
dialogitem 'STATIC','Source Code:',-1,4,2,180,10,WS_VISIBLE+SS_LEFT
dialogitem 'STATIC','Parsed Tokens:',-1,206,2,180,10,WS_VISIBLE+SS_LEFT
dialogitem 'RICHEDIT50W','',ID_EDIT_CODE,4,12,190,184,\
	WS_VISIBLE or WS_VSCROLL or WS_HSCROLL\
	or ES_MULTILINE or ES_NOHIDESEL or ES_WANTRETURN or ES_AUTOHSCROLL
dialogitem 'RICHEDIT50W','<click here to update>',ID_EDIT_TOKENS,206,12,190,184,\
	WS_VISIBLE or WS_VSCROLL or WS_HSCROLL\
	or ES_READONLY\
	or ES_MULTILINE or ES_NOHIDESEL or ES_WANTRETURN or ES_AUTOHSCROLL
enddialog


resdata manifest
db '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>'
db '<assembly xmlns="urn:schemas-microsoft-com:asm.v1" manifestVersion="1.0">'
db '<dependency>'
db	'<dependentAssembly>'
db		'<assemblyIdentity '
db			'type="win32" '
db			'name="Microsoft.Windows.Common-Controls" '
db			'version="6.0.0.0" '
db			'processorArchitecture="*" '
db			'publicKeyToken="6595b64144ccf1df" '
db			'language="*" '
db		'/>'
db	'</dependentAssembly>'
db '</dependency>'
db '</assembly>'
endres
.end Why ; this is where the magic happens

; Cambria font has wristwatch icon 0x231A, for timing button ⌚
; 0x23F0-3 are also clocks




