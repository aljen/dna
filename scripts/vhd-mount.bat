@echo off
set DISKNAME=%CD%\disk.vhd
set DISKLETTER=z
if not "%1"=="" set DISKNAME=%1
if not "%2"=="" set DISKLETTER=%2
if not exist %DISKNAME% goto NOTFOUND
echo Mounting %DISKNAME% as %DISKLETTER%:
echo select vdisk file="%DISKNAME%" > script.vhd
echo attach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
goto END
:NOTFOUND
echo Disk %DISKNAME% not found!
:END
