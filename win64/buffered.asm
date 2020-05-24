struc BUFFERED A=?,B=?,C=?
label .
namespace .
	address	dq A
	length	dd B
	index	dd C
end namespace
end struc


Buffered__New:
	invoke VirtualAlloc,?
	retn


macro BUFFERED__READ buff
end macro


Buffered__Read:
	retn


macro BUFFERED__WRITE buff
	local _
	mov edi,[buff#.index]
	lea eax,[rcx+rdi]
	cmp eax,[buff#.length]
	jbe _
	push rcx
	call Buffered__Flush
	pop rcx
	mov eax,ecx
	xor edi,edi
_:	mov [buff#.index],eax
	add rdi,[buff#.address]
	rep movsb
end macro


Buffered__Write:
; RSI source data to write
; RCX bytes to write
; RBX *BUFFERED object
; RAX used
; RDI used
	mov edi,[rbx+BUFFERED.index]
	lea eax,[rcx+rdi]
	cmp eax,[rbx+BUFFERED.length]
	jbe @F
	push rcx
	call Buffered__Flush
	pop rcx
	mov eax,ecx
	xor edi,edi
@@:	mov [rbx+BUFFERED.index],eax
	add rdi,[rbx+BUFFERED.address]
	rep movsb
	retn


Buffered__Flush:
	cmp [rbx+BUFFERED.index],0
	jz @F
	invoke WriteFile,[out_handle],[rbx+BUFFERED.address],[rbx+BUFFERED.index],_written,0
	mov [rbx+BUFFERED.index],0
@@:	retn
