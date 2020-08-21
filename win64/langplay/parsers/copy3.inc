Tokenizer:
	enter 32,0
	imul rax,[input_bytes],3
	mov [result_bytes],rax
	invoke HeapAlloc,[hHeap],4,[result_bytes]
	mov [result_buffer],rax

push rsi rdi
mov rdi,[result_buffer]
mov edx,3
.copy:	mov rcx,[input_bytes]
	mov rsi,[input_buffer]
	rep movsb
.join:	cmp byte [rdi-1],0
	jnz @F
	sub rdi,1
	sub [result_bytes],1
	jmp .join
@@:	sub edx,1
	jnz .copy
pop rdi rsi

	leave
	retn

.data