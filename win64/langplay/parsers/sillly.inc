; This is a silly language to give examples of different adaptations
; of popular language mechanics to the basic four state method:
;
; comments:
;		end of line type ';'
;		inline `text`
;		block ``text``		(consumes new lines)
;
; scoping:
;		whitespace counting at start of line
;		keyword: BEGIN/END
;
; line continuation (consumes line termination character):
;	'\' or ','
;
; number groups are of the form: 0...(base)
;	range checking on base and digits
;
; letter groups:
;
; symbol groups:
;
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
	call Sillly
	sub r11,rdi ; unused bytes
	sub [result_bytes],r11 ; actual output bytes (not including null byte)
	xor eax,eax
	stosb
	pop rbx rdi rsi

	retn



Sillly:
namespace Sillly
	mov rbx,tab_UTF8

line:	; reset line flags
	mov [Line_Scope_Depth],-2


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
letter_start:				; [A-Za-z][0-9A-Za-z]*
	lea rdx,[rsi-1]
letter_more:
	lodsb
	xlatb
	test al,1100_0000b
	jpe letter_end
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
number_start:				; [0-9][0-9A-Za-z]*( '(' [0-9][0-9]? ')' )?
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
other_start:				; ? control class ?
	and eax,0x3F
	cmp byte [Control_Table-1],al
	jbe _errorX
	push rax
	call qword [Control_Table+rax*8]
	jc _error
	pop rax
	jz init
	jmp line
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
end namespace ; Sillly


; NOTE: CF=1 error code on stack
;	ZF=1 continues line processing


EndOfInput:
	stc
	retn

CommentLine:
  @@:	lodsb
	test al,al
	jz EndOfInput
	cmp al,10
	jz @F
	cmp al,13
	jnz @B
  @@:	sub rsi,1
	ret ; CF = 0 and ZF = 0

IgnoreControl:
	xor eax,eax
	ret ; CF = 0 and ZF = 1

CommentSuper:
	cmp byte [rsi],'`'
	jz .block
  @@:	lodsb
	test al,al
	jz EndOfInput
	cmp al,13 ; FIX: any line terminator
	jz EndOfInput
	cmp al,'`'
	jnz @B
	ret ; CF = 0 and ZF = 1
.block:	lodsb ; skip triple ` start by design
	mov ah,al
	push rdi
	push rsi
	pop rdi
	mov ecx,dword[] ; length
	sub ecx,edi	; current
	sub ecx,dword[] ; start
@@:	repnz scasb
	jnz @F
	scasw ; ?
;	cmp [rdi],ax
	sub ecx,2
	ja @B
	; skip triple ` end by design
@@:	xchg rax,rdi
	pop rdi
	jnz EndOfInput ; end of input reached before closing ``
; update RSI
	clc
	ret ; CF = 0 and ZF = 1

SpaceScoping:
	; NOTE: would be (-2) if we didn't already have a space
	cmp [Line_Scope_Depth],-1
	jz .scope_space
	clc
	retn
.scope_space:
	xchg rdi,rsi
	or ecx,-1
	mov al,' '
	repz scasb
	lea rdi,[rdi-1]
	sub [Line_Scope_Depth],ecx ; scope depth
	xchg rdi,rsi
	clc
	ret ; CF = 0 and ZF = 1

ContinueLine:
	cmp byte [rsi],13
	jnz .not_special
	add rsi,1 ; skip newline
	; back-slashes are consumed,
	; but commas are still part of syntax
	cmp byte [rsi-2],','
	jnz @F
	; output comma
	pop rax
	pop rax
	jmp Sillly.init
@@:	clc
	retn
.not_special:
	pop rax
	pop rax
	jmp Sillly.symbol_start



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



CONTROL_ENDOFINPUT	= 0
CONTROL_IGNORE		= 1
CONTROL_COMMENTLINE	= 2
CONTROL_COMMENTSUPER	= 3
CONTROL_SCOPE		= 4
CONTROL_CONTINUE	= 5

align 64
rb 7
db (sizeof Control_Table) shr 3
Control_Table Δ dq \
	EndOfInput,\
	IgnoreControl,
	CommentLine,\
	CommentSuper,\
	ScopingSpace,\
	ContinueLine

Error_Table dq \
	Error_EOI,\
	Error_NoError,\
	Error_EOI,\
	Error_SuperClose,\
	Error_NoError,\
	Error_CtlRng
; Unassigned errors can be appropriated where multiple errors are needed for a particular control state.

Error_EOI		Δ db sizeof Error_EOI-1,	'end of input expected'
Error_NoError		Δ db sizeof Error_NoError-1,	"this doesn't happen"
Error_SuperClose	Δ db sizeof Error_SuperClose-1,	"comment not closed"
Error_CtlRng		Δ db sizeof Error_CtlRng-1,	'unsupported control byte'



CLASS_NUMBER	= 0000_0000b
CLASS_LETTER	= 0100_0000b
CLASS_SYMBOL	= 1000_0000b
CLASS_CONTROL	= 1100_0000b

align 64 ; constant
tab_UTF8:
repeat 256,i:0
	match A =i B,: 9 10 11 12 13 :
		db CONTROL_IGNORE or CLASS_CONTROL
	else
	if i > 127
		db $3F or CLASS_LETTER
	else if i = 0
		db CONTROL_ENDOFINPUT or CLASS_CONTROL
	else if i = ';'
		db CONTROL_COMMENTLINE or CLASS_CONTROL
	else if i = '`'
		db CONTROL_COMMENTSUPER or CLASS_CONTROL
	else if i = ' '
		db CONTROL_SCOPE or CLASS_CONTROL
	else if i = '\'
		db CONTROL_CONTINUE or CLASS_CONTROL
	else if i = ','
		db CONTROL_CONTINUE or CLASS_CONTROL
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



align 64 ; this space is for parser state information

; total state

; line state
Line_Scope_Depth rd 1



