; coding: utf-8, tab: 8
include './.win64/coffms64.g'

include './.win64/interface/IUnknown.g'
include './.win64/interface/IShellLink.g'
include './.win64/interface/IPersistFile.g'

public GetPathOfShortcutW:
namespace GetPathOfShortcutDx
frame.enter <hWnd:QWORD,pszLnkFile:QWORD,pszPath:QWORD>,\
<	pShellLink:IShellLinkW,		\
	pPersistFile:IPersistFile,	\
	find:WIN32_FIND_DATAW,		\
	bResult:DWORD			\
>
	mov [bResult],0
	call OLE32:CoCreateInstance,ADDR CLSID_ShellLink,0,CLSCTX_INPROC_SERVER,	\
		ADDR IID_IShellLinkW,ADDR pShellLink
	test eax,eax
	js A
	pShellLink->QueryInterface ADDR IID_IPersistFile,ADDR pPersistFile
	test eax,eax
	js B
	pPersistFile->Load [pszLnkFile],STGM_READ
	test eax,eax
	js C
	pShellLink->Resolve [hWnd],SLR_NO_UI or SLR_UPDATE
	pShellLink->GetPath [pszPath],MAX_PATH,ADDR find,0
	test eax,eax
	js C
	mov rax,[pszPath]
	cmp byte [rax],0
	setnz byte [bResult]
C:	pPersistFile->Release
B:      pShellLink->Release
A:	mov eax,[bResult]
	frame.leave
	retn
end namespace
