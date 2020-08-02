; Use 64-bit registers globally and down-translate when beneficial: high bits
; are cleared in all write cases of reg32 ; otherwise, use 'low' as further
; indication of uneffected high bits on write for 16-/8-bit cases.
iterate <reg,rlow>, ax,al, cx,cl, dx,dl, bx,bl, sp,spl, bp,bpl, si,sil, di,dil
define reg32.r#reg? e#reg
define reg16low.r#reg? reg
define reg8low.r#reg? rlow
end iterate
repeat 8, i:8
define reg32.r#i? r#i#d
define reg16low.r#i? r#i#w
define reg8low.r#i? r#i#b
end repeat

; tail of stack frame is almost always the same, name the parts to simplify use
iterate X, RBP,return_addr,RCX,RDX,R8,R9
	define FRAME.#X rbp+8*%
end iterate