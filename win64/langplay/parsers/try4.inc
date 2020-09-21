; This is a silly language to give examples of different adaptations
; of popular language mechanics to the basic four state method:
;
; comments:
;		end of line type ';'
;		inline `text`
;		block ``text``		(consumes new lines)
;
; Two or more '`' are consumed to begin a block comment, and similarly two
; or more are consumed to end the block comment - the comment must consist
; of at least one non-'`' character. Comments are a token separator.
;
; scoping:
;		1. whitespace counting at start of line
;		2. keyword: BEGIN/END
;
; line continuation (consumes line termination character):
;	'\' or ','
;
; number groups:
;	must begin with a decimal digit
;	use subscripts to indicate base ₀₁₂₃₄₅₆₇₈₉
;	range checking on digits
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

line:	; reset line flags
	or [Line_Scope_Depth],-1

; go from the empty class to the class of first character
init:	mov rbx,tab_UTF8		; do this here to free up RBX sometimes
	lodsb
	xlatb				; byte classes and decoding
	test al,1100_0000b
	jz number_start
	jns letter_start
	jpo symbol_start
	jmp other_start

number_start:				; [09](_|[09AZaz])*[₀₉]*
	push rsi			; preserve start address for display
	mov ecx,eax
number_more:
	cmp ecx,eax
	cmovc ecx,eax			; keep largest digit
number_space:
	lodsb
	xlatb
	test al,1100_0000b
	jns number_more
	cmp byte [rsi-1],"_"		; allow spacers inside number
	jz number_space
number_end:
	and ecx,0011_1111b
	sub rsi,1
; validate number:
;  - only digits in range of base are checked
;  - trailing number space is okay (e.x. 1020_₃)
	push rcx
	push 10
	mov ebx,$2080 ; subscript range base
	call UTF8__u64_FromDecimalRange
	pop rdx ; default base
	cmovz rax,rdx
	pop rdx ; largest digit in number
	cmp rdx,rax
	mov rax,' !ERROR' or ($09 shl 56)
	jc @F
	mov rax,' number' or ($09 shl 56)
@@:	pop rdx
	mov rcx,rsi
	call _display
	jmp init

symbol_start: ; punc, math, etc ...	; state initialization
	push rsi			; preserve start
symbol_more:
	lodsb
	xlatb
	test al,1100_0000b
	jns symbol_end
	jpo symbol_more
symbol_end:				; state termination
	pop rdx
	push rax
	pushfq
	lea rcx,[rsi-1]
	mov rax,' symbol' or ($09 shl 56)
	call _display
	popfq
	pop rax
	js other_start
	jpe number_start
letter_start:				; [A-Za-z][0-9A-Za-z]*
	push rsi			; preserve start
letter_more:
	lodsb
	xlatb
	test al,1100_0000b
	jns letter_more
letter_end:
	pop rdx
	push rax
	pushfq
	lea rcx,[rsi-1]
	mov rax,' letter' or ($09 shl 56)
	call _display
	; if token is a keyword then execute command
	popfq
	pop rax

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
; errors don't need to be fast, we could linear scan and avoid the table
; the errors could also indicate if they are continuable or terminate
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
;	CF=0 no error
;		ZF=1 continue line
;		ZF=0 line ended/reset


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

IgnoreControl: ; breaks token groups
	xor eax,eax
	ret ; CF = 0 and ZF = 1

CommentSuper:
	cmp byte [rsi],'`'
	jz .block
  @@:	lodsb
	test al,al
	jz EndOfInput ; (error: unexpected end of input)
; FIX: any line terminator
	cmp al,13
	jz EndOfInput ; (warning: inline comment not closed)
	cmp al,'`'
	jnz @B
	ret ; CF = 0 and ZF = 1

