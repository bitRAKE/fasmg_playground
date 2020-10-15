include '../.win64/coffms64.g'

GENERIC_READ = 0x80000000
OPEN_EXISTING = 3
FILE_ATTRIBUTE_NORMAL = 0x80

MEM_COMMIT = 0x1000
MEM_RESERVE = 0x2000
PAGE_READWRITE = 4

WS_EX_TOPMOST = 8
WS_POPUP = 0x80000000
WS_VISIBLE = 0x10000000

PM_REMOVE = 1
VK_CONTROL = 0x11

GL_FRAGMENT_SHADER = 0x8B30


section '.drectve' linkinfo linkremove
db '/SUBSYSTEM:WINDOWS",6" /STACK:0,0 /HEAP:0,0 '

section '.' code readable writeable executable align 64

public WinMainCRTStartup:
frame.enter ,<				\
	ShaderCode:QWORD,		\
	Shader:QWORD,			\
	hDC:QWORD,			\
	hFile:QWORD,			\
	glCreateShaderProgramv:QWORD,	\
	glDeleteProgram:QWORD,		\
	glUseProgram:QWORD		>

	call KERNEL32:VirtualAlloc,0,64*1024,\
		MEM_COMMIT or MEM_RESERVE,PAGE_READWRITE
	mov [ShaderCode],rax
	call USER32:SetProcessDPIAware
	call USER32:CreateWindowExA,WS_EX_TOPMOST,ADDR _static,0,\
		WS_POPUP or WS_VISIBLE,0,0,3840,2160,0,0,0,0
	call USER32:GetDC,rax
	mov [hDC],rax

	call GDI32:ChoosePixelFormat,[hDC],ADDR PixelFormatDesc
	call GDI32:SetPixelFormat,[hDC],rax,ADDR PixelFormatDesc
	call OPENGL32:wglCreateContext,[hDC]
	call OPENGL32:wglMakeCurrent,[hDC],rax
	iterate prca,glUseProgram,glCreateShaderProgramv,glDeleteProgram
		call OPENGL32:wglGetProcAddress,ADDR _#prca
		mov [prca],rax
	end iterate
LoadNewShader:
	call KERNEL32:CreateFileA,ADDR ShaderFileName,\
		GENERIC_READ,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
	mov [hFile],rax
	cmp rax,-1
	jz .skip
	call KERNEL32:GetFileSize,[hFile],0
	call KERNEL32:ReadFile,[hFile],[ShaderCode],rax,ADDR BytesRead,0
	call KERNEL32:CloseHandle,[hFile]
;	call KERNEL32:Sleep,20
	call [glDeleteProgram],[Shader]
	call [glCreateShaderProgramv],GL_FRAGMENT_SHADER,1,ADDR ShaderCode
	mov [Shader],rax
	call [glUseProgram],rax
.skip:	call WINMM:timeBeginPeriod,1 ; ask for 1 ms timer resolution
	call WINMM:timeGetTime
	xchg edi,eax ; edi = beginTime, resets on shader load
MainLoop:
	call USER32:PeekMessageW,ADDR Message,0,0,0,PM_REMOVE
	call WINMM:timeGetTime
	sub eax,edi		; currentTime = time - beginTime

	cvtsi2ss xmm0,eax
	call OPENGL32:glTexCoord1f
	call OPENGL32:glRecti,-1,-1,1,1
	call GDI32:SwapBuffers,[hDC]

	call USER32:GetAsyncKeyState,'S'
	xchg ebx,eax
	call USER32:GetAsyncKeyState,VK_CONTROL
	and ax,bx
	js LoadNewShader

	call USER32:GetAsyncKeyState,'Q'
	xchg ebx,eax
	call USER32:GetAsyncKeyState,VK_CONTROL
	and ax,bx
	jns MainLoop

	call KERNEL32:ExitProcess,0
frame.leave
int3

_static db 'static',0
_glCreateShaderProgramv db 'glCreateShaderProgramv',0 ; 4.1
_glDeleteProgram db 'glDeleteProgram',0 ; 2.0
_glUseProgram db 'glUseProgram',0 ; 2.0
ShaderFileName db 'ShaderV.glsl',0

BytesRead:
Message:
PixelFormatDesc:
    dd 0
    dd 0x00000021 ; PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER
    db 32 dup 0
