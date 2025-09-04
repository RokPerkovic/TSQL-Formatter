{$mode objfpc}
unit uToken;

interface

uses sysUtils, TypInfo;

type
	TTokenType = (keyword, identifier, literal, oper, symbol, comment, unknown, EOF);

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
	FValue := TokenValue;
	FType := TokenType;
end;

function TToken._toString(): String;
begin
	Result := format('%s (%s)', [GetEnumName(TypeInfo(TTokenType), Ord(FType)), QuotedStr(FValue)]);
end;

end.