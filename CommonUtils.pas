unit CommonUtils;

interface

uses
  System.SysUtils;

function StringInSet(const S: string; const StringSet: array of string): Boolean;
function FileExtInSet(const FileExt: string; const FileExtSet: array of string): Boolean;

implementation

function StringInSet(const S: string; const StringSet: array of string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := Low(StringSet) to High(StringSet) do
  begin
    if S = StringSet[I] then
    begin
      Result := True;
      Break;
    end;
  end;
end;

function FileExtInSet(const FileExt: string; const FileExtSet: array of string): Boolean;
begin
  Result := StringInSet(LowerCase(FileExt), FileExtSet);
end;

end.
