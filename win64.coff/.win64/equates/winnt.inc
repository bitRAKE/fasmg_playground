
; winnt.inc
; almost 23k lines, slowly to appear here ...

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
