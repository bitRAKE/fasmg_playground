; based on: https://www.cs.princeton.edu/courses/archive/spr09/cos333/beautiful.html
;
; By using the Z-flag the code becomes quite concise.


;	^	matches the beginning of the input string
;	$	matches the end of the input string
;	.	matches any single character
;	*	matches zero or more occurrences of the previous character
;	c	matches any literal character c
RegEx__Simple:
namespace RegEx__Simple
; RSI: pattern to match
; RDI: string to search
	cmp byte [rsi],'^'
	jz start
more:	push rsi rdi
	call here
	pop rdi rsi
	jz _Z
	mov al,0
	scasb		; iterate through input text until zero
	jnz more
_1:	or al,1		; ~Z, not found
_Z:	retn		; Z, found match, RDI start of match, RSI unchanged

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
	push rsi rdi
	call here		; must preserve: RSI RDI AL
	pop rdi rsi
	jz _Z
	cmp byte [rdi],0	; stop at string end
	jz _1
	scasb			; advance string
	jz star			; continue if character match
	cmp al,'.'
	jz star			; also continue if wild character
	retn

end namespace ; RegEx__Simple
