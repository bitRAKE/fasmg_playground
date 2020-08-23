; no empty strings, one or more strings
multi_concatenation:
	pop rdx
	xchg rax,rsi
.strcpy:
	pop rsi
.copy:	movsb
	cmp byte [rsi],0
	jnz .copy
.next_string
	cmp qword [rsp],0
	jnz .strcpy
	xchg rax,rsi
	pop rax
	jmp rdx

; inline version of above, only RDI updated
macro MULTICAT sources&
	local str,cpy
	push rsi
	push 0
	iterate S,sources
		indx %%-%+1 ; reverse order
		push S
	end iterate
	jmp str
cpy:	movsb
	cmp byte [rsi],0
	jnz cpy
str:	pop rsi
	test rsi,rsi
	jnz cpy
	pop rsi
end macro
