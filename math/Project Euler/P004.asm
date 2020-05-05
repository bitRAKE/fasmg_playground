; The palindrome can be written as:	abccba
; Which then simpifies to:		100000a + 10000b + 1000c + 100c + 10b + a
; And then:				100001a + 10010b + 1100c
; Factoring out 11, you get:		11(9091a + 910b + 100c)
;
; So the palindrome must be divisible by 11.  Seeing as 11 is prime, at least
; one of the numbers must be divisible by 11. -- Begoner
macro PROBLEM
	virtual at RSP
		max	rq 1
		maxI	rq 1
		maxJ	rq 1
	end virtual
	push 0
	push 0
	push 0
	mov esi,999
ii:	mov edi,990
jj:	mov eax,esi
	mul rdi
	cmp [max],rax
	jnc skip
	push rax
	PalidroneQ rax,rdx
	pop rax
	jnz skip
	mov [max],rax
	mov [maxI],rsi
	mov [maxJ],rdi
skip:	sub edi,11
	cmp edi,100
	jnc jj
	sub esi,1
	cmp esi,100
	jnc ii
	pop rbx
	pop rsi
	pop rdi
	SOLUTION "Problem 4: %lld = %lld x %lld", rbx,rsi,rdi
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
	INCLUDE "palindrome.inc"
end macro