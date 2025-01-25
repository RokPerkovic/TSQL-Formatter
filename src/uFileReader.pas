{$mode objfpc}
unit uFileReader;

interface
uses SysUtils, Classes;

// class TFileReader
const BuffSize = 512; 

type 
	TFileReader = class
	
	private
		FFileName: String;
		//FFile: File;
		FBuff: array of byte;
		FFileStream: TFileStream;
		FBytesRead, FBuffPos: Integer;
		FInput: AnsiString;
	
		procedure Init();
		
	public
		constructor Create(FileName: String);
		destructor Destroy(); override;

		// reads file in blocks of size BuffSize, returns a next line on each NextLine function call
		function NextLine(): AnsiString;
end;


implementation

constructor TFileReader.Create(FileName: String);
begin
	FFileName := FileName;
	Init;
end;

destructor TFileReader.Destroy();
begin
	FFileStream.Free;
	inherited Destroy;
end;

procedure TFileReader.Init();
begin
	SetLength(FBuff, BuffSize);
	FInput := '';
	
	try
		FFileStream := TFileStream.Create(FFileName, fmOpenRead);
	except
		on E: EFOpenError do
		begin
			WriteLn('Error reading file ' + FFileName + ' because it is already used by another process.');
			exit;
		end;
	end;
	
	FBuffPos := 0;
	FBytesRead := 0;
end;

function TFileReader.NextLine(): AnsiString;
var
	Line, Block: AnsiString;
	NewLinePos: Integer;
	EOF: Boolean;
begin
	EOF := False;
	
	while True do
	begin
		NewLinePos := Pos(#13#10, FInput);
		
		if NewLinePos > 0 then 
		begin
			Line := Copy(FInput, 1, NewLinePos + 1);
			Delete(FInput, 1, NewLinePos + Length(sLineBreak) - 1);
			Result := Line;
			exit;
		end;
		
		if EOF then
		begin
			Result := FInput;
			FInput := '';
			exit;
		end;
		
		FBytesRead := FFileStream.Read(FBuff[0], BuffSize);
		
		if FBytesRead = 0 then
		begin
			EOF := True;
			Continue;
		end;
		
		SetString(Block, PAnsiChar(@FBuff[0]), FBytesRead);
		FInput := FInput + Block;
	end;

	Result := Line;
end;

end.