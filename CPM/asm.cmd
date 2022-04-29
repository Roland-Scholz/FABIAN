PATH=%PATH%;C:\mingw\bin;C:\atarigit\CPM\asm85-master\src\Default
asm85 tst8080.asm -b0100:1000
move tst8080-0100.bin tst8080.com
..\Tools\FatFs\Debug\FatFs.exe -c ..\My6502Emu\test.dat tst8080.com
pause
