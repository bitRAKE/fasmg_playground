include 'format\format.inc'
include 'macro\@@.inc'
FORMAT MS64 COFF

;Public Interface ##############################################################

public PROP_COLOR_LINK		as "HYPERLINK_PROP_COLOR_LINK"
public PROP_FONT_ORIGINAL	as "HYPERLINK_PROP_FONT_ORIGINAL"
public PROP_FONT_UNDERLINE	as "HYPERLINK_PROP_FONT_UNDERLINE"

public ConvertStaticToHyperlink

;############################################################## Public Interface
; Paste into modules using this interface:
;
;	extrn HYPERLINK_PROP_COLOR_LINK
;	extrn HYPERLINK_PROP_FONT_ORIGINAL
;	extrn HYPERLINK_PROP_FONT_UNDERLINE
;
;	extrn ConvertStaticToHyperlink
;
;############################################################## Public Interface

FALSE	= 0
TRUE	= 1


; COMCTL32
extrn '__imp_DefSubclassProc'		as DefSubclassProc:QWORD
extrn '__imp_GetWindowSubclass'		as GetWindowSubclass:QWORD
extrn '__imp_RemoveWindowSubclass'	as RemoveWindowSubclass:QWORD
extrn '__imp_SetWindowSubclass'		as SetWindowSubclass:QWORD


; GDI32
extrn '__imp_CreateFontIndirectW'	as CreateFontIndirectW:QWORD
extrn '__imp_DeleteObject'		as DeleteObject:QWORD
extrn '__imp_GetObjectW'		as GetObjectW:QWORD
extrn '__imp_SetTextColor'		as SetTextColor:QWORD

struc LOGFONTW
	label .:..
	.lfHeight		rd 1
	.lfWidth		rd 1
	.lfEscapement		rd 1
	.lfOrientation		rd 1
	.lfWeight		rd 1
	.lfItalic		rb 1
	.lfUnderline		rb 1
	.lfStrikeOut		rb 1
	.lfCharSet		rb 1
	.lfOutPrecision		rb 1
	.lfClipPrecision	rb 1
	.lfQuality		rb 1
	.lfPitchAndFamily	rb 1
	.lfFaceName		rw 32
	.. = $ - .
end struc



; USER32
extrn '__imp_ClientToScreen'	as ClientToScreen:QWORD
extrn '__imp_GetDlgItem'	as GetDlgItem:QWORD
extrn '__imp_GetWindowRect'	as GetWindowRect:QWORD
extrn '__imp_PtInRect'		as PtInRect:QWORD
extrn '__imp_SendMessageW'	as SendMessageW:QWORD

extrn '__imp_GetPropA'		as GetPropA:QWORD
extrn '__imp_SetPropA'		as SetPropA:QWORD
extrn '__imp_RemovePropA'	as RemovePropA:QWORD

extrn '__imp_GetCapture'	as GetCapture:QWORD
extrn '__imp_SetCapture'	as SetCapture:QWORD
extrn '__imp_ReleaseCapture'	as ReleaseCapture:QWORD

extrn '__imp_LoadCursorW'	as LoadCursorW:QWORD
extrn '__imp_SetCursor'		as SetCursor:QWORD


WM_DESTROY		  = 0002h
WM_SETCURSOR		  = 0020h
WM_SETFONT		  = 0030h
WM_GETFONT		  = 0031h
WM_CTLCOLORSTATIC	  = 0138h
WM_MOUSEMOVE		  = 0200h

IDC_HAND	= 32649

struc POINT
	.:
	.x rd 1
	.y rd 1
	.. = $ - .
end struc
struc RECT
	.:
	.left	rd 1
	.top	rd 1
	.right	rd 1
	.bottom	rd 1
	.. = $ - .
end struc



section '.drectve' linkinfo linkremove
	db "/DEFAULTLIB:GDI32.LIB "
	db "/DEFAULTLIB:USER32.LIB "
	db "/DEFAULTLIB:COMCTL32.LIB "


section '$zzzz' data readable align 1

	PROP_COLOR_LINK		db '_Hyperlink_Link_Color_',0
	PROP_FONT_ORIGINAL	db '_Hyperlink_Original_Font_',0
	PROP_FONT_UNDERLINE	db '_Hyperlink_Underline_Font_',0


