format PE64 CONSOLE 6.2
include 'win64wxp.inc'
.code
Quilt:

lea rdi,[_test]

; Two or more '`' are consumed to begin a block comment, and similarly two
; or more are consumed to end the block comment - the comment must consist
; of at least one non-'`' character.
	 

.block:	lodsb
	mov ah,al
	push rdi
	push rsi
	pop rdi
	mov ecx,sizeof _test	;dword[] ; length
	sub ecx,edi		;current
	sub ecx,ebx		;dword[] ; start
;	repz scasb
.single:
	repnz scasb
	jnz .end
	scasb
	jnz .single

	; skip triple ` end by design
	xchg rax,rdi
	pop rdi

.end:

invoke GetStdHandle,STD_OUTPUT_HANDLE
mov [hCon],rax
invoke GetLastError
invoke FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER\
\	; always use these two together
	or FORMAT_MESSAGE_FROM_SYSTEM\
	or FORMAT_MESSAGE_IGNORE_INSERTS,0,rax,0,ADDR lpBuffer,0,0
invoke WriteConsole,[hCon],[lpBuffer],eax,0,0
invoke LocalFree,[lpBuffer]
invoke ExitProcess,eax
.data


label _test: _test_end - $
	db '``',17 dup ' ','``',0
_test_end:


; U+0000..U+007F      00..7F
; U+0080..U+07FF      C2..DF	 80..BF
; U+0800..U+0FFF      E0         A0..BF     80..BF
; U+1000..U+CFFF      E1..EC     80..BF     80..BF
; U+D000..U+D7FF      ED         80..9F     80..BF
; U+E000..U+FFFF      EE..EF     80..BF     80..BF
; U+10000..U+3FFFF    F0         90..BF     80..BF     80..BF
; U+40000..U+FFFFF    F1..F3     80..BF     80..BF     80..BF
; U+100000..U+10FFFF  F4         80..8F     80..BF     80..BF



align 16
; these sets have standard processing
	db $00,$7F	; no extension byte
	db $C2,$DF	; one ext byte
	db $E1,$EC	; two ext bytes
	db $EE,$EF	; two ext bytes
	db $F1,$F3	; three ext bytes

; these are ill-formed sets
	db $80,$C1
	db $F4,$FF

	rb 2 ; padding

; special processing of select values not within (above) groups: E0 ED F0 F4





hCon		rq 1
lpBuffer	rq 1
.end Quilt
