set CPMIMAGE=..\cpmimage\Debug\cpmimage.exe
set DISK=cc.dsk

del %DISK%

%CPMIMAGE% %DISK% make
%CPMIMAGE% cc.dsk w cc.com
%CPMIMAGE% cc.dsk w cc2.com
%CPMIMAGE% cc.dsk w cconfig.com
%CPMIMAGE% cc.dsk w clink.com
%CPMIMAGE% cc.dsk w cload.c
%CPMIMAGE% cc.dsk w stdio.h
%CPMIMAGE% cc.dsk w c.ccc
%CPMIMAGE% cc.dsk w deff.crl
%CPMIMAGE% cc.dsk w deff2.crl
%CPMIMAGE% cc.dsk w power.com



..\..\Tools\FatFs\Debug\FatFs.exe -c ..\..\My6502Emu\test.dat %DISK%

copy disk0.dsk e:
copy cpm22.sys e:


