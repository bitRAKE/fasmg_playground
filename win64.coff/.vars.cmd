TITLE fasmg NMAKE MSBuild CMAKE NINJA : %~dp0
set path=C:\~\fasmg\core;%path%
set include=C:\~\fasmg\packages\x86\include

:set VSCMD_DEBUG=3
set VS160COMNTOOLS=C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\Common7\Tools\
"%VS160COMNTOOLS%VsDevCmd.bat" -no_logo -arch=amd64 -startdir=

	NOTE NOTHING AFTER THE ABOVE GETS EXECUTED!

Change the paths to reflect installation.
