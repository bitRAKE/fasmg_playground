include 'helpers.asm'

a_1 := 1
struc a: n
	repeat 1,dn:n
		if ~ defined a_#dn
			a_#dn = 0
			local _a,_s
			repeat n-1
				_a a %
				_s s n-1,%
				a_#dn = a_#dn + _a*_s*%
			end repeat
			a_#dn = a_#dn / (n-1)
		end if
		. = a_#dn
	end repeat
end struc


struc s: n*,k*
	repeat 1, dn:n, dk:k
		if ~ defined s_#dk#_#dn
			restore s_#dk#_#dn ; force variable
			s_#dk#_#dn a n+1-k
			if ~ (n < 2*k)
				local _s
				_s s n-k,k
				s_#dk#_#dn = s_#dk#_#dn + _s
			end if
		end if
		. = s_#dk#_#dn
	end repeat
end struc


struc A000055 n
	repeat 1, dn:n
		if ~ defined A000055_#dn
			restore A000055_#dn ; force variable
			A000055_#dn a n
			local aj,da
			repeat n/2
				aj a %
				da a n-%
				A000055_#dn = A000055_#dn - aj*da
			end repeat
			if ~ (n and 1)
				A000055_#dn = A000055_#dn + da*(da+1)/2
			end if
		end if
		. = A000055_#dn
	end repeat
end struc

display "n",9,"bits",9,"A000055(n), Number of trees with n unlabeled nodes.",13,10
repeat 196
	DisplayNumber %
	DISPLAY 9
	N A000055 %
	DisplayNumber 1+(bsr N)
	DISPLAY 9
	DisplayNumber N
	DISPLAY 13,10
end repeat
err 'NO OUTPUT FILE'