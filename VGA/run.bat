@echo off
PATH="C:\Program Files (x86)\teraterm";%PATH%
start s51 -t 8052 -X22118400 -Sport=555 -e r %1
start ttermpro localhost:555 /DS