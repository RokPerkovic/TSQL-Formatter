{$mode objfpc}
unit uToken;

interface

uses sysUtils, TypInfo;

type
	TTokenType = (ttKeyword, ttIdentifier, ttQuotedIdentifier, ttLiteral, ttString, ttOper, ttSymbol, ttComment, ttUnknown, ttEOF);

type
	TToken = class
		private
		
		public
			FValue: String; // string representation of a token
			FType: TTokenType;
			constructor Create(TokenValue: String; TokenType: TTokenType);
			function _toString: String;
end;

implementation

constructor TToken.Create(TokenValue: String; TokenType: TTokenType);
begin
	FValue := LowerCase(TokenValue);
	FType := TokenType;
end;

function TToken._toString(): String;
begin
	//Writeln('FType: ', FType, 'FValue: ', FValue);
	Result := format('%s (%s)', [GetEnumName(TypeInfo(TTokenType), Ord(FType)), FValue]);
end;

end.