
; WinUser.inc
; USER procedure declarations, constant definitions and macros

;include 'windef.g'


struct MSGBOXPARAMSW
cbSize			dd ?,?
hwndOwner		dq ?
hInstance		dq ?
lpszText		dq ?
lpszCaption		dq ?
dwStyle			dd ?,?
lpszIcon		dq ?
dwContextHelpId		dd ?,?
lpfnMsgBoxCallback	dq ?
dwLanguageId		dd ?,?
end struct



include 'WinUser.keyboard.g'
include 'WinUser.menu.g'




ENDSESSION_CLOSEAPP	=0x00000001
ENDSESSION_CRITICAL	=0x40000000
ENDSESSION_LOGOFF	=0x80000000



; ExitWindowsEx flags

EWX_LOGOFF		=0x00000000
EWX_SHUTDOWN		=0x00000001
EWX_REBOOT		=0x00000002
EWX_FORCE		=0x00000004
EWX_POWEROFF		=0x00000008
EWX_FORCEIFHUNG		=0x00000010
EWX_QUICKRESOLVE	=0x00000020
EWX_RESTARTAPPS		=0x00000040
EWX_HYBRID_SHUTDOWN	=0x00400000
EWX_BOOTOPTIONS		=0x01000000
EWX_ARSO		=0x04000000





;include 'WinUser.window.inc'

struct PAINTSTRUCT
  hdc	      dq ?
  fErase      dd ?
  rcPaint     RECT
  fRestore    dd ?
  fIncUpdate  dd ?
  rgbReserved db 36 dup (?)
end struct

; Window state messages

