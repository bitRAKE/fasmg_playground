; used by the following problems:
;	003
;

; create data structure where file is included
align 64
PRIME_TAB_CACHELINES = (PRIME_LIMIT + 1023) shr 10
PRIME_TAB_BITS = PRIME_TAB_CACHELINES * 64 * 8
PRIME_TAB: rb PRIME_TAB_CACHELINES*64


; This initialization is not meant to be fast, but small in code size. Utility
; stems from needing small prime testing within an inner loop of an algorithm.
; Change the logic of the array based on the needs of the algorithm - prime
; bits are zero or one.

; TODO: we want to not use bit zero to save an instruction (3/2=1)

macro PRIME_TAB_Initialize neg_logic=0
	local clr,find

	push rdi

	; set all bits in buffer ; assume all numbers are prime

	lea rdi,[PRIME_TAB]
	mov ecx,PRIME_TAB_BITS/32
	if neg_logic
		xor eax,eax
	else
		or eax,-1
	end if
	push rdi
	rep stosd
	pop rdi
	xor ecx,ecx
	jmp find

	if neg_logic
	clr:	bts [rdi],eax
		lea eax,[rax+rcx*2+1]
		cmp eax,PRIME_TAB_BITS
		jc clr
	find:	bt [rdi],ecx
		inc ecx
		jc find
	else
; 0 1 2 3 4 5 6 7 8 9 10 11 ...			| bit index
;-----------------------------------------	|
; 3 5 7 9 11 13 15 17 19 21 23 25 ...		| (N)
; 9 15 21 27 33 39 45 51 57 63 69 75 ...	| 3(N)
; 15 25 35 45 55 65 75 85 95 ...		| 5(N)

; clear bits representing odd multiples of (P)
	clr:	btr [rdi],eax
		lea eax,[rax+rcx*2+1]
		cmp eax,PRIME_TAB_BITS
		jc clr
	find:	bt [rdi],ecx
		inc ecx
		jnc find
	end if
; ECX*2 + 1 is prime number (P)
; 2(P) is even - skip even numbers

; number 3(P) is represented by bit 3: ECX*3
; number 5(P) is represented by bit 6: ECX*5 + 1
; number 7(P) is represented by bit 9: ECX*7 + 2
; number x(P) = bit y: ECX * x + [(x-3)/2]

; start with (P)^2 as first odd multiple to mark
; as non-prime: all others have been marked

	lea eax,[rcx*2]
	mul ecx
	lea eax,[rax+rcx*2-1]
	cmp eax,PRIME_TAB_BITS
	jc clr
	pop rdi

macro NEXT_PRIME reg
	local back
back:	bt [PRIME_TAB],reg
	lea reg,[reg+1]
	if neg_logic
		jc back ; primes are zero bits
	else
		jnc back ; primes are one bits
	end if
end macro
end macro