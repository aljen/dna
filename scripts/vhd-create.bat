@echo off
set DISKNAME=disk
set DISKSIZE=128
set DISKLETTER=z
if not "%1"=="" set DISKNAME=%1
if not "%2"=="" set DISKSIZE=%2
if not "%3"=="" set DISKLETTER=%3
echo Creating %CD%\%DISKNAME%.vhd with size %DISKSIZE% MB (ext2)
echo create vdisk file="%CD%\%DISKNAME%.vhd" maximum=%DISKSIZE% type=fixed noerr > script.vhd
echo select vdisk file="%CD%\%DISKNAME%.vhd" >> script.vhd
echo attach vdisk noerr>> script.vhd
echo clean >> script.vhd
echo create partition primary noerr>> script.vhd
echo select partition 1 >> script.vhd
echo active >> script.vhd
echo assign letter=%DISKLETTER% >> script.vhd
diskpart /s script.vhd > nul
"c:\program files\ext2fsd\mke2fs" -b 4096 -L DNA %DISKLETTER%: < nul > nul
echo select vdisk file="%CD%\%DISKNAME%.vhd" > script.vhd
echo detach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
