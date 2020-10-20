; menu helper functions

hMenu__ToggleItemCheck:
namespace hMenu__ToggleItemCheck
	frame.enter <menu:QWORD,item:QWORD>,<miInfo:MENUITEMINFOW>

	mov [miInfo.cbSize],sizeof MENUITEMINFOW
	mov [miInfo.fMask],MIIM_STATE

	xor r8,r8
	call USER32:GetMenuItemInfoW,rcx,rdx,r8,ADDR miInfo
	xchg ecx,eax ; BOOL
	jrcxz F
	xor [miInfo.fState],MFS_CHECKED ; toggle
	mov edx,[item]
	xor r8,r8
	call USER32:SetMenuItemInfoW,[menu],rdx,r8,ADDR miInfo
	test eax,eax ; BOOL, should never fail?
	jz F
	test [miInfo.fState],MFS_CHECKED
	setnz al
X:	frame.leave
	retn ; ~ZF same as BOOL result ;)

F:	stc ; programer error? result invalid
	jmp X
end namespace
