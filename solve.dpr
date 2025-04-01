uses sysutils;

type
  PPolyNode = ^TPolyNode;
  
  TPolyNode = record
    Power: Integer;
    Coeff: Integer;
    Next: PPolyNode;
  end;

// Создание нового узла многочлена
function CreateNode(power, coeff: Integer): PPolyNode;
var
  node: PPolyNode;
begin
  New(node);
  node^.Power := power;
  node^.Coeff := coeff;
  node^.Next := nil;
  CreateNode := node;
end;

// Добавление члена в многочлен (с сохранением порядка по убыванию степеней)
procedure AddTerm(var poly: PPolyNode; power, coeff: Integer);
var
  current, prev, newNode: PPolyNode;
begin
  // Если коэффициент равен 0, не добавляем член
  if coeff = 0 then
    Exit;
    
  newNode := CreateNode(power, coeff);
  
  // Если список пуст или новый член имеет степень выше, чем первый узел
  if (poly = nil) or (power > poly^.Power) then
  begin
    newNode^.Next := poly;
    poly := newNode;
    Exit;
  end;

  if power = poly^.Power then
  begin
    poly^.Coeff := poly^.Coeff + coeff;

    if poly^.Coeff = 0 then
    begin
      current := poly;
      poly := poly^.Next;
      Dispose(current);
    end;
    

    Dispose(newNode);
    Exit;
  end;
  
  current := poly;
  while (current^.Next <> nil) and (current^.Next^.Power > power) do
    current := current^.Next;
  
  // Если нашли узел с такой же степенью
  if (current^.Next <> nil) and (current^.Next^.Power = power) then
  begin
    current^.Next^.Coeff := current^.Next^.Coeff + coeff;
    
    if current^.Next^.Coeff = 0 then
    begin
      prev := current^.Next;
      current^.Next := current^.Next^.Next;
      Dispose(prev);
    end;
    
    Dispose(newNode);
  end
  else
  begin
    newNode^.Next := current^.Next;
    current^.Next := newNode;
  end;
end;

function CreatePolynomial(powers, coeffs: array of Integer): PPolyNode;
var
  poly: PPolyNode;
  i: Integer;
begin
  poly := nil;
  for i := 0 to High(powers) do
    AddTerm(poly, powers[i], coeffs[i]);
  CreatePolynomial := poly;
end;

procedure PrintPolynomial(poly: PPolyNode);
var
  current: PPolyNode;
  isFirst: Boolean;
begin
  if poly = nil then
  begin
    WriteLn('0');
    Exit;
  end;
  
  current := poly;
  isFirst := True;
  
  while current <> nil do
  begin
    // Вывод знака
    if isFirst then
    begin
      if current^.Coeff < 0 then
        Write('-');
      isFirst := False;
    end
    else
    begin
      if current^.Coeff < 0 then
        Write(' - ')
      else
        Write(' + ');
    end;
    
    if (Abs(current^.Coeff) <> 1) or (current^.Power = 0) then
      Write(Abs(current^.Coeff));
    
    case current^.Power of
      0: ;
      1: Write('x');
      else Write('x^', current^.Power);
    end;
    
    current := current^.Next;
  end;
  
  WriteLn;
end;

procedure FreePolynomial(var poly: PPolyNode);
var
  current, temp: PPolyNode;
begin
  current := poly;
  while current <> nil do
  begin
    temp := current;
    current := current^.Next;
    Dispose(temp);
  end;
  poly := nil;
end;

function Equality(p, q: PPolyNode): Boolean;
var
  currentP, currentQ: PPolyNode;
begin
  currentP := p;
  currentQ := q;
  
  while (currentP <> nil) and (currentQ <> nil) do
  begin
    if (currentP^.Power <> currentQ^.Power) or (currentP^.Coeff <> currentQ^.Coeff) then
    begin
      Equality := False;
      Exit;
    end;
    
    currentP := currentP^.Next;
    currentQ := currentQ^.Next;
  end;
  
  Equality := (currentP = nil) and (currentQ = nil);
