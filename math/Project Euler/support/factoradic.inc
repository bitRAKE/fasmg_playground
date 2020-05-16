; REFERENCES:
;	https://wikipedia.org/wiki/Factorial_number_system

;   integer: factoradic form
;	  0: 2				0!
;	  1: 1 3			1!
;	  2: 0 1 4			2!
;	  3: 1 1 4
;	  4: 0 2 4
;	  5: 1 2 4
;	  6: 0 0 1 5			3!
;	 24: 0 0 0 1 6			4!
;	120: 0 0 0 0 1 7		5!
;	720: 0 0 0 0 0 1 8		6!
;      5040: 0 0 0 0 0 0 1 9		7!
;     40320: 0 0 0 0 0 0 0 1 A		8!
;    362880: 0 0 0 0 0 0 0 0 1 B	9!
;   3628799: 1 2 3 4 5 6 7 8 9 B	10!-1
;	(... works for 64-bit range ...)
;  121645100408832000: 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 L = 19!
; 2432902008176639999: 1 2 3 4 5 6 7 8 9 A B C D E F G H I J L = 20! - 1
;18446744073709551615: 1 1 2 0 0 0 5 3 8 0 5 3 5 3 F 3 4 C B 7 M = 20! + ...


; convert stack QWORD to factoradic form
; strip zero place, store in [RDI]
macro INTEGER__Factoradic reg=RCX
	local l,x
	push 1
	pop reg
l:	pop rax
	xor edx,edx
	add reg32.reg,1
	test rax,rax
	jz x
	div reg
	push rax
	xchg eax,edx
	stosb
	jmp l
x:	xchg eax,reg32.reg
	stosb
end macro
; REG:RDX: 0
; RAX: digits + 1
; RDI += RAX-1 




; convert [RSI] factoradic form to integer
; no leading zero, terminates with invalid digit
macro FACTORADIC__Integer reg=RBX,reg0=RBP,reg1=RCX
	local l,x
	xor reg32.reg,reg32.reg
	lea reg32.reg1,[reg+1]
	lea reg32.reg0,[reg+1]
l:	cmp reg8low.reg1,[rsi]
	jc x
	xor eax,eax
	add reg32.reg1,1
	lodsb
	mul reg0
	imul reg0,reg1
	add reg,rax
	jmp l
x:
end macro
; REG: result interger
; REG0:REG1:RAX unknown
; RDX: 0
; RSI +++



IF __source__=__file__;___TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.DATA
	buf rb 64
	message db "Factoradic Test: "
	result: db "____.",13,10,0
	message.bytes = $ - message
.CODE
Start:	push -128 ; test range [-127,126]
.chk:	add qword[rsp],1
	cmp qword[rsp],127
	mov ebx,"pass"
	jz .pass
	lea rdi,[buf]
	pop rax
	push rax
	push rax
	INTEGER__Factoradic
	lea rsi,[buf]
	FACTORADIC__Integer
	cmp [rsp],rbx
	jz .chk
.fail:	mov ebx,"FAIL"
.pass:	pop rax

	mov [result],ebx
	invoke WriteConsoleA,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,message,message.bytes,0,0
	invoke	ExitProcess,0
.END Start
END IF;____TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST



; Use 64-bit registers globally and down-translate when beneficial: high bits
; are cleared in all write cases of reg32 ; otherwise, use 'low' as further
; indication of uneffected high bits on write for 16-/8-bit cases.
iterate <reg,rlow>, ax,al, cx,cl, dx,dl, bx,bl, sp,spl, bp,bpl, si,sil, di,dil
define reg32.r#reg? e#reg
define reg16low.r#reg? reg
define reg8low.r#reg? rlow
end iterate
repeat 8, i:8
define reg32.r#i? r#i#d
define reg16low.r#i? r#i#w
define reg8low.r#i? r#i#b
end repeat