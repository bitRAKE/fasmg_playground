: build single file programs with fasmg/rc/link and clean up
for %%G in (%*) do (
	if not exist %%~nG.exe (
		if exist %%~nG.rc (
			rc /nologo %%~nG.rc
		)
		fasmg -v 1 -e 3 %%G
		if exist %%~nG.res (
			if exist %%~nG.obj (
				link %%~nG.obj %%~nG.res
				del %%~nG.obj
			)
:RES might exist without RC, DO NOT delete those RES files!
			if exist %%~nG.rc (
				del %%~nG.res
			)
		) else (
			if exist %%~nG.obj (
				link %%~nG.obj
				del %%~nG.obj
			)
		)
	)
)
