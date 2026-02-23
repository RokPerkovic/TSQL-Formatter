{$mode objfpc}
unit uLexan;

interface
uses uToken, uFileReader, classes, sysUtils;

const
	Keywords: Array [0..11] of String = ('select', 'from', 'where', 'order', 'top', 'join', 'left join', 'right join', 'as', 'group', 'by', 'is');
	
const 
	Symbols: Array [0..5] of Char = (',', '.', ';', '(', ')', '"');
	
const
	SymbolNames: Array [0..8] of String = ('comma', 'dot', 'semicolon', 'left_paren', 'right_paren', 'left_square', 'right_square', 'single_quote', 'quote');
	
const
	Operators: Array [0..13] of String = ('=', 'in', 'not', '+', '-', '*', '/', '<', '>', '<>', '>=', '<=', 'and', 'or');
	
const
	OperatorNames: Array [0..13] of String = ('EQ', 'IN', 'NOT', 'ADD', 'SUB', 'MUL', 'DIV', 'LT', 'GT', 'NOT_EQ', 'GTE', 'LTE', 'AND', 'OR');
	
const
	Whitespace: Array [0..4] of Char = (' ', #9, #10, #13, #0);

type
	TLexan = class
		private
			FFileReader: TFileReader;
			FInput: String;
			FInputLen: Integer;
			FInputPos: Integer;
			FKeyWords: Array [0..11] of String;
			function MakeToken(): TToken;
			function IsKeyword(Lexem: String): Boolean;
			function IsSymbol(c: Char): Boolean;
			function IsOperator(c: Char): Boolean;
			function IsWhitespace(c: Char): Boolean;
			function MakeString(): TToken;
			function MakeNumber(): TToken;
			function MakeComment(): TToken;
			function MakeMultiLineComment(): TToken;
			function MakeIdentifier(): TToken;
			function MakeQuotedIdentifier(): TToken;
			function MakeOperator(op: String): TToken;
			function Peek(): Char;
			
			//procedure printChars(s: String);
		public
			constructor Create({FileName: String} AInput: String);
			destructor Destroy(); override;
			function NextToken(): TToken;
			procedure printChars(s: String);
			
			
end;

implementation

constructor TLexan.Create({FileName: String;} AInput: String);
begin
	//FFileReader := TFileReader.Create(FileName);
	FInput := AInput;
	FInputLen := length(FInput);
	FInputPos := 1; // In old Turbo Pascal, ShortString (255-char strings) stored the length at s[0]
	FKeyWords := Keywords;
	//Writeln(FInput);
end;

destructor TLexan.Destroy();
begin
	FFileReader.Free;
	inherited Destroy;
end;

procedure TLexan.printChars(s: String);
var
  i: Integer;
begin
  //s := 'select';  // or the string you suspect
  Writeln('Length = ', Length(s));
  for i := 1 to Length(s) do
    Writeln(i, ': ', s[i], ' (', Ord(s[i]), ')');
end;


function TLexan.IsKeyword(Lexem: String): Boolean;
var 
	k: Integer;
begin
	Result := False;
	for k := Low(Keywords) to High(Keywords) do
	begin
		//Writeln(Keywords[k]);
		if Keywords[k] = LowerCase(Lexem) then
		begin
			Result := True;
			Exit;
		end;
	end;
end;

function TLexan.IsSymbol(c: Char): Boolean;
begin
	Result := False;
end;

function TLexan.IsWhitespace(c: Char): Boolean;
var	
	w: Integer;
begin
	Result := False;
	for w := Low(Whitespace) to High(Whitespace) do
	begin
		if Whitespace[w] = c then
		begin
			Result := True;
			Exit;
		end;
	end;
end;

function TLexan.IsOperator(c: Char): Boolean;
var
	o: Integer;
begin
	Result := False;
	for o := Low(Operators) to High(Operators) do
	begin
		if Operators[o] = c then
		begin
			Result := True;
			Exit;
		end;
	end;

end;

function TLexan.Peek(): Char;
begin

	if FInputPos < FInputLen then
	begin
		Inc(FInputPos);
		Result := FInput[FInputPos];
		Dec(FInputPos);
	end else
	begin
		Result := #0;
	end;
end;

function TLexan.MakeString(): TToken;
var
	Lexem: String;
	c: Char;
begin
	Lexem := '';
	// preberes '; se postavis na naslednji znak; preveris ali je konec vhoda; 
	while FInputPos <= FInputLen do
	begin
		if FInput[FInputPos] = '''' then
		begin
			if Peek() <> '''' then // escaped ' 'abc''def'
			begin
				Inc(FInputPos);
				break;
			end;
			Lexem := Lexem + '''';
			Inc(FInputPos); // ce je narekovaj in je escaped (naslednji je spet narekovaj), potem preskoci narekovaj
		end;
		c := FInput[FInputPos];
		Lexem := Lexem + c;
		Inc(FInputPos);
	end;

	Result := TToken.Create(Lexem, ttString);
end;

function TLexan.MakeNumber(): TToken;
var
	Lexem: String;
	c: Char;
begin
	Lexem := '';
	c := FInput[FInputPos];
	//Inc(FInputPos);
	while (FInput[FInputPos] >= '0') and (FInput[FInputPos] <= '9') do//(c >= '0') and (c <= '9') do // input = '12 +'
	begin
		Lexem := Lexem + c;
		//WriteLn(FInput[FInputPos]);
		Inc(FInputPos);
		if (FInput[FInputPos] >= '0') and (FInput[FInputPos] <= '9') then
			c := FInput[FInputPos]; // kaj pa ce naslednji znak ni vec stevilo? '1 ' 
		//Inc(FInputPos);
	end;
	
	//Writeln('FInputPos: ', FInputPos);
	//Inc(FInputPos);
	
	Result := TToken.Create(Lexem, ttLiteral);
end;

// build single-line ttComment (-- ttComment)
function TLexan.MakeComment(): TToken;
var
	Lexem: String;
	c: Char;
begin
	Lexem := '--';
	c := FInput[FInputPos];
	
	while (c <> #10) and (c <> #0) do
	begin
		Lexem := Lexem + c;
		Inc(FInputPos, 1);
		c := FInput[FInputPos];
	end;
	
	//printChars(Lexem); // CRLF messes up the TToken._toString() ?
	Result := TToken.Create(Lexem, ttComment);
end;

// build multi-line ttComment 
{
/* 
	line
	another line
...
*/
}
// vse kar je znotraj /* */ obravnavas kot Lexem (nima veze nested)
function TLexan.MakeMultiLineComment(): TToken;
var
  Lexem: String;
  c: Char;
  Token: TToken;
  Counter: Integer;
begin
  Lexem := '/*';
  Counter := 1;

  while FInputPos < Length(FInput) do
  begin
    c := FInput[FInputPos];

    if (c = '/') and (Peek() = '*') then
    begin
      Lexem := Lexem + c + Peek(); // add '/*'
      Inc(Counter);
      Inc(FInputPos, 2);
      Continue;
    end
    else if (c = '*') and (Peek() = '/') then
    begin
      Lexem := Lexem + c + Peek(); // add '*/'
      Dec(Counter);
      Inc(FInputPos, 2);
      if Counter = 0 then
        Break;
      Continue;
    end
    else
    begin
      Lexem := Lexem + c;
      Inc(FInputPos);
    end;
  end;

  if Counter <> 0 then
    raise Exception.Create('Missing end ttComment mark ''*/''');

  Result := TToken.Create(Lexem, ttComment);
