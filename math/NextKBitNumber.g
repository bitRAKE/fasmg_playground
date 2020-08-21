struc NextKBitNumber
  local smallest,ripple
  smallest = . and (- .)
  ripple = . + smallest
  . = ripple or ((. xor ripple) shr (2 + (bsf smallest)))
end struc

repeat 9
  ; number of digits = bits set
  n = (1 shl %) - 1
  while (bsr n) < 9
    repeat 9
      m = n and (1 shl (%-1))
      if m
        display "0"+%
      end if
    end repeat
    display 13,10
    n NextKBitNumber
  end while
end repeat