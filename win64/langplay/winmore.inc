format PE64 GUI 6.2
heap 1 shl 20,1 shl 30 ; commit meg, reserve gig
include 'win64wxp.inc'

; bitRAKE, things not present in base fasmg package

struc Δ txt& ; give a label the sizeof its data, and not the sizeof its data type
	label . : .#_end - .
	txt
	.#_end:
end struc

HTCAPTION = 2

EM_SETBKGNDCOLOR	= WM_USER+67
EM_GETTEXTEX		= WM_USER+94
EM_GETTEXTLENGTHEX	= WM_USER+95
EM_SETTEXTEX		= WM_USER+97

GT_DEFAULT	= 0
GT_USECRLF	= 1
GT_SELECTION	= 2
GT_RAWTEXT	= 4
GT_NOHIDDENTEXT	= 8

ST_DEFAULT	= 0
ST_KEEPUNDO	= 1
ST_SELECTION	= 2
ST_NEWCHARS	= 4
ST_UNICODE	= 8

GTL_DEFAULT	= 0
GTL_USECRLF	= 1
GTL_PRECISE	= 2
GTL_CLOSE	= 4
GTL_NUMCHARS	= 8
GTL_NUMBYTES	= 16


struct GETTEXTLENGTHEX
	flags		dd ?
	codepage	dd ?
ends

struct SETTEXTEX
	flags		dd ?
	codepage	dd ?
ends

struct GETTEXTEX
	cb		dd ?
	flags		dd ?
	codepage	dd ?
	lpDefaultChar	dq ?
	lpUsedDefChar	dq ?
ends

.code ; jump right to it ...