UTF8__Valid_NC:

; RSI string start
; RDI string end

.reset:	cmp rsi,rdi
	jnc .true
	lodsb
	shl al,1
	jnc .reset
	jns .false
	mov ah,al
	cmp al,11110000b
	jnc .false
.more:	shl ah,1
	jnc .reset
	lodsb
	shr al,7
	ja .more ; CF=0 and ZF=0
.false:	stc ; return false
.true:	retn