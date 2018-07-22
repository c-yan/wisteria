unit Logging;

interface

uses
  System.SysUtils;

procedure InitLogging(const FileName: string);
procedure Error(const Text: string);
procedure Warn(const Text: string);
procedure Info(const Text: string);
procedure Debug(const Text: string);

var
  DebugEnabled: Boolean = False;

implementation

var
  LogFileName: string = '';

procedure InitLogging(const FileName: string);
var
  F: TextFile;
begin
  LogFileName := FileName;
  if LogFileName = '' then
    Exit;
  if not DirectoryExists(ExtractFilePath(LogFileName)) then
    ForceDirectories(ExtractFilePath(LogFileName));
  if not FileExists(LogFileName) then
  begin
    AssignFile(F, LogFileName);
    try
      Rewrite(F);
    finally
      Close(F);
    end;
  end;
end;

procedure Log(const Category, Text: string);
var
  F: TextFile;
  T: string;
begin
  if LogFileName = '' then
    Exit;
  AssignFile(F, LogFileName);
  T := FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now());
  try
    Append(F);
    Writeln(F, Format('%s %-5s - %s', [T, Category, Text]));
  finally
    CloseFile(F);
  end;
end;

procedure Error(const Text: string);
begin
  Log('ERROR', Text);
end;

procedure Warn(const Text: string);
begin
  Log('WARN', Text);
end;

procedure Info(const Text: string);
begin
  Log('INFO', Text);
end;

procedure Debug(const Text: string);
begin
  if DebugEnabled then
    Log('DEBUG', Text);
end;

end.
