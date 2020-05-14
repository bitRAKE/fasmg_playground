macro PROBLEM ; very close to problem 16.
	local calc,mlt,grew,_0,_1

	; set up number in binary

	xor edi,edi		; track growth of big integer
	mov ebx,1		; product of [1..100]
calc:	xor esi,esi
	xor edx,edx
	pushfq
mlt:	mov eax,[bignum+rsi*4]
	mov [bignum+rsi*4],edx
	mul ebx
	popfq
	adc [bignum+rsi*4],eax
	pushfq
	add esi,1		; higher limbs of big integer
	cmp edi,esi		; past the end?
	jnc mlt
	add ebx,1		; multiply by larger numbers
	popfq
	adc edx,0		; carry remaining means it needs to grow
	jz grew
	mov [bignum+rdi*4+4],edx
	add edi,1
grew:	cmp ebx,101		; only 3ms for 964!
	jnz calc

	; convert to decimal to sum digits 

	lea ebp, [bignum]
	mov ecx, 10
	xor ebx, ebx		; sum
_0:	mov esi, edi		; dwords to convert
	xor edx, edx
_1:	mov eax, [rbp+rsi*4]
	div ecx
	mov [rbp+rsi*4], eax
	dec esi
	jns _1
	add ebx, edx
	cmp DWORD [rbp+rdi*4], 0
	jnz _0
	dec edi
	jns _0

	SOLUTION "Problem 20: %llu", rbx
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
ALIGN 64
	bignum dd 1, 255 DUP (?) ; good up to 964! (c:
end macro