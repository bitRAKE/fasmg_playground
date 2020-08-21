@echo off
for %%G in (.\parsers\*.inc) do (
fasmg -i "define PARSER '%%G'" tokens.asm %%~nG.exe
)
@echo on