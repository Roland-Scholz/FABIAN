PROGRAM Fractal;

VAR A, B, CA, CB, T:Real;
    X, Y, I:Integer;

LABEL ZH, ZHZ;

BEGIN

FOR Y:=-12 TO 12 DO BEGIN

FOR X:=-39 TO 39 DO BEGIN
CA:=X*0.0458;
CB:=Y*0.08333;
A:=CA;
B:=CB;

FOR I:=0 TO 15 DO BEGIN
  T:=A*A-B*B+CA;
  B:=2*A*B+CB;
  A:=T;
  IF (A*A+B*B)>4 THEN GOTO ZH;
END; (* Ende FOR I *)
WRITE (' ');
GOTO ZHZ;

ZH:
IF I>9 THEN I:=I+7;
WRITE (Chr(48+I));

ZHZ:
END;
WRITELN('');
END;
END.
