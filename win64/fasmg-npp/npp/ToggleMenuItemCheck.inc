; npp doesn't return the previous state to us, so we need to bypass NPPM_SETMENUITEMCHECK :/
ToggleMenuItemCheck:
	enter 32,0
	label .hMenu:8 at FRAME.RCX
	label .nCmdId:4 at FRAME.RDX

	mov [.nCmdId],ecx

	xor r9,r9
	mov r8d,NPPPLUGINMENU
	mov edx,NPPM_GETMENUHANDLE
	mov rcx,[nppHandle]
	call [SendMessageW]
	mov [.hMenu],rax

	xor r8,r8 ; MF_BYCOMMAND or MF_UNCHECKED
	mov edx,[.nCmdId]
	mov rcx,[.hMenu]
	call [CheckMenuItem]

	test eax,MF_CHECKED ; was it MF_UNCHECKED already?
	jnz .unchecked

	mov r8d,MF_CHECKED ; or MF_BYCOMMAND
	mov edx,[.nCmdId]
	mov rcx,[.hMenu]
	call [CheckMenuItem]
.unchecked:
	; eax is previous state
	leave
	retn