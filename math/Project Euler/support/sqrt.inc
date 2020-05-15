;
; REFERENCES:
;
; https://groups.google.com/forum/#!original/comp.sys.arm/mmDEfO9O71M/bWo_Eqvmny8J
; http://www.andrijar.com/algorithms/algorithms.htm
; https://en.wikipedia.org/wiki/Methods_of_computing_square_roots


; with remainder
macro SQRT_REM reg,rem,		prox=RBX,T=RSI,bit=RDI
	local do,zend
	push prox T bit		; preserve temporary registers
	xor	prox,prox
	xor	rem,rem
;How many itterations saved before this becomes a win?
;bsr T,reg
;jz zero ; to xchg instruction
;shr T,1
;xor bit,bit
;bts bit,T
	mov	bit,1 shl 62	; register size - 2
do:	lea	T,[bit+prox]
	add	T,rem
	shr	rem,1
	cmp	reg,T
	jc	zend
	mov	prox,T
	add	rem,bit
zend:	shr	bit,2
	jnz	do
	sub	reg,prox
	xchg	reg,rem
	pop bit T prox
end macro



IF __source__=__file__;___TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.DATA
	buf rb 64
	message db "Square Root Test: "
	result: db "FAIL.",13,10,0
	message.bytes = $ - message
.CODE
Start:	mov rcx,0xFFFF_FFFF_0000_0000
.more:	mov rax,rcx

	SQRT_REM	rax, rbp

	mul rax
	add rax,rbp
	sub rax,rcx
	jrcxz .pass		; want to test zero
	lea rcx,[rcx+1]
	test rax,rax
	jz .more
	jmp .fail
.pass:	test rax,rax
	jnz .fail
	mov dword[result],'pass'
.fail:	invoke WriteConsoleA,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,message,message.bytes,0,0
	invoke	ExitProcess,0
.END Start
END IF;____TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST