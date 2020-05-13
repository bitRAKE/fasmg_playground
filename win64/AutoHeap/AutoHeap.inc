; Growing heap with initialization

struc AUTOHEAP
label .
namespace .
	dblst	DOUBLELIST ; linked together to have one exception handler

	BaseAddr	rq 1	;
	Commit		rq 1	;
	Reserved	rq 1	;
	PageInit	rq 1	; function to initialize new pages, page type
	Protection	rd 4	;
	bytes = $ - .
end namespace
end struc

virtual at 0
AUTOHEAP AUTOHEAP
end virtual

assert 0 = AutoHeap.bytes AND (AutoHeap.bytes-1) ; power of two
assert AutoHeap.bytes > 8




; Only needs a reserve size in RCX.
; (...and space for the fifth parameter on stack ;)
AutoHeap__Create_Basic:
	; read/write protection
	push 4
	pop r9
	; (recommended) do nothing initialization
	lea r8,[AutoHeaps__GuardHandler.r]
	; minimal commit size, fixed below to: Granularity - PageBytes
	xor edx,edx
	; any base address
	and [rsp+8*6],0 
	; fall through because we still need to confirm reserve size

ALIGN 64
AutoHeap__Create:
	enter 32,0

	; correct commit/reserve size based on system parameters
	; 1) increase commit size to include guard page
	; 2) expand commit/reserve size to next allocation boundary

	mov eax,[AutoHeaps.PageBytes]
	add rdx,rax
	mov eax,[AutoHeaps.Granularity]
	sub eax,1
	add rcx,rax
	add rdx,rax
	not rax
	and rcx,rax
	and rdx,rax

	mov [FRAME.RCX],rcx	; reserve
	mov [FRAME.RDX],rdx	; commit
	mov [FRAME.R8],r8	; function
	mov [FRAME.R9],r9	; protection

	cmp rdx,rcx			; reserve needs to be >= commit
	cmovc rdx,rcx			;
	; r9: protection
	mov r8d,MEM_RESERVE
	; rdx: size of reserve
	mov rcx,[FRAME.R9 + 8]		; address desired
	call [VirtualAlloc]
	xchg rcx,rax
	jrcxz .no_reserve
	mov [FRAME.R9 + 8],rcx		; if it was zero update it

	mov edx,[AutoHeaps.PageBytes]
	sub [FRAME.RDX],rdx

	mov r9,[FRAME.R9]
	mov r8d,MEM_COMMIT
	mov rdx,[FRAME.RDX]
	; RCX: base address from above
	call [VirtualAlloc]
	xchg rcx,rax
	jrcxz .no_commit

	mov r9,[FRAME.R9]
	or r9d,PAGE_GUARD
	mov r8d,MEM_COMMIT
	mov edx,[AutoHeaps.PageBytes]
	add rcx,[FRAME.RDX]
	call [VirtualAlloc]
	xchg rcx,rax
	jrcxz .no_guard

	; find place for data

	bsf rax,qword[AutoHeaps.heaps]
	jz .no_space_for_heap
	btr dword [AutoHeaps.heaps],eax
	shl eax,bsf AutoHeap.bytes
	lea rax,[AutoHeaps.heaps+rax+8]

	; fill structure
	mov [rax+AUTOHEAP.GuardAddr],rcx; pointer to guard page
	mov rcx,[FRAME.RCX]		; reserve
	mov rdx,[FRAME.RDX]		; commit
	mov r8,[FRAME.R8]		; function
	mov r9,[FRAME.R9]		; protection
	mov r10,[FRAME.R9 + 8]		; base address
	mov [rax+AUTOHEAP.Reserved],rcx	; reserved
	mov [rax+AUTOHEAP.Commit],rdx	; committed
	mov [rax+AUTOHEAP.PageInit],r8	; function for initialization
	mov [rax+AUTOHEAP.Protection],r9d; protection flags for this heap
	mov [rax+AUTOHEAP.BaseAddr],r10

	; put it in front (assume it's being used now)
	DOUBLELIST__INSERT AutoHeaps.root,rax, rcx

	; initilize commit memory
	xchg rax,r10
	; RDX: commit size
	call r8

	; is VEH installed?
	cmp [AutoHeaps.hGuardVEH],0
	jnz .got_VEH

	lea rdx,[AutoHeaps__GuardHandler]
	or ecx,-1			; who doesn't like to be first
	call [AddVectoredExceptionHandler]
	xchg rcx,rax
	jrcxz AutoHeap__Destroy
	mov [AutoHeaps.hGuardVEH],rcx
.got_VEH:
	clc
	leave
	retn

.no_space_for_heap:; too many heaps
.no_guard:; fatal error
.no_commit:; fatal error
	mov r8d,MEM_RELEASE
	xor edx,edx
	mov rcx,[FRAME.R9 + 8]
	call [VirtualFree]		; ignore error
.no_reserve:; memory address/size invalid
	and qword[FRAME.R9 + 8],0	; clear address to also signal problem
	stc
	leave
	retn



ALIGN 64
AutoHeap__Destroy:
	; find heap containing address RCX
	call AutoHeaps__LocateHeap
	jnc .bad

	enter 32,0
	mov [FRAME.RCX],rax
	DOUBLELIST__REMOVE rax, rcx,rdx

	mov r8d,MEM_RELEASE
	xor edx,edx ; free whole address range
	mov rcx,[rax+AUTOHEAP.BaseAddr]
	call [VirtualFree]

	lea rdx,[AutoHeaps.heaps]
	mov eax,dword[FRAME.RCX]
;	sub eax,8 ; the shift clears this bit
	sub eax,edx
	shr eax,bsf AutoHeap.bytes ; divide by power of two
	bts dword[rdx],eax
	cmp qword[rdx],-1
	jnz .more
	; last freed heap removes VEH
	mov rcx,[AutoHeaps.hGuardVEH]
	call [RemoveVectoredExceptionHandler]
	and [AutoHeaps.hGuardVEH],0
.more:	leave
.bad:	retn