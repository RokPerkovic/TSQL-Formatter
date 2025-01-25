{$mode objfpc}
unit uFileReader;

interface
uses SysUtils, Classes;
type
  TFileReader = class
  private
    FStream: TFileStream;
    FBuffer: array of Byte;
    FBufferSize: Integer;
    FBufferPos: Integer;
    FBufferEnd: Integer;
    FLineBuffer: string;
    function ReadBlock: Boolean;
  public
    constructor Create(const FileName: string; BufferSize: Integer = 512);
    destructor Destroy; override;
    function NextLine: string;
    function EOF: Boolean;
  end;

implementation
constructor TFileReader.Create(const FileName: string; BufferSize: Integer);
begin
  FStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  FBufferSize := BufferSize;
  SetLength(FBuffer, FBufferSize);
  FBufferPos := 0;
  FBufferEnd := 0;
  FLineBuffer := '';
end;

destructor TFileReader.Destroy;
begin
  FStream.Free;
  inherited Destroy;
end;

function TFileReader.ReadBlock: Boolean;
begin
  FBufferEnd := FStream.Read(FBuffer[0], FBufferSize);
  FBufferPos := 0;
  Result := FBufferEnd > 0;
end;

function TFileReader.NextLine: string;
var
  LineEndPos: Integer;
begin
  Result := '';
  while True do
  begin
    // Search for a newline character in the line buffer
    LineEndPos := Pos(#10, FLineBuffer);
    if LineEndPos > 0 then
    begin
      // Extract the line up to the newline
      Result := Copy(FLineBuffer, 1, LineEndPos - 1);
      Delete(FLineBuffer, 1, LineEndPos);

      // Handle Windows-style line endings (CRLF)
      if (Length(Result) > 0) and (Result[Length(Result)] = #13) then
        Delete(Result, Length(Result), 1);

      Exit;
    end;

    // If no newline, read more data into the buffer
    if FBufferPos >= FBufferEnd then
    begin
      if not ReadBlock then
      begin
        // End of file; return remaining buffer as the last line
        Result := FLineBuffer;
        FLineBuffer := '';
        Exit;
      end;
    end;

    // Append the current buffer content to the line buffer
    FLineBuffer := FLineBuffer + TEncoding.UTF8.GetString(FBuffer, FBufferPos, FBufferEnd - FBufferPos);
    FBufferPos := FBufferEnd;
  end;
end;

function TFileReader.EOF: Boolean;
begin
  Result := (FBufferPos >= FBufferEnd) and (FLineBuffer = '');
end;
end.
