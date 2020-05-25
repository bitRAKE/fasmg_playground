k = 1 + ((bsr __source__) shr 3)
tmp = __source__ bswap k
while 1
	if '.' = (tmp and 0xFF)
		break
	end if
	tmp = tmp shr 8
end while
k = 0
while 1
	k = k + 8
	b = ((tmp shr k) and 0xFF)
	if b = '/'
		break
	else if b = '\'
		break
	else if b = 0
		break
	end if
end while
tmp = ((((1 shl k)-1) and tmp) shl 24) + 'lld'
k = 1 + ((bsr __source__) shr 3)
__DLL_NAME__ = string (tmp bswap k)