WM_STATE		  = 0000h
WM_NULL 		  = 0000h
WM_CREATE		  = 0001h
WM_DESTROY		  = 0002h
WM_MOVE 		  = 0003h
WM_SIZE 		  = 0005h
WM_ACTIVATE		  = 0006h
WM_SETFOCUS		  = 0007h
WM_KILLFOCUS		  = 0008h
WM_ENABLE		  = 000Ah
WM_SETREDRAW		  = 000Bh
WM_SETTEXT		  = 000Ch
WM_GETTEXT		  = 000Dh
WM_GETTEXTLENGTH	  = 000Eh
WM_PAINT		  = 000Fh
WM_CLOSE		  = 0010h
WM_QUERYENDSESSION	  = 0011h
WM_QUIT 		  = 0012h
WM_QUERYOPEN		  = 0013h
WM_ERASEBKGND		  = 0014h
WM_SYSCOLORCHANGE	  = 0015h
WM_ENDSESSION		  = 0016h
WM_SYSTEMERROR		  = 0017h
WM_SHOWWINDOW		  = 0018h
WM_CTLCOLOR		  = 0019h
WM_WININICHANGE 	  = 001Ah
WM_DEVMODECHANGE	  = 001Bh
WM_ACTIVATEAPP		  = 001Ch
WM_FONTCHANGE		  = 001Dh
WM_TIMECHANGE		  = 001Eh
WM_CANCELMODE		  = 001Fh
WM_SETCURSOR		  = 0020h
WM_MOUSEACTIVATE	  = 0021h
WM_CHILDACTIVATE	  = 0022h
WM_QUEUESYNC		  = 0023h
WM_GETMINMAXINFO	  = 0024h
WM_PAINTICON		  = 0026h
WM_ICONERASEBKGND	  = 0027h
WM_NEXTDLGCTL		  = 0028h
WM_SPOOLERSTATUS	  = 002Ah
WM_DRAWITEM		  = 002Bh
WM_MEASUREITEM		  = 002Ch
WM_DELETEITEM		  = 002Dh
WM_VKEYTOITEM		  = 002Eh
WM_CHARTOITEM		  = 002Fh
WM_SETFONT		  = 0030h
WM_GETFONT		  = 0031h
WM_SETHOTKEY		  = 0032h
WM_QUERYDRAGICON	  = 0037h
WM_COMPAREITEM		  = 0039h
WM_COMPACTING		  = 0041h
WM_COMMNOTIFY		  = 0044h
WM_WINDOWPOSCHANGING	  = 0046h
WM_WINDOWPOSCHANGED	  = 0047h
WM_POWER		  = 0048h
WM_COPYDATA		  = 004Ah
WM_CANCELJOURNAL	  = 004Bh
WM_NOTIFY		  = 004Eh
WM_INPUTLANGCHANGEREQUEST = 0050h
WM_INPUTLANGCHANGE	  = 0051h
WM_TCARD		  = 0052h
WM_HELP 		  = 0053h
WM_USERCHANGED		  = 0054h
WM_NOTIFYFORMAT 	  = 0055h
WM_CONTEXTMENU		  = 007Bh
WM_STYLECHANGING	  = 007Ch
WM_STYLECHANGED 	  = 007Dh
WM_DISPLAYCHANGE	  = 007Eh
WM_GETICON		  = 007Fh
WM_SETICON		  = 0080h
WM_NCCREATE		  = 0081h
WM_NCDESTROY		  = 0082h
WM_NCCALCSIZE		  = 0083h
WM_NCHITTEST		  = 0084h
WM_NCPAINT		  = 0085h
WM_NCACTIVATE		  = 0086h
WM_GETDLGCODE		  = 0087h
WM_NCMOUSEMOVE		  = 00A0h
WM_NCLBUTTONDOWN	  = 00A1h
WM_NCLBUTTONUP		  = 00A2h
WM_NCLBUTTONDBLCLK	  = 00A3h
WM_NCRBUTTONDOWN	  = 00A4h
WM_NCRBUTTONUP		  = 00A5h
WM_NCRBUTTONDBLCLK	  = 00A6h
WM_NCMBUTTONDOWN	  = 00A7h
WM_NCMBUTTONUP		  = 00A8h
WM_NCMBUTTONDBLCLK	  = 00A9h
WM_KEYFIRST		  = 0100h
WM_KEYDOWN		  = 0100h
WM_KEYUP		  = 0101h
WM_CHAR 		  = 0102h
WM_DEADCHAR		  = 0103h
WM_SYSKEYDOWN		  = 0104h
WM_SYSKEYUP		  = 0105h
WM_SYSCHAR		  = 0106h
WM_SYSDEADCHAR		  = 0107h
WM_KEYLAST		  = 0108h
WM_INITDIALOG		  = 0110h
WM_COMMAND		  = 0111h
WM_SYSCOMMAND		  = 0112h
WM_TIMER		  = 0113h
WM_HSCROLL		  = 0114h
WM_VSCROLL		  = 0115h
WM_INITMENU		  = 0116h
WM_INITMENUPOPUP	  = 0117h
WM_GESTURE		  = 0119h
WM_GESTURENOTIFY	  = 011Ah
WM_MENUSELECT		  = 011Fh
WM_MENUCHAR		  = 0120h
WM_ENTERIDLE		  = 0121h
WM_MENURBUTTONUP	  = 0122h
WM_MENUDRAG		  = 0123h
WM_MENUGETOBJECT	  = 0124h
WM_UNINITMENUPOPUP	  = 0125h
WM_MENUCOMMAND		  = 0126h
WM_CTLCOLORMSGBOX	  = 0132h
WM_CTLCOLOREDIT 	  = 0133h
WM_CTLCOLORLISTBOX	  = 0134h
WM_CTLCOLORBTN		  = 0135h
WM_CTLCOLORDLG		  = 0136h
WM_CTLCOLORSCROLLBAR	  = 0137h
WM_CTLCOLORSTATIC	  = 0138h
WM_MOUSEFIRST		  = 0200h
WM_MOUSEMOVE		  = 0200h
WM_LBUTTONDOWN		  = 0201h
WM_LBUTTONUP		  = 0202h
WM_LBUTTONDBLCLK	  = 0203h
WM_RBUTTONDOWN		  = 0204h
WM_RBUTTONUP		  = 0205h
WM_RBUTTONDBLCLK	  = 0206h
WM_MBUTTONDOWN		  = 0207h
WM_MBUTTONUP		  = 0208h
WM_MBUTTONDBLCLK	  = 0209h
WM_MOUSEWHEEL		  = 020Ah
WM_MOUSELAST		  = 020Ah
WM_PARENTNOTIFY 	  = 0210h
WM_ENTERMENULOOP	  = 0211h
WM_EXITMENULOOP 	  = 0212h
WM_NEXTMENU		  = 0213h
WM_SIZING		  = 0214h
WM_CAPTURECHANGED	  = 0215h
WM_MOVING		  = 0216h
WM_POWERBROADCAST	  = 0218h
WM_DEVICECHANGE 	  = 0219h
WM_MDICREATE		  = 0220h
WM_MDIDESTROY		  = 0221h
WM_MDIACTIVATE		  = 0222h
WM_MDIRESTORE		  = 0223h
WM_MDINEXT		  = 0224h
WM_MDIMAXIMIZE		  = 0225h
WM_MDITILE		  = 0226h
WM_MDICASCADE		  = 0227h
WM_MDIICONARRANGE	  = 0228h
WM_MDIGETACTIVE 	  = 0229h
WM_MDISETMENU		  = 0230h
WM_ENTERSIZEMOVE	  = 0231h
WM_EXITSIZEMOVE 	  = 0232h
WM_DROPFILES		  = 0233h
WM_MDIREFRESHMENU	  = 0234h
WM_IME_SETCONTEXT	  = 0281h
WM_IME_NOTIFY		  = 0282h
WM_IME_CONTROL		  = 0283h
WM_IME_COMPOSITIONFULL	  = 0284h
WM_IME_SELECT		  = 0285h
WM_IME_CHAR		  = 0286h
WM_IME_KEYDOWN		  = 0290h
WM_IME_KEYUP		  = 0291h
WM_MOUSEHOVER		  = 02A1h
WM_MOUSELEAVE		  = 02A3h
WM_CUT			  = 0300h
WM_COPY 		  = 0301h
WM_PASTE		  = 0302h
WM_CLEAR		  = 0303h
WM_UNDO 		  = 0304h
WM_RENDERFORMAT 	  = 0305h
WM_RENDERALLFORMATS	  = 0306h
WM_DESTROYCLIPBOARD	  = 0307h
WM_DRAWCLIPBOARD	  = 0308h
WM_PAINTCLIPBOARD	  = 0309h
WM_VSCROLLCLIPBOARD	  = 030Ah
WM_SIZECLIPBOARD	  = 030Bh
WM_ASKCBFORMATNAME	  = 030Ch
WM_CHANGECBCHAIN	  = 030Dh
WM_HSCROLLCLIPBOARD	  = 030Eh
WM_QUERYNEWPALETTE	  = 030Fh
WM_PALETTEISCHANGING	  = 0310h
WM_PALETTECHANGED	  = 0311h
WM_HOTKEY		  = 0312h
WM_PRINT		  = 0317h
WM_PRINTCLIENT		  = 0318h
WM_HANDHELDFIRST	  = 0358h
WM_HANDHELDLAST 	  = 035Fh
WM_AFXFIRST		  = 0360h
WM_AFXLAST		  = 037Fh
WM_PENWINFIRST		  = 0380h
WM_PENWINLAST		  = 038Fh
WM_COALESCE_FIRST	  = 0390h
WM_COALESCE_LAST	  = 039Fh
WM_USER 		  = 0400h

