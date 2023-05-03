@echo off
PATH=%PATH%;..\tools;..\tools\z88dk\bin;..\tools\cpmimage\Debug

set CPM=C:\atarigit\CPM\RunCPM-master\Release
set ASM=z80asm
rem set ASM=z80asm.exe
rem set ASM=tniasm.exe

call :compile z80 0000
if not %ERRORLEVEL%==0 goto error

call :compile z80test 8000
if not %ERRORLEVEL%==0 goto error

call :compile cpm22z80 DC00
if not %ERRORLEVEL%==0 goto error

call :compile cpm22bios F200 -DSTANDALONE
if not %ERRORLEVEL%==0 goto error


move ..\src\*.o ..\release
move ..\src\*.hex ..\release
move ..\src\*.lis ..\release
move ..\src\*.com ..\release


pushd ..\CPM

del ..\release\disk00.dsk
cpmimage.exe ..\release\disk00.dsk make
cpmimage.exe ..\release\disk00.dsk init
cpmimage.exe ..\release\disk00.dsk wsys ..\release\cpm22z80.com

cpmimage.exe ..\release\disk00.dsk w test.pas
cpmimage.exe ..\release\disk00.dsk w turbo.com
cpmimage.exe ..\release\disk00.dsk w TURBO.EDT
cpmimage.exe ..\release\disk00.dsk w TURBO.MSG
cpmimage.exe ..\release\disk00.dsk w TURBO.ovr
cpmimage.exe ..\release\disk00.dsk w tinst.com
cpmimage.exe ..\release\disk00.dsk w tinst.dta
cpmimage.exe ..\release\disk00.dsk w tinst.msg

cpmimage.exe ..\release\disk00.dsk w ddt.com
cpmimage.exe ..\release\disk00.dsk w dskmaint.com
cpmimage.exe ..\release\disk00.dsk w dump.com
cpmimage.exe ..\release\disk00.dsk w ed.com
cpmimage.exe ..\release\disk00.dsk w load.com
cpmimage.exe ..\release\disk00.dsk w pip.com
cpmimage.exe ..\release\disk00.dsk w stat.com
cpmimage.exe ..\release\disk00.dsk w submit.com
cpmimage.exe ..\release\disk00.dsk w xsub.com
cpmimage.exe ..\release\disk00.dsk w ddtz.com
cpmimage.exe ..\release\disk00.dsk w zexdoc.com
cpmimage.exe ..\release\disk00.dsk w nc.com

cpmimage.exe ..\release\disk00.dsk w power.com
popd

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


