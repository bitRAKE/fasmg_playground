;
; Given a font name, checks if that font is available on the system.
; Conversion of C code, Copyright (C) Kai Liu.  All rights reserved.
;
; Yes, EnumFonts is old, but we neither need nor care about the additional
; info returned by the newer font enumeration APIs; all that we care about
; is whether the callback is ever called.
;
IsFontAvailable:
	enter 32,0 ; basic frame
	mov [FRAME.RCX],rcx

	xor ecx,ecx
	mov dword[FRAME.R9],ecx		; clear return value
	call[GetDC]

	mov [FRAME.RDX],rax		; save hDC
	xchg rcx,rax
	mov rdx,[FRAME.RCX]		; font name
	lea r8,[.EnumFontsProc]
	lea r9,[FRAME.R9]
	call[EnumFonts]			; use A/W based on font name

	xor ecx,ecx
	mov rdx,[FRAME.RDX]
	call[ReleaseDC]

	movsx eax,byte[FRAME.R9]	; FIX: use ECX to branch w/o test
	leave
	retn

.EnumFontsProc:
	or byte[r9],-1
	xor eax,eax			; halt enumeration
	retn