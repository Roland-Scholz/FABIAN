program srecv;
{$I-}
type
  tBuf = array [1..128] of byte;

var
  i: integer;
  buf: tBuf;
  c: char;
  b: byte;
  f: file;
  fname: string[20];

procedure getBuffer(var buf: tBuf);
begin
  inline (
   $06/$80/                        { ld   b, 128     00}
   $2A/buf/                        { ld   hl, (buf)  02}
   $DB/$01/                        { in   a, (STATA) 04}
   $E6/$01/                        { and  1          06}
   $28/$FA/                        { jr   Z, -6      08}
   $DB/$03/                        { in   a, (RECA)  0A}
   $77/                            { ld   (hl), a    0C}
   $23/                            { inc  hl         0D}
   $10/$F4/                        { djnz -12        0E}
   $C9                             { ret             10}
   );
end;

procedure prtMenu;
begin
  writeln('send/recv waiting for command...');
end;

procedure send;
begin
  write(aux, 's');
end;

procedure ack;
begin
  write(aux, 'A');
end;

procedure err;
begin
  write(aux, 'E');
end;

procedure doReceive;
begin
  ack;
  readln(aux, fname);
  assign(f, fname);
  rewrite(f);
  if IOResult <> 0 then
     err
  else begin
     write('receiving ', fname);
     ack;

     repeat
       read(aux, c);
       if c = 's' then
       begin
         getBuffer(buf);
         write('.');
         BlockWrite(f, buf, 1);
         if IOResult <> 0 then
         begin
           err;
           c := 'c';
         end else begin
           ack;
         end;
       end;
     until c <> 's';
     close(f);
     writeln;
  end;
end;

procedure doSend;
begin
  ack;
  readln(aux, fname);
  assign(f, fname);
  reset(f);
  if IOResult <> 0 then
     err
  else begin
     write('sending ', fname);
     ack;
     repeat
       c := 'A';
       BlockRead(f, buf, 1);
       if IOResult <> 0 then
       begin
         err;
         c := 'E';
       end else begin
         write('.');
         send;
         for i := 1 to 128 do begin
           write(aux, chr(buf[i]));
         end;
         read(aux, c);
       end;
     until c <> 'A';

     close(f);
     writeln;
  end;

end;


begin
  repeat
    prtMenu;
    read(aux, c);
    case c of
      's': doReceive;
      'r': doSend;
    end;
  until c = 'q';
end.