end;

function Meaning(p: PPolyNode; x: Integer): Integer;
var
  current: PPolyNode;
  res, term, i: Integer;
begin
  res := 0;
  current := p;
  
  while current <> nil do
  begin
    term := 1;
    for i := 1 to current^.Power do
      term := term * x;
    
    // Добавляем coeff * x^power к результату
    res := res + current^.Coeff * term;
    
    current := current^.Next;
  end;
  
  Meaning := res;
end;

// Сложение многочленов q и r, результат в p
procedure Add(var p: PPolyNode; q, r: PPolyNode);
var
  currentQ, currentR: PPolyNode;
begin
  FreePolynomial(p);
  
  currentQ := q;
  currentR := r;
  
  while (currentQ <> nil) or (currentR <> nil) do
  begin
    if (currentR = nil) or ((currentQ <> nil) and (currentQ^.Power > currentR^.Power)) then
    begin
      AddTerm(p, currentQ^.Power, currentQ^.Coeff);
      currentQ := currentQ^.Next;
    end
    else if (currentQ = nil) or ((currentR <> nil) and (currentR^.Power > currentQ^.Power)) then
    begin
      AddTerm(p, currentR^.Power, currentR^.Coeff);
      currentR := currentR^.Next;
    end
    else
    begin
      if currentQ^.Coeff + currentR^.Coeff <> 0 then
        AddTerm(p, currentQ^.Power, currentQ^.Coeff + currentR^.Coeff);
      
      currentQ := currentQ^.Next;
      currentR := currentR^.Next;
    end;
  end;
end;

var
  P, Q, R: PPolyNode;
  x: Integer;

begin
  // Создаем многочлен P(x) = 3x^4 + 2x^2 - 5
  P := nil;
  AddTerm(P, 4, 3);
  AddTerm(P, 2, 2);
  AddTerm(P, 0, -5);
  
  // Создаем многочлен Q(x) = -2x^3 + x^2 + 7
  Q := nil;
  AddTerm(Q, 3, -2);
  AddTerm(Q, 2, 1);
  AddTerm(Q, 0, 7);
  
  // Выводим многочлены
  Write('P(x) = ');
  PrintPolynomial(P);
  WriteLn();
  
  Write('Q(x) = ');
  PrintPolynomial(Q);
  WriteLn();
  
  // Проверяем равенство
  WriteLn('P = Q is ', Equality(P, Q));
  
  // Вычисляем значения в точке x = 2
  x := 2;
  WriteLn('P(', x, ') = ', Meaning(P, x));
  WriteLn('Q(', x, ') = ', Meaning(Q, x));
  
  // Складываем многочлены
  R := nil;
  Add(R, P, Q);
  Write('R(x) = P(x) + Q(x) = ');
  PrintPolynomial(R);
  WriteLn();
  
  // Вычисляем значение суммы в точке x = 2
  WriteLn('R(', x, ') = ', Meaning(R, x));
  WriteLn();

  WriteLn('P(', x, ') + Q(', x, ') = ', Meaning(P, x) + Meaning(Q, x));
  WriteLn();
  
  // Проверяем, что R(x) = P(x) + Q(x)
  WriteLn('R(', x, ') = P(', x, ') + Q(', x, ') is ', Meaning(R, x) = Meaning(P, x) + Meaning(Q, x));
  WriteLn();
  
  // Создаем многочлен S(x) = -5x^6 + 3x^2 - x + 7 из примера в задании
  WriteLn;
  WriteLn('Добавление:');
  P := nil;
  AddTerm(P, 6, -5);
  AddTerm(P, 2, 3);
  AddTerm(P, 1, -1);
  AddTerm(P, 0, 7);
  
  Write('S(x) = ');
  PrintPolynomial(P);
  
  // Освобождаем память
  FreePolynomial(P);
  FreePolynomial(Q);
  FreePolynomial(R);
end.
