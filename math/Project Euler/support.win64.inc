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


macro __DATA ; empty
end macro


macro SOLUTION template,parameters&
; limitations: RBP and RAX cannot be passed as a parameter/template
	Get100ns
	sub [rsp],rax ; -delta
	pop rax
	neg rax
	enter 2048,0
	and spl,-64

	; store values first to preserve them
	iterate pram,parameters
		mov rax,pram
		mov [rsp+8*%],rax
	end iterate
	pop rcx ; alignment fix
	call plat
	db template,0
plat:	; print time in ms
	sub rsp,8*4
	cvtsi2sd xmm0,rax
	mulsd xmm0,[One_10v4] ; / 10^4
	lea rcx,[TimeDisplay]
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

macro Get100ns ; use KUSER_SHARED_DATA.InterruptTime
local atom
atom:	mov rax,[0x7FFE0008]
	ror rax,32
	cmp [0x7FFE0010],eax
	jnz atom
	ror rax,32
end macro

align 16
One_10v4: dq 0.0001,0.0001,0.0001,0.0001 ; convert 100 ns -> ms
TimeDisplay db 13,10,"Problem took: %f ms",13,10,0

ENTRY $ ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY ; ENTRY
	Get100ns
	push rax ; start timer

	PROBLEM ; must use SOLUTION at end

	call [exit]
	int3