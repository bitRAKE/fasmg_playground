macro PROBLEM
	mov edx, 1000000
	xor ebp, ebp		; max chain
	xor ebx, ebx
next:	dec edx
	je done
	cmp ebp, ebx
	mov eax, edx
	cmovc ebp, ebx		; save chain length
	cmovc edi, edx		; save number
	xor ebx, ebx
	jmp _even
_odd:	lea eax, [rax+rax*2+2]
	inc ebx
_even:	inc ebx
	shr eax, 1
	je next
	jc _odd
	jmp _even
done:	inc edi			; answer

	SOLUTION "Problem 14: %llu", rdi
end macro

INCLUDE ".\support\win64.inc"