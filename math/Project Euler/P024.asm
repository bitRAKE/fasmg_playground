macro PROBLEM
	include 'factoradic.inc'

	lea rdi,[p24]
	push 999_999
	INTEGER__Factoradic

	; the digits of the factoradic select permutation items
	; from a shrinking array (c:

	lea rdi,[p24+8]
	xor ebx,ebx
	xor ebp,ebp ; bit array in register
.ll:	movzx ecx,byte[rdi]
	sub rdi,1

; this is a little strange, we are counting off zero bits to find the
; number and then setting that bit/number as used.

	xor eax,eax
@@:	bt rbp,rax
	lea eax,[rax+1]
	jc @B
	sub ecx,1
	jns @B
	sub eax,1
	bts rbp,rax

	imul rbx,rbx,10
	lea rbx,[rbx+rax]
	cmp rdi,p24
	jnc .ll

	; no trailing zero, so we need another digit

	not rbp
	bsf rcx,rbp
	imul rbx,rbx,10
	lea rbx,[rbx+rcx]

	SOLUTION "Problem 24: %llu", rbx
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
ALIGN 64
	p24 db 16
end macro