; where f:S->S is some easily-computable function, and x_0 in S.
struc f X*
.=((X)*(X)+C) mod S
end struc


; Floyd's Algorithm:
; find m >= 0 and n >= 1 such that x_(m+n) = x_m,
; then x_(i+n) = x_i for all i >= m.

x = x0
y = x0
j = 0
while x <> y
	j = j + 1
	x f x
	y f y
	y f y
end while
; j is a multiple of n (the period)
; x = x_j, y = x_2j


; Floyd's Algorithm
	mov rbx,rax
	or edi,-1
.out:	add edi,1 ; 2^64 itterations
	or rcx,-1
.inn:	xchg rax,rbx
	call f
	xchg rax,rbx
	call f
	call f
	cmp rax,rbx
	loopnz .inn
	jz .done
; one more for 2^64
	xchg rax,rbx
	call f
	xchg rax,rbx
	call f
	call f
	cmp rax,rbx
	jnz .out
	add edi,1
.done:	push -1
	sub [rsp],rcx
	pop rcx

; RDI:RCX is a multiple of cycle count!




; Brent's Algorithm (B_Q):

u = 0
Q = 2

y = x0
r = 1 shl u ; Q^u
k = 0
done = 0
while ~ done
	x = y
	j = k
	r = Q * r
	while ~ done
		k = k + 1
		y f y
		if x = y
			done = 1
		end if
		if k>= r
			break
		end if
	end while
end while
n = k - j



.out:	mov [.x],rax
	mov [.j],rbx
	shl [.r],1 ; r = Q * r
.inn:	add rbx,1
	call f
	cmp rax,[.x]
	jz .done
	cmp rbx,[.r]
	jc .inn
	jmp .out
.done:	sub rbx,[.j] ; period


