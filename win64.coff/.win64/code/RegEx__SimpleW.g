; coding: utf-8, tab: 8
include '../../.win64/coffms64.g'

section '.flat' code readable executable align 64

public RegEx__SimpleW:
namespace RegEx__SimpleW
	cmp word [rsi],'^'
	jz start
more:	push rsi rdi
	call here
	pop rdi rsi
	jz _Z
	xor eax,eax
	scasw			; iterate through input text until zero
	jnz more
_1:	or al,1			; ~Z, not found
_Z:	retn			; Z, found match, RDI start of match, RSI unchanged

term:	cmp word [rdi],0	; Z flag if input text terminates
	retn

start:	lodsw			; skip '^'
here:	cmp word [rsi],0
	jz _Z
	cmp dword [rsi],'$'
	jz term
	cmp word [rsi+2],'*'
	jz star
	cmp word [rdi],0
	jz _1
	cmpsw			; literal match, advance strings
	jz here
	cmp word [rsi-2],'.'
	jz here
	retn

star:	lodsd			; get widechar and '*'
@@:	push rsi rdi
	call here		; must preserve: RSI RDI AL
	pop rdi rsi
	jz _Z
	cmp word [rdi],0	; stop at string end
	jz _1
	scasw			; advance string
	jz @B			; continue if character match
	cmp ax,'.'
	jz @B			; also continue if wild character
	retn
end namespace ; RegEx__SimpleW
