define FREELIST R15 ; something non=volatile

macro FREELIST_Get reg0=RAX,reg1=FREELIST
	mov reg0,reg1
	mov reg1,[reg1]
end macro
macro FREELIST_Put reg0=FREELIST,reg1=RAX
	mov [reg0],reg1
	mov reg0,reg1
end macro


MINIMUM_BLOCK_SIZE = 64 ; 64,128,256,512,1024,2048,4096
FreeList__InitMem:
; RAX : start address to fill
; RDX : bytes to fill - must be a multiple of 64 and a factor of PageSize
	push rax
	push rdx
	lea rax,[rax+MINIMUM_BLOCK_SIZE]
@@:	sub rdx,MINIMUM_BLOCK_SIZE
	mov [rax-MINIMUM_BLOCK_SIZE],rax
	lea rax,[rax+MINIMUM_BLOCK_SIZE]
	jnz @B
	pop rdx
	pop rax
	retn