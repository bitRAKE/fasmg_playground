; executing 32-bit code from 64-bit

	use64

; Only indirect far call/jmp are supported in 64-bit mode. To be dynamic
; use a RETF
Begin32Bit:
	mov dword [rsp+4],23h
	retf


Just_a_test:
	call Begin32Bit
	use32


	pushad
	popad


	jmp 33h:@F
@@:	use64

	retn




my_32:	use32
	pushad
	popad
	retf
	use64


macro call32? function
	push function
	mov dword [rsp+4],23h
	call pword [rsp]
	lea esp,[rsp+8]
end macro


; or use a table of pwords and just call them

__my_32:	pword 23h:my_32


call [__my_32]





; https://board.flatassembler.net/topic.php?t=20208
; deteching code segment type by Martin Strimberg,
;                 use16           use32                   use64
;
; 48              dec ax          dec eax                 mov rax,4848484848484808h
; B8 08 48        mov ax,4808h    mov eax,48484808h
; 48              dec ax
; 48              dec ax
; 48              dec ax          dec eax
; 48              dec ax          dec eax
; 48              dec ax          dec eax
; 48              dec ax          dec eax
;
; result:       al = 2          al = 4                  al = 8