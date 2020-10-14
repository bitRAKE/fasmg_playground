; coding: utf-8, tab: 8
include './.win64/coffms64.g'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" ',	\
	'/STACK:0,0 ',			\
	'/HEAP:0,0 '

section '.flat' code readable executable align 64

	dq _True
BoolTab dq _False
_False	db "False",0
_True	db "True",0

message db 'Some random values:',10,	\
9,'bit:   %s',10,	\
9,'byte:  %hhu',10,	\
9,'word:  %hu',10,	\
9,'dword: %u',10,	\
9,'qword: %llu',0	; Last line doesn't need newline
; ToDo :
;9,'float:  %f',10,0
;9,'double: %e',10,0

string_params = 5

public mainCRTStartup:
	sub rsp,40+(((string_params+1)shr 1) shl 4)
	xor ebx,ebx
	lea rbp,[rsp+32] ; buffer for random data

	BCRYPT_USE_SYSTEM_PREFERRED_RNG = 2
@@:	call BCRYPT:BCryptGenRandom,rbx,rbp,8*string_params,BCRYPT_USE_SYSTEM_PREFERRED_RNG

	bt [rbp],ebx
	sbb rax,rax		; 0 | -1
	lea rdx,[BoolTab]
	push [rdx+rax*8]
	pop [rbp] ; overwrite random data with string pointer

; __conio_common_vcprintf not documented : options,template,locale,vector
; NOTE: rely on parameter types to filter random data
	call UCRT:__conio_common_vcprintf,rbx,ADDR message,rbx,rbp
	call KERNEL32:ExitProcess,rbx
	int3
