macro PROBLEM
	PRIME_TAB_Initialize

	mov rsi,600851475143
	xor ebx,ebx
try_next_prime:
	or rax,-1 ; error state?
	cmp ebx,500_000
	jnc prime_exceeds_table
	NEXT_PRIME rbx 
	lea rcx,[rbx*2+1]	; prime
try_this_prime:
	xor edx,edx
	mov rax,rsi
	div rcx
	test rdx,rdx
	jnz try_next_prime
	mov rsi,rax

	; is the number small enough to test directly for primeness?
	; (early exit)

	cmp rax,1_000_000
	jnc try_this_prime
	shr rax,1
	jnc try_this_prime ; even numbers aren't prime
	sub rax,1
	bt [PRIME_TAB],rax
	jnc try_this_prime
prime_exceeds_table:
	cmovnc rsi,rax
	SOLUTION "Problem 3: %d", rsi
end macro

INCLUDE "support.win64.inc"

macro __DATA ; must be placed after support include (if present)
	PRIME_LIMIT = 1_000_000 ; any# >= SQRT(600851475143)
	INCLUDE "prime_sieve.inc"
end macro