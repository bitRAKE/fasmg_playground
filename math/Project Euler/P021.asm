macro PROBLEM

; FIX: proper factors loop is wrong for: 2,6,... (for different reasons)

LIMIT = 10000

	xor edi,edi
	mov eax,LIMIT
SumOfDiv:
	mov ebx,1		; all numbers divisible by one
	mov ecx,1
	push rax
DNxt:	add ecx,1
	mov eax,[rsp]
	xor edx,edx
	div ecx
	test edx,edx
	jnz xdiv
	add ebx,ecx	; add proper divisor
	cmp eax,ecx
	jz square	; done, have sum of divisors
	add ebx,eax
xdiv:	cmp eax,ecx	; TODO: remove same CMP instruction above this one
	jnc DNxt

; have sum of proper divisors of [RSP] in RBX

square:	pop rax
	mov [nRay+(rax-1)*4],ebx	; store sum of divisors
	cmp eax,ebx			; could we have found it's pair?
	jnc INxt
	cmp ebx,LIMIT			; is it in array?
	ja INxt
	cmp [nRay+(rbx-1)*4],eax	; does it match?
	jnz INxt
	add edi,ebx
	add edi,eax
INxt:	sub eax,1
	jnz SumOfDiv

	SOLUTION "Problem 21: %llu", rdi
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
ALIGN 64
	nRay rd LIMIT
end macro