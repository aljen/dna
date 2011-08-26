@echo off
set DISKNAME=%CD%\disk.vhd
set DISKLETTER=z
if not "%1"=="" set DISKNAME=%1
if not "%2"=="" set DISKLETTER=%2
echo select vdisk file="%DISKNAME%" > script.vhd
echo attach vdisk noerr>> script.vhd
echo clean >> script.vhd
echo create partition primary noerr>> script.vhd
echo select partition 1 >> script.vhd
echo active >> script.vhd
echo assign letter=%DISKLETTER% >> script.vhd
diskpart /s script.vhd > nul
"c:\program files\ext2fsd\mke2fs" -b 4096 -L DNA %DISKLETTER%: < nul > nul
echo select vdisk file="%DISKNAME%" > script.vhd
echo detach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
:END
