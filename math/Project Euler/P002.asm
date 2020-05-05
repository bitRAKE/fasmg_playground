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

; I estimate that I had written about 3 million lines
; of assembler code in my whole life. Now, code only
; when strictly necessary.
;
; Phi (golden ratio) is the approximate ratio between
; two consecutive terms in a Fibonacci sequence.
; The ratio between consecutive even terms approaches
; phi^3 (4.236068) because each 3rd term is even.
; Use a calculator and round the results to the nearest
; integer when calculating the next terms:
;
; 2,8,34,.. multiplying by 4.236068 each time: 144,610,
; 2584,10946,46368,196418 & 832040
;
; The sum is 1089154
;
; My codeless regards,
; Rudy.
;
; Rudy Penteado died on Feb 25, 2006