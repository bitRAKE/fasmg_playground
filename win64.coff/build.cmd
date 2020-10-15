: build single file programs with fasmg/link and clean up
for %%G in (%*) do (
	if not exist %%~nG.exe (
		fasmg -v 1 -e 3 %%G
		if exist %%~nG.obj (
			link %%~nG.obj
			del %%~nG.obj
		)
	)
)