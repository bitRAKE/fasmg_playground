INCLUDE 'format/format.inc'
INCLUDE 'cpu/ext/avx2.inc'
FORMAT PE64 GUI 6.2 AT $10000 ON "NUL"
STACK	$1000,$1000
HEAP	$1000,$1000

SECTION '.flat' CODE READABLE WRITEABLE EXECUTABLE

CreateShader:
	push rbx
	push rsi
	push rdi
	enter 8*15,0

	lea ecx,[ShaderFileName]
	mov edx,0x80000000	; dwDesiredAccess = GENERIC_READ
	xor r8,r8		; dwShareMode
	xor r9,r9		; lpSecurityAttributes
	mov qword[rsp+8*4],3	; dwCreationAndDesposition = OPEN_EXISTING
	mov qword[rsp+8*5],0x80	; dwFlagsAndAttributes = FILE_ATTRIBUTE_NORMAL
	mov qword[rsp+8*6],0	; hTemplateFile
	call [CreateFile]
	lea rcx,[rax+1]
	jrcxz .skip
	xchg rbx,rax

	push rbx
	pop rcx
	xor edx,edx
	call [GetFileSize]
	push rbx
	pop rcx
	mov rdx,[ShaderCode]
	xchg r8,rax
	lea r9,[BytesRead]
	and qword[rsp+8*4],0
	call [ReadFile]
	push rbx
	pop rcx
	call [CloseHandle]

	mov ecx,20	;?
	call [Sleep]	;?

	mov rcx,[Shader]
	call [glDeleteProgram]
	lea r8,[ShaderCode]
	push 1 ; strings
	pop rdx
	mov ecx,0x8B30 ; GL_FRAGMENT_SHADER
	call [glCreateShaderProgramv]
	mov [Shader],rax
	xchg rcx,rax
	call [glUseProgram]
.skip:
	push 1			; ask for 1 ms timer resolution
	pop rcx
	call [timeBeginPeriod]
	call [timeGetTime]
	xchg rdi,rax		; edi = beginTime
	leave
	pop rdi
	pop rsi
	pop rbx
	retn



ENTRY $
pop rax
	xor ecx,ecx
        push rcx		; lpParam
        push rcx		; hInstance
        push rcx		; hMenu
        push rcx		; hWndParent
        push 2160		; nHeight
        push 3840		; nWidth
        push 0			; y
        push 0			; x
	sub rsp,8*4

;	xor ecx,ecx		; lpAddress
	mov edx,64*1024		; dwSize
	mov r8,0x3000		; flAllocationType = MEM_COMMIT|MEM_RESERVE
	mov r9,4		; flProtect = PAGE_READWRITE
	call [VirtualAlloc]
	mov [ShaderCode],rax

	call [SetProcessDPIAware]

	push 8			; dwExStyle = WS_EX_TOPMOST
	pop rcx
	lea edx,[_static]	; lpClassName
	xor r8,r8		; lpWindowName
	mov r9d,0x90000000	; dwStyle = WS_POPUP|WS_VISIBLE
	call [CreateWindowEx]
	xchg rcx,rax
	call [GetDC]
	push rax
	pop rbx			; hdc
	xchg rcx,rax
	lea edx,[PixelFormatDesc]
	call [ChoosePixelFormat]
	push rbx		; hdc
	pop rcx
	xchg rdx,rax		; pixel format id
	lea r8,[PixelFormatDesc]
	call [SetPixelFormat]
	push rbx		; hdc
	pop rcx
	call [wglCreateContext]
	push rbx		; hdc
	pop rcx
	xchg rdx,rax		; GL context
	call [wglMakeCurrent]

