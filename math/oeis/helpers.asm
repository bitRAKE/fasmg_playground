MACRO DisplayNumber n
	LOCAL number
	number = n scale 0
	IF number < 0
		DISPLAY '-'
		number = -number
	END IF
	REPEAT 1, N:number
		DISPLAY `N
	END REPEAT
END MACRO


VIRTUAL AT 0
	HexDigits:: DB '0123456789ABCDEF'
END VIRTUAL
MACRO DisplayHex n*,bytes:0
	LOCAL number,chars
	number = n scale 0
	IF bytes
		; assume leading set bits of negative numbers is desired
		chars = 2*bytes
	ELSE
		; assume compact representation is desired
		IF number < 0
			DISPLAY '-'
			number = -number
		END IF
		chars = 2 + 2*((BSR (number))/8)
	END IF
	REPEAT chars
		load digit:byte from HexDigits:((number) SHR ((%%-%) SHL 2)) AND 0Fh
		DISPLAY digit
	END REPEAT
END MACRO


struc egcd?: a,b ; extended GCD
	local t
	if a = 0
		.gcd = b
		.x = 0
		.y = 1
	else
		. egcd (b mod a),a
		t := .x
		.x = (.y - (b / a) * .x)
		.y = t
	end if
end struc

struc pow?: n,e
	repeat 1,dn:n,de:e
		if de > 0
			local t
			t pow dn,de shr 1
			if de and 1
				. = t * t * dn
			else
				. = t * t
			end if
		else if de = 0
			. = 1
		else
			err
		end if
	end repeat
end struc


; https://board.flatassembler.net/topic.php?p=208207#208207
macro put key,value
	repeat 1, dk:`key
		stored.dk = value
	end repeat
end macro

struc get key
	repeat 1, dk:`key
		. = stored.dk
	end repeat
end struc
