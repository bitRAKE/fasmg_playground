format PE64 CONSOLE 6.2
include 'win64wxp.inc'
.code
Quilt:
invoke GetStdHandle,STD_OUTPUT_HANDLE
mov [hCon],rax
invoke GetLastError
invoke FormatMessage,FORMAT_MESSAGE_ALLOCATE_BUFFER\
\	; always use these two together
	or FORMAT_MESSAGE_FROM_SYSTEM\
	or FORMAT_MESSAGE_IGNORE_INSERTS,0,rax,0,ADDR lpBuffer,0,0
invoke WriteConsole,[hCon],[lpBuffer],eax,0,0
invoke LocalFree,[lpBuffer]
invoke ExitProcess,eax
.data
hCon		rq 1
lpBuffer	rq 1
.end Quilt