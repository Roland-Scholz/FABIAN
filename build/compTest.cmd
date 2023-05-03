@echo off
PATH=%PATH%;..\tools;..\tools\z88dk\bin;..\tools\cpmimage\Debug

set CPM=C:\atarigit\CPM\RunCPM-master\Release
set ASM=z80asm
rem set ASM=z80asm.exe
rem set ASM=tniasm.exe


call :compile z80test 2000
if not %ERRORLEVEL%==0 goto error

call :compile cpm22bios F200 -DSTANDALONE
if not %ERRORLEVEL%==0 goto error

move ..\src\*.o ..\release
move ..\src\*.hex ..\release
move ..\src\*.lis ..\release
move ..\src\*.com ..\release

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


