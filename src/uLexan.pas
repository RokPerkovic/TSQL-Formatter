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
	Whitespace: Array [0..3] of Char = (' ', #9, #10, #13);

type
	TLexan = class
		private
			FFileReader: TFileReader;
			FInput: String;
			FInputPos: Integer;
			FKeyWords: Array [0..11] of String;
			function MakeToken(): TToken;
			function IsKeyword(Lexem: String): Boolean;
			//function IsSymbol(c: Char): Boolean;
			//function IsOperator(Lexem: String): Boolean;
			function IsWhitespace(c: Char): Boolean;
			
			procedure printChars(s: String);
		public
			constructor Create({FileName: String} AInput: String);
			destructor Destroy(); override;
			function NextToken(): TToken;
			
end;

implementation

constructor TLexan.Create({FileName: String;} AInput: String);
begin
	//FFileReader := TFileReader.Create(FileName);
	FInput := AInput;
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

function TLexan.NextToken(): TToken;
begin

	Result := MakeToken();
	
	{
	for i := FInputPos to length(FInput) do
	begin
		Writeln(FInput[i]);
		FInputPos := FInputPos + 1;
		MakeToken();
	end;
	}

end;

{
function TLexan.NextToken(): TToken;
var
	NextLine: AnsiString;
	i: Integer;
	ch: Char;
	
begin
	Result := Nil;
	
	while True do
	begin
		NextLine := FFileReader.NextLine();
		
		if NextLine = '' then
		begin
			exit;
		end;
		
		// Tokenize the NextLine
		
		for i := 0 to Length(NextLine) do
		begin
			write(NextLine[i]);
			// list of keywords
			ch := NextLine[i];
			
			if ch > '' and ch < '' then
			begin
				MakeToken();
			end;
		end;
		
		//WriteLn(Length(NextLine));
	end;
end;
}

// najprej sestavis lexem (torej sestavljas do prvega whitespace-a) in potem z vsemi funkcijami preveris, kam spada
// glede na prvi prebran znak se odlocis, kaj bi lahko bil lexem, ki ga beres? npr. ce je prvi znak stevilka, gres v makeNumber
function TLexan.MakeToken(): TToken;
var
	i: Integer;
	Lexem: String;
	Token: TToken;
begin
	Lexem := '';
	
	//Writeln('Input pos: ', FInputPos, 'input len: ', length(FInput));
	
	if FInputPos > length(FInput) then
	begin
		Token := TToken.Create(Lexem, EOF);
		Result := Token;
		Exit;
	end;
	
	for i := FInputPos to length(FInput) do
	begin
		if IsWhitespace(FInput[i]) then
		begin
			//Writeln('IsWhitespace');
			FInputPos := FInputPos + 1;
			Break;
		end;
		
		if (FInput[i] = '/') or (FInput[i] = '-') then
		begin
			// check next character to see if it is a comment (*, -)
			// --, /* */
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
	
		Lexem := Lexem + FInput[i];
		FInputPos := FInputPos + 1;
	end;
	
	if IsKeyword(Lexem) then
	begin
		Token := TToken.Create(Lexem, keyword);
	end else
	begin
		Token := TToken.Create(Lexem, unknown);
	end;
	
	Result := Token;
end;


end.