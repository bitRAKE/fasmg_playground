; The language defined by this parser is:
;	input	= token* 0x00
;	token	= letter | number | symbol | comment | CTRL
;*	letter	=	[AZaz]+
;*	number	=	[09]+
;*	symbol	=	(-([AZaz09]|CTRL))+
;	comment	=	;* CR
;	CR	=	0x0D
;	CTRL	=	[0x09-0x0D]+
;
;*these matchers are greedy

Tokenizer:
	enter 32,0
	; assume every token is one byte w/o whitespace! yikes!
	imul rax,[input_bytes],27
	mov [result_bytes],rax
	invoke HeapAlloc,[hHeap],4,[result_bytes]
	mov [result_buffer],rax
	leave

	push rsi rdi rbx
	mov rsi,[input_buffer]
	mov r11,[result_bytes]
	mov rdi,[result_buffer]
	add r11,rdi ; memory limit of output
	call FourState
	sub r11,rdi ; unused bytes
	sub [result_bytes],r11 ; actual output bytes (not including null byte)
	xor eax,eax
	stosb
	pop rbx rdi rsi

	retn



CLASS_NUMBER	= 0000_0000b
CLASS_LETTER	= 0100_0000b
CLASS_SYMBOL	= 1000_0000b
CLASS_CTRL	= 1100_0000b

CTRL_ENDOFINPUT	= 0
CTRL_LINECOMMENT= 1
CTRL_IGNORE	= 2


FourState:
namespace FourState
	mov rbx,tab_UTF8
; go from the empty class to the class of first character
init:	lodsb
	xlatb				; byte classes and decoding
	test al,1100_0000b
	jz number_start
	jns letter_start
	jpe other_start
symbol_start: ; punc, math, etc ...	; state initialization
	lea rdx,[rsi-1]			; preserve name start
symbol_more:
	lodsb
	xlatb
	test al,1100_0000b
	jns symbol_end
	jpo symbol_more
symbol_end:				; state termination
	push rax
	pushfq
	lea rcx,[rsi-1]
	mov rax,' symbol' or ($0D shl 56)
	call _display
	popfq
	pop rax
	js other_start
	jpe number_start
letter_start:
	lea rdx,[rsi-1]
letter_more:
	lodsb
	xlatb
	test al,1100_0000b
	jns letter_more
letter_end:
	push rax
	pushfq
	lea rcx,[rsi-1]
	mov rax,' letter' or ($0D shl 56)
	call _display
	popfq
	pop rax
	jpo symbol_start
	js other_start
number_start:
	lea rdx,[rsi-1]
number_more:
	lodsb
	xlatb
	test al,1100_0000b
	jz number_more
number_end:
	push rax
	pushfq
	lea rcx,[rsi-1]
	mov rax,' number' or ($0D shl 56)
	call _display
	popfq
	pop rax
	jns letter_start
	jpo symbol_start
other_start:
	and eax,0x3F
	cmp byte [Control_Table-1],al
	jbe _errorX
	push rax
	call qword [Control_Table+rax*8]
	jc _error
	pop rax
	jmp init
_errorX:
	movzx eax,byte [Control_Table-1]
	push rax
_error:
	mov rax,('ERROR: ' shl 8) or 13
	stosq
	pop rax
	push rsi
	mov rsi,[Error_Table+rax*8]
	lodsb
	movzx ecx,al
	rep movsb
	pop rsi
	retn
end namespace ; FourState



EndOfInput:
	stc
	retn

LineComment:
  @@:	lodsb
	test al,al
	jz EndOfInput
	cmp al,10
	jz @F
	cmp al,13
	jnz @B
  @@:	sub rsi,1

IgnoreCtrl:
	clc
	retn


_display:
	push rax

	; don't exceed buffer - just give up if full
	mov eax,ecx
	sub eax,edx
	lea rax,[rdi+rax+8*3+3]
	cmp r11,rax
	jc .buffer_full

	mov rax,('class:' shl 16) or $090D
	stosq
	pop rax
	stosq
	mov rax,('value: ' shl 8) or $09
	stosq
	mov al,'"'
	stosb
	; copy data string to output
	push rsi
	mov rsi,rdx
	sub ecx,edx
	rep movsb
	stosb
	pop rsi
	retn

.buffer_full:	; just don't produce more output
	pop rax
	retn


.data

align 64
rb 7
db (sizeof Control_Table) shr 3
Control_Table Δ dq \
	EndOfInput,\
	LineComment,\
	IgnoreCtrl

Error_Table dq \
	Error_EOI,\
	Error_EOI,\
	Error_NoError,\
	Error_CtlRng


Error_EOI	Δ db sizeof Error_EOI-1,	'end of input expected'
Error_NoError	Δ db sizeof Error_NoError-1,	"this doesn't happen"
Error_CtlRng	Δ db sizeof Error_CtlRng-1,	'unsupported control byte'





align 64
tab_UTF8:
repeat 256,i:0
	match A =i B,: 9 10 11 12 13 32 :
		db CTRL_IGNORE or CLASS_CTRL
	else
	if i > 127
		db $3F or CLASS_LETTER
	else if i = 0
		db CTRL_ENDOFINPUT or CLASS_CTRL
	else if i = '#'
		db CTRL_LINECOMMENT or CLASS_CTRL
	else if (i >= 'A') & (i <= 'Z')
		db (i-'A'+10) or CLASS_LETTER
	else if (i >= 'a') & (i <= 'z')
		db (i-'a'+10) or CLASS_LETTER
	else if (i >= '0') & (i <= '9')
		db (i-'0') or CLASS_NUMBER
	else
		db (i and $3F) or CLASS_SYMBOL
	end if
	end match
end repeat