end;


function TLexan.MakeOperator(op: String): TToken;
begin
	Inc(FInputPos);
	Result := TToken.Create(op, ttOper);
end;

function TLexan.MakeIdentifier(): TToken;
var
	Lexem: String;
	c: Char;
	Token: TToken;
begin
	Lexem := '';
	c := FInput[FInputPos];
	
	while not IsWhitespace(c) do
	begin
		Lexem := Lexem + c;
		Inc(FInputPos);
		c := FInput[FInputPos];
	end;
	
	Inc(FInputPos);
	
	if IsKeyword(Lexem) then
	begin
		Token := TToken.Create(Lexem, ttKeyword);
		Result := Token;
	end else
	begin
		Token := TToken.Create(Lexem, ttIdentifier);
		Result := Token;
	end;
end;

function TLexan.MakeQuotedIdentifier(): TToken;
var
	Lexem: String;
	c: Char;
	Token: TToken;
begin
	Lexem := '';
	c := FInput[FInputPos];
	
	while not IsWhitespace(c) do
	begin
		Lexem := Lexem + c;
		Inc(FInputPos);
		c := FInput[FInputPos];
	end;
	
	if IsKeyword(Lexem) then
	begin
		Token := TToken.Create(Lexem, ttKeyword);
		Result := Token;
	end else
	begin
		Token := TToken.Create(Lexem, ttQuotedIdentifier);
		Result := Token;
	end;
