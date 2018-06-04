unit Helpers;

interface

uses
  System.Classes, System.SysUtils;

type
  TStreamHelper = class helper for TStream
    function ReadByte: Byte;
    function ReadString(Count: Integer): AnsiString;
    function ReadCardinal(Count: Integer; LittleEndian: Boolean): Cardinal;
    procedure Skip(Count: Integer);
  end;

implementation

var
  Buffer: array[0..1024] of Byte;

function TStreamHelper.ReadByte: Byte;
begin
  Self.Read(Result, 1);
end;

function TStreamHelper.ReadString(Count: Integer): AnsiString;
begin
  Self.Read(Buffer, Count);
  SetString(Result, PAnsiChar(@Buffer[0]), Count);
end;

function TStreamHelper.ReadCardinal(Count: Integer; LittleEndian: Boolean): Cardinal;
var
  I: Integer;
begin
  Result := 0;
  if (Count < 0) or (Count > 4) then raise Exception.Create('out of range');
  if LittleEndian then
  begin
    for I := 0 to Count - 1 do
      Result := Result + Self.ReadByte shl (I * 8);
  end
  else
  begin
    for I := 0 to Count - 1 do
      Result := (Result shl 8) + Self.ReadByte;
  end;
end;

procedure TStreamHelper.Skip(Count: Integer);
begin
  Self.Read(Buffer, Count);
end;

end.
