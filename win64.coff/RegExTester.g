; coding: utf-8, tab: 8
include './.win64/coffms64.g'

; some constants
include './.win64/equates/winnt.g'
include './.win64/equates/windef.g'
include './.win64/equates/WinBase.g'
include './.win64/equates/WinUser.g'
include './.win64/equates/sysinfoapi.g'
include './.win64/equates/wincon.g'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" /STACK:0,0 /HEAP:0,0 '


section '.data' data readable writeable align 8

label notice:(notice_end-$)shr 1
label title:(notice_break-$)shr 1
du 10,9,"Simple Regular Expression Tester",10,10
notice_break:
du \
"Expecting at least two command line parameters:"			,10,\
9,	"1. pattern to search for"					,10,\
9,	"2+. string to look for pattern in"				,10,\
									10,\
"Supported regex features:"						,10,\
9,	"^",9,	"matches the beginning of the input string"		,10,\
9,	"$",9,	"matches the end of the input string"			,10,\
9,	".",9,	"matches any single character"				,10,\
9,	"*",9,	"matches zero or more of the previous character"	,10,\
9,	"otherwise matches literal characters of string"		,10,\
									10,\
"note: Might want to wrap parameters in double quotes.",10
notice_end:

label pattern:(pattern_end-$)shr 1
du 10,"pattern:",9
pattern_end:

label _string:(_string_end-$)shr 1
du 10," string:",9
_string_end:

label found:(found_end-$)shr 1
du 10,"<found>:",9
found_end:

label not_found:(not_found_end-$)shr 1
du 10,"<not found>"
not_found_end:


section '.flat' code readable executable align 64

extrn RegEx__SimpleW

public mainCRTStartup:
frame.enter ,<		\
	hConOut:QWORD,	\
	hHeap:QWORD,	\
	_pat:QWORD,	\
	_str:QWORD,	\
	argv:QWORD,	\
	argn:DWORD	>

	call KERNEL32:GetStdHandle, STD_OUTPUT_HANDLE
	mov [hConOut],rax

; Command line length limitations: Raymond Chen, https://devblogs.microsoft.com/oldnewthing/2003/12/10
;	<method>	<limit>		<reason>
;	CreateProcess	32767		(UNICODE_STRING structure)
;	CMD.EXE		8191		command processor
;	ShellExecute	2048		INTERNET_MAX_URL_LENGTH
;	Win95		260		MAX_PATH
	call KERNEL32:GetCommandLineW
	call SHELL32:CommandLineToArgvW,rax,ADDR argn
	cmp [argn],3
	jnc work_with_it
	xchg rcx,rax
	call KERNEL32:LocalFree,rcx
	call KERNEL32:WriteConsoleW,[hConOut],ADDR notice,sizeof notice,0,0
	call KERNEL32:ExitProcess,0
	int3

work_with_it:
	mov [argv],rax
	xchg rsi,rax
	lodsq ; skip exe pathname
	call KERNEL32:WriteConsoleW,[hConOut],ADDR title,sizeof title,0,0

; caution: CommandLineToArgvW has stripped double quotes from the arguments
; with its rules - this could be problematic for some inputs.

	call KERNEL32:WriteConsoleW,[hConOut],ADDR pattern,sizeof pattern,0,0
; Use whatever framework you are limiting yourself to:
;	call MSVCRT:wcslen,[rsi] ; get charater length of wide string
;	call UCRTBASE:wcslen,[rsi]
	call KERNEL32:uaw_wcslen,[rsi]
	xchg r8,rax
	call KERNEL32:WriteConsoleW,[hConOut],[rsi],r8,0,0
	lodsq
	mov [_pat],rax ; save pattern for later


; We want to put the string on the stack, but we don't know how long all the
; strings are. So, first we must count all their lengths.
	call KERNEL32:WriteConsoleW,[hConOut],ADDR _string,sizeof _string,0,0

	mov rdi,rsi
	mov ebx,[argn]
	sub ebx,2
	mov dword [_str],ebx
	sub ebx,1			; accumulator starts with space separator count
accumulate_lengths:
	lodsq				; FYI: this array is null terminating as well
	xchg rcx,rax
	call KERNEL32:uaw_wcslen,rcx
	add ebx,eax
	sub dword [_str],1
	jnz accumulate_lengths
	lea r8,[(rbx+1)*2 + 63]		; widechar and null space
	and r8l,-64			; minimal alignment
	mov rsi,rdi			; restore string pointer array

	call KERNEL32:GetProcessHeap
	mov [hHeap],rax
	xchg rcx,rax
	call KERNEL32:HeapAlloc,rcx,0,r8
	mov [_str],rax
	xchg rdi,rax

	; finally ready to copy strings
	mov ecx,[argn]
	sub ecx,2
string_copy:
	lodsq
	xchg rsi,rax
	push rax
	xor eax,eax
char_copy:
	lodsw
	stosw
	test eax,eax
	jnz char_copy
	mov word [rdi-2],' '		; copy null then overwrite
	pop rsi
	loop string_copy
	mov word [rdi-2],0

	call KERNEL32:WriteConsoleW,[hConOut],[_str],rbx,0,0

; try to find pattern(s) and output location

	mov rdi,[_str]
	mov dword [_str],0		; match counter
	mov rsi,[_pat]			; same pattern every time (doesn't change)
perform_matching:
	call RegEx__SimpleW
	jnz no_matches
	add dword [_str],1
	call KERNEL32:WriteConsoleW,[hConOut],ADDR found,sizeof found,0,0
	; output partial match location value [0-32] char
	call KERNEL32:uaw_wcslen,rdi
	mov r8d,32
	cmp eax,r8d
	cmovc r8d,eax
	call KERNEL32:WriteConsoleW,[hConOut],rdi,r8,0,0

	; keep looking for more if matches isn't fixed to string start

	cmp word [rsi],'^'
	jz done
	xor eax,eax
	scasw ; advance start position
	jnz perform_matching
no_matches:
	cmp dword [_str],0
	jnz done
	call KERNEL32:WriteConsoleW,[hConOut],ADDR not_found,sizeof not_found,0,0
done:
	call KERNEL32:HeapFree,[hHeap],0,[_str]
	call KERNEL32:LocalFree,[argv]
	call KERNEL32:ExitProcess,0
	frame.leave
	int3
