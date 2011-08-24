@echo off
set DISKNAME=disk
set DISKSIZE=128
if not "%1"=="" set DISKNAME=%1
if not "%2"=="" set DISKSIZE=%2
echo Creating %CD%\%DISKNAME%.vhd with size %DISKSIZE% MB
echo create vdisk file="%CD%\%DISKNAME%.vhd" maximum=%DISKSIZE% type=fixed noerr > script.vhd
echo select vdisk file="%CD%\%DISKNAME%.vhd" >> script.vhd
echo attach vdisk >> script.vhd
echo clean >> script.vhd
echo create partition primary >> script.vhd
echo format fs=fat32 label="DNA" quick >> script.vhd
echo detach vdisk >> script.vhd
diskpart /s script.vhd > nul
del script.vhd
