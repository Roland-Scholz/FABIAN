@echo off
PATH=%PATH%;C:\atarigit\Tools\cc65\bin;C:\atarigit\CPM\z88dk\bin

set CPM=C:\atarigit\CPM\RunCPM-master\Release
set ASM=sjasm

call :compile z80doc 0100
if not %ERRORLEVEL%==0 goto error
copy z80doc.com ..\..
pause
pushd
cd %CPM%
rem %CPM%\runcpm
popd
goto ende

rem ----------------------------------------------
:compile
	%ASM% %1.asm %1.com
	if not %ERRORLEVEL%==0 goto ende
	rem pause
	bin2hex %1.com %1.hex -o %2
	copy %1.com %CPM%\A\0
	pause
	goto ende
rem ----------------------------------------------
:error
	pause
:ende


