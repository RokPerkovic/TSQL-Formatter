{$mode objfpc}
unit uLexan;

interface
uses uToken, uFileReader, classes, sysUtils;

const
	Keywords: Array [0..11] of String = ('select', 'from', 'where', 'order', 'top', 'join', 'left join', 'right join', 'as', 'group', 'by', 'is');
	
const 
	Symbols: Array [0..8] of Char = (',', '.', ';', '(', ')', '[', ']', '''', '"');
	
const
	SymbolNames: Array [0..8] of String = ('comma', 'dot', 'semicolon', 'left_paren', 'right_paren', 'left_square', 'right_square', 'single_quote', 'quote');
	
const
	Operators: Array [0..13] of String = ('=', 'in', 'not', '+', '-', '*', '/', '<', '>', '<>', '>=', '<=', 'and', 'or');
	
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
			//function IsSymbol(c: Char): Boolean;
			//function IsOperator(Lexem: String): Boolean;
			function IsWhitespace(c: Char): Boolean;
			function MakeQuotedIdentifier(): TToken;
			function MakeString(): TToken;
			function MakeNumber(): TToken;
			function MakeComment(): TToken;
			function MakeMultiLineComment(): TToken;
			function MakeIdentifier(): TToken;
			function MakeOperator(): TToken;
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
		if Keywords[k] = Lexem then
		begin
			Result := True;
			Exit;
		end;
	end;
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

function TLexan.MakeQuotedIdentifier(): TToken;
begin

end;

function TLexan.MakeString(): TToken;
begin

end;

function TLexan.MakeNumber(): TToken;
begin

end;

// build single-line comment (-- comment)
function TLexan.MakeComment(): TToken;
var
	Lexem: String;
	c: Char;
	Token: TToken;
begin
	Lexem := '--';
	c := FInput[FInputPos];
	
	while (c <> #10) and (c <> #0) do
	begin
		Lexem := Lexem + c;
		Inc(FInputPos, 2);
		c := FInput[FInputPos];
	end;
	
	Result := TToken.Create(Lexem, comment);
end;

// build multi-line comment 
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
    raise Exception.Create('Missing end comment mark ''*/''');

  Result := TToken.Create(Lexem, comment);
end;


function TLexan.MakeOperator(): TToken;
begin

end;

function TLexan.MakeIdentifier(): TToken;
var
	Lexem: String;
	c: Char;
	Token: TToken;
begin
	Lexem := '';
	c := FInput[FInputPos];
	
	while not IsWhitespace(c){((c >= 'a') and (c <= 'z')) or ((c >= 'A') and (c <= 'Z'))} do
	begin
		Lexem := Lexem + c;
		Inc(FInputPos);
		c := FInput[FInputPos];
	end;
	
	if IsKeyword(Lexem) then
	begin
		Token := TToken.Create(Lexem, keyword);
		Result := Token;
	end else
	begin
		Token := TToken.Create(Lexem, identifier);
		Result := Token;
	end;
	

end;

function TLexan.NextToken(): TToken;
begin
	Result := MakeToken();
end;


// najprej sestavis lexem (torej sestavljas do prvega whitespace-a) in potem z vsemi funkcijami preveris, kam spada
// glede na prvi prebran znak se odlocis, kaj bi lahko bil lexem, ki ga beres? npr. ce je prvi znak stevilka, gres v makeNumber
function TLexan.MakeToken(): TToken;
var
	i: Integer;
	NextChar: Char;
	Token: TToken;
begin
	
	for i := FInputPos to FInputLen do
	begin
		if ((FInput[i] >= 'a') and (FInput[i] <= 'z')) or ((FInput[i] >= 'A') and (FInput[i] <= 'Z')) then
		begin
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
				Result := MakeOperator();
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
				Result := MakeOperator();
				Exit;
			end;
		end else
		begin
			if not IsWhitespace(FInput[i]) then
			begin
				Raise Exception.Create(format('Unknown symbol encountered: %s', [FInput[i]]));
			end;
		end;
		{
		if (FInput[i] = '/') or (FInput[i] = '-') then
		begin
			// check next character to see if it is a comment (*, -)
			// --, /* */
			//Writeln('komentar');
			NextChar := Peek();
			if (NextChar = '*') or (NextChar = '-') then
			begin
				Writeln('komentar');
				FInputPos := FInputPos + 2;
				MakeComment();
			end;
		end;
		
		// quoted identifiers: "first name", [first name]
		if (FInput[i] = '"') or (FInput[i] = '[') then
		begin
			Result := MakeQuotedIdentifier();
			exit;
		end;
		
		if FInput[i] = '''' then
		begin
			Result := MakeString();
			exit;
		end;
		
		if (FInput[i] >= '0') and (FInput[i] <= '9') then
		begin
			Result := MakeNumber();
			exit;
		end;
		}
		//Lexem := Lexem + FInput[i];
		Inc(FInputPos);
		{if FInputPos > FInputLen then
		begin
			Token := TToken.Create(Lexem, EOF);
			Result := Token;
			Exit;
		end;}
	end;
	
	Token := TToken.Create('', EOF);
	Result := Token;
end;


end.