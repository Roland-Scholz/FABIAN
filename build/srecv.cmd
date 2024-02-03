@echo off
set CLASSPATH=.;..\tools\Terminal\bin;..\tools\Terminal\lib\jSerialComm-2.10.4.jar

for %%i in (C:\github\FABIAN\cpm\mixc\*.*) do (
java Terminal -p COM4 send %%i
)
goto quit

for %%i in (C:\github\FABIAN\cpm\cobol\*.*) do (
java Terminal -p COM4 send %%i
)
goto quit

java Terminal -p COM4 recv C:\github\FABIAN\src\srecv.pas
java Terminal -p COM4 recv C:\github\FABIAN\src\hexedit.pas
java Terminal -p COM4 recv C:\github\FABIAN\src\showdir.pas

:quit
java Terminal -p COM4 quit

pause
