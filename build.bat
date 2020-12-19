@echo off
echo Building ROM...
asm68k /p /q /c /o l+ /o ae- Sonic2B4.asm,Sonic2B4_Built.bin, ,S2B4.lst
IF NOT EXIST Sonic2B4_Built.bin goto LABLERR
echo Build succeeded!
goto LABLDONE
:LABLERR
echo Build failed.
:LABLDONE
pause
