; coding: utf-8, tab: 8
include './.win64/coffms64.g'

; This program is based on the following thread:
;	https://board.flatassembler.net/topic.php?p=216213#216213
;
; Basically, we are testing for cases where CMPSB reads different values for
; the same memory address. This means the processor allows a store between
; the two reads of a string instruction.
;
; It's important that these threads be THREAD_PRIORITY_TIME_CRITICAL in order
; to not have the scheduler interfere. Yet, if __BATCH__ = 0, all the threads
; will line up and cause the WORST case -- your machine might freeze for a
; very long time.
;
; Amazingly, the batch mode is much more forgiving and works fine.


; some constants
include './.win64/equates/winnt.g'
include './.win64/equates/WinBase.g'
include './.win64/equates/sysinfoapi.g'
include './.win64/equates/wincon.g'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6" /STACK:0,0 /HEAP:0,0 '


section '.data' data readable writeable align 64

_10 dq 10

label vstop:4 at volatile-64-4
	rd 1
	align 64 ; cacheline boundary
label vcount:8 at volatile-8
	rq 1 ; insure we have space
	align 64 ; cacheline boundary
volatile:
	repeat 64
		db 0-%
	end repeat
;align 64 ; cacheline boundary



notice Δ db "Split CMPSB results: "
output db 22 dup (0)



section '.flat' code readable executable align 64

__BATCH__ = 0 ; non-batch hammers a single byte, batch is a cacheline

align 64
MyWorkerThread:
namespace MyWorkerThread
	define REG r8
	push rsi rdi
	mov REG,rcx
	xor eax,eax
	if __BATCH__
	big:	xor edx,edx
		mov ecx,1 shl (32-6)
	little:	mov rsi,REG
		mov rdi,REG
		repeat 64
			cmpsb
			setnz al
			add edx,eax
		end repeat
		sub ecx,1
		jnz little
		lock add [REG-8],rdx
	else
	big:	xor edx,edx
;		mov ecx,1 shl 31 ; keep this small ;)
or ecx,-1
;		xor ecx,ecx
	little:	mov rsi,REG
		mov rdi,REG
		cmpsb
		setnz al
		add edx,eax
		loop little
		lock add [REG-8],rdx
	end if
;	jmp .big
	pop rdi rsi
	retn
end namespace


align 64
MyBuggerThread:
	xchg rax,rcx
	xor ecx,ecx
	if __BATCH__
		mov rdx,0x01010101_01010101
	.A:	repeat 64/8
			xor [rax+(%-1)*8],rdx
		end repeat
	else
	.A:	xor byte [rax],1
	end if
	xchg ecx,[rax-64-4] ; implied lock
	jrcxz .A
	retn



macro u64__to_CHAR dest*,source
	local N,A
	lea rdi,[dest]
	match any,source
		mov rax,source
	end match
	push rdi
	push 0
N:	xor edx,edx
	div [_10]
	add edx,'0'
	push rdx
	test rax,rax
	jnz N
	pop rax
A:	stosb
	pop rax
	test eax,eax
	jnz A
	sub edi,[rsp]
	; return bytes written to stringz
	xchg eax,edi
	pop rdi
end macro


MAX_THREADS := 256

public mainCRTStartup:
assert MAX_THREADS*8 < 4096+8 ; 64k is minimum stack
sub rsp,MAX_THREADS*8
frame.enter ,<			\
	hConOut:QWORD,		\
	SystemInfo:SYSTEM_INFO,	\
	ThreadId:DWORD		>

	define .handles rbp ; the stack space was made above

	call KERNEL32:GetCurrentProcess
	xchg rcx,rax
	call KERNEL32:SetPriorityClass,rcx,IDLE_PRIORITY_CLASS;REALTIME_PRIORITY_CLASS
	test eax,eax
	jz .not_any_thread
; create an array of handles
.spin_up:
	call KERNEL32:GetSystemInfo, ADDR SystemInfo
	cmp [SystemInfo.dwNumberOfProcessors],MAX_THREADS
	jbe @F
	mov [SystemInfo.dwNumberOfProcessors],MAX_THREADS
@@:	xor ebx,ebx ;  0 -> upwards, so we know how many at the end

.more_threads:
	lea r8,[MyBuggerThread]	; separate thread changing data
	test ebx,ebx
	jz .bugger
	lea r8,[MyWorkerThread]	; common check thread
.bugger:
	call KERNEL32:CreateThread,0,0,r8,ADDR volatile,CREATE_SUSPENDED,ADDR ThreadId
	mov [.handles+rbx*8],rax
	xchg rcx,rax
	jrcxz .no_thread
	call KERNEL32:SetThreadPriority,[.handles+rbx*8],THREAD_PRIORITY_BELOW_NORMAL;THREAD_PRIORITY_TIME_CRITICAL
	call KERNEL32:ResumeThread,[.handles+rbx*8]
	add ebx,1
	cmp [SystemInfo.dwNumberOfProcessors],ebx
	jnz .more_threads
.no_thread:
	sub ebx,1
	jbe .not_any_thread
	xchg ecx,ebx ; don't wait on first thread
	call KERNEL32:WaitForMultipleObjects,rcx,ADDR .handles+8,TRUE,INFINITE
	mov [vstop],-1 ; stop bugger thread

	; display conclusion results
	call KERNEL32:GetStdHandle,STD_OUTPUT_HANDLE
	mov [hConOut],rax
	u64__to_CHAR output,[vcount]
;	mov dword [output + rax],' of '
;	u64__to_CHAR output
	call KERNEL32:WriteConsoleA,[hConOut],ADDR notice,ADDR (rax+sizeof notice),0,0
.not_any_thread:
	call KERNEL32:ExitProcess,0
	int3
	frame.leave
