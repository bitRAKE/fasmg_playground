; verify controls have text value
; RSI : handle array, null terminating
; temp : any local memory location with four bytes to overwrite
; carry flag : control [RSI-8] had no text
macro IsAnyControlEmpty temp,CF=clc
	local H,X
	CF
H:	lodsq
	xchg rcx,rax
	jrcxz X
	mov r8d,4
	lea rdx,[temp]
	call [GetWindowTextW]
	sub eax,1
	jnc H
X:
end macro




; RBX : dialog handle
; RSI : control ID array

H:	lodsb			; byte arrray of control IDs
	movzx edx,al
	mov rcx,rbx
	call [GetDlgItem]
	xchg rcx,rax
	jrcxz X			; invalid handle signals termination
	mov r8d,4
	lea rdx,[temp]
	call [GetWindowTextW]
	sub eax,1
	jnc H
X:

