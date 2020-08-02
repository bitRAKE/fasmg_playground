include 'gcd.g' ; binary large number greatest common divisor

; test on F_8 = 2^2^8 + 1, which took 2 hours to factor in 1981

n = 1 shl (1 shl 8) + 1 ; F8, Fermat Number

n = 1 shl (1 shl 11) + 1

; initial constants:
c = 1
max = 1 shl 24
check = 17

while 1
	factor = 1 ; trivial factor

	x1 = 2
	x2 = 4 + c
	range = 1
	product = 1
	terms = 0

	i = 0
	while i < max
		j = 0
		while j < range
			x2 = (x2 * x2 + c) mod n
			if x1 > x2 ; absolute value of (x1-x2)
				xT = ((x1 - x2) mod n)
			else
				xT = ((x2 - x1) mod n)
			end if
			if xT = 0 ; (x1-x2), is a multiple of (n)
				display "."
			else
				product = (product * xT) mod n
			end if
			terms = terms + 1
			if terms = check
				factor GCD product,n
				if factor < n
				if factor > 1
					break ; factor (factor)
				end if
				end if
				product = 1
				terms = 0
				factor = 1
			end if
			j = j + 1
		end while
		if factor > 1
			break ; factor (factor)
		end if

		x1 = x2
		range = range shl 1
		j = 0
		while j < range
			x2 = (x2 * x2 + c) MOD n
			j = j + 1
		end while
		i = i + 1
	end while
	if factor > 1
		repeat 1,N0:factor,N1:n
			display 13,10,`N0,' is a non-trivial factor of ',`N1,13,10
		end repeat
		break
	end if

	; select another (c)
	c = c + 1
end while