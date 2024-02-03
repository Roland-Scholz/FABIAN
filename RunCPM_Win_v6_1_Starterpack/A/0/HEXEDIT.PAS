program hexedit;
{$I-}
Const
  TAB = #9;
  LEFT = #19;
  RIGHT = #4;
  UP = #5;
  DOWN = #24;
  ESC  = #27;
  NEXT = 'n';
  PREV = 'p';
  RELOAD = 'r';
  GOADR = 'g';
Type
  HexStr = string[2];
  AdrStr = string[4];

Var
  filvar: file;
  buffer: array[1..128] of Byte;
  fsize, curx, cury, res, seekadr: integer;
  c: char;
  isdirty, inedit, redraw: boolean;
  filename: string[14];

procedure NV;
begin
  NormVideo;
end;

procedure LV;
begin
  LowVideo;
end;

function h2b(c: char): byte;
begin
  if c > '9' then h2b := ord(c) - ord('a') + 10
  else h2b := ord(c) - ord('0');
end;

function hexnibble(b: byte): char;
begin
  if b < 10 then hexnibble := chr(b + ord('0'))
  else hexnibble := chr(b + ord('A') - 10);
end;

function hex(b: byte): HexStr;
begin
  hex := hexnibble(b shr 4) + hexnibble(b and 15);
end;

function hexadr(i: integer): AdrStr;
begin
  hexadr := hex(i shr 8) + hex(i and 255);
end;

procedure update(adr: integer);
begin
  if isdirty then
  begin
    Reset(filvar);
    Seek(filvar, adr);
    BlockWrite(filVar, buffer, 1);
    isdirty := false;
  end;
end;


function fseek(adr: integer): integer;
Var
  res: integer;
begin
  Reset(filvar);
  res := IOresult;
  if res = 0 then
  begin
    Seek(filvar, adr);
    res := IOresult;
    if res = 0 then
    begin
      BlockRead(filvar, buffer, 1);
      res := IOresult;
    end;
  end;

  fseek := res;
end;

procedure prtDashline;
begin
  NV;
  writeln('+------------------------------------------------------------------------------+');
end;

procedure prtHeader;
begin
  LV; write('| ');
  NV; write(filename); GotoXY(18, 2);
  NV; write('filepos: ');
  LV; write(hexadr(seekadr shl 7));
  NV; write(' record: ');
  LV; write(hexadr(seekadr));
  NV; write(' size: ');
  LV; write(hexadr(fsize));
  NV; write(' modified: ');
  LV; write(isdirty, '   ');
  GotoXY(80, 2); write('|');
  writeln;
end;

procedure prtFooter;
begin
  LV; write('| ');
  NV; write('g');
  LV; write(': goto adr  ');
  NV; write('n');
  LV; write(': next rec  ');
  NV; write('p');
  LV; write(': prev rec  ');
  NV; write('r');
  LV; write(': reload  ');
  NV; write('ESC');
  LV; write(': exit');
  GotoXY(80, 13); writeln('|');
end;

procedure displayBuffer;
Var
  adr, x, y: integer;
  b: byte;
begin
  if redraw then
  begin
    redraw := false;
    adr := seekadr shl 7;

    GotoXY(1, 1);
    prtDashline;
    prtHeader;
    prtDashline;

    for y:= 0 to 7 do
    begin
      LV; write('| ');

      write(hexadr(adr), ': ');
      for x:= 1 to 16 do
      begin
        if x = 9 then
           write(' ');
        write(hex(buffer[(y shl 4) + x]), ' ');
      end;

      NV; write ('  |'); LV;
      for x := 1 to 16 do
      begin
        b := buffer[(y shl 4) + x];
        if (b < 32) or (b > 126) then write('.')
        else write(chr(b));
      end;

      NV; write('|  ');
      LV; write('|');
      adr := adr + 16;
      writeln;
    end;

    prtDashline;
    prtFooter;
    prtDashLine;
  end;
end;

procedure posCursor(x, y: integer);
Var
  offset: integer;
begin
  offset := 9;
  if x > 7 then offset := offset + 1;
  if inedit then offset := offset + 1;
  GotoXY(x * 3 + offset, y + 4);
end;

procedure doUp;
begin
  cury := cury - 1;
  if cury < 0 then cury := 7;
  inedit := false;
end;

procedure doDown;
begin
  cury := cury + 1;
  if cury > 7 then cury := 0;
  inedit := false;
end;

procedure doLeft;
begin
  curx := curx - 1;
  if curx < 0 then
  begin
    curx := 15;
    doUp;
  end;
  inedit := false;
end;

procedure doRight;
begin
  curx := curx + 1;
  if curx > 15 then
  begin
    curx := 0;
    doDown;
  end;
  inedit := false;
end;


procedure doEdit(c: char);
Var
  b, b1: byte;
  i: integer;
begin

  b := h2b(c);

  i := (cury shl 4) + curx + 1;
  b1 := buffer[i];


  {
  GotoXY(1, 20);
  writeln(i, ' ', b, ' ', b1);
  }

  if inedit then
  begin
    buffer[i] := (b1 and 240) or b;
    doRight;
    inedit := true;
  end else begin
    b := b shl 4;
    buffer[i] := (b1 and 15) or b;
  end;

  isDirty := true;
  inedit := not inedit;
  redraw := true;
end;

procedure doPrev;
begin
  update(seekadr);
  if seekadr > 0 then
     seekadr := seekadr - 1;
  res := fseek(seekadr);
  redraw := true;
  inedit := false;
end;

procedure doNext;
begin
  update(seekadr);
  seekadr := seekadr + 1;
  res := fseek(seekadr);
  if res <> 0 then
     seekadr := seekadr - 1;
  redraw := true;
  inedit := false;
end;

procedure doReset;
Var
  res: integer;
begin
  res := fseek(seekadr);
  isdirty := false;
  redraw := true;
  inedit := false;
end;

procedure doGoAdr;
Var
  c: char;
  rest, adr, res, i: integer;
  b: byte;
begin
  GotoXY(27, 2);
  i := 0;
  repeat
    read(kbd, c);
    case c of
      '0'..'9', 'a'..'f':
      begin
        b := h2b(c);
        adr := adr shl 4 + b;
        write(c);
        i := i + 1;
      end;
    end;
  until i > 3;

  rest := adr and 127;
  adr := adr shr 7;

  update(seekadr);
  i := fseek(adr);
  if i = 0 then
  begin
    seekadr := adr;
    cury := rest shr 4;
    curx := rest and 15;
  end;

  redraw := true;
  inedit := false;
end;

begin
  if ParamCount > 0 then
    filename := ParamStr(1)
  else begin
    write('enter file to edit:');
    readln(filename);
  end;

  assign(filvar, filename);
  reset(filvar);
  if IOresult <> 0 then
  begin
    writeln('unable to open file, press any key to exit');
    read(kbd, c);
    exit;
  end;


  ClrScr;
  seekadr := 0;
  curx := 0;
  cury := 0;
  inedit := false;
  isdirty := false;

  res := fseek(seekadr);
  fsize := FileSize(filvar);
  redraw := true;

  repeat

    DisplayBuffer;

    posCursor(curx, cury);

    read(kbd, c);
    case c of
      '0'..'9', 'a'..'f': doEdit(c);
      LEFT: doLeft;
      RIGHT, TAB: doRight;
      UP: doUp;
      DOWN: doDown;
      PREV: doPrev;
      NEXT: doNext;
      RELOAD: doReset;
      GOADR: doGoAdr;
    end;

  until c = ESC;

  close(filvar);
  GotoXY(1, 15);
end.