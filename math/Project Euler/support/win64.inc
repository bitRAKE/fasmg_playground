; Support wrapper, in order that each problem can take the form:
;
;	macro PROBLEM
;		< solve problem >
;		SOLUTION "Some text: %d, %s", [rbx], rsi
;	end macro
;	macro __DATA
;	end macro
;
; OS specific overhead, some problems need:
;	- memory (static/dynamic)
;	?
;
INCLUDE 'win64a.inc'
FORMAT PE64 CONSOLE 6.2 at $10000 on "NUL"
SECTION '.FLAT' CODE READABLE WRITEABLE EXECUTABLE
POSTPONE
	msvcrt_name db 'msvcrt',0
	_exit db 0,0,'exit',0
	__printf_p db 0,0,'_printf_p',0
	align 8
	DATA IMPORT
		dd 0,0,0,RVA msvcrt_name,RVA msvcrt_table
		dd 0,0,0,0,0
		align 8
		msvcrt_table:
			exit dq RVA _exit
			_printf_p dq RVA __printf_p
			dq 0
	END DATA

	__DATA ; defined static data by PROBLEM
END POSTPONE


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


macro __DATA ; empty
end macro


macro SOLUTION template,parameters&
; limitations: RBP cannot be passed as a parameter/template
	Get100ns rbp
	sub [rsp],rbp ; -delta
	pop rbp
	; no reason to grab this much stack, but RBP is back on that stack
	enter 2048,0
	and spl,-64 ; a little paranoia is a good thing (for debugging)

	; store values first to preserve them
	iterate pram,parameters
		mov rax,pram
		mov [rsp+8*%],rax
	end iterate
	pop rax ; alignment fix
	call plat
	db template,0 ; easy way to support complex strings like <" "," ">
plat:	; print time in ms
	cvtsi2sd xmm0,qword [rbp]
	mulsd xmm0,[One_10v4] ; -10^-4
	movq rdx,xmm0
	lea rcx,[TimeDisplay]
	sub rsp,8*4
	call [_printf_p]
	add rsp,8*4

	; print result
	mov rcx,[rsp]
	mov rdx,[rsp+8]
	mov r8,[rsp+16]
	mov r9,[rsp+24]
	call [_printf_p]
	leave
end macro

macro Get100ns reg=RAX ; use KUSER_SHARED_DATA.InterruptTime
local atom
atom:	mov reg,[0x7FFE0008]
	ror reg,32
	cmp [0x7FFE0010],reg32.reg
	jnz atom
	ror reg,32
end macro

align 16
One_10v4: dq -0.0001,-0.0001,-0.0001,-0.0001 ; convert 100 ns -> ms
TimeDisplay db 13,10,"Problem time: %f ms",13,10,0

ENTRY $ ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY
	Get100ns rbp
	push rbp ; start timer

	PROBLEM ; must use SOLUTION at end

	call [exit]
	int3