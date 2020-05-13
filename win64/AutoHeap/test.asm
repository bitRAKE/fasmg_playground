INCLUDE 'win64a.inc'
FORMAT PE64 CONSOLE 6.2 at $10000 on "NUL"
SECTION '.FLAT' CODE READABLE WRITEABLE EXECUTABLE

include 'x64help.inc'
include 'freelist.inc'
include 'doublelist.inc'
include 'exception.inc'
include 'autoheaps.inc'

; global - all AutoHeaps use same VEH, and system parameters
align 64
AutoHeaps:
	; sentinal node of double list
	.root DOUBLELIST AutoHeaps.root,AutoHeaps.root

	.Granularity	rd 1
	.PageBytes	rd 1

	.hGuardVEH	rq 1
	.heaps 		dq -1 ; bit pattern of heap availiblity
	rb 64 * AutoHeap.bytes ; overkill

ENTRY $ ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY
__TRY:
VIRTUAL AT RBP-.FRAME
	rq 4 ; shadow forward
.pSI	SYSTEM_INFO
	rb (16-(($-$$) AND 15)) AND 15 ; only if padding needed
.FRAME := $-$$
END VIRTUAL

	lea rcx,[.pSI]
	call [GetSystemInfo]
	mov ecx,[.pSI.dwAllocationGranularity]
	mov eax,[.pSI.dwPageSize]
	mov [AutoHeaps.Granularity],ecx
	mov [AutoHeaps.PageBytes],eax



;	reserve,commit,FreeList__PageInit
	call AutoHeap__Create
	call AutoHeap__Destroy





	call [exit]
	int3



msvcrt_name db 'msvcrt',0
_exit db 0,0,'exit',0
__printf_p db 0,0,'_printf_p',0
ALIGN 8
msvcrt_table:
	exit dq RVA _exit
	_printf_p dq RVA __printf_p
	dq ?
ALIGN 8
DATA IMPORT
dd ?,?,?,RVA msvcrt_name,RVA msvcrt_table
dd ?,?,?,?,?
END DATA