program termio;

Const
  ESC = #27;
  WIDTH = 80;
  HEIGHT = 24;
  MAXIT = 10;
Var
  c : char;
  x : integer;
  y : integer;
  xmin, xmax, ymin, ymax : real;
  dx, dy : real;
  x0 : real;
  y0 : real;

procedure iterate(x0, y0 : real);
var i : integer;
var x, y, xx, yy : real;
begin
  i := 0;
  x := 0;
  y := 0;
  repeat
    i := i + 1;
    xx := x * x;
    yy := y * y;
    y := 2 * x * y + y0;
    x := xx - yy + x0;
  until (i > MAXIT) or (xx + yy > 4.0);
  if i > MAXIT then
    write(ESC, '[1;7m');
  write(' ', ESC, '[m');
end;

begin
  ClrScr;

  xmin := -2.0;
  xmax := 0.5;
  ymin := -1;
  ymax := 1;

  dx := (xmax - xmin) / WIDTH;
  dy := (ymax - ymin) / HEIGHT;

  y0 := ymin;
  for y := 1 to HEIGHT do
  begin
    x0 := xmin;
    for x := 1 to WIDTH do
    begin
      iterate(x0, y0);
      x0 := x0 + dx;
    end;
    if y <> HEIGHT then writeln;
    y0 := y0 + dy;
  end;
  read(kbd, c);
end.