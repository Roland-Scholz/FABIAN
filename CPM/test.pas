program hanoi;
  {$A-}

  procedure hanoi(n, a, b, h:integer);
  begin
    if n > 0 then
    begin
         hanoi(n-1, a, h, b);
         writeln(a, ' --> ', b);
         hanoi(n-1, h, b, a);
    end;
  end;

begin
  hanoi(3, 1, 2, 3);
end.