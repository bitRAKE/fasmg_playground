macro char_scan mem,val ; set memory to length of characters (not)matching
	match Z chr,val
		mov al,chr
		or ecx,-1
		mov [mem],-2
		rep#Z scasb
		lea rdi,[rdi-1]
		sub [mem],ecx
	else
		err "char_scan, expected parameters not present: [mem], Z/NZ 'X'"
	end match
end macro