
; Registered clipboard formats are identified by values in the range 0xC000 through 0xFFFF

ClipboardFormatHandles:
	dw .0 - $
	dw .1 - $
	dw .2 - $
	dw .3 - $
	dw .4 - $
	dw .5 - $
	dw .6 - $
	dw .7 - $
	dw .8 - $
	dw .9 - $
	dw .A - $
	dw .B - $
	dw 0
	.0	db 'RichEdit Text and Objects',0
	.1	db 'Rich Text Format',0
	.2	db 'FileNameW',0
	.3	db 'FileName',0
	.4	db 'Link Source Descriptor',0
	.5	db 'Object Descriptor',0
	.6	db 'Link Source',0
	.7	db 'Embed Source',0
	.8	db 'Embedded Object',0
	.9	db 'ObjectLink',0
	.A	db 'OwnerLink',0
	.B	db 'Native',0


; initialize used clipboard formats to use word indices.

RegClipboardFormats:
	enter 32,0
	mov [FRAME.RCX],rdi
	lea rdi,[ClipboardFormatHandles]
.A:	movzx ecx,word [rdi]
	jrcxz .x
	add rcx,rdi
	call [RegisterClipboardFormatA]
	stosw
	jmp .A
.x:	mov rdi,[FRAME.RCX]
	leave
	retn