end;

function TLexan.NextToken(): TToken;
begin
	Result := MakeToken();
end;

function TLexan.MakeToken(): TToken;
var
	i: Integer;
	NextChar: Char;
	Token: TToken;
begin
	
	for i := FInputPos to FInputLen do
	begin
		if ((FInput[i] >= 'a') and (FInput[i] <= 'z')) or ((FInput[i] >= 'A') and (FInput[i] <= 'Z')) 
				or (FInput[i] = '[')
				or (FInput[i] = '"')
				or (FInput[i] = '@') then
		begin
			if ((FInput[i] = '[') or (FInput[i] = '"')) then
			begin
				Result := MakeQuotedIdentifier(); // a je to naloga tokenizerja ali parserja? Ali bi moral tokenizer vrnit left_square, ttIdentifier ali quoted ttIdentifier?
				Exit;
			end;
			Result := MakeIdentifier();
			Exit;
		end else if FInput[i] = '/' then
		begin
			NextChar := Peek();
			if (NextChar = '*')  then
			begin
				Inc(FInputPos, 2);
				Result := MakeMultiLineComment();
				Exit;
			end else
			begin
				Result := MakeOperator('/');
				Exit;
			end;
		end else if FInput[i] = '-' then
		begin
			NextChar := Peek();
			if (NextChar = '-')  then
			begin
				Inc(FInputPos, 2);
				Result := MakeComment();
				Exit;
			end else
			begin
				Result := MakeOperator('-');
				Exit;
			end;
		end else if IsOperator(FInput[i]) then //?
		begin
			NextChar := Peek();
			if IsOperator(NextChar) then
			begin
				Result := MakeOperator(FInput[i] + NextChar); // npr. 1+++1 je v MsSql veljaven expr...
				Exit;
			end else
			begin
				Result := MakeOperator(FInput[i]);
				//Inc(FInputPos);
				Exit;
			end;
		end else if (FInput[i] >= '0') and (FInput[i] <= '9') then
		begin
			Result := MakeNumber(); // tukaj gre delat številko
			//WriteLn('Input pos after MakeNumber', FInputPos);
			Exit;
		end else if (FInput[i] = '''') then
		begin
			//WriteLn('Make string');
			Inc(FInputPos);
			Result := MakeString();
			Exit;
		end else
		begin
			if not IsWhitespace(FInput[i]) then
			begin
				Raise Exception.Create(format('ttUnknown ttSymbol encountered: %s', [FInput[i]]));
			end else
			begin
				Inc(FInputPos); // prekoci whitespace?
			end;
		end;
	end;
	
	Token := TToken.Create('', ttEOF);
	Result := Token;
end;


end.