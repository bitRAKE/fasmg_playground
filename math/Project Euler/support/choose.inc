ALIGN 64
; 39 bytes, EAX: n, ECX: k, recursive O(k)
Binomial:
Choose:	lea edx,[rcx*2]
	jrcxz .k0
	; n >= k > 0
	cmp eax,edx
	jnc .def
	; 2k > n >= k > 0
	sub ecx,eax
	neg ecx
.def:	push rcx	; k
	push rax	; n
	sub ecx,1
	sub eax,1
	call Choose
	pop rdx
	pop rcx
	mul rdx
	div rcx
	retn
.k0:	lea eax,[rcx+1] ; mov eax,1 ; push 1 / pop rax
	retn
; ECX: k or n-k
; RDX: used
; RAX: Choose(EAX,ECX)
