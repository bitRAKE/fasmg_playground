;
; ca_prng cellular automaton random number generator, period unknown
;
; Tony Pasqualoni (original C version) / Sept. 20, 2006
; (all links appear to not work, included for it's novelty)
;
if __source__<>__file__ ; FYI: assembly of this file builds test case!
define ca_prng
namespace ca_prng

STATE_BYTES = 1024 - 4 ; some multiple of cacheline-4 defines the update interval

struc CTX
label .
namespace .
	nr	rd 1
	state	rb ca_prng.STATE_BYTES
end namespace
end struc


ALIGN 16
next:	virtual at RCX
		.ctx CTX
	end virtual
	mov eax,[.ctx.nr]
	sub [.ctx.nr],1
	js .renew
	mov eax,[.ctx.nr+rax*4]
	retn

.renew:	push rbp rdi rsi rbx
	mov edi, STATE_BYTES - 1
	movzx ebp, [.ctx.state+rdi-0]
  @@:	mov eax, ebp
	movzx edx, [.ctx.state+rdi-1]
	movzx ebx, [.ctx.state+rdi-2]
	movzx esi, [.ctx.state+rdi-3]
	movzx ebp, [.ctx.state+rdi-4] ; NOTE: underflow read on last loop
	add al, dl
	add dl, bl
	add bl, sil
	add sil, bpl
	mov al, [rule+rax]
	mov dl, [rule+rdx]
	mov ah, [rule+rbx]
	mov dh, [rule+rsi]
	mov [.ctx.state+rdi-0], al
	mov [.ctx.state+rdi-1], dl
	mov [.ctx.state+rdi-2], ah
	mov [.ctx.state+rdi-3], dh
	sub rdi, 4
	jnc @B
	pop rbx rsi rdi rbp
	mov [.ctx.nr],(STATE_BYTES/4)-1
	mov eax,dword[.ctx.state+STATE_BYTES-4]
	retn


init:	virtual at RCX
		.ctx CTX
	end virtual

	mov eax,STATE_BYTES
  @@:	mov [.ctx.state+rax-1],al
	sub eax,1
	jnz @B
	mov [.ctx.nr],eax
	push STATE_BYTES
  @@:	call next.renew
	sub dword [rsp],1
	jnz @B
	pop rax
	retn


ALIGN 64
rule db \
100, 75, 16,  3,229, 51,197,118, 24, 62,198, 11,141,152,241,188,\
  2, 17, 71, 47,179,177,126,231,202,243, 59, 25, 77,196, 30,134,\
199,163, 34,216, 21, 84, 37,182,224,186, 64, 79,225, 45,143, 20,\
 48,147,209,221,125, 29, 99, 12, 46,190,102,220, 80,215,242,105,\
 15, 53,  0, 67, 68, 69, 70, 89,109,195,170, 78,210,131, 42,110,\
181,145, 40,114,254, 85,107, 87, 72,192, 90,201,162,122, 86,252,\
 94,129, 98,132,193,249,156,172,219,230,153, 54,180,151, 83,214,\
123, 88,164,167,116,117,  7, 27, 23,213,235,  5, 65,124, 60,127,\
236,149, 44, 28, 58,121,191, 13,250, 10,232,112,101,217,183,239,\
  8, 32,228,174, 49,113,247,158,106,218,154, 66,226,157, 50, 26,\
253, 93,205, 41,133,165, 61,161,187,169,  6,171, 81,248, 56,175,\
246, 36,178, 52, 57,212, 39,176,184,185,245, 63, 35,189,206, 76,\
104,233,194, 19, 43,159,108, 55,200,155, 14, 74,244,255,222,207,\
208,137,128,135, 96,144, 18, 95,234,139,173, 92,  1,203,115,223,\
130, 97, 91,227,146,  4, 31,120,211, 38, 22,138,140,237,238,251,\
240,160,142,119, 73,103,166, 33,148,  9,111,136,168,150, 82,204

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