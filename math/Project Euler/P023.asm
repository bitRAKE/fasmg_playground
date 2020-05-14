macro PROBLEM ; reuse of problem 21, proper divisor code

LIMIT = 28123 ; last number which cannot be written as sum of two abundant

	xor edi,edi
	mov eax,LIMIT
	; sentinal bits to force halt later loops
	bts [bAbundant],eax ; sum exceeds the limit, value never used
	bts [bSum],eax ; known not to be lower limit, stated in problem
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
square:
; have sum of proper divisors of [RSP] in RBX

; flag all abundant numbers
	pop rax
	cmp eax,ebx
	jnc INxt
	bts [bAbundant],eax
INxt:	sub eax,1
	jnz SumOfDiv

; flag all sums of two

	xor ebx,ebx
outer:	bt [bAbundant],ebx
	jnc bnot
	mov ecx,ebx
inner:	bt [bAbundant],ecx
	jnc cnot
	lea eax,[ecx+ebx]
	cmp eax,LIMIT
	ja overflow
	bts [bSum],eax
cnot:	inc ecx
	jmp inner
overflow:
bnot:	inc ebx
	cmp ebx,LIMIT
	jnz outer

; sum un-flagged numbers, could invert and POPCNT, too

	xor edi,edi
	xor eax,eax
  _s:	inc eax
	bt [bSum],eax
	jc _s
	cmp eax,LIMIT
	jz _x
	add edi,eax
	jmp _s
_x:
	SOLUTION "Problem 23: %llu", rdi
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
ALIGN 64
	bAbundant rd (LIMIT+31)/32
	bSum rd (LIMIT+31)/32
end macro