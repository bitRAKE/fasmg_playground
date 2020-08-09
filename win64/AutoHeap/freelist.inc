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
; RCX : bytes to fill - must be a multiple of MINIMUM_BLOCK_SIZE,
;	and a factor of PageSize
	jrcxz .fail
	push rax
	push rcx
	lea rax,[rax+MINIMUM_BLOCK_SIZE]
@@:	sub rcx,MINIMUM_BLOCK_SIZE
	mov [rax-MINIMUM_BLOCK_SIZE],rax
	lea rax,[rax+MINIMUM_BLOCK_SIZE]
	ja @B
	pop rcx
	pop rax
.fail:	retn