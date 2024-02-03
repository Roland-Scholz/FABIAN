@echo off
PATH=%PATH%;..\tools;..\tools\z88dk\bin;\github\fabian\tools

set CPM=C:\atarigit\CPM\RunCPM-master\Release
set ASM=z80asm

rem ****************************************************
rem * compile CP/M 2.2
rem ****************************************************
call :compile cpm22z80 DC00
if not %ERRORLEVEL%==0 goto error

rem ****************************************************
rem * compile BIOS
rem ****************************************************
call :compile cpm22bios F200 -DSTANDALONE
if not %ERRORLEVEL%==0 goto error


move ..\src\*.o ..\release
move ..\src\*.hex ..\release
move ..\src\*.lis ..\release
move ..\src\*.com ..\release

pause
goto ende

pushd ..\CPM

del ..\release\disk00.dsk
cpmfs.exe -t 8MB ..\release\disk00.dsk init
rem pause
cpmfs.exe ..\release\disk00.dsk ws ..\release\cpm22z80.com

cpmfs.exe ..\release\disk00.dsk w test.pas
cpmfs.exe ..\release\disk00.dsk w turbo.com
cpmfs.exe ..\release\disk00.dsk w TURBO.EDT
cpmfs.exe ..\release\disk00.dsk w TURBO.MSG
cpmfs.exe ..\release\disk00.dsk w TURBO.ovr
rem cpmfs.exe ..\release\disk00.dsk w tinst.com
rem cpmfs.exe ..\release\disk00.dsk w tinst.dta
rem cpmfs.exe ..\release\disk00.dsk w tinst.msg

rem cpmfs.exe ..\release\disk00.dsk w ddt.com
cpmfs.exe ..\release\disk00.dsk w dskmaint.com
cpmfs.exe ..\release\disk00.dsk w dump.com
cpmfs.exe ..\release\disk00.dsk w ed.com
rem cpmfs.exe ..\release\disk00.dsk w load.com
cpmfs.exe ..\release\disk00.dsk w pip.com
cpmfs.exe ..\release\disk00.dsk w stat.com
cpmfs.exe ..\release\disk00.dsk w submit.com
cpmfs.exe ..\release\disk00.dsk w xsub.com
cpmfs.exe ..\release\disk00.dsk w ddtz.com
rem cpmfs.exe ..\release\disk00.dsk w zexdoc.com
rem cpmfs.exe ..\release\disk00.dsk w nc.com
cpmfs.exe ..\release\disk00.dsk w power.com
cpmfs.exe ..\release\disk00.dsk w te.com
popd

pushd ..\src
cpmfs.exe ..\release\disk00.dsk w mandel.pas
cpmfs.exe ..\release\disk00.dsk w hexedit.pas
popd

pushd ..\vga\vt100-test
cpmfs.exe ..\..\release\disk00.dsk w xmas-05.vt
cpmfs.exe ..\..\release\disk00.dsk w xmas-06.vt
cpmfs.exe ..\..\release\disk00.dsk w xmas-07.vt
popd

rem copy ..\release\disk00.dsk e:

pause
goto ende

rem ----------------------------------------------
:compile
	pushd ..\src
	echo *** compile %1
	%ASM% -mz80 %3 -b -l -o%1.com %1 
	if not %ERRORLEVEL%==0 goto ende

	bin2hex %1.com %1.hex -o %2
	popd
	goto ende
rem ----------------------------------------------

:error
	pause
:ende


