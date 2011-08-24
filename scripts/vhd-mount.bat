@echo off
set DISKNAME=disk
set DISKLETTER=z
if not "%1"=="" set DISKNAME=%1
if not "%2"=="" set DISKLETTER=%2
if not exist %CD%\%DISKNAME%.vhd goto NOTFOUND
echo Mounting %CD%\%DISKNAME%.vhd as %DISKLETTER%:
echo select vdisk file="%CD%\%DISKNAME%.vhd" > script.vhd
echo attach vdisk >> script.vhd
echo select partition 1 >> script.vhd
echo assign letter=%DISKLETTER% >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
goto END
:NOTFOUND
echo Disk %CD%\%DISKNAME%.vhd not found!
:END
