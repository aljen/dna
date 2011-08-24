@echo off
set DISKNAME=%CD%\disk.vhd
if not "%1"=="" set DISKNAME=%1
if not exist %DISKNAME% goto NOTFOUND
echo Unmounting %DISKNAME%
echo select vdisk file="%DISKNAME%" > script.vhd
echo detach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
goto END
:NOTFOUND
echo Disk %DISKNAME% not found!
:END
