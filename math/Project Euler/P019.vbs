Dim dat
dat = #1/1/1901#
i = 0
Do While Not dat = #12/31/2000#
	If Day(dat) = 1 Then
		If Weekday(dat) = vbSunday Then
			i = i + 1
		End If
	End If
	dat = dat + 1
Loop
Wscript.Echo i