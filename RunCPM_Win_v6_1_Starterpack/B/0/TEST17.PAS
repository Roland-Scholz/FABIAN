PROGRAM directory;
   TYPE
     Str2 = STRING[2];
   CONST
      fcb : ARRAY[0..35] OF CHAR='?FILE?      '#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#00#;
      FindFirst = 17;
      FindNext = 18;
      SetDMA = 26;
   VAR
      a : BYTE;
      i,j,dmaIndex : INTEGER;
      c : CHAR;
      dma : ARRAY[0..127] OF BYTE;
      buf : ARRAY[0..15] OF BYTE;

   FUNCTION tohex(b : BYTE) : Str2;
   CONST
      Hex : ARRAY[0..15] OF CHAR='0123456789ABCDEF';
   BEGIN
     tohex := Hex[b DIV 16]+Hex[b MOD 16];
   END;

   BEGIN
      BDOS(SetDMA,ADDR(dma));
      a := BDOS(FindFirst,ADDR(fcb));
      WHILE a in [0..3] DO BEGIN
         dmaIndex := a*32;
         FOR i := 0 TO 31 DO BEGIN
            buf[i] := dma[dmaIndex];
            dmaIndex := SUCC(dmaIndex);
         END;
         FOR i := 0 TO 1 DO BEGIN
            FOR j := 0 TO 15 DO
               WRITE(tohex(buf[i*16+j]),' ');
            WRITE(' ');
            FOR j :=  0 TO 15 DO BEGIN
               c := CHR(buf[16*i+j]);
               IF c IN [' '..'~'] THEN
                  WRITE(c)
               ELSE
                  WRITE('.');
            END;
            WRITELN;
         END;
         a := BDOS(FindNext,ADDR(fcb));
      END;
   END.
