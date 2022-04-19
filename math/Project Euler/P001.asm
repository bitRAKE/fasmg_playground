; https://www.youtube.com/watch?v=YmencXbXuNk

macro sum_for_divisor end,divisor
	push divisor
	pop rcx
	mov rax,end
	cqo
	div rcx
	lea rdx,[rax+1]
	mul rdx
	shr rax,1
	mul rcx
end macro

macro PROBLEM
	sum_for_divisor 1000,3
	push rax
	sum_for_divisor 1000,5
	add [rsp],rax
	sum_for_divisor 1000,15
	sub [rsp],rax
	pop rbx

	SOLUTION "Problem 1: %lld", rbx
end macro
INCLUDE ".\support\win64.inc"
