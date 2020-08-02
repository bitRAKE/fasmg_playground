align 64
IsStackAvailable:	; 34 bytes
	push rcx	; preserve amount desired
	push rcx
	push rsp
	pop rdx
	push rcx
	push rsp
	pop rcx
	enter 40,0
	call[GetCurrentThreadStackLimits];kernel32 6.2 subsystem required
	leave
	pop rax		; low address of stack
	pop rdx		; high address of stack
	neg rax
	pop rcx

	add rdx,rax	; total stack bytes
	add rax,rsp	; remaining stack bytes

	cmp rax,rcx
; return flags and values:
;	carry flag set if stack bytes insufficient
;	RCX: unchanged, bytes desired on the stack
;	RDX: total stack bytes
;	RAX: bytes on stack - 4 (return address)
	retn



align 64
IsStackAvailable:	; 20 bytes
	xor eax,eax
	push rsp
	pop rdx
	mov rax,[gs:rax+0x30]	; Thread Environment Block (TEB)
	; RDX = remaining stack space
	sub rdx,[rax+0x1478]	; TEB.DeallocationStack, valid for all windows
	cmp rdx,rcx
	retn



	; get stack space needed for stack overflow exception:

	lea rcx,[rsp+32]
	and qword [rcx],0
	call[SetThreadStackGuarantee];kernel32



; Use before ShowWindow to cause Desktop Window Manager(DWM) to exclude the
; window pixels from composition outside of the monitor. 

	mov rcx,[.hWnd]
	mov edx,WDA_MONITOR
	call[SetWindowDisplayAffinity];user32
