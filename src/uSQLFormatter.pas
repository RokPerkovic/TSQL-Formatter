{$mode objfpc}
unit uSQLFormatter;

interface
uses uLexan, uToken, sysUtils;

type 
	TSQLFormatter = class
	
	private
		FInputFile, FOutputFile: String;
		
	public
		constructor Create(inputFile: String; outputFile: String);
		procedure SQLFormat();
	
end;

implementation

constructor TSQLFormatter.Create(inputFile: String; outputFile: String);
begin
	FInputFile := inputFile;
	FOutputFile := outputFile;
end;


procedure TSQLFormatter.SQLFormat();
var
	//fr: TFileReader;
	Lexan: TLexan;
	//Line: AnsiString;
	//n, LineCount: Integer;
	Token: TToken;
	input: String;
begin
	input := 'select acKey from tHE_Move';
	
	Lexan := TLexan.Create({FInputFile} input);
	Token := Lexan.NextToken();
	Writeln(Token._toString);
	
	while Token.FType <> EOF do
	begin
		Token := Lexan.NextToken();
		Writeln(Token._toString);
	end;

	//WriteLn('Formatting ' + FInputFile);
	
	// Read file
	{fr := TFileReader.Create(FInputFile);
	LineCount := 2000;
	n := 0;

	try
    while n < LineCount do
    begin
      Line := fr.NextLine;
      if Line = '' then
				Break; // EOF
				
			n := n + 1;
      Write(Line); // Process the line
    end;
  finally
		//ReadLn();
    fr.Free;
  end;}

end;

end.