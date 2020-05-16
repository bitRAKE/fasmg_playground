min = 1 ; calculate the smallest 1000 bigit number
REPEAT 999
min=min*10
END REPEAT

n=2
f0=1
f1=1
while f1 < min
n=n+1
T=f1
f1=f1+f0
f0=T
end while

DISPLAY 13,10,"Problem 25: "
REPEAT 1, N:n
	DISPLAY `N
END REPEAT
DISPLAY 13,10