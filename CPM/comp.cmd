
asm8080.exe cpm22.asm -lcpm22.lst
asm8080.exe tst8080.asm -ltst8080.lst

zmac -l zexdoc.asm > zexdoc.lst
copy zout\zexdoc.cim zexdoc.com

@echo off
copy /B startup.bin + cpm22.bin cpm22.sys
..\Tools\FatFs\Debug\FatFs.exe -c ..\My6502Emu\test.dat cpm22.sys
..\Tools\FatFs\Debug\FatFs.exe -c ..\My6502Emu\test.dat tst8080.bin
..\Tools\FatFs\Debug\FatFs.exe -c ..\My6502Emu\test.dat prelim.rom

copy zexdoc.com C:\atarigit\CPM\RunCPM-master\Release\A\0

del disk00.dsk
cpmimage\Debug\cpmimage.exe disk00.dsk make
cpmimage\Debug\cpmimage.exe disk00.dsk init
cpmimage\Debug\cpmimage.exe disk00.dsk wsys cpm22z80.com
cpmimage\Debug\cpmimage.exe disk00.dsk w test.pas

cpmimage\Debug\cpmimage.exe disk00.dsk w turbo.com
cpmimage\Debug\cpmimage.exe disk00.dsk w TURBO.EDT
cpmimage\Debug\cpmimage.exe disk00.dsk w TURBO.MSG
cpmimage\Debug\cpmimage.exe disk00.dsk w TURBO.ovr
cpmimage\Debug\cpmimage.exe disk00.dsk w tinst.com
cpmimage\Debug\cpmimage.exe disk00.dsk w tinst.dta
cpmimage\Debug\cpmimage.exe disk00.dsk w tinst.msg

cpmimage\Debug\cpmimage.exe disk00.dsk w ddt.com
cpmimage\Debug\cpmimage.exe disk00.dsk w dskmaint.com
cpmimage\Debug\cpmimage.exe disk00.dsk w dump.com
cpmimage\Debug\cpmimage.exe disk00.dsk w ed.com
cpmimage\Debug\cpmimage.exe disk00.dsk w load.com
cpmimage\Debug\cpmimage.exe disk00.dsk w pip.com
cpmimage\Debug\cpmimage.exe disk00.dsk w stat.com
cpmimage\Debug\cpmimage.exe disk00.dsk w submit.com
cpmimage\Debug\cpmimage.exe disk00.dsk w xsub.com
cpmimage\Debug\cpmimage.exe disk00.dsk w ddtz.com
cpmimage\Debug\cpmimage.exe disk00.dsk w zexdoc.com
cpmimage\Debug\cpmimage.exe disk00.dsk w nc.com

rem cpmimage\Debug\cpmimage.exe disk00.dsk w dis6502.com
rem cpmimage\Debug\cpmimage.exe disk00.dsk w dis6502.mac

rem cpmimage\Debug\cpmimage.exe disk00.dsk w hw.com

cpmimage\Debug\cpmimage.exe disk00.dsk w power.com
rem cpmimage\Debug\cpmimage.exe disk00.dsk w exit.com

rem cpmimage\Debug\cpmimage.exe disk00.dsk w sample.txt
rem cpmimage\Debug\cpmimage.exe disk00.dsk w ws.com
rem cpmimage\Debug\cpmimage.exe disk00.dsk w wsmsgs.ovr
rem cpmimage\Debug\cpmimage.exe disk00.dsk w install.com
rem cpmimage\Debug\cpmimage.exe disk00.dsk w mergprin.ovr
rem cpmimage\Debug\cpmimage.exe disk00.dsk w WSOVLY1.OVR

..\Tools\FatFs\Debug\FatFs.exe -c ..\My6502Emu\test.dat disk00.dsk

rem copy disk0.dsk e:
copy disk00.dsk C:\Users\rolan\workspace\myWebServer
rem copy cpm22.sys e:

set CPM=RunCPM-master\Release
pushd %CPM%
runcpm
popd

pause


