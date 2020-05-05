macro PROBLEM
	PRIME_TAB_Initialize

	xor edx,edx
	mov ecx,10001-1 ; prime number two not in binary half-table
more_primes:
	bt [PRIME_TAB],rdx
	lea rdx,[rdx+1]
	sbb ecx,0
	jrcxz done
	jmp more_primes
done:	lea rdx,[rdx*2+1]

	SOLUTION "Problem 7: %lld", rdx
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
;
; How many primes do we need?
;
; The asymptotic bound on the nth prime p_n:
;	n ln n + n (ln ln n − 1) < p_n < n ln n + n ln ln n ; for n >= 6
; Suggesting between the range (104318,114319) we'll find the prime.
	PRIME_LIMIT = 115000
	INCLUDE "prime_sieve.inc"
end macro