@echo off
for %%G in (.\parsers\*.inc) do (
fasmg -n -i "define PARSER '%%G'" tokens.asm %%~nG.exe
)
@echo on