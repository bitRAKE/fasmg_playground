align 32 ; force both of these in the same cacheline
_0F: db 16 dup 0x0F
_F0: db 16 dup 0xF0

macro PalidroneQ reg0,reg1 ; 16 digit limit
	local shrk,shrq
	push reg0
	push reg0
	fild QWORD [rsp]
	fbstp TBYTE [rsp] ; slow
	mov reg0,[rsp]
	mov reg1,[rsp]
	and reg0,[_0F]
	and reg1,[_F0]
	shl reg0,4
	shr reg1,4
	or reg0,reg1
	bswap reg0
	jmp shrq
shrk:	ror reg0,8
shrq:	test reg0,0xFF
	jz shrk
	cmp [rsp],reg0
	lea rsp,[rsp+16]
end macro