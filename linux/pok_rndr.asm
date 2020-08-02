; https://github.com/TM35-Metronome/metronome

	enter buflen,0
	mov r14,0
	mov r13,0
read_more:
	test r13,r13
	js last_line
	; preserve partial

	mov rsi,r15
	mov rdi,rsp
	mov rcx,r14
	push rcx
	rep movsb
	pop rdx

	sub rdx,buflen
	neg rdx			; length for read

	mov r14,rdx		; preserve for scan
	mov r15,rdi		; preserve for scan

	; fill remainder

	mov rsi,rdi		; address
	mov eax,0
	mov edi,0
	syscall
	mov r13,rax
	sub r13,r14		; negative if no more data to read

	; scan for line end

	mov rcx,r14
	mov rdi,r15
scan_more:
	mov al,10
	repnz scasb
	jnz read_more

; parse line [R15,RDI]

	push rdi
	push rcx

	lea rsi,[template_starter]
	mov rdi,r15
	jz found_starter

	lea rsi,[template_pokemons]
	mov rdi,r15
	jz found_pokemons

; ...





	; no parsing match, just output

	mov rdx,rdi		; length
	sub rdx,r15
	mov rsi,r15		; address
	mov eax,1
	mov edi,1
	syscall

	; moved past found string and continue

	pop r14
	pop r15
	jmp scan_more





ParseNumberS:
; rsi : buffer to read characters from
; note : can read past end of buffer (terminate with non-number to prevent)
	xor eax,eax
	or ecx,-1 ; non-number flag
ParseNumber_more:
	mov cl,[rsi]
	add rsi,1
	sub cl,'0'
	jc ParseNumber_done
	cmp cl,10
	jnc ParseNumber_done
	mov ecx,cl ; clear number flag
	imul rax,10
	add rax,rcx
	jmp ParseNumber_more
ParseNumber_done:
	sub rsi,1		; first non-digit char on return
	test ecx,ecx		; set S flag if not number
	retn





String__MatchZ:
; rdi = source string
; rsi = template
	lodsb			; get length
	movzx ecx,al		; extend length into RAX
	repz cmpsb		; compare
; Z flag if template matches
	retn

template_starter db 10,".starters["
template_pokemons db 10,".pokemons["



macro STRING__MatchZ src,lit
	local do,bytes
	push bytes
	call do
	bytes = do - $
	db lit
do:	pop rsi
	pop rcx
	repz cmpsb
end macro

macro STRING__Copy dest,src
	rep movsb
end macro

macro STRING__Find dest,src
	repnz scasb
end macro





; The flexiblity of the tree structure allows early matching of more likely
; canidates, so the full depth of the tree does not need to be searched. Holes
; can be filled with zero [non-token] bytes allowing any tree segmenting.

TreeTokenScan:
	mov al,[rsi]
	xor ebx,ebx
	movzx ecx,byte [base]	; tree depth
	sub rsi,-1		; instead of ADD RSI,1 : to set carry flag
;	stc
@@:	adc ebx,ebx
	cmp al,[base+rbx*8]
	loopnz @B
	jnz not_found

; need to diferenciate all tokens starting with the same letter

; use index and length to fast match rest of token

	movzx ecx,byte [token_length]
	mov rax,[rsi] ; nine byte limit?
	; upper case and clip tail bytes
	and rax,[_filter_bytes_ + rcx*8]
	and rdx,[_filter_bytes_ + rcx*8]
	cmp rax,rdx
	jnz not_found







