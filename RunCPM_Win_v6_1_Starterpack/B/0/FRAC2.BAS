10 C$ = ".,'~=+:;[/<&?oxOX# " : REM 'Pallet' Lightest to darkest...
20 FOR Y=-12 TO 12
30 FOR X=-39 TO 39
40 CA=X*.0458
50 CB= Y*.08333
60 A=CA
70 B=CB
80 FOR I=0 TO 15
90 T=A*A-B*B+CA
100 B=2*A*B+CB
110 A=T
120 IF (A*A+B*B)>4 THEN GOTO 160
130 NEXT I
140 PRINT " ";
150 GOTO 190
160 IF I>9 THEN I=I+7
170 REM PRINT CHR$(48+I);
180  PRINT MID$(C$, I+1, 1);
190 NEXT X
200 PRINT
210 NEXT Y
0 GOTO 190
160 IF I>9 THEN I=I+7
170 REM PRINT CHR$(48+I);
180  PRINT MID$(C$, I+1, 1);
190 NEXT 