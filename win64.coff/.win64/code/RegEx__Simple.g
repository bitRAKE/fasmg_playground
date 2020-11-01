; based on: https://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html
;
; By using the Z-flag the code becomes quite concise.


;	^	matches the beginning of the input string
;	$	matches the end of the input string
;	.	matches any single character
;	*	matches zero or more occurrences of the previous character
;	c	matches any literal character c
RegEx__SimpleA:
namespace RegEx__SimpleA
; RSI: pattern to match
; RDI: string to search
	cmp byte [rsi],'^'
	jz start
more:	push rsi rdi
	call here
	pop rdi rsi
	jz _Z
	mov al,0
	scasb			; iterate through input text until zero
	jnz more
_1:	or al,1			; ~Z, not found
_Z:	retn			; Z, found match, RDI start of match, RSI unchanged

term:	cmp byte [rdi],0	; Z flag if input text terminates
	retn

start:	lodsb			; skip '^'
here:	cmp byte [rsi],0
	jz _Z
	cmp word [rsi],'$'
	jz term
	cmp byte [rsi+1],'*'
	jz star
	cmp byte [rdi],0
	jz _1
	cmpsb			; literal match, advance strings
	jz here
	cmp byte [rsi-1],'.'
	jz here
	retn

; match AL*[RSI] at [RDI]
star:	lodsw			; get wild char and '*'
@@:	push rsi rdi
	call here		; must preserve: RSI RDI AL
	pop rdi rsi
	jz _Z
	cmp byte [rdi],0	; stop at string end
	jz _1
	scasb			; advance string
	jz @B			; continue if character match
	cmp al,'.'
	jz @B			; also continue if wild character
	retn
end namespace ; RegEx__SimpleA

; extensions:
;	+	one or more character
;	?	option character
;	`	negation character
;	\\	complex literal or extended characters (utf8)
;	[]	group/range extend character operations
; (?<name>)	labeled range
;
; other comments:
;	- UTF8 use requires abstracting codepoint extraction
;	- easy to adapt to widechar
;







RegEx__SimpleW:
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
