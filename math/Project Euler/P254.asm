;	Sums of Digit Factorials
;	Problem 254, https://projecteuler.net/problem=254
;
; Define f(ə) as the sum of the factorials of the digits of ə.
; For example, f(342) = 3! + 4! + 2! = 32.
;
; Define sf(ə) as the sum of the digits of f(ə).
; So sf(342) = 3 + 2 = 5.
;
; Define g(i) to be the smallest positive integer ə such that sf(ə) = i.
; Though sf(342) is 5, sf(25) is also 5, and it can be verified that g(5) is 25.
;
; Define sg(i) as the sum of the digits of g(i). So sg(5) = 2 + 5 = 7.
;
; Further, it can be verified that g(20) is 267 and ∑ sg(i) for 1 ≤ i ≤ 20 is 156.
;
; What is ∑ sg(i) for 1 ≤ i ≤ 150?
;
FORMAT PE64 CONSOLE
INCLUDE 'win64axp.inc'
.DATA

__fac0 = 1 ; hack
repeat 9,i:0
	__fac#% = __fac#i * %
end repeat
__fac0 = 0 ; unhack

ALIGN 64
FacDelta:
	__fac10 = 0 ; hack
	repeat 10,i:0
		dq __fac#% - __fac#i
	end repeat

_10 dq 10
MAX_DIGITS = 32
digits_n rb MAX_DIGITS

N_scale rd 2

ALIGN 64
g_n_first rd 32
g_n rq 256
sg.bytes = $ - digits_n

.CODE

; if the average digit is "5" then 30 digits are needed to sum to 150, wow!
macro SumIntegerDigits memreg64*
	local digs
	mov rax,memreg64
	xor ecx,ecx
digs:	xor edx,edx
	div [_10]
	add ecx,edx
	test rax,rax
	jnz digs
end macro

;-------------------------------------------------------------------------------
; Need all the values of g() up to 150.
; Which is a search and the problem crux.

sg:	push rbx ; find this many first values, 1..
	xor r15,r15 ; actual (n), not used in inner loop

	; clear tables

	xor eax,eax
	lea rdi,[digits_n]
	mov ecx,(sg.bytes+3)/4
	rep stosd

	mov [g_n],rbx		; g[0] undefined, use for count
	xor edi,edi		; initial (n) digit factorial sum
;	mov [digits_n],0	; digit array has been reset
.too_large_result:
.duplicate:
.find_more:
	add r15,1

; for each digit place run an automata that adjusts the sum of factorial:
; incrementing is just adding the difference of two factorials in most cases.

	mov ebp,[N_scale]
.factorial_carry:
	repeat 6
		movzx ecx,[digits_n+rbp+%-1]
		add [digits_n+rbp+%-1],1
		add rdi,[FacDelta+rcx*8]
		jnc .factorial_summed
		mov [digits_n+rbp+%-1],0
	end repeat

	; inject large, semi-constant lower digits

	add rdi,1
	mov [digits_n+rbp+6],1 ; should have been zero
	; promote first 8 to 9
	; add another 8 if all nines
	xor ebp,ebp
nines:	cmp [digits_n+rbp],9
	lea ebp,[rbp+1]
	jz .nines
	cmp [N_scale],ebp
	jz .eight
	movzx ecx,[digits_n+rbp-1]
	add [digits_n+rbp-1],1
	add rdi,[FacDelta+rcx*8]

	; switch lower nines to eights

	jmp .scaled
.eight:
	add [N_scale],1
	mov [digits_n+rbp+%-1],8
	add rdi,__fac8

	; switch all low nines to eights

.scaled:

.factorial_summed:
	SumIntegerDigits rdi

	cmp ebx,ecx
	jc .too_large_result
	bts [g_n_first],ecx
	jc .duplicate

; lazy, don't calc (n)
mov [g_n+rcx*8],r15
; need to switch to storing sum of digits

	sub [g_n],1
	jnz .find_more

	; sum 1..N results
	push 0
.sum:	SumIntegerDigits [rbx*8+g_n]
	add [rsp],rcx
	sub ebx,1
	jnz .sum
	pop rax ; result
	pop rbx ; RSI RDI RDX RCX used
	retn
;-------------------------------------------------------------------------------
Start:
	pop rax

	mov ebx,20
	call sg ; 156

	mov ebx,46
	call sg ; 709

	mov ebx,150
	call sg ; a lot bigger ;)

;	invoke WriteConsoleA,<invoke GetStdHandle,STD_OUTPUT_HANDLE>,message,message.bytes,0,0
	invoke ExitProcess,0
.END Start;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; 153 000 000 000
; 
;dq 1,2,5,15,25,3,13,23,6,16,26,44,144,256,36,136,236,67,167,267,
;349,1349,2349,49,149,249,9,19,29,129,
;229,1229,39,139,239,1239,13339,23599,4479,14479,2355679,
;344479,1344479,
;        2378889	---.
;       12378889	---.
;      133378889	---.
;     2356888899	----..
;    12356888899	----..
;   133356888899  	----..
;  2
; 1 
;1



; only the first 20 don't end in nine?
; when the digit array gets too big, generate numbers of the form N_8*9* to excellerate discovery
; only five variant leading digits are suffcient to fine tune result


