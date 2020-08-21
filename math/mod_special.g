; Modulus by Special Forms:
;	2ⁿ, 2ⁿ−1, 2ⁿ+1
;
; Most of the time N is constant through a large calculation and it would be
; advantageous to cache the bit mask of that value globally. These algorithms
; are overly general in that regard.
;
; In x86 code many of the constants can be eliminated. For example, maintaining
; a large integer in granular packets no shifts are needed. Or tests for zero
; of a large integer can be accumulated during the previous operation.


struc mod_2ⁿ val,n
	. = val and ((1 shl n) - 1)
end struc


struc mod_2ⁿ−1 val,n
	local D,X
	D = (1 shl n) - 1
	X = val
	. = val
	while X > D
		. = 0
		while X
			. = . + (X and D)
			X = X shr n
		end while
		X = .
	end while
	if . = D
		. = 0
	end if
end struc


struc mod_2ⁿ₊1 val,n
	local D,X,sign
	D = (1 shl n) - 1
	X = val
	sign = 1
	. = 0
	while X
		if sign
			. = . + (X and D)
		else ; force positive
			. = . - (X and D) + D + 2
		end if
		sign = sign xor 1
		X = X shr n
		if X = 0
			if (D + 1) < . & (bsr .) < (n shl 1)
				. = (. and D) - (. shr n)
			else ; force reset when bsr val >> n^2
				X = .
				sign = 1
				. = 0
			end if
		end if
	end while
end struc


IF __source__=__file__;___TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST

include 'Randomizer.g' ; Tomasz Grysztar's xorshift implementation
Randomizer.SEED := %t

repeat 16
	N Randomizer.rand 4095
	X Randomizer.rand32
	N = N or 1
	X = (X shl (%*N)) + 2*(X*N) + 1
	K = bsr X

	temp mod_2ⁿ X, N
	if temp <> (X mod (1 shl N))
		display "mod_2ⁿ: fail",13,10
		break
	end if

	temp mod_2ⁿ−1 X, N
	if temp <> (X mod ((1 shl N)-1))
		display "mod_2ⁿ−1: fail",13,10
		break
	end if

	temp mod_2ⁿ₊1 X, N
	if temp <> (X mod ((1 shl N)+1))
		display "mod_2ⁿp1: fail",13,10
		break
	end if

	repeat 1,n:N,k:K
		display 9,"tested N = ",`n,9,"(on ",`k," bit number)",13,10
	end repeat
end repeat
display "pass",13,10

END IF;____TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST_TEST