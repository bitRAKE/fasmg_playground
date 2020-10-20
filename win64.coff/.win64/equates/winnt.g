
; winnt.inc
; almost 23k lines, slowly to appear here ...

FALSE=0
TRUE=1
INFINITE=-1

THREAD_DYNAMIC_CODE_ALLOW	=1	; Opt-out of dynamic code generation.

THREAD_BASE_PRIORITY_LOWRT	=15	; value that gets a thread to LowRealtime-1
THREAD_BASE_PRIORITY_MAX	=2	; maximum thread base priority boost
THREAD_BASE_PRIORITY_MIN	=-2	; minimum thread base priority boost
THREAD_BASE_PRIORITY_IDLE	=-15	; value that gets a thread to idle


struct MEMORY_BASIC_INFORMATION32
BaseAddress rd 1
AllocationBase rd 1
AllocationProtect rd 1
RegionSize rd 1
State rd 1
Protect rd 1
Type rd 1
end struct

struct MEMORY_BASIC_INFORMATION64 ; needs 'align 16'
BaseAddress rq 1
AllocationBase rq 1
AllocationProtect rd 2 ; 1 for alignment
RegionSize rq 1
State rd 1
Protect rd 1
Type rd 2 ; 1 for alignment
end struct
