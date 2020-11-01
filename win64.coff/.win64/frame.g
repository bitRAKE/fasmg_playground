; This is like "frame.g" except parameters are perserved. When the safeframe
; ends RCX RDX R8 R9 RSP are returned to the starting values. To reduce size
; push/enter/*/leave/pop pattern is used.

; View of stack:
;		 (low addresses)
; top-of-stack	-----------------	RSP, 0 mod 16
;		| shadow space	|
;		|---------------|
;		| local params	|
;		|---------------|	RBP
;		| RBP		|
;		|---------------|
;		| saved regs	|
;		|---------------|
;		| return	|
;		|---------------|
;		| parent shadow	|
;		|---------------|
;		| passed params	|
;		-----------------
;		 (high addresses)


; TODO: name parent shadow: FRAME.* are different than default naming

define FRAME? FRAME?

macro FRAME?.ENTER? proto,loco,rego
;     proto:	<list>
;     loco:	<list>		; name:type to allocate space after shadow
;     rego:	<list>		; registers to preserved
	local frame_bytes,shadow_octets,loco_bytes,rego_octets
	local loco_names,rego_names,proto_names,temp

	macro FRAME?.LEAVE?
		shadow_octets := FRAME.MAX_PARAMS
		restore FRAME.MAX_PARAMS
		repeat shadow_octets - 4, i:4
			restore ..P#i
		end repeat
		irpv N, proto_names
			restore N
		end irpv
		leave
; TODO: support SIMD registers
		irpv N, rego_names
			indx %%-%+1
			pop N
		end irpv
		purge FRAME?.LEAVE?
	end macro

	; this value is used by all frame types, preserve previous value
	FRAME.MAX_PARAMS =: 4 ; start at minimum

	temp = 0
	iterate PP,proto
	indx %%-%+1 ; reverse order
	match AA:BB,PP
		define proto_names AA
;		display 13,10,`AA
		match =QWORD,BB
; the common case
			repeat 1,f:%%-%,g:(rego_octets+%%-%+2)shl 3
			match Y|=f:R|Z,:|0:RCX|1:RDX|2:R8|3:R9|:
				define AA (rbp+g-40)
				define rego_names R
				temp = temp + 1
				push R
			else ; skip over RBP,saved regs,return address and parent shadow
				define AA (rbp+g)
			end match
			end repeat
		else
			err "parameter type not supported"
; TODO: save float values on stack:
;	sub rsp,8 / vmovq [rsp],[x|y|z]mmN ; top of SIMD regs zeroed
		end match
	end match
	end iterate

	; reverse order push puts registers on the stack from right-to-left,
	; from low addresses to high addresses, respectively
	match RR,rego
		iterate R,RR
			indx %%-%+1
			define rego_names R
			temp = temp + 1
			push R
		end iterate
	end match
	rego_octets := temp

	; 8  for RET, 8 for RBP
	temp = ((shadow_octets + rego_octets)shl 3) + loco_bytes + 15
	; shadow and local, adjusted for odd reg push
	frame_bytes := (temp and -16) - (rego_octets shl 3)

	enter frame_bytes,0

	repeat shadow_octets - 4, i:4
		define ..P#i (rbp-frame_bytes+i*8)
	end repeat

	virtual at RBP - frame_bytes + (shadow_octets shl 3)
		iterate LL,loco
			match A:B,LL
				?A B
			else
				?LL rq 1
			end match
		end iterate
		loco_bytes := $ - $$
	end virtual
end macro

; This version moves towards less hidden/implied parameters because their were
; errors I couldn't resolve. Trying to simplify and keep the features of the
; previous version.
;
; Register passed values are not on stack by default though. Naming them is
; inconsistent unless they are stored on the stack.
;
;


; By including register preservation stack alignment can be preserved without
; manually tracking register count. Allow naming any preserved register to ease
; repeated use.

;_.enter <RCX:hWnd,RDX:uMsg,R8:wParam,R9:lParam,RSI,RDI,RBX>,\
;	<>



;_.leave val0:rax,val1:rcx
;retn


; The problem with using RBP for parameter space is that stack can't be used
; through API calls. Ex. it would be nice to do:
;	sub rsp,BUFFER_SIZE
;	lea rdi,[rsp + FRAME.MAX_PARAMS shl 3]	; buffer pointer
; to grab some space, but then during API call parameters >4 get put in the
; wrong place. If we use RSP relative then everything is preserved.




; only support constant source types: memory addresses or literals
macro FRAME?.PARAMS? PP& ; w64 ABI parameter convension
	local @src,f_RAX
	f_RAX = 0
	iterate p,PP
		indx %%-%+1 ; reverse order
		repeat 1,f:%%-% ; need correct index - 1
		match A|=f:R|B,:|0:RCX|1:RDX|2:R8|3:R9|:
			match =ADDR C,p
				lea R,[C]
			else

x86.parse_operand @src,p
if @src.type = 'reg'
; this condition split out because (p) can make the comparison unparseable
if R eq p
	; do nothing
else
	mov R,p
end if
else
	mov R,p
end if

			end match
		else ; f > 3
			match =ADDR C,p
				lea rax,[C]
				mov [..P#f],rax
				f_RAX = 1 ; register destroyed
			else
				mov qword[..P#f],p
			end match
		end match
		end repeat

		if % = %% \
		& %% > FRAME.MAX_PARAMS
			FRAME.MAX_PARAMS = %%
		end if
	end iterate
end macro
FRAME.MAX_PARAMS = 1 shl 64 ; error at this level as there is no frame
