
; a(n) = 3*a(n-1) + a(n-2), with a(0)=0, a(1)=1

; compute the ECX'th "bronze Fibonacci number"
A006190: ; only valid for ECX in [0,38]
    xor eax,eax
    jrcxz .zero
    mov edx,1
    jmp .entry
.loop:
    lea rdx,[rax*2+rdx]
    add rdx,rax
    jc .overflow
.entry:
    xchg rax,rdx
    loop .loop
.zero:
.overflow:
    ; carry flag indicates error
    ; RCX is remaining sequence to be generated
    ; RAX is last valid term
    retn


; NOTES:
;
; https://en.wikipedia.org/wiki/Generalizations_of_Fibonacci_numbers
; N-bonacci sequences (metalic mean)
;
; 0, 1, N, N^2+1, ...
;
; if matrix M is [[N 1][1 0]],
; then M^k gives P_(k+1) for the N-bonacci sequence, in O(log k) time*
; (* in the 0,0 matrix position of the result)
;
; ex. [[3 1][1 0]]^37 (0,0) = 14468818770132982923 = P_(38), for N=3
; https://www.wolframalpha.com/input/?i=%7B%7B3,1%7D,%7B1,0%7D%7D%5E37
