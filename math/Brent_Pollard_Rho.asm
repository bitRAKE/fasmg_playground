
; In 1980 it took 2 hours to compute the smallest non-trivial factor of
; 2^2^8 + 1. If computers have improved by three orders than the same
; computation should take 7.2 seconds.




; big unsigned integers:
;	x0	initial value mod N
;	N	number to factor (odd)
;	x	track loop start
;	y	follow loop
;	ys	needed for backtracking
;	t	temp value
;	q	term accumulator
;	G	possible factor

Brent_Pollard_Rho:

; local machine size:
	.m	rq 1	; [log N, N^(1/4)], large m increases backtrack cost
	.r	rq 1	; increasing powers of two
	.k	rq 1	; multiples of (m)

	y _copy x0
	mov [.r],1
	q _set 1
.out:	x _copy y

	push [.r]
  @@:	y _f y
	sub qword [rsp],1
	jnz @B
	mov [.k],0
.mid:	ys _copy y

	; min(m,r-k)
	mov rax,[.r]
	sub rax,[.k]
	cmp rax,[.m]
	cmovc rax,[.m]
	push rax
.inn:	y _f y
	t _abs_sub x,y
	q _mulmod q,t,N
	sub qword [rsp],1
	jnz .inn
	pop rax

	G _GCD q,N

	mov rax,[.m]
	add [.k],rax

	mov rax,[.k]
	cmp [.r],rax
	jnc .done

	G _EQ 1, .mid
.done:	shl [.r],1

	G _EQ 1, .out
	G _NE N, .skip_backtrack
.backtrack:
	ys _f ys
	t _abs_sub x,ys
	G _GCD t,N
	G _EQ 1, .backtrack

.skip_backtrack:
	G _NE N, .success
.failure:

.success:
	retn





struc _NE B,dest
	mov rsi,[.]
	mov rdi,[B]
	call BigU__compare
	jnz dest
end struc








; BigU Library, an unsigned integer framework
;
; Basically, an array of 32-bit values - where the first item is the length
; of the array. Pointers are passed around, destinations are allocated from
; the heap to the correct size.
;
; If the array has zero values at the top of the array, they are degenerate
; BigU's and not desired. Algorithms shouldn't produce or consume degenerate
; values unless there is no cost to do so.


; how can an allocator be good and cache friendly?
; beyond allocation granularity?


; header constants
define BigU__REG R15	; used throughout BigU framework for header access
BigU__BYTES	= 0	;dw	how much was allocated total
BigU__POOLBYTES	= 4	;dw	how much was allocated for BigU's
BigU__POOLEND	= 8
BigU__BLOCKS	= 16	;dw	to track
; cache aligned variable structure, every dword needs a bit
BigU__FLAGS	= ((BigU__BLOCKS+4+63)shr 6)shl 6



BigU__build:
; differs from BigU__create in that the user supplies a memory area
	int3



BigU__create:
; create a BigU pool on the heap
	enter.frame 4

	; adjust size for pool bits and header structure

	test ecx,ecx
	mov eax,1 shl 11	; minimum data size granularity
	lea edx,[rax-1]
	cmovnz eax,ecx
	add eax,edx
	not edx
	and eax,edx
	mov dword[FRAME.R8],eax		; total data size
	shr eax,11 - 6
	add eax,BigU__FLAGS
	mov dword[FRAME.R8+4],eax	; total header size

	Win64abi GetProcessHeap
	xchg rcx,rax
	jrcxz .fail

	mov r8d,dword[FRAME.R8]
	add r8d,dword[FRAME.R8+4]
	mov edx,12 ; HEAP_GENERATE_EXCEPTIONS or HEAP_ZERO_MEMORY
	Win64abi HeapAlloc
	mov BigU__REG,rax

	; need to configure

	; set size of only availible block, and flag

	leave.frame
	retn

.fail:	stc
	leave.frame
	retn



BigU__pool:
; get the address of largest unallocated block. used when the final size
; of BigU is unknown -- cannot be known.
	retn



BigU__to_pool:
; free a block by returning it to the pool of memory from RSI

; is the block in front of this one free? merge into a larger block
	mov ecx,[rsi]
	add ecx,1			; include this header
.gather:
	lea rax,[rsi+rcx*4]		; possible header address
	cmp rax,[r15+BigU__POOLEND]
	jnc .past_end
	test dword[rax],-1		; either the head of a BigU or free
	jns .busy
	sub ecx,[rax]			; increase block size
	sub rax,r15
	shr eax,2
	btr [r15+BigU__FLAGS],eax	; flag block gone
	jmp .gather			; try more
.past_end:
.busy:
	neg ecx				; -1 * (dword length)
	mov [rsi],ecx			; mark free
	sub rsi,r15
	shr esi,2
	bts [r15+BigU__FLAGS],esi	; flag block availible
	retn



BigU__zero:
; return a BigU of zero in RDI
	xor ecx,ecx

BigU__from_pool:
; get the address of a free block of a specific size ECX to RDI

; scan flags and check block sizes, try to forward merge blocks

; must grab first block sufficient and prune the tail (try to merge tail forward)

	retn



BigU__uint:
; convert RCX to a correctly sized BigU in RDI
	jrcxz BigU__zero		; valid zero length!
	push rcx
	shr rcx,32
	jrcxz .D			; dword size
	push 2				; qword size
	pop rcx
	call BigU__from_pool
	pop rcx
	mov [rdi+4],rcx
	retn

.D:	mov ecx,1
	call BigU__from_pool
	pop rcx
	mov [rdi+4],ecx
	retn



