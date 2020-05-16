; cmwc4096 PRNG algorithm by George Marsaglia
;
; This RNG has period > 2^131086, some 10^33459 times as long as that of the
; Mersenne Twister and rates highly in all  categories. It provides the more
; than 10^39460 base-b digits in the expansion of (p-1)/p,  where p is the
; prime p=18782*b^4096+1, b=2^32-1. Those base-b 'digits' are returned in
; reverse order from a random starting point determined by the random choice
; of the initial values in Q[4096] and c.

if __source__<>__file__ ; FYI: assembly of this file builds test case!
define cmwc4096
namespace cmwc4096


struc CTX
label .
namespace .
	index	rd 1
	carry	rd 1
	repeat 4
		state rd 4096
	end repeat
end namespace
end struc


ALIGN 16
next:	virtual at RCX
		.ctx CTX
	end virtual

	retn



init:	virtual at RCX
		.ctx CTX
	end virtual

	retn

end namespace
else;-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.CODE
Start:	lea rbx,[TestArray]	; test intervals to confirm
	lea rcx,[ctx]		; PRNG context
	call cmwc4096.init	; perserves RCX
;	lea rcx,[ctx]
check:	call cmwc4096.next	; perserves RCX
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

	include '.\cmwc4096.inc' ; dot dir changes name to bypass 'if' at start
.DATA

ctx cmwc4096.CTX ; PRNG context

message db "cmwc4096 PRNG test: "
result: db "FAIL.",13,10,0
message.bytes = $ - message
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST