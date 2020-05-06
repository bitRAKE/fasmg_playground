
; fasmg preprocessor language syntax

num = 1 shl 1000
sum = 0
WHILE num > 0
	sum = sum + (num MOD 10)
	num = num / 10
END WHILE

DISPLAY 13,10,"Problem 16: "
REPEAT 1, N:sum
	DISPLAY `N
END REPEAT
DISPLAY 13,10