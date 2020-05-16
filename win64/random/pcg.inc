;
; pcg random number generator
; Copyright 2014 Melissa O'Neill <oneill@pcg-random.org>
; Licensed under Apache License 2.0 (NO WARRANTY, etc. see website)
;
; https://www.pcg-random.org/download.html
;
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define pcg
namespace pcg

struc CTX
label .
namespace .
	staet	rq 1
	_inc	rq 1
end namespace
end struc


ALIGN 16
next:	virtual at RCX
		.ctx CTX
	end virtual


	mov rax,0x5851_F42D_4C95_7F2D
	mul [.ctx._inc]
	

	retn


init:	virtual at RCX
		.ctx CTX
	end virtual

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

	include '.\ca_prng.inc' ; dot dir changes name to bypass 'if' at start
.DATA
template db "ca_prng : 0.%.3u ms, (about 0.%.3u mb/sec).",13,10,0

ALIGN 64
ctx ca_prng.CTX ; PRNG context

ALIGN 64
	rq 1
buffer: rb 4096-8
.END Start
end if;EST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST-TEST