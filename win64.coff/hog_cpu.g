; coding: utf-8, tab: 8
include './.win64/coffms64.g'

; some constants
include './.win64/equates/kernel64.inc'
include './.win64/equates/wincon.inc'
include './.win64/equates/user64.inc'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" /STACK:0,0 /HEAP:0,0 '



section '.data' data readable writeable align 8
notice Δ TCHAR \
13,10,	"This program is for testing purposes only.",\
13,10,	"It is designed to consume all available CPU cycles.",\
13,10,\
13,10,	"IT WILL RENDER YOUR SYSTEM UNRESPONSIVE!",\
13,10,\
13,10,	"Press the '+' on keypad to continue, or any other key to exit.",\
13,10,0

working Δ TCHAR 13,10,"Working... (please wait)",0
error_priority Δ TCHAR 13,10,"Error: Failed to raise to process priority.",0



section '.flat' code readable executable align 64

define TOTAL_COUNT 100_000_000_000

; Some busy work to consume cycles ...
align 64
MyWorkerThread:
	mov rcx,TOTAL_COUNT
.A:	movzx eax,cl			; [ 0,  255]
	not rax				; [-1, -256]
	mov [rsp+rax*8],rcx		; use 2k below stack pointer
	loop .A
	xchg eax,ecx
	retn


MAX_THREADS := 256

public mainCRTStartup:
assert MAX_THREADS*8 < 4096+8 ; 64k is minimum stack
sub rsp,MAX_THREADS*8
frame.enter ,<			\
	hConOut:QWORD,		\
	hConIn:QWORD,		\
	SystemInfo:SYSTEM_INFO,	\
	ThreadId:DWORD		> ; scratch space

	define .handles rbp ; the stack space was made above

	; scare the user and then give them a choice ;)

	call KERNEL32:GetStdHandle, STD_OUTPUT_HANDLE
	mov [hConOut],rax
	call KERNEL32:WriteConsoleW,[hConOut],\
		ADDR notice,(sizeof notice-1)shr 1,0,0
	call KERNEL32:GetStdHandle, STD_INPUT_HANDLE
	mov [hConIn],rax
	call KERNEL32:FlushConsoleInputBuffer,rax

	; just makes things easier
	virtual at notice
		.inRec INPUT_RECORD
	end virtual
@@:	call KERNEL32:ReadConsoleInputW,[hConIn],ADDR .inRec,1,ADDR ThreadId
	test eax,eax
	jz .not_any_thread
	cmp [.inRec.EventType],KEY_EVENT
	jnz @B
	cmp [.inRec.KeyEvent.bKeyDown],0 ; wait until key released
	jnz @B
	cmp [.inRec.KeyEvent.wVirtualKeyCode],VK_ADD
	jnz .not_any_thread

	call KERNEL32:WriteConsoleW,[hConOut],\
		ADDR working,(sizeof working-1)shr 1,0,0

; flush console buffer so user gets to see message :P
;	call KERNEL32:FlushConsoleInputBuffer,[hConIn]
	call KERNEL32:Sleep,1

	call KERNEL32:GetCurrentProcess
	xchg rcx,rax
	call KERNEL32:SetPriorityClass,rcx,REALTIME_PRIORITY_CLASS
	test eax,eax
	jnz .spin_up
	call KERNEL32:WriteConsoleW,[hConOut],\
		ADDR error_priority,(sizeof error_priority-1)shr 1,0,0
	jmp .not_any_thread

.spin_up:	; create an array of handles
	call KERNEL32:GetSystemInfo, ADDR SystemInfo
	cmp [SystemInfo.dwNumberOfProcessors],MAX_THREADS
	jbe @F
	mov [SystemInfo.dwNumberOfProcessors],MAX_THREADS
@@:	xor ebx,ebx ;  0 -> upwards, so we know how many at the end
.more_threads:
	call KERNEL32:CreateThread,0,0,ADDR MyWorkerThread,rbx,CREATE_SUSPENDED,ADDR ThreadId
	mov [.handles+rbx*8],rax
	xchg rcx,rax
	jrcxz .no_thread
	call KERNEL32:SetThreadPriority,[.handles+rbx*8],THREAD_PRIORITY_TIME_CRITICAL
	call KERNEL32:ResumeThread,[.handles+rbx*8]
	add ebx,1
	cmp [SystemInfo.dwNumberOfProcessors],ebx
	jnz .more_threads
.no_thread:
	xchg ecx,ebx
	jrcxz .not_any_thread
	call KERNEL32:WaitForMultipleObjects,rcx,ADDR .handles,TRUE,-1 ; INFINITE
.not_any_thread:
	call KERNEL32:ExitProcess,0

frame.leave
int3