section '$' code readable executable align 64

;SUBCLASSPROC
;	hWnd		rcx
;	uMsg		rdx
;	wParam		r8
;	lParam		r9
;	uIdSubclass	[rsp+32]
;	dwRefData	[rsp+40]
HyperlinkParentProc:
	cmp edx,WM_DESTROY
	je .WM_DESTROY
	cmp edx,WM_CTLCOLORSTATIC
	je .WM_CTLCOLORSTATIC
	jmp [DefSubclassProc]


	.WM_DESTROY:
		push r9 r8 rdx rcx
		enter 32,0
			; RCX hWnd
			lea rdx,[HyperlinkParentProc] ; r11
			mov r8,[rbp+8*10] ; uIdSubclass
			call [RemoveWindowSubclass]
		leave
		pop rcx rdx r8 r9
		jmp [DefSubclassProc]


	.WM_CTLCOLORSTATIC:
		push r8			; hDC
		push r9			; hStatic
		enter 32,0		; shadow space, align stack
		call [DefSubclassProc]

		; if static control lacks link color property
		; then just return default result
		mov rcx,[rbp+8*1]	; lParam, handle of static control
		mov [rbp+8*1],rax	; save WndProc return
		mov rdx,[rbp+8*9]	; dwRefData, link color property name
		call [GetPropA]
		xchg rax,rcx
		jrcxz @F		; NOTE: black must have high bit set!

		mov edx,ecx		; hyperlink color
		mov rcx,[rbp+8*2]	; hDC from WM_CTLCOLORSTATIC message
		call [SetTextColor]
	@@:	leave
		pop rax
		pop rcx
		retn




	align 64
;SUBCLASSPROC
;	hWnd		rcx
;	uMsg		rdx
;	wParam		r8
;	lParam		r9
;	uIdSubclass	[rsp+40]
;	dwRefData	[rsp+48]
HyperlinkProc:
	cmp edx,WM_MOUSEMOVE
	je .WM_MOUSEMOVE
	cmp edx,WM_SETCURSOR
	je .WM_SETCURSOR
	cmp edx,WM_DESTROY
	je .WM_DESTROY
	jmp [DefSubclassProc]


	.WM_SETCURSOR:
		enter 32,0
		call [DefSubclassProc]
		mov [rbp+8*2],rax		; return result

		xor ecx,ecx
		mov edx,IDC_HAND
		call [LoadCursorW]
		xchg rcx,rax
		call [SetCursor]

		mov rax,[rbp+8*2]		; return result
		leave
		retn


	.WM_DESTROY:
		push r9 r8 rdx rcx
		enter 32,0

;		mov rcx,[rbp+8*1]	; handle of static control
		lea rdx,[HyperlinkProc] ; r11
		mov r8,[rbp+8*10]	; uIdSubclass
		call [RemoveWindowSubclass]

		mov rcx,[rbp+8*1]	; handle of static control
		lea rdx,[PROP_COLOR_LINK]
		call [RemovePropA]

		mov rcx,[rbp+8*1]	; handle of static control
		mov rdx,[rbp+8*10]	; original hFont
		call [RemovePropA]
		mov rcx,[rbp+8*1]	; hStatic, hWnd
		mov edx,WM_SETFONT	;
		xchg r8,rax		; old hFont
		xor r9,r9		; don't redraw control
		call [SendMessageW]

		mov rcx,[rbp+8*1]	; handle of static control
		mov rdx,[rbp+8*11]	; underline hFont
		call [RemovePropA]
		xchg rcx,rax		; hFont underline
		call [DeleteObject]

		leave
		pop rcx rdx r8 r9
		jmp [DefSubclassProc]


	.WM_MOUSEMOVE:
		push r9 r8 rdx rcx
		enter .frame,0
		virtual at rbp-.frame
				rq 4 ; maximum parameters
			.rt RECT
			.pt POINT
			.frame = NOT 15 AND ($-$$+15)
					rb $$+.frame-$ ; stack alignment
			.RBP		rq 1
			.hWnd		rq 1
			.uMsg		rq 1
			.wParam		rq 1
			.lParam		rq 1

			.RET		rq 1
					rq 4
			.original	rq 1	; uIdSubclass
			.underline	rq 1	; dwRefData
		end virtual

		call [GetCapture]
		cmp rax,[.hWnd]
		jne .start_capture

		xchg rcx,rax		; hWnd
		lea rdx,[.rt]		; lpRECT
		call [GetWindowRect]

		mov rcx,[.hWnd]		; hWnd
		lea rdx,[.rt]		; lpPOINT
		call [ClientToScreen]

		lea rcx,[.rt]		; lpRECT
		mov rdx,[.rt]		; POINT structure
		call [PtInRect]
		xchg rax,rcx
		jrcxz .outside

	@@:	leave
		pop rcx rdx r8 r9
		jmp [DefSubclassProc]

	.outside:
		mov rcx,[.hWnd]		; handle of static control
		mov rdx,[.original]	; original font
		call [GetPropA]		;

		mov rcx,[.hWnd]		; hWnd, static control
		mov edx,WM_SETFONT	;
		xchg r8,rax		; hFont, original
		push TRUE
		pop r9			; bRedraw
		call [SendMessageW]

		call [ReleaseCapture]
		jmp @B

	.start_capture:
		mov rcx,[.hWnd]		; hWnd, static control
		mov rdx,[.underline]	; underline font
		call [GetPropA]		;

		mov rcx,[.hWnd]		; hWnd, static control
		mov edx,WM_SETFONT	;
		xchg r8,rax		; hFont, underline
		push TRUE
		pop r9			; bRedraw
		call [SendMessageW]

		mov rcx,[.hWnd]
		call [SetCapture]
		jmp @B