macro wglGetProcAddr prca*
	lea rcx,[_#prca]
	call [wglGetProcAddress]
	mov [prca],rax
end macro
wglGetProcAddr glUseProgram
wglGetProcAddr glCreateShaderProgramv
wglGetProcAddr glDeleteProgram

	call CreateShader
MainLoop:
	lea ecx,[Message]
	xor edx,edx
	xor r8,r8
	xor r9,r9
	mov qword[rsp+8*4],1	; PM_REMOVE
	call [PeekMessage]
	mov ecx,'S'
	call [GetAsyncKeyState]
	xchg ebp,eax
	mov ecx,0x11		; VK_CONTROL
	call [GetAsyncKeyState]
	and ax,bp
	jns .no_new_shader
	call CreateShader
.no_new_shader:
	call [timeGetTime]
	sub eax,edi		; currentTime = time - beginTime

	cvtsi2ss xmm0,eax
	call [glTexCoord1f]

	push 1
	push 1
	push -1
	push -1
	pop rcx
	pop rdx
	pop r8
	pop r9
	call [glRecti]

	push rbx		; hdc
	pop rcx
	call [SwapBuffers]

	mov ecx,'Q'
	call [GetAsyncKeyState]
	xchg ebp,eax
	mov ecx,0x11		; VK_CONTROL
	call [GetAsyncKeyState]
	and ax,bp
	jns MainLoop

	xor ecx,ecx
	call [ExitProcess]


POSTPONE

	_gdi32 db 'gdi32',0
	_ChoosePixelFormat db 0,0,'ChoosePixelFormat',0
	_SetPixelFormat db 0,0,'SetPixelFormat',0
	_SwapBuffers db 0,0,'SwapBuffers',0

	_kernel32 db 'kernel32',0
	_CloseHandle db 0,0,'CloseHandle',0
	_CreateFile db 0,0,'CreateFileA',0
	_ExitProcess db 0,0,'ExitProcess',0
	_GetFileSize db 0,0,'GetFileSize',0
	_ReadFile db 0,0,'ReadFile',0
	_Sleep db 0,0,'Sleep',0
	_VirtualAlloc db 0,0,'VirtualAlloc',0

	_opengl32 db 'opengl32',0
	_glRecti db 0,0,'glRecti',0
	_glTexCoord1f db 0,0,'glTexCoord1f',0
	_wglCreateContext db 0,0,'wglCreateContext',0
	_wglGetProcAddress db 0,0,'wglGetProcAddress',0
	_wglMakeCurrent db 0,0,'wglMakeCurrent',0

	_glCreateShaderProgramv db 'glCreateShaderProgramv',0 ; 4.1
	_glDeleteProgram db 'glDeleteProgram',0 ; 2.0
	_glUseProgram db 'glUseProgram',0 ; 2.0

	_user32 db 'user32',0
	_CreateWindowEx db 0,0,'CreateWindowExA',0
	_GetAsyncKeyState db 0,0,'GetAsyncKeyState',0
	_GetDC db 0,0,'GetDC',0
	_DispatchMessage db 0,0,'DispatchMessageA',0
	_MessageBox db 0,0,'MessageBoxA',0
	_PeekMessage db 0,0,'PeekMessageA',0
	_SetProcessDPIAware db 0,0,'SetProcessDPIAware',0

	_winmm db 'winmm',0
	_timeBeginPeriod db 0,0,'timeBeginPeriod',0
	_timeGetTime db 0,0,'timeGetTime',0

	_static db 'static',0
	ShaderFileName db 'ShaderV.glsl',0

	align 8
	DATA IMPORT ; section '.idata' import data readable writeable
		dd 0,0,0,RVA _gdi32,RVA gdi32_table
		dd 0,0,0,RVA _kernel32,RVA kernel32_table
		dd 0,0,0,RVA _opengl32,RVA opengl32_table
		dd 0,0,0,RVA _user32,RVA user32_table
		dd 0,0,0,RVA _winmm,RVA winmm_table
		dd 0,0,0,0,0
	align 8
	gdi32_table:
		ChoosePixelFormat dq RVA _ChoosePixelFormat
		SetPixelFormat dq RVA _SetPixelFormat
		SwapBuffers dq RVA _SwapBuffers
		dq 0
	kernel32_table:
		CloseHandle dq RVA _CloseHandle
		CreateFile dq RVA _CreateFile
		ExitProcess dq RVA _ExitProcess
		GetFileSize dq RVA _GetFileSize
		ReadFile dq RVA _ReadFile
		Sleep dq RVA _Sleep
		VirtualAlloc dq RVA _VirtualAlloc
		dq 0
	opengl32_table:
		glRecti dq RVA _glRecti
		glTexCoord1f dq RVA _glTexCoord1f
		wglCreateContext dq RVA _wglCreateContext
		wglGetProcAddress dq RVA _wglGetProcAddress
		wglMakeCurrent dq RVA _wglMakeCurrent
		dq 0
	user32_table:
		CreateWindowEx dq RVA _CreateWindowEx
		GetAsyncKeyState dq RVA _GetAsyncKeyState
		GetDC dq RVA _GetDC
		DispatchMessage dq RVA _DispatchMessage
		MessageBox dq RVA _MessageBox
		PeekMessage dq RVA _PeekMessage
		SetProcessDPIAware dq RVA _SetProcessDPIAware
		dq 0
	winmm_table:
		timeBeginPeriod dq RVA _timeBeginPeriod
		timeGetTime dq RVA _timeGetTime
		dq 0
	END DATA

glCreateShaderProgramv dq 0
glDeleteProgram dq 0
glUseProgram dq 0

Shader dq 0
ShaderCode dq 0
END POSTPONE


BytesRead:
Message:
PixelFormatDesc:
    dd 0
    dd 0x00000021 ; PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
    db 32 dup 0

;SECTION '.RELOC' FIXUPS DATA READABLE DISCARDABLE
; CTRL + 'S'	reload shader & reset time
; CTRL + 'Q'	quit
; CTRL + 'T'	reset time *TODO*