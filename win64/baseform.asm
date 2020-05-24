UINT64__Baseform:
; RAX number to convert
; RCX number base to use [2,36]
; RDI string buffer of length [65,14] bytes
	push 0
.A:	div rcx
	push qword [digit_table+rdx]
	test rax,rax
	jnz .A

.B:	pop rax
	stosb
	test al,al
	jnz .B
	retn
; RCX unchanged
; RAX 0
; RDI end of null-terminated string

align 64
digit_table db '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ'