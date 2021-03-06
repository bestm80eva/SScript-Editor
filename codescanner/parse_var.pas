(* TCodeScanner.ParseVar *)
Procedure TCodeScanner.ParseVar;
Var Name, TypeStr: String;
    Vari         : TVariable;
Begin
 With Parser do
 Begin
  eat(_LOWER); // `<`
  TypeStr := read_type;
  eat(_GREATER); // `>`

  While (true) Do
  Begin
   Name := read_ident;

   Vari     := TVariable.Create(self, next(-1), getCurrentRange, Name);
   Vari.Typ := TypeStr;

   AddIdentifier(Vari, next(-1));

   if (inFunction) Then
    CurrentFunction.SymbolList.Add(TSymbol.Create(stVariable, Vari)) Else
    CurrentNamespace.SymbolList.Add(TSymbol.Create(stVariable, Vari));

   // var<foo> xyz = ...;
   if (next_t = _EQUAL) THen
   Begin
    eat(_EQUAL);
    read_and_mark([_SEMICOLON, _COMMA]);
    StepBack; // 'read_and_mark' eats previous token
   End Else

   // var<foo[]> xyz(...);
   if (next_t = _BRACKET1_OP) Then
   Begin
    eat(_BRACKET1_OP);
    read_and_mark([_BRACKET1_CL]);
   End;

   if (next_t in [_SEMICOLON, _IN]) Then
   Begin
    eat(next_t);
    Break;
   End Else
   Begin
    eat(_COMMA);
   End;
  End;
 End;
End;

(* TCodeScanner.ParseConst *)
Procedure TCodeScanner.ParseConst;
Var Name: String;
    Cnst: TVariable;
Begin
 With Parser do
 Begin
  While (true) Do
  Begin
   Name := read_ident;
   Cnst := TVariable.Create(self, next(-1), getCurrentRange, Name);

   if (inFunction) Then
    CurrentFunction.SymbolList.Add(TSymbol.Create(stConstant, Cnst)) Else
    CurrentNamespace.SymbolList.Add(TSymbol.Create(stConstant, Cnst));

   eat(_EQUAL);

   Cnst.Value := read_and_mark([_COMMA, _SEMICOLON]);

   if (next_t(-1) = _SEMICOLON) Then
    Exit;
  End;
 End;
End;
