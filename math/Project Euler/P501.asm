; Let f(x) be the count of numbers not exceeding (x) with exactly eight
; divisors. Given:
;	f(100)	= 10
;	f(1000)	= 180		; 180
;	f(10^6)	= 224427	; 222814 why off?
; Find f(10^12).

; The smallest eight divisors of N would be:
;   1, 2, 3, 4, N/4, N/3, N/2, N
;   Therefore, N >= 1*2*3*4 and
;   ,,,only the primes up to M/(2*3*4) need be calculated to find f(M).
;
; N,1 are always divisors of N.
; 24 = 2.2.2.3, only eight combinations of factors - sub-sets
; {},{2},{2,2},{2,2,2},{2,3},{2,2,3},{2,2,2,3},{3}
;
; Must be third power of a prime, and another prime or three distinct primes:
;
; 2.2.2.3	1   2	3   4	6   8  12  24
; 2.2.2.5	1   2	4   5	8  10  20  40
; 2.2.2.7	1   2	4   7	8  14  28  56
; 2.2.2.11	1   2	4   8  11  22  44  88
;
; 2.3.3.3	1   2	3   6	9  18  27  54
;
; 2.3.5 	1   2	3   5	6  10  15  30
; 2.3.7		1   2   3   6   7  14  21  42
; 2.3.11	1   2   3   6  11  22  33  66
; 2.3.13	1   2   3   6  13  26  39  78
; 2.5.7 	1   2	5   7  10  14  35  70
;
; Method:
;   - sieve primes
;   - gather divisors under M
;	a. primes and prime powers
;
; f(x) will result in three prime ranges
;	~ seventh root of x
;	~ fourth root of x
;	~ third root of x
; This is where the loops will stop producing results.

IF __source__=__file__
INCLUDE 'win64axp.inc'
.DATA ; .DATA ; .DATA ; .DATA ; .DATA ; .DATA ; .DATA ; .DATA ; .DATA ; .DATA ;

	define TENv6 100_0000
	define TENv12 1_0000_0000_0000
	_X_ emit 16:TENv6 ; 128 bit integer

	FLAGS rq 1
		RANGE0_OKAY = 0
		RANGE1_OKAY = 1
		RANGE2_OKAY = 2

; Need 8GB to calculate the full range, this can be shorted if we know the count
; of primes under:
;		x=10^12
;	x/2^3	5100605440	-1 for P_0==P_1, but +1 for P_0^7
;	x/3^3	1590395560
; 	x/5^3	 367783654
;	x/7^3	 140573117
;	x/11^3	  38767450
;	x/13^3	  24112077
;	x/17^3	  11264206
;	x/19^3	   8220785
;	x/23^3	   4789852
;	x/29^3	   2490873
; For example, we can starting on 11^3 and we only need primes up to Prime[38767450],
; if we manually add the counts for the previous small primes.
if 0
PSTART=31
RSTART=5100605440+1590395560+367783654+140573117+38767450+24112077+11264206+8220785+4789852+2490873
; calculate primes up to this number
PRIME_LIMIT = (TENv12+PSTART*PSTART*PSTART-1)/(PSTART*PSTART*PSTART)
else ; debug, don't use partial solve
PSTART=2
RSTART=0
PRIME_LIMIT = (TENv6+7)/8 ; 222814
end if
include 'prime_sieve.asm' ; PRIME_LIMIT data created where included
include 'multi_limb.asm'

.CODE ; .CODE ; .CODE ; .CODE ; .CODE ; .CODE ; .CODE ; .CODE ; .CODE ; .CODE ;

REAL_Start:
	PRIME_TAB_Initialize

define P_0	r8	; first scanning prime
define P_0v3	r9	; the third power of P_0

; bit indices into PRIME_TAB (not directly prime)
define p_0	r10
define p_1	r11
define p_2	r12
define RESULT	r13

	or [FLAGS],111b shl RANGE0_OKAY
	xor RESULT,RESULT
	
; limits: P_0^3 < 2^64, maybe effective past 2^20 primes
	mov P_0,2
	xor p_0,p_0
	jmp BigLoop.go
BigLoop:
	push RESULT
	NEXT_PRIME p_0
	lea P_0,[p_0+p_0+1]		; P_0

	; skip ahead, artificially reduced problem space, baked partial result
.go:	cmp P_0,PSTART
	jc SmallLoop.too_big

	mov rax,P_0
	mul P_0				; P_0^2
	mov P_0v3,rax
	mul P_0				; P_0^3
	xchg P_0v3,rax
	; are we done testing 7th powers?
	btr [FLAGS],RANGE0_OKAY
	jnc .too_big
	mul rax				; P_0^4
	MUL128x64 P_0v3			; P_0v3 = P_0^3 for next form use
	CMP128mem rdx:rax,_X_
	ja .too_big
	add RESULT,1
	bts [FLAGS],RANGE0_OKAY
.too_big:

	mov rax,2			; P_1
	xor p_1,p_1
	jmp SmallLoop.go
SmallLoop:
	NEXT_PRIME p_1
	lea rax,[p_1+p_1+1]		; P_1
.go:	cmp p_0,p_1
	jz SmallLoop
	mul P_0v3			; P_0^3 * P_1
	CMP128mem rdx:rax,_X_
	ja .too_big
	add RESULT,1
	jmp SmallLoop
.too_big:

	mov p_1,p_0
TinyLoop1:
	NEXT_PRIME p_1
	mov p_2,p_1
	push RESULT
TinyLoop2:
	NEXT_PRIME p_2
	lea rax,[p_1+p_1+1]		; P_1
	lea rdx,[p_2+p_2+1]		; P_2
	mul rdx
	MUL128x64 P_0			; P_0 * P_1 * P_3
	CMP128mem rdx:rax,_X_
	ja .too_big
	add RESULT,1
	jmp TinyLoop2
.too_big:
	; keep trying until no more results
	cmp [rsp],RESULT
	pop rax
	jnz TinyLoop1

	cmp [rsp],RESULT
	pop rax
	jnz BigLoop
; output RESULT
add RESULT,RSTART
int3

;###############################################################################
Start:	invoke MessageBoxA,0,"Use a debugger.","Hello",MB_OK
	invoke ExitProcess,0
	call REAL_Start
	int3
.END Start
ELSE
	ERR "stand alone file"
END IF