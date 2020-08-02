struc GCD A*,B*
	if A = 0
		. = B
	else if B = 0
		. = A
	else if A = B
		. = A
	else
		local shift,t0,t1
		shift = bsf (A or B)
		t0 = A shr shift

		t1 = B shr (bsf B)
		while t0 > 0
			t0 = t0 shr (bsf t0)
			if t1 > t0
				t0 = t1 - t0
				t1 = t1 - t0
			else
				t0 = t0 - t1
			end if
		end while
		. = t1 shl shift
	end if
end struc