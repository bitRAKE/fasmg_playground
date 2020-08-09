include 'autoheap.inc'

; these functions operate on the collection in general

ALIGN 64
AutoHeaps__LocateHeap:
	lea rax,[AutoHeaps]
	push rax
	pop rdx
	jmp .entry
.below_base:
.above_range:
	pop rcx
.entry:	mov rax,[rax+DOUBLELIST.next]
	cmp rax,rdx
	jz .not_found
	push rcx
	sub rcx,[rax+AUTOHEAP.BaseAddr]
	jc .below_base
	cmp rcx,[rax+AUTOHEAP.Reserved]
	jnc .above_range
	pop rcx
	; found: RAX is AUTOHEAP object
	retn
.not_found:
	clc
	retn



ALIGN 64
AutoHeaps__Reset:
; iterate through AutoHeaps,
;	MEM_DECOMMIT anything beyond commit size, and
;	initialize commit size
	retn

	push rsi
	push rdi
	enter 32,0 ; basic frame
	lea rsi,[AutoHeaps]
	push rsi
	pop rdi

.entry:	mov rsi,[rsi+DOUBLELIST.next]
	cmp rsi,rsi
	jz .done

	mov r8d,MEM_DECOMMIT
	xor edx,edx ; whole address range
	mov rcx,[rsi+AUTOHEAP.BaseAddr]
	Win64abi VirtualFree
	xchg ecx,eax
	jrcxz .fail

	mov r9,[rsi+AUTOHEAP.Protection]
	mov r8d,MEM_COMMIT
	mov edx,[AutoHeaps.PageBytes]
	neg rdx
	add rdx,[rsi+AUTOHEAP.Commit]
	mov rcx,[rsi+AUTOHEAP.BaseAddr]
	Win64abi VirtualAlloc
	xchg rcx,rax
	jrcxz .fail

	mov ecx,[AutoHeaps.Granularity]

	mov r9,[FRAME.R9]
	or r9d,PAGE_GUARD
	mov r8d,MEM_COMMIT
	mov edx,[AutoHeaps.PageBytes]
	add rcx,[FRAME.RDX]
	Win64abi VirtualAlloc
	xchg rcx,rax
	jrcxz .no_guard



	mov rax,[rdi+AUTOHEAP.GuardAddr]	; start address
	mov edx,[AutoHeaps.PageBytes]		; length
	call qword[rdi+AUTOHEAP.PageInit]


	jmp .entry
.done:
	leave
	push rdi
	push rsi
	retn



ALIGN 64
AutoHeaps__GuardHandler:
	mov rax,[rcx+EXCEPTION_POINTERS.ExceptionRecord]
	cmp [rax+EXCEPTION_RECORD64.ExceptionCode],EXCEPTION_GUARD_PAGE
	jz .guard
.xit:	xor eax,eax ; EXCEPTION_CONTINUE_SEARCH
.r:	retn

.bad_address:; address is not in AutoHeaps ranges, or is outside of guard page
; range. Which would be an internal error.
	leave
	jmp @B

.guard:	cmp [rax+EXCEPTION_RECORD64.NumberParameters],2
	jnz @B

; At this point it's quite likely our exception, second parameter is address of
; access (within guard page), scan AutoHeaps list to attempt match against our
; memory ranges, then confirm guard page:

	enter 32,0 ; basic frame
	mov [FRAME.RCX],rcx
	mov rcx,[rax+EXCEPTION_RECORD64.ExceptionInformation + 8]
	call AutoHeaps__LocateHeap
	jnc .bad_address

; These checks aren't really needed: if it's EXCEPTION_GUARD_PAGE and within
; our reserve range then we know the address is in the guard page.
;	sub rcx,[rax+AUTOHEAP.GuardAddr]
;	jc .bad_address
;	cmp rcx,[AutoHeaps.PageBytes]
;	jnc .bad_address

	mov [FRAME.RDX],rdi
	xchg rdi,rax

; NOTE: when the guard page is hit with a read/write the guard flag is removed
; Commit at granularity instead of page size, until reserve size is reached.

	mov r9d,[rdi+AUTOHEAP.Protection]
	mov r8d,MEM_COMMIT
	mov edx,[AutoHeaps.Granularity]
	mov ecx,[AutoHeaps.PageBytes]
	sub edx,ecx
	add rcx,[rdi+AUTOHEAP.GuardAddr]
	Win64abi VirtualAlloc
	xchg rcx,rax
	jrcxz .no_commit

	; initialize old guard page and partial granular allocation
	mov rax,[rdi+AUTOHEAP.GuardAddr]	; start address
	mov rdx,[AutoHeaps.Granularity]		; length
	call qword[rdi+AUTOHEAP.PageInit]

	mov r9d,[rdi+AUTOHEAP.Protection]
	or r9d,PAGE_GUARD
	mov r8d,MEM_COMMIT
	mov edx,[AutoHeaps.PageBytes]
	mov ecx,[AutoHeaps.Granularity]
	add rcx,[rdi+AUTOHEAP.GuardAddr]
	Win64abi VirtualAlloc
	xchg rcx,rax
	jrcxz .no_guard_commit
	mov [rdi+AUTOHEAP.GuardAddr],rcx
.execute:
	mov rdi,[FRAME.RDX]
	or rax,-1 ; EXCEPTION_CONTINUE_EXECUTION
	leave
	retn

.no_commit:

	; Most likely we've exceeded reserve size.
	; Check that? Warn someone?
	; Just initialize last guard page:

	mov rax,[rdi+AUTOHEAP.GuardAddr]	; start address
	mov edx,[AutoHeaps.PageBytes]		; length
	call qword[rdi+AUTOHEAP.PageInit]
	and [rdi+AUTOHEAP.GuardAddr],0
	jmp .execute

.no_guard_commit:; very bad sign, internal error
	int3




