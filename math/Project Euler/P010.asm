macro PROBLEM
	PRIME_TAB_Initialize

	xor eax,eax
	xor edx,edx
	mov ecx,2-1 ; prime number two not in binary half-table
more_primes:
	lea rcx,[rcx+rdx*2+1]
more_tests:
	bt [PRIME_TAB],rdx
	lea rdx,[rdx+1]
	jnc more_tests
	cmp rdx,2_000_000/2
	jc more_primes

	SOLUTION "Problem 10: %llu", rcx
end macro

INCLUDE ".\support\win64.inc"

macro __DATA ; must be placed after support include (if present)
	PRIME_LIMIT = 2_000_000
	INCLUDE "prime_sieve.inc"
end macro