@echo off
set DISKNAME=disk
if not "%1"=="" set DISKNAME=%1
if not exist %CD%\%DISKNAME%.vhd goto NOTFOUND
echo Unmounting %CD%\%DISKNAME%.vhd from Z:
echo select vdisk file="%CD%\%DISKNAME%.vhd" > script.vhd
echo detach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
goto END
:NOTFOUND
echo Disk %CD%\%DISKNAME%.vhd not found!
:END
