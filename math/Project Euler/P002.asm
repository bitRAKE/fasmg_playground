macro PROBLEM
	push 1
	pop rcx
	xor edx,edx
	xor ebx,ebx	; sum
_0:	test ecx,1
	jnz _odd
_even:	add ebx,ecx
_odd:	xadd ecx,edx

; NOTE: previous version of the problem was limit of 1 million

	cmp ecx,4_000_000
	jc _0

	SOLUTION "Problem 2: %lld", rbx
end macro
INCLUDE ".\support\win64.inc"