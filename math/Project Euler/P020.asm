macro PROBLEM
	lea ebp, [Number]



	mov eax,1
	mov ecx,1
@@:	lea ecx,[rcx+1]
	cmp ecx,101
	jz last
	imul rax,rcx
	jnc @B






	; set up number in binary
	mov ebx, 100
@@:	invoke mpn_mul_1, ebp, ebx, 0
	dec ebx
	jne @B






	; find used limbs
	mov edi, Number.limbs
@@:	cmp DWORD [rbp+(rdi-1)*4], 0
	lea edi,[rdi-1]
	jz @B

	; convert to decimal to sum digits 
	mov ecx, 10
	xor ebx, ebx ; sum
_0:	mov esi, edi ; dwords to convert
	xor edx, edx
@@:	mov eax, [rbp+rsi*4]
	div ecx
	mov [rbp+rsi*4], eax
	dec esi
	jns @B
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
	BIGINT STRUCT
		limbs	DWORD ?
	BIGINT ENDS
	BIGINT <1024>
	Number DWORD 1, 1023 DUP (0)
end macro
; veery close to problem 16.