BigU__copy:
; another BigU the same value as RSI from pool
	push rsi
	push rcx
	mov ecx,[rsi]
	call BigU__from_pool
	rep movsd
	movsd
	pop rcx
	pop rsi
	retn



BigU__reduce:
; copy part of RSI and free degenerate BigU, return new BigU in RDI
	mov ecx,[rsi]
	jrcxz .fine
	cmp [rsi+rcx*4],0
	jnz .fine
@@:	lea ecx,[rcx-1]
	jrcxz .Z
	cmp [rsi+rcx*4],0
	jz @B

	; could clear pool bits directly

	push qword [rsi]
	mov [rsi],ecx
	call BigU__copy
	pop qword [rsi]
	push rdi
	call BigU__to_pool
	pop rdi
	retn

.Z:	call BigU__to_pool		; reduced to zero
	jmp BigU__zero

.fine:	mov rdi,rsi			; source wasn't degenerate, NOP
	retn



BigU__resize:
; resize RSI to size ECX, worst case allocate new and copy
; check pool bits at end, can this BigU grow?
	int3



BigU__compare:
	mov ecx,[rsi]
	mov edx,[rdi]
.inn:	cmp ecx,edx
	jnz .F
	jrcxz .F
.cmp:	mov edx,[rsi+rcx*4]
	cmp edx,[rdi+rcx*4]
	loopz .cmp
.F:	retn



BigU__abs_sub:
; |a-b| always returns an unsigned value of the same or smaller size
	mov ecx,[rsi]
	mov edx,[rdi]
	test ecx,ecx
	jz BigU__gcd.B
	test edx,edx
	jz BigU__gcd.A

	call BigU__compare.inn
	jnc .no_swap
	xchg rsi,rdi
.no_swap:				; 0 < RDI < RSI
	push rdi
	call BigU__copy			; get working copy of larger value
	pop rsi				; 0 < RSI < RDI
	xor ecx,ecx			; carry flag clear
	jmp @F

.sub:	popfq
	mov eax,[rsi+rcx*4]
	sbb [rdi+rcx*4],eax
@@:	pushfq
	add ecx,1
	cmp [rsi],ecx
	jnc .sub
	popfq
@@:	sbb [rdi+rcx*4],0
	lea ecx,[rcx+1]
	jc @B
	mov rsi,rdi
	jmp BigU__reduce



BigU__gcd:
; RDI <- GCD(RSI,RDI)
	call BigU__compare
	jnz .gcd
.B:	xchg rsi,rdi
.A:	jmp BigU__copy

.gcd:	mov eax,[rsi]
	mov edx,[rdi]
	test eax,eax
	jz .B
	test edx,edx
	jz .A

; copy and in-place shift, favors high entropy least bits. use specialized
; code if that is not the case.

	push rdi
	call BigU__copy
	pop rsi

	push rdi
	call BigU__copy
	pop rsi

	push rsi
	push rdi
  @@:	mov ecx,[rsi+4]
	or ecx,[rdi+4]
	add rsi,4
	add rdi,4
	jrcxz @B
	bsf ecx,ecx
	sub edi,[rsp]
	lea ecx,[rcx+(rdi-4)*8]
	pop rdi
	pop rsi

	push rbp ; destination
	push rcx ; shift







; return temporaries to memory

	pop rsi
	call BigU__to_pool

	pop rsi
	call BigU__to_pool

	retn



BigU__add:
; RDI = RSI ADD RDI
	retn



BigU__mod:
; RDI = RSI MOD RDI
	retn



BigU__div:
; RDI = RSI DIV RDI
	retn



BigU__mulmod:
; RDI = (RSI * RDI) MOD RBP
	retn



BigU__mulmod_2N:
; RDI = (RSI * RDI) MOD 2^N
	retn



BigU__mulmod_Fermat:
; RDI = (RSI * RDI) MOD (2^2^N + 1)
	retn



BigU__2ⁿ−1:
	push rcx
	shr ecx,5
	; get mem in rdi
	mov rdx,rdi
	or eax,-1
	scasd
	rep stosd
	pop rcx
	shl eax,cl
	not eax
	stosd
;	mov rdi,rdx
	retn




; could cache mask values: ((1 shl n) - 1)

struc mod_2ⁿ val*,n*
	. = val and ((1 shl n) - 1)
end struc


struc mod_2ⁿ−1 val*,n*
	local D,N
	D = (1 shl n) - 1
	N = val
	. = val
	while N > D
		. = 0
		while N
			. = . + (N and D)
			N = N shr n
		end while
		N = .
	end while
	if . = D
		. = 0
	end if
end struc


struc mod_2ⁿp1 val*,n*
	local D,N,sign
	D = (1 shl n) - 1
	N = val
	sign = 1
	. = 0
	while N
		if sign
			. = . + (N and D)
			if . > (D+2)
				. = . - D - 2
			end if
		else
			. = . - (N and D)
			if . < 0
				. = . + D + 2
			end if
		end if
		N = N shr n
		sign = sign xor 1
	end while
end struc


struc mod_2ⁿp1 val*,n*
	local D,N,sign
	D = (1 shl n) - 1
	N = val
	sign = 1
	. = 0
	while N
		if sign
			. = . + (N and D)
		else ; force positive
			. = . - (N and D) + D + 2
		end if
		N = N shr n
		sign = sign xor 1
		if ~ N
			if . > (D+2)
				N = .
				. = 0
				sign = 1
			end if
		end if
	end while
end struc


IF __source__=__file__;___TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST

; need a random number generator, seed with time


END IF;____TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST