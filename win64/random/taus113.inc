;
; taus113 based pseudo random number generator, period about 2^113
;
; [1] P. L'Ecuyer, "Tables of Maximally-Equidistributed
;     Combined LFSR Generators", Mathematics of Computation, Vol. 68, 225 (1999), 261-269.
; [2] http://www.iro.umontreal.ca/~lecuyer/myftp/papers/tausme2.ps
;     Online version of [1]
;
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define taus113
namespace taus113

ICNT = 10 ; initialization count to reach valid state

struc CTX
label .
namespace .
	nr	rd 1
	repeat 4
		z#% rd 1
	end repeat
end namespace
end struc


ALIGN 16
next:	push rbx
	push rsi
	virtual at RCX
		.ctx CTX
	end virtual
	iterate reg_, eax,ebx,edx,esi
		define .reg#% reg_
		mov .reg#%, [.ctx.z#%]
	end iterate
	iterate tap, 6,2,13,3
		shl .reg#%, tap
	end iterate
	repeat 4
		xor .reg#%, [.ctx.z#%]
	end repeat
	iterate tap, 13,27,21,12
		shr .reg#%, tap
	end iterate
	iterate clamp, 1,3,4,7
		and [.ctx.z#%], -1 shl clamp
	end iterate
	iterate tap, 18,2,7,13
		shl [.ctx.z#%], tap
	end iterate
	repeat 4
		xor [.ctx.z#%], .reg#%
	end repeat
	pop rsi
	pop rbx
	mov eax,[.ctx.z1]
	xor eax,[.ctx.z2]
	xor eax,[.ctx.z3]
	xor eax,[.ctx.z4]
	mov [.ctx.nr],eax
	retn



init:	virtual at RCX
	.ctx CTX
	end virtual
	mov [.ctx.nr],0
	; minimal seed, at least one bit > than these must be non-zero
	iterate tap, 1,3,4,7
		or [.ctx.z#%],1 shl tap
	end iterate
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
	call taus113.init	; perserves RCX
;	lea rcx,[ctx]
check:	call taus113.next	; perserves RCX
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

	include '.\taus113.inc' ; dot dir changes name to bypass 'if' at start
.DATA

ctx taus113.CTX ; PRNG context

; Test values from t_taus113.c based on [2]

TestArray dd	500-taus113.ICNT,$B2209AE9,\
		1000	-500,	$37D83989,\
		2500	-1000,	$3BFCADBD,\
		10000	-2500,	$26620794,\
		20000	-10000,	$7AAA2B26,\
		30000	-20000,	$A98802F6,0
message db "taus113 PRNG test: "
result: db "FAIL.",13,10,0
message.bytes = $ - message
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST