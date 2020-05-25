@ECHO OFF
SET PLUG=fasmg-npp
REM Need custom install of Notepad++
:SET DEST=%appdata%\Notepad++\plugins
REM Need to run as Administrator
SET DEST=C:\Program Files\Notepad++\plugins
if not exist "%DEST%\Config\NUL" md "%DEST%\Config"
if not exist "%DEST%\%PLUG%\NUL" md "%DEST%\%PLUG%"
copy "%PLUG%.xml" "%DEST%\Config"
copy "%PLUG%.dll" "%DEST%\%PLUG%"
if not exist "%DEST%\%PLUG%\%PLUG%.dll" ECHO Install Failed!
ECHO ON