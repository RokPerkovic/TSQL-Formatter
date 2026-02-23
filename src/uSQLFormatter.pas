{$mode objfpc}
unit uSQLFormatter;

interface
uses uLexan, uToken, sysUtils, uFileReader;

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
	fr: TFileReader;
	Lexan: TLexan;
	//Line: AnsiString;
	//n, LineCount: Integer;
	Token: TToken;
	input: String;
begin
	//input := 'select abc from the_order where acKey';
	
	fr := TFileReader.Create(FInputFile);
	input := fr.LoadFile();

	Lexan := TLexan.Create({FInputFile} input);
	//Lexan.PrintChars(input);
	
	try
		try
			Token := Lexan.NextToken();
			Writeln(Token._toString);
			
			while Token.FType <> ttEOF do
			begin
				Token := Lexan.NextToken();
				Writeln(Token._toString);
			end;
		except on E:Exception do
			Writeln(E.Message);
		end;
	finally
		Writeln('Finished');
		Lexan.Free;
		fr.Free;
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