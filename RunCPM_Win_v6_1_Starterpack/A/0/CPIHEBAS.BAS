140 PRINT "Calculating Pi as a BASIC benchmark."
150 PRINT "Enter number of digits (below or equal 1000): ";
160 INPUT S$
170 IF S$ = "" THEN PRINT "Nothing done.": END
180 N = VAL(S$):IF N > 1000 OR N< 1 THEN PRINT "Not a valid number.": GOTO 150
200 LN = INT(10 * N / 3) + 16
210 ND = 1
230 DIM A(3350)
240 SM=MILLIS(1)
250 N9 = 0
260 PD = 0
280 FOR J = 1 TO LN
290 A(J) = 2
300 NEXT J
320 FOR J = 1 TO N
330     Q = 0
340     FOR I = LN TO 1 STEP -1
350         X = 10 * A(I) + Q * I
360         A(I) = X - (2 * I - 1) * INT(X / (2 * I - 1))
370         Q = INT(X / (2 * I - 1))
380     NEXT I
390 A(1) = Q - 10 * INT(Q / 10)
400     Q = INT(Q / 10)
410     IF Q = 9 THEN N9 = N9 + 1: GOTO 610
420     IF Q <> 10 THEN GOTO 540
440        D = PD + 1: GOSUB 670
450        IF N9 <= 0 THEN GOTO 500
460           FOR K = 1 TO N9
470              D = 0: GOSUB 670
480           NEXT K
500        PD = 0
510        N9 = 0
520        GOTO 610
540        D = PD: GOSUB 670
550        PD = Q
560        IF N9 = 0 THEN GOTO 610
570           FOR K = 1 TO N9
580              D = 9: GOSUB 670
590           NEXT K
600           N9 = 0
610 NEXT J
620 PRINT RIGHT$(STR$(PD), 1);
640 END
670  IF ND=0 THEN PRINT RIGHT$(STR$(PD), 1);: RETURN
680 IF D=0 THEN RETURN
690 PRINT RIGHT$(STR$(PD), 1);".";
700 ND = 0
710 RETURN
                                                