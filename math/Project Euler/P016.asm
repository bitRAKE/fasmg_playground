macro PROBLEM

	POWER = 1000

	; set up number in binary
	mov eax, POWER
	lea rbp, [Number]
	bts [ebp], eax

	; convert to decimal base to extract digits
	mov edi, Number.limbs - 1
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
	; slight optimization reduces number size dynamically
	cmp DWORD [rbp+rdi*4], 0
	jne _0
	dec edi
	jns _0

	SOLUTION "Problem 16: %llu", rbx
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
	ALIGN 64
	Number.limbs = (POWER+31)shr 5
	Number rd Number.limbs
end macro