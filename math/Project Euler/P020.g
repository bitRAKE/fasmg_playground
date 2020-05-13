num = 1
REPEAT 100
	num = num * %
END REPEAT
; (this follows almost exactly as in Problem 16)
sum = 0
WHILE num > 0
	sum = sum + (num MOD 10)
	num = num / 10
END WHILE

DISPLAY 13,10,"Problem 20: "
REPEAT 1, N:sum
	DISPLAY `N
END REPEAT
DISPLAY 13,10