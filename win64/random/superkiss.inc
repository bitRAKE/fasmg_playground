;
; SuperKISS based on Usenet posting by G. Marsaglia, period 54767 * 2^1337279
;
; http://www.cs.ucl.ac.uk/staff/d.jones/GoodPracticeRNG.pdf

 
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define superkiss
namespace superkiss

SUPERKISS_QMAX = 41790
GSL_MT19937_1999 = 14

struc CTX
label .
namespace .
	indx	rd 1
	carry	rd 1
	xcng	rd 1
	xs	rd 1
	Q	rd SUPERKISS_QMAX
end namespace
end struc


ALIGN 16
refill:	virtual at RCX
		.ctx CTX
	end virtual
	mov r8,-SUPERKISS_QMAX*4
  .ll:	mov eax,7010176
	mul [.ctx.Q + r8 + SUPERKISS_QMAX*4]
	add eax,[.ctx.carry]
	adc edx,0
	not eax
	mov [.ctx.carry],edx
	mov [.ctx.Q + r8 + SUPERKISS_QMAX*4],eax
	add r8,4
	jnz .ll
	mov [.ctx.indx],1
	mov eax,[.ctx.Q]
	retn


ALIGN 16
next:	virtual at RCX
		.ctx CTX
	end virtual
	mov eax,69069
	mul [.ctx.xcng]
	add eax,123
	mov [.ctx.xcng],eax

	push rax
	mov edx,[.ctx.xs]
	mov eax,edx
	shl edx,13
	xor edx,eax
	mov eax,edx
	shr edx,17
	xor eax,edx
	mov edx,eax
	shr eax,5
	xor edx,eax
	mov [.ctx.xs],edx
	pop rax
	add edx,eax

	mov eax,[.ctx,indx]
	inc [.ctx,indx]
	cmp eax,SUPERKISS_QMAX
	mov eax,[.ctx.Q + rax*4]
	jc .okay
	push rdx
	call refill
	pop rdx
.okay:	add eax,edx
	retn


ALIGN 16
init:	virtual at RCX
		.ctx CTX
	end virtual

	mov	[.ctx.indx], SUPERKISS_QMAX-1
.fill:
	; use another PRNG to seed state

	mov	edx,[.ctx.indx]
	sub	[.ctx.indx],1
	mov	[.ctx.Q + rdx*4],eax
	jns	.fill
	mov	[.ctx.indx], SUPERKISS_QMAX
	mov	[.ctx.carry], 362436
	mov	[.ctx.xcng], 1236789
	mov	[.ctx.xs], 521288629
	retn

end namespace
else;-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.CODE
Start:	lea rbx,[TestArray]	; test intervals to confirm
	lea rcx,[ctx]		; PRNG context
	call superkiss.init	; perserves RCX
;	lea rcx,[ctx]
check:	call superkiss.next	; perserves RCX
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

	include '.\superkiss.inc' ; dot dir changes name to bypass 'if' at start
.DATA

ctx superkiss.CTX ; PRNG context

?

message db "superkiss PRNG test: "
result: db "FAIL.",13,10,0
message.bytes = $ - message
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST