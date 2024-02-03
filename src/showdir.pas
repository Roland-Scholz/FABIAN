program showdir;
var
  dma: array [1..128] of byte;
  fcb: array [1..36] of byte;
  func, res, adr, i: integer;

procedure prtDirEntry;
var
  adr: integer;
  drv: byte;
begin

  adr := res shl 5;
  drv := dma[adr+1];

  if (drv <> 229) and (res <> 255) then begin
    for i := 2 to 12 do begin
      write(chr(dma[i+adr]));
    end;
    writeln;
  end;
end;

begin

  FillChar(fcb, 36, 0);
  FillChar(fcb[2], 11, '?');
  fcb[10] := ord('C');

  func := 17;
  Bdos(26, addr(dma));

  repeat
    res := Bdos(func, addr(fcb));
    prtDirEntry;
    if func = 17 then func := 18;
  until res = 255;

end.
