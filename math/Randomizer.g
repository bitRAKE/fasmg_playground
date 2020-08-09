; https://board.flatassembler.net/topic.php?p=210079#210079
define Randomizer

;if ~ defined Randomizer.SEED
;	Randomizer.SEED := %t
;else
;	postpone
;		Randomizer.SEED := Randomizer.XORSHIFT
;	end postpone
;end if

Randomizer.XORSHIFT = Randomizer.SEED

struc Randomizer.rand32
	. = Randomizer.XORSHIFT shr 96
	. = ( . xor (. shl 11) xor (. shr 8) xor (Randomizer.XORSHIFT) xor (Randomizer.XORSHIFT shr 19) ) and 0FFFFFFFFh
	Randomizer.XORSHIFT = (. or Randomizer.XORSHIFT shl 32) and 0FFFFFFFF_FFFFFFFF_FFFFFFFFh
end struc

struc Randomizer.rand limit
	while 1
		. Randomizer.rand32
		. = . and (1 shl (bsr (limit) + 1) - 1)
		if . <= limit
			break
		end if
	end while
end struc