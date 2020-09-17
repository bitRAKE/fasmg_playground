; A consistent framework for parameter passing and management:
;
; View of stack:
;		 (low addresses)
; top-of-stack	-----------------	RSP, 0 mod 16
;		| shadow space	|
;		|---------------|
;		| local params	|
;		|---------------|
;		| saved regs	|
;		|---------------|	RBP, 0 mod 16
;		| RBP, return	|
;		|---------------|
;		| parent shadow	|
;		|---------------|
;		| passed params	|
;		-----------------
;		 (high addresses)

define FRAME? FRAME? ; root needs definition to be reachable through namespaces

; tail of stack frame is almost always the same, name the parts to simplify use
; this is only true after ENTER instruction
iterate X, RBP,RET,RCX,RDX,R8,R9
	define FRAME?.#X? (rbp+8*%-8)
end iterate


; based on SAFEFRAME - fix errors there first
macro FRAME?.ENTER? loco,rego
;     loco:	<list>		; name:type to allocate space after shadow
;     rego:	<list>		; registers to preserved beyond RCX RDX R8 R9

	local frame_bytes,shadow_octets,loco_bytes,rego_octets
	local loco_names,rego_names,proto_names,temp

	; this value is used by all frame types, preserve previous
	FRAME.MAX_PARAMS =: 4

	macro FRAME?.LEAVE?
		shadow_octets := FRAME.MAX_PARAMS
		repeat shadow_octets - 4, i:4
			restore ..P#i
		end repeat
; TODO: locals can produce a lot of symbols this doesn't make sense
;		irpv N, loco_names
;			restore N
;		end irpv
		irpv N, proto_names
			restore N
		end irpv
		leave
		irpv N, rego_names
; TODO: support SIMD registers
			indx %%-%+1
			pop N
		end irpv
		restore FRAME.MAX_PARAMS
		purge FRAME?.LEAVE?
	end macro

	; reverse order push puts registers on the stack from right-to-left,
	; from low addresses to high addresses, respectively
	match RR,rego
		iterate R,RR
			indx %%-%+1
			define rego_names R
			push R
			if % = %%
				rego_octets := %%
			end if
		end iterate
	end match

	; 8  for RET, 8 for RBP
	temp = ((shadow_octets + rego_octets)shl 3) + loco_bytes + 15
	; shadow and local, adjusted for odd reg push
	frame_bytes := (temp and -16) - (rego_octets shl 3)

	enter frame_bytes,0

	repeat shadow_octets - 4, i:4
		define ..P#i (rbp-frame_bytes+i*8)
	end repeat

	match LL,loco
	virtual at RBP - frame_bytes + (shadow_octets shl 3)
	iterate L,LL
		match A:B,L
			?A B
;			define loco_names A
		end match
	end iterate
	loco_bytes := $ - $$
	end virtual
	else
		loco_bytes := 0
	end match
end macro



; only support constant source types: memory addresses or literals
macro FRAME?.PARAMS? PP& ; w64 ABI parameter convension
	iterate p,PP
		indx %%-%+1 ; reverse order
		repeat 1,f:%%-% ; need correct index - 1
		match A|=f:R|B,:|0:RCX|1:RDX|2:R8|3:R9|:
			match =ADDR C,p
				lea R,[C]
			else
				mov R,p
			end match
		else ; f > 3
			match =ADDR C,p
				lea rax,[C]
				mov [..P#f],rax
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
FRAME.MAX_PARAMS =: 0
