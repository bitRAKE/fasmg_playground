include '..\.win64\coff.g'

;Public Interface ##############################################################

public PROP_COLOR_LINK		as "HYPERLINK_PROP_COLOR_LINK"
public PROP_FONT_ORIGINAL	as "HYPERLINK_PROP_FONT_ORIGINAL"
public PROP_FONT_UNDERLINE	as "HYPERLINK_PROP_FONT_UNDERLINE"

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

struct LOGFONTW
	lfHeight		rd 1
	lfWidth			rd 1
	lfEscapement		rd 1
	lfOrientation		rd 1
	lfWeight		rd 1
	lfItalic		rb 1
	lfUnderline		rb 1
	lfStrikeOut		rb 1
	lfCharSet		rb 1
	lfOutPrecision		rb 1
	lfClipPrecision		rb 1
	lfQuality		rb 1
	lfPitchAndFamily	rb 1
	lfFaceName		rw 32
end struct


WM_DESTROY		  = 0002h
WM_SETCURSOR		  = 0020h
WM_SETFONT		  = 0030h
WM_GETFONT		  = 0031h
WM_CTLCOLORSTATIC	  = 0138h
WM_MOUSEMOVE		  = 0200h

IDC_HAND	= 32649

struct POINT
	x rd 1
	y rd 1
end struct

struct RECT
	left	rd 1
	top	rd 1
	right	rd 1
	bottom	rd 1
end struct


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
;	uIdSubclass	[rsp+32]	PROP_FONT_ORIGINAL
;	dwRefData	[rsp+40]	PROP_COLOR_LINK
HyperlinkParentProc:
namespace HyperlinkParentProc

	iterate msg, WM_DESTROY,WM_CTLCOLORSTATIC
		cmp edx,msg
		jz _#msg
	end iterate
	jmp COMCTL32:DefSubclassProc


_WM_DESTROY:
	safeframe.enter SUBCLASSPROC
	call COMCTL32:RemoveWindowSubclass,rcx,ADDR HyperlinkParentProc,[uIdSubclass]
	safeframe.leave
	jmp COMCTL32:DefSubclassProc


_WM_CTLCOLORSTATIC: ; hDC, hWndCtrl
	safeframe.enter SUBCLASSPROC,<result:QWORD>
	call COMCTL32:DefSubclassProc ;,[hWnd],[uMsg],[wParam],[lParam]
	mov [result],rax ; save result
	; lParam	handle of static control
	; dwRefData	link color property name
	call USER32:GetPropA,[lParam],[dwRefData]
	; NOTE: black color would be a problem
	xchg rax,rcx
	jrcxz @F
	call GDI32:SetTextColor,[wParam],rcx
@@:	mov rax,[result] ; hBrush for background painting
	safeframe.leave
	retn
end namespace



	align 64
;SUBCLASSPROC
;	hWnd		rcx
;	uMsg		rdx
;	wParam		r8
;	lParam		r9
;	uIdSubclass	[rsp+40]	PROP_FONT_ORIGINAL
;	dwRefData	[rsp+48]	PROP_FONT_UNDERLINE
HyperlinkProc:
namespace HyperlinkProc
	iterate msg, WM_MOUSEMOVE,WM_SETCURSOR,WM_DESTROY
		cmp edx,msg
		jz _#msg
	end iterate
	jmp COMCTL32:DefSubclassProc


_WM_SETCURSOR:
; TODO: regular frame is fine
	safeframe.enter SUBCLASSPROC,<result:QWORD>
	call COMCTL32:DefSubclassProc ;,[hWnd],[uMsg],[wParam],[lParam]
	mov [result],rax
	call USER32:LoadCursorW,0,IDC_HAND
	call USER32:SetCursor,rax
	mov rax,[result]
	safeframe.leave
	retn


_WM_DESTROY:
	safeframe.enter SUBCLASSPROC
	call COMCTL32:RemoveWindowSubclass,[hWnd],ADDR HyperlinkProc,[uIdSubclass]
	call USER32:RemovePropA,[hWnd],ADDR PROP_COLOR_LINK
	call USER32:RemovePropA,[hWnd],[uIdSubclass]
	call USER32:SendMessageW,[hWnd],WM_SETFONT,rax,0
	call USER32:RemovePropA,[hWnd],[dwRefData]
	call GDI32:DeleteObject,rax ; hFont underline
	safeframe.leave
	jmp COMCTL32:DefSubclassProc


_WM_MOUSEMOVE:
	safeframe.enter SUBCLASSPROC,<rt:RECT,pt:POINT>
	call USER32:GetCapture
	cmp rax,[hWnd]
	jz .use_capture
	call USER32:GetPropA,[hWnd],ADDR PROP_FONT_UNDERLINE
	call USER32:SendMessageW,[hWnd],WM_SETFONT,rax,1
	call USER32:SetCapture,[hWnd]
	jmp @F

.outside:
	call USER32:GetPropA,[hWnd],ADDR PROP_FONT_ORIGINAL
	call USER32:SendMessageW,[hWnd],WM_SETFONT,rax,1
	call USER32:ReleaseCapture
	jmp @F

.use_capture:
	call USER32:GetWindowRect,[hWnd],ADDR rt
	movsx eax,word[lParam+2]
	movsx edx,word[lParam]
	mov [pt.y],eax
	mov [pt.x],edx
	call USER32:ClientToScreen,[hWnd],ADDR pt
	call USER32:PtInRect,ADDR rt,qword [pt]
	xchg rax,rcx
	jrcxz .outside

@@:	safeframe.leave
	jmp COMCTL32:DefSubclassProc

end namespace



define DUMMYPROTO hParent:QWORD,idCtrl:QWORD

public ConvertStaticToHyperlink:
namespace ConvertStaticToHyperlink
	safeframe.enter DUMMYPROTO,<hCtrl:QWORD,hFont:QWORD,lf:LOGFONTW>
	call USER32:GetDlgItem ;,rcx,rdx
	mov [hCtrl],rax

	; Subclass the parent to capture WM_CTLCOLORSTATIC messages
	call COMCTL32:SetWindowSubclass,[hParent],ADDR HyperlinkParentProc,\
		ADDR PROP_FONT_ORIGINAL,ADDR PROP_COLOR_LINK

	call USER32:SendMessageW,[hCtrl],WM_GETFONT,0,0
	mov [hFont],rax
	call USER32:SetPropA,[hCtrl],ADDR PROP_FONT_ORIGINAL,[hFont]
	call GDI32:GetObjectW,[hFont],sizeof lf,ADDR lf
	mov [lf.lfUnderline],TRUE
	call GDI32:CreateFontIndirectW,ADDR lf
	call USER32:SetPropA,[hCtrl],ADDR PROP_FONT_UNDERLINE,rax ; hNewFont
	call USER32:SetPropA,[hCtrl],ADDR PROP_COLOR_LINK,$FF0000 ; bluiest

	; Subclass the child to recieve mouse changes
	call COMCTL32:SetWindowSubclass,[hCtrl],ADDR HyperlinkProc,\
		ADDR PROP_FONT_ORIGINAL,ADDR PROP_FONT_UNDERLINE

	safeframe.leave
	retn
end namespace
