;  A000931: Padovan numbers; 1,1,1,2,2,3,4,5,7,9,12,16,...

; Plastic ratio
; only real solution to x^3 = x + 1

; return the RCX'th Padovan number
A000931:
	push 1 1 1
	pop rax rdx rbx
@@:
	xchg rax,rbx
	xchg rax,rdx
	lea rbx,[rdx+rax]
	loop @B