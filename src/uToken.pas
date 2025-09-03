{$mode objfpc}
unit uToken;

interface

type
	TToken = class
		private
		
		public
			FValue: String; // string representation of a token
			FType: String;
			constructor Create(TokValue: String; TokType: String);
end;

implementation

constructor TToken.Create(TokValue: String; TokType: String);
begin
	FValue := TokValue;
	FType := TokType;
end;

end.