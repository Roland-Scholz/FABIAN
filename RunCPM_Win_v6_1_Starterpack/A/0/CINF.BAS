10 PRINT "Which INFO do you want in INFO.TXT? (empty String = ABORT)"
20 INPUT "> ";TEXT$
30 IF TEXT$="" THEN GOTO 110
40 OPEN "O",1,"INFO.TXT"
50 PRINT #1,TEXT$
60 CLOSE #1
70 PRINT
80 PRINT "INFO.TXT file created with the following content:"
90 PRINT TEXT$
100 GOTO 130
110 PRINT
120 PRINT "No INFO.TXT created - because of empty input"
130 END
llowing content:"
90 P