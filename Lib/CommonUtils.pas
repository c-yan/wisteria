unit CommonUtils;

interface

uses
  System.SysUtils;

function IsDirectory(const Filename: string): Boolean;
function Chop(S: string): string;
function StrToFloatDef(const S: string; Default: Extended): Extended;
function AvoidCollisionName(const FileName: string): string;
function StringInSet(const S: string; const StringSet: array of string): Boolean;
function FileExtInSet(const FileExt: string; const FileExtSet: array of string): Boolean;

implementation

function IsDirectory(const Filename: string): Boolean;
begin
  Result := (FileGetAttr(FileName) and faDirectory) <> 0;
end;

function Chop(S: string): string;
begin
  Result := Copy(S, 1, Length(S) - 1);
end;

function StrToFloatDef(const S: string; Default: Extended): Extended;
var
  Value: Extended;
begin
  if TextToFloat(PChar(S), Value, fvExtended) then Result := Value
  else Result := Default;
end;

function AvoidCollisionName(const FileName: string): string;
var
  I: Integer;
  Path, Name, Ext: string;
begin
  if not FileExists(FileName) then
  begin
    Result := FileName;
    Exit;
  end;
  I := 1;
  Path := ExtractFilePath(FileName);
  Name := ChangeFileExt(ExtractFileName(FileName), '');
  Ext := ExtractFileExt(FileName);
  while FileExists(Format('%s%s[%d]%s', [Path, Name, I, Ext])) do
    Inc(I);
  Result := Format('%s%s[%d]%s', [Path, Name, I, Ext]);
end;

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
