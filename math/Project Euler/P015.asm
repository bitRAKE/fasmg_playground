macro PROBLEM
	jmp Bunny

INCLUDE "Choose.inc"

Bunny:	mov eax,40
	mov ecx,20
	call Choose ; 137846528820
	SOLUTION "Problem 15: %llu", rax
end macro

INCLUDE ".\support\win64.inc"