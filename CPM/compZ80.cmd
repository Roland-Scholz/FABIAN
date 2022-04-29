@echo off
PATH=%PATH%;C:\atarigit\Tools\cc65\bin;C:\atarigit\CPM\z88dk\bin

set CPM=C:\atarigit\CPM\RunCPM-master\Release
set ASM=z80asm
rem set ASM=z80asm.exe
rem set ASM=tniasm.exe

call :compile z80 0000
if not %ERRORLEVEL%==0 goto error
call :compile z80test 8000
if not %ERRORLEVEL%==0 goto error
call :compile cpm22z80 E400
if not %ERRORLEVEL%==0 goto error
call :compile cpm22z80 E400 -DCPU65816
if not %ERRORLEVEL%==0 goto error
call :compile cpm22bios FA00 -DSTANDALONE
if not %ERRORLEVEL%==0 goto error

rem zmac prelim.asm 0100
if not %ERRORLEVEL%==0 goto error

pause
goto ende
pushd
cd %CPM%
%CPM%\runcpm
popd
goto ende

rem ----------------------------------------------
:compile
	echo *** compile %1
	%ASM% -mz80 %3 -b -l -o%1.com %1 
	if not %ERRORLEVEL%==0 goto ende
	rem pause
	bin2hex %1.com %1.hex -o %2
	copy %1.com %CPM%\A\0\%1.com
	rem pause
	goto ende
rem ----------------------------------------------
:error
	pause
:ende


