;
; taus88 based pseudo random number generator, period about 2^88
;
; [1] P. L'Ecuyer, "Maximally Equidistributed Combined Tausworthe Generators",
;     Mathematics of Computation 65, 213 (1996), 203-213
; [2] http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme.ps
;     Online version of [1] with corrections
;
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define taus88
namespace taus88

ICNT = 6 ; initialization count to reach valid state

struc CTX
label .
namespace .
	nr	rd 1
	s1	rd 1
	s2	rd 1
	s3	rd 1
end namespace
end struc


ALIGN 16
next:	push rbx
	virtual at RCX
		.ctx CTX
	end virtual
	mov eax,[.ctx.s1]
	mov ebx,[.ctx.s2]
	mov edx,[.ctx.s3]
	shl eax,13
	shl ebx,2
	shl edx,3
	xor eax,[.ctx.s1]
	xor ebx,[.ctx.s2]
	xor edx,[.ctx.s3]
	shr eax,19
	shr ebx,25
	shr edx,11
	and [.ctx.s1],$FFFFFFFE
	and [.ctx.s2],$FFFFFFF8
	and [.ctx.s3],$FFFFFFF0
	shl [.ctx.s1],12
	shl [.ctx.s2],4
	shl [.ctx.s3],17
	xor [.ctx.s1],eax
	xor [.ctx.s2],ebx
	xor [.ctx.s3],edx
	pop rbx
	mov eax,[.ctx.s1]
	xor eax,[.ctx.s2]
	xor eax,[.ctx.s3]
	mov [.ctx.nr],eax
	retn


init:	virtual at RCX
		.ctx CTX
	end virtual
	mov [.ctx.nr],0
	; minimal seeds, these must be > zero
	or [.ctx.s1],2
	or [.ctx.s2],8
	or [.ctx.s3],16
	; state not valid until ICNT iterations
	repeat ICNT
		call next
	end repeat
	retn

end namespace
else;-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.CODE
Start:	lea rbx,[TestArray]	; test intervals to confirm
	lea rcx,[ctx]		; PRNG context
	call taus88.init	; perserves RCX
;	lea rcx,[ctx]
check:	call taus88.next	; perserves RCX
	sub dword[rbx],1
	jnz check
	add rbx,8
	cmp eax,[rbx-4]
	jnz fail
	cmp dword[rbx],0
	jnz check
pass:	mov dword[result],"pass"
fail:	invoke GetStdHandle,STD_OUTPUT_HANDLE
	invoke WriteConsoleA,rax,message,message.bytes,0,0
        invoke ExitProcess,0

	include '.\taus88.inc' ; dot dir changes name to bypass 'if' at start
.DATA

ctx taus88.CTX ; PRNG context

; Test values from t_taus88.c based on [2]

TestArray dd	500-taus88.ICNT,$4F87C056,\
		1000	-500,	$FED1530B,\
		5000	-1000,	$91D993A0,\
		10000	-5000,	$438F5E83,\
		20000	-10000,	$F4645720,\
		30000	-20000,	$D5CCC345,0
message db "taus88 PRNG test: "
result: db "FAIL.",13,10,0
message.bytes = $ - message
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST