; Van Eck Sequence : https://oeis.org/A181391

; slower due to scanning for last
; RBP array initialized to zero
A181391:
	xor ecx,ecx
	jmp .outer
.found:	sub edx,ecx
	sub [rbp+rcx*4+4],edx
.outer:	mov edx,ecx
	add ecx,1
	js .done
	mov eax,[rbp+rcx*4]
.inner:	cmp eax,[rbp+rdx*4]	; scan previous values for latest value
	jz .found
	sub edx,1
	jns .inner
	jmp .outer
.done:
