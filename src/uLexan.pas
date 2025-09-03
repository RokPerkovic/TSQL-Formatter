{$mode objfpc}
unit uLexan;

interface
uses uToken, uFileReader;

type
	TLexan = class
		private
			FFileReader: TFileReader;
			//FKeyWords: TFPHashObjectList;
			function MakeToken(): TToken;
		public
			constructor Create(FileName: String);
			destructor Destroy(); override;
			function NextToken(): TToken;
			
end;

implementation

constructor TLexan.Create(FileName: String);
begin
	FFileReader := TFileReader.Create(FileName);

end;

destructor TLexan.Destroy();
begin
	FFileReader.Free;
	inherited Destroy;
end;

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
			
			if ch > '' and < '' then
			begin
				MakeToken();
			end;
		end;
		
		//WriteLn(Length(NextLine));
	end;
end;

function MakeToken(): TToken;
begin

end;

end.