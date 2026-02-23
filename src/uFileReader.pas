{$mode objfpc}
unit uFileReader;

interface
uses SysUtils, Classes;

// class TFileReader

type 
	TFileReader = class
	private
		FFileName: String;
	public
		constructor Create(FileName: String);
		function LoadFile(): String;
end;

implementation

constructor TFileReader.Create(FileName: String);
begin
	FFileName := FileName;
end;


function TFileReader.LoadFile(): String;
var
  SL: TStringList;
begin
	SL := TStringList.Create;
  try
    SL.LoadFromFile(FFileName, TEncoding.UTF8);  // Load as UTF-8
    Result := SL.Text;  // Join all lines into a single string
  finally
    SL.Free;
  end;
end;

end.