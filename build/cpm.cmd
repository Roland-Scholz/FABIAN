@echo off
set CLASSPATH=.;..\tools\Terminal\bin;..\tools\Terminal\lib\jSerialComm-2.10.4.jar
java Terminal -p COM4 cpm
