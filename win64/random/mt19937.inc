;
; mt19937 based on Mersenne Twister, period 2^19937
; by Makoto Matsumoto and Takuji Nishimura
; http://www.math.sci.hiroshima-u.ac.jp/~m-mat/MT/emt.html
;
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define mt19937
namespace mt19937

	n         = 312
	m         = 156
	notSeeded = n + 1

	hiMask = 0XFFFFFFFF80000000
	loMask = 0X000000007FFFFFFF

	matrixA = 0xB5026F5AA96619E9

struc CTX
label .
namespace .
	indx	rd 2
	x	rq n ; state
end namespace
end struc


ALIGN 16
next:	virtual at RCX
		.ctx CTX
	end virtual

	retn


; use RAX to seed context RCX
init:	virtual at RCX
		.ctx CTX
	end virtual
	mov r8,0x5851_F42D_4C95_7F2D
	mov r9,n-1
	jmp .xx

  .ll:	mov rdx,rax
	shr rax,62
	xor rax,rdx
	mul r8
	add rax,r9
  .xx:	mov [.ctx.x + r9*8],rax
	sub r9,1
	jns .ll
	mov [.ctx.indx],n
	retn

end namespace
else;-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
include '..\x64help.inc'
include '..\time.inc'
.CODE ; Just test the speed ...
Start:
	lea rcx,[ctx]		; PRNG context
	call ca_prng.init
	Get100ns rax		; start time
	push rax
	push 1 shl 20
check:	lea rcx,[ctx]
	call ca_prng.next
	sub dword[rsp],4
	jnz check
	pop rax
	Get100ns rax		; end time
	sub [rsp],rax
	neg qword [rsp]
	push 0

; TODO: do some unit conversion ...
mov rax,rsp
invoke wvsprintfA,buffer,template,rax
mov [buffer-8],rax

	invoke GetStdHandle,STD_OUTPUT_HANDLE
	invoke WriteConsoleA,rax,buffer,[buffer-8],0,0
	invoke ExitProcess,0

	include '.\mt19937.inc' ; dot dir changes name to bypass 'if' at start
.DATA
template db "mt19937 : 0.%.3u ms, (about 0.%.3u mb/sec).",13,10,0

ALIGN 64
ctx mt19937.CTX ; PRNG context

ALIGN 64
	rq 1
buffer: rb 4096-8
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST