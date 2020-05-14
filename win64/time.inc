macro Get100ns reg=RAX ; use KUSER_SHARED_DATA.InterruptTime
local atom
atom:	mov reg,[0x7FFE0008]
	ror reg,32
	cmp [0x7FFE0010],reg32.reg
	jnz atom
	ror reg,32
end macro
;	cvtsi2sd xmm0,qword [rbp]
;	mulsd xmm0,[One_10v4] ; / 10^4
;	movq rdx,xmm0

;align 16
;One_10v4: dq 0.0001,0.0001,0.0001,0.0001 ; convert 100 ns -> ms
;TimeDisplay db 13,10,"time: %f ms",13,10,0