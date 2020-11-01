; coding: utf-8, tab: 8
include './.win64/coffms64.g'
include './.win64/equates/sysinfoapi.g'

section '.drectve' linkinfo linkremove
db	'/SUBSYSTEM:CONSOLE",6.2" /STACK:0,0 /HEAP:0,0 '

; loosly based on:
; https://github.com/MicrosoftDocs/sdk-api/blob/docs/sdk-api-src/content/sysinfoapi/nf-sysinfoapi-globalmemorystatusex.md#examples

section '.flat' code readable executable align 64

message db "There is %ld percent of memory in use.", \
10,"Physical Memory:",			\
10,9,	"%lld KB free of %lld KB total",\
10,"Virtual Memory:",			\
10,9,	"%lld KB free of %lld KB total",\
10,"Extended Memory:",			\
10,9,	"%lld KB free",			\
10,"Paging File Use:",			\
10,9,	"%lld KB free of %lld KB total",0

struct VPARAMS ; matches order of above format specifiers
	use	rq 1
	pfree	rq 1
	ptotal	rq 1
	vfree	rq 1
	vtotal	rq 1
	xfree	rq 1
	dfree	rq 1
	dtotal	rq 1
end struct


public mainCRTStartup:
	; Note: MEMORYSTATUSEX needs 'align 16', hence it's first
	frame.enter ,<msex:MEMORYSTATUSEX,vmem:VPARAMS>
	mov [msex.dwLength],sizeof msex
	call KERNEL32:GlobalMemoryStatusEx,ADDR msex

; massage data of MEMORYSTATUSEX to the form needed

	lea rsi,[msex+4]
	lodsd
	mov [vmem.use],rax

	lodsq
	shr rax,10
	mov [vmem.ptotal],rax
	lodsq
	shr rax,10
	mov [vmem.pfree],rax

	lodsq
	shr rax,10
	mov [vmem.dtotal],rax
	lodsq
	shr rax,10
	mov [vmem.dfree],rax

	lodsq
	shr rax,10
	mov [vmem.vtotal],rax
	lodsq
	shr rax,10
	mov [vmem.vfree],rax

	lodsq
	shr rax,10
	mov [vmem.xfree],rax

	call UCRT:__conio_common_vcprintf,0,ADDR message,0,ADDR vmem
	call KERNEL32:ExitProcess,0
	frame.leave
	int3