.block:	lodsb			; get second block comment char
	mov rcx,[input_bytes]
	add rcx,[input_buffer]
	sub rcx,rsi		;current
	push rdi
	push rsi
	pop rdi
	repz scasb		; skip (`)*
.single:
	repnz scasb		; skip -(`)+
	jnz .X			; error to end without reaching a ``
	lea rsi,[rdi+1]
	repz scasb		; skip (`)+
	cmp rsi,rdi		; how many `?
	jnc .single		; one doesn't count
; point at following byte - no matter what it is
	lea rsi,[rdi-1]		; skip comment block
	pop rdi
	xor eax,eax
	retn ; CF = 0 and ZF = 1, always continue line processing after comment

.X:	pop rdi
	stc
	retn


SpaceScoping:
	; NOTE: would be (-2) if we didn't already have a space
	cmp [Line_Scope_Depth],-1
	jnz .separator
	xchg rdi,rsi
	or ecx,-1
	mov al,' '
	repz scasb
	lea rdi,[rdi-1]
	sub [Line_Scope_Depth],ecx ; scope depth
	xchg rdi,rsi
.separator:
	xor eax,eax
	ret ; CF = 0 and ZF = 1


ContinueLine:
	mov ah,[rsi-1] ; preserve continue type

	; need to consume end of line type comment, too
	cmp byte [rsi],';'
	jnz .no_comment

	; same as above :/ Capture_Until_EOL function needed
@@:	lodsb
	test al,al
	jz EndOfInput ; FIX: this is an error, "continuation expected", "unexpected end of file"
	cmp al,10
	jz @F
	cmp al,13
	jnz @B
@@:	; eol consumed already
	jmp .got_eol

.no_comment:
	; NOTE: this is specific to RichEdit UTF8 conversion
	cmp byte [rsi],13
	jnz .not_special
	add rsi,1 ; skip newline
.got_eol:
	; back-slashes are consumed,
	; but commas are still part of syntax
	cmp ah,','
	jnz @F
	; FIX: output comma
@@:	clc
	retn

.not_special:
	pop rax
	pop rax
	jmp Sillly.symbol_start




_display:
	push rax
	; NOTE: RDX is one byte past start of display string, just to reduce code elsewhere
	lea rdx,[rdx-1]
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



; Avoid spending too long on letter strings by pre-check for subscript when
; first character is a letter in range [AZaz].

UTF8r__CreateNumber:
; if string starts with a number, but is invalid set CF "error: number digits outside of base range"
; if number starts with a letter, but is invalid number set ZF and preserve RSI
.precheck:
; subscripts are a string of bytes with the high-bit set. So, back up the end pointer and resolve the base first.
	push rsi
	mov rsi,rdi
@@:	sub rsi,1
	test byte[rsi],$80
	jnz @B
	add rsi,1
	cmp rsi,rdi
	jnz .try_base
.letter:
	pop rsi
	retn
.try_base:
	mov ebx,$2080 ; subscript range base
	call UTF8__u64_FromDecimalRange
	jz .letter
	cmp rsi,rdi
	jnz .invalid_psuedo_number_base
	; check digits against base RAX

	retn
.invalid_psuedo_number_base:
	xor eax,eax
	jmp .letter



; NOTE: assume UTF8 is well-formed, no error checking
UTF8__CharToUTF32:
	xor eax,eax
	lodsb
	test al,al
	js .ext
	retn

.ext:	not al
	or edx,-1
	bsr ecx,eax
	not al
	shl edx,cl
	mov ecx,eax
	and eax,edx
	shl eax,8
	shl cl,2
.go:	lodsb
	shl al,2
	shl eax,6
	shl cl,1
	jc .go
	shr eax,8
	ret

; given a codepoint digit base, convert the number at RSI
; RSI is only advanced past valid digits, next digit is not in range
; ZF set if no number in range present
UTF8__u64_FromDecimalRange:
	push rbp
	push rsi
	xor ebp,ebp
.next_char:
	push rsi
	call UTF8__CharToUTF32
	sub eax,ebx
	jc .rangex
	cmp eax,10
	jnc .rangex
	pop rdx
	; FIX: check for number overflow, use CF
	imul rbp,10
	add rbp,rax
	jmp .next_char
.rangex:
	pop rsi
	xchg rax,rbp
	; were there any digits?
	cmp [rsp],rsi
;	jz .no_number ; just use Z flag
	pop rdx
	pop rbp
	retn

.data


; :update: refactor iterate on <id,func,error> to create structures

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
	IgnoreControl,\
	CommentLine,\
	CommentSuper,\
	SpaceScoping,\
	ContinueLine

; Most control states have a default error. Unassigned errors can be appropriated where multiple errors are needed for a particular control state.
Error_Table dq \
	Error_EOI,\
	Error_NoError,\
	Error_EOI,\
	Error_SuperClose,\
	Error_NoError,\
	Error_CtlRng

Error_EOI		Δ db sizeof Error_EOI-1,	'end of input expected'
Error_NoError		Δ db sizeof Error_NoError-1,	"this doesn't happen"
Error_SuperClose	Δ db sizeof Error_SuperClose-1,	"comment not closed"
Error_CtlRng		Δ db sizeof Error_CtlRng-1,	'unsupported control byte'



; lexical classes
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
	if i > 127 ; UTF8 lexically differentiated into one class
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
Keyword_Scope_Depth rd 1




; Problems with RichEdit control:
;	1. Conversion to UTF8
;		a. subscript, superscript digits become ASCII digits,
;		   not UTF8 codepoints unless they already were.
;
;
; More general solution for number token would detect subscripts and backtrack;
; this way, FFFF_FFFF₁₆ would be a valid number and not a letter token. This
; could be implemented by checking for number at hash map insert. For the sake
; of readablity this is highly desirable.
;
; Also consider implentation of other encodings: Base32 (various forms),
; Base64, etc. We want an easy to read/use syntax with custom conversion
; to binary.
;
;