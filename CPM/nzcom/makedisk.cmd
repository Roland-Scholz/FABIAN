@echo off
set PATH=%PATH%;..\cpmimage\Debug
set DISK=disk01.dsk

copy ..\pip.com .
copy ..\power.com .

del %DISK%
cpmimage %DISK% make
cpmimage %DISK% init
cpmimage %DISK% wsys ..\cpm22z80.com

cpmimage %DISK% w NZCOM.COM
cpmimage %DISK% w ARUNZ.COM
cpmimage %DISK% w EASE.COM
cpmimage %DISK% w NZCOM.LBR
cpmimage %DISK% w ALIAS.CMD
cpmimage %DISK% w ZFILER.CMD
cpmimage %DISK% w MKZCM.COM
cpmimage %DISK% w LX.COM
cpmimage %DISK% w SHOW.COM
cpmimage %DISK% w SALIAS.COM
cpmimage %DISK% w IF.COM
cpmimage %DISK% w myterm.Z3T
cpmimage %DISK% w SDZ.COM
cpmimage %DISK% w ZEX.COM
cpmimage %DISK% w ZEX.RSX
cpmimage %DISK% w LDIR.COM
cpmimage %DISK% w TCSELECT.COM
cpmimage %DISK% w Z3TCAP.TCP
cpmimage %DISK% w ZF-REV.COM
cpmimage %DISK% w PIP.COM
cpmimage %DISK% w POWER.COM


rem copy %DISK% C:\Users\rolan\workspace\myWebServer

pause