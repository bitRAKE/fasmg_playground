macro PROBLEM

; EBP = n-1
; EBX = n^2
	mov ebp, 1
	mov ebx, 4
; ESI = m
; EDI = T(m) = m(m+1)/2
	mov esi, 2
	mov edi, 3

_0:	inc esi
	mov ecx, 0		; factors
	add edi, esi		; triangle number

	cmp ebx, edi		; next square?
	jnbe _1
	lea ebx, [rbx + 2*rbp + 3]
	inc ebp
_1:	push rbp
	; EDI = triangle number
	; EBP = square root of EDI rounded down
_2:	mov eax, edi
	xor edx, edx
	div ebp
	sub edx, 1		; C?
	dec ebp			; Z?
	jnbe _2
	lea ecx, [ecx+2]	; two factors
	jne _2
	cmp ecx, 500
	pop rbp
	jl _0
; EDI is answer

	SOLUTION "Problem 12: %llu", rdi
end macro

INCLUDE ".\support\win64.inc"
; Despite the above algorithm finding the solution, this algorithm is
; incorrect! ; N = 2^a.3^b... has (a+1)(b+1)... divisors