ConvertStaticToHyperlink:
	; custom local frame and parent frame
	virtual at rsp
		rq 4		; parameter shadow space

		.lf LOGFONTW

		; size of local frame, insuring alignment is maintained
		.frame = NOT 15 AND ($-$$+15)
		rb .frame - ($-$$)

		; saved registers
		.rbx	rq 1
		.rbp	rq 1

		; aligned entry state
		.ret1	rq 1
		.ret0	rq 1
		; ...WndProc parameter shadow space...
	end virtual

	push rbp rbx
	mov rbp,rcx			; preserve hParent
	sub rsp,.frame

	; Get handle of control from parent handle and child id.
	; RCX is hParent
	; RDX is idChild
	call [GetDlgItem]
	xchg rbx,rax			; hChild used throughout

; Subclass the parent to capture WM_CTLCOLORSTATIC messages

	mov rcx,rbp			; hParent
	lea rdx,[HyperlinkParentProc]
	lea r8,[PROP_FONT_ORIGINAL]	; uIdSubclass
	lea r9,[PROP_COLOR_LINK]	; dwRefData
	call [SetWindowSubclass]	;

	mov rcx,rbx			; hChild
	mov edx,WM_GETFONT
	xor r8,r8
	xor r9,r9
	call [SendMessageW]
	xchg rbp,rax			; hFont (hParent no longer needed)

	; save original font handle as property of child control
	mov rcx,rbx			; hChild
	lea rdx,[PROP_FONT_ORIGINAL]	;
	mov r8,rbp			; hFont, original
	call [SetPropA]			;

	mov rcx,rbp			; hFont, original
	mov edx,sizeof .lf		;sizeof.LOGFONT		;
	lea r8,[.lf]			; LOGFONT structure
	call [GetObjectW]		;

	; Create an updated font by adding an underline
	mov [.lf.lfUnderline],TRUE
	lea rcx,[.lf]			; LOGFONT structure
	call [CreateFontIndirectW]

	; save underline font as property of child control
	mov rcx,rbx			; hChild
	lea rdx,[PROP_FONT_UNDERLINE]	;
	xchg r8,rax			; hFont, underline
	call [SetPropA]

	; set default link color
	mov rcx,rbx			; hChild
	lea rdx,[PROP_COLOR_LINK]	;
	mov r8d,$FF0000			; RGB
	call [SetPropA]

; Subclass the child to recieve mouse changes

	mov rcx,rbx			; hChild
	lea rdx,[HyperlinkProc]
	lea r8,[PROP_FONT_ORIGINAL]	; uIdSubclass
	lea r9,[PROP_FONT_UNDERLINE]	; dwRefData
	call [SetWindowSubclass]	;

	add rsp,.frame
	pop rbx rbp
	retn
