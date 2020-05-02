; some support abstractions for larger integers:

macro CMP128mem regs,mem
	local x
	match A:B,regs
		cmp A,qword [mem+8]
		jnz x
		cmp B,qword [mem]
	else
		err "expecting CMP128mem reg0:reg1,regmem"
	end match
x:
end macro

macro MUL128x64 reg ; RDX:RAX * reg, unsigned, clamp to 128-bit
	push rax
	xchg rax,rdx
	mul reg
	pop rdx
	push rax
	xchg rax,rdx
	mul reg
	add rdx,[rsp]
	lea rsp,[rsp+8] ; return flags of upper QWORD result
end macro