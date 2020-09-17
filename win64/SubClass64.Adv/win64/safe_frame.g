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

define SAFEFRAME? SAFEFRAME?

macro SAFEFRAME?.ENTER? proto*,loco,rego
;     proto:	function prototype
;     loco:	<list>		; name:type to allocate space after shadow
;     rego:	<list>		; registers to preserved beyond RCX RDX R8 R9

	local frame_bytes,shadow_octets,loco_bytes,rego_octets
	local loco_names,rego_names,proto_names,temp

	; this value is used by all frame types, preserve previous
	FRAME.MAX_PARAMS =: 4

	macro SAFEFRAME?.LEAVE?
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
			indx %%-%+1
			pop N
; TODO: support SIMD registers
		end irpv
		restore FRAME.MAX_PARAMS
		purge SAFEFRAME?.LEAVE?
	end macro

	temp = 0
	match PP,proto
	iterate P,PP
		indx %%-%+1 ; reverse order
		match A:B,P
			define proto_names A
			match =QWORD,B
			repeat 1,f:%%-% ; need correct index - 1
			match C|=f:R|D,:|0:RCX|1:RDX|2:R8|3:R9|:
				define rego_names R
				repeat 1,k:(rego_octets-temp) shl 3
				define A (rbp+k)
				end repeat
				temp = temp + 1
				push R
			else ; skip over return address and parent shadow
				repeat 1,k:(rego_octets+f+1) shl 3
				define A (rbp+k)
				end repeat
			end match
			end repeat
			else
; TODO: save float values on stack:
;	sub rsp,8 / vmovq [rsp],[x|y|z]mmN ; top of SIMD regs zeroed
			end match
		end match
;		display 13,10,`P
	end iterate
	end match

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
