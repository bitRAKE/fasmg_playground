format binary as 'obj'
COFF.Settings.Machine = IMAGE_FILE_MACHINE_AMD64
COFF.Settings.Characteristics = IMAGE_FILE_32BIT_MACHINE or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_BYTES_REVERSED_LO
include 'format/coffms.inc'
include 'cpu/x64.inc'
use64

macro public it*
	match A:,it
		public A
		A:
	else
		public it
	end match
end macro

include '.\frame.g'
include '.\safe_frame.g'

define WNDPROC hWnd:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD
define SUBCLASSPROC hWnd:QWORD,uMsg:QWORD,wParam:QWORD,lParam:QWORD,uIdSubclass:QWORD,dwRefData:QWORD

iterate <type,R>,BYTE,rb,WORD,rw,DWORD,rd,QWORD,rq
struc type
	. R 1
end struc
end iterate

;struc Δ txt&
;	label . : .#_end - .
;	txt
;	.#_end:
;end struc

; sizeof label set to size of data
calminstruction (N) Δ txt&
	local cmd
	arrange cmd, =label N : N#=_bytes
	assemble cmd
	assemble txt
	arrange cmd, N#=_bytes == =$ - N
	assemble cmd
end calminstruction


iterate inst,call,jmp
macro inst? function*,params&
	match dll:fun,function
		namespace COFF
			; TODO: check for ordinal
			define __DEFAULTLIB dll
			dll#.use = 0
			define __EXTRN fun
			fun#.use = 0
		end namespace
		FRAME.PARAMS params
		inst [fun]
	else match ,params
		inst function
	else
		FRAME.PARAMS params
		inst function
	end match
end macro
end iterate

postpone
namespace COFF
irpv ext,__EXTRN
	if ~ ext#.use
		end namespace
		eval 'extrn "__imp_',`ext,'" as ',`ext,':QWORD'
		namespace COFF
		ext#.use = 1
	end if
end irpv

section '.drectve' linkinfo linkremove
irpv lib,__DEFAULTLIB
	if ~ lib#.use
		; include API definitions
		db '/DEFAULTLIB:',`lib,'.LIB '
		lib#.use = 1
	end if
end irpv
end namespace
end postpone

include 'encoding\utf8.inc'
include 'macro\@@.inc'
