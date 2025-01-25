{$mode objfpc}

program Main;

uses SysUtils, uSQLFormatter, uFile;

var
	inputFile, outputFile: String;
	sqlFormatter: TSQLFormatter;

begin

	try
		// first argument: input file (mandatory)
		// second argument: ouput file (optional) - if not specified, the output is written in the input file
		
		if ParamCount = 0 then
		begin
			Raise Exception.Create('Input file not specified!');
		end;
		
		inputFile := ParamStr(1);
		outputFile := ParamStr(2);	
		
		if not FileExists(inputFile) then
		begin
			Raise Exception.Create('Input file does not exist!');
		end;
		
		if outputFile = '' then
		begin
			// rewrite the input file
			outputFile := inputFile; 
		end; {else
		begin
			if not fileExists(outputFile) then
			begin
				// create output file
			end;
		end;}
		
	except 
		on E: Exception do
		begin
			WriteLn(E.Message);
			exit;
		end;
	end;
	
	//WriteLn('Input file: ' + inputFile);
	//WriteLn('Output file: ' + outputFile);
	
	// call formatter
	sqlFormatter := TSQLFormatter.Create(inputFile, outputFile);
	sqlFormatter.SQLFormat();
	sqlFormatter.Free();